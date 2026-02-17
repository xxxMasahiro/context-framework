# CHARTER — context-framework 最高憲章

本文書は context-framework の存在理由・不変原則・統治構造を定める最上位文書である。
すべての下位文書（Mode, Architect, Skills, Adapters）は本 Charter に従属する。

---

## §1 Purpose（フレームワークの存在理由）

- context-framework は、複数の AI エージェント（Claude Code / Codex / Antigravity 等）が**安全・再現可能・監査可能**にソフトウェア開発を行うためのガバナンス基盤である
- 開発者（Developer）が AI エージェントに役割を割り当て、Mode を設定し、エージェントはその制約のもとで `app/` に成果物を生成する
- フレームワーク自体はツール非依存であり、特定の AI エージェントに依存しない

---

## §2 Developer Sovereignty（開発者主権）

開発者はフレームワーク運用における最高権限者であり、以下を排他的に制御する:

| 制御対象 | 内容 |
|---------|------|
| **エージェント選択** | タスクに使用する AI エージェント（Claude Code, Codex, Antigravity 等）を選択する |
| **役割割当** | エージェントに役割（Architect, Crafter, Orchestrator, Auditor）を付与する。役割はエージェント固有ではなく、タスクごとに開発者が決定する |
| **Mode 設定** | Lite / Standard / Strict を選択し、テスト・監査の要否を決定する |
| **Gate 承認** | Gate A〜D の通過を承認する。エージェントは Gate 承認を自律的に行わない |
| **成果物受入** | `app/` に生成された成果物の最終的な受入判断を行う |

- エージェントは開発者の設定した制約を超える行動を取ってはならない
- 開発者不在時はフェイルセーフ（Lite モード、保守的判断）をデフォルトとする

---

## §3 Execution Model（実行モデル）

### 3.1 エージェント実行フロー

```
Developer
  │  エージェント選択 + 役割割当 + Mode 設定
  ↓
Agent（Charter → Mode の制約を受けて起動）
  │  SSOT 参照チェーンに従い上位方針を読み込む
  ↓
ARTIFACTS（作業計画・証跡・検証の記録層）
  │  エージェント間の共有コンテキスト
  │  Gate ごとに成果物を更新・蓄積
  ↓
Skills（再利用可能な手順）
  │  品質向上のための標準化された手順を適用
  ↓
app/（成果物の生成先）
    フレームワーク管轄外（L3）
    Mode/Gate は適用されない
```

### 3.2 ARTIFACTS の役割

ARTIFACTS は 2 つの機能を持つ:

1. **エージェント間の調整層**
   - 複数エージェントが同一タスクに関与する場合、ARTIFACTS が共有コンテキストとなる
   - `TASK_LISTS.md`（スコープ）→ `IMPLEMENTATION_PLAN.md`（計画）→ `WALKTHROUGH.md`（検証）→ `AUDIT_REPORT.md`（監査）の順に蓄積される
   - あるエージェント（Crafter）が残した証跡を、別のエージェント（Auditor）が検証する

2. **品質向上の経路**
   - ARTIFACTS に記録された計画・証跡を通じて Skills が適用される
   - Skills は ARTIFACTS の記録を入力とし、標準化された手順で品質を担保する
   - 成果物は Skills → ARTIFACTS への書き戻しにより追跡可能な状態を維持する

### 3.3 app/ の位置づけ

- `app/` はエージェントが生成する成果物の格納先である
- フレームワークのガバナンス（Mode, Gate, SSOT）は `app/` 内には適用されない（L3 自由）
- ただし、`app/` の成果物生成に至る**プロセス**（L1/L2 の変更を伴う場合）には Mode が適用される

---

## §4 Immutable Principles（不変原則 — Mode/Architect/Skills が決して上書きできない）

1. **SSOT 階層の不可侵性**: Charter → Mode → Artifacts → Skills。下位層は上位層を上書きできない
2. **証跡なき変更の禁止**: すべての意思決定はトレーサブルな証跡（commit, diff, log, checksum）を伴わなければならない
3. **実装と監査の分離**: Auditor は実装しない。Crafter/Orchestrator は自身の成果物を監査しない
4. **main ブランチの保護**: main への直接コミットは禁止。すべての変更は PR + Gate を通過する
5. **Gate の順序性**: A（スコープ合意）→ B（実装計画）→ C（ウォークスルー）→ D（監査）は省略不可
6. **フェイルセーフデフォルト**: 不明な場合はリスク高（conservative）、モードは Lite（最小コスト）をデフォルトとする
7. **ツール非依存性**: Skills はツール固有の手順を含まない。ツール固有部分は Adapter に分離する
8. **レイヤー分離の厳守**: L1（ガバナンス）はインスタンスで編集禁止、L2（プロジェクト）は自由編集、L3（app/）はフレームワーク管轄外

---

## §5 Governance Chain（統治構造）

```
Charter（本文書）
  │  フレームワークの目的・不変原則・改訂規則を定める
  │  全ての下位文書はこれに従属する
  ↓
Mode（WORKFLOW/MODES_AND_TRIGGERS.md）
  │  実行厳密度（Lite / Standard / Strict）を定める
  │  Triggers によるエスカレーション規則を定める
  ↓
Architect（WORKFLOW/GATES.md, AUDIT.md, BRANCHING.md 等）
  │  Gate A〜D のプロセス、監査手順、ブランチ戦略を定める
  │  Translation Layer で抽象→具象を橋渡しする
  ↓
Skills（SKILLS/*.md）
  │  再利用可能な手順を定義する
  │  Concrete → Abstract → Skills の昇格パスに従う
  │  上位方針を再定義しない
  ↓
Adapters（CLAUDE.md / AGENTS.md / GEMINI.md）
    ツール固有の入口。SSOT ではない。参照のみ。
```

---

## §6 Mode（実行厳密度の制御）

| Mode | 適用条件 | テスト（Gate C） | 監査（Gate D） | 証跡レベル |
|------|---------|:---------------:|:-------------:|-----------|
| **Lite** | 小規模変更、影響限定、Triggers なし | — | — | 要点のみ |
| **Standard** | 複数ファイル変更、依存関係変更、Triggers あり | **必須** | — | 再現可能な検証手順 |
| **Strict** | セキュリティ・認証変更、破壊的変更、外部 API 影響 | **必須** | **必須** | 完全な監査証跡 |

- デフォルトは **Lite**（テストなし・監査なし）
- Triggers 検出時は **Standard 以上**（テスト必須）にエスカレーション
- 重大性が高い場合は **Strict**（テスト＋監査必須）にエスカレーション
- `app/` のみの変更には Mode/Triggers/Gate 適用外（L3 自由）

---

## §7 Architect（構造的統制）

- **Gate A**: スコープと Done 定義の合意 → `ARTIFACTS/TASK_LISTS.md`
- **Gate B**: ファイル単位の実装計画の確定 → `ARTIFACTS/IMPLEMENTATION_PLAN.md`
- **Gate C**: ウォークスルー + 証跡収集 → `ARTIFACTS/WALKTHROUGH.md` + `LOGS/`
- **Gate D**: 独立監査 → `ARTIFACTS/AUDIT_REPORT.md` + `AUDIT_CHECKLIST.md`
- ブランチ: `wip/<version>` パターン。main への fast-forward マージのみ
- コミット: `gate(A):`, `gate(B):`, `gate(C):`, `gate(D):` マーカー必須

---

## §8 Skills（再利用可能な手順）

- 構造: Purpose → Prerequisites → Inputs → Outputs → Steps → Validation → Rollback
- 昇格パス: Concrete（1 回目）→ Abstract（2 回目）→ Skills（3 回目 + 再現性 + 受入テスト合格）
- 呼び出し: `SKILL: <名前>` + Mode/Target/Inputs/Expected/Evidence の固定フォーマット
- 成果物書き戻し: TASK_LISTS → WALKTHROUGH → IMPLEMENTATION_PLAN → AUDIT → EXCEPTIONS の優先順

---

## §9 Role Boundaries（役割境界）

| 役割 | 責務 | 禁止事項 |
|------|------|---------|
| **Architect** | 設計・整合性チェック・エスカレーション | 実装 |
| **Crafter** | 実装・Artifacts 更新・証跡作成 | 自身の成果物の監査 |
| **Orchestrator** | タスク分解・横断調整・進行管理 | 監査判定 |
| **CI/QA** | ウォークスルー実行・ログ収集 | コンプライアンス判定 |
| **Auditor** | 証跡検証・リスク評価・PASS/FAIL 判定 | 実装・修正 |

---

## §10 Safety（安全機構）

- **Repo Lock**: `.repo-id/repo_fingerprint.json` による身元確認。破壊的操作前に `guard.sh --check` 必須
- **危険操作検知**: `rules/policy.json` による自動スキャン（rm -rf, git push --force, 秘密情報等）
- **Go/No-Go**: リスクスコア ≥ 8 または危険カテゴリ検出時に自動停止

---

## §11 Language（言語方針）

- 規範文書の正は**日本語**
- パス・コマンド・GitHub 用語は英語表記固定
- Adapter は日本語本文 + 必要最小限の英語要約を許容

---

## §12 Amendment（改訂規則）

- Charter の改訂には **Strict モード + Gate D（監査）必須**
- 改訂提案は PR として提出し、全 Gate を通過すること
- §4 Immutable Principles の削除・緩和は、上位（Developer）の明示的承認を要する
