# context-framework — Task Tracker

## 進捗サマリ

- 未完了タスク: あり（Gate J / J0）
- 次の作業: Gate J / J0（Gate J 入口定義: 目的/Done条件/最初の1手をSSOTに最小追記）

## タスク一覧（Gate 別）

### Gate A〜G: 完了

| Gate | 内容 | 状態 |
|------|------|------|
| Gate A | Charter/Mode/Workflow 定義 | 完了 |
| Gate B | Artifact テンプレート | 完了 |
| Gate C | Agent Adapters（3 ファイル） | 完了 |
| Gate D | Audit 実行 | 完了 |
| Gate E | 言語ポリシー | 完了 |
| Gate F | 役割割当 | 完了 |
| Gate G | ログ最適化 | 完了 |

### Gate H: 完了（アーカイブ）

- H3: ctx-run + ssot_manifest 最小
- H4: ルール設計（routes/policy/manifest）
- H5: Controller 骨格（分類/検証/束/ログ）
- H6: 危険操作ゲート（Go/NoGo + 検知）
- H7: 2 段階出力（分類→生成）
- H8: テスト（不一致/高 risk/JSON 破損）
- H9: Gate C 検証組込み
- H10: Docs MCP（読み取り専用）手順整備
- H11: 用途別ツール MCP（STDIO）設計
- H12: 運用成熟（CI/ログ整備）

### Gate I: 完了

- [x] I0: Gate H 完了チェックリスト退避 + SSOT スリム化
- [x] I1: Gate I 入口定義（SSOT 文言を runbook 最上位 / tracker は進捗に統一）
- [x] I2: 事前調査（外部仕様 4 ファイルの要点と SSOT 整合）
- [x] I3: SPEC Phase 0（gate-g.yaml に STEP-G003 定義）
- [x] I4: doctor Phase 0（tools/doctor.sh 最小実装）
- [x] I5: 運用統合（runbook/tracker に実行タイミング・失敗時運用・Evidence 追記）

### Gate J: 未着手

- [ ] J0: Gate J 入口定義（目的/Done 条件/最初の 1 手を SSOT に最小追記）

## Progress Log/Updates

| Date | ID | Summary | Evidence |
|------|----|---------|---------|
| 2026-02-17 | UPD-20260217-03 | Charter + handoff restructure + .gate-audit 削除完了 | PR#115, merge:82b6237 |
| 2026-02-17 | UPD-20260217-02 | Charter 作成 + handoff リストラクチャ開始 | branch: wip/handoff-restructure |
| 2026-02-17 | UPD-20260217-01 | インスタンス化全フェーズ完了 | branch: wip/cf-zero-phase1, as-built v0.7/v0.13/v1.4 |
| 2026-02-02 | UPD-20260202-01 | Gate D REQ3 STRICT PASS | evidence: gateD_redo_req3_functional_strict.txt |
| 2026-01-31 | UPD-20260131-04 | Gate J: J0 追加 | tracker 更新 |
| 2026-01-31 | UPD-20260131-03 | Gate I: I4/I5 Done | doctor PASS, 運用統合 runbook 追記済み |
| 2026-01-31 | UPD-20260131-02 | Gate I: I2 Done | 外部仕様 4 ファイル確認 |
| 2026-01-31 | UPD-20260131-01 | Gate I: I1 Done | PR#99, commit:6a7b31d |
| 2026-01-30 | UPD-20260130-01 | Gate I: I3/I4 Phase0 実装完了 | commit:0773431 |
| 2026-01-28 | UPD-20260128-03 | Gate I: I1 入口定義開始 | commit:7ba1242 |
| 2026-01-28 | UPD-20260128-02 | Gate I: I0 完了 | commit:54a6bae |
| 2026-01-28 | UPD-20260128-01 | Gate H: H12 完了 | commit:9626c12 |
| 2026-01-27 | UPD-20260127-11 | Gate H: H11 完了 | commit:40f33ad |
| 2026-01-27 | UPD-20260127-10 | Gate H: H10 完了 | commit:904b79a |
| 2026-01-27 | UPD-20260127-09 | Gate H: H9 完了 | commit:6b5cd88 |
| 2026-01-27 | UPD-20260127-08 | Gate H: H8 完了 | commit:4a4c86f |
| 2026-01-27 | UPD-20260127-07 | Gate H: H7 完了 | commit:b4b9295 |
| 2026-01-27 | UPD-20260127-06 | Gate H: H6 完了 | commit:8a1dba1 |
| 2026-01-27 | UPD-20260127-04 | Gate H: H5 完了 | commit:06261ac |
| 2026-01-27 | UPD-20260127-03 | Gate H: H4 完了 | commit:0fd03cf |
| 2026-01-27 | UPD-20260127-02 | Gate H: H3 完了 | commit:1f8fa30 |
| 2026-01-27 | UPD-20260127-01 | Gate H: Controller 新規タスク追加 | PR#74, commit:9c5624e |
| 2026-01-26 | UPD-20260126-03 | Gate H 新規入口統一（Gate G 完了扱い） | PR#70, merge:e9105da |
| 2026-01-25 | UPD-20260125-05 | Gate G: STEP-G007 完了 | PR#59, merge:795d53f |
| 2026-01-25 | UPD-20260125-04 | Gate G: STEP-G006 完了 | PR#57, merge:6305b49 |
| 2026-01-25 | UPD-20260125-03 | Gate G: STEP-G005 完了 | PR#54, merge:f14ec13 |
| 2026-01-25 | UPD-20260125-02 | Gate G: STEP-G201〜G204 完了 | commit:97535ef |
| 2026-01-25 | UPD-20260125-01 | Gate G: STEP-G104 受入テスト PASS | HEAD:637b0db |

### LOG-009 — LOGS/INDEX 自動生成（log-index.sh 連携）

- 実装: `tools/log-index.sh` が本ファイルの `Progress Log/Updates` セクションから UPD エントリを抽出し `LOGS/INDEX.md` を生成する。
- 手動編集禁止: `LOGS/INDEX.md` は `log-index.sh` で再生成すること。
