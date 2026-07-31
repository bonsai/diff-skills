# diff-skills — ロードマップ

> 更新: 2026-08-01

## 現状 (2026-08-01)

- ✅ 概念定義 (本リポジトリ)
- ✅ 実装: `bonsai/diff-env` に diff-skills スキーマ + 収集スクリプト
- ✅ 収集: opencode / hermes / kilo / soubi の skills・MCP・agents・commands
- ✅ WSL 正移行 (2026-08-01, Windows 側はアーカイブ→3日後削除)
- ✅ 下流同期: soubi.db 装備品台帳 (弁慶担当)
- ✅ 組織管理 (soshiki) を独立リポジトリ化: `bonsai/soshiki` (ドラッカー担当)
- ✅ 既存 `bonsai/soubi` (private) を確認: 資産カタログ層 (inventory.sqlite)

## 短期 (Next)

- [x] **装備棚卸しコマンド** (弁慶用): `soubi list / issues / add`
      実装: `~/soubi/soubi.py` → `~/.local/bin/soubi`（`show` / `set-status` / `discard` / `sync` / `log` / `stat` も実装済み）
- [x] **組織 CLI** (soshiki 用, ドラッカー): `soshiki tree / dept / delegate / add-agent`
      実装: `soshiki/bin/soshiki.py` → `~/.local/bin/soshiki` (`add-domain` / `route` / `agent` / `domains` / `skills` も実装済み)
- [x] **鍵管理のスコープ除外**: API キー・シークレット管理はエージェント責務から除外し **手動のみ** に変更
      （弁慶・吉田松陰のスコープから鍵管理を除去）
- [ ] **スキル内容ハッシュの信頼性向上**: 現在の version ハッシュ方式の
      検証 (同一スキルが異なるハッシュになるケースの確認)
- [ ] **soubi 統合の整理**: ローカル `~/soubi/`（配備次元）と既存 `bonsai/soubi`（カタログ次元）の
      役割を統合方針に沿って整理

## 中期 (Mid)

- [ ] **資産の配布**: 欠品一覧 (`v_issues`) から「このマシンに足りない
      スキルを自動コピー/リンク」するブートストラップ
- [ ] **スキルの内容差分ビューア**: 同一スキル名で CLI 間の
      プロンプト差分を diff 表示
- [ ] **エージェント間シナプス連携**: nyuro の索引と組み合わせて
      孤児スキル・重複スキルの自動検出

## 長期 (Long)

- [ ] **ポリシーベースの配備管理**: 「company-pc にはこのスキルを
      必須にする」等の intent を soubi.db で宣言し、diff と突き合わせ
- [ ] **組織図の自動生成**: `v_org_tree` から ORGCHART.md (wiki) を自動生成
- [ ] **他 CLI エージェントへの対応**: 新しいエージェント型ツールを
      プラグイン的に追加できる構造
- [ ] **BQ への集約**: 履歴を BigQuery にロードし、経時変化の分析
