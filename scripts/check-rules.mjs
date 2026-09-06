#!/usr/bin/env node
// contracts/rules.json の受け入れ確認スクリプト (Node 標準のみ ･ 依存追加なし)
// 使い方 : node scripts/check-rules.mjs
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const RULES_PATH = join(root, "contracts", "rules.json");
const EXPECTED_COUNT = 8;

let failed = 0;
const check = (label, ok, detail = "") => {
  if (!ok) failed++;
  console.log(`${ok ? "PASS" : "FAIL"}  ${label}${detail ? "  " + detail : ""}`);
};

// --- 1. JSON として妥当 ･ 8件のまま -------------------------------------
let rules;
try {
  rules = JSON.parse(readFileSync(RULES_PATH, "utf8"));
} catch (e) {
  console.log(`FAIL  rules.json が JSON として不正 : ${e.message}`);
  process.exit(1);
}
check("rules.json が JSON として妥当", true);
check(`規則が ${EXPECTED_COUNT} 件`, rules.length === EXPECTED_COUNT, `実際 : ${rules.length} 件`);

// --- 2. 全 pattern が new RegExp(pattern, "gu") で生成できる --------------
for (const r of rules) {
  let ok = true, msg = "";
  try {
    new RegExp(r.pattern, "gu");
  } catch (e) {
    ok = false;
    msg = e.message;
  }
  check(`RegExp 生成 : ${r.id}`, ok, msg);
}

// --- 3. NO_EMOJI の検出期待値 -------------------------------------------
const emoji = rules.find((r) => r.id === "NO_EMOJI");
check("NO_EMOJI が存在", Boolean(emoji));
check("NO_EMOJI severity は error", emoji?.severity === "error");
check("NO_EMOJI detector は regex", emoji?.detector === "regex");

const CASES = [
  { group: "取りこぼしていた絵文字", chars: ["‼", "⁉", "ℹ", "↔", "⌚"], expect: true },
  { group: "現行どおり検出", chars: ["😀", "🌀", "☀", "🪀"], expect: true },
  { group: "肌の色の修飾子", chars: ["\u{1F3FB}", "\u{1F3FF}"], expect: true },
  { group: "著作権表記 (除外)", chars: ["©", "®", "™"], expect: false },
  { group: "通常文字 ･ 約物", chars: ["A", "1", "あ", "･", "→", ":", "("], expect: false },
];

const hit = (s) => new RegExp(emoji.pattern, "gu").test(s);
const cp = (s) => "U+" + s.codePointAt(0).toString(16).toUpperCase().padStart(4, "0");

const rows = [];
for (const { group, chars, expect } of CASES) {
  for (const c of chars) {
    const actual = hit(c);
    const ok = actual === expect;
    if (!ok) failed++;
    rows.push({ group, char: c, cp: cp(c), expect, actual, ok });
  }
}

// Markdown 表で出力 (SUMMARY.md 貼り付け用)
console.log("\n| 入力 | コードポイント | 分類 | 期待 | 実際 | 判定 |");
console.log("| --- | --- | --- | --- | --- | --- |");
const label = (b) => (b ? "検出する" : "検出しない");
for (const r of rows) {
  console.log(`| \`${r.char}\` | ${r.cp} | ${r.group} | ${label(r.expect)} | ${label(r.actual)} | ${r.ok ? "PASS" : "FAIL"} |`);
}

console.log(`\n${failed === 0 ? "OK : 全チェック pass" : `NG : ${failed} 件 fail`}`);
process.exit(failed === 0 ? 0 : 1);
