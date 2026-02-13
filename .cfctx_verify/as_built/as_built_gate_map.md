# as-built Gate Map & 操作ガイド（Temporary Verification Kit）

version: 1.9
date: 2026-02-07
status: 正式版（v1.9: Phase 5 lockdown/unlock 実装 + MAIN_REPO バリデーション強化、as-built v1.9 準拠）

---

## 0. 本書の位置づけ

本書は **Temporary Verification Kit（検証キット）** の **現状（as-built）説明書** である。
初めてこのリポジトリに触れるエンジニアが、キットの全体像・各コマンドの使い方・Gate の意味・ディレクトリ構造を理解できることを目的とする。

**準拠文書（as_built 3 文書）**:

| 文書 | 役割 | パス |
|------|------|------|
| 要件定義書 | 「なぜ必要か」を定義 | `as_built/as_built_requirements.md`（v1.7） |
| 仕様書 | 「どう動くか」を定義 | `as_built/as_built_spec.md`（v1.7） |
| 実装計画書 | 「どう作ったか」を定義 | `as_built/as_built_implementation_plan.md`（v1.7） |

**SSOT（運用の正）**: `verify/verify_spec.md`。SSOT と as-built の差分は各文書の「差分/曖昧/未実装一覧」セクションで管理している。

---

## 1. 検証キットとは何か

### 1.1 一言で言うと

本体リポジトリ（`cf-context-framework`）の品質を **外部から壊さずに検証する** ためのツールセットである。

### 1.2 なぜ必要か

ソフトウェアの品質保証（QA）では、テスト対象のコードを変更してしまうと「テスト結果の信頼性」が損なわれる。たとえば、テスト中にバグを直してしまえば、元々バグがあったという事実が消えてしまう。

本キットは以下の原則で設計されている:

1. **本体 repo を絶対に変更しない（REQ-S02: read-only）** — 本体 repo に対して `git commit` / `git push` / ファイル書き込みを一切行わない。
2. **本体 repo の外に配置する（REQ-S01）** — キット自体が本体のコードに混入しないようにする。
3. **すべての操作に証跡（Evidence）を残す（REQ-T01）** — いつ・誰が・何をチェックし・結果がどうだったかを自動記録する。

### 1.3 基本的な仕組み

```
┌──────────────────────────────────────────────────────┐
│  本体 repo (cf-context-framework)                     │
│  ※ read-only: 参照のみ、書き込み禁止                    │
└──────────────────────┬───────────────────────────────┘
                       │ 参照（git status, grep, sha256sum 等）
                       ▼
┌──────────────────────────────────────────────────────┐
│  検証キット (KIT_ROOT)                                 │
│  ~/.cfctx_verify_root/.cfctx_verify/                  │
│                                                        │
│  ./kit verify    → Gate A〜I を自動検証                 │
│  ./kit test      → Phase 1〜3 のテスト実行              │
│  ./kit ciqa      → 8 種の CI/QA チェック                │
│  ./kit all       → 上記全部を一気通貫で実行              │
│  ./kit handoff   → 引継ぎ文書を再生成                   │
│  ./kit status    → 進捗サマリを表示（副作用なし）         │
│  ./kit lockdown  → 検証キットを quarantine に隔離        │
│  ./kit unlock    → quarantine から復元（二段階解除）      │
│                                                        │
│  結果はすべて logs/evidence/ に自動保存                  │
│  進捗は tasks/ のトラッカーに自動記録                    │
│  引継ぎ文書は handoff/latest.md に自動生成               │
└──────────────────────────────────────────────────────┘
```

---

## 2. ディレクトリ構造

```
KIT_ROOT/
│
├── kit                          ← 統合 CLI（全操作の入口）
├── .gitignore                   ← git 除外設定
│
├── SSOT/                        ← 本体 _handoff_check/ のスナップショット（3 ファイル）
│   ├── cf_handoff_prompt.md
│   ├── cf_update_runbook.md
│   └── cf_task_tracker_v5.md
│
├── context/                     ← 運用ルール・プロンプト
│   ├── run_rules.md             ← 運用ルール集
│   └── codex_high_prompt.md     ← Codex high 向けプロンプト
│
├── config/                      ← 設定ファイル
│   └── ciqa.conf                ← CI/QA チェックの設定
│
├── tasks/                       ← トラッカー群（6 ファイル）
│   ├── verify_task_tracker.md   ← Gate A-I 検証トラッカー（49/49 ALL_PASS）
│   ├── test_task_tracker.md     ← テスト実行トラッカー（6/6 ALL_PASS）
│   ├── as_built_task_tracker.md ← as-built 作成トラッカー（10/10 ALL_PASS）
│   ├── rebuild_task_tracker.md  ← 再構築タスク管理（34/34 ALL_PASS）
│   ├── post_rebuild_task_tracker.md ← 再構築後タスク管理（7/7 ALL_PASS）
│   └── ciqa_task_tracker.md     ← CI/QA タスク管理（35/35 ALL_PASS）
│
├── as_built/                    ← as-built 文書（本書を含む 4 ファイル）
│   ├── as_built_requirements.md ← 要件定義書（v1.2）
│   ├── as_built_spec.md         ← 仕様書（v1.2）
│   ├── as_built_implementation_plan.md ← 実装計画書（v1.2）
│   └── as_built_gate_map.md     ← 本書（Gate Map & 操作ガイド）
│
├── verify/                      ← SSOT のキット内参照コピー
│   ├── verify_requirements.md
│   ├── verify_spec.md
│   └── verify_implementation_plan.md
│
├── docs/                        ← 設計文書
│   ├── rebuild/                 ← 再構築設計（3 ファイル）
│   └── ciqa/                    ← CI/QA 設計（4 ファイル）
│
├── scripts/                     ← スクリプト群
│   ├── verify_all.sh            ← Gate A-I 一括検証
│   ├── verify_gate.sh           ← 個別 Gate 検証
│   ├── generate_handoff.sh      ← handoff 生成
│   ├── run_tests.sh             ← テストランナー Phase 1-3
│   ├── ciqa_runner.sh           ← CI/QA 実行器
│   ├── lockdown.sh              ← 検証キット隔離（Phase 5）
│   ├── unlock.sh                ← 検証キット隔離解除（Phase 5）
│   └── lib/                     ← ライブラリ群
│       ├── evidence.sh          ← 共通関数（証跡管理・判定・ファイル操作）
│       ├── ssot_check.sh        ← SSOT 整合比較
│       ├── gate_registry.sh     ← Gate 自動発見レジストリ
│       ├── handoff_builder.sh   ← latest.md 生成ロジック
│       ├── tracker_updater.sh   ← トラッカー自動更新
│       ├── ciqa_common.sh       ← CI/QA 共通ヘルパー
│       ├── gate_a.sh〜gate_i.sh ← 各 Gate 検証ロジック（9 ファイル）
│       └── ciqa_checks/         ← CIQA チェックプラグイン（7 + テンプレート）
│
├── tools/                       ← ユーティリティ（テンプレート等）
│   └── verify_ro_mount_nopasswd_template_v5.sh
│
├── logs/                        ← 検証ログ・証跡
│   ├── evidence/                ← 検証証跡（タイムスタンプ付き）
│   └── ciqa/baseline/           ← CIQA 回帰検出用ベースライン
│
└── handoff/                     ← 引継ぎ文書
    ├── latest.md                ← 自動生成される引継ぎ文書
    └── latest.txt               ← 同内容テキスト版
```

---

## 3. コマンド詳細ガイド

### 3.0 前提：./kit とは

`./kit` は検証キットの **統合 CLI（コマンドラインインターフェース）** である。すべての操作は `./kit <サブコマンド>` の形式で実行する。

**パス解決の仕組み（SPEC-S01）**:
- `kit` は自分自身の置かれたディレクトリを `SCRIPT_DIR` として検出し、そこを `KIT_ROOT`（キットのルートディレクトリ）として使う。
- 環境変数を手動で設定する必要はない。`./kit` を実行するだけで、すべてのパスが自動的に解決される。
- 内部で `handoff_builder.sh`、`tracker_updater.sh`、`gate_registry.sh` をライブラリとして読み込む。

**Exit code の約束（REQ 要件定義書 §7 準拠）**:

| コマンド | Exit 0 | Exit 1 |
|----------|--------|--------|
| `./kit verify` | 全 Gate が PASS | 1 件以上 FAIL |
| `./kit test` | 全 Phase が PASS | 1 件以上 FAIL |
| `./kit ciqa` | 全チェックが PASS | 1 件以上 FAIL |
| `./kit all` | 全ステップが PASS | 1 件以上 FAIL |
| `./kit handoff` | 生成成功 | 生成失敗 |
| `./kit status` | 常に 0 | — |
| `./kit lockdown` | 隔離成功 | 中断またはエラー |
| `./kit unlock` | 復元成功 | 中断またはエラー |

---

### 3.1 ./kit verify [GATE...]

#### なぜ使うのか

Gate A〜I は本体リポジトリの品質を **多角的に検証するための段階的チェックポイント** である。
各 Gate は 3 つの観点（req1: 機能要約、req2: 体系整合、req3: 機能性）で検証を行い、結果を Evidence（証跡）として自動保存する。

「本体リポジトリが壊れていないか？」「ドキュメントとコードの間に矛盾がないか？」を、**人間の目視確認に頼らず、スクリプトで機械的に判定する** ために使う。

#### 何が達成されるか

- Gate A〜I のすべて（または指定した Gate）が PASS/FAIL で判定される。
- 各 Gate の証跡が `logs/evidence/<タイムスタンプ>_gate<ID>/` に自動保存される。
- `tasks/verify_task_tracker.md` が自動更新される（`[ ]` → `[x]`、判定・Evidence パス・日時が自動挿入）。
- `handoff/latest.md` が自動再生成される。

#### どうして便利なのか

- **手動作業ゼロ**: コマンド一発で 9 Gate × 3 観点 = 27 チェックが実行される。
- **証跡が自動保存**: 「いつ・何をチェックし・結果がどうだったか」が全自動で記録される。後から「本当にチェックしたの？」と聞かれても、Evidence を見せるだけで済む。
- **トラッカー自動更新**: 検証結果がトラッカーに自動反映されるため、進捗管理の手間がない。

#### 使い方

```bash
# 全 Gate を検証（最も一般的な使い方）
./kit verify

# 特定の Gate だけ検証（例: Gate C のみ）
./kit verify C

# 複数の Gate を指定して検証
./kit verify A B C
```

#### 内部処理の流れ（SPEC-S02, S03）

1. 本体 repo を自動発見（`discover_main_repo()`）
2. repo の参照証跡を記録（HEAD, status 等）
3. SSOT 比較（Kit `SSOT/` と本体 `_handoff_check/` の sha256 一致確認）
4. 各 Gate の `verify_gate_<id>()` を順次実行
5. `gate_summary()` が各 Gate の総合判定を出力し、`GATE_EVIDENCE` マーカーを出力
6. `kit` がマーカーを自動パースしてトラッカーを更新（SPEC-S15）
7. `handoff/latest.md` を再生成

---

### 3.2 ./kit test [PHASE]

#### なぜ使うのか

`./kit verify` が「本体 repo の品質」を検証するのに対し、`./kit test` は **「検証キット自体が正しく動作するか」** を検証する。

検証ツールが壊れていたら、そのツールで得た検証結果は信用できない。これは「体重計が壊れていたら、体重を量っても意味がない」のと同じ理屈である。

#### 何が達成されるか

3 つの Phase で段階的にテストが実行される:

| Phase | 名前 | 内容 | 確認すること |
|-------|------|------|------------|
| Phase 1 | 環境/スモーク | 環境前提確認 + 最小スモーク | Kit の配置場所が正しいか、本体 repo が clean か、Repo Lock が有効か、全スクリプトが read-only か |
| Phase 2 | Gate 固有 | 各 Gate を個別に再検証 | Gate A〜I それぞれが単独実行で PASS するか |
| Phase 3 | E2E/再現性 | 全体導線 + 再現性確認 | verify_all.sh → handoff 生成の全工程が通るか、2 回実行して同じ結果になるか |

#### どうして便利なのか

- **キット自体の信頼性を保証**: 「このキットで検証した結果は信用できる」と第三者に説明できる。
- **再現性の確認**: 同じ条件で 2 回実行して結果が一致するかを自動チェックする。

#### 使い方

```bash
# 全 Phase を実行（最も一般的）
./kit test

# Phase 1 のみ実行（環境確認だけ素早く行いたい場合）
./kit test 1

# Phase 2 のみ実行（Gate 固有のテストだけ再実行したい場合）
./kit test 2
```

---

### 3.3 ./kit ciqa [CHECK...]

#### なぜ使うのか

`verify` と `test` が合格しても、**ドキュメント間の整合性** や **命名規約の逸脱** など、Gate 検証ではカバーしきれない品質問題がある。

`ciqa`（CI/QA）は、こうした「検証の検証」を行う 8 種のチェックを提供する。人間が見落としがちなメタ品質を機械的にチェックするためのレイヤーである。

#### 何が達成されるか

8 種のチェックが実行され、それぞれ PASS/FAIL で判定される:

| Check Key | Check ID | チェック内容 | なぜ必要か |
|-----------|----------|------------|----------|
| tracker | CQ-TRK | トラッカー整合性 | `[x]` になった項目に判定・Evidence・日時が揃っているか確認。記録漏れを防ぐ |
| evidence | CQ-EVC | Evidence 実在確認 | トラッカーが参照している Evidence ファイルが実際に存在するか確認。リンク切れを防ぐ |
| ssot | CQ-SSOT | SSOT ドリフト検出 | Kit の SSOT/ と本体の _handoff_check/ の sha256 が一致するか確認。知らないうちに SSOT が変わっていないか検出する |
| docs | CQ-DOC | ドキュメント整合 | 要件書と仕様書の間でセクション対応が取れているか確認 |
| lint | CQ-LINT | スクリプト品質 | shellcheck でシェルスクリプトの品質を検査 |
| naming | CQ-NAME | 命名規約 | Evidence ファイル名がタイムスタンプ付き命名規約に従っているか確認 |
| regression | CQ-REG | 回帰検出 | 前回 PASS だったチェックが今回 FAIL になっていないか自動検出 |
| readonly | CQ-RO | Read-only Compliance | gate/verify スクリプトに本体 repo への書き込み操作（13 種パターン）が存在しないことを静的検証。REQ-S02 の自動担保 |

#### どうして便利なのか

- **メタ品質の自動チェック**: 「トラッカーを更新し忘れた」「Evidence を消してしまった」「SSOT が更新された」といった見落としを自動検出する。
- **プラグイン方式**: 新しいチェックを追加するには `scripts/lib/ciqa_checks/cq_<key>.sh` を置くだけ（REQ-F08, SPEC-S09）。kit 本体の変更は不要。

#### 使い方

```bash
# 全チェック実行（最も一般的）
./kit ciqa

# 特定のチェックのみ実行
./kit ciqa tracker evidence

# config/ciqa.conf で除外指定（否定構文）
#   checks=!lint,!naming  → lint と naming 以外を実行
#   注意: 正の指定（tracker）と負の指定（!lint）の混在はエラーになる
```

#### チェック実行順序

プラグインは `@check_order` メタデータで実行順序が制御される（SPEC-S09）:

```
tracker(10) → evidence(20) → ssot(30) → docs(40) → lint(50) → naming(50) → regression(60)
```

数字が小さいほど先に実行される。同じ数字のプラグインはキー名のアルファベット順で安定ソートされる。

---

### 3.4 ./kit all

#### なぜ使うのか

`verify` → `test` → `ciqa` → `handoff` を個別に実行するのは面倒である。`./kit all` は **4 ステップを一気通貫で実行する** コマンドである。

#### 何が達成されるか

```
Step 1/4: verify（全 Gate A〜I）
Step 2/4: test（全 Phase 1〜3）
Step 3/4: ciqa（全 8 チェック）
Step 4/4: handoff（引継ぎ文書の最終生成）
```

**重要な設計判断**: FAIL があっても最後の handoff まで実行する。これは「一部が FAIL でも、現在の状態を引継ぎ文書に正確に記録する」ためである（SPEC-S06）。

#### どうして便利なのか

- **コマンド一発で全工程が完了**: 検証・テスト・品質チェック・引継ぎ文書生成がすべて自動で行われる。
- **最終的な handoff が常に最新**: 全工程の結果を反映した引継ぎ文書が生成される。

#### 使い方

```bash
./kit all
```

---

### 3.5 ./kit handoff

#### なぜ使うのか

チャットセッション（Claude Code 等）は有限である。セッションが終わるとき、次のセッションに「今どこまで進んだか」を正確に伝える必要がある。`./kit handoff` はその **引継ぎ文書を自動生成する** コマンドである。

#### 何が達成されるか

`handoff/latest.md`（と `latest.txt`）が生成される。この文書には以下の情報が含まれる:

| セクション | 内容 |
|-----------|------|
| 1. Meta | 生成日時、Kit のブランチ・HEAD |
| 2. Main Repo Snapshot | 本体 repo のパス・HEAD・ブランチ・状態・SSOT 一致状況 |
| 3. Trackers Digest | 6 トラッカーの進捗（完了数/総数/パーセント/ステータス） |
| 4. Evidence Index | 全 Evidence の一覧（目的・判定・sha256・パス） |
| 5. Kit Files | SSOT / verify / context のファイルリスト |
| 6. Commands | ./kit のサブコマンド一覧 |
| 7. Notes | 安全性・運用上の注意 |

#### どうして便利なのか

- **自己完結型**: `latest.md` 一枚を読むだけで、キットの全状態がわかる。
- **全自動**: 手動で状態をまとめる必要がない。コマンド一発で最新状態が文書化される。

#### 使い方

```bash
# 通常はこれだけ（verify/test/ciqa 後に自動的に呼ばれるため、手動で実行する機会は少ない）
./kit handoff

# MAIN_REPO が自動発見できない環境では環境変数を指定する
MAIN_REPO=/path/to/context-framework ./kit handoff
```

#### MAIN_REPO の自動発見ロジック

`discover_main_repo()` 関数（evidence.sh:18-38）は以下の優先順序で本体 repo を探す:

1. `CFCTX_MAIN_REPO` 環境変数（明示指定）
2. `MAIN_REPO` 環境変数（呼び出し元が設定）
3. KIT_ROOT の兄弟ディレクトリを検索
4. `CFCTX_SEARCH_PATH`（デフォルト: `$HOME/projects`）内を検索

通常は自動発見されるが、**Claude Code のような非対話環境では KIT_ROOT の兄弟ディレクトリに本体 repo が存在しない場合がある**ため、`MAIN_REPO` 環境変数の明示指定が必要になることがある。

**v1.9 バリデーション強化（REQ-F16, SPEC-S16）**:
すべての候補 repo は `_validate_main_repo()` で 4 段階検証される:
1. `.git` ディレクトリ存在
2. `_handoff_check/` ディレクトリ存在
3. 構造マーカー（WORKFLOW/controller/rules のいずれか）
4. **SSOT sha256 照合**: Kit SSOT/ と候補 repo の `_handoff_check/` 3 ファイルの sha256 が完全一致

これにより、同一検索パスに複数の cf-context-framework クローンが存在する場合でも、**Kit の SSOT スナップショットと一致する正しい repo のみ**が自動選択される。「正しい患者ではなく、別の患者を診断してしまう」リスクが排除される。

---

### 3.6 ./kit status

#### なぜ使うのか

6 つのトラッカー（verify, test, as_built, rebuild, post_rebuild, ciqa）の進捗を一覧するコマンドである。
「いま全体でどこまで進んでいるのか」をコマンド一発で把握できる。

#### 何が達成されるか

副作用なし（ファイルの変更なし）で、以下のような進捗サマリが表示される:

```
=== Kit Status ===

  Verify:    49/49 (100%) ALL_PASS
  Test:       6/6  (100%) ALL_PASS
  As-built:  10/10 (100%) ALL_PASS
  Rebuild:   34/34 (100%) ALL_PASS
  PostRebld:  7/7  (100%) ALL_PASS
  CIQA:      35/35 (100%) ALL_PASS

Kit root: /home/masahiro/.cfctx_verify_root/.cfctx_verify
Timestamp: 2026-02-06 22:55 JST
```

#### どうして便利なのか

- **副作用なし**: 何も変更しないので、いつでも安全に実行できる。
- **全トラッカー横断**: 6 つのトラッカーの状態を一画面で把握できる。

#### 使い方

```bash
./kit status
```

---

### 3.7 ./kit lockdown

#### なぜ使うのか

検証が完了した後、検証キットを隔離して通常運用からアクセスしにくくするためのコマンドである。
「注意書きで触らない運用」ではなく「鍵がかかった扉」を提供する（REQ-S02 の物理ロック補強）。

#### 何が達成されるか

1. KIT_ROOT が `.cfctx_quarantine/verify-<timestamp>/` に移動される
2. `chmod -R go-rwx` で owner 以外のアクセスが禁止される
3. `LOCKED.flag`（解除判定用メタデータ）と `README_LOCKED.md`（ロック説明）が作成される

#### 使い方

```bash
# 対話的に確認してロック
./kit lockdown

# 非対話環境（CI等）でロック
LOCKDOWN_CONFIRM=yes ./kit lockdown
```

---

### 3.8 ./kit unlock

#### なぜ使うのか

隔離された検証キットを元のパスに復元するためのコマンドである。二段階の安全解除で誤操作を防止する。

#### 何が達成されるか

1. `LOCKED.flag` の存在確認（ステージ 1）
2. パスフレーズ `UNLOCK-VERIFY-KIT` の確認（ステージ 2）
3. 権限復元 + Kit を元のパスに移動 + LOCKED.flag / README_LOCKED.md 削除

#### 使い方

```bash
# quarantine 内から直接実行
bash ~/.cfctx_verify_root/.cfctx_quarantine/verify-<timestamp>/scripts/unlock.sh

# 非対話環境
UNLOCK_PASSPHRASE=UNLOCK-VERIFY-KIT bash <quarantine_path>/scripts/unlock.sh
```

---

## 4. Gate A〜I の詳細

Gate はそれぞれ本体 repo の異なる側面を検証する。各 Gate は 3 つの観点で検証を行う:

- **req1（機能要約）**: 対象アーティファクトの存在確認・内容チェック
- **req2（体系整合）**: クロスリファレンス（ドキュメント間の整合性）
- **req3（機能性）**: 実際の動作・構造の確認

### Gate A — Task Lists 合意（タスク合意）

- **何を検証するか**: ARTIFACTS/TASK_LISTS.md が存在し、スコープ・完了条件が定義されていること。
- **evidence 根拠**:
  - WORKFLOW/GATES.md:11 — Gate A の定義
  - README.md:43 — タスクリスト参照
  - WORKFLOW/MODES_AND_TRIGGERS.md:67 — モード遷移条件
  - QUICK_START.md:21 — クイックスタートの参照

### Gate B — Implementation Plan 合意（実装計画合意）

- **何を検証するか**: 実装計画が合意され、ワークフロー定義に反映されていること。
- **evidence 根拠**:
  - WORKFLOW/GATES.md:17 — Gate B の定義
  - README.md:44 — 実装計画参照
  - WORKFLOW/MODES_AND_TRIGGERS.md:68 — モード遷移条件

### Gate C — Walkthrough 完走（アダプタ参照整合）

- **何を検証するか**: アダプタの参照整合性、policy.json のルールが正しく定義されていること。
- **evidence 根拠**:
  - WORKFLOW/GATES.md:23 — Gate C の定義
  - README.md:45 — ウォークスルー参照
  - WORKFLOW/MODES_AND_TRIGGERS.md:69 — モード遷移条件
  - QUICK_START.md:25 — クイックスタートの参照
- **実装根拠（policy 参照）**:
  - controller/main.py:301, 307, 308 — コントローラのポリシー参照
  - rules/policy.json:111-114 — ポリシールール定義

### Gate D — Audit 完了（監査ゲート）

- **何を検証するか**: 監査プロセスが完了し、ワークフロー定義に反映されていること。
- **evidence 根拠**:
  - WORKFLOW/GATES.md:31 — Gate D の定義
  - WORKFLOW/MODES_AND_TRIGGERS.md:70 — モード遷移条件

### Gate E — 言語ポリシー（日本語統一）

- **何を検証するか**: ドキュメントの言語ポリシー（日本語統一）が遵守されていること。
- **evidence 根拠**:
  - _handoff_check/cf_update_runbook.md:766-775 — 言語ポリシー定義

### Gate F — 初期設定/役割割当（フレームワーク整合性）

- **何を検証するか**: フレームワークの初期設定と役割の割り当てが整合していること。
- **evidence 根拠**:
  - _handoff_check/cf_update_runbook.md:791-801 — 初期設定/役割定義

### Gate G — ログ運用95%効率化（ログ導線）

- **何を検証するか**: ログ運用の導線（索引・ログ・ルール）が存在し、整合していること。
- **evidence 根拠**:
  - _handoff_check/cf_update_runbook.md:804-860 — ログ運用定義

### Gate H — 新規タスクの入口（Handoff 整合）

- **何を検証するか**: 新規タスクの入口としてのアーカイブが整備されていること。
- **evidence 根拠**:
  - _handoff_check/cf_update_runbook.md:441-474 — 新規タスク定義

### Gate I — 用途別ツールMCP（統合ゲート）

- **何を検証するか**: MCP（STDIO）設計が定義され、統合が完了していること。
- **evidence 根拠**:
  - _handoff_check/cf_update_runbook.md:443-451 — MCP 設計定義

### Gate 自動発見の仕組み（REQ-F07, SPEC-S08）

新しい Gate を追加するには:

1. `scripts/lib/gate_<id>.sh` を作成する（`<id>` は英数字・アンダースコアのみ。正規表現メタ文字は不可）
2. ファイル内に `verify_gate_<id>()` 関数を定義する
3. **他のファイルの変更は不要** — `gate_registry.sh` が自動発見、`run_tests.sh` が自動追従、`tracker_updater.sh` がトラッカーセクションを自動生成する

---

## 5. セキュリティ

### 5.1 セキュリティ姿勢（REQ-S05, SPEC-D03）

2026-02-06 のセキュリティ総合調査（シェルスクリプト 28 本 + 設定・データファイル）の結果:

| 項目 | 状態 |
|------|------|
| Critical/High の脆弱性 | **0 件** |
| eval コマンド | **不使用**（全スクリプトで検出ゼロ） |
| set -euo pipefail | **全メインスクリプトで統一採用** |
| 変数クォート | **大部分がダブルクォート適切化** |
| バッククォート | **不使用**（$() 構文に統一） |
| 本体 repo への書き込み | **なし**（read-only 設計） |
| 機密情報（パスワード・トークン・API キー） | **漏洩なし** |
| ファイル権限 | **world-writable ファイルなし** |
| /tmp の使用 | **なし**（一時ファイルはキット管理下に限定） |

全 17 件の指摘事項（Medium 3 / Low 11 / Info 3）はすべて Pass（受容）と判定された。
詳細は `as_built/as_built_spec.md` の SPEC-D03 セクションを参照。

### 5.2 || true パターンの安全性

`|| true` はシェルスクリプトで頻繁に見られるパターンだが、「エラーを握りつぶしている」と誤解されることがある。本キットでは以下の用途にのみ限定使用している:

| 用途 | 例 | 理由 |
|------|---|------|
| 検索コマンドの安全終了（REQ-S03） | `grep ... \|\| true` | grep がマッチなしで非ゼロ終了するのを防ぐ。仕様で明示的に要求されたパターン |
| repo 自動検出のフォールバック | `MAIN_REPO=$(discover_main_repo) \|\| true` | 検出失敗時にデフォルト値を使用 |
| bash 算術演算の保護 | `((counter++)) \|\| true` | bash で counter=0 時に (( )) が非ゼロ終了するバグの回避 |
| トラッカー自動更新の隔離 | `update_verify_tracker ... \|\| true` | 更新失敗が検証結果（exit code）に影響しない設計 |

致命的エラーは `set -euo pipefail` によって即座にスクリプトを停止する。`|| true` は非致命的操作にのみ使用されている。

---

## 6. tools/ ディレクトリ: NOPASSWD mount/umount 検証テンプレート

### 6.1 このスクリプトは何か

`tools/verify_ro_mount_nopasswd_template_v5.sh` は、本体 repo ディレクトリを **read-only でマウント**して物理的な書き込みを防止するための **検証テンプレート** である。

### 6.2 なぜ必要か: read-only マウントの意義

検証キットの最も重要な安全性要件は「本体 repo を変更しない（REQ-S02）」である。
スクリプトレベルでは `git commit/push` を使わないことで実現しているが、**人為的ミスやバグによって意図しない書き込みが発生するリスク** は完全にはゼロにできない。

read-only マウントを使うと、**OS レベルで書き込みを物理的に禁止**できる。
つまり、どんなスクリプトを実行しても、どんなコマンドを打っても、マウントされたディレクトリへの書き込みは OS が拒否する。

### 6.3 検証の流れ（6 ステップ）

このスクリプトは以下を順番に検証する:

```
1. 負のテスト:  sudo -n -k /usr/bin/id -u が「失敗」すること
   → mount/umount 以外の sudo が NOPASSWD でないことを確認

2. bind mount:  sudo -n -k /usr/bin/mount --bind "$CORE" "$CORE"
   → CORE ディレクトリを自分自身にバインドマウント

3. ro remount:  sudo -n -k /usr/bin/mount -o remount,ro,bind "$CORE" "$CORE"
   → read-only に切り替え（書き込み禁止状態になる）

4. rw remount:  sudo -n -k /usr/bin/mount -o remount,rw,bind "$CORE" "$CORE"
   → read-write に復元（書き込み可能状態に戻す）

5. umount:      sudo -n -k /usr/bin/umount "$CORE"
   → マウントを解除して元の状態に戻す

6. 最終判定:    1〜5 すべて合格なら PASS、1 つでも不合格なら FAIL
```

### 6.4 NOPASSWD と TTY の関係（詳細解説）

#### 6.4.1 TTY（端末）とは

TTY（TeleTYpe）は、ユーザーがキーボードから入力し画面に出力する **対話的な端末** のことである。
ターミナルアプリ（Windows Terminal、iTerm2 等）で開いたシェルは TTY が割り当てられている。

```bash
# TTY が割り当てられているか確認する方法
tty
# 出力例: /dev/pts/0  → TTY あり
# 出力例: not a tty   → TTY なし
```

#### 6.4.2 なぜ TTY が問題になるのか

`sudo` コマンドは通常、パスワード入力を求める。パスワード入力には TTY（対話的端末）が必要である。

しかし、以下の環境では **TTY が存在しない**:

| 環境 | TTY | sudo のパスワード入力 |
|------|-----|---------------------|
| ターミナルで手動実行 | あり | 可能 |
| Claude Code から実行 | **なし** | **不可能** |
| GitHub Actions | **なし** | **不可能** |
| cron ジョブ | **なし** | **不可能** |
| SSH 経由のスクリプト実行（-T オプション） | **なし** | **不可能** |

Claude Code のような **AI アシスタントが実行するコマンド** は、TTY を持たない非対話的な環境で動作する。
そのため、通常の `sudo` は「パスワードを入力してください」というプロンプトを表示しようとして **即座に失敗** する。

#### 6.4.3 NOPASSWD の仕組み

`NOPASSWD` は `/etc/sudoers` に設定する指示で、「特定のコマンドに限り、パスワードなしで sudo を許可する」という意味である。

```
# /etc/sudoers の設定例:
masahiro ALL=(root) NOPASSWD: /usr/bin/mount, /usr/bin/umount
```

この設定は「`masahiro` ユーザーが `/usr/bin/mount` と `/usr/bin/umount` だけはパスワードなしで sudo 実行できる」ことを意味する。**他の全てのコマンド**（例: `/usr/bin/id`）は通常通りパスワードが必要なままである。

#### 6.4.4 sudo -n -k の意味

スクリプト内で使われている `sudo -n -k` は 2 つのフラグの組み合わせである:

| フラグ | 正式名 | 意味 |
|--------|--------|------|
| `-n` | `--non-interactive` | パスワードプロンプトを表示しない。パスワードが必要な場合は即座にエラー終了する。TTY がない環境でハングアップすることを防ぐ |
| `-k` | `--reset-timestamp` | 以前にキャッシュされたパスワードを無効化する。毎回フレッシュな認証状態でテストする |

つまり `sudo -n -k /usr/bin/mount ...` は「パスワードなしで mount できるか？ できなければ即座にエラー」という意味になる。

#### 6.4.5 負のテスト（ステップ 1）の重要性

```bash
# このコマンドが「失敗」することを確認する
sudo -n -k /usr/bin/id -u
```

このテストは「mount/umount **以外**の sudo が NOPASSWD になっていないこと」を確認している。
もしこのテストが **成功** してしまったら、`/etc/sudoers` の設定が緩すぎる（汎用 sudo が NOPASSWD になっている）ことを意味し、セキュリティ上問題がある。

**正しい状態**: mount/umount のみ NOPASSWD で許可され、他のコマンドは通常通りパスワードが必要。

#### 6.4.6 安全ガード

スクリプトには以下の安全機構が組み込まれている:

1. **事前チェック**: CORE が既にマウントポイントの場合は中断する。二重マウントを防ぐ。
2. **Cleanup trap**: スクリプトが異常終了しても、`trap cleanup EXIT` により自動的に umount が試みられる。マウントが残ったままになることを防ぐ。
3. **set -euo pipefail**: 予期しないエラーで即座に停止する。

### 6.5 使い方

```bash
# CORE（本体 repo のパス）を指定して実行
CORE=/home/masahiro/projects/context-framework \
  bash tools/verify_ro_mount_nopasswd_template_v5.sh

# または CFCTX_MAIN_REPO 環境変数を使用
CFCTX_MAIN_REPO=/home/masahiro/projects/context-framework \
  bash tools/verify_ro_mount_nopasswd_template_v5.sh
```

**前提条件**:
- `/etc/sudoers` で mount/umount の NOPASSWD が設定されていること
- CORE ディレクトリが既にマウントポイントでないこと

---

## 7. トレーサビリティ（REQ → SPEC → PLAN）

本キットのすべての要件・仕様・実装計画は相互に追跡可能（traceable）である。

| カテゴリ | 要件 ID | 対応 SPEC | 対応 PLAN |
|---------|---------|-----------|-----------|
| 安全性 | REQ-S01 (生成場所) | SPEC-D01 | PLAN-P1 |
| 安全性 | REQ-S02 (read-only) | SPEC-D02 | PLAN-P1 |
| 安全性 | REQ-S03 (検索安全) | SPEC-D02 | PLAN-P1 |
| 安全性 | REQ-S04 (Repo Lock) | SPEC-S02 | PLAN-P2 |
| 安全性 | REQ-S05 (セキュリティ姿勢) | SPEC-D02, SPEC-D03 | PLAN-SEC01 |
| 追跡性 | REQ-T01 (Evidence) | SPEC-S10 | PLAN-P2 |
| 追跡性 | REQ-T02 (命名) | SPEC-S10 | PLAN-P2 |
| 追跡性 | REQ-T03 (Checksum) | SPEC-S10 | PLAN-P2 |
| 追跡性 | REQ-T04 (Tracker) | SPEC-S11 | PLAN-P2 |
| 追跡性 | REQ-T05 (handoff) | SPEC-S12 | PLAN-P3 |
| 機能 | REQ-F01 (./kit) | SPEC-S01 | PLAN-P3 |
| 機能 | REQ-F02 (verify) | SPEC-S02, S03 | PLAN-P3 |
| 機能 | REQ-F03 (test) | SPEC-S04 | PLAN-P3 |
| 機能 | REQ-F04 (ciqa) | SPEC-S05 | PLAN-P4 |
| 機能 | REQ-F05 (all) | SPEC-S06 | PLAN-P3 |
| 機能 | REQ-F06 (status) | SPEC-S07 | PLAN-P3 |
| 機能 | REQ-F07 (Gate 自動発見) | SPEC-S08 | PLAN-P3 |
| 機能 | REQ-F08 (CIQA 自動発見) | SPEC-S09 | PLAN-P4 |
| 機能 | REQ-F09 (トラッカー自動更新) | SPEC-S11, S15 | PLAN-MAINT03 |
| 機能 | REQ-F10 (プラグインソート) | SPEC-S09 | PLAN-MAINT02 |
| 機能 | REQ-F11 (否定構文) | SPEC-S05 | PLAN-PROC04 |
| 機能 | REQ-F12 (REQ-ID 範囲展開) | SPEC-CQ01 | PLAN-P4 |
| 機能 | REQ-F13 (GATE_EVIDENCE マーカー) | SPEC-S10, S15 | PLAN-EV01 |
| 機能 | REQ-F14 (進捗ログ自動記録) | SPEC-S11 | PLAN-MAINT03 |

---

## 8. よくある質問（FAQ）

### Q1: 本体 repo が別の場所にあるとき、どうすればよいですか？

`MAIN_REPO` 環境変数を設定してからコマンドを実行してください:

```bash
MAIN_REPO=/path/to/context-framework ./kit verify
```

### Q2: 新しい Gate を追加するにはどうすればよいですか？

`scripts/lib/gate_<id>.sh` を作成し、`verify_gate_<id>()` 関数を定義するだけです。`kit` 本体や他のファイルの変更は不要です（PLAN-MAINT01）。

### Q3: 新しい CIQA チェックを追加するにはどうすればよいですか？

`scripts/lib/ciqa_checks/cq_<key>.sh` を作成し、メタデータヘッダ（`@check_key`, `@check_id`, `@check_display`, `@check_order`）と `run_check()` 関数を定義するだけです（PLAN-MAINT02）。

### Q4: SSOT が更新されたとき、どうすればよいですか？

```bash
# 1. SSOT を更新
cp ~/projects/context-framework/_handoff_check/*.md SSOT/

# 2. SSOT 一致を確認
./kit ciqa ssot
```

### Q5: FAIL が出たとき、どうすればよいですか？

`logs/evidence/` 内の証跡ファイル（特に `judgement.txt`）を確認し、FAIL の原因を特定してください。詳細な切り分け手順は `as_built/as_built_implementation_plan.md` の §4（PLAN-FAIL01〜04）を参照。

---

## 9. 変更履歴

- v0.1（2026-02-03 JST）: 旧版（Claude Code 作成、Gate 根拠リストのみ）
- v1.0（2026-02-06 JST）: 全面改訂（as-built 3 文書準拠、コマンド詳細ガイド追加、ディレクトリ構造説明、Gate 詳細、セキュリティ姿勢、NOPASSWD/TTY 解説、FAQ 追加）
- v1.2（2026-02-06 JST）: as-built v1.2（セキュリティ総合調査結果）に準拠
- v1.3（2026-02-07 JST）: CQ-RO チェック追加（CIQA 8 種に更新）、Phase 1 ro mount 検証統合、as-built v1.3 準拠
- v1.4（2026-02-07 JST）: バグ修正 8 件の反映（Gate 判定厳格化、exit code 修正、パス修正、サマリ抽出修正、階層修正）、as-built v1.4 準拠
- v1.5（2026-02-07 JST）: Gate 動的スケーラビリティ対応（run_tests.sh 動的化、tracker_updater.sh セクション自動生成、gate_registry.sh Gate ID バリデーション〈`_gr_is_safe_gate_id()` ヘルパー、列挙時+source 前で一貫適用〉、Gate 追加手順に ID 制約・全自動追従を反映）、as-built v1.5 準拠
- v1.6（2026-02-07 JST）: Codex 評価指摘 4 件修正（verify_all.sh fail-closed 化 + SSOT MATCH 必須化、gate_registry.sh unsafe ID→FATAL + while read 堅牢化）、as-built v1.6 準拠
- v1.7（2026-02-07 JST）: run_tests.sh Phase 2 Gate 0 件ガード追加（プロセス置換の偽 PASS 防止）、as-built v1.7 準拠
- v1.8（2026-02-07 JST）: gate_a.sh/gate_b.sh req② の `repo_grep` 引数バグ修正（`-i` フラグ誤渡し解消→Gate A/B PASS 復帰）、9 PASS / 0 FAIL + SSOT MATCH 達成、as-built v1.8 準拠
- v1.9（2026-02-07 JST）: Phase 5 lockdown/unlock 実装（§3.7/3.8 追加）+ MAIN_REPO バリデーション強化（SSOT sha256 照合で誤 repo 接続防止、§3.5 更新）+ ディレクトリ構造・Exit code テーブル・コマンド一覧更新、as-built v1.9 準拠
