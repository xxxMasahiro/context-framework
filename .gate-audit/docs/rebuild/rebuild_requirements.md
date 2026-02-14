# 検証キット再構築 要件定義

## 0. 目的

現行の検証キット（Temporary Verification Kit）を再構築し、**`handoff/latest.md` 単体で検証キットの全状態を把握できる**ようにする。

現状の課題:
- `latest.md` はファイルパスの一覧に過ぎず、内容を知るには各ファイルを開く必要がある
- Evidence は直近10件のパスのみで、目的・判定・sha256 が不明
- トラッカーの進捗サマリがなく、完了/未完了の概要が分からない
- 本体repoの状態（HEAD/clean/lock等）が latest.md に埋め込まれていない
- 検証・テスト・handoff生成が個別スクリプトに分散し、一気通貫で回せない

---

## 1. スコープ

### 1.1 対象
- `handoff/latest.md` の構造刷新
- `scripts/generate_handoff.sh` の全面改修
- 統合コマンド `./kit` の新規作成
- トラッカー更新ルールの明確化

### 1.2 非対象（Non-goals）
- 本体repo（~/projects/context-framework）のファイル変更
- verify/ 配下の検証ドキュメント（verify_requirements.md / verify_spec.md / verify_implementation_plan.md）の内容変更（運用の正として尊重）
- Gate A〜I の検証ロジック自体の変更（scripts/lib/gate_*.sh）

---

## 2. 要件一覧

### REQ-R01: latest.md 自己完結性（MUST）

latest.md 単体で以下を把握できること（参照先を開かなくても意味が分かる）:

| セクション | 含む情報 | 根拠 |
|---|---|---|
| Main Repo Snapshot | path, HEAD (short+full), branch, clean/dirty, guard/lock状態, SSOT fingerprint (sha256先頭8桁) | 新チャットが即座にrepo状態を把握するため |
| Trackers Digest | 各トラッカーの完了数/総数、未完了項目リスト、最終更新日時 | 進捗を一目で確認するため |
| Evidence Index | 全Evidence（最新N件ではなく全件）の: 目的, コマンド概要, 判定(PASS/FAIL), sha256, 参照パス | 証跡の正当性を latest.md 内で検証可能にするため |
| Commands | `./kit` の使い方（引数・機能） | 新チャットが即座に操作開始できるため |

### REQ-R02: 統合コマンド `./kit`（MUST）

以下のサブコマンドを提供する:

| サブコマンド | 機能 |
|---|---|
| `./kit handoff` | latest.md を再生成する |
| `./kit verify [GATE]` | 指定Gate（省略時は全Gate）の検証を実行し、Evidence保存→トラッカー更新→latest.md再生成 |
| `./kit test [PHASE]` | テスト実行（Phase1/2/3/all） |
| `./kit all` | verify + test + handoff を一気通貫で実行 |
| `./kit status` | 各トラッカーの進捗サマリを標準出力に表示 |

一気通貫フロー:
```
実行 → Evidence保存 → トラッカー更新 → latest.md再生成
```

### REQ-R03: verify/ との整合（MUST）

- `verify/verify_requirements.md`, `verify/verify_spec.md`, `verify/verify_implementation_plan.md` は**運用の正**として尊重する
- 再構築はこれらのドキュメントが定義する検証フローに沿って動作する
- 既存の `scripts/lib/gate_*.sh` を流用する（破壊的変更はしない）

### REQ-R04: Evidence 管理強化（MUST）

- Evidence ファイル命名: `YYYYMMDD-HHMMSS_<purpose>.txt` （既存踏襲）
- 各Evidence に sha256 を計算し、latest.md の Evidence Index に記録する
- FAIL 判定でも Evidence を残す（FAIL Evidence は判定列に `FAIL` と明記）
- Evidence は追記式（過去のものを削除しない）

### REQ-R05: トラッカー更新ルール（MUST）

- `[ ]` → `[x]` 変更時に以下を必須とする:
  - 判定: PASS または FAIL
  - Evidence: logs/evidence/ 内のパス
  - 日時: JST タイムスタンプ
- Progress Log セクションに更新履歴を追記する
- トラッカーの `[x]` を `[ ]` に戻すことは禁止（再検証は新規項目を追加する）

### REQ-R06: 変更範囲の限定（MUST）

- すべての変更は検証キット内（`$GATE_AUDIT_ROOT/.gate-audit/`）に限定する
- 本体repoへの書き込みは一切行わない
- 本体repoへのアクセスは参照系（git status/diff/log/rev-parse/show 等）のみ

### REQ-R07: エラーハンドリング（MUST）

- `GATE_AUDIT_ROOT` 未設定時: 即座に FAIL（exit 1）
- 本体repo が見つからない場合: FAIL + エラーメッセージ
- 検索コマンド（rg/grep）は必ず `|| true` 付与
- `./kit` の各サブコマンドは終了コード 0（成功）/ 1（失敗）を返す

---

## 3. 合格条件（Acceptance Criteria）

| # | 条件 | 検証方法 |
|---|---|---|
| AC-01 | `handoff/latest.md` だけ読めば、本体repoの状態（HEAD/branch/clean/lock）が分かる | latest.md の Main Repo Snapshot セクションを目視確認 |
| AC-02 | `handoff/latest.md` だけ読めば、全トラッカーの進捗（完了/未完了/総数）が分かる | latest.md の Trackers Digest セクションを目視確認 |
| AC-03 | `handoff/latest.md` だけ読めば、全Evidence の目的・判定・sha256が分かる | latest.md の Evidence Index セクションを目視確認 |
| AC-04 | `./kit all` で検証→Evidence保存→トラッカー更新→latest.md再生成が一気通貫で完了する | `./kit all` を実行し、各成果物を確認 |
| AC-05 | `./kit verify C` で Gate C 単独の検証→Evidence→トラッカー更新→latest.md再生成が完了する | `./kit verify C` を実行し確認 |
| AC-06 | verify/ 配下の3ドキュメントが変更されていない | sha256 比較 |
| AC-07 | 本体repoに変更が入っていない（clean） | `git -C <main_repo> status --porcelain` が空 |

---

## 4. 変更履歴

- v1.0（2026-02-03 JST）：再構築要件定義 初版
