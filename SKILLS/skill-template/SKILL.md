# Skill: skill-001（テンプレート）
> **目的**: Skills（再利用可能な手順）を、SSOT（Charter→Mode→Artifacts→Skills）に従って記録するための標準テンプレ。

---

## 1. 概要
- **Skill ID**: skill-001
- **Skill名**: （例）監査テンプレ生成 / トラッカー更新 / 監査観点チェック など
- **対象Gate**: （例）Gate A / Gate B / Gate C / Gate D
- **対象Mode**: lite / standard / strict（該当するもの）
- **対象範囲**: （例）Docs / Tracker / Audit / Tooling など

---

## 2. SSOT上の位置づけ
- Skills は **上位（Charter/Mode/Artifacts）を上書きしない**。
- Skills は **繰り返し可能な手順**を記録する（作業ログではなく“再現可能な手順”）。
- 実行手段（UI/CLI/特定AIツール等）は **adapters 側へ分離**し、Skill本文は原則として「目的/入力/出力/手順/検証」を中心に書く。

---

## 3. いつ使うか（適用条件）
- （例）同様の作業を複数回行う見込みがある
- （例）手順がブレやすく、再現性の担保が必要
- （例）監査・証跡（Evidence）が必須の作業である

---

## 4. 入力（Inputs）
- （例）対象ファイル: `WORKFLOW/AUDIT.md`
- （例）対象トラッカー: `_handoff_check/task_tracker.md`
- （例）関連SSOT/ルール: `WORKFLOW/TOOLING/COEXIST_3FILES.md`

---

## 5. 出力（Outputs）
- （例）更新されたドキュメント（追記のみ / 変更点明示）
- （例）トラッカーの [ ]→[x] と Evidence 追記
- （例）Progress Log/Updates への完了記録（日時・タスクID・証跡）

---

## 6. 手順（Steps）
### 6.1 最小手順（Standard想定）
1. （例）対象の現状確認（grep / sed / git status など）
2. （例）追記内容を決定（SSOTに矛盾しないこと）
3. （例）必要ファイルへ追記（既存記述の削除・改変は原則しない）
4. （例）トラッカー更新（[ ]→[x]、Evidence、Progress Log/Updates）
5. （例）差分確認（git diff）
6. （例）コミット & push（commit hash を Evidence に記録）

### 6.2 Strict（必要時）
- 条件: 重大性が高い / 監査上の指摘が重大 など
- 追加手順:
  - 監査（Auditor）結果の記録・再監査条件の明記
  - 例外運用がある場合は `ARTIFACTS/EXCEPTIONS.md` に理由・リスク・軽減策・期限（解除条件）を記録

---

## 7. 検証（Validation）
- [ ] 変更点が **追記中心**で、既存記述の破壊がない
- [ ] トラッカーに Done と Evidence がある
- [ ] Progress Log/Updates に完了記録がある
- [ ] `git status -sb` が `main...origin/main` でクリーン

---

## 8. Evidence（証跡の書き方）
- Evidence は **コミットハッシュ / diff / ログ / チェックサム**など、第三者が追跡できる形にする。
- 例: `commit: abc1234 / PATH/TO/FILE.md`

---

## 9. Notes
- 実行手段が特定ツール（Claude Code/Codex/Antigravity/GUI/CLI等）に依存する場合は、原則 `TOOLING/ADAPTERS/` 側に“実行方法”を寄せる。
- Skill本文は、将来ツールが変わっても再利用できるように保つ。

