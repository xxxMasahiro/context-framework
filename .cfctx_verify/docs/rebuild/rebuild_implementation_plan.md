# 検証キット再構築 実装計画

## 0. 目的

rebuild_requirements.md（REQ-R01〜R07）と rebuild_spec.md に従い、検証キットを再構築する。
変更は最小単位で段階的に行い、各ステップに受け入れ条件を設ける。

---

## 1. 変更ファイル一覧

### 1.1 新規作成

| # | ファイルパス | 説明 |
|---|---|---|
| N1 | `kit` | 統合コマンド（エントリポイント） |
| N2 | `scripts/lib/handoff_builder.sh` | latest.md 生成ロジック（関数群） |
| N3 | `scripts/lib/tracker_updater.sh` | トラッカー自動更新ロジック（関数群） |
| N4 | `docs/rebuild/rebuild_requirements.md` | 再構築要件定義（本ファイル群） |
| N5 | `docs/rebuild/rebuild_spec.md` | 再構築仕様 |
| N6 | `docs/rebuild/rebuild_implementation_plan.md` | 再構築実装計画（本ファイル） |
| N7 | `tasks/rebuild_task_tracker.md` | 再構築タスク管理表 |

### 1.2 修正

| # | ファイルパス | 変更内容 |
|---|---|---|
| M1 | `scripts/generate_handoff.sh` | 全面改修: 新フォーマットの latest.md 生成（handoff_builder.sh を source） |
| M2 | `scripts/verify_all.sh` | `./kit verify` から呼び出せるようI/F調整（exit code の統一） |
| M3 | `scripts/verify_gate.sh` | `./kit verify <GATE>` から呼び出せるようI/F調整 |

### 1.3 変更なし（尊重）

| ファイルパス | 理由 |
|---|---|
| `verify/verify_requirements.md` | 運用の正 |
| `verify/verify_spec.md` | 運用の正 |
| `verify/verify_implementation_plan.md` | 運用の正 |
| `scripts/lib/gate_*.sh` | 既存の検証ロジック（破壊的変更なし） |
| `scripts/lib/evidence.sh` | 既存のEvidence保存ロジック |
| `scripts/lib/ssot_check.sh` | 既存のSSOT比較ロジック |
| `tasks/verify_task_tracker.md` | 既存の検証記録（追記のみ） |
| `tasks/test_task_tracker.md` | 既存のテスト記録（追記のみ） |
| `tasks/as_built_task_tracker.md` | 既存のas-built記録（追記のみ） |

---

## 2. 実装ステップ

### Step 1: handoff_builder.sh 作成

**対象**: `scripts/lib/handoff_builder.sh`（新規）

**内容**:
- latest.md の各セクションを生成する関数群を実装:
  - `emit_meta()` — Meta セクション
  - `emit_main_repo_snapshot()` — Main Repo Snapshot（HEAD/branch/status/lock/SSOT fingerprint）
  - `emit_trackers_digest()` — 3トラッカーの進捗集計
  - `emit_evidence_index()` — Evidence 全件の一覧（目的/コマンド/判定/sha256/パス）
  - `emit_kit_files()` — Kit Files 固定リスト
  - `emit_commands()` — Commands 固定テキスト
  - `emit_notes()` — Notes
- 本体repoパスは `MAIN_REPO` 環境変数 or 既知パス（`~/projects/context-framework`）

**受け入れ条件**:
- `source scripts/lib/handoff_builder.sh && emit_meta` が正常出力される
- 各 emit 関数が単独で呼び出し可能

### Step 2: generate_handoff.sh 改修

**対象**: `scripts/generate_handoff.sh`（修正）

**内容**:
- `handoff_builder.sh` を source し、全 emit 関数を順に呼び出して latest.md を生成
- 旧コードを置き換え（旧コードはバックアップ `*.bak.<timestamp>` に保存）
- latest.txt も同時に生成

**受け入れ条件**:
- `bash scripts/generate_handoff.sh` で新フォーマットの latest.md が生成される
- latest.md に Main Repo Snapshot / Trackers Digest / Evidence Index が含まれる
- latest.md 単体で本体repoの状態が把握できる

### Step 3: tracker_updater.sh 作成

**対象**: `scripts/lib/tracker_updater.sh`（新規）

**内容**:
- トラッカー自動更新の関数群:
  - `update_verify_tracker <gate> <verdict> <evidence_path>` — verify_task_tracker.md の該当Gateを更新
  - `update_test_tracker <phase> <verdict> <evidence_path>` — test_task_tracker.md の該当Phaseを更新
  - `append_progress_log <tracker_file> <message>` — Progress Log に追記
- 更新時は sed を使い、既存の `[ ]` を `[x]` に変更

**受け入れ条件**:
- テスト用の仮トラッカーに対して関数を実行し、正しく更新されることを確認

### Step 4: kit コマンド作成

**対象**: `kit`（新規、ルート直下）

**内容**:
- `#!/usr/bin/env bash` + `set -euo pipefail`
- サブコマンド分岐: handoff / verify / test / all / status
- 各サブコマンドから既存スクリプト（verify_all.sh / verify_gate.sh / generate_handoff.sh）を呼び出す
- handoff サブコマンド後は必ず latest.md を再生成
- 終了コード: 0（全成功）/ 1（1件以上失敗）

**受け入れ条件**:
- `./kit handoff` で latest.md が新フォーマットで生成される
- `./kit status` で3トラッカーの進捗が表示される
- `./kit verify C` で Gate C の検証 → Evidence → トラッカー更新 → latest.md再生成が完了する

### Step 5: verify_all.sh / verify_gate.sh I/F調整

**対象**: `scripts/verify_all.sh`, `scripts/verify_gate.sh`（修正）

**内容**:
- `./kit` から呼び出された場合と単独実行の場合の両方で動作するよう調整
- 終了コードの統一（0: 全PASS / 1: FAIL あり）
- Evidence 保存後にパスを stdout に出力（`./kit` が拾えるように）

**受け入れ条件**:
- `bash scripts/verify_all.sh` が従来通り動作する（後方互換）
- `./kit verify` 経由でも正常に動作する

### Step 6: 統合テスト

**対象**: 全体

**内容**:
1. `./kit all` を実行し、一気通貫フローが完了することを確認
2. 生成された latest.md を目視で確認:
   - Main Repo Snapshot が正しい
   - Trackers Digest の数値が正しい
   - Evidence Index に全件が記載されている
3. verify/ 配下の3ドキュメントが変更されていないことを sha256 で確認
4. 本体repoが clean であることを確認

**受け入れ条件**:
- AC-01〜AC-07 が全て PASS

---

## 3. 実装順序と依存関係

```
Step 1 (handoff_builder.sh)
    ↓
Step 2 (generate_handoff.sh 改修)
    ↓
Step 3 (tracker_updater.sh) ← Step 1 と並行可能
    ↓
Step 4 (kit コマンド) ← Step 2, 3 に依存
    ↓
Step 5 (verify_all/gate I/F調整) ← Step 4 と並行可能
    ↓
Step 6 (統合テスト) ← Step 4, 5 に依存
```

---

## 4. リスクと対策

| リスク | 影響 | 対策 |
|---|---|---|
| generate_handoff.sh 改修で旧フォーマットが壊れる | 既存の handoff が使えなくなる | 改修前に .bak を作成。旧スクリプトは git 上にスナップショット済み |
| Evidence Index 生成が旧形式ファイルに対応できない | Evidence が欠落する | ヘッダなしの旧形式にフォールバック（ファイル名から推定） |
| verify_all.sh のI/F変更が既存動作を壊す | 既存の検証フローが使えなくなる | 後方互換を維持（追加のみ、既存引数は変えない） |
| 本体repoへの誤書き込み | SSOT 汚染 | `./kit` 内で MAIN_REPO への cd を禁止。全操作は `git -C` 経由 |

---

## 5. 変更履歴

- v1.0（2026-02-03 JST）：再構築実装計画 初版
