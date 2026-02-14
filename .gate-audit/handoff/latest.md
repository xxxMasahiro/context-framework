# Verification Kit Handoff

## 1. Meta
- generated: 2026-02-13T22:53:10Z / 2026-02-14 07:53:10 JST
- kit_root: /home/masahiro/.cfctx_verify_root/.cfctx_verify/.gate-audit
- kit_branch: wip/rename-gate-audit
- kit_HEAD: 814f2b7

## 2. Main Repo Snapshot
- path: /home/masahiro/projects/context-framework
- HEAD: b3d5ca2 (b3d5ca2eb1f4388c9b3460f24d2f064d3e0ea06b)
- branch: wip/rename-repo-id
- status: dirty (18 files)
- repo_lock: OK
- SSOT fingerprint:
  - cf_handoff_prompt.md: 8e7dc706
  - cf_update_runbook.md: 9c589b99
  - cf_task_tracker_v5.md: c0304cde
- SSOT match: YES (kit SSOT/ vs repo _handoff_check/)

## 3. Trackers Digest

### 3.1 Verification Tracker (tasks/verify_task_tracker.md)
- progress: 78/78 (100%)
- status: ALL_PASS
- pending items:
  - (none)
- last_updated: 2026-02-14 07:52:10

### 3.2 Test Tracker (tasks/test_task_tracker.md)
- progress: 6/6 (100%)
- status: ALL_PASS
- pending items:
  - (none)
- last_updated: 2026-02-14 07:52:32

### 3.3 As-built Tracker (tasks/as_built_task_tracker.md)
- progress: 18/18 (100%)
- status: ALL_PASS
- pending items:
  - (none)
- last_updated: 2026-02-13 04:21:02

### 3.4 Rebuild Tracker (tasks/rebuild_task_tracker.md)
- progress: 34/34 (100%)
- status: ALL_PASS
- pending items:
  - (none)
- last_updated: 2026-02-13 04:21:02

### 3.5 Post-rebuild Tracker (tasks/post_rebuild_task_tracker.md)
- progress: 7/7 (100%)
- status: ALL_PASS
- pending items:
  - (none)
- last_updated: 2026-02-13 04:21:02

### 3.6 Self-check Tracker (tasks/self_check_task_tracker.md)
- progress: 35/35 (100%)
- status: ALL_PASS
- pending items:
  - (none)
- last_updated: 2026-02-14 07:38:53

## 4. Evidence Index

| # | Timestamp | Purpose | Command | Verdict | SHA256 (first 16) | Path |
|---|-----------|---------|---------|---------|-------------------|------|
| 1 | 20260213-225310 | Self-check: Self-check Summary | - | FAIL | c23d5f17654a984d | logs/evidence/20260213-225310_sc_summary.txt |
| 2 | 20260213-225310 | Self-check: Regression Detection | - | PASS | ae687788a45e1e89 | logs/evidence/20260213-225310_sc_CQ-REG.txt |
| 3 | 20260213-225310 | Self-check: Naming Convention | - | PASS | 4ed9b2470783de5d | logs/evidence/20260213-225310_sc_CQ-NAME.txt |
| 4 | 20260213-225310 | Self-check: Script Quality | - | PASS | dad7f74d4b527660 | logs/evidence/20260213-225310_sc_CQ-LINT.txt |
| 5 | 20260213-225310 | Self-check: Document Consistency | - | PASS | 155f9ab6ba241837 | logs/evidence/20260213-225310_sc_CQ-DOC.txt |
| 6 | 20260213-225310 | Self-check: SSOT Drift | - | PASS | 23132ec9e658eda5 | logs/evidence/20260213-225310_sc_CQ-SSOT.txt |
| 7 | 20260213-225310 | Self-check: Evidence Chain | - | FAIL | 3cbbfc580f877c7a | logs/evidence/20260213-225310_sc_CQ-EVC.txt |
| 8 | 20260213-225307 | Self-check: Read-only Compliance | - | PASS | 2de6438331fcfa9b | logs/evidence/20260213-225307_sc_CQ-RO.txt |
| 9 | 20260213-225306 | Self-check: Tracker Integrity | - | PASS | 0499537bfc5490f4 | logs/evidence/20260213-225306_sc_CQ-TRK.txt |
| 10 | 20260213-225232 | test phase3 | - | PASS | b2135e9d0aa90985 | logs/evidence/20260213-225232_test_phase3.txt |
| 11 | 20260213T225231Z | gateI | - | PASS | 0930a2cb5e6b5a58 | logs/evidence/20260213T225231Z_gateI |
| 12 | 20260213T225231Z | gateH | - | PASS | 0918ce4d78952d16 | logs/evidence/20260213T225231Z_gateH |
| 13 | 20260213T225231Z | gateG | - | PASS | a734d186b96ab6a7 | logs/evidence/20260213T225231Z_gateG |
| 14 | 20260213T225231Z | gateF | - | PASS | 5fc6ebb823834219 | logs/evidence/20260213T225231Z_gateF |
| 15 | 20260213T225231Z | gateE | - | PASS | 5fb6d671bbbb525f | logs/evidence/20260213T225231Z_gateE |
| 16 | 20260213T225231Z | gateD | - | PASS | 765730a33f02000e | logs/evidence/20260213T225231Z_gateD |
| 17 | 20260213T225231Z | gateC | - | PASS | 3ab959640eccaf8a | logs/evidence/20260213T225231Z_gateC |
| 18 | 20260213T225231Z | gateB | - | PASS | d86b53d515f54060 | logs/evidence/20260213T225231Z_gateB |
| 19 | 20260213T225230Z | gateA | - | PASS | 05494e49509d2e68 | logs/evidence/20260213T225230Z_gateA |
| 20 | 20260213T225230Z | ssot precheck | - | UNKNOWN | 55e363738ebbf6d8 | logs/evidence/20260213T225230Z_ssot_precheck |
| 21 | 20260213T225230Z | repo reference | - | UNKNOWN | 725747bcceaea4d9 | logs/evidence/20260213T225230Z_repo_reference |
| 22 | 20260213T225230Z | gateI | - | PASS | 0b2bba765f8a132c | logs/evidence/20260213T225230Z_gateI |
| 23 | 20260213T225230Z | gateH | - | PASS | 7d9d2adb127feb5d | logs/evidence/20260213T225230Z_gateH |
| 24 | 20260213T225230Z | gateG | - | PASS | aa1cfa8974ac7e7c | logs/evidence/20260213T225230Z_gateG |
| 25 | 20260213T225230Z | gateF | - | PASS | 65febda9ea6b1ee0 | logs/evidence/20260213T225230Z_gateF |
| 26 | 20260213T225230Z | gateE | - | PASS | 7374b4865bf0f29c | logs/evidence/20260213T225230Z_gateE |
| 27 | 20260213T225229Z | gateD | - | PASS | 797747bdc3105231 | logs/evidence/20260213T225229Z_gateD |
| 28 | 20260213T225229Z | gateC | - | PASS | 0bef2e86c9b2cfd4 | logs/evidence/20260213T225229Z_gateC |
| 29 | 20260213T225229Z | gateB | - | PASS | fa8d51a8eaf88aec | logs/evidence/20260213T225229Z_gateB |
| 30 | 20260213T225229Z | gateA | - | PASS | 55721f115b1152ab | logs/evidence/20260213T225229Z_gateA |
| 31 | 20260213T225229Z | ssot precheck | - | UNKNOWN | 442c10be51bdc9ab | logs/evidence/20260213T225229Z_ssot_precheck |
| 32 | 20260213T225229Z | repo reference | - | UNKNOWN | 01b3f20fbda84025 | logs/evidence/20260213T225229Z_repo_reference |
| 33 | 20260213T225227Z | gateI | - | PASS | 85810e4844cffb11 | logs/evidence/20260213T225227Z_gateI |
| 34 | 20260213T225227Z | gateH | - | PASS | 79d7229988e288b3 | logs/evidence/20260213T225227Z_gateH |
| 35 | 20260213T225227Z | gateG | - | PASS | f7d73e6441e8a4e9 | logs/evidence/20260213T225227Z_gateG |
| 36 | 20260213T225227Z | gateF | - | PASS | b6ab10c090b29ced | logs/evidence/20260213T225227Z_gateF |
| 37 | 20260213T225227Z | gateE | - | PASS | 00420e82488f9558 | logs/evidence/20260213T225227Z_gateE |
| 38 | 20260213T225227Z | gateD | - | PASS | 2d3c8715399d4c6e | logs/evidence/20260213T225227Z_gateD |
| 39 | 20260213T225227Z | gateC | - | PASS | 149e5fd8f1a1d63b | logs/evidence/20260213T225227Z_gateC |
| 40 | 20260213T225226Z | gateB | - | PASS | 6e2741d1455c767e | logs/evidence/20260213T225226Z_gateB |
| 41 | 20260213T225226Z | gateA | - | PASS | d40b174c702c24c0 | logs/evidence/20260213T225226Z_gateA |
| 42 | 20260213T225226Z | ssot precheck | - | UNKNOWN | 688dc5272f97c22d | logs/evidence/20260213T225226Z_ssot_precheck |
| 43 | 20260213T225226Z | repo reference | - | UNKNOWN | dc0b5a2f3fb58bb1 | logs/evidence/20260213T225226Z_repo_reference |
| 44 | 20260213-225226 | test phase2 | - | PASS | 7a36b1736f8e0ec0 | logs/evidence/20260213-225226_test_phase2.txt |
| 45 | 20260213T225226Z | gateI | - | PASS | 174b3b4eb91699a0 | logs/evidence/20260213T225226Z_gateI |
| 46 | 20260213T225226Z | gateH | - | PASS | 9c69a929e952c0a4 | logs/evidence/20260213T225226Z_gateH |
| 47 | 20260213T225226Z | repo reference single | - | UNKNOWN | abb58447363bd741 | logs/evidence/20260213T225226Z_repo_reference_single |
| 48 | 20260213T225225Z | gateG | - | PASS | 91343b4bc2931978 | logs/evidence/20260213T225225Z_gateG |
| 49 | 20260213T225225Z | gateF | - | PASS | da6625c80866ad76 | logs/evidence/20260213T225225Z_gateF |
| 50 | 20260213T225225Z | gateE | - | PASS | b815b0e25f3a6a43 | logs/evidence/20260213T225225Z_gateE |
| 51 | 20260213T225225Z | gateD | - | PASS | 3032b63f9dc23534 | logs/evidence/20260213T225225Z_gateD |
| 52 | 20260213T225225Z | repo reference single | - | UNKNOWN | eb06e4377c2f9e68 | logs/evidence/20260213T225225Z_repo_reference_single |
| 53 | 20260213T225225Z | gateC | - | PASS | bab2397822534cae | logs/evidence/20260213T225225Z_gateC |
| 54 | 20260213T225224Z | gateB | - | PASS | ac63fc7a35762a81 | logs/evidence/20260213T225224Z_gateB |
| 55 | 20260213T225224Z | gateA | - | PASS | 5c523a6de758bc6d | logs/evidence/20260213T225224Z_gateA |
| 56 | 20260213T225224Z | repo reference single | - | UNKNOWN | 35901f4d3983c566 | logs/evidence/20260213T225224Z_repo_reference_single |
| 57 | 20260213-225224 | test phase1 | - | PASS | d85feb86f9891c31 | logs/evidence/20260213-225224_test_phase1.txt |
| 58 | 20260213T225224Z | gateI | - | PASS | 24ffb76855c29a08 | logs/evidence/20260213T225224Z_gateI |
| 59 | 20260213T225224Z | gateH | - | PASS | 0de62a5af0e64065 | logs/evidence/20260213T225224Z_gateH |
| 60 | 20260213T225223Z | gateG | - | PASS | 5e2cad0fd9e50cd3 | logs/evidence/20260213T225223Z_gateG |
| 61 | 20260213T225223Z | gateF | - | PASS | c87bdd1534450037 | logs/evidence/20260213T225223Z_gateF |
| 62 | 20260213T225223Z | gateE | - | PASS | 68224c1c5d5f4810 | logs/evidence/20260213T225223Z_gateE |
| 63 | 20260213T225223Z | gateD | - | PASS | f42f3808dc0bc712 | logs/evidence/20260213T225223Z_gateD |
| 64 | 20260213T225223Z | gateC | - | PASS | 728ef539bcc9b80e | logs/evidence/20260213T225223Z_gateC |
| 65 | 20260213T225223Z | gateB | - | PASS | 21c1e85325abd3cd | logs/evidence/20260213T225223Z_gateB |
| 66 | 20260213T225223Z | gateA | - | PASS | 02bfeb5528f23c82 | logs/evidence/20260213T225223Z_gateA |
| 67 | 20260213T225223Z | ssot precheck | - | UNKNOWN | bd31743c2093fa83 | logs/evidence/20260213T225223Z_ssot_precheck |
| 68 | 20260213T225223Z | repo reference | - | UNKNOWN | 6395bc4b8e11b9bd | logs/evidence/20260213T225223Z_repo_reference |
| 69 | 20260213T225210Z | gateI | - | PASS | 86f558db951c2d98 | logs/evidence/20260213T225210Z_gateI |
| 70 | 20260213T225209Z | gateH | - | PASS | e2440ce66bd4e4ef | logs/evidence/20260213T225209Z_gateH |
| 71 | 20260213T225209Z | gateG | - | PASS | 01c4fcca19180b07 | logs/evidence/20260213T225209Z_gateG |
| 72 | 20260213T225209Z | gateF | - | PASS | c853be39f214da7f | logs/evidence/20260213T225209Z_gateF |
| 73 | 20260213T225209Z | gateE | - | PASS | 06079e4ba06340a7 | logs/evidence/20260213T225209Z_gateE |
| 74 | 20260213T225209Z | gateD | - | PASS | ec1b548238f7ef4e | logs/evidence/20260213T225209Z_gateD |
| 75 | 20260213T225209Z | gateC | - | PASS | 603b03d9e0eb38fe | logs/evidence/20260213T225209Z_gateC |
| 76 | 20260213T225209Z | gateB | - | PASS | 5317f27f178eac88 | logs/evidence/20260213T225209Z_gateB |
| 77 | 20260213T225208Z | gateA | - | PASS | 57cb15946c6bdfcf | logs/evidence/20260213T225208Z_gateA |
| 78 | 20260213T225208Z | ssot precheck | - | UNKNOWN | b9a573897aba456a | logs/evidence/20260213T225208Z_ssot_precheck |
| 79 | 20260213T225208Z | repo reference | - | UNKNOWN | 4f362194114c02c1 | logs/evidence/20260213T225208Z_repo_reference |
| 80 | 20260203T154404Z | gateC | - | PASS | e46720f8aef7e13d | logs/evidence/20260203T154404Z_gateC |
| 81 | 20260203T154404Z | repo reference single | - | UNKNOWN | 4ff3fb8a84530283 | logs/evidence/20260203T154404Z_repo_reference_single |
| 82 | 20260204-002755 | Step 4: kit CLI subcommand tests | ./kit --help, ./kit status, ./kit han... | PASS | 01686e164eb424e5 | logs/evidence/20260204-002755_step4_kit_cli_test.txt |
| 83 | 20260204-004817 | Step 6: Acceptance Testing (AC-01 through AC-07) | ./kit all, ./kit verify C, ./kit stat... | PASS | fae51d90a3c6ba2c | logs/evidence/20260204-004817_step6_acceptance_ac01_07.txt |
| 84 | 20260204-035500 | CIQA Phase 1: Implementation Evidence | bash scripts/ciqa_runner.sh (all chec... | PASS | f26efaccc0c219f0 | logs/evidence/20260204-035500_ciqa_phase1_implementation.txt |
| 85 | 20260203T154326Z | gateI | - | PASS | 779397a1ebb00caa | logs/evidence/20260203T154326Z_gateI |
| 86 | 20260203T154326Z | gateH | - | PASS | 5483a6df25a44ddc | logs/evidence/20260203T154326Z_gateH |
| 87 | 20260203T154326Z | gateG | - | PASS | 5e6745a906160b82 | logs/evidence/20260203T154326Z_gateG |
| 88 | 20260203T154326Z | gateF | - | PASS | 0f3213bd0e91cba2 | logs/evidence/20260203T154326Z_gateF |
| 89 | 20260203T154326Z | gateE | - | PASS | 236e305f281865ae | logs/evidence/20260203T154326Z_gateE |
| 90 | 20260203T154325Z | ssot precheck | - | UNKNOWN | dc5ca8142b810f91 | logs/evidence/20260203T154325Z_ssot_precheck |
| 91 | 20260203T154325Z | gateD | - | PASS | d987294747dba306 | logs/evidence/20260203T154325Z_gateD |
| 92 | 20260203T154325Z | repo reference | - | UNKNOWN | aae879a2be32c51f | logs/evidence/20260203T154325Z_repo_reference |
| 93 | 20260203T154325Z | gateC | - | PASS | bcf65cb4f24aea26 | logs/evidence/20260203T154325Z_gateC |
| 94 | 20260203T154325Z | gateB | - | PASS | f536e512759763b2 | logs/evidence/20260203T154325Z_gateB |
| 95 | 20260203T154325Z | gateA | - | PASS | 31e3babd417f8355 | logs/evidence/20260203T154325Z_gateA |
| 96 | 20260203-184649 | CIQA Phase 0: Design Documents | create docs/ciqa/{requirements,spec,i... | PASS | e3814f882a3617a8 | logs/evidence/20260203-184649_ciqa_phase0_design.txt |
| 97 | 20260203-234314 | Step 3: tracker_updater.sh 単体テスト | source scripts/lib/tracker_updater.sh... | PASS | 968d7692876e815d | logs/evidence/20260203-234314_step3_tracker_updater_unit_test.txt |

Total: 97 evidences (79 PASS, 2 FAIL, 0 DIAG, 16 UNKNOWN)

## 5. Kit Files
- SSOT/cf_handoff_prompt.md
- SSOT/cf_update_runbook.md
- SSOT/cf_task_tracker_v5.md
- verify/verify_requirements.md
- verify/verify_spec.md
- verify/verify_implementation_plan.md
- context/run_rules.md
- context/codex_high_prompt.md

## 6. Commands
```
./kit handoff          latest.md を再生成
./kit verify [GATE]    検証実行 (例: ./kit verify C)
./kit test [PHASE]     テスト実行 (例: ./kit test 2)
./kit all              verify + test + handoff 一気通貫
./kit status           進捗サマリ表示
```

## 7. Notes
- This kit is generated outside repo by default (safety).
- Evidence is saved under logs/evidence/ and referenced from trackers.
- verify/ docs are canonical (do not modify).
