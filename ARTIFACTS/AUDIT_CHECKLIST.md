# AUDIT_CHECKLIST

## 0. メタ
- Audit Gate: **D (Audit)**
- 対象: `<repo / branch / commit / version>`
- Mode: `<lite | standard | strict>`
- 日付: `<YYYY-MM-DD>`
- Auditor: `<agent/model name>`

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
- [ ] Status: ___ | **Charter → Mode → Artifacts → Skills** を遵守 | Evidence: ___ | Notes: ___
- [ ] Status: ___ | 下位レイヤが上位ルールを上書きしない | Evidence: ___ | Notes: ___

### 2.2 ロール境界
- [ ] Status: ___ | Auditor は PASS/FAIL と指摘のみ（実装はしない） | Evidence: ___ | Notes: ___
- [ ] Status: ___ | 修正の担当は Crafter/Orchestrator（明示） | Evidence: ___ | Notes: ___

---

## 3. Gate 統合 (A/B/C + D)

### 3.1 Gate 定義
- [ ] Status: ___ | Gate A/B/C の定義が維持または整合更新されている | Evidence: `WORKFLOW/GATES.md` | Notes: ___
- [ ] Status: ___ | Gate D (Audit) が定義済み（inputs/outputs/decision） | Evidence: `WORKFLOW/GATES.md` | Notes: ___

### 3.2 Gate フロー整合
- [ ] Status: ___ | Task Lists が Gate A のスコープ判断を反映 | Evidence: `ARTIFACTS/TASK_LISTS.md` | Notes: ___
- [ ] Status: ___ | Implementation Plan が Gate B のファイル単位計画を反映 | Evidence: `ARTIFACTS/IMPLEMENTATION_PLAN.md` | Notes: ___
- [ ] Status: ___ | Walkthrough が Gate C の証跡（logs/diffs/checksums）を含む | Evidence: `ARTIFACTS/WALKTHROUGH.md` | Notes: ___
- [ ] Status: ___ | Audit が Evidence を消化して report/checklist を作成 (Gate D) | Evidence: `ARTIFACTS/AUDIT_REPORT.md` + this file | Notes: ___

---

## 4. 必須 Artifacts の有無

### 4.1 Artifacts フォルダ
- [ ] Status: ___ | `ARTIFACTS/AUDIT_REPORT.md` が存在する | Evidence: ___ | Notes: ___
- [ ] Status: ___ | `ARTIFACTS/AUDIT_CHECKLIST.md` が存在する | Evidence: ___ | Notes: ___
- [ ] Status: ___ | `ARTIFACTS/EXCEPTIONS.md` が存在する（または NA を記録） | Evidence: ___ | Notes: ___

### 4.2 Prompts & workflow docs（採用時）
- [ ] Status: ___ | `PROMPTS/AUDITOR.md` が存在する（または NA） | Evidence: ___ | Notes: ___
- [ ] Status: ___ | `WORKFLOW/AUDIT.md` が存在する（または NA） | Evidence: ___ | Notes: ___

---

## 5. Evidence 品質

### 5.1 Evidence 完全性
- [ ] Status: ___ | 変更が追跡可能（diff / file list / summary） | Evidence: ___ | Notes: ___
- [ ] Status: ___ | 主要チェックのログが存在（CI/QA or manual） | Evidence: `LOGS/` | Notes: ___
- [ ] Status: ___ | 配布バンドル時の checksums が存在（または NA） | Evidence: `meta/CHECKSUMS.sha256` | Notes: ___

### 5.2 Evidence 一貫性
- [ ] Status: ___ | Artifacts の内容がリポジトリ状態と一致（参照の古さ無し） | Evidence: ___ | Notes: ___
- [ ] Status: ___ | ドキュメントのリンク/パスが正しく解決 | Evidence: ___ | Notes: ___

---

## 6. Skills 統合（該当時）

- [ ] Status: ___ | Skills は方針を再定義せず、手順を実装する | Evidence: `SKILLS/` | Notes: ___
- [ ] Status: ___ | Skills が Artifacts を evidence/outputs に参照する | Evidence: `SKILLS/` | Notes: ___
- [ ] Status: ___ | Mode の差分を尊重（lite/standard/strict） | Evidence: `WORKFLOW/MODES_AND_TRIGGERS.md` | Notes: ___

---

## 7. Tool/Agent ファイル（CLAUDE / AGENTS / GEMINI）

- [ ] Status: ___ | 各ファイルは adapter 的（フレームワークの複製ではない） | Evidence: `CLAUDE.md/AGENTS.md/GEMINI.md` | Notes: ___
- [ ] Status: ___ | 各ファイルが framework を単一の正として参照 | Evidence: ___ | Notes: ___

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
