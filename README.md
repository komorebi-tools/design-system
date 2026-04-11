# Komorebi Design System

コモレビの全ツール共通デザインガイドラインです。

カラーパレット、フォント、コンポーネント、日本語テキスト整形ルールなどを一元管理しています。

## デザインシステム プレビュー

DESIGN.md の内容をビジュアルで確認できるページです。

カラー、タイポグラフィ、コンポーネント、アイコン、アニメーション、ダークモード、レスポンシブ、JP Formatting ルールなど全セクションをインタラクティブに閲覧できます。

https://komorebi-tools.github.io/design-system/

## 仕組み

Claude Code にコモレビの UI 制作を依頼すると、デザインが意図通りに出てきます。

プロンプトに「色は #6E87B6 で、フォントは Noto Sans JP で...」と毎回書く必要はありません。

理由は、プロジェクトに設計書を置いているからです。

Claude Code はセッション開始時にこれらを自動で読み込み、ルールに従って作業します。

```
design-system/
├── DESIGN.md                    ... デザイン仕様書 (色、フォント、余白、コンポーネント)
├── index.html                   ... ビジュアルプレビュー (GitHub Pages)
├── contracts/
│   └── rules.json               ... 禁止ルール9件 (hook で自動チェック)
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
| [rules.json](contracts/rules.json) | 絵文字禁止、#000000 禁止、全角括弧禁止など 9 件の禁止ルール。ファイル編集のたびに hook が自動チェックし、違反があれば警告する |
| [index.html](index.html) | DESIGN.md をビジュアルで確認できるページ。チーム全員が同じトークンを見られる |

### 品質を維持する仕組み

1. **DESIGN.md** がルールを定義する
2. **SKILL.md** が Claude Code に判断基準を与える
3. **rules.json + hook** が編集のたびに違反を自動検出する

この 3 層で、誰が作業しても品質がブレない構造になっています。

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
