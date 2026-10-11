# 進捗: ログイン・新規登録・ユーザー詳細画面

> この文書は後続のループエンジニアリングで指揮官が更新する。未実施の作業・検証を完了や成功として記録しない。

## 現在の状態

完了。修正 4 回目後の要件レビュー、仕様レビュー、テスト実行、セキュリティレビューはすべて OK。development の HTTP 確認でもログイン画面表示を確認済み。

## 確認対象のコードの状態

初回実装のワークスペース差分。`User`、users migration、bcrypt、認証・登録・詳細の controllers/views/routes、統合テストを追加済み。Git リポジトリは初期化されていないため、確認対象はワークスペース差分として記録する。

## 初回実装

完了。REQ-001〜005 の初回実装を実施。仕様・テストレビューの指摘を修正 1 回目として対応する。

## 修正回数

4 / 6（全修正完了）

## 各回の担当別判定

| 回 | implementer | requirements_reviewer | spec_reviewer | test_runner | security_reviewer | コード状態 |
| --- | --- | --- | --- | --- | --- | --- |
| 初回実装 | 実装完了 | OK | NG（SPEC-001、SPEC-002） | NG（TEST-001、TEST-002） | 未実施 | 初回実装差分 |
| 修正 1 回目 | 修正完了 | OK | NG（SPEC-003） | OK | 未実施 | 初回指摘の修正後 |
| 修正 2 回目 | 修正完了 | OK | OK | OK | NG（SEC-001、SEC-002、SEC-003） | SPEC-003 修正後 |
| 修正 3 回目 | 修正完了 | OK | OK | OK | OK | セキュリティ指摘の修正後 |
| 最終 HTTP 確認 | — | NG（RUNTIME-001） | NG（RUNTIME-001） | NG（RUNTIME-001） | NG（RUNTIME-001） | development の GET / が例外ページ |
| 修正 4 回目 | 修正完了 | OK | OK | OK | OK | RUNTIME-001 修正後 |

## 指摘と対応

- SPEC-001: 新規登録フォームは `user[login_id]` / `user[password]` を送るが、controller がトップレベル params だけを許可しており、実際のフォーム送信では登録できない。
- SPEC-002: ログイン失敗時の `alert` を設定しているが、layout または画面に flash を表示する実装がない。
- TEST-001: 登録済み ID と不一致パスワードでのログイン失敗を確認する統合テストがない。
- TEST-002: ログイン ID またはパスワードの空入力でログインできないことを確認する統合テストがない。
- SPEC-003: ログイン成功後に、送信した平文パスワードが詳細画面に含まれないことを明示する統合テストがない。
- SEC-001: 本番環境で TLS を強制する設定がなく、HTTP 公開時に認証情報・セッションを盗聴される可能性がある。
- SEC-002: ログイン試行のレート制限がなく、未登録 ID は bcrypt 比較を行わないため、ブルートフォースと応答時間差による ID 列挙の可能性がある。
- SEC-003: 認証済みセッションを維持したまま失敗ログインすると既存セッションが残り、別利用者が前利用者の詳細画面を閲覧できる。
- RUNTIME-001: development の `GET /` で `SessionsController::BCrypt` が未定義となり、ログイン画面ではなく Rails の例外ページが返る。`SessionsController` が `BCrypt::Password` を直接参照するが、development のコントローラ読み込み時に bcrypt を明示 require していない。

## 実行した検証

- `docker-compose up -d && docker-compose exec -T web bin/setup --skip-server` — 成功。
- `docker-compose exec -T web bin/rails test` — 成功（7 runs、46 assertions）。
- `docker-compose exec -T web bin/rubocop`、`bin/bundler-audit`、`bin/importmap audit`、`bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error` — すべて成功。
- 修正 1 回目後にも同じ検証を再実行し、`bin/rails test` は 10 runs、76 assertions、静的解析・監査はすべて成功。
- 修正 2 回目後にも同じ検証を再実行し、`bin/rails test` は 10 runs、78 assertions、静的解析・監査はすべて成功。
- security_reviewer はコードを読み取り専用で確認し、最新の監査成功記録を参照した。TLS 終端・本番デプロイ構成の実環境確認は未実施。
- 修正 3 回目後に `bin/rails test` は 12 runs、107 assertions、静的解析・監査はすべて成功。
- 最終 HTTP 確認: `GET http://localhost:3000/` は HTTP 200 だが、本文は `NameError: uninitialized constant SessionsController::BCrypt` の Rails 例外ページであり、ログイン画面を確認できなかった。
- 修正 4 回目後: Web コンテナを再起動し、`curl --fail --show-error --silent http://localhost:3000/ | grep -q 'ログイン'` が成功。`bin/rails test` は 12 runs、107 assertions、静的解析・監査はすべて成功。
- test_runner による再実行でも、`GET /` は HTTP 200 で Rails 例外ではないログイン画面を返し、RUNTIME-VERIFY-001 は解消。
- システムテストと `bin/ci` は未実行。システムテストのブラウザ実行基盤は未設定。

## 未解決事項

- requirements.md と design.md の「未確定事項」に記載したログイン ID、パスワード、セッション、入力引き継ぎの方針。
- 実運用の TLS 終端プロキシ、および複数インスタンス時のレート制限用共有キャッシュストアは未検証。

## 最終結果

完了。REQ-001〜005 を実装し、修正 4 回目後の要件レビュー、仕様レビュー、テスト実行、セキュリティレビューがすべて OK。development の HTTP 確認でログイン画面を確認済み。実運用の TLS 終端と複数インスタンス向け共有キャッシュは、デプロイ基盤が未提供のため未検証。
