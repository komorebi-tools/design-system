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

チームメンバーは以下の手順でセットアップしてください。

### できること

- デザイントークン (カラー、タイポグラフィ、スペーシング、シャドウ) の自動適用
- アイコンルール (Material Icons 必須、絵文字禁止) の遵守
- ロゴ使用規定 (実画像 URL の参照、CSS 模造の禁止)
- コーポレートサイト、会社説明スライドからの実データ参照
- 制作完了チェックリストによる品質確認

### セットアップ手順

#### 方法 1 : このリポジトリを clone して使う (推奨)

リポジトリを clone :

```bash
git clone git@github.com:komorebi-tools/design-system.git
```

clone したディレクトリ内で Claude Code を起動 :

```bash
cd design-system
claude
```

`.claude/skills/` 配下のスキルが自動的に認識されます。

#### 方法 2 : 既存プロジェクトにスキルだけコピーする

ディレクトリを作成 :

```bash
mkdir -p .claude/skills/komorebi-design-system
```

SKILL.md をダウンロード :

```bash
curl -o .claude/skills/komorebi-design-system/SKILL.md \
  https://raw.githubusercontent.com/komorebi-tools/design-system/main/.claude/skills/komorebi-design-system/SKILL.md
```

#### 方法 3 : グローバルに設定する (全プロジェクトで有効)

ディレクトリを作成 :

```bash
mkdir -p ~/.claude/skills/komorebi-design-system
```

SKILL.md をダウンロード :

```bash
curl -o ~/.claude/skills/komorebi-design-system/SKILL.md \
  https://raw.githubusercontent.com/komorebi-tools/design-system/main/.claude/skills/komorebi-design-system/SKILL.md
```

### 使い方

セットアップ後、Claude Code にコモレビ関連の UI 制作を依頼するだけで自動適用されます。

```
コモレビのランディングページを作って
```

```
コモレビのダッシュボード UI を設計して
```

```
コモレビのサービス紹介ページの HTML を作って
```

スキルが適用されると、以下が自動的に行われます :

- コーポレートサイト、会社説明スライド、デザインシステムの 3 ソースを参照
- デザイントークンに基づいた CSS の生成
- Material Icons の使用 (絵文字は使わない)
- 実画像ロゴの参照
- 制作完了チェックリストの実施

### スキルの更新

スキルの内容が更新された場合、最新版を取得してください。

方法 1 の場合 :

```bash
cd design-system && git pull
```

方法 2, 3 の場合 :

```bash
curl -o <SKILL.md のパス> \
  https://raw.githubusercontent.com/komorebi-tools/design-system/main/.claude/skills/komorebi-design-system/SKILL.md
```
