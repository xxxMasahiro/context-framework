# cf_handoff_prompt.md（このチャットの引継ぎメモ）

## 0. 目的
- 引継ぎ運用を「_handoff_check の3ファイル添付」に簡略化した（ZIP不要）。
- 今後 Prompt.md は使わない（参照禁止）。

## 1. 今回の変更サマリ（何を追加/削除/修正したか）
- 修正対象は _handoff_check の3ファイル：
  - _handoff_check/cf_handoff_prompt.md
  - _handoff_check/cf_update_runbook.md
  - _handoff_check/cf_task_tracker_v5.md
- 変更内容（要約）：
  - Gate F（INITIAL_SETTINGS導入・固定ロール撤廃）前提に統一
  - SSOTは _handoff_check の3ファイルで統一（ZIP不要）
  - Gate Fの証跡（PR#28/commit）をタスク表と更新ログに反映

## 2. エビデンス（コミット/状態）
- Gate F（PR#28）:
  - Merge: 18edacb
  - Commit: 463b277（docs: add INITIAL_SETTINGS + role assignment (Gate F)）
- 現状：main ブランチ、作業ツリー clean（作業前提）。
- 最新のタスク（暫定）: Concrete（初回）→ Abstract（2回）→ Skills（3回）の判定条件を“定義として固定”する（次チャットで合意→SSOT反映）
- 最新の次タスク: Gate G / 次フェーズ（定義固定）— 成功/失敗分類・Signature・Skill昇格条件を WORKFLOW/SKILLS_INTEGRATION.md 等へ移す

## 3. 同一性確認（引用個所と同じ最新版か）
- sha256 は固定値を書かず、必要時に現物で算出する：
  - `sha256sum _handoff_check/cf_handoff_prompt.md _handoff_check/cf_update_runbook.md _handoff_check/cf_task_tracker_v5.md`

## 4. 懸念点/次にやる候補（未実施）
※致命ではないが、将来の混乱を減らす改善候補（必要なら最小差分）
- tracker 冒頭に「v3」表記が残っている箇所があれば「v5」に寄せる
- runbook に旧運用の言い回し（例：添付3ZIP/next1-3 等）が残っていれば、新運用（添付3ファイル）へ文言を寄せる
（※矛盾まではしていない前提。実際に残っているかはSSOTの現物で確認して判断する）

## 5. 新チャット側への要求（最重要）
- 検索（見つからなくてもOK）系の `rg`/`grep` などは必ず `|| true` を付けて 0 終了にする（runbook ##8）
- 添付3ファイルを最初に読むこと
- `cf_handoff_prompt.md` 読了直後に `cf_update_runbook.md` の「## 8. 実行プロトコル（運用ルール）」を必ず確認し、以後の出力は **根拠/判定/変更提案** を厳守する
- SSOTは _handoff_check の3ファイル（ZIP不要）
- 運用規範は runbook/tracker を優先し、handoff_prompt は経緯メモとして整合させる
- tracker はスリム化済み。詳細テンプレ/完了済み一覧/旧ログは runbook 付録「tracker退避」へ移設
- 新規タスクの入口は Gate H（Phase 1）に統一する（Gate G は完了扱い）
- 次にやることは「1つ（1コマンド/1操作）」で提示すること
- 最初の安全確認として Repo Lock を実行する（`./tools/cf-guard.sh --check`）
- 役割は初期設定ファイルに従う（`WORKFLOW/TOOLING/INITIAL_SETTINGS.md` を参照）

### SSOT 3ファイルを添付できない場合の代替手順（必須）
- 代替: リポジトリの `_handoff_check/` から **直接読み込む**
- その前に必ず Guard（誤リポジトリ防止＋Repo Lock）を通す:
  - `cd /home/masahiro/projects/_cfctx/cf-context-framework`
  - `test "$(git rev-parse --show-toplevel)" = "/home/masahiro/projects/_cfctx/cf-context-framework"`
  - `./tools/cf-guard.sh --check`（Repo Lock: OK）
- 一括処理を希望された場合は、runbook 8.1 の「ガード付き一括テンプレ（コピペ枠）」へ誘導する  
  （一括でも Guard を先頭に置くこと）

---

## 追記（2026-01-25）｜次チャット引継ぎメモ：Concrete→Abstract→Skills 判定条件（未確定→合意予定）

### 背景（要約）
- 具体ログ（成功/失敗）を記録し、抽象ログ（カテゴリ/パターン）から検索→具体ログへ辿る。
- ログ膨張を避けるため、抽象は「索引＋パターン＋参照先（具体ログ/Skill）」に限定する。

### 提案フロー（草案）
- Concrete（初回）
  ↓
- Abstract（2回目で候補化）
  ↓
- Skills（3回目で昇格）

### 未確定の論点（次チャットで合意したい）
1) 成功/失敗の分類基準（Concreteに記録する単位）
2) 「同種が増えた」判断根拠をどこに置くか（ConcreteのSignature/タグ、または抽象側の集計）
3) 「解決が安定したらSkillへ昇格」= 解決/安定の定義（再現性、適用回数、証跡、受入テスト 等）

### 合意後にやること（CodexでSSOT反映）
- WORKFLOW/SKILLS_INTEGRATION.md / tracker / handoff_prompt に判定条件を“定義として固定”（追記のみ）
- 必要なら tracker に新タスク追加し、Progress Log/Updates に証跡を残す

（作業時点HEAD: b270712）

## 追記（2026-01-25）｜PR #54/#55（Gate G STEP-G005 チェック項目固定＋Progress Log証跡）

- 反映内容:
  - PR #54: Gate G / STEP-G005 に「受入テスト（最小シナリオ）チェック項目（実行→期待→記録）」を追記
  - PR #55: Progress Log/Updates に PR #54 の証跡（PR/commit/行番号レンジ）を追記
- Evidence:
  - PR #54 merged: merge f14ec13 / topic 69aad10
  - PR #55 merged: merge b1d4a36 / topic ca43087
  - 対象レンジ（目安）: `rg -n "STEP-G005" _handoff_check/cf_update_runbook.md || true` ＋ `rg -n "UPD-20260125-03" _handoff_check/cf_task_tracker_v5.md || true`
- 次に進むべきタスク:
  - ①成功/失敗分類 ②Signature（同種判定キー）③Skill昇格条件 を、トラッカー「チェック項目」から一段上げて **定義として固定**（WORKFLOW/SKILLS_INTEGRATION.md 等へ）するフェーズ
  - 新チャット開始の最初の1手: `./tools/cf-guard.sh --check`



## 追記（2026-01-25）| PR #51（Gate G Phase 3 — Skills導線/昇格条件/受入テスト）

### 目的
Gate G / Phase 3（STEP-G201〜G204）を、Skills統合の本文へ反映して確定する。

### 変更点（Add/Del/Mod）
- **Mod**: WORKFLOW/SKILLS_INTEGRATION.md
  - Skillsへの導線（抽象→Skill）
  - Skill昇格条件（候補化の条件）
  - 受入テスト（入口→Skillに辿れる）
- **Mod**: _handoff_check/cf_task_tracker_v5.md
  - STEP-G201〜G204 を Done 更新
  - Evidence/Progress Log を追記

### 証跡（Evidence）
- PR #51（merged）
- Merge commit: 8b51993
- commits: 97535ef / 3e5ff0a
- Repo Lock: OK / main == origin/main / working tree clean

次に進むべきタスク: Gate G / STEP-G005（受入テストの最小シナリオ検証）

---

## 追記（2026-01-24）｜PR #47（chore(tools): add safe branch cleanup scripts）

### 目的
- ブランチ掃除の安全手順を標準化し、ローカル/リモートの削除操作を再現可能にする。

### 変更点（Add/Del/Mod）
- **Add**: `tools/cleanup-local-merged.sh`
  - main にマージ済みのローカルブランチだけを安全に削除（`git branch -d`）
- **Add**: `tools/delete-remote-branch.sh`
  - `--yes` 必須のリモート削除（protected: main/master/HEAD 拒否）
  - `--yes` なしは DRY-RUN で即終了（ネットワーク不要）

### 証跡（Evidence）
- PR #47（merged）
- Merge: `f6d5c7c`

---

## 追記（2026-01-24）｜Gate G 進捗（STEP-G005/101/102）

### 目的
- Gate G の最新進捗を handoff に反映し、runbook/tracker と整合させる。
- INDEX は Generated（手編集禁止）であり、“正”は tracker/runbook に置く方針を明示する。

### 変更点（Add/Del/Mod）
- **Add**: handoff_prompt に進捗メモを追記（本項）

### 進捗（Done）
- STEP-G005: 受入テスト（失敗→抽象→具体→解決策）PASS → Done[x]
- STEP-G101: 固定カテゴリ案（git/tooling/docs/workflow/log-index + OTHER）→ Done[x]
- STEP-G102: パターン分類案（reference-miss / generation-gap / permission-block / connectivity-issue / procedure-mismatch / state-divergence）→ Done[x]

### 証跡（Evidence）
- Progress Log: `UPD-20260124-04` / `UPD-20260124-05` / `UPD-20260124-06`
- tracker: `_handoff_check/cf_task_tracker_v5.md`（Gate G Phase 1/2）

### 次にやること
- STEP-G103（新カテゴリ追加ルールの必要性判定）→ STEP-G104（受入テスト）
- 新チャット開始時の最初の一手: `./tools/cf-guard.sh --check`


## 追記（2026-01-25）｜Gate G STEP-G103（新カテゴリ追加ルール）完了

### 目的
- カテゴリ増殖（肥大化）を抑えるため、新カテゴリ追加の Go/No-Go（同種2回目から検討）を最小ルールとして確定し、SSOT（tracker）へ反映したことを handoff に記録する。

### 変更点（Add/Del/Mod）
- **Mod**: `_handoff_check/cf_task_tracker_v5.md`
  - STEP-G103 を Done[x] に更新
  - 「新カテゴリ追加ルール（STEP-G103）」を追記（3〜7行の最小ルール）
  - Progress Log/Updates に `UPD-20260124-07` を追記（日時/タスクID/証跡）

### 証跡（Evidence）
- Commit: `857cb61`（STEP-G103 完了を main へ反映済み）
- Repo: main / origin/main 同期、作業ツリー clean（手元確認済み）

### 次にやること
- Gate G Phase 2 / STEP-G104（受入テスト）※原則 read-only 検証→必要なら最小 diff 提案
- 新チャット開始時の最初の一手: `./tools/cf-guard.sh --check`

---

## 追記（2026-01-24）｜PR #46（Gate G STEP-G004 decision）

### 目的
- Gate G Phase 1 / STEP-G004（運用ルール追記の要否判定）を完了し、運用ルールは「追記不要」と確定。

### 変更点（Add/Del/Mod）
- **Mod**: `_handoff_check/cf_task_tracker_v5.md`
  - STEP-G004 を Done[x] に更新（Evidence: `rg -n "Repo Lock（作業開始前の必須チェック）" _handoff_check/cf_update_runbook.md || true`）
  - Progress Log/Updates に `UPD-20260124-02` を追記
- **Mod**: `LOGS/INDEX.md`
  - `./tools/cf-log-index.sh` 再実行で再生成（`UPD-20260124-02` を反映）

### 証跡（Evidence）
- PR #46（merged）
- Merge: `5dd667f`
- 次に進むべきタスク: Gate G / STEP-G005（受入テストの最小シナリオ検証）
- 新チャット開始時の最初の1手: `./tools/cf-guard.sh --check`

---

## 追記（2026-01-24）｜PR #44（Gate G STEP-G003 抽象ログ（索引）仕様合意）

### 目的
- Gate G Phase 1 / STEP-G003（抽象ログ仕様合意）を完了し、Concrete（tracker）と Abstract（LOGS/INDEX）を整合させる。

### 変更点（Add/Del/Mod）
- **Mod**: `_handoff_check/cf_task_tracker_v5.md`
  - Gate G: STEP-G003 を Done[x] に更新（Evidence: `LOG-009` / `LOGS/INDEX.md`）
  - `LOG-009` を追記（抽象ログ仕様の合意内容）
  - Progress Log/Updates に `UPD-20260124-01` を追記
- **Mod**: `LOGS/INDEX.md`
  - `./tools/cf-log-index.sh` 再実行で再生成（`LOG-009` / `UPD-20260124-01` を反映）

### 証跡（Evidence）
- PR #44（merged）
- Merge: `40b3f0c`
- Repo Lock: OK / `main == origin/main` / working tree clean
- 次に進むべきタスク: Gate G / STEP-G004（運用ルール追記が必要か判定）
- 新チャット開始時の最初の1手: `./tools/cf-guard.sh --check`
- 確認コマンド:
  - `rg -n "^| STEP-G003" _handoff_check/cf_task_tracker_v5.md`
  - `rg -n "LOG-009" _handoff_check/cf_task_tracker_v5.md`
  - `rg -n "UPD-20260124-01" _handoff_check/cf_task_tracker_v5.md`
  - `rg -n "LOG-009" LOGS/INDEX.md`
  - `rg -n "UPD-20260124-01" LOGS/INDEX.md`

---

## 追記（2026-01-24）｜PR #43（handoff note for STEP-G002）

### 目的
- STEP-G002 完了後の引継ぎメモを追加し、handoff_prompt の経緯メモを最新化する。

### 変更点（Add/Del/Mod）
- **Mod**: `_handoff_check/cf_handoff_prompt.md`
  - STEP-G002 完了の引継ぎメモを追記

### 証跡（Evidence）
- PR #43（merged）
- Merge: `7a86b2a`

---

## 追記（2026-01-23）｜PR #42（Gate G STEP-G002 minimal concrete log template）

### 目的
- Gate G Phase 1 / STEP-G002（具体ログの最小テンプレ合意）を完了し、Concrete（tracker）と Abstract（LOGS/INDEX）を整合させる。

### 変更点（Add/Del/Mod）
- **Mod**: `_handoff_check/cf_task_tracker_v5.md`
  - Gate G: STEP-G002 を Done[x] に更新（Evidence: `LOG-008` / `LOGS/INDEX.md`）
  - `LOG-008` を追記（最小テンプレ合意の内容を明文化）
  - Progress Log/Updates に `UPD-20260123-02` を追記（検索導線の証跡を追加）
- **Mod**: `LOGS/INDEX.md`
  - `./tools/cf-log-index.sh` 再実行で再生成（`LOG-008` / `UPD-20260123-02` を反映）

### 証跡（Evidence）
- PR #42（merged）
- Merge: `244dc7b` / Commit: `1b844f5`
- Branch: `wip/gate-g-stepg002`（削除済み）
- Repo Lock: OK / `main == origin/main` / working tree clean
- 次に進むべきタスク: Gate G / STEP-G003（抽象ログ仕様合意）
- 新チャット開始時の最初の1手: `./tools/cf-guard.sh --check`
- 確認コマンド:
  - `rg -n "^| STEP-G002" _handoff_check/cf_task_tracker_v5.md`
  - `rg -n "LOG-008" _handoff_check/cf_task_tracker_v5.md`
  - `rg -n "UPD-20260123-02" _handoff_check/cf_task_tracker_v5.md`
  - `rg -n "LOG-008" LOGS/INDEX.md`
  - `rg -n "UPD-20260123-02" LOGS/INDEX.md`

---

## 追記（2026-01-23）｜PR #40（Gate G STEP-G001 logs/index sync）

### 目的
- Gate G Phase 1 / STEP-G001（現状棚卸し）を完了し、Concrete（tracker）と Abstract（LOGS/INDEX）を整合させる。

### 変更点（Add/Del/Mod）
- **Mod**: `_handoff_check/cf_task_tracker_v5.md`
  - Gate G: STEP-G001 を Done[x] に更新（Evidence: `LOG-007` / `LOGS/INDEX.md`）
  - `LOG-007` を追記（Concrete/Abstract/検索導線/証跡確定の記録）
  - Progress Log/Updates に `UPD-20260123-01` を追記（索引生成ツールが拾えるよう行パイプ形式に正規化）
- **Mod**: `LOGS/INDEX.md`
  - `./tools/cf-log-index.sh` 再実行で再生成（`LOG-007` / `UPD-20260123-01` を反映）

### 証跡（Evidence）
- PR #40（merged）
- Merge: `9a802ee` / Commit: `b4e1f7a`
- Branch: `wip/gate-g-stepg001`（削除済み）
- Repo Lock: OK / `main == origin/main` / working tree clean
- 確認コマンド:
  - `rg -n "^| STEP-G001" _handoff_check/cf_task_tracker_v5.md`
  - `rg -n "LOG-007" _handoff_check/cf_task_tracker_v5.md`
  - `rg -n "UPD-20260123-01" _handoff_check/cf_task_tracker_v5.md`
  - `rg -n "LOG-007" LOGS/INDEX.md`
  - `rg -n "UPD-20260123-01" LOGS/INDEX.md`

---

## 追記: 2026-01-20 PR#25（例外：PR後の後処理を“ガード付きで一括提示”してよいケース）

### 変更点（何を追加・削除・修正したか）
- Mod: `_handoff_check/cf_task_tracker_v5.md`
  - 「次にやることは1つ（1コマンド/1操作）」原則の**例外**として、Developerが明示的に依頼した場合のみ
    「PR作成→merge→branch削除→main同期→prune→status」を**まとめて提示してよい**旨を追記（詳細は runbook 8.1）。
- Mod: `_handoff_check/cf_update_runbook.md`
  - `8.1 例外: PR後の後処理をまとめて提示する場合（ガード付き一括手続きテンプレ）` を追記。
  - main保護、`--ff-only`、開始ブランチ（`TOPIC_BRANCH` / `start_branch`）、削除条件、想定repoガード等を明文化。

### エビデンス
- PR: #25（merged）
- commit: `eb6fc91`（docs: add guarded batch cleanup exception）
- merge commit: `8d888ab`
- 作業ブランチ: `wip/exception-batch-postpr-cleanup`（削除済み）
- 最終状態: `main` が `origin/main` と一致（`git status -sb` で確認）

## 6. 追記（2026-01-21）｜Gate F 完了（役割固定撤廃 / INITIAL_SETTINGS導入）
- 方針:
  - 役割は初期設定ファイルで割り当て（固定しない）
  - 3ファイル（CLAUDE/AGENTS/GEMINI）は入口として初期設定を参照
- エビデンス:
  - PR#28（merged）
  - Merge: 18edacb / Commit: 463b277

## 7. 追記（2026-01-22）｜初期設定の実運用ファイルはローカル専用（.gitignore）
- 目的:
  - INITIAL_SETTINGS の実運用ファイルを誤コミットしないため（.gitignore化）
- 変更点:
  - PR #31 で `.gitignore` にローカル専用ファイルの除外を反映済み
  - runbook に「実運用ファイルは Git 管理しない」旨を追記
  - tracker に Progress Log/Updates の追記
- 証跡:
  - PR #31（merged）
  - Merge: ee5c074 / Commit: 8f06dcc
  - Repo Lock: OK / main==origin/main / working tree clean
- 変更点（Add/Del/Mod）:
  - Mod: _handoff_check/cf_handoff_prompt.md / _handoff_check/cf_update_runbook.md / _handoff_check/cf_task_tracker_v5.md

---

## 追記（2026-01-22）｜runbook「添付不可時の代替手順」注記の追加

### 目的
- runbook単体で読んだ新エージェントが「3ファイル添付できない」ケースで詰まる確率を下げる。

### 変更点（Add/Del/Mod）
- **Mod**: `_handoff_check/cf_update_runbook.md`
  - 「表記ポリシー（日本語統一 / SSOT）」内の「3ファイル必ず添付」直後に、
    「添付できない場合は `cf_handoff_prompt.md` の『SSOT 3ファイルを添付できない場合の代替手順』に従う。」を**1行**追記。

### 証跡（Evidence）
- Repo Lock: OK
- Commit: 35a6483（docs: runbookに添付不可時の代替手順注記を追記）
- 状態: `main == origin/main`, 作業ツリー clean
- 追記行確認: `rg -n "添付できない場合は.*代替手順" _handoff_check/cf_update_runbook.md` で該当行を確認

---

## 追記（2026-01-22）｜PR #33（衝突時の意思決定フロー／tracker修復）

### 変更点（Add/Del/Mod）
- **Mod**: `_handoff_check/cf_update_runbook.md`
  - 4.1 ロール（責務）に「衝突時の意思決定」1行を追記
- **Mod**: `_handoff_check/cf_task_tracker_v5.md`
  - Progress Log/Updates の UPD-20260122-02 を復元（壊れ行の修正）

### 証跡（Evidence）
- PR #33（merged）
- Merge: 85f2e88 / Commits: 554ed36, fb54b7d
- 最終状態: Repo Lock: OK / `main == origin/main` / working tree clean

## 追記（2026-01-22）｜PR #36（ログ索引生成ツール導入）
- PR #36（merge commit: 2f8cc22）
  - tools/cf-log-index.sh を追加（trackerから LOG/UPD/SKILL-LOG を抽出して LOGS/INDEX.md を生成）
  - LOGS/INDEX.md を追加（生成物：手編集禁止、再生成コマンドは `./tools/cf-log-index.sh`）
  - _handoff_check/cf_update_runbook.md に「LOGS/INDEX.md は生成物。tracker更新PRでは再生成して同一PRで更新」を1行追記
  - _handoff_check/cf_task_tracker_v5.md に UPD-20260122-04 を追記（Done[x]）
- 証跡: Merge 2f8cc22 / Commits d404554, 593dea4 / Repo Lock OK / main==origin/main / clean

## 追記（2026-01-22）｜PR #38（Gate G 追加＋LOGS/INDEX更新）
- PR #38（merged）
  - tracker: Gate G（Concrete/Abstract連携のロードマップ）追加＋Done定義、Progress Log/Updates に UPD-20260122-05 追記
  - runbook準拠: tracker更新に伴い tools/cf-log-index.sh を再実行し、LOGS/INDEX.md を同一PRで更新（生成物）
  - 状態: PR merge済み／ブランチ削除済み／main==origin/main／Repo Lock: OK
---

## 追記（2026-01-25）｜Gate G Phase 2: STEP-G104（受入テスト）Done → 次は Phase 3（STEP-G201）

### 変更点（Add/Del/Mod）
- **Mod**: `_handoff_check/cf_task_tracker_v5.md`
  - STEP-G104 を Done[x]（procedure-mismatch / runbook:パッチ事故防止）
  - Progress Log/Updates: UPD-20260125-01 を追記
- **Mod**: `_handoff_check/cf_update_runbook.md`
  - 出力（根拠/判定/変更提案）を「重要点のみ短く」する運用ルールを最小追記
- **Mod**: `_handoff_check/cf_handoff_prompt.md`（本追記）

### 証跡（Evidence）
- Commit: `7f9655a`（docs: trackerでSTEP-G104をDoneに更新）
- 状態: Repo Lock: OK / `main == origin/main` / working tree clean
- 次に進むべきタスク: Gate G / Phase 3 / STEP-G201（Skill昇格条件）
- 新チャット開始時の最初の1手: `./tools/cf-guard.sh --check`
- 確認コマンド:
  - `rg -n "STEP-G20" _handoff_check/cf_update_runbook.md || true`
  - `rg -n "Progress Log/Updates" _handoff_check/cf_task_tracker_v5.md || true`


### Handoff Memo: PR #57-#60（Gate G: STEP-G006/STEP-G007）
- 目的: Concrete→Abstract→Skills の運用（成功/失敗/同種判定/昇格/例外）を定義固定し、同種判定の集計（Signature出現回数）をオンデマンドで検出できるようにした。
- 反映内容:
  - PR #57 (merged): docs: add STEP-G006 define-freeze (Concrete→Abstract→Skills)
  - PR #58 (merged): docs: mark STEP-G006 done and log PR57
  - PR #59 (merged): docs: add signature report tool (STEP-G007)
  - PR #60 (merged): docs: mark STEP-G007 done and log PR59
- Evidence（代表）:
  - merge commits: PR57=6305b49 / PR58=390dd58 / PR59=795d53f / PR60=695279
  - tool: tools/cf-signature-report.sh（read-only, refs付き）
- 使い方（同種2回/3回の候補検出）:
  - ./tools/cf-guard.sh -- tools/cf-signature-report.sh -min 2
  - ./tools/cf-guard.sh -- tools/cf-signature-report.sh -min 3 -scope LOGS
- 次に進むべき作業:
  - _handoff_check/cf_task_tracker_v5.md の Gate H 未完了 [ ] を上から実施（Concreteの記録→Signature付与→集計→Abstract/Skill昇格判断）。


## 追記（2026-01-26）｜PR #62/#63：runbook8 出力契約・検索0終了ルールを固定

### 変更内容（最小差分）
- PR #62（merged）: handoff_prompt に runbook8 必読＋出力契約（**根拠/判定/変更提案**）を明示
- PR #63（merged）: runbook8 に「見つからなくてもOKの検索は `rg/grep ... || true` で 0 終了」を運用ルールとして固定

### Evidence（代表）
- PR #62: merge commit = 2f56e69 / commit = 6facfa8
- PR #63: merge commit = 7b4ed39 / commit = c98331c

### 次チャットの開始手順（再掲）
- Repo Lock: `./tools/cf-guard.sh --check`
- 読み込み順: handoff → runbook（##8）→ tracker
- 出力: **根拠/判定/変更提案**
- 検索（見つからなくてもOK）: `rg ... || true`

<!-- CFCTX_HANDOFF_20260126_SSOT_DEDUP_NOTE_V2 -->
## 引継ぎメモ（2026-01-26 15:33 JST）

### 現状（確定）
- Repo Lock: OK
- 同期: HEAD と origin/main が同一（fd13699）
- 作業ツリー: clean（このメモ追加後は差分が出ます）

### このチャットで確定した論点
- 『3ファイルの整合性から無駄を省いて整理（特にトラッカーの重複/不要の削除）』は、SSOT（_handoff_check の3ファイル）へは **未反映**。
- （注）一時ワークスペース `_handoff_check/_workspace_tracker_20260126/`／`cf_task_tracker_v5.WIP.md` はリポジトリ内に実体が見つからない（作成は未実施 or ローカルのみで破棄済みの可能性）。以後は SSOT（_handoff_check の3ファイル）を正として作業する。
- SSOT方針: ZIPは不要。正は `_handoff_check` の3ファイル（cf_handoff_prompt.md / cf_update_runbook.md / cf_task_tracker_v5.md）。

### 次にやること（1つだけ）
- SSOT 3ファイルに ZIP/旧運用の残骸がないか横断検索し、結果を貼って判定する。

```bash
./tools/cf-guard.sh -- rg -n "(ZIP|zip|cf_handoff_and_tracker\\.zip|next[0-9]+_work\\.zip)" \
  _handoff_check/cf_handoff_prompt.md \
  _handoff_check/cf_update_runbook.md \
  _handoff_check/cf_task_tracker_v5.md || true
```

<!-- CFTCX_HANDOFF_20260126_PR66_67_NOTE -->

## 引継ぎメモ（2026-01-26）

### 直近で確定したこと（PR #66/#67 の反映状況）
- PR #66（merge commit: 7897a64）: handoff_prompt 内の「workspace_tracker_20260126 / cf_task_tracker_v5.WIP.md 作成」記述は、**リポジトリ実体（ファイル/ディレクトリ）が見つからない**ため、未実施 or ローカルのみの可能性として扱う（SSOTは _handoff_check の3ファイルを正とする）。
- PR #67（merge commit: 4998f4f）: SSOT運用の「本文中の .zip は旧運用ラベル（実体ZIPは前提にしない）」に加え、**vendor/ 配下の *.zip は入力/成果物ZIP（実体）であり、運用ZIP廃止/ラベル扱いとは別物**、を明確化。

### 現状（確定）
- Repo Lock: OK
- HEAD == origin/main（merge PR #67 反映済み）
- working tree: clean

### 次にやること（1つだけ）
./tools/cf-guard.sh --check
意味（復習用）: Repo Lock の安全確認（想定リポジトリ以外なら中止）
