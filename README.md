# Komorebi Design System

コモレビの全ツール共通デザインガイドラインです。

カラーパレット、フォント、コンポーネント、日本語テキスト整形ルールなどを一元管理しています。

## デザインシステム プレビュー

DESIGN.md の内容をビジュアルで確認できるページです。

カラー、タイポグラフィ、コンポーネント、アイコン、アニメーション、ダークモード、レスポンシブ、JP Formatting ルールなど全セクションをインタラクティブに閲覧できます。

https://komorebi-tools.github.io/design-system/

## 仕組み

Claude Code にコモレビの UI 制作を依頼すると、デザインが意図通りに出てきます。

プロンプトに「色は `#6E87B6` で、フォントは Plus Jakarta Sans で...」と毎回書く必要はありません。

理由は、プロジェクトに設計書を置いているからです。

Claude Code はセッション開始時にこれらを自動で読み込み、ルールに従って作業します。

```
design-system/
├── DESIGN.md                    ... デザイン仕様書 (色、フォント、余白、コンポーネント)
├── index.html                   ... ビジュアルプレビュー (GitHub Pages)
├── contracts/
│   └── rules.json               ... 禁止ルール9件 (hook で自動チェック)
├── hooks/
│   └── design-check.sh          ... 違反を検出する hook の本体 (各自 ~/.claude/hooks/ へコピー)
├── scripts/
│   ├── check-hook.mjs           ... hook の受け入れテスト
│   └── check-rules.mjs          ... rules.json 自体の受け入れテスト
├── tests/
│   └── fixtures/                ... テストが使う rules.json の固定コピー
├── assets/
│   ├── logo/                    ... ロゴ素材 (PNG 透過、JPG 白背景)
│   └── tools/                   ... 各ツールのロゴ SVG
└── .claude/
    └── skills/
        └── komorebi-design-system/
            └── SKILL.md         ... Claude Code 用スキル
```

### 各ファイルの役割

| ファイル | 何をしているか |
|---|---|
| [DESIGN.md](DESIGN.md) | 色、フォント、角丸、余白、シャドウを数値で定義。Claude Code はここを見てトークン準拠の CSS を書く |
| [SKILL.md](.claude/skills/komorebi-design-system/SKILL.md) | デザイントークン、情報ソース (コーポレートサイト、会社説明スライド)、品質 3 層定義 (L1/L2/L3)、アンチパターン、チェックリストを定義。Claude Code が UI を作る際の判断基準になる |
| [rules.json](contracts/rules.json) | 絵文字禁止、`#000000` 禁止、全角括弧禁止など 9 件の禁止ルール。ファイル編集のたびに hook が自動チェックし、違反があれば警告する |
| [index.html](index.html) | DESIGN.md をビジュアルで確認できるページ。チーム全員が同じトークンを見られる |

> 約物 ･ 記号の表記ルール ( 中黒 ･ スラッシュ ･ 引用符 ･ 括弧 ･ コロン ･ カンマ等の 11 項目 + 句点後改行ルール ) は [DESIGN.md §3.6](DESIGN.md) を一次情報源として参照してください。

#### 2026/9/1 の `NO_EMOJI` の変更について

判定基準を Unicode の定義 (`Extended_Pictographic`) に合わせました。**規則は 9 件のままです。**増えた側と減った側の両方があります。

**拾うようになったもの** — 二重感嘆符 `‼` (U+203C), 感嘆疑問符 `⁉` (U+2049), 情報記号 `ℹ` (U+2139), 左右矢印 `↔` (U+2194), 腕時計 `⌚` (U+231A) など。もともと禁止対象だったのに、旧パターンの範囲の下端が U+2600 だったため検出漏れしていた絵文字です。

**対象外になったもの** — `★` `☆` `♪` `✓` `✗` `❶` `➔` など。**Unicode 上これらは絵文字ではありません。**旧パターンの範囲 (U+2600 - U+27FF) が粗く、和文の組版記号として正当に使うものまで巻き込んで `error` にしていました。誤検出なので落としています。

既存ファイルを編集したときに警告の出方が変わることがありますが、規則が増減したのではなく、判定の基準が Unicode の定義に揃ったためです。

`✓` や `★` を擬似アイコンとして使うのをやめさせたい場合は、`NO_EMOJI` とは別の規則を立てる話になります。

### 品質を維持する仕組み

1. **DESIGN.md** がルールを定義する
2. **SKILL.md** が Claude Code に判断基準を与える
3. **rules.json + hook** が編集のたびに違反を自動検出する

この 3 層で、誰が作業しても品質がブレない構造になっています。

#### hook は各自の環境に入れる必要があります

3 の hook の本体は [hooks/design-check.sh](hooks/design-check.sh) です。

**このリポジトリに置いてあるだけでは動きません。**実際に動くのは `~/.claude/hooks/` に置いたコピーの方です。

```bash
# clone したディレクトリで実行する
cp hooks/design-check.sh ~/.claude/hooks/design-check.sh
chmod +x ~/.claude/hooks/design-check.sh
```

あわせて `~/.claude/settings.json` の `PostToolUse` (matcher: `Edit|Write`) に登録します。

**入れていない人の環境では機械チェックは一切効きません。**その場合でも編集は止まらないため、気づかないまま違反が入ります。

hook 本体はコピー先に置かれるため、`rules.json` の場所を自分で探します。順番は次のとおりです。

1. 環境変数 `KOMOREBI_RULES_FILE`
2. `~/claude/work/design-system/contracts/rules.json`
3. `~/design-system/contracts/rules.json` (下記「方法 1」で clone した場合)

**このどれとも違う場所に clone している場合は、`KOMOREBI_RULES_FILE` で明示してください。**

```bash
export KOMOREBI_RULES_FILE=/path/to/design-system/contracts/rules.json
```

**`rules.json` ･ `node` ･ `jq` のどれかが見つからないときは、黙って通さず「検査を飛ばした」と1行出します。**編集自体は止めません。「検査を飛ばした」と「違反なし」が見分けられることが大事なので、無出力で終わることはありません。

2026/9/1 まで hook は候補を1つしか見ておらず、そこに clone していない環境では**まるごと no-op** になっていました。**それに気づけなかったのは、黙って終わっていたからです。**探索順と失敗時の表示は、この一件を受けて入れています。

なお「。」改行チェックは、`<script` ･ `<style` ･ `//` ･ `/*` ･ `*/` のいずれかを含む行を除外します。**この条件は HTML の属性値やコメントを避けるためのものですが、URL の `//` にも当たります。**結果として `https://example.com` を含む行は、「。」の直後に文字が続いていても指摘されません (実測で確認済み)。

URL を除外することを狙って書かれた条件ではなく**現状そうなっているという既存の挙動**なので、見直す余地はあります。

---

## rules.json の pattern を書くときの決まり

`contracts/rules.json` の `pattern` の方言は **JS の `RegExp` ＋ `u` フラグ**です。`\p{...}` ･ 先読み `(?!…)` ･ `\u{...}` が使えます。

`rules.json` は JSON なのでコメントを書けず、トップレベルの配列構造も変えられません (読み手が `rules.length` ･ `rules.map` ･ `rules.find` を前提にしています)。そのため方言の決まりをここに書いています。

読み手は次の2つで、**どちらも Node で評価します**。

| 読み手 | 評価の仕方 |
| --- | --- |
| report-studio `utils/report-verify.js` の `DESIGN_RULE_CHECKS` | `new RegExp(rule.pattern, "gu")` |
| design-system の hook [hooks/design-check.sh](hooks/design-check.sh) | 同上 (bash から node を1回呼んで9件まとめて評価) |

**読み手を増やすときは、そのエンジンが同じ方言を解釈できるか必ず確認してください。**

2026/9/1 まで、hook 側だけが `grep -E` (POSIX ERE) でした。POSIX ERE は `\p{...}` を解釈できませんが、**エラーも出さずに「マッチ0件」を返します。**`NO_EMOJI` を `\p{Extended_Pictographic}` に変える直前にこれが判明しました。**あのまま grep で評価していたら、`NO_EMOJI` は誰にも気づかれないまま全件素通りしていました。**この一件を受けて hook を Node 評価に揃えています。

パターンを変えたら、次のテストを両方回してください。

```bash
node scripts/check-rules.mjs   # rules.json 自体 (9件 ･ 全 pattern が RegExp で生成できるか ･ NO_EMOJI の検出期待値)
node scripts/check-hook.mjs    # hook 経由の挙動 (9件の検出 / 非検出 ･ 各種スキップ表示)
```

---

## Claude Code スキル : komorebi-design-system

コモレビの UI / Web 制作時に、デザインシステムのルールを Claude Code が自動適用するスキルです。

### できること

- デザイントークン (カラー、タイポグラフィ、スペーシング、シャドウ) の自動適用
- アイコンルール (Material Icons 必須、絵文字禁止) の遵守
- ロゴ使用規定 (実画像 URL の参照、CSS 模造の禁止)
- コーポレートサイト、会社説明スライドからの実データ参照
- 制作完了チェックリストによる品質確認

### セットアップ

Claude Code を開いて、以下をそのまま貼り付けてください。

#### 方法 1 : このリポジトリを clone して使う (推奨)

> komorebi-tools/design-system リポジトリを ~/design-system に clone して。

clone したフォルダで Claude Code を開けば、スキルが自動的に有効になります。

#### 方法 2 : 今のプロジェクトにスキルを追加する

> komorebi-tools/design-system リポジトリから .claude/skills/komorebi-design-system/SKILL.md を取得して、このプロジェクトの同じパスに配置して。

#### 方法 3 : 全プロジェクトで有効にする (グローバル設定)

> komorebi-tools/design-system リポジトリから .claude/skills/komorebi-design-system/SKILL.md を取得して、~/.claude/skills/komorebi-design-system/SKILL.md に配置して。

### 使い方

セットアップ後、コモレビ関連の UI 制作を依頼するだけで自動適用されます。

> コモレビのランディングページを作って

> コモレビのサービス紹介ページの HTML を作って

> コモレビのダッシュボード UI を設計して

スキルが適用されると、以下が自動的に行われます :

- コーポレートサイト、会社説明スライド、デザインシステムの 3 ソースを参照
- デザイントークンに基づいた CSS の生成
- Material Icons の使用 (絵文字は使わない)
- 実画像ロゴの参照
- 制作完了チェックリストの実施

### スキルの更新

スキルが更新された場合、Claude Code に以下を伝えてください。

> design-system リポジトリから最新の SKILL.md を取得して上書きして。

---

## 社内向けの文書について

社内ツールの標準構成 (`STACK.md`) と作業記録は、2026/9/2 に別のリポジトリへ移しました。

**このリポジトリはデザインシステム本体 (色 ･ フォント ･ 約物ルール ･ 検査ルール) のみを扱います。**
