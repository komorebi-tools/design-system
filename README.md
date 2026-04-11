# Komorebi Design System

コモレビの全ツール共通デザインガイドラインです。

カラーパレット、フォント、コンポーネント、日本語テキスト整形ルールなどを一元管理しています。

## デザインシステム プレビュー

DESIGN.md の内容をビジュアルで確認できるページです。

カラー、タイポグラフィ、コンポーネント、アイコン、アニメーション、ダークモード、レスポンシブ、JP Formatting ルールなど全セクションをインタラクティブに閲覧できます。

https://komorebi-tools.github.io/design-system/

## リポジトリの構成

| ファイル | 説明 |
|---|---|
| [DESIGN.md](DESIGN.md) | デザイン仕様書 (カラー、フォント、スペーシング、コンポーネント定義) |
| [index.html](index.html) | ビジュアルプレビュー (GitHub Pages で公開中) |
| [assets/logo/](assets/logo/) | ロゴ素材 (PNG 透過、JPG 白背景) |
| [assets/tools/](assets/tools/) | 各ツールのロゴ SVG |
| [.claude/skills/komorebi-design-system/SKILL.md](.claude/skills/komorebi-design-system/SKILL.md) | Claude Code 用スキル |

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
