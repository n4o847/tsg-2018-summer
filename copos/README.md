# copos

copos は code point sum の略で、文字のコードポイントの分バイト数を食うゴルフ用ジョーク言語です。（実装では多分 UTF-8 → Unicode）

実態はスクリプト言語で eval するだけです。

Ruby 版のみがあります。

## 注意

`getc` などの入力関数が `nil` を返すようです。`STDIN.getc` や `$stdin.getc` と書くと入力をとれます。
