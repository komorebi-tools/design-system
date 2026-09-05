#!/usr/bin/env node
// hooks/design-check.sh の受け入れテスト (Node 標準のみ ･ 依存追加なし)
//
// 使い方 : node scripts/check-hook.mjs
//
// なぜこのテストがあるか :
//   2026/9/1 に hook が「検査できていないのに違反なしとして通す」状態になっていた。
//   原因は2つ。(1) rules.json のパスが間違っていて毎回 no-op だった
//   (2) パターンの評価器が grep -E で、JS 方言の pattern を無言で0件にしていた。
//   どちらも「静かに通る」ため気づけなかった。ここでは
//   「検査できなかったことが見える形で出るか」までを確かめる。
import { readFileSync, writeFileSync, mkdtempSync, rmSync, mkdirSync, symlinkSync, existsSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";
import { tmpdir } from "node:os";
import { spawnSync } from "node:child_process";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const HOOK = join(root, "hooks", "design-check.sh");
const RULES_MAIN = join(root, "contracts", "rules.json");

let failed = 0;
const check = (label, ok, detail = "") => {
  if (!ok) failed++;
  console.log(`${ok ? "PASS" : "FAIL"}  ${label}${detail ? "  " + detail : ""}`);
};

const tmp = mkdtempSync(join(tmpdir(), "check-hook-"));
const write = (name, body) => {
  const p = join(tmp, name);
  mkdirSync(dirname(p), { recursive: true });
  writeFileSync(p, body);
  return p;
};

// hook を1回走らせる。env で経路を切り替える。
function runHook(targetFile, env = {}, hookPath = HOOK) {
  const r = spawnSync("bash", [hookPath], {
    input: JSON.stringify({ tool_input: { file_path: targetFile } }),
    encoding: "utf8",
    env: { ...process.env, ...env },
  });
  return { out: (r.stdout || "") + (r.stderr || ""), status: r.status };
}

// 指定の rules.json を使って、入力文字列に対し規則 id が検出されたかを返す
function detects(ruleId, body, rulesPath, ext = ".md") {
  const f = write(`case-${Math.abs(hashCode(ruleId + body + rulesPath))}${ext}`, body);
  const { out } = runHook(f, { KOMOREBI_RULES_FILE: rulesPath });
  return new RegExp(`\\] ${ruleId}:`).test(out);
}
function hashCode(s) {
  let h = 0;
  for (let i = 0; i < s.length; i++) h = (Math.imul(31, h) + s.charCodeAt(i)) | 0;
  return h;
}

// ---------------------------------------------------------------------------
console.log("=== 1. 静的チェック ===");
{
  const r = spawnSync("bash", ["-n", HOOK], { encoding: "utf8" });
  check("bash -n が構文エラーを出さない", r.status === 0, (r.stderr || "").trim());
  const src = readFileSync(HOOK, "utf8");
  check("grep の PCRE オプションが残っていない", !/grep\s+-[a-zA-Z]*P/.test(src));
  check('パターン評価が new RegExp(pattern, "gu")', src.includes('new RegExp(rule.pattern, "gu")'));
  const nodeInvocations = (src.match(/\$NODE_BIN"? -e/g) || []).length;
  check("node の起動は1回だけ (規則ごとに起動しない)", nodeInvocations === 1, `起動箇所 : ${nodeInvocations}`);
  check("エラーを 2>/dev/null で捨てていない", !src.includes("2>/dev/null)\nCHECK_STATUS"));
}

// ---------------------------------------------------------------------------
console.log("\n=== 2. 8件すべての挙動 (違反する入力 / 違反しない入力) ===");
const rules = JSON.parse(readFileSync(RULES_MAIN, "utf8"));
// 各規則につき、違反する入力と違反しない入力を1つずつ
const CASES = {
  NO_EMOJI: { bad: "見出し 😀 です", good: "見出し です" },
  NO_TEXT_BLACK: { bad: "color: #000000;", good: "color: #333333;" },
  NO_FULLWIDTH_SLASH: { bad: "A／B", good: "A / B" },
  NO_FULLWIDTH_PAREN: { bad: "これは（補足）です", good: "これは (補足) です" },
  NO_FULLWIDTH_COLON: { bad: "仮説：結論", good: "仮説 : 結論" },
  NO_FULLWIDTH_NAKAGURO: { bad: "Notion・Slack", good: "Notion ･ Slack" },
  NO_BORDER_RADIUS_50: { bad: "border-radius: 50%;", good: "border-radius: 8px;" },
  NO_HARDCODED_PRIMARY: { bad: "color: #6E87B6;", good: "color: var(--primary);" },
};
check(`規則が ${rules.length} 件 ･ 全件にテストケースがある`, rules.every((r) => CASES[r.id]), rules.map((r) => r.id).filter((id) => !CASES[id]).join(" "));

const rows2 = [];
for (const rule of rules) {
  const c = CASES[rule.id];
  if (!c) continue;
  const badHit = detects(rule.id, c.bad, RULES_MAIN);
  const goodHit = detects(rule.id, c.good, RULES_MAIN);
  const ok = badHit === true && goodHit === false;
  if (!ok) failed++;
  rows2.push({ id: rule.id, sev: rule.severity, bad: c.bad, badHit, good: c.good, goodHit, ok });
}
console.log("\n| 規則 | severity | 違反する入力 | 検出 | 違反しない入力 | 検出 | 判定 |");
console.log("| --- | --- | --- | --- | --- | --- | --- |");
for (const r of rows2) {
  console.log(`| ${r.id} | ${r.sev} | \`${r.bad}\` | ${r.badHit ? "する" : "しない"} | \`${r.good}\` | ${r.goodHit ? "する" : "しない"} | ${r.ok ? "PASS" : "FAIL"} |`);
}

// ---------------------------------------------------------------------------
console.log("\n=== 3. NO_EMOJI : 変更前の rules.json と 変更後の rules.json の比較 ===");
// 比較用の rules.json は tests/fixtures/ に固定してある。
// 以前は PR #4 のブランチを git 参照で直接読んでいたが、その PR が merge されて
// ブランチが消えた瞬間にこのテストが落ちるため、fixture に切り出した。
// 由来は tests/fixtures/README.md を参照。
const FIXTURE_DIR = join(root, "tests", "fixtures");
const RULES_BEFORE = join(FIXTURE_DIR, "rules-before.json");
const RULES_AFTER = join(FIXTURE_DIR, "rules-after.json");

let fixturesOk = true;
for (const [label, f] of [["rules-before.json", RULES_BEFORE], ["rules-after.json", RULES_AFTER]]) {
  if (!existsSync(f)) {
    // 比較できないことを pass と呼ばない
    console.log(`  FAIL : tests/fixtures/${label} が無いため比較できない (pass ではない)`);
    fixturesOk = false;
    failed++;
  }
}
if (fixturesOk) console.log(`  比較元 : tests/fixtures/rules-before.json ･ rules-after.json`);

const EMOJI_CASES = [
  { input: "\u{1F600}", expectBefore: true, expectAfter: true, note: "もともと検出できていた絵文字" },
  { input: "\u203C", expectBefore: false, expectAfter: true, note: "取りこぼしていた絵文字" },
  { input: "\u2049", expectBefore: false, expectAfter: true, note: "取りこぼしていた絵文字" },
  { input: "\u2605", expectBefore: true, expectAfter: false, note: "Unicode 上は絵文字でない記号" },
  { input: "\u266A", expectBefore: true, expectAfter: false, note: "Unicode 上は絵文字でない記号" },
  { input: "\u2713", expectBefore: true, expectAfter: false, note: "Unicode 上は絵文字でない記号" },
  { input: "\u2776", expectBefore: true, expectAfter: false, note: "Unicode 上は絵文字でない記号" },
  { input: "\u2794", expectBefore: true, expectAfter: false, note: "Unicode 上は絵文字でない記号" },
  { input: "\u00A9", expectBefore: false, expectAfter: false, note: "著作権表記" },
  { input: "\u00AE", expectBefore: false, expectAfter: false, note: "著作権表記" },
  { input: "\u2122", expectBefore: false, expectAfter: false, note: "著作権表記" },
];

console.log("\n| 入力 | 分類 | 変更前 : 期待 | 変更前 : 実際 | 変更後 : 期待 | 変更後 : 実際 | 判定 |");
console.log("| --- | --- | --- | --- | --- | --- | --- |");
const yn = (b) => (b ? "検出" : "非検出");
for (const c of EMOJI_CASES) {
  const gotBefore = fixturesOk ? detects("NO_EMOJI", `見出し ${c.input} です`, RULES_BEFORE) : null;
  const gotAfter = fixturesOk ? detects("NO_EMOJI", `見出し ${c.input} です`, RULES_AFTER) : null;
  const ok = fixturesOk && gotBefore === c.expectBefore && gotAfter === c.expectAfter;
  if (!ok) failed++;
  console.log(`| \`${c.input}\` | ${c.note} | ${yn(c.expectBefore)} | ${fixturesOk ? yn(gotBefore) : "SKIP"} | ${yn(c.expectAfter)} | ${fixturesOk ? yn(gotAfter) : "SKIP"} | ${ok ? "PASS" : "FAIL"} |`);
}

// ---------------------------------------------------------------------------
console.log("\n=== 4. RULES_FILE の解決経路 ===");
{
  const target = write("route.md", "見出し 😀 です");

  // ① KOMOREBI_RULES_FILE を指定
  const r1 = runHook(target, { KOMOREBI_RULES_FILE: RULES_MAIN });
  check("① KOMOREBI_RULES_FILE を指定した場合に検査が走る", r1.out.includes("] NO_EMOJI:") && r1.out.includes(`Rules: ${RULES_MAIN}`));

  // ② 候補パス ($HOME/claude/work/...) で見つかる場合
  const fakeHome = join(tmp, "home2");
  const dest = join(fakeHome, "claude", "work", "design-system", "contracts");
  mkdirSync(dest, { recursive: true });
  writeFileSync(join(dest, "rules.json"), readFileSync(RULES_MAIN));
  const r2 = runHook(target, { HOME: fakeHome, KOMOREBI_RULES_FILE: "" });
  check("② $HOME/claude/work/design-system/contracts/rules.json で見つかる",
    r2.out.includes("] NO_EMOJI:") && r2.out.includes(join(dest, "rules.json")));

  // ③ どこにも無い場合 : 黙って通さない
  const emptyHome = join(tmp, "home3");
  mkdirSync(emptyHome, { recursive: true });
  const r3 = runHook(target, { HOME: emptyHome, KOMOREBI_RULES_FILE: "" });
  const skipped = r3.out.includes("スキップ") && r3.out.includes("rules.json が見つからない") && r3.out.includes("探したパス");
  check("③ どこにも無い場合に「飛ばした」と探したパスが出る", skipped);
  check("③ そのとき「違反なし」(無出力) にならない", r3.out.trim().length > 0);
  console.log(`     実際の出力 : ${r3.out.trim().slice(0, 160)}…`);
}

// ---------------------------------------------------------------------------
console.log("\n=== 5. node が見つからない場合のフェイルラウド ===");
{
  const target = write("nonode.md", "見出し 😀 です");
  // PATH から node を外し、nvm も homebrew も見えない HOME にする
  const emptyHome = join(tmp, "home4");
  mkdirSync(emptyHome, { recursive: true });
  const r = spawnSync("bash", [HOOK], {
    input: JSON.stringify({ tool_input: { file_path: target } }),
    encoding: "utf8",
    env: {
      PATH: "/usr/bin:/bin:/usr/sbin:/sbin",
      HOME: emptyHome,
      KOMOREBI_RULES_FILE: RULES_MAIN,
      KOMOREBI_NODE: "",
    },
  });
  const out = (r.stdout || "") + (r.stderr || "");
  const loud = out.includes("スキップ") && out.includes("node が見つからない");
  check("node が無いとき「飛ばした」と出る", loud);
  check("そのとき「違反なし」(無出力) にならない", out.trim().length > 0);
  check("終了コードは 0 (編集は止めない)", r.status === 0, `実際 : ${r.status}`);
  console.log(`     実際の出力 : ${out.trim().slice(0, 160)}…`);
}

// ---------------------------------------------------------------------------
console.log("\n=== 6. 「。」改行チェック ===");
{
  const bad = write("period-bad.md", "これは一文目です。これは二文目です。\n");
  const good = write("period-good.md", "これは一文目です。\nこれは二文目です。\n");
  const skip = write("period-skip.md", '<script>const s = "一文目です。二文目です。";</script>\n');
  const rb = runHook(bad, { KOMOREBI_RULES_FILE: RULES_MAIN });
  const rg = runHook(good, { KOMOREBI_RULES_FILE: RULES_MAIN });
  const rs = runHook(skip, { KOMOREBI_RULES_FILE: RULES_MAIN });
  check("違反する入力で検出される", rb.out.includes("「。」改行チェック"), rb.out.trim().split("\n").pop());
  check("違反しない入力では検出されない", !rg.out.includes("「。」改行チェック"));
  check("<script> 行は除外される", !rs.out.includes("「。」改行チェック"));

  // URL を含む行は除外される (行内に // があるため)
  const url = write("period-url.md", "詳しくは https://example.com を見てください。これは二文目です。\n");
  const ru = runHook(url, { KOMOREBI_RULES_FILE: RULES_MAIN });
  check("URL (// を含む) の行は除外される", !ru.out.includes("「。」改行チェック"));
}

// ---------------------------------------------------------------------------
console.log("\n=== 6b. jq が見つからない場合のフェイルラウド (F6) ===");
// jq が無いと INPUT を解釈できず FILE が空になり、以前は静かに exit 0 していた。
// jq だけを外した PATH を作って確かめる。
function makeShimBin(dirName, exclude = []) {
  const bin = join(tmp, dirName);
  mkdirSync(bin, { recursive: true });
  const NEEDED = ["bash", "sh", "cat", "ls", "sort", "tail", "head", "dirname", "basename", "env", "grep", "sed"];
  for (const name of NEEDED) {
    if (exclude.includes(name)) continue;
    for (const d of ["/bin", "/usr/bin"]) {
      const src = join(d, name);
      if (existsSync(src)) {
        try { symlinkSync(src, join(bin, name)); } catch {}
        break;
      }
    }
  }
  return bin;
}
{
  const target = write("nojq.md", "見出し 😀 です");
  const shimBin = makeShimBin("bin-nojq", ["jq"]); // jq は最初から入れない
  const emptyHome = join(tmp, "home-nojq");
  mkdirSync(emptyHome, { recursive: true });

  const jqEnv = {
    PATH: shimBin,
    HOME: emptyHome,
    KOMOREBI_NODE: process.execPath,
    KOMOREBI_RULES_FILE: RULES_MAIN,
  };
  // shim に jq が無いことを先に確認しておく (前提が崩れたテストは意味がない)
  const probe = spawnSync("/bin/bash", ["-c", "command -v jq"], { encoding: "utf8", env: jqEnv });
  check("前提 : shim の PATH に jq が無い", probe.status !== 0, probe.stdout.trim());

  const runWith = (hookPath) => {
    const r = spawnSync("/bin/bash", [hookPath], {
      input: JSON.stringify({ tool_input: { file_path: target } }),
      encoding: "utf8",
      env: jqEnv,
    });
    return { out: (r.stdout || "") + (r.stderr || ""), stdout: r.stdout || "", status: r.status };
  };

  const r = runWith(HOOK);
  check("(1) 「スキップ」と「jq が見つからない」が出る",
    r.stdout.includes("スキップ") && r.stdout.includes("jq が見つからない"));
  check("(2) 出力が空にならない", r.stdout.trim().length > 0);
  check("(3) 終了コードは 0", r.status === 0, `実際 : ${r.status}`);
  console.log(`     実際の出力 : ${r.stdout.trim()}`);

  // このテストが本当に効くか : jq チェックを外した hook では静かに通ることを確認する
  const src = readFileSync(HOOK, "utf8");
  const without = src.replace(
    /# ─── jq が無いときは黙って終わらない ───[\s\S]*?\nfi\n/,
    ""
  );
  check("前提 : jq チェックを外した版を作れている", without !== src);
  const withoutPath = write("hook-no-jq-guard.sh", without);
  const rNo = runWith(withoutPath);
  const silent = rNo.stdout.trim().length === 0;
  check("jq チェックを外すと静かに通る (＝このテストが差を捕まえる)", silent,
    `外した版の stdout : [${rNo.stdout.trim()}] / stderr にのみ : ${(rNo.out.replace(rNo.stdout, "")).trim().slice(0, 80)}`);
}

// ---------------------------------------------------------------------------
console.log("\n=== 7. わざと壊して、テストが捕まえることを確認する ===");
// (a) u フラグを外す
{
  const src = readFileSync(HOOK, "utf8");
  const broken = src.replace('new RegExp(rule.pattern, "gu")', 'new RegExp(rule.pattern, "g")');
  const brokenPath = write("hook-no-u.sh", broken);
  const target = write("break-a.md", "見出し 😀 です");
  // 変更後の pattern は \u{...} と \p{...} を含むので、u フラグの有無がここで効く
  const useRules = fixturesOk ? RULES_AFTER : RULES_MAIN;
  const r = runHook(target, { KOMOREBI_RULES_FILE: useRules });
  const rBroken = spawnSync("bash", [brokenPath], {
    input: JSON.stringify({ tool_input: { file_path: target } }),
    encoding: "utf8",
    env: { ...process.env, KOMOREBI_RULES_FILE: useRules },
  });
  const outBroken = (rBroken.stdout || "") + (rBroken.stderr || "");
  const changed = outBroken !== r.out;
  check("(a) u フラグを外すと挙動が変わる (例外か検出漏れ)", changed,
    changed ? `壊した側 : ${outBroken.trim().split("\n")[0] || "(無出力)"}` : "差が出なかった");
  check("(a) 戻した hook では正常に検出される", r.out.includes("] NO_EMOJI:"));
}

// (b) エラーの握り潰しを復活させる
{
  const src = readFileSync(HOOK, "utf8");
  // 壊れた pattern を1つ混ぜた rules.json
  const withBad = JSON.parse(readFileSync(RULES_MAIN, "utf8"));
  withBad.push({
    id: "BROKEN_RULE", severity: "error", description: "壊れた pattern",
    detector: "regex", pattern: "[unclosed", alternative: "-",
  });
  const badRules = write("rules-broken.json", JSON.stringify(withBad, null, 2));
  const target = write("break-b.md", "普通の文です\n");

  // 現行 : 見える形で出る
  const rNow = runHook(target, { KOMOREBI_RULES_FILE: badRules });
  const visible = rNow.out.includes("検査できなかった規則があります") && rNow.out.includes("BROKEN_RULE");
  check("(b) 現行 : 壊れた pattern が見える形で出る", visible, rNow.out.trim().split("\n")[1] || "");

  // 握り潰し版 : 何も出ずに「違反なし」に見える
  let swallowed = src
    .replace(/badPatterns\.push\([^;]+;/, "/* 握り潰し */")
    .replace('CHECK_OUT=$("$NODE_BIN" -e "$NODE_SRC" "$RULES_FILE" "$FILE" 2>&1)',
             'CHECK_OUT=$("$NODE_BIN" -e "$NODE_SRC" "$RULES_FILE" "$FILE" 2>/dev/null)');
  const swallowPath = write("hook-swallow.sh", swallowed);
  const rSwallow = spawnSync("bash", [swallowPath], {
    input: JSON.stringify({ tool_input: { file_path: target } }),
    encoding: "utf8",
    env: { ...process.env, KOMOREBI_RULES_FILE: badRules },
  });
  const outSwallow = (rSwallow.stdout || "") + (rSwallow.stderr || "");
  const silent = !outSwallow.includes("BROKEN_RULE");
  check("(b) 握り潰し版では「違反なし」で通ってしまう (＝このテストが差を捕まえる)", silent && visible,
    `握り潰し版の出力 : ${outSwallow.trim() || "(無出力)"}`);
}

rmSync(tmp, { recursive: true, force: true });
console.log(`\n${failed === 0 ? "OK : 全チェック pass" : `NG : ${failed} 件 fail`}`);
process.exit(failed === 0 ? 0 : 1);
