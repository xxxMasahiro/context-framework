# WORKFLOW / MODES_AND_TRIGGERS

## 用語整理（Mode / Profile）
- **Mode**：運用ルールの定義（Lite / Standard / Strict）
- **Profile**：成果物内でModeを記録するための記入欄
- 本フレームでは **Mode と Profile は同義** として扱う
  - 使い分け：運用説明では Mode、記録欄では Profile を使う

## Mode定義（Lite / Standard / Strict）
### Lite
- 目的：最小コストで前進しつつ、重要な判断のみ残す
- 適用範囲：小規模変更、影響が限定的、検証が軽い
- 期待する成果物の粒度：要点のみ、差分の説明は短くてもよい

### Standard
- 目的：レビュー可能な証跡を残し、実行の再現性を確保
- 適用範囲：複数ファイル変更や機能追加、影響が中程度
- 期待する成果物の粒度：変更内容と理由を明確化、検証手順の具体化

### Strict
- 目的：高リスク変更の失敗確率を下げ、監査/説明責任に耐える
- 適用範囲：重大な変更（破壊的変更、セキュリティ、外部依存や課金など）
- 期待する成果物の粒度：意思決定ログ、詳細な検証、証跡の完全性

## Triggers定義（Yes / No）
- **Triggers = Yes**：Standard以上へエスカレーションすべき条件がある
- **Triggers = No**：Liteの範囲内で進行可能

### 代表的なトリガ一覧
- 複数ファイル変更、依存関係の増減
- リリース/配布物更新、外部公開への影響
- 破壊的変更、後方互換性の破れ
- セキュリティ/権限/個人情報に触れる変更
- 外部API/課金/コスト発生の可能性
- 監査対象、コンプライアンス要件の影響
- 再現性リスクが高い手順（手動操作が多い等）

## エスカレーション規則
- 既定は **Lite**
- **Triggers = Yes** の場合は **Standard** へ
- 重大性が高い場合は **Strict** へ

### 重大性の判定目安
- 破壊的変更、セキュリティ/権限、外部公開/配布、監査対象
- 外部API/課金などコストや契約に影響する変更
- 失敗時の復旧が難しい、または影響範囲が広い

## 記載テンプレ（ARTIFACT冒頭貼り付け用）
```text
## Profile / Triggers
- Profile: Lite | Standard | Strict
- Triggers: Yes | No
- Reason: 
- 定義: [../WORKFLOW/MODES_AND_TRIGGERS.md](../WORKFLOW/MODES_AND_TRIGGERS.md)
```

## GATEとの接続（最低限の運用手順）
- Gate A：`ARTIFACTS/TASK_LISTS.md` に **Profile / Triggers** を記入して合意
- Gate B：`ARTIFACTS/IMPLEMENTATION_PLAN.md` で **Profile / Triggers** を再確認（必要なら昇格）
- Gate C：`ARTIFACTS/WALKTHROUGH.md` で **Profile / Triggers** と証跡の整合を確認
