# diff-skills — PRD (Product Requirements / 概念定義)

> 更新: 2026-08-01

## 1. 目的 (Why)

複数デバイス (home-pc / home-wsl / company-pc …) で動く CLI エージェントの
**知能資産**（スキル・MCP・agents・commands）が、マシン間で意図せず
ずれる問題を可視化し、**環境差を検出・解消・統一**できるようにする。

diff-env が「どのマシンにどのツールがどのバージョンで入っているか」を
スナップショットするのに対し、diff-skills は
「どのマシンにどの CLI エージェントのどの知能資産が装備されているか」を
スナップショットする。

## 2. 対象 (What)

収集対象 CLI: **opencode / hermes / kilo / soubi**

| 資産 | 説明 | 収集元の例 |
|---|---|---|
| CLI バージョン | エージェント本体のバージョン | `opencode --version` 等 |
| skills | スキル定義 (SKILL.md) | `~/.opencode/skills/*/SKILL.md`, `~/.config/*/skills/*/SKILL.md`, hermes スキル群 |
| MCP サーバ | 外部ツール接続設定 | `opencode.jsonc` の mcp セクション |
| agents | エージェント定義 (役割・人格) | `~/.config/opencode/agents/*.md` |
| commands | カスタムコマンド | `command.db`, `~/.config/opencode/commands` |
| 組織 (soshiki) | エージェント組織の構造 (部署・lead・委譲・得意ドメイン) | `bonsai/soshiki`（別リポジトリ, 組織管理=ドラッカー） |

## 3. 非目的 (Non-Goals)

- 知能資産の**中身**（スキルの本文・プロンプト）の詳細差分は見ない。
  スナップショットは「内容ハッシュ (version)」で有無・変化を判定する。
- 資産の**配布・デプロイ**は行わない（配備管理は soubi.db の領域）。
- ソースコード・依存パッケージの管理はしない（それは diff-env のツール差分 / 通常の VCS の領域）。
- 組織の**人事評価・勤怠**は管理しない（あくまで構造・関係の記録）。

## 4. 要件 (Requirements)

### 4.1 スナップショット
- `skills` は CLI × スキル名 で一意 (UNIQUE(cli,name))。
- `skill_snapshots` は デバイス × スキル で一意。version 列に内容ハッシュを記録。
- MCP / agents / commands は デバイス × 名前 で一意。

### 4.2 差分表示
- デバイス × スキル の有無マトリクス (`v_skill_matrix`) で「その環境に無い」を `✗` 表示。
- CLI ごとの一覧ビュー (`v_mcp`, `v_agents`, `v_commands`) で環境差を俯瞰。

### 4.3 収集
- `bin/collect-tools.py` が CLI ごとの既定ディレクトリを走査して自動収集。
- WSL から `--os windows` で Windows 側 (`/mnt/c/Users/*`) も収集できる。
- `--dry-run` で DB を書き換えずに確認できる。
- `.hostmap.json` でホスト名 → ラベル (home/company) の自動解決。

### 4.4 同期
- `sync.sh` (WSL 正) が収集 → DB 更新 → git commit → push を一括実行。
- `env.db` は Git 管理下で履歴追跡可能。

### 4.5 下流利用
- 装備品台帳 `soubi.db` が diff-env の `env.db` を参照し、
  「装備 (equipment)」「配備 (deployments)」の視点でラップする。

## 5. 成功指標

- マシン間の知能資産の差を 1 クエリで一覧できる。
- 新規マシンに資産を揃えるとき、欠品一覧をベースに作業できる。
- 装備品台帳 (soubi.db) が自動同期で最新を保てる。

## 6. 用語

| 用語 | 意味 |
|---|---|
| CLI エージェント | コマンドラインで動くエージェント型ツール (opencode/hermes/kilo/soubi) |
| 知能資産 | エージェントの能力を定義する設定・知識 (skills/MCP/agents/commands) |
| 内容ハッシュ | スキルの中身を要約したハッシュ。変化の検出に使用 |
| 装備 | soubi.db の視点。知能資産を「道具」として扱う |
