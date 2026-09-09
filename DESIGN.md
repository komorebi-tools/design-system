# DESIGN.md — komorebi tools

> このファイルはAIエージェントが正確な日本語UIを生成するためのデザイン仕様書です。
> コモレビ 全ツール共通のデザインガイドラインとして適用されます。
> セクションヘッダーは英語、値の説明は日本語で記述しています。

---

## 0. Logo Assets

ロゴ原本の格納先: `~/Documents/仕事系/コモレビ/_ロゴ/komorebi-logo/`

### バリエーション

| 名称 | 用途 | ファイル |
|---|---|---|
| Wide (横長) | ヘッダー、メール署名など横幅が取れる場所 | `png_bg-clear/logo-clear-wide.png` / `jpg_bg-white/logo-white-wide.jpg` |
| Short (縦型) | 正方形に近いスペース、OGP、名刺など | `png_bg-clear/logo-short.png` / `jpg_bg-white/logo-white-short.jpg` |
| Symbol (シンボルマーク) | favicon、アイコン、小スペース | `png_bg-clear/logo-clear-symbol.png` / `jpg_bg-white/logo-white-symbol.jpg` |

### フォーマット

| フォーマット | ディレクトリ | 備考 |
|---|---|---|
| PNG (透過) | `png_bg-clear/` | Web、アプリUI向け。背景透過 <!-- design-check: allow NO_PERIOD_LINEBREAK --> |
| JPG (白背景) | `jpg_bg-white/` | 印刷物、白背景前提の用途 |
| AI (ベクター) | `ai_vector/` | 編集 ･ 高解像度出力用。`komorebi_logo.ai` <!-- design-check: allow NO_PERIOD_LINEBREAK --> |

### ロゴの特徴

- 水彩テクスチャの円が重なり合うシンボルマーク
- ロゴタイプは小文字の `komorebi` + カタカナ `コモレビ` のルビ表記
- ロゴカラーは Primary (`#6E87B6`) 系のブルーグレー <!-- design-check: allow NO_HARDCODED_PRIMARY -->

### 使用ルール

- シンボルマークとロゴタイプの比率 ･ 配置はオリジナルを維持すること
- 最小表示サイズ: Symbol 24px、Short 48px、Wide 120px (幅基準)
- 背景色が暗い場合は PNG 透過版を使用し、白背景の場合は JPG 版でも可
- ロゴの色やテクスチャを改変しないこと

---

## 1. Visual Theme & Atmosphere

- **デザイン方針**: クリーンで信頼感がありつつ、柔らかさと透明感を持つ
- **密度**: 適度な余白を取った業務ツールUI。
  情報を詰め込みすぎない
- **キーワード**: 透明感、水彩、信頼、シンプル、やさしい

---

## 2. Color Palette & Roles

### Primary (ブランドカラー)

- **Primary** (`#6E87B6`): コモレビブルー。 <!-- design-check: allow NO_HARDCODED_PRIMARY -->
  CTAボタン、リンク、アクセントに使用
- **Primary Light** (`#9BB0D0`): 背景のアクセント、ホバー状態の背景
- **Primary Dark** (`#5A74A3`): ホバー ･ プレス時のボタン色

### Secondary / Accent (セカンダリカラー)

- **Accent** (`#C4A55A`): ゴールド。
  注目させたいCTA、バッジ、ハイライトに使用
- **Accent Dark** (`#B0923E`): ホバー ･ プレス時のアクセント色
- **Accent Light** (`#E0D5A8`): 背景のアクセント、バッジ背景

### Semantic (意味的な色)

- **Danger** (`#D9534F`): エラー、削除、危険な操作
- **Warning** (`#F0AD4E`): 警告、注意喚起
- **Success** (`#5CB85C`): 成功、完了
- **Info** (`#6E87B6`): 情報 (Primary と同系色) <!-- design-check: allow NO_HARDCODED_PRIMARY -->

### Neutral (ニュートラル)

- **Text Primary** (`#333333`): 本文テキスト
- **Text Secondary** (`#666666`): 補足テキスト、ラベル
- **Text Disabled** (`#AAAAAA`): 無効状態のテキスト
- **Border** (`#E0E0E0`): 区切り線、入力欄の枠
- **Background** (`#F7F7F7`): ページ背景
- **Surface** (`#FFFFFF`): カード、モーダル等の面

### 図表 ･ スライド

図表 ( グラフ ･ 図解 ･ 表 ) とスライドの配色は [FIGURE.md](FIGURE.md) を参照する。
色の値の一次情報源はこのファイルのままで、`FIGURE.md` は使い方と図表固有の規約だけを持つ。
図表のプレビューは [figure.html](figure.html)。

---

## 3. Typography Rules

### 3.1 和文フォント

- **ゴシック体**: Noto Sans JP

### 3.2 欧文フォント

- **サンセリフ**: Plus Jakarta Sans
- **等幅**: SFMono-Regular, Consolas, Menlo

### 3.3 font-family 指定

本文、見出し :

```css
font-family: "Plus Jakarta Sans", "Noto Sans JP", sans-serif;
```

等幅 (コード表示) :

```css
font-family: "SFMono-Regular", "Consolas", "Menlo", monospace;
```

**フォールバックの考え方**:
- Plus Jakarta Sans を先に指定し、欧文は Plus Jakarta Sans のグリフを優先
- 和文は Noto Sans JP にフォールバック
- 最後に generic family (sans-serif) を指定

### 3.4 文字サイズ ･ ウェイト階層

| Role | Font | Size | Weight | Line Height | Letter Spacing | 備考 |
|------|------|------|--------|-------------|----------------|------|
| Title-XL | Plus Jakarta Sans, Noto Sans JP | 48px | 700 | 1.3 | 0.05em | ページタイトル |
| Title-L | Plus Jakarta Sans, Noto Sans JP | 32px | 700 | 1.4 | 0.05em | セクション見出し |
| Title-M | Plus Jakarta Sans, Noto Sans JP | 24px | 700 | 1.4 | 0.05em | サブ見出し |
| Paragraph-L | Plus Jakarta Sans, Noto Sans JP | 16px | 400 | 1.6 | 0.05em | 本文 |
| Paragraph-M | Plus Jakarta Sans, Noto Sans JP | 12px | 400 | 1.6 | 0.05em | 補足、注釈 |

### 3.5 行間 ･ 字間

- **本文の行間 (line-height)**: 1.6 (日本語の読みやすさを考慮)
- **見出しの行間**: 1.3〜1.4
- **字間 (letter-spacing)**: 0.05em (見出し ･ 本文共通)

**ガイドライン**:
- 長文テキストでは `line-height: 1.7` まで広げてもよい
- `letter-spacing: 0.05em` を本文のベースとして適用する

### 3.6 約物 ･ 記号の表記ルール

日本語テキスト内の約物は以下のルールに統一する。
AI エージェントがテキストを生成 ･ 編集する際は必ず従うこと。
本ルールはコモレビ全社共通 (web ･ slides ･ Notion ･ Slack ･ コミットメッセージ ･ コードコメント等すべてに適用) 。

> 中黒は `･` (半角中黒 U+FF65) です。
> 見た目の似た `・` (全角中黒 U+30FB) ･ `·` (中点 U+00B7) とは別の文字で、どちらも使いません。 <!-- design-check: allow NO_FULLWIDTH_NAKAGURO -->

| # | ルール | OK 例 | NG 例 |
|---|---|---|---|
| 1 | 中黒は半角 `･` (U+FF65)、**前後に半角スペース有り** | `Notion ･ Slack ･ Email` | `Notion・Slack` (全角 U+30FB)、`Notion·Slack` (中点 U+00B7)、`Notion･Slack` (スペース無し) <!-- design-check: allow NO_FULLWIDTH_NAKAGURO --> |
| 2 | スラッシュ `/` は半角。**要素並列は前後にスペース有り、日付 ･ パス ･ 単位 ･ 二者択一 (compound) は前後スペース無し** | `Notion / Slack / Email`、`7/27`、`2026/04/28`、`src/foo`、`km/h`、`ON/OFF` | `Notion/Slack/Email`、`7 / 27`、`2026 / 04 / 28` <!-- design-check: allow NO_PERIOD_LINEBREAK --> |
| 3 | 引用符 `"..."` は前後にスペース有り (文中の場合、文末は閉じ後スペース不要) | `これは "重要" な点` | `これは"重要"な点` |
| 4 | 半角丸括弧 `()`: **外側に半角スペース、内側にスペース無し** | `この (テキスト) として` | `この(テキスト)として`、`この ( テキスト ) として` |
| 5 | 全角丸括弧 `（）` は禁止、半角 `()` に置換 | `(ピザのみ)` | `（ピザのみ）` <!-- design-check: allow NO_FULLWIDTH_PAREN --> |
| 6 | 全角括弧 (「」 `『』` ［］ 【】) の前後にスペース無し (前後がどんな文字でも同様) | `この「テキスト」として`、`「タイトル」「サブ」`、`「テキスト」(補足)` | `この 「テキスト」 として` |
| 7 | 表示用途の角括弧は全角 `［］`、半角 `[]` 禁止。**例外**: Markdown リンク `[text](url)` ･ 配列 ･ 正規表現等のコード構文は半角必須 | `［補足］` | `[補足]` (display 用途で半角) <!-- design-check: allow NO_PERIOD_LINEBREAK --> |
| 8 | 全角演算記号 (`＋ × ÷ =`) の前後に半角スペース | `A ＋ B`、`kcal ＝ P × 4 ＋ F × 9 ＋ C × 4` | `A＋B`、`収入×0.3` |
| 9 | コロン `:` は半角、**前後にスペース有り**。例外: 直後に全角開き括弧 (「『［【) が来る場合はスペース無し | `仮説 : 結論`、`仮説:「結論」` | `仮説:結論`、`仮説 : 「結論」` <!-- design-check: allow NO_PERIOD_LINEBREAK --> |
| 10 | カンマ `,` は半角、**後ろに半角スペース有り** (前は無し) | `A, B, C`、`Apple, Google, Meta` | `A,B,C`、`A ,B` |
| 11 | 日本語の中の半角英数字の前後にスペース無し。英単語間 (`Phase 3`) の半角スペースは保持 | `毎月1万円`、`インフルエンサーSNS発信`、`Phase 3` | `毎月 1 万円`、`インフルエンサー SNS 発信` <!-- design-check: allow NO_PERIOD_LINEBREAK --> |
| 12 | 句点後改行: 句点「。」 の後に続きの文があり、**直前の文が 10 文字 (codepoint) 以上**なら「。」 の後で改行。短い文の後 ･ 文末の「。」 ･ 後続が閉じ括弧 ･ 句読点のときは改行しない | `議事録を確認しました。\n次の打ち合わせは木曜です。`、`了解。次に進みます。` (前の文が短い→改行無し) | `議事録を確認しました。次の打ち合わせは木曜です。` (長い文が続くのに改行無し) <!-- design-check: allow NO_PERIOD_LINEBREAK --> |

### 3.7 禁則処理 ･ 改行ルール

```css
word-break: break-all;
overflow-wrap: break-word;
line-break: strict;
```

**禁則対象**:
- 行頭禁止: `）」』】〕〉》」】、。，．・：；？！` <!-- design-check: allow NO_FULLWIDTH_PAREN,NO_FULLWIDTH_COLON,NO_FULLWIDTH_NAKAGURO,NO_PERIOD_LINEBREAK -->
- 行末禁止: `（「『【〔〈《「【` <!-- design-check: allow NO_FULLWIDTH_PAREN -->

### 3.8 OpenType 機能

見出し、ナビゲーションのみ :

```css
font-feature-settings: "palt" 1;
```

欧文カーニング :

```css
font-feature-settings: "kern" 1;
```

- 本文には `palt` を適用しない (可読性優先)
- 見出しやボタンラベルには `palt` を適用して字詰め

### 3.9 縦書き

該当なし

---

## 4. Component Stylings

### Buttons

**Primary**
- Background: `#6E87B6` <!-- design-check: allow NO_HARDCODED_PRIMARY -->
- Background (hover): `#5A74A3`
- Text: `#FFFFFF`
- Padding: 12px 24px
- Border Radius: 6px
- Font Size: 16px
- Font Weight: 700
- Transition: `0.3s cubic-bezier(0.4, 0.4, 0, 1)`

**Secondary**
- Background: `transparent`
- Text: `#6E87B6` <!-- design-check: allow NO_HARDCODED_PRIMARY -->
- Border: 1px solid `#6E87B6` <!-- design-check: allow NO_HARDCODED_PRIMARY -->
- Padding: 12px 24px
- Border Radius: 6px

**Danger**
- Background: `#D9534F`
- Text: `#FFFFFF`
- Padding: 12px 24px
- Border Radius: 6px

### Inputs

- Background: `#FFFFFF`
- Border: 1px solid `#E0E0E0`
- Border (focus): 1px solid `#6E87B6` <!-- design-check: allow NO_HARDCODED_PRIMARY -->
- Border Radius: 6px
- Padding: 10px 14px
- Font Size: 16px
- Height: 44px

### Cards

- Background: `#FFFFFF`
- Border: 1px solid `#E0E0E0`
- Border Radius: 8px
- Padding: 24px
- Shadow: `0 1px 3px rgba(0, 0, 0, 0.08)`

---

## 5. Layout Principles

### Spacing Scale

| Token | Value |
|-------|-------|
| XS | 4px |
| S | 8px |
| M | 16px |
| L | 24px |
| XL | 40px |
| XXL | 64px |

### Container

- Max Width: 1280px
- Padding (horizontal): 24px

### Grid

- Columns: 12
- Gutter: 24px

---

## 6. Depth & Elevation

| Level | Shadow | 用途 |
|-------|--------|------|
| 0 | none | フラットな要素 |
| 1 | `0 1px 3px rgba(0, 0, 0, 0.08)` | カード、入力欄 |
| 2 | `0 4px 12px rgba(0, 0, 0, 0.1)` | ドロップダウン、ポップオーバー |
| 3 | `0 8px 24px rgba(0, 0, 0, 0.12)` | モーダル、ダイアログ |

---

## 7. Do's and Don'ts

### Do (推奨)

- フォントは必ず `"Plus Jakarta Sans", "Noto Sans JP", sans-serif` のフォールバックチェーンを指定する
- 日本語本文の line-height は 1.6、letter-spacing は 0.05em を基本とする
- 色のコントラスト比は WCAG AA 以上を確保する
- コンポーネントの余白は Spacing Scale に従う
- ブランドカラーは水彩ブルー `#6E87B6` を基調とする <!-- design-check: allow NO_HARDCODED_PRIMARY -->
- ボタンや操作要素には十分なパディングを取り、クリックしやすくする

### Don't (禁止)

- `font-family` に和文フォント1つだけを指定しない (環境依存になる)
- 全角 ･ 半角スペースを混在させない
- テキストの色に純粋な `#000000` を使わない (`#333333` を使う) <!-- design-check: allow NO_TEXT_BLACK -->
- Primary カラーを警告 ･ エラーの意味で使わない
- 角丸を `border-radius: 50%` のような極端な値にしない (ブランドの角丸は 6〜8px) <!-- design-check: allow NO_BORDER_RADIUS_50 -->

---

## 8. Responsive Behavior

### Breakpoints

| Name | Width | 説明 |
|------|-------|------|
| Mobile | ≤ 480px | モバイルレイアウト |
| Tablet | ≤ 768px | タブレットレイアウト |
| Desktop | > 768px | デスクトップレイアウト |

### タッチターゲット

- 最小サイズ: 44px × 44px (WCAG基準)

### フォントサイズの調整

- モバイルでは本文 14〜16px、見出しはデスクトップの 70〜80% 程度に縮小
- Title-XL: 48px → 28px (mobile)
- Title-L: 32px → 24px (mobile)
- Title-M: 24px → 20px (mobile)

---

## 9. Agent Prompt Guide

### クイックリファレンス

```text <!-- design-check: allow-block NO_HARDCODED_PRIMARY -->
Primary Color: #6E87B6
Primary Dark:  #5A74A3
Primary Light: #9BB0D0
Accent:        #C4A55A
Accent Dark:   #B0923E
Accent Light:  #E0D5A8
Text Color:    #333333
Background:    #F7F7F7
Surface:       #FFFFFF
Border:        #E0E0E0
Font:          "Plus Jakarta Sans", "Noto Sans JP", sans-serif
Body Size:     16px
Line Height:   1.6
Border Radius: 6px
```

### プロンプト例

```text <!-- design-check: allow-block NO_HARDCODED_PRIMARY -->
このサービスのデザインシステムに従って、UIを作成してください。
- プライマリカラー: #6E87B6 (水彩ブルー)
- フォント: "Plus Jakarta Sans", "Noto Sans JP", sans-serif
- 行間: 本文は line-height: 1.6
- 背景色: #F7F7F7
- カード背景: #FFFFFF、角丸 8px、影 0 1px 3px rgba(0,0,0,0.08)
- ボタン: 角丸 6px、パディング 12px 24px
- テキスト色: #333333
```

---

## 10. Frontend Design Skill

> UI を新規作成 ･ 大幅改修する際に従うべきデザイン思考とクオリティ基準。
> 汎用的な「AIっぽい」見た目を避け、コモレビらしい意図のあるデザインを実現する。

### Design Thinking (設計前に考えること)

新しい画面やコンポーネントを作る前に、以下を明確にする :

- **Purpose**: このUIは何の課題を解決するか？ 誰が使うか？
- **Tone**: コモレビのトーン (クリーン ･ 信頼 ･ やさしい) をベースに、画面の性質に応じて調整する。
  業務ツールは落ち着きと効率を、クライアント向けレポートは洗練と説得力を意識する
- **Constraints**: 技術要件 (React/Tailwind/Vanilla等)、パフォーマンス、アクセシビリティ
- **Differentiation**: この画面で「おっ」と思わせるポイントは何か？

### Aesthetics Guidelines (美的基準)

- **タイポグラフィ**: フォントは Plus Jakarta Sans + Noto Sans JP を基本としつつ、見出しやヒーロー部分では display 用のウェイトや letter-spacing で変化をつける。
  Arial / Roboto / system-ui のような汎用フォントは使わない
- **カラー**: CSS変数で一貫性を保つ。
  プライマリブルー `#6E87B6` を軸に、アクセントカラーは控えめに。 <!-- design-check: allow NO_HARDCODED_PRIMARY -->
  均等配色より、メインカラー + シャープなアクセントの方が効果的
- **モーション**: アニメーションは意図を持って使う。
  ページ読み込み時のstaggered reveal (animation-delay) は効果的。
  散発的なmicro-interactionより、ひとつの美しいトランジションの方がインパクトがある。
  CSS-onlyを優先し、ReactではMotionライブラリを検討する
- **空間構成**: 余白を恐れない。
  カード ･ セクション間の spacing は Spacing Scale に従いつつ、視覚的なリズムを意識する
- **背景 ･ 質感**: べた塗りの白やグレーだけでなく、微細なグラデーション、テクスチャ、レイヤードな透過で奥行きと雰囲気を出す

### Anti-Patterns (避けるべきこと)

- **汎用的なAI生成デザイン**: ありがちな紫グラデーション、白背景にカードを並べただけのレイアウト、どこかで見たことのあるテンプレート感
- **コンテキスト無視のデザイン**: 食品マーケティングの分析ツールなのに、SaaS LP のような見た目にしない
- **実装と野心のミスマッチ**: シンプルなデザインを選ぶなら、スペーシングとタイポグラフィを徹底的に磨く。
  リッチなデザインを選ぶなら、アニメーションとインタラクションに手を抜かない

### 実装の心得

- **意図のあるデザイン**: すべてのデザイン判断に「なぜ」があること。
  デフォルト値をそのまま使わない
- **ビジョンと複雑さの一致**: ミニマルなデザインにはスペーシング ･ タイポグラフィの精緻さを、マキシマルなデザインにはアニメーション ･ エフェクトの作り込みを
- **毎回違う表現を**: 同じパターンを繰り返さない。
  画面ごとにその文脈にふさわしい表現を探す

---

## 11. 検査と allow 注釈

このリポジトリの `hooks/design-check.sh` は、保存されたファイルを `contracts/rules.json` の8件と
「。」改行チェックに掛ける。
検査を飛ばしたとき (node ･ jq ･ rules.json が無いなど) は必ず1行出す。
無出力は「違反なし」だけを意味する。

### rules.json から外した規則

`NO_LINE_HEIGHT_LOW` (日本語本文に line-height 1.5 以下は禁止) は 2026/9/5 に rules.json から外した。
静的検査では要素の役割を見られないため、見出し ･ ラベル ･ 表ヘッダに付いた 1.6 未満をすべて違反として拾ってしまう。
判定は描画後 (実ブラウザ ･ `getComputedStyle`) で行う。
人が読むルールとしての「本文の行間 1.6」は §3.5 に残っている。

### 意図的な違反を1行だけ黙らせる

規則そのものを引用する行 — NG 例 ･ 禁止文字の一覧 ･ 色の定義値など — は、
その行に注釈を書いて黙らせる。
書式は `design-check:` に続けて `allow` と規則 ID を書く。

- **規則 ID は必須**。
  カンマ区切りで複数書ける。
  `allow all` と引数なしの `allow` は受け付けない。
  「この行は全部見ない」を作ると、ファイル単位の除外と同じ問題に戻る
- コメント記法は問わない (`<!-- -->` ･ `/* */` ･ `//` ･ `#`) 。
  検査器は文字列を探すだけなので `.md` ･ `.html` ･ `.css` ･ `.ts` で同じように効く
- 知らない規則 ID を書くと「未知の規則 ID」として報告される。
  黙って無視されない
- **要らなくなった注釈は「不要な allow」として報告される**。
  違反が消えたら注釈も消す
- 「。」改行チェックだけは `rules.json` に無いので、ID は `NO_PERIOD_LINEBREAK` を使う。
  表のセルのように改行できない行のためにある

### どこまで覆うか

覆う範囲は3通り。
内容のある行に付けた注釈は、**その行しか覆わない**。

| 置き場所 | 覆う範囲 |
| --- | --- |
| 内容のある行の末尾 | **その行だけ** |
| 注釈しか書かれていない行 | その行と**次の1行** |
| コードフェンスの行 (`allow-block`) | **そのブロック全体** |

内容のある行の末尾に付けた注釈が次の行まで届くと、**あとから足した行が黙って飲まれる**。
次の行を覆うのは「次の行のために書かれた行」= 注釈しか書かれていない行だけにしてある。

Markdown での書き方 (この行自体が全角中黒を含む実例) :

```
Notion・Slack <!-- design-check: allow NO_FULLWIDTH_NAKAGURO -->
```

コードブロックの中に HTML コメントを書くと**そのまま表示されてしまう**ので、注釈を置けない。
開始フェンスの後ろに `allow-block` を書いてブロック全体を覆う。
本ファイルの §9 がその例。

````
```text <!-- design-check: allow-block NO_HARDCODED_PRIMARY -->
Primary: #6E87B6
```
````

この例も実際に Primary の直書きを含んでいるので、注釈は「使われている」判定になる。
`allow-block` はコードフェンスの行以外に書くと、そう報告されて効かない。

### 注釈は「意図的な違反」だけに付ける

直せる違反は直す。
注釈は「これは引用なので直せない」と言うための印であって、面倒を消すための印ではない。

### ファイル単位で除外しているファイル

`contracts/rules.json` だけ。
JSON にはコメントを書けず、注釈を置く場所がないため。
description に禁止文字そのものを書いている行が7件ある。
それ以外のファイルはすべて検査される。

---
