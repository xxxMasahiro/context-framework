# Gate A〜I 検証・テスト用キット 要件定義（暫定）

## 0. 目的
本ドキュメントは、Gate A〜I の検証・テストを **安全**かつ **再現性高く**行うための「Temporary Verification Kit（検証キット）」の要件（MUST/SHOULD）と合格条件を定義する。

- 本体repoのSSOT（_handoff_check/ 3ファイル）を汚さず、検証結果（Evidence）をキット側に蓄積する。
- 検証作業は原則 read-only とし、必要な PASS/FAIL 判定と変更提案へ繋げる。

---

## 1. スコープ
### 1.1 対象
- Gate A〜I の検証・テスト（最小スモーク〜フル検証）
- 検証結果（Evidence）・進捗（verify_task_tracker）・引継ぎ（handoff/latest.md）

### 1.2 非対象（Non-goals）
- 本体repoのファイル修正、コミット、PR作成
- 本体repoの SSOT 3ファイルの内容変更（検証キットでは “参照コピー” として固定）

---

## 2. 用語
- **本体repo**: context-framework のGitリポジトリ（read-only 対象）
- **検証キット**: $GATE_AUDIT_ROOT/.gate-audit（既定・推奨）
- **SSOT snapshot**: 本体repoの `_handoff_check/` 3ファイルを “そのままコピー” したもの
- **Evidence**: 実行コマンド結果・確認結果を保存したログ（logs/evidence/）
- **verify_task_tracker**: 検証用ミニトラッカー（tasks/verify_task_tracker.md）
- **->handoff**: チャット上の運用トリガ語（実体は scripts/generate_handoff.sh の実行）

---

## 3. 安全性要件（MUST）
### 3.1 生成場所の安全（MUST）
- 既定の検証キットルートは **`$GATE_AUDIT_ROOT/.gate-audit/`** とする（リポジトリ外生成を推奨）。
- `GATE_AUDIT_ROOT` 未設定時に既定動作を試みた場合、スクリプトは **中断（FAIL）**する。

### 3.2 本体repo不変更（MUST）
- 検証は原則 read-only とし、本体repoに対して以下を禁止する：
  - ファイル編集、`git commit/push/reset/clean/checkout` 等の変更操作
- 本体repoへのアクセスは `status/diff/log/rev-parse` 等の参照系に限定する。

### 3.3 Repo Lock（MUST）
- 検証開始時に `./tools/cf-guard.sh --check` を実行し、`Repo Lock: OK` を Evidence 化する。

### 3.4 検索の0終了（MUST）
- `rg/grep` 等の検索は「見つからなくてもOK」のため **必ず `|| true` を付与**して 0 終了にする。

---

## 4. 再現性・追跡性要件（MUST）
### 4.1 証跡保存（MUST）
- すべての検証コマンド結果は `logs/evidence/` に保存する。
- 保存は原則 `|& tee <evidence_path>` を用い、画面出力と同一内容をファイル化する。
- Evidence ファイル名には **UTCのタイムスタンプ**を含め、衝突を避ける。

### 4.2 トラッキング（MUST）
- `tasks/verify_task_tracker.md` に Gate A〜I のチェック項目を列挙し、各項目に：
  - `[ ]/[x]`
  - Evidence パス
  - 判定（PASS/FAIL）
  を記録する。
- `verify_task_tracker.md` は **追記式**を基本とし、過去証跡は消さない（必要なら “最新Evidence” を追記で更新する）。

### 4.3 引継ぎ（MUST）
- `handoff/latest.md` は、検証キットの参照情報（SSOT snapshot / run rules / tracker / evidence）をまとめる。
- 新チャットへの引継ぎソースは原則 `handoff/latest.md` の全文とする（本体repoの添付は不要）。

---

## 5. 運用要件（MUST/SHOULD）
### 5.1 進め方（MUST）
- 指示は「次にやること1つだけ」（1コマンド/1操作）。
- 出力フォーマットは必ず「根拠 / 判定 / 変更提案」。
- コマンド提示時は必ず「意味（復習用）」を併記する。

### 5.2 Codex high（Verifier）委任（SHOULD）
- フル検証（Gate A〜I）は Codex high に委任し、手順提示→実行結果貼付のループで進める。
- Codex high には「本体repo read-only」「Evidence はキット配下のみ」「rg/grep は || true」を絶対条件として渡す。

---

## 6. 機能要件（MUST）
### 6.1 最小スモーク（MUST）
- Phase 2（最小スモーク）として最低限以下を PASS/FAIL 判定できること：
  - Repo Lock を Evidence 化（cf-guard）
  - doctor step（例：STEP-G003）を Evidence 化
  - Gate C（アダプタ参照整合）read-only 確認
  - Gate G（ログ導線：索引/ログ/ルールの存在）read-only 確認

### 6.2 フル検証（MUST）
- Phase 3（フル）として Gate A〜I の要件①②③を Evidence 付きで説明できること：
  - **要件①**：各Gateの追加/変更点を、SSOT・差分・ログに基づき要約できる
  - **要件②**：体系整合（参照切れ/矛盾/衝突）がない、または問題を特定できる
  - **要件③**：最小実行で PASS/FAIL が取れる（doctor/guard/整合チェック等）

---

## 7. 合格条件（Acceptance Criteria）
- 検証キットが `$GATE_AUDIT_ROOT/.gate-audit/` に存在し、次が揃っている：
  - SSOT/  に3ファイル（参照コピー）
  - `context/run_rules.md` と `context/codex_high_prompt.md`
  - `tasks/verify_task_tracker.md`
  - `logs/evidence/` に Evidence が蓄積されている
  - `handoff/latest.md` が生成できる
- Phase 2 のスモークが PASS/FAIL 判定可能で、Evidence とトラッカー更新ができる
- Phase 3 の Gate A〜I が、Evidence を伴って進捗管理できる

---

## 8. 変更履歴
- v0.1（2026-02-01 JST）：要件定義ドラフト（verify_spec / verify_implementation_plan と整合） 
