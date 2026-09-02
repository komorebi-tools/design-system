# tests/fixtures

`scripts/check-hook.mjs` の「セクション3 : NO_EMOJI の変更前後の比較」で使う `rules.json` の固定コピーです。

**手で編集しないでください。**取得元から機械的にコピーしたものです。

## 中身と取得元

| ファイル | 中身 | 取得元 | 取得時点のコミット |
| --- | --- | --- | --- |
| `rules-before.json` | `NO_EMOJI` 修正前の `contracts/rules.json` | `git show origin/main:contracts/rules.json` | `c935bbdee397251d90e0321c41a20b7f3e7aa781` |
| `rules-after.json` | `NO_EMOJI` 修正後の `contracts/rules.json` | `git show origin/fix/no-emoji-detection-20260901:contracts/rules.json` (PR #4) | `07e0a90f2d61cb79edc1c71bcd6ae30a3206ce35` |

取得日 : 2026/9/1

2つの差分は `NO_EMOJI` の `description` と `pattern` の2行だけです。他の8件は同一です。

## なぜファイルとして固定するのか

以前は `check-hook.mjs` が `origin/fix/no-emoji-detection-20260901` を git 参照で直接読んでいました。
そのままだと **PR #4 が merge されてブランチが削除された瞬間にテストが落ちます**。
しかも落ちる理由が「ブランチが無い」なので、原因の見当がつきません。

比較できないことを pass と呼ばない (`failed++` にする) 判断自体は正しいので、参照の持ち方だけを変えました。

## 名前について

`main` / `PR #4` ではなく `before` / `after` にしています。
PR #4 が merge されると `main` の中身が「変更後」になるため、`main` という名前が嘘になるからです。

## 更新するとき

**`NO_EMOJI` の `pattern` を変えたときだけ、`rules-after.json` を取り直してください。**

```bash
cp contracts/rules.json tests/fixtures/rules-after.json
```

(`git show origin/main:contracts/rules.json` は、その変更が main に入ったあとでないと「変更後」になりません。作業中は上のように作業コピーからそのまま取ってください)

`rules-before.json` は「修正前はこうだった」という記録なので、**取り直す必要はありません。**

### `pattern` 以外を変えたときは取り直さない

`alternative` ･ `description` ･ `severity` の文言を直しただけのときは、**取り直さないでください。**この fixture は「`NO_EMOJI` の判定がどう変わったか」を比べるためのもので、比較に効くのは `pattern` だけです。文言の修正まで取り込むと、`rules-after.json` が「PR #4 時点の記録」でなくなります。

そのため、次の `diff` に差分が出るのは**正常です。**

```bash
diff contracts/rules.json tests/fixtures/rules-after.json
```

2026/9/2 時点では `NO_FULLWIDTH_NAKAGURO` の `alternative` の1行だけ差分が出ます (`\u00B7 (half-width)` というエスケープ表記が hook の出力にそのまま出ていたため、`･ (半角中黒 U+FF65)` に直したもの)。

**`pattern` に差分が出ていたら異常です。**その場合は取り直しが漏れています。`pattern` だけを比べるにはこうします。

```bash
node -e 'const f=p=>JSON.parse(require("fs").readFileSync(p,"utf8")).map(r=>[r.id,r.pattern]);
console.log(JSON.stringify(f("contracts/rules.json"))===JSON.stringify(f("tests/fixtures/rules-after.json"))?"pattern は一致":"pattern に差分あり")'
```
