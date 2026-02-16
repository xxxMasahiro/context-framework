# INITIAL_SETTINGS（初期設定の置き場と運用）

## 目的
- Developer が「エージェント → 役割」を割り当てるための初期設定の置き場を定義する。
- 3ファイル（CLAUDE/AGENTS/GEMINI）は、この初期設定を参照する入口とする（固定ロールにしない）。

## 初期設定ファイル
- 設定例: `.repo-id/agent_role_assignment.example.yaml`
- 実運用の配置候補: `.repo-id/agent_role_assignment.yaml`（名称は運用で決めてよい）

## 参照関係（簡易図）

```
Developer 設定
  └─ .repo-id/agent_role_assignment*.yaml
        └─ CLAUDE.md / AGENTS.md / GEMINI.md
              └─ SSOT: Charter → Mode → Artifacts → Skills
```

## 注意
- Repo Lock（guard.sh）とは別系統の仕組み。混同しない。
- 役割の行動規範は SSOT（Charter → Mode → Artifacts → Skills）に従う。
