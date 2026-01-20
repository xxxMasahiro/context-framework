# cf_handoff_prompt.md（このチャットの引継ぎメモ）

## 0. 目的
- 引継ぎ運用を「_handoff_check の3ファイル添付」に簡略化した。
- 今後 Prompt.md は使わない（参照禁止）。

## 1. 今回の変更サマリ（何を追加/削除/修正したか）
- 修正対象は _handoff_check の2ファイルのみ：
  - _handoff_check/cf_update_runbook.md
  - _handoff_check/cf_task_tracker_v5.md
- 変更内容（要約）：
  - Prompt.md 参照を runbook/tracker から排除（運用からPrompt.md撤廃）
  - 「新チャット引継ぎ = 3ファイル添付（runbook/tracker + cf_handoff_prompt）」のテンプレを両ファイルへ統一
  - tracker の Progress Log/Updates に「引継ぎ簡略運用」系の更新を反映

## 2. エビデンス（コミット/状態）
- 直近コミット：
  - 0f70baa docs: handoff simplification (drop prompt refs)
  - c15a9c3 docs: tracker log evidence for handoff simplification
- push は最終的に成功（DNS失敗が出たが再実行で解消）。
- 現状：main ブランチ、作業ツリー clean。

## 3. 同一性確認（引用個所と同じ最新版か）
- sha256（引用スクショで示されていた値と一致）：
  - cf_update_runbook.md: 2347a6ac7021d9304f67f60dba77346d34dd5d97163eaa7bf7cd06e66e307673
  - cf_task_tracker_v5.md: 2f7a01112a589e02ecf1fced3608435a2b98e2f262fbfc7859fc582320e22fc0
→ 「引用個所のファイル」と同一の最新版。

## 4. 懸念点/次にやる候補（未実施）
※致命ではないが、将来の混乱を減らす改善候補（必要なら最小差分）
- tracker 冒頭に「v3」表記が残っている箇所があれば「v5」に寄せる
- runbook に旧運用の言い回し（例：添付3ZIP/next1-3 等）が残っていれば、新運用（添付3ファイル）へ文言を寄せる
（※矛盾まではしていない前提。実際に残っているかはSSOTの現物で確認して判断する）

## 5. 新チャット側への要求（最重要）
- 添付3ファイルを最初に読むこと
- runbook/tracker をSSOTとして準拠すること（cf_handoff_prompt はメモであり、整合性チェック対象外だが運用はSSOT準拠）
- 次にやることは「1つ（1コマンド/1操作）」で提示すること
