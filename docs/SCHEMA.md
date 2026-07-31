# diff-skills — 概念スキーマ

> 実装は `bonsai/diff-env/db/schema.sql`。ここでは概念としての設計意図を記す。
> 更新: 2026-08-01

## 1. エンティティ関係

```
clis (CLIカタログ)
  │
  ├──< skills (スキルマスタ: cli, name UNIQUE)
  │         │
  │         └──< skill_snapshots (デバイス × スキル)
  │
  ├── mcp_servers (デバイス × MCP名 UNIQUE)
  ├── agents (デバイス × エージェント名 UNIQUE)
  └── commands (デバイス × コマンド名 UNIQUE)
```

## 2. テーブル定義（概念）

### clis — CLI エージェントのカタログ
```
cli_id   INTEGER PK
name     TEXT UNIQUE   -- opencode | hermes | kilo | soubi
kind     TEXT          -- cli
category TEXT          -- CLI
```

### skills — スキルマスタ
```
skill_id    INTEGER PK
cli         TEXT       -- どの CLI のスキルか
name        TEXT
description TEXT
triggers    TEXT
UNIQUE(cli, name)
```

> 概念のポイント: スキルは「名前と CLI」で世界に一つ。
> 中身（プロンプト）はスナップショット側でハッシュ管理する。

### skill_snapshots — デバイス × スキルの有無
```
device_id   TEXT PK/FK → devices
skill_id    INTEGER PK/FK → skills
version     TEXT        -- 内容ハッシュ / git commit
path        TEXT        -- 実体パス (エビデンス)
snapshot_ts TEXT
```

> 概念のポイント: マスタに存在するがスナップショットが無い = そのデバイスに**未配備**。

### mcp_servers / agents / commands — デバイスごとの設定
```
mcp_servers:  device_id, name, command, args, enabled
agents:       device_id, name, description, path
commands:     device_id, name, description, run
いずれも UNIQUE(device_id, name)
```

## 3. ビュー（概念）

| ビュー | 意味 |
|---|---|
| `v_skill_matrix` | デバイス × スキル の有無マトリクス (`✗` = 無し) |
| `v_clis` | CLI 本体のバージョン比較 |
| `v_mcp` / `v_agents` / `v_commands` | デバイス × 資産 の一覧 |
| `v_matrix` / `v_diff` / `v_by_kind` | 既存 diff-env のツール差分 |

## 4. 実装との対応

| 概念 | 実装 (bonsai/diff-env) |
|---|---|
| DDL | `db/schema.sql` (「diff-skills」セクション, L75-178) |
| 収集 | `bin/collect-tools.py` |
| 同期 | `bin/sync.sh` (WSL 正) |
| 使い方 | `.opencode/skills/diff-env/SKILL.md` |

## 5. 将来: soubi 連携の概念マッピング

soubi.db では「装備」として wrap する:

```
diff-skills の視点          soubi.db の視点
──────────────────────     ──────────────────────
skills マスタ           →  equipment(kind=skill)
skill_snapshots(有無)   →  deployments(status)
mcp_servers             →  equipment(kind=mcp)
agents                  →  equipment(kind=agent)
commands                →  equipment(kind=command)
```

「差分を検出する (diff-skills)」と「装備として運用する (soubi)」は
同じデータの異なる視点。
