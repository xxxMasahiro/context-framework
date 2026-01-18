# WORKFLOW / TRANSLATION_LAYER

## 目的
- Charter/Mode/Artifacts の抽象要求を、具体的な編集・検証・証跡へ翻訳する
- 各エージェントが迷わず Skills を適用できるようにする

## 固定用語（運用語彙）
- Done: 完了判定（成果物の合格条件）
- Evidence: 証跡（diff/log/commit/checksum 等）
- No-op: 変更なしの判断（理由と確認観点を記録）
- Apply Skill: Skill適用の固定表記（`Apply Skill: ...`）
- Skillログ: Skill実行の記録（手順・検証・証跡）
- Progress Log/Updates: トラッカーの完了記録欄

## 位置づけ（SSOTの優先順位）
- **Charter → Mode → Artifacts → Skills**
- 翻訳レイヤは上位の要求を「具体化するだけ」で、上位を上書きしない

## 抽象→具体の翻訳手順（if/then）
### Mode別の判断
- if Mode = lite:
  - 変更点は最小限で記録し、Evidenceは要点のみ
- if Mode = standard:
  - 変更点と理由を明確化し、再現可能な検証とEvidenceを残す
- if Mode = strict:
  - 監査観点を含め、Evidenceの完全性を優先する

### Artifacts別の判断
- if Task Lists:
  - 変更点（Add/Del/Mod）と Done を明示し、Apply Skill を記録する
  - No-op の場合は記載しない（Skill未実行のため）
- if Implementation Plan:
  - 変更ファイル単位の差分計画を追記し、Skill適用がある場合は参照を明示する
- if Walkthrough:
  - 検証手順・判断・Evidence を記録し、Skillログを残す
- if Audit artifacts:
  - Evidenceの整合性・不足・例外を記録する

## 固定の完成条件（Artifactsへ落とす）
- Done: 目的がArtifactsで確認できること
- Evidence: 追跡可能な証跡があること
- No-op: 変更しない理由と確認観点があること
- Apply Skill: `Apply Skill: SKILLS/<skill_file>.md` を固定表記で記録
- Skillログ: 実行内容と検証ログを Walkthrough に残す
- Progress Log/Updates: 完了時にトラッカーへ追記する

## 典型フロー（1手ずつ運用）
1) SSOTを読む（Charter → Mode → Artifacts → Skills）
2) 変更対象を確定し、Translation Layerで具体化
3) 追記で反映（変更点を Add/Del/Mod で明示）
4) 検証 → Evidence を残す
5) Commit → Progress Log/Updates に記録

## 迷ったら戻る場所
- ルール判断に迷ったら **SSOT階層**へ戻る
- 実装手順に迷ったら **Artifacts** と **Skills** を確認する
