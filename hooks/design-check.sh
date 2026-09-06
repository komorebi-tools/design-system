#!/bin/bash
# Komorebi Design System — post-edit hook
# Edit/Write で保存されたファイルに禁止パターンがないかチェックする
#
# 導入 : このファイルを ~/.claude/hooks/design-check.sh へコピーし、
#        ~/.claude/settings.json の PostToolUse (matcher: Edit|Write) に登録する。
#        リポジトリ側を直しても、実際に動くのはコピーの方なので入れ直しが要る。
#
# パターンの評価は Node で行う。理由 :
#   rules.json の pattern は JS の RegExp ＋ u フラグの方言で書かれており、
#   report-studio の report-verify.js も同じ方言で評価している。
#   以前はここで grep -nE を使っていたが、POSIX ERE は \p{...} も先読みも解釈できず、
#   しかもエラーを出さずに「マッチ0件」を返すため、壊れても誰も気づけなかった。
#   評価器を report-studio と揃えることで、この食い違いをなくす。

# ─── node を探す ───
# hook は非対話で起動されるため、nvm で入れた node は PATH に載らない。
find_node() {
  if [ -n "${KOMOREBI_NODE:-}" ] && [ -x "$KOMOREBI_NODE" ]; then
    echo "$KOMOREBI_NODE"; return 0
  fi
  if command -v node >/dev/null 2>&1; then
    command -v node; return 0
  fi
  local newest
  newest=$(ls -d "$HOME"/.nvm/versions/node/*/bin/node 2>/dev/null | sort -V | tail -1)
  if [ -n "$newest" ] && [ -x "$newest" ]; then
    echo "$newest"; return 0
  fi
  local c
  for c in /opt/homebrew/bin/node /usr/local/bin/node; do
    if [ -x "$c" ]; then echo "$c"; return 0; fi
  done
  return 1
}

NODE_BIN=$(find_node)

# ─── jq が無いときは黙って終わらない ───
# INPUT の解釈に jq を使うため、無いと FILE が空になり
# 「対象ファイルなし」として静かに exit 0 していた。
# node ･ rules.json の不在と同じ扱いにする。
if ! command -v jq >/dev/null 2>&1; then
  echo "[Design System Check] スキップ : jq が見つからないため設計チェックを行いませんでした (PATH を確認)。brew install jq で入ります"
  exit 0
fi

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.filePath // empty')

[ -z "$FILE" ] && exit 0
[ ! -f "$FILE" ] && exit 0

case "$FILE" in
  *.html|*.css|*.js|*.ts|*.tsx|*.jsx|*.vue|*.svelte|*.md) ;;
  *) exit 0 ;;
esac

# ─── ファイル単位の除外は contracts/rules.json だけ ───
# 規則を説明する文書は規則違反そのものを引用するが、ファイル単位で除外すると
# 引用も実違反もまとめて黙る。実際 DESIGN.md には地の文の実違反が43行たまっていて、
# 2026/9/3 の PR #2 まで誰も気づいていなかった。除外があったからである。
# 意図的な違反 (引用) は下の「行単位の許可注釈」で 1行 ･ 1規則ずつ黙らせる。
#
# contracts/rules.json だけは残す。JSON にはコメントを書けず、注釈を置く場所がない。
# description に禁止文字そのものを書いている行が7件あり、他に黙らせる手段がないため。
# パスは末尾の厳密一致にする。以前は *"contracts/rules.json"* の部分一致だったため、
# docs/contracts/rules.json.md のような無関係なパスまで黙っていた。
# (上の拡張子ガードに .json は無いので通常はそこで止まるが、除外の意図として残す)
case "$FILE" in
  contracts/rules.json|*/contracts/rules.json) exit 0 ;;
esac

# ─── node が無いときは黙って終わらない ───
# 「node が無くて検査を飛ばした」と「違反なし」は区別できなければならない。
if [ -z "$NODE_BIN" ]; then
  echo "[Design System Check] スキップ : node が見つからないため設計チェックを行いませんでした (PATH ･ \$HOME/.nvm ･ /opt/homebrew/bin ･ /usr/local/bin を確認)。KOMOREBI_NODE で明示できます"
  exit 0
fi

# ─── rules.json を探す ───
# 環境変数が最優先。無ければ候補を順に探す。
# README の「方法1」は ~/design-system に clone する案内なので、そちらも候補に残す。
RULES_CANDIDATES=(
  "$HOME/claude/work/design-system/contracts/rules.json"
  "$HOME/design-system/contracts/rules.json"
)

RULES_FILE="${KOMOREBI_RULES_FILE:-}"
if [ -z "$RULES_FILE" ] || [ ! -f "$RULES_FILE" ]; then
  RULES_FILE=""
  for _c in "${RULES_CANDIDATES[@]}"; do
    if [ -f "$_c" ]; then RULES_FILE="$_c"; break; fi
  done
fi

# ─── rules.json が無いときも黙って終わらない ───
if [ -z "$RULES_FILE" ]; then
  _searched=$(printf '%s / ' "${KOMOREBI_RULES_FILE:-(KOMOREBI_RULES_FILE 未設定)}" "${RULES_CANDIDATES[@]}")
  echo "[Design System Check] スキップ : rules.json が見つからないため設計チェックを行いませんでした (探したパス : ${_searched% / })。KOMOREBI_RULES_FILE で明示できます"
  exit 0
fi

# ─── 検査本体 ───
# 8件を1回の node 起動でまとめて評価する。PostToolUse は編集のたびに走るため、
# 規則ごとに node を起動しない。
read -r -d '' NODE_SRC <<'NODEJS'
const fs = require("fs");
const [rulesPath, filePath] = process.argv.slice(1);

const fail = (msg) => {
  // stdout に出す。stderr だけだと呼び出し側の扱い次第で消える。
  process.stdout.write("[Design System Check] " + msg + "\n");
  process.exit(2);
};

let rules;
try {
  rules = JSON.parse(fs.readFileSync(rulesPath, "utf8"));
} catch (e) {
  fail("rules.json を読めません : " + e.message);
}
if (!Array.isArray(rules)) fail("rules.json のトップレベルが配列ではありません");

let text;
try {
  text = fs.readFileSync(filePath, "utf8");
} catch (e) {
  fail("対象ファイルを読めません : " + e.message);
}
const lines = text.split("\n");

const blocks = [];
const badPatterns = [];
let count = 0;

// ─── 行単位の許可注釈 ───
// 書式 :
//   design-check: allow <RULE_ID>[,<RULE_ID>...]
//       その行だけを黙らせる。注釈しか書かれていない行なら、次の1行も覆う。
//   design-check: allow-block <RULE_ID>[,<RULE_ID>...]
//       コードフェンスの行に置き、そのブロック全体を覆う。
//
// 覆う範囲を「その行だけ」に寄せているのは、内容のある行の末尾に付けた注釈が
// 次の行まで届くと、あとから足した行が黙って飲まれるため。
// 次の行を覆うのは「注釈しか書かれていない行」= 次の行のために書かれた行だけにする。
// コードブロックの中は HTML コメントがそのまま表示されて注釈を置けないので、
// フェンス行に置く allow-block でブロック全体を覆う。
const PERIOD_RULE_ID = "NO_PERIOD_LINEBREAK";
const RULE_IDS = new Set([...rules.map((r) => r.id), PERIOD_RULE_ID]);
const ALLOW_MARK = /design-check:[ \t]*(allow-block|allow)\b/g;
// ID の並びだけを取る。`-->` や `*/` は文字クラスに入らないので自然にそこで止まる。
const ALLOW_IDS = /^[ \t]*([A-Za-z_][A-Za-z0-9_]*(?:[ \t]*,[ \t]*[A-Za-z_][A-Za-z0-9_]*)*)/;
// 注釈を取り除いた残りがコメント記号と空白だけなら「注釈だけの行」
const COMMENT_ONLY = /^[\s<>!\-\/*#;%]*$/;
const FENCE = /^[ \t]{0,3}(`{3,}|~{3,})/;

const allowEntries = []; // { at, id, from, to, kind, used }
const allowProblems = [];

for (let i = 0; i < lines.length; i++) {
  const found = [];
  ALLOW_MARK.lastIndex = 0;
  let m;
  while ((m = ALLOW_MARK.exec(lines[i])) !== null) {
    const kind = m[1];
    const idMatch = ALLOW_IDS.exec(lines[i].slice(ALLOW_MARK.lastIndex));
    if (!idMatch) {
      // 引数なしは受け付けない。黙って無視もしない。
      allowProblems.push(`${i + 1} 行目 : ${kind} に規則 ID がありません。黙らせる規則 ID を必ず書いてください`);
      found.push({ kind, ids: [], span: m[0] });
      continue;
    }
    found.push({ kind, ids: idMatch[1].split(",").map((x) => x.trim()), span: m[0] + idMatch[0] });
    ALLOW_MARK.lastIndex += idMatch[0].length;
  }
  if (found.length === 0) continue;

  // その行が「注釈だけの行」か ･ フェンス行かで、覆う範囲が変わる
  let rest = lines[i];
  for (const f of found) rest = rest.replace(f.span, "");
  const commentOnly = COMMENT_ONLY.test(rest);
  const fence = FENCE.exec(lines[i]);

  for (const f of found) {
    let from = i;
    let to = i;
    if (f.kind === "allow-block") {
      if (!fence) {
        allowProblems.push(`${i + 1} 行目 : allow-block はコードフェンスの行にだけ置けます。1行だけ黙らせるなら allow を使ってください`);
        continue;
      }
      const close = new RegExp("^[ \\t]{0,3}[" + fence[1][0] + "]{" + fence[1].length + ",}[ \\t]*$");
      to = lines.length - 1;
      for (let j = i + 1; j < lines.length; j++) {
        if (close.test(lines[j])) { to = j; break; }
      }
    } else if (commentOnly) {
      to = i + 1; // 注釈だけの行は、次の行のために書かれている
    }
    for (const id of f.ids) {
      if (/^(all|any)$/i.test(id)) {
        allowProblems.push(`${i + 1} 行目 : ${f.kind} ${id} は受け付けません。黙らせる規則 ID を1つずつ書いてください`);
        continue;
      }
      if (!RULE_IDS.has(id)) {
        allowProblems.push(`${i + 1} 行目 : ${f.kind} に未知の規則 ID \`${id}\` があります`);
        continue;
      }
      allowEntries.push({ at: i, id, from, to, kind: f.kind, used: false });
    }
  }
}

// 行 -> その行を覆っている注釈
const coverage = new Map();
for (const e of allowEntries) {
  for (let k = e.from; k <= e.to && k < lines.length; k++) {
    if (!coverage.has(k)) coverage.set(k, []);
    coverage.get(k).push(e);
  }
}

// その行のその規則が黙らされているか。使われた注釈には印を付ける。
const silence = (lineIdx, ruleId) => {
  const es = coverage.get(lineIdx);
  if (!es) return false;
  let hit = false;
  for (const e of es) if (e.id === ruleId) { e.used = true; hit = true; }
  return hit;
};

// pattern が壊れている規則は「使われていない注釈」を判定できない
const uncheckable = new Set();

for (const rule of rules) {
  let re;
  try {
    // report-studio の report-verify.js と同じ生成の仕方に揃える
    re = new RegExp(rule.pattern, "gu");
  } catch (e) {
    badPatterns.push(`規則 ${rule.id} の pattern を解釈できません : ${e.message}`);
    uncheckable.add(rule.id);
    continue;
  }
  const hits = [];
  // 使われていない注釈を数えるため、報告が3件で足りても最後まで走査する。
  for (let i = 0; i < lines.length; i++) {
    re.lastIndex = 0; // g フラグは test() で状態を持つので毎回戻す
    if (!re.test(lines[i])) continue;
    if (silence(i, rule.id)) continue;
    if (hits.length < 3) hits.push(`  ${i + 1}:${lines[i]}`);
  }
  if (hits.length > 0) {
    count++;
    blocks.push(`[${rule.severity}] ${rule.id}: ${rule.description}\n  -> ${rule.alternative}\n${hits.join("\n")}\n\n`);
  }
}

let out = "";
if (count > 0) {
  out += `--- Design System Check: ${count} violation(s) ---\n\n`;
  out += blocks.join("") + "\n";
  out += `Rules: ${rulesPath}\n`;
}

// ─── 「。」改行チェック (日本語は「。」ごとに改行) ───
// HTML タグ内の属性値や <script>/<style> ブロック内は除外
// テキストコンテンツで「。」の後に日本語が続く行を検出
// 以前は grep の PCRE モードを使っていたが、BSD grep はそのオプションを持たず
// invalid option になるため、macOS ではこの検査は一度も動いていなかった。
const PERIOD = /。[^<\n"')\]}>）」』】\s]/u;
const SKIP_LINE = /<script|<style|\/\/|\/\*|\*\//;
const periodHits = [];
for (let i = 0; i < lines.length; i++) {
  if (!PERIOD.test(lines[i]) || SKIP_LINE.test(lines[i])) continue;
  // この検査も allow NO_PERIOD_LINEBREAK で黙らせられる
  if (silence(i, PERIOD_RULE_ID)) continue;
  if (periodHits.length < 5) periodHits.push(`${i + 1}:${lines[i]}`);
}
if (periodHits.length > 0) {
  out += "\n--- 「。」改行チェック ---\n";
  out += "日本語は「。」ごとに改行してください (1文1行):\n";
  out += periodHits.join("\n") + "\n";
}

// ─── 注釈そのものの問題を報告する ───
// 知らない規則 ID ･ ID 無し ･ allow all は、黙って無視しない。
if (allowProblems.length > 0) {
  out += "\n--- Design System Check: allow 注釈の問題 ---\n";
  for (const m of allowProblems) out += "[allow] " + m + "\n";
}

// ─── 使われていない注釈を報告する ───
// 印は書き忘れれば鳴り、要らなくなれば言ってくる。
// 放置すると印が古びて、いつの間にか本物を黙らせる。
const staleAllows = [];
for (const e of allowEntries) {
  if (uncheckable.has(e.id)) continue; // pattern が壊れていて判定できない
  if (!e.used) {
    const range = e.from === e.to ? "その行" : `${e.from + 1}-${e.to + 1} 行目`;
    staleAllows.push(`${e.at + 1} 行目 : ${e.id} の ${e.kind} が付いていますが、${range}に ${e.id} の違反はありません`);
  }
}
if (staleAllows.length > 0) {
  out += "\n--- Design System Check: 不要な allow ---\n";
  for (const m of staleAllows) out += "[allow] " + m + "\n";
  out += "要らなくなった注釈は消してください\n";
}

// 壊れた pattern は必ず見える形で出す。黙って0件にしない。
if (badPatterns.length > 0) {
  out += "\n--- Design System Check: 検査できなかった規則があります ---\n";
  for (const m of badPatterns) out += "[skipped] " + m + "\n";
  out += "違反なしと解釈しないでください\n";
}

process.stdout.write(out);
process.exit(badPatterns.length > 0 ? 3 : 0);
NODEJS

# エラーを握り潰さない (2>/dev/null を付けない)。
# 今回の事故は「黙って0件」が原因なので、node の失敗は必ず表に出す。
CHECK_OUT=$("$NODE_BIN" -e "$NODE_SRC" "$RULES_FILE" "$FILE" 2>&1)
CHECK_STATUS=$?

[ -n "$CHECK_OUT" ] && printf '%s\n' "$CHECK_OUT"

if [ "$CHECK_STATUS" -ne 0 ] && [ "$CHECK_STATUS" -ne 3 ]; then
  echo "[Design System Check] 警告 : 検査が正常に終了しませんでした (node 終了コード ${CHECK_STATUS})。違反なしと解釈しないでください"
fi

exit 0
