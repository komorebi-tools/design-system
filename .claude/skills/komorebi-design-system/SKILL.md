---
name: komorebi-design-system
description: |
  株式会社コモレビのデザインシステム準拠スキル。コモレビのウェブサイト、UI、HTMLプロトタイプを作成 / 編集するときに必ず適用する。デザイントークン (色、タイポグラフィ、スペーシング、シャドウ)、アイコンルール (Material Icons 必須、絵文字禁止)、ロゴ使用規定、実在する会社情報の参照元を定義。トリガー : コモレビ、komorebi、コモレビのサイト、コモレビのUI、コモレビのデザイン、コモレビのHTML、コモレビのウェブ、食品マーケティングのサイトなど、コモレビに関連するあらゆるUI / Web制作タスク。
---

# コモレビ デザインシステム準拠ガイド

このスキルは、株式会社コモレビ (komorebi-inc.com) のUI / Web制作で同じミスを繰り返さないために作られた。
ここに書かれているルールはすべて、過去の制作で実際に起きた問題から学んだもの。

---

## 情報ソース (3つとも必ず参照すること)

コモレビのUIを作るときは、仮データや推測ではなく、以下3つのソースから実データを取得する。
これを怠ると、架空の社長名や設立年が混入してやり直しになる。

1. **コーポレートサイト** : https://komorebi-inc.com/
   - 会社概要、メンバー情報、ニュース、サービス内容
2. **会社説明スライド** : https://docs.google.com/presentation/d/1tjvM9q3SJfkgJ7mlXrXcx-oqrInpMP-OUci_JoqDvNk/edit
   - ミッション、ビジョン、事業詳細、ケーススタディ、組織体制
3. **デザインシステム** : https://komorebi-tools.github.io/design-system/
   - デザイントークン、カラー、タイポグラフィ、アイコン規定、ロゴ素材

**制作開始前にこの3つを読み、実データを抽出してから作業に入る。**

---

## デザイントークン

### カラーパレット

Primary :

```css
--primary: #6E87B6;
--primary-light: #9BB0D0;
--primary-dark: #5A74A3;
```

Accent :

```css
--accent: #C4A55A;
--accent-dark: #B0923E;
--accent-light: #E0D5A8;
```

Semantic :

```css
--danger: #D9534F;
--warning: #F0AD4E;
--success: #5CB85C;
--info: #6E87B6;
```

Neutral :

```css
--text-primary: #333333;
--text-secondary: #666666;
--text-disabled: #AAAAAA;
--border: #E0E0E0;
--background: #F7F7F7;
--surface: #FFFFFF;
```

色は必ず CSS custom properties 経由で使う。ハードコードしない。

### タイポグラフィ

**フォントファミリー** : `"Inter", "Noto Sans JP", sans-serif`

| トークン | サイズ | 用途 |
|----------|--------|------|
| --title-xl | 48px | ヒーロー見出し |
| --title-l | 32px | セクション見出し |
| --title-m | 24px | サブ見出し |
| --paragraph-l | 16px | 本文 |
| --paragraph-m | 12px | 注釈、ラベル |

**見出し (h1 / h2 / h3) のスタイル :**

font-weight: 700 は必須。
省略すると見出しが細くなり視認性が落ちる。

font-feature-settings: "palt" 1, "kern" 1 で日本語プロポーショナルメトリクスを有効にする。

letter-spacing: 0.05em は見出し、本文共通。

```css
h1, h2, h3 {
  font-weight: 700;
  font-feature-settings: "palt" 1, "kern" 1;
  letter-spacing: 0.05em;
}
h1 { font-size: var(--title-xl); line-height: 1.3; }
h2 { font-size: var(--title-l); line-height: 1.4; }
h3 { font-size: var(--title-m); line-height: 1.4; }
```

`.section-title` のような見出し用クラスにも同じプロパティを明示的に指定する。
h2 を継承するだろうと思っても、div 等に付与される場合があるため。

**本文のスタイル :**

```css
body {
  line-height: 1.6;
  letter-spacing: 0.05em;
}
```

説明文 (.section-desc 等) の行高は最大 `1.7` まで。それ以上は間延びする。

### スペーシングスケール

| トークン | 値 | 用途の目安 |
|----------|------|------------|
| --sp-xs | 4px | アイコンとテキストの間 |
| --sp-s | 8px | ラベルとコンテンツの間 |
| --sp-m | 16px | カード内パディング |
| --sp-l | 24px | セクション内要素間 |
| --sp-xl | 40px | セクション見出しとコンテンツ間 |
| --sp-xxl | 64px | セクション間 |

### シャドウ

| レベル | 値 | 用途 |
|--------|------|------|
| --shadow-0 | none | フラットな要素 |
| --shadow-1 | 0 1px 3px rgba(0,0,0,0.08) | カード、ヘッダー |
| --shadow-2 | 0 4px 12px rgba(0,0,0,0.1) | ホバー状態 |
| --shadow-3 | 0 8px 24px rgba(0,0,0,0.12) | モーダル、強調 |

### レイアウト

| プロパティ | 値 |
|------------|------|
| 最大幅 | 1280px |
| 角丸 (通常) | 6px |
| 角丸 (大) | 8px |
| ガター | 24px |
| トランジション | 0.3s cubic-bezier(0.4, 0.4, 0, 1) |

**レスポンシブブレークポイント :**
- モバイル : ≤480px
- タブレット : ≤768px
- デスクトップ : >768px

---

## アイコンルール

**Material Icons を使う。絵文字は使用禁止。**

デザインシステムの Section 04 (Iconography) で「絵文字は使用禁止」と明記されている。
過去に絵文字を使ってしまい、全面やり直しになった。この間違いは二度としない。

CDN 読み込み (head 内) :

```html
<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
```

使い方 :

```html
<span class="material-icons">restaurant</span>
<span class="material-icons">analytics</span>
<span class="material-icons">trending_up</span>
```

SVG アイコンも原則使わない。Material Icons に統一することで、サイト全体の一貫性を保つ。

---

## ロゴ使用規定

ロゴは CSS で模造しない (丸や四角で "それっぽく" 作るのは NG)。
デザインシステムに実画像がホストされているので、それを使う。

ヘッダー用 (明るい背景) :

```html
<img src="https://komorebi-tools.github.io/design-system/assets/logo/logo-clear-wide.png"
     alt="株式会社コモレビ" style="height: 32px; width: auto;">
```

フッター用 (暗い背景、filter で白に反転) :

```html
<img src="https://komorebi-tools.github.io/design-system/assets/logo/logo-clear-wide.png"
     alt="株式会社コモレビ"
     style="height: 28px; width: auto; filter: brightness(0) invert(1);">
```

ロゴの周囲には十分な余白を確保する。

---

## 実在データの参照

以下の情報はソースから取得する。推測や仮データを絶対に入れない。

| 項目 | 正しい値 | 取得元 |
|------|----------|--------|
| 代表取締役 | 安原 悠 | コーポレートサイト |
| 取締役 | 小野里 尊 | コーポレートサイト |
| 執行役員 | 松本 健太郎 | コーポレートサイト |
| 設立年 | 2024年 | コーポレートサイト |
| 所在地 | 東京都中央区東日本橋3-9-16-901 | コーポレートサイト |
| ミッション / ビジョン | スライドから原文を取得 | 会社説明スライド |
| ケーススタディ | スライドから実例を取得 | 会社説明スライド |
| サービスフロー | スライドから実データを取得 | 会社説明スライド |

人名を「佐藤太郎」、設立年を「2020年」のように仮で入れると信頼性を損なう。
不明な場合はソースを再確認する。空欄のほうが嘘より良い。

---

## UIパターン

### ヘッダー

固定ヘッダー + backdrop-filter。スクロール時にシャドウを追加。

```css
header {
  position: fixed;
  background: rgba(247, 247, 247, 0.88);
  backdrop-filter: blur(20px);
  border-bottom: 1px solid var(--border);
  height: 72px;
}
header.scrolled { box-shadow: var(--shadow-1); }
```

### スクロールアニメーション

IntersectionObserver を使った reveal パターン。

```css
.reveal {
  opacity: 0;
  transform: translateY(24px);
  transition: opacity 0.7s cubic-bezier(0.25, 0.46, 0.45, 0.94),
              transform 0.7s cubic-bezier(0.25, 0.46, 0.45, 0.94);
}
.reveal.is-visible { opacity: 1; transform: translateY(0); }
```

子要素には `transition-delay` をスタガード (0.1s 間隔) で付与する。

### ボタン

```css
.btn-primary {
  background: var(--primary);
  color: #fff;
  padding: 12px 24px;
  border-radius: var(--radius);
  font-weight: 700;
  font-size: var(--paragraph-l);
}
.btn-primary:hover {
  background: var(--primary-dark);
  transform: translateY(-2px);
  box-shadow: 0 4px 16px rgba(110, 135, 182, 0.3);
}
```

---

## 制作完了チェックリスト

制作が終わったら、以下をすべて確認してから納品する :

- [ ] 絵文字が一つも使われていない
- [ ] すべてのアイコンが Material Icons である
- [ ] ロゴが実画像 (design-system の URL) である
- [ ] 人名、設立年、所在地が実データである
- [ ] 見出し (h1-h3, .section-title) が font-weight: 700 である
- [ ] 本文の line-height が 1.6、letter-spacing が 0.05em である
- [ ] 見出しの letter-spacing が 0.05em、font-feature-settings が "palt" 1, "kern" 1 である
- [ ] カラーが CSS custom properties 経由で使われている
- [ ] レスポンシブ対応 (480px, 768px) が入っている
- [ ] フォントが Inter + Noto Sans JP である
- [ ] シャドウがトークン (--shadow-1 等) 経由である
