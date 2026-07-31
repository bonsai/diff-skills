# diff-skills — CLI エージェント資産の差分管理 概念リポジトリ

> ステータス: **概念 (Concept) / 実装は bonsai/diff-env に寄託**
> 更新: 2026-08-01

## これは何か

**diff-skills** は、CLI エージェント（opencode / hermes / kilo / soubi）が持つ
**知能資産**を、通常のツール・バージョンと同様に「環境差分」として
追跡・一元管理するための**概念**です。

- スキル (SKILL.md)
- MCP サーバ
- エージェント定義 (agents)
- コマンド (commands)
- CLI 自体のバージョン

これらは「コード」ではなく「設定・知識」ですが、マシン間でずれると
能力の非対称が生まれます。diff-env がツールの `v_matrix` / `v_diff` で
環境差を見せるのと同じ発想を、**CLI の「知能資産」**にも適用したものが
diff-skills です。

```
┌─────────────────────────────────────────────────────────────┐
│                    diff-skills の立ち位置                       │
│                                                             │
│  環境 (デバイス)  ──▶  CLI エージェント  ──▶  知能資産         │
│  home-pc           opencode             skills (SKILL.md)   │
│  home-wsl          hermes               MCP サーバ           │
│  company-pc        kilo                 agents               │
│  ...               soubi                commands             │
│                                                             │
│  知能資産の「どの環境に何が装備されているか」を                     │
│  デバイス × 資産 のマトリクスで差分管理する。                     │
└─────────────────────────────────────────────────────────────┘
```

## 実装

概念の実装は **`https://github.com/bonsai/diff-env`** に含まれています。

| 概念 | 実装先 |
|---|---|
| スキーマ (clis / skills / skill_snapshots / mcp_servers / agents / commands) | `diff-env/db/schema.sql` |
| 収集スクリプト (skills / MCP / agents / commands) | `diff-env/bin/collect-tools.py` |
| 収集 + push | `diff-env/bin/sync.sh` (WSL 正) |
| エージェント用クエリ | `diff-env/.opencode/skills/diff-env/SKILL.md` |
| 下流コンシューマ: 装備品台帳 | `~/soubi/` (soubi.db) |

## ドキュメント

- [PRD.md](PRD.md) — 目的・非目的・要件
- [docs/CONCEPT.md](docs/CONCEPT.md) — 全体概念・構成
- [docs/SCHEMA.md](docs/SCHEMA.md) — 概念スキーマ（実装対応）
- [docs/INTEGRATION.md](docs/INTEGRATION.md) — soubi.db / エージェント連携
- [docs/ROADMAP.md](docs/ROADMAP.md) — 将来構想

## クイックスタート

```bash
# diff-env 側の実装を clone して、概念の実物を触る
git clone https://github.com/bonsai/diff-env.git
cd diff-env
bash bin/sync.sh home     # WSL 正: Windows+WSL の資産を収集して push
make skills               # デバイス × スキル マトリクス
make agents               # デバイス × agents
make mcp                  # デバイス × MCP サーバ
make commands             # デバイス × commands

# 装備品台帳 (下流) へ同期
python3 ~/soubi/import_from_envdb.py ~/diff-env/env.db ~/soubi/soubi.db
```

## 関連リポジトリ

- `bonsai/diff-env` — 実装 (ツール + CLI 資産のスナップショット DB)
- `bonsai/soubi` — (構想) 装備品台帳。現状はローカル `~/soubi/soubi.db`
- エージェント: shizuka (ルーティング) / benkei (装備管理) / nyuro (索引)
