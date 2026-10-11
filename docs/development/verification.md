# 検証手順

このプロジェクトは Rails 8.1.4、Minitest、MySQL、Docker Compose を使用する。RSpec は導入されていない。コマンドはホストではなく起動済みの `web` コンテナから実行する。

## 準備

```bash
docker-compose up -d
docker-compose exec -T web bin/setup --skip-server
```

`web` は MySQL のヘルスチェック完了を待つ。開発・テスト DB だけを対象にする。

## 必須の基本確認

対象変更に応じて範囲を絞ることはできるが、実行しなかった項目は未実行として報告する。

```bash
# Minitest
docker-compose exec -T web bin/rails test

# Ruby スタイル
docker-compose exec -T web bin/rubocop

# 依存 Gem の既知脆弱性
docker-compose exec -T web bin/bundler-audit

# importmap の既知脆弱性
docker-compose exec -T web bin/importmap audit

# Rails コードの静的セキュリティ解析
docker-compose exec -T web bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error
```

全体の既存 CI は次で実行できる。これは上記の setup、スタイル、セキュリティ検査、Rails テスト、テスト環境の seeds 再投入を順に行う。

```bash
docker-compose exec -T web bin/ci
```

システムテストは Rails に生成されているが、CI では任意であり、このプロジェクトにブラウザ実行基盤は未設定である。必要な機能で実行する場合は環境を整え、未実行を成功と扱わない。新しい検証ツールは導入候補であり、現時点の必須検証ではない。
