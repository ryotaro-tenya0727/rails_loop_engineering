# Codex 実装・レビュー・修正ループ

## 担当

| 担当 | 役割 |
| --- | --- |
| 指揮官（メインエージェント） | タスクを読み、担当を起動し、結果を集約して進捗を更新する。 |
| `implementer` | Rails の実装と必要なテストを変更する唯一の担当。 |
| `requirements_reviewer` | 要件と受け入れ条件に照らして確認する。 |
| `spec_reviewer` | 設計・既存契約との整合を確認する。 |
| `test_runner` | 定めた検証を実行し、結果だけを報告する。 |
| `security_reviewer` | 3 担当が OK の後に、変更に関係する安全性を確認する。 |

各担当は `.codex/agents/` の同名設定で定義され、担当からの再委任は禁止する。権限は親セッションの実行時ポリシーにも影響されるため、`read-only` の指定だけが編集不能を機械的に保証するものではない。

## 手順

1. `docs/tasks/_template/` を `docs/tasks/<task-name>/` へコピーし、空欄を埋める。未記入テンプレートを開始対象にしない。
2. 指揮官が requirements と design の未確定事項を解消する。
3. implementer が実装・必要なテストを完了し、変更を止める。
4. requirements_reviewer、spec_reviewer、test_runner を同じコード状態で並列実行する。
5. 指揮官が結果を progress に記録する。NG は重複をまとめ、implementer が修正する。
6. 修正後は手順 3 から再確認する。3 担当が全員 OK の場合のみ security_reviewer を実行する。
7. security_reviewer が NG なら修正後に手順 3 へ戻る。最新状態で全担当 OK のときだけ完了を報告する。

BLOCKED、未実行、未報告は OK ではない。初回実装後の修正は最大 3 回で、上限時は未解決事項と試行内容を報告して停止する。詳細な判定ルールは `AGENTS.md` と `review_rules.md` を参照する。

## 開始依頼の例

```text
docs/tasks/<task-name>/の要件と仕様を実装してください。
あなたは指揮官としてAGENTS.mdとdocs/development/codex_loop.mdを読み、
定義済みの各担当を起動してください。
NGなら指摘を実装担当へ戻し、修正後に再確認してください。
最新の変更について全担当がOKになったら完了を報告してください。
BLOCKEDや修正上限の場合は、未解決事項を報告してください。
```

このループは Codex への指示とレビュー記録によって進行する。全員 OK をコードで強制する CI 実行基盤は、この設定の対象外である。
