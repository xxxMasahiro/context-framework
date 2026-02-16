# Gate A〜I 検証・テスト用キット 実装計画（暫定）

## 0. 目的
要件定義・仕様に従い、Gate A〜I の検証・テストを安全に実行できる一時キットを構築する。
構築後、このキット（+ SSOT）を Codex high に渡し、横断検証・テストを実施する。

---

## 1. 進め方（フェーズ）
### Phase 1：ブートストラップ（キット生成）
- `GATE_AUDIT_ROOT` を確認（未設定なら中断 / 例外は明示オプトイン）
- `$GATE_AUDIT_ROOT/.gate-audit/` を生成（既定・推奨）
- `_handoff_check/` の SSOT 3ファイルを SSOT/  へコピー
- `context/` と `tasks/` を作成
- `scripts/` に最小スクリプト群を作成（verify / evidence / handoff / lockdown / unlock）
- `.gitignore` を置き、検証キットが commit されないことを担保

**完了条件**
- `GATE_AUDIT_ROOT` が設定され、検証キットが **リポジトリ外**に生成されている（既定）
- `README.md` が存在し、キットの目的と使い方が記載されている
- SSOT/  に3ファイルが揃っている
- `scripts/verify.sh` が read-only で動作し、ログが残る（dry-run でも可）

### Phase 2：最小検証（スモーク）
- `./tools/guard.sh --check`（Repo Lock）を Evidence 化
- `./tools/doctor.sh step STEP-G003`（最小スモーク）を Evidence 化
- Gate C（アダプタ）参照整合のチェック（ファイル存在/参照先）を read-only で確認
- Gate G（ログ導線）最低限の “辿れる” 確認（索引/ログ/ルールの存在）を確認

**完了条件**
- PASS/FAIL が出せる
- `handoff/latest.md` が生成される

### Phase 3：全体検証（フル）
- Gate A〜I の検証チェックリストを `tasks/verify_task_tracker.md` で回す
- 体系的整合性（概念定義の衝突、参照切れ）を `rg` 等で検出（`|| true`）
- 必要に応じて CI/Controller 周辺の検証（ただし “安全・最小” で）

**完了条件**
- Gate A〜I の要件①②③が Evidence 付きで説明できる
- 合格なら Gate J / J0 の具体タスクへ進む準備が整う

### Phase 4：ロックダウン（隔離）
- `scripts/lockdown.sh` で検証キットを quarantine へ移動し、アクセス制限（owner のみ）
- `LOCKED.flag` によりロック状態を明示する
- 必要時のみ `scripts/unlock.sh` で解除できる状態にする（固定フレーズ入力の二段階解除）

---

## 2. 検証観点（Gate A〜I）
- 要件①：各Gateで追加した機能の説明（SSOT・差分・ログに基づく）
- 要件②：全体の体系（SSOT→Adapter→Artifacts→Audit→Logs→Doctor）に矛盾がない
- 要件③：最小実行で PASS/FAIL が取れる（doctor、ガード、整合チェック）

---

## 3. Codex high への引き渡し（実行用コンテキスト）
### 3.1 Codex high に渡す情報（最低限）
- SSOT 3ファイル（_handoff_check）
- 本キットの 3 文書（要件定義 / 仕様 / 実装計画）
- 直近の handoff（あれば）
- 実行ログ（あれば）

### 3.2 Codex high への依頼テンプレ（案）
- 目的：Gate A〜I の横断検証（read-only中心）
- 出力：常に「根拠 / 判定 / 変更提案」
- 進め方：1コマンドずつ提示（ユーザーが実行→結果貼付）

※ 実際のプロンプト本文は `context/codex_high_prompt.md` に作成する。

---

## 4. 実装タスクリスト（キット生成側）
- [ ] `GATE_AUDIT_ROOT` を確認し、既定では **リポジトリ外**にキットを生成する
- [ ] `.gate-audit/` を作成（例外は明示オプトイン）
- [ ] `.gitignore` を作成（検証キット全体を無視）
- [ ] SSOT/  に3ファイルをコピー
- [ ] `tasks/verify_task_tracker.md` を生成（Gate A〜I チェック項目）
- [ ] `context/run_rules.md` を生成（運用ルール）
- [ ] `context/codex_high_prompt.md` を生成
- [ ] `scripts/*.sh` を生成（verify/evidence/handoff/lockdown/unlock）
- [ ] Phase 2 スモークを実行し、Evidence を保存
- [ ] `->handoff` トリガの運用を確立（handoff/latest.md を即時出せる）

---

## 5. リスクと対策
- リスク：検証キットが repo に混入し、運用が複雑化する  
  対策：`.gitignore` 強制、quarantine への移動、権限制限
- リスク：検証が “ドキュメント確認” だけで終わり、機能性が未検証  
  対策：doctor/guard を必須スモークにする
- リスク：検証が長期化して状況が分からなくなる  
  対策：verify_task_tracker と handoff 自動生成で可視化

---

## 6. 変更履歴
- v0.1（2026-01-31 JST）：初版（実装計画ドラフト）
