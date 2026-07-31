# diff-skills — 連携 (soubi.db / エージェント)

> 更新: 2026-08-01

## 1. レイヤー

```
┌──────────────────────────────────────────────────┐
│  diff-skills (概念)                                │
│  「CLI エージェントの知能資産を環境差分で管理する」      │
│  ── 実装: bonsai/diff-env (env.db)               │
├──────────────────────────────────────────────────┤
│  soubi.db (装備品台帳, 弁慶)                        │
│  「どのマシンに何を装備しているか」を運用視点で管理      │
│  ── env.db を参照して equipment / deployments に同期│
├──────────────────────────────────────────────────┤
│  エージェント                                       │
│  shizuka (ルーティング) / benkei (装備) / nyuro (索引)│
└──────────────────────────────────────────────────┘
```

## 2. env.db → soubi.db 同期

`~/soubi/import_from_envdb.py` が変換する:

| env.db (diff-skills) | soubi.db (装備品台帳) |
|---|---|
| `skills` + `skill_snapshots` | `equipment(kind=skill)` + `deployments` |
| `mcp_servers` | `equipment(kind=mcp)` + `deployments` |
| `agents` | `equipment(kind=agent)` + `deployments` |
| `commands` | `equipment(kind=command)` + `deployments` |

### 実行
```bash
python3 ~/soubi/import_from_envdb.py ~/diff-env/env.db ~/soubi/soubi.db
```

### 結果サンプル (2026-08-01 時点)
```
== equipment ==   skill 127 / mcp 11 / agent 18 / command 15
== deployments == home-pc 75 / home-wsl 96
== v_issues ==    (欠品・問題装備) 0
```

## 3. soubi.db のビュー

- `v_equipment` — 装備一覧 (デバイス別ステータス)
- `v_issues` — 欠品・問題装備 (status != 'equipped')

## 4. エージェント利用フロー

1. **収集** (`bash ~/diff-env/bin/sync.sh home`) → env.db 更新 → push
2. **同期** (`python3 ~/soubi/import_from_envdb.py`) → soubi.db 更新
3. **回答** (弁慶) → soubi.db を照会して「どのマシンに何が装備されているか」を答える
   ```bash
   sqlite3 ~/soubi/soubi.db "SELECT kind, cli, name, device_id, status FROM v_equipment WHERE status!='equipped';"
   ```
4. **ルーティング** (しずか) → env.db の cli 情報からモデル・ツールを判断

## 5. 注意点

- `env.db` は Git 管理下で履歴が残る。`soubi.db` は現状ローカルのみ。
- スキルの**中身**の差分は見ない (version ハッシュのみ)。
- 配備の「意図」(何を揃えたいか) は soubi.db の deployments.status で管理する。
