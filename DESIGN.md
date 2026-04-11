# DESIGN.md — komorebi tools

> このファイルはAIエージェントが正確な日本語UIを生成するためのデザイン仕様書です。
> gpt-mcp-server 配下の全ツール共通のデザインガイドラインとして適用されます。
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
| PNG (透過) | `png_bg-clear/` | Web、アプリUI向け。背景透過 |
| JPG (白背景) | `jpg_bg-white/` | 印刷物、白背景前提の用途 |
| AI (ベクター) | `ai_vector/` | 編集・高解像度出力用。`komorebi_logo.ai` |

### ロゴの特徴

- 水彩テクスチャの円が重なり合うシンボルマーク
- ロゴタイプは小文字の `komorebi` + カタカナ `コモレビ` のルビ表記
- ロゴカラーは Primary (`#6E87B6`) 系のブルーグレー

### 使用ルール

- シンボルマークとロゴタイプの比率・配置はオリジナルを維持すること
- 最小表示サイズ: Symbol 24px、Short 48px、Wide 120px (幅基準)
- 背景色が暗い場合は PNG 透過版を使用し、白背景の場合は JPG 版でも可
- ロゴの色やテクスチャを改変しないこと

---

## 1. Visual Theme & Atmosphere

- **デザイン方針**: クリーンで信頼感がありつつ、柔らかさと透明感を持つ
- **密度**: 適度な余白を取った業務ツールUI。情報を詰め込みすぎない
- **キーワード**: 透明感、水彩、信頼、シンプル、やさしい

---

## 2. Color Palette & Roles

### Primary（ブランドカラー）

- **Primary** (`#6E87B6`): コモレビブルー。CTAボタン、リンク、アクセントに使用
- **Primary Light** (`#9BB0D0`): 背景のアクセント、ホバー状態の背景
- **Primary Dark** (`#5A74A3`): ホバー・プレス時のボタン色

### Secondary / Accent（セカンダリカラー）

- **Accent** (`#C4A55A`): ゴールド。注目させたいCTA、バッジ、ハイライトに使用
- **Accent Dark** (`#B0923E`): ホバー・プレス時のアクセント色
- **Accent Light** (`#E0D5A8`): 背景のアクセント、バッジ背景

### Semantic（意味的な色）

- **Danger** (`#D9534F`): エラー、削除、危険な操作
- **Warning** (`#F0AD4E`): 警告、注意喚起
- **Success** (`#5CB85C`): 成功、完了
- **Info** (`#6E87B6`): 情報（Primary と同系色）

### Neutral（ニュートラル）

- **Text Primary** (`#333333`): 本文テキスト
- **Text Secondary** (`#666666`): 補足テキスト、ラベル
- **Text Disabled** (`#AAAAAA`): 無効状態のテキスト
- **Border** (`#E0E0E0`): 区切り線、入力欄の枠
- **Background** (`#F7F7F7`): ページ背景
- **Surface** (`#FFFFFF`): カード、モーダル等の面

---

## 3. Typography Rules

### 3.1 和文フォント

- **ゴシック体**: Noto Sans JP

### 3.2 欧文フォント

- **サンセリフ**: Inter
- **等幅**: SFMono-Regular, Consolas, Menlo

### 3.3 font-family 指定

```css
/* 本文・見出し */
font-family: "Inter", "Noto Sans JP", sans-serif;

/* 等幅（コード表示） */
font-family: "SFMono-Regular", "Consolas", "Menlo", monospace;
```

**フォールバックの考え方**:
- Inter を先に指定し、欧文は Inter のグリフを優先
- 和文は Noto Sans JP にフォールバック
- 最後に generic family（sans-serif）を指定

### 3.4 文字サイズ・ウェイト階層

| Role | Font | Size | Weight | Line Height | Letter Spacing | 備考 |
|------|------|------|--------|-------------|----------------|------|
| Title-XL | Inter, Noto Sans JP | 48px | 700 | 1.3 | 0 | ページタイトル |
| Title-L | Inter, Noto Sans JP | 32px | 700 | 1.4 | 0 | セクション見出し |
| Title-M | Inter, Noto Sans JP | 24px | 700 | 1.4 | 0 | サブ見出し |
| Paragraph-L | Inter, Noto Sans JP | 16px | 400 | 1.6 | 0.05em | 本文 |
| Paragraph-M | Inter, Noto Sans JP | 12px | 400 | 1.6 | 0.05em | 補足、注釈 |

### 3.5 行間・字間

- **本文の行間 (line-height)**: 1.6（日本語の読みやすさを考慮）
- **見出しの行間**: 1.3〜1.4
- **本文の字間 (letter-spacing)**: 0.05em（日本語テキストの可読性向上）
- **見出しの字間**: 0

**ガイドライン**:
- 長文テキストでは `line-height: 1.7` まで広げてもよい
- `letter-spacing: 0.05em` を本文のベースとして適用する

### 3.6 約物・記号の表記ルール

日本語テキスト内の約物は以下のルールに統一する。AIエージェントがテキストを生成・編集する際は必ず従うこと。

| 元の表記 | 変換後 | ルール |
|----------|--------|--------|
| `・` | `･` | 中黒は半角 |
| `／` | ` / ` | スラッシュは半角、前後に半角スペース |
| `"` | ` "` | 開き引用符の前に半角スペース（文中の場合） |
| `"` | `" ` | 閉じ引用符の後に半角スペース（文末でない場合） |
| `（` | ` (` | 括弧は半角、開き括弧の前に半角スペース |
| `）` | `) ` | 括弧は半角、閉じ括弧の後に半角スペース |
| `：` | ` : ` | コロンは半角、前後に半角スペース |

### 3.7 禁則処理・改行ルール

```css
word-break: break-all;
overflow-wrap: break-word;
line-break: strict;
```

**禁則対象**:
- 行頭禁止: `）」』】〕〉》」】、。，．・：；？！`
- 行末禁止: `（「『【〔〈《「【`

### 3.8 OpenType 機能

```css
font-feature-settings: "palt" 1; /* 見出し・ナビゲーションのみ */
font-feature-settings: "kern" 1; /* 欧文カーニング */
```

- 本文には `palt` を適用しない（可読性優先）
- 見出しやボタンラベルには `palt` を適用して字詰め

### 3.9 縦書き

該当なし

---

## 4. Component Stylings

### Buttons

**Primary**
- Background: `#6E87B6`
- Background (hover): `#5A74A3`
- Text: `#FFFFFF`
- Padding: 12px 24px
- Border Radius: 6px
- Font Size: 16px
- Font Weight: 700
- Transition: `0.3s cubic-bezier(0.4, 0.4, 0, 1)`

**Secondary**
- Background: `transparent`
- Text: `#6E87B6`
- Border: 1px solid `#6E87B6`
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
- Border (focus): 1px solid `#6E87B6`
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

### Do（推奨）

- フォントは必ず `"Inter", "Noto Sans JP", sans-serif` のフォールバックチェーンを指定する
- 日本語本文の line-height は 1.6、letter-spacing は 0.05em を基本とする
- 色のコントラスト比は WCAG AA 以上を確保する
- コンポーネントの余白は Spacing Scale に従う
- ブランドカラーは水彩ブルー `#6E87B6` を基調とする
- ボタンや操作要素には十分なパディングを取り、クリックしやすくする

### Don't（禁止）

- `font-family` に和文フォント1つだけを指定しない（環境依存になる）
- 日本語本文に `line-height: 1.2` 以下を使わない（可読性が著しく低下する）
- 全角・半角スペースを混在させない
- テキストの色に純粋な `#000000` を使わない（`#333333` を使う）
- Primary カラーを警告・エラーの意味で使わない
- 角丸を `border-radius: 50%` のような極端な値にしない（ブランドの角丸は 6〜8px）

---

## 8. Responsive Behavior

### Breakpoints

| Name | Width | 説明 |
|------|-------|------|
| Mobile | ≤ 480px | モバイルレイアウト |
| Tablet | ≤ 768px | タブレットレイアウト |
| Desktop | > 768px | デスクトップレイアウト |

### タッチターゲット

- 最小サイズ: 44px × 44px（WCAG基準）

### フォントサイズの調整

- モバイルでは本文 14〜16px、見出しはデスクトップの 70〜80% 程度に縮小
- Title-XL: 48px → 28px (mobile)
- Title-L: 32px → 24px (mobile)
- Title-M: 24px → 20px (mobile)

---

## 9. Agent Prompt Guide

### クイックリファレンス

```
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
Font:          "Inter", "Noto Sans JP", sans-serif
Body Size:     16px
Line Height:   1.5
Border Radius: 6px
```

### プロンプト例

```
このサービスのデザインシステムに従って、UIを作成してください。
- プライマリカラー: #6E87B6（水彩ブルー）
- フォント: "Inter", "Noto Sans JP", sans-serif
- 行間: 本文は line-height: 1.5
- 背景色: #F7F7F7
- カード背景: #FFFFFF、角丸 8px、影 0 1px 3px rgba(0,0,0,0.08)
- ボタン: 角丸 6px、パディング 12px 24px
- テキスト色: #333333
```

---

## 10. Frontend Design Skill

> UI を新規作成・大幅改修する際に従うべきデザイン思考とクオリティ基準。
> 汎用的な「AIっぽい」見た目を避け、コモレビらしい意図のあるデザインを実現する。

### Design Thinking（設計前に考えること）

新しい画面やコンポーネントを作る前に、以下を明確にする：

- **Purpose**: このUIは何の課題を解決するか？ 誰が使うか？
- **Tone**: コモレビのトーン（クリーン・信頼・やさしい）をベースに、画面の性質に応じて調整する。業務ツールは落ち着きと効率を、クライアント向けレポートは洗練と説得力を意識する
- **Constraints**: 技術要件（React/Tailwind/Vanilla等）、パフォーマンス、アクセシビリティ
- **Differentiation**: この画面で「おっ」と思わせるポイントは何か？

### Aesthetics Guidelines（美的基準）

- **タイポグラフィ**: フォントは Inter + Noto Sans JP を基本としつつ、見出しやヒーロー部分では display 用のウェイトや letter-spacing で変化をつける。Arial / Roboto / system-ui のような汎用フォントは使わない
- **カラー**: CSS変数で一貫性を保つ。プライマリブルー `#6E87B6` を軸に、アクセントカラーは控えめに。均等配色より、メインカラー + シャープなアクセントの方が効果的
- **モーション**: アニメーションは意図を持って使う。ページ読み込み時のstaggered reveal（animation-delay）は効果的。散発的なmicro-interactionより、ひとつの美しいトランジションの方がインパクトがある。CSS-onlyを優先し、ReactではMotionライブラリを検討する
- **空間構成**: 余白を恐れない。カード・セクション間の spacing は Spacing Scale に従いつつ、視覚的なリズムを意識する
- **背景・質感**: べた塗りの白やグレーだけでなく、微細なグラデーション、テクスチャ、レイヤードな透過で奥行きと雰囲気を出す

### Anti-Patterns（避けるべきこと）

- **汎用的なAI生成デザイン**: ありがちな紫グラデーション、白背景にカードを並べただけのレイアウト、どこかで見たことのあるテンプレート感
- **コンテキスト無視のデザイン**: 食品マーケティングの分析ツールなのに、SaaS LP のような見た目にしない
- **実装と野心のミスマッチ**: シンプルなデザインを選ぶなら、スペーシングとタイポグラフィを徹底的に磨く。リッチなデザインを選ぶなら、アニメーションとインタラクションに手を抜かない

### 実装の心得

- **意図のあるデザイン**: すべてのデザイン判断に「なぜ」があること。デフォルト値をそのまま使わない
- **ビジョンと複雑さの一致**: ミニマルなデザインにはスペーシング・タイポグラフィの精緻さを、マキシマルなデザインにはアニメーション・エフェクトの作り込みを
- **毎回違う表現を**: 同じパターンを繰り返さない。画面ごとにその文脈にふさわしい表現を探す

---
