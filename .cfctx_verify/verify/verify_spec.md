# Gate A〜I 検証・テスト用キット 仕様（暫定）

## 0. 概要
本仕様は、Gate A〜I の検証・テストを安全かつ再現性高く行うための「一時キット（Temporary Verification Kit）」の構造・インターフェイス・動作を定義する。

---

## 1. ディレクトリ仕様
### 1.1 ルート
- **既定（推奨・安全側）**：`$CFCTX_VERIFY_ROOT/.cfctx_verify/`（`CFCTX_VERIFY_ROOT` は必須）
- **例外（明示的オプトイン時のみ）**：`./.cfctx_verify/`（リポジトリ直下・git管理外）
- `CFCTX_VERIFY_ROOT` が未設定のまま既定動作を試みた場合、スクリプトは **中断（FAIL）**する

### 1.2 構成（案）
```
.cfctx_verify/
  README.md
  .gitignore
  SSOT/
    cf_handoff_prompt.md
    cf_update_runbook.md
    cf_task_tracker_v5.md
  context/
    codex_high_prompt.md
    run_rules.md
  tasks/
    verify_task_tracker.md
  scripts/
    verify.sh
    collect_evidence.sh
    generate_handoff.sh
    lockdown.sh
    unlock.sh
  logs/
    runs/
      <YYYYMMDD-HHMMSS>/
        verify.log
        commands.txt
    evidence/
      <YYYYMMDD-HHMMSS>/
        repo_status.txt
        doctor_step_g003.txt
  handoff/
    latest.md
    latest.txt
```

---

## 2. ファイル仕様
### 2.1 SSOT/ （参照コピー）
- `_handoff_check/` の3ファイルを **そのままコピー**して格納する（改変しない）。
- 目的：検証時に “参照した SSOT の版” を固定する。

### 2.2 `tasks/verify_task_tracker.md`
- 検証専用のミニトラッカー。
- Gate A〜I のチェック項目を並べ、`[ ]/[x]` と Evidence を記録する。
- SSOT 本体の tracker を汚さず、検証の進捗を管理する。

### 2.3 `context/codex_high_prompt.md`
- Codex high に渡す「検証スコープ・ルール・出力形式」を 1 本にまとめたプロンプト。
- 重要：出力は常に「根拠 / 判定 / 変更提案」を含む。

### 2.4 `context/run_rules.md`
- オペレーションルール（1手ずつ、rg||true、コピーブロック等）を再掲し、検証キット内の全スクリプトにも反映する。

### 2.5 `scripts/verify.sh`
- Gate A〜I の最小検証を順序立てて実行する “read-only 検証” スクリプト。
- 特徴：
  - `set -euo pipefail`
  - すべてのコマンドをログに記録
  - 書き込み操作（git commit/push、ファイル改変）を行わない
  - 実行結果を `logs/runs/<timestamp>/` に保存

#### 2.5.1 verify.sh の入出力
- 入力：
  - `--mode`（`smoke` / `full`）※既定 `smoke`
  - `--step`（例：`STEP-G003`）※既定 `STEP-G003`
- 出力：
  - `logs/runs/<ts>/verify.log`
  - `logs/runs/<ts>/commands.txt`
  - `logs/evidence/<ts>/*`

### 2.6 `scripts/generate_handoff.sh`
- 直近の検証結果から `handoff/latest.md` を生成する。
- 出力フォーマット（例）：
  - 前提（Repo Lock、HEAD、SSOT 版）
  - 実行済みコマンド一覧
  - PASS/FAIL サマリ（Gate 別）
  - 次にやる 1 手（1 コマンド）
  - Evidence パス

### 2.7 `scripts/lockdown.sh` / `unlock.sh`
- 目的：検証完了後に検証キットを隔離し、通常運用からアクセスしにくくする。

#### 2.7.1 `lockdown.sh`（隔離＋ロック）
- 動作（案）：
  - `.cfctx_verify/` → `./.cfctx_quarantine/verify-<timestamp>/` に移動
  - `chmod -R go-rwx` を適用（owner のみアクセス可）
  - “ロック中” を示す `README_LOCKED.md` を作成
  - ロック状態の明示として `LOCKED.flag` を作成（解除時の判定に利用）

#### 2.7.2 `unlock.sh`（二段階解除）
- 安全性のため **二段階**で解除する。
  1. `LOCKED.flag` の存在確認（無ければ中断）
  2. 解除実行前に、ユーザーに **固定フレーズ入力**を要求（例：`UNLOCK-VERIFY-KIT`）
     - 一致しない場合は中断（FAIL）
- owner による明示解除のみ（ディレクトリを戻す、権限を戻す、`LOCKED.flag` を削除）

---

## 3. 「->handoff」チャットトリガ仕様
### 3.1 トリガ条件
- ユーザー入力が **完全一致**で `->handoff`（前後空白は許容）した場合。

### 3.2 出力
- **原則**：`scripts/generate_handoff.sh` により `handoff/latest.md` を生成し、内容をそのまま **コピーブロック**で返す（出力源を `handoff/latest.md` に統一）
- `handoff/latest.md` が無い場合：
  - まず「`generate_handoff.sh` を実行する 1 手」を提示する
  - 実行不能（未構築等）の場合に限り、テンプレ出力（未生成である旨＋次の1手）

---

## 4. 安全性仕様
- 検証スクリプトは read-only。
- git 操作は `status`, `diff`, `rev-parse`, `log` 等の参照系に限定。
- 必須の安全確認：
  - `./tools/cf-guard.sh --check` を最初に実行し、`Repo Lock: OK` を Evidence に記録する。
- 検索コマンドは `|| true` を強制（見つからなくても 0 終了）。

---

## 5. 互換性・依存
- bash が動作する環境（Ubuntu/WSL）を前提。
- 既存の `./tools/cf-guard.sh` / `./tools/cf-doctor.sh` を利用する。
- 追加依存は原則禁止（どうしても必要な場合は runbook に追記が必要）。

---

## 6. 変更履歴
- v0.1（2026-01-31 JST）：初版（仕様ドラフト）
