# diff-skills — 全体概念

> 更新: 2026-08-01

## 1. 動機

あるマシンでは opencode に 60 個のスキルが入っていて、別のマシンでは
そのうち 40 個しか入っていない。MCP サーバも、agents も、commands も
同様にずれる。

「どのマシンに何のツールが入っているか」を diff-env が管理するなら、
「どのマシンの CLI エージェントが何の能力を持っているか」も
同じ仕組みで管理できるはずだ。それが diff-skills の発想。

## 2. 対象とする「知能資産」

```
知能資産 = CLI エージェントの能力を定義するもの

  skills     ─ プロンプト・ワークフローの知識カード (SKILL.md)
  mcp_servers─ 外部ツール・データソースへの接続設定
  agents     ─ 役割・人格の定義 (subagent / primary)
  commands   ─ ユーザー定義のスラッシュコマンド
  clis       ─ エージェント本体 (バージョン)
```

これらは「コード」ではなく「設定・知識」だが、マシン間でずれると
能力の非対称になる。特にエージェントを使う立場では「全部のマシンに
同じスキルがある」ことは前提にできない。

## 3. データモデルの概念

diff-env のコア (`devices` / `tools` / `snapshots`) と対になる形で、
資産系 (`clis` / `skills` / `skill_snapshots` / `mcp_servers` / `agents` / `commands`)
を持つ。

```
devices ──────┬── tools ───── snapshots      (既存: ツール差分)
              └── clis ──────────────────────┬── skills ── skill_snapshots
                                             ├── mcp_servers
                                             ├── agents
                                             └── commands
```

- `skills` はマスタ (CLI × 名前 で一意)
- `skill_snapshots` はデバイスごとの有無 + 内容ハッシュ
- MCP / agents / commands はデバイスごとの設定そのもの

## 4. 差分の見せ方

### デバイス × スキル マトリクス (`v_skill_matrix`)

```
device      cli      skill          version
──────────  ───────  ─────────────  ────────
home-pc     opencode  article-update  9f3a2c1
home-wsl    opencode  article-update  9f3a2c1
company-pc  opencode  article-update  ✗        ← 無い
```

### 一覧ビュー (MCP / agents / commands)

```
device      name        description
──────────  ──────────  ─────────────────────
home-wsl    benkey      道具・装備管理 (soubi.db)
company-pc  (無い)      ← 未配備
```

## 5. 収集の流れ

```
sync.sh (WSL 正)
  │
  ├─ WSL 側: hermes / opencode / soubi の資産を走査
  ├─ Windows 側 (/mnt/c/Users/*): opencode スキル等を走査
  │
  ├─ collect-tools.py が skills / MCP / agents / commands を抽出
  │    └─ version 列 = 内容ハッシュ (変化検出用)
  │
  ├─ env.db を upsert
  └─ git commit + push  (履歴として残る)
```

## 6. 下流: soubi.db (装備品台帳)

diff-skills は「知能資産の差分」を見るための**概念**。実際に
「どのデバイスに何を装備するか」を運用するのは装備品台帳 soubi.db。

- 概念: 差分を検出する (diff-skills / diff-env)
- 運用: 装備・配備を管理する (soubi.db, 弁慶)
- つなぎ: `import_from_envdb.py` が env.db から soubi.db へ装備を同期

## 7. エージェント連携

| エージェント | 役割 | diff-skills との関係 |
|---|---|---|
| shizuka | モデルルーティング | env.db の cli 情報でルーティング判断 |
| benkei (弁慶) | 装備管理 | soubi.db から「どのマシンに何が装備されているか」を回答 |
| nyuro (にゅろ) | 索引 | 資産の孤児・重複の検出に利用 |

## 8. 関連ファイル

- 実装スキーマ: `bonsai/diff-env` → `db/schema.sql` (diff-skills セクション)
- 収集: `bin/collect-tools.py`
- 使い方: `.opencode/skills/diff-env/SKILL.md`
