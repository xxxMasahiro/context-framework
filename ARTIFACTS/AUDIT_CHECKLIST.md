# AUDIT_CHECKLIST

## 0. メタ
- Audit Gate: **D (Audit)**
- 対象: `xxxMasahiro/cf-context-framework / main / bbca353`
- Mode: `standard`
- 日付: `2026-01-19`
- Auditor: `ChatGPT (GPT-5.2 Thinking)`

> Rule: AuditorはPRへ監査結果を返す。修正はCrafter/Orchestratorが行う。

---

## 1. チェックリスト形式 (Checklist Format)
各行の記入:
- Status: **Yes / No / NA**
- Evidence: file path / log path / diff / commit
- Notes: 短い根拠
- Action Item (if No): 最小修正案 + Re-audit condition

---

## 2. コア整合性

### 2.1 Single Source of Truth hierarchy
- [x] Status: Yes | **Charter → Mode → Artifacts → Skills** を遵守 | Evidence: `WORKFLOW/MODES_AND_TRIGGERS.md` / bbca353 | Notes: SSOT方針は維持
- [x] Status: Yes | 下位レイヤが上位ルールを上書きしない | Evidence: `WORKFLOW/AUDIT.md` / bbca353 | Notes: 監査テンプレ構造維持を確認

### 2.2 ロール境界
- [x] Status: Yes | Auditor は PASS/FAIL と指摘のみ（実装はしない） | Evidence: `PROMPTS/AUDITOR.md` / bbca353 | Notes: 監査責務の文言維持
- [x] Status: Yes | 修正の担当は Crafter/Orchestrator（明示） | Evidence: `ARTIFACTS/AUDIT_REPORT.md` / bbca353 | Notes: 原則文言を維持

---

## 3. Gate 統合 (A/B/C + D)

### 3.1 Gate 定義
- [x] Status: Yes | Gate A/B/C の定義が維持または整合更新されている | Evidence: `WORKFLOW/GATES.md` | Notes: 既存定義の維持
- [x] Status: Yes | Gate D (Audit) が定義済み（inputs/outputs/decision） | Evidence: `WORKFLOW/AUDIT.md` / bbca353 | Notes: 日本語化のみ

### 3.2 Gate フロー整合
- [x] Status: Yes | Task Lists が Gate A のスコープ判断を反映 | Evidence: `ARTIFACTS/TASK_LISTS.md` | Notes: 参照のみ
- [x] Status: Yes | Implementation Plan が Gate B のファイル単位計画を反映 | Evidence: `ARTIFACTS/IMPLEMENTATION_PLAN.md` | Notes: 参照のみ
- [x] Status: Yes | Walkthrough が Gate C の証跡（logs/diffs/checksums）を含む | Evidence: `ARTIFACTS/WALKTHROUGH.md` | Notes: 参照のみ
- [x] Status: Yes | Audit が Evidence を消化して report/checklist を作成 (Gate D) | Evidence: `ARTIFACTS/AUDIT_REPORT.md` / `ARTIFACTS/AUDIT_CHECKLIST.md` | Notes: 本記録

---

## 4. 必須 Artifacts の有無

### 4.1 Artifacts フォルダ
- [x] Status: Yes | `ARTIFACTS/AUDIT_REPORT.md` が存在する | Evidence: `ARTIFACTS/AUDIT_REPORT.md` | Notes: 本記録
- [x] Status: Yes | `ARTIFACTS/AUDIT_CHECKLIST.md` が存在する | Evidence: `ARTIFACTS/AUDIT_CHECKLIST.md` | Notes: 本記録
- [x] Status: Yes | `ARTIFACTS/EXCEPTIONS.md` が存在する（または NA を記録） | Evidence: `ARTIFACTS/EXCEPTIONS.md` | Notes: 例外なし

### 4.2 Prompts & workflow docs（採用時）
- [x] Status: Yes | `PROMPTS/AUDITOR.md` が存在する（または NA） | Evidence: `PROMPTS/AUDITOR.md` / bbca353 | Notes: 日本語化済み
- [x] Status: Yes | `WORKFLOW/AUDIT.md` が存在する（または NA） | Evidence: `WORKFLOW/AUDIT.md` / bbca353 | Notes: 日本語化済み

---

## 5. Evidence 品質

### 5.1 Evidence 完全性
- [x] Status: Yes | 変更が追跡可能（diff / file list / summary） | Evidence: `git show --name-status --stat bbca353` | Notes: doc-only差分
- [x] Status: NA | 主要チェックのログが存在（CI/QA or manual） | Evidence: `LOGS/` | Notes: doc-only変更のため不要
- [x] Status: NA | 配布バンドル時の checksums が存在（または NA） | Evidence: `meta/CHECKSUMS.sha256` | Notes: doc-only変更のため不要

### 5.2 Evidence 一貫性
- [x] Status: Yes | Artifacts の内容がリポジトリ状態と一致（参照の古さ無し） | Evidence: `git show bbca353 -- ARTIFACTS/AUDIT_REPORT.md` | Notes: 構造維持
- [x] Status: Yes | ドキュメントのリンク/パスが正しく解決 | Evidence: `git show bbca353 -- WORKFLOW/AUDIT.md` | Notes: 参照維持

---

## 6. Skills 統合（該当時）

- [x] Status: Yes | Skills は方針を再定義せず、手順を実装する | Evidence: `SKILLS/` | Notes: 監査範囲外だが方針維持
- [x] Status: Yes | Skills が Artifacts を evidence/outputs に参照する | Evidence: `SKILLS/` | Notes: 監査範囲外だが方針維持
- [x] Status: Yes | Mode の差分を尊重（lite/standard/strict） | Evidence: `WORKFLOW/MODES_AND_TRIGGERS.md` | Notes: 監査範囲外だが方針維持

---

## 7. Tool/Agent ファイル（CLAUDE / AGENTS / GEMINI）

- [x] Status: Yes | 各ファイルは adapter 的（フレームワークの複製ではない） | Evidence: `CLAUDE.md/AGENTS.md/GEMINI.md` | Notes: 監査範囲外だが方針維持
- [x] Status: Yes | 各ファイルが framework を単一の正として参照 | Evidence: `WORKFLOW/TOOLING/COEXIST_3FILES.md` | Notes: 監査範囲外だが方針維持

---

## 8. 要約

### 8.1 最終判断の準備
- PASS: 重要項目が **Yes** で Evidence が十分
- FAIL: 重要項目に **No** がある、または Evidence 不足

Critical items (minimum):
- 階層の遵守
- Gate D 定義と接続
- Evidence が存在し一貫している
- Auditor の独立性と修正担当が明確
