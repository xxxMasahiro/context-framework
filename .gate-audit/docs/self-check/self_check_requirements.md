# Self-check 要件定義（Self-check Requirements）

## 0. 目的

検証キットに **Self-check（内部品質保証）** レイヤーを追加し、
既存の verify（Gate A-I 検証）と test（Phase 1-3 テスト）の **上位で動作する品質ゲートキーパー** を構築する。

### 解決する課題

| # | 課題 | 現状 | Self-check で解決 |
|---|------|------|-------------|
| 1 | 回帰検出が手動 | `./kit all` の結果は目視比較のみ | run 間の自動 diff / 回帰検出 |
| 2 | ドキュメント不整合の検出がない | req ↔ spec ↔ plan の整合は人力 | 自動クロスリファレンスチェック |
| 3 | トラッカー健全性の保証がない | `[x]` に Evidence が欠けても気づかない | Evidence chain 自動検証 |
| 4 | SSOT ドリフトが handoff 時にしか分からない | generate_handoff.sh 実行時のみ | 独立した SSOT ドリフトチェック |
| 5 | スクリプト品質の基準がない | shellcheck 等が CI に組み込まれていない | lint / 静的解析の自動実行 |

### 非目的（Non-goals）

- 本体repo（~/projects/context-framework）の変更（read-only 厳守）
- 既存の `./kit verify` / `./kit test` のロジック変更（Self-check はそれらの上位レイヤー）
- 外部 CI サービス（GitHub Actions 等）への統合（将来拡張として設計のみ）
- パフォーマンス測定やベンチマーク

---

## 1. スコープ

### 1.1 対象（Self-check がチェックするもの）

| カテゴリ | チェック内容 | 根拠 |
|----------|-------------|------|
| **CI: 回帰検出** | 前回 run の結果と今回 run の結果を比較し、PASS→FAIL の回帰を検出 | 検証の信頼性維持 |
| **CI: パイプライン統合** | verify → test → self-check → handoff の一気通貫実行 | 実行順序の保証 |
| **QA: トラッカー整合性** | 全 `[x]` 項目に Evidence パス・判定・日時があること | REQ-R05 (トラッカー更新ルール) の自動検証 |
| **QA: Evidence chain** | トラッカーが参照する Evidence ファイルが実在し、sha256 が一致 | REQ-R04 (Evidence 管理強化) の自動検証 |
| **QA: SSOT ドリフト** | kit SSOT/ と repo _handoff_check/ の sha256 比較 | REQ-R01 (latest.md 自己完結性) の前提条件 |
| **QA: ドキュメント整合** | requirements ↔ spec 間のキーワード / セクション対応 | 設計文書の品質維持 |
| **QA: スクリプト品質** | shellcheck (警告レベル以上), 関数シグネチャ一貫性 | スクリプト保守性 |
| **QA: 命名規約** | Evidence ファイル名、トラッカー書式の規約準拠 | 運用規約の自動検証 |

### 1.2 非対象

- Gate A-I の検証ロジック自体（`scripts/lib/gate_*.sh` の内容）
- 本体repo のコード品質（本体は read-only）
- テストの追加・削除（`scripts/run_tests.sh` の Phase 変更）

---

## 2. 成功条件（Acceptance Criteria）

| # | 条件 | 検証方法 |
|---|------|----------|
| AC-CQ01 | `./kit self-check` で全 QA チェックが実行され、結果が Evidence に保存される | コマンド実行 + Evidence 確認 |
| AC-CQ02 | `./kit self-check` の exit code が 0(全PASS) / 1(FAIL あり) | exit code 確認 |
| AC-CQ03 | トラッカー整合性チェックで、Evidence 欠損を検出できる | 意図的に Evidence パスを壊して FAIL 確認 |
| AC-CQ04 | SSOT ドリフトチェックで、不一致を検出できる | 意図的に SSOT を変更して FAIL 確認 |
| AC-CQ05 | 回帰検出で、前回 PASS → 今回 FAIL を検出できる | 前回結果を保存し比較 |
| AC-CQ06 | `./kit all` に self-check が統合されている（verify → test → self-check → handoff） | `./kit all` 実行で self-check が含まれることを確認 |
| AC-CQ07 | 既存の verify / test / handoff が破壊されていない | 後方互換テスト |
| AC-CQ08 | self_check_task_tracker.md の全 Phase 0 項目が `[x]` | トラッカー確認 |

---

## 3. 運用要件

### 3.1 Evidence

- Self-check の結果は `logs/evidence/YYYYMMDD-HHMMSS_ciqa_<check_name>.txt` に保存する
- Evidence ヘッダは既存の書式に準拠:
  ```
  === Self-check: <Check Name> ===
  Timestamp (JST): <YYYY-MM-DD HH:MM:SS JST>
  Timestamp (UTC): <YYYY-MM-DDTHH:MM:SSZ>
  Check: <check_id>
  VERDICT: PASS | FAIL
  ---
  <details>
  ```

### 3.2 Exit Code

- `0`: 全チェック PASS
- `1`: 1件以上 FAIL
- 既存の verify / test と同一契約

### 3.3 失敗時の扱い

- FAIL でも全チェックを最後まで実行する（fail-fast しない）
- 各チェックの PASS/FAIL を個別に Evidence 化する
- サマリに FAIL 件数と該当チェック名を表示する

### 3.4 トラッカー連携

- `tasks/self_check_task_tracker.md` を Self-check 専用トラッカーとして運用する
- `[x]` 更新時は判定 / Evidence / 日時を必須とする（既存ルール踏襲）
- `./kit status` に Self-check トラッカーを追加表示する

---

## 4. 将来拡張

### 4.1 追加チェック（拡張ポイント）

| 拡張 | 説明 | 優先度 |
|------|------|--------|
| カバレッジ分析 | Gate A-I のどの要件がテストでカバーされているか | 中 |
| 変更影響分析 | git diff から影響を受ける Gate / チェックを特定 | 中 |
| カスタムルール | ユーザ定義の QA ルールを config で追加可能にする | 低 |
| レポート生成 | HTML/Markdown の品質レポート自動生成 | 低 |
| 外部 CI 連携 | GitHub Actions / pre-commit hook 向けのアダプタ | 低 |

### 4.2 追加 Runner（プラグイン方式）

- `scripts/lib/self_checks/` 配下に個別チェックスクリプトを配置
- 各スクリプトは共通インタフェース（引数・戻り値・出力書式）に準拠
- config ファイルで有効/無効を切り替え可能
- 新しいチェックは「スクリプトを1つ追加 + config に1行追加」で完了する設計

---

## 5. 変更履歴

- v1.0（2026-02-04 JST）：Self-check 要件定義 初版
