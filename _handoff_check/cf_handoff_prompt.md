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
- 最新の次タスク: Gate I / I1（Gate I 入口定義: 目的/Done条件/最初の1手をSSOTに最小追記）

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
- 運用規範の最上位は runbook。trackerは進捗、handoff_prompt は経緯メモとして整合させる
- 次にやる1手の正は tracker の進捗サマリ。過去追記内の“次にやる”は履歴扱い。
- tracker はスリム化済み。詳細テンプレ/完了済み一覧/旧ログは runbook 付録「tracker退避」へ移設
- 新規タスクの入口は Gate H（Phase 1）に統一する（Gate G は完了扱い）
- 次にやることは「1つ（1コマンド/1操作）」で提示すること
- 最初の安全確認として Repo Lock を実行する（`./tools/cf-guard.sh --check`）
- 役割は初期設定ファイルに従う（`WORKFLOW/TOOLING/INITIAL_SETTINGS.md` を参照）

### SSOT 3ファイルを添付できない場合の代替手順（必須）
- 代替: リポジトリの `_handoff_check/` から **直接読み込む**
- その前に必ず Guard（誤リポジトリ防止＋Repo Lock）を通す:
  - `cd /home/masahiro/projects/context-framework`
  - `test "$(git rev-parse --show-toplevel)" = "/home/masahiro/projects/context-framework"`
  - `./tools/cf-guard.sh --check`（Repo Lock: OK）
- 一括処理を希望された場合は、runbook 8.1 の「ガード付き一括テンプレ（コピペ枠）」へ誘導する  
  （一括でも Guard を先頭に置くこと）

---


## 追記（2026-01-28）| Gate I: I1 開始（入口定義）

- 反映内容:
  - I0 を完了扱いで閉じ、I1 を未完了として開始
  - 3ファイルの「次にやる1手」を I1 に統一
- Evidence: commit: 7ba1242
- 次にやる1手: Gate I / I1（Gate I 入口定義: 目的/Done条件/最初の1手をSSOTに最小追記）


## 追記（2026-01-28）｜Gate I 開始（I0: SSOTスリム化）

- 反映内容:
  - tracker: Gate H 完了チェックリストを runbook 付録へ退避し、未完了を Gate I / I0 に移行
  - runbook: Gate H アーカイブ（完了済みチェックリスト）を付録として追加
  - handoff: 最新の次タスクを Gate I / I0 に統一
- Evidence: commit: 54a6bae
- 次にやる1手: Gate I / I1（Gate I 入口定義: 目的/Done条件/最初の1手をSSOTに最小追記）

## 追記（2026-01-28）｜Gate H / Phase 3 H12（運用成熟：CI/ログ整備）完了

- 反映内容:
  - CI: `.github/workflows/ci-validate.yml` 追加
  - 検証: `tools/cf-ci-validate.sh` 追加（rules/manifest/routes/policy + smoke）
  - ログ: `LOGS/ci/*.log` を artifact 回収
- Evidence: commit: 9626c12 / cmd: ./tools/cf-ci-validate.sh
- 次にやる1手: Gate I / I1（Gate I 入口定義: 目的/Done条件/最初の1手をSSOTに最小追記）

## 追記（2026-01-27）Gate H / Phase 1：H7〜H8 完了 → 次は H9（Gate C 検証組込み）

- 状況
  - H7 / H8 は PR で main に反映済み（2段階出力の定型追加・テスト強化まで完了）
  - 次に進むべきタスク: Gate H / Phase 1 / H9（Gate C 検証組込み）

- トラッカー（参照）
  - - 次にやる1手: Gate I / I1（Gate I 入口定義: 目的/Done条件/最初の1手をSSOTに最小追記）
  - - [x] H8: Phase 1 — テスト（不一致は停止 / high riskはGo/NoGo / JSON破損は再生成or停止）
  - - [ ] H9: Phase 1 — Gate C 検証組込み（`validate_agent_adapters()`：STEP-304/305/306）

- Evidence（Progress Log）
  - - 2026-01-27T14:03:15+0900 | UPD-20260127-08 | Gate H: H8 テスト（不一致/高risk/JSON破損）完了 | Evidence: commit:4a4c86f / cmd: ./tools/cf-controller-smoke.sh
  - - 2026-01-27T13:31:37+0900 | UPD-20260127-07 | Gate H: H7 2段階出力（分類→生成）整備完了 | Evidence: commit:b4b9295 / cmd: ./tools/cf-controller-smoke.sh

- H9 以降の外部仕様（Codex実行時は必ず参照）
  - /mnt/c/Users/MASAHIRO/Desktop/作業ファイル/メモ/UPDATE/_mpc/01_説明.md
  - /mnt/c/Users/MASAHIRO/Desktop/作業ファイル/メモ/UPDATE/_mpc/02_要件定義.md
  - /mnt/c/Users/MASAHIRO/Desktop/作業ファイル/メモ/UPDATE/_mpc/03_仕様書.md
  - /mnt/c/Users/MASAHIRO/Desktop/作業ファイル/メモ/UPDATE/_mpc/04_実装計画.md



## 追記（2026-01-27）｜Gate H H4 ルール設計完了

- 反映内容: rules/ssot_manifest.yaml を拡張（charter/architect/skills/projection/allowlist）、rules/routes.yaml と rules/policy.json を追加（決定論ルート/分類スキーマ/危険フラグ/ Gate C検知）。
- Evidence: commit:0fd03cf

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

### 確定済み（再確認）
※内容は変更せず、STEP-G006 を正として再確認。
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
- カテゴリ増殖（肥大化）を抑えるため、新カテゴリ追加の Go/No-Go（同種2回目から検討）を最小ルールとして確定し、進捗（tracker）へ反映したことを handoff に記録する。

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
- 確定ルール: 参照不能/存在不明の作業メモは SSOT 判断根拠にしない。
- SSOT方針: ZIPは不要。正は `_handoff_check` の3ファイル（cf_handoff_prompt.md / cf_update_runbook.md / cf_task_tracker_v5.md）。

### 調査証跡（2026-01-26）
- `ls -la _workspace_tracker_20260126` → `No such file or directory`
- `find . -maxdepth 3 -type d -name "*workspace*tracker*"` → 検出なし

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

## 追記 (2026-01-27) | PR #70/#71 : Gate H 入口統一 + tracker Evidence 修正
- PR #70（merged）: 新規タスクの入口を Gate H（Phase 1）に統一（Gate G は完了扱い）。Evidence: PR #70 / merge e9105da
- PR #71（merged）: tracker 更新ログ UPD-20260126-03 の Evidence を「PR予定」から「PR #70 / merge e9105da」へ修正。Evidence: PR #71 / merge 6d5df16

（新チャットでは SSOT として _handoff_check の3ファイルを添付し、最初に Repo Lock（./tools/cf-guard.sh --check）から開始する）


<!-- CFCTX_HANDOFF_20260127_GATEH_H4_RULES_START -->
## 引継ぎメモ（2026-01-27 10:43 JST）｜Gate H: H4（ルール設計）着手

### 直近の確定（PR）
- PR #74（merged / merge: 23f03dd / commit: 9c5624e）: Gate H に Controller 実装タスク（Phase 0〜3）を追加
- PR #75（merged / merge: aaa01ea / commit: edb1cb2）: UPD-20260127-01 の Evidence を PR #74 に確定（埋め残し解消）
- PR #76（merged / merge: c70ccd1 / commits: 1f8fa30, a8a0714）: H3（Phase 0 ctx-run + ssot_manifest 最小）実装・tracker H3 を Done[x]

### 現状
- Repo Lock: OK
- 作業ブランチ: wip/gate-h-h4-rules
- HEAD: c70ccd1
- 次タスク: H4（Phase 1 — ルール設計：routes.yaml / policy.json / ssot_manifest.yaml）

### 次にやること（1つだけ）
```bash
./tools/cf-guard.sh --check
```
意味（復習用）: Repo Lock の安全確認（想定リポジトリ以外なら中止）

（新チャットでは SSOT 3ファイルを添付し、Gate H / H4 を進める）

<!-- CFCTX_HANDOFF_20260127_GATEH_H4_RULES_DONE -->
## 追記（2026-01-27 12:11 JST）｜Gate H: H4（ルール設計）完了

### 完了内容
- PR #78（merged）: `rules/routes.yaml` / `rules/policy.json` / `rules/ssot_manifest.yaml` の導入・更新、および SSOT 側の完了記録（Evidence）を反映。

### Evidence
- PR #78 / merge: 7885ee5

### 現状
- Repo Lock: OK
- 作業ブランチ: wip/handoff-pr78-h4-done
- HEAD: 7885ee5
- 次タスク: Gate H / Phase 1 / H5（Controller骨格）

### 次にやること（1つだけ）
```bash
./tools/cf-guard.sh --check
```
意味（復習用）: Repo Lock の安全確認（想定リポジトリ以外なら中止）

## 追記

## 追記（2026-01-28）｜PR #91（Gate I: I1 入口定義）＋Repo Lock（CI expected_remotes）整合
・ 注記: PR一覧で #89/#90 が×なのは当時のRepo Lock expected_remotes不一致が原因。後続PR #91で解消済み。

- 事象:
  - CI validate で Repo Lock: NG（reason: origin remote does not match expected_remotes）
- 対応:
  - expected_remotes に https origin を追加（CI/runner の origin が https のため）
- Evidence:
  - PR #91 merged（main）: commit:39339b3
  - Gate I / I1 start 記録: commit:207545b
  - Repo Lock fingerprint 更新: commit:b3c80c7
- 次にやる1手: Gate I / I1（Gate I 入口定義: 目的/Done条件/最初の1手をSSOTに最小追記）

<!-- CFCTX_HANDOFF_GATEI_PR93_94_NOTE -->
## 追記（2026-01-29 18:38 JST）｜PR #93/#94（Gate I 番号整理＋runbook注記）反映

- 事象:
  - Gate I の番号が I2→I1、I1→I0 へ整理され、入口定義を I1 から開始する運用に統一された。
  - runbook に「Gate I: 入口定義（I1）＆ SSOTスリム化（I0）」の注記ブロックが追加された。
- 対応:
  - handoff にも上記を明記し、次チャットの「次にやる1手」を Gate I / I1 に統一する。
- Evidence:
  - PR #93 merged（merge:87410aa）
  - PR #94 merged（merge:b7ae771）
- 次にやる1手: Gate I / I1（入口定義: 目的/Done条件/最初の1手をSSOTに最小追記）

---

## 引継ぎメモ（20260130-014312）: STEP-G003 / cf-doctor / SSOT混乱の整理

### 根拠
- 外部仕様（特に 03_仕様書.md）に `ssot: _handoff_check/cf_task_tracker_v5.md` と tracker 前提の invariants が記載されていたため、Claude Code が「tracker 正」と解釈した可能性が高い。
- あなたの運用整理：SSOT最高位は runbook（_handoff_check/cf_update_runbook.md）。tracker は進捗計測、handoff_prompt は引継ぎ便宜。
- 観測メモ（ターミナル出力より）：cf-doctor.sh が `sh` 実行で syntax error（line 131 付近）を起こした。原因候補は **POSIX sh で無効なクォート/正規表現（例：sed の single-quote 内に \\' を含める等）**。

### 判定
- **SSOT（最高位）= cf_update_runbook.md** に統一するのが正。
- 外部4ファイル（01-04）は runbook 最上位の優先順位を明文化し、spec/doctor も runbook 参照へ寄せる。
- doctor は read-only のまま、**PASS/FAIL + 根拠 + Next 1 action** を安定出力できればよい。

### 変更提案（次タスクの方向性）
- 外部4ファイル（01-04）: SSOT優先順位を「runbook > tracker（進捗） > handoff_prompt（便宜）」で統一（※既にCodexで修正を進めている想定）。
- repo側: tools/cf-doctor.sh を POSIX sh/dash 互換で修正（クォート事故の解消）。
- repo側: Gate G の SPEC（例: WORKFLOW/SPEC/gates/gate-g.yaml）も SSOT を runbook に統一し、evidence_commands は末尾 `|| true` を付ける。
- 必要なら: tools/cf-log-index.sh の入力デフォルトが tracker 参照になっていないか点検し、runbook 正へ寄せる（別PRでも可）。

### 参考（証跡：この時点の repo 状態）
- HEAD: 2b5ed9c
- status: ## wip/handoff-20260130-014312-stepg003-ssot
- stash(top): stash@{0}: On main: wip: pre-handoff auto stash
- runbook STEP-G003: 790:| STEP-G003 | 抽象ログ（索引）仕様合意（カテゴリ→パターン→具体ID、ID検索を正） | [x] | LOG-009 / LOGS/INDEX.md | Mod |
- runbook LOG-009: 1163:### LOG-009｜Gate G（STEP-G003）抽象ログ（索引）仕様合意
- LOGS/INDEX LOG-009: 47:- LOG-009 | Gate G（STEP-G003）抽象ログ（索引）仕様合意 | L694 | Ref: rg -n "LOG-009" _handoff_check/cf_task_tracker_v5.md

### 次にやること（1つだけ）
./tools/cf-guard.sh --check
意味（復習用）: Repo Lock の安全確認（想定リポジトリ以外なら中止）
---

## 引継ぎ追記（UPD-20260130-PR97-HANDOFF）

### 状態（直近）
- PR #97 merged: docs: runbook SSOT align cf-doctor/spec (STEP-G003)
- 時刻（JST）: 
- HEAD: 
- status: 
- stash:  件（0件が正）

### 今回の変更サマリ（Add/Del/Mod）
- Add:
  - WORKFLOW/SPEC/gates/gate-g.yaml
  - tools/cf-doctor.sh
- Mod:
  - _handoff_check/cf_update_runbook.md（SSOT最上位=runbook を明文化）
  - _handoff_check/cf_task_tracker_v5.md（tracker=進捗計測 を明確化）
  - _handoff_check/cf_handoff_prompt.md（引継ぎメモ更新）
- Del: なし

### 次にやりたいこと（新チャット）
- 目的: 外部仕様（例: 03_仕様書.md など）や SPEC/doctor 側に「tracker を SSOT 扱い」する記述が残っていないか確認し、**runbook SSOT** に統一する（Gate I / I1）。
- 最初の1手: `./tools/cf-guard.sh --check`

#### 調査コマンド候補（見つからなくてもOK → 末尾 `|| true`）
- `rg -n "tracker.*SSOT|SSOT.*tracker|cf_task_tracker_v5|03_仕様書|WORKFLOW/SPEC|cf-doctor" -S . || true`
- `rg -n "SSOT" WORKFLOW/SPEC tools _handoff_check || true`

<!-- CFCTX_HANDOFF_NOTE_20260130_GATEI_SPEC_DOCTOR_V1 -->
## 追記（2026-01-30）｜Gate I: SPEC（宣言的仕様）+ cf-doctor（検証ツール）方針整理（実装前準備を含む）

- 背景: 外部仕様 4ファイル（01_説明 / 02_要件定義 / 03_仕様書 / 04_実装計画）に基づき、cf-context-framework に「SPEC + cf-doctor」を段階導入する提案を比較（Codex vs Claude Code）。
  - Windows: `C:\Users\MASAHIRO\Desktop\作業ファイル\メモ\UPDATE\_Script`
  - WSL: `/mnt/c/Users/MASAHIRO/Desktop/作業ファイル/メモ/UPDATE/_Script`
- 判定（採用方針）:
  - 設計ガード（invariants/線引き/Phase0=決め打ちで安全に閉じる）は Claude Code 案を採用。
  - 実装（最小差分に落として repo へ反映）は Codex に担当させる（ただし上記ガードを必須条件として適用）。
- 事前検証（read-only / 失敗許容なしのための事実確認）:
  - `git status -sb`: `## main...origin/main`（clean）
  - `sh -n tools/cf-doctor.sh`: OK（出力なし）
  - tracker（`_handoff_check/cf_task_tracker_v5.md`）に `LOG-009` は存在しない（rg出力なし）
- 懸念（要確認）:
  - `tools/cf-log-index.sh` の入力ソースが tracker のみの場合、INDEX 再生成で `LOG-009` が落ち、doctor の Next action（index再生成）で PASS に戻らない可能性がある。
- 次フェーズ方針:
  - 実装に入る前に「事前準備段階を含めた Gate I タスク」を tracker に正式追加してから着手する（スクリプト絡みの重要セクションで失敗許容なし）。
- 新チャット開始の最初の1手（運用固定）:
  - `./tools/cf-guard.sh --check`
- Repo Lock: OK 後の read-only 確認（次の1手候補）:
  - `./tools/cf-guard.sh -- bash -lc 'rg -n "cf_task_tracker|tracker|cf_update_runbook|runbook|INPUT|SOURCE|DEFAULT|LOGS/INDEX" tools/cf-log-index.sh || true'`

---
## 追記（2026-01-30T22:57:02+09:00）｜handoff更新（cf-doctor Phase 0 / 運用フロー契約 / Gate I 整合）

- 反映内容（Add/Del/Mod）:
  - **Mod**: `_handoff_check/cf_handoff_prompt.md`（本追記）
  - **Ref**: `tools/cf-doctor.sh` / `WORKFLOW/SPEC/gates/gate-g.yaml`（cf-doctor Phase 0: STEP-G003）
  - **Ref**: `_handoff_check/cf_update_runbook.md`（運用フロー契約: SSOT→cf-doctor→GO/NO-GO→Skills）
  - **Ref**: `_handoff_check/cf_task_tracker_v5.md`（Gate I: I0/I1 の整合）

- 状態:
  - 次にやる1手: Gate I / I1（Gate I 入口定義: 目的/Done条件/最初の1手をSSOTに最小追記）
  - 新チャット開始時の最初の1手: `./tools/cf-guard.sh --check`

- Evidence:
  - HEAD: 5932561
  - 最近のコミット（参考）:
  - 5932561 docs: fix tracker consistency for Gate I (I0/I1)
  - cbd22ec docs: add ops flow contract (SSOT->doctor->GO/NO-GO->Skills)
  - 0773431 feat: add cf-doctor Phase 0 (STEP-G003)
  - 495b876 docs: tracker add Gate I tasks (I2-I5)
  - 7e7da51 docs: handoff note (Gate I SPEC + cf-doctor)
  - 6a8e99b Merge pull request #98 from xxxMasahiro/wip/gate-i-i1-ssot-bundle-clarify
  - bf28712 docs: clarify ssot bundle vs runbook SSOT (Gate I / I1)
  - 7594b85 docs: handoff memo (PR#97 / stash cleanup)
  - cf-doctor:
    - `./tools/cf-guard.sh -- ./tools/cf-doctor.sh step STEP-G003` => PASS（必要なら再実行）

---
## 追記（2026-01-31T07:46:48+0900）｜Gate I: I1 完了（tracker整合）→ 次は I2

### 根拠
- tracker 側で Gate I / I1 が Done[x] になり、「次にやる1手」が Gate I / I2 に更新済み。

### 判定
- 次チャットの入口（handoff）を tracker の最新進捗（I2）に揃える。

### 変更提案
- handoff 末尾に本追記を追加し、最新の「次にやる1手」を I2 として明示する。

### 変更内容（Add/Del/Mod）
- **Mod**: `_handoff_check/cf_handoff_prompt.md`（本追記）
- **Ref**: `_handoff_check/cf_task_tracker_v5.md`（I1 Done[x] / 次の1手 I2）

### 状態
- - 次にやる1手: Gate I / I2（Gate I 事前調査: 外部仕様4ファイルの要点とSSOT整合→LOG-009・LOGS/INDEX・cf-log-index入力ソースを read-only 確認）
- 新チャット開始の最初の1手（運用固定）:
  - `./tools/cf-guard.sh --check`

### Evidence
- HEAD: fc24b3b
- HEAD(1): fc24b3b Merge pull request #100 from xxxMasahiro/wip/gate-i-i1-tracker-close
- related (if in recent log):
  - fc24b3b Merge pull request #100 from xxxMasahiro/wip/gate-i-i1-tracker-close
  - df8a60f Merge pull request #99 from xxxMasahiro/wip/gate-i-i1-ssot-wording-fix

<!-- CFCTX_HANDOFF_AUTO:fc24b3b -->

## 追記（2026-01-31 13:47 JST）｜Gate I 完了 → 次は Gate J / J0（入口定義）

### 根拠
- Repo Lock: OK（mainはorigin/mainに追従）
- Gate I:
  - I2（外部仕様4ファイルの要点/SSOT整合をread-only確認）完了
  - I4/I5（運用統合: timing / failure / evidence / smoke）をrunbookへ追記し、最小スモークを実行
  - 最小スモーク（doctor）: [cf-doctor] step=STEP-G003
- status: PASS
- evidence:
  - _handoff_check/cf_update_runbook.md:818 | | STEP-G003 | 抽象ログ（索引）仕様合意（カテゴリ→パターン→具体ID、ID検索を正） | [x] | LOG-009 / LOGS/INDEX.md | Mod |
  - _handoff_check/cf_update_runbook.md:1191 | ### LOG-009｜Gate G（STEP-G003）抽象ログ（索引）仕様合意
  - LOGS/INDEX.md:47 | - LOG-009 | Gate G（STEP-G003）抽象ログ（索引）仕様合意 | L694 | Ref: rg -n "LOG-009" _handoff_check/cf_task_tracker_v5.md
- next: (none) => PASS
- trackerに Gate J のタスク行が無かったため、入口として Gate J / J0 を最小追加し「次にやる1手」を Gate J へ移行

### 判定
- 次チャットは Gate J / J0 を入口として進める。

### 変更提案
- Gate J / J0 で「目的 / Done条件 / 最初の1手」をSSOTに最小追記して固定し、以後のGate J作業へ接続する。

### 変更内容（Add/Del/Mod）
- **Mod**: （本追記）
- **Ref**: （I5 運用統合の規範）
- **Ref**: （次にやる1手: Gate J / J0）

### 状態
- 次にやる1手: Gate J / J0（Gate J 入口定義: 目的/Done条件/最初の1手をSSOTに最小追記）
- 新チャット開始の最初の1手（運用固定）:
  - Repo Lock: OK

### Evidence
- HEAD: 2de66e5
- recent merges (if any):
  - 008ff86 Merge pull request #101 from xxxMasahiro/wip/handoff-20260131-pr100-note
  - fc24b3b Merge pull request #100 from xxxMasahiro/wip/gate-i-i1-tracker-close
  - df8a60f Merge pull request #99 from xxxMasahiro/wip/gate-i-i1-ssot-wording-fix
  - 6a8e99b Merge pull request #98 from xxxMasahiro/wip/gate-i-i1-ssot-bundle-clarify
  - fbd86b7 Merge pull request #97 from xxxMasahiro/wip/gate-g-stepg003-cf-doctor-ssot
  - 8c87c9e Merge pull request #96 from xxxMasahiro/wip/handoff-20260130-014312-stepg003-ssot
  - 2b5ed9c Merge pull request #95 from xxxMasahiro/wip/handoff-20260129-gate-i-pr93-94-note
  - b7ae771 Merge pull request #94 from xxxMasahiro/wip/gate-i-i1-entry-definition-text
  - 87410aa Merge pull request #93 from xxxMasahiro/wip/gate-i-i2-entry-definition
  - 9187cca Merge pull request #92 from xxxMasahiro/wip/gate-i-pr89-90-checks-note
  - 39339b3 Merge pull request #91 from xxxMasahiro/wip/gate-i-i2-entry-definition
  - 9f139cd Merge pull request #90 from xxxMasahiro/wip/gate-i-slim-ssot

<!-- CFCTX_HANDOFF_AUTO:2de66e5 -->
