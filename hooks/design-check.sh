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

[[ "$FILE" == *"contracts/rules.json"* ]] && exit 0
[[ "$FILE" == *"DESIGN.md"* ]] && exit 0
[[ "$FILE" == *"SKILL.md"* ]] && exit 0

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
# 9件を1回の node 起動でまとめて評価する。PostToolUse は編集のたびに走るため、
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

for (const rule of rules) {
  let re;
  try {
    // report-studio の report-verify.js と同じ生成の仕方に揃える
    re = new RegExp(rule.pattern, "gu");
  } catch (e) {
    badPatterns.push(`規則 ${rule.id} の pattern を解釈できません : ${e.message}`);
    continue;
  }
  const hits = [];
  for (let i = 0; i < lines.length && hits.length < 3; i++) {
    re.lastIndex = 0; // g フラグは test() で状態を持つので毎回戻す
    if (re.test(lines[i])) hits.push(`  ${i + 1}:${lines[i]}`);
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
for (let i = 0; i < lines.length && periodHits.length < 5; i++) {
  if (PERIOD.test(lines[i]) && !SKIP_LINE.test(lines[i])) periodHits.push(`${i + 1}:${lines[i]}`);
}
if (periodHits.length > 0) {
  out += "\n--- 「。」改行チェック ---\n";
  out += "日本語は「。」ごとに改行してください (1文1行):\n";
  out += periodHits.join("\n") + "\n";
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
