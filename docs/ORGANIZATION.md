# diff-skills — 組織管理 (Organization = Agents)

> 更新: 2026-08-01

## 1. 概念

diff-skills の対象は「CLI エージェントの知能資産」だが、その頂点にあるのは
**エージェント自身**だ。スキル・MCP・コマンドは道具であり、それを使いこなす
「人格」たちの**組織**を管理しなければ、道具の管理も意味を持たない。

**soshiki（組織）** は、エージェント群を「会社組織」として一元管理する次元:

```
誰がいるか      → org_members (18 人格)
どの部署か      → departments (統括 / 開発 / 資産・守り / 監視・助言)
誰に従うか      → lead_id (直属リーダー) / v_org_tree (組織ツリー)
誰が誰に任せるか → delegations (委譲関係)
何の道具を持つか → member_equipment (soubi.db 装備連携)
```

## 2. 対象 (2026-08-01 時点の 18 人格)

### 統括 (Shizuka の傘下)
| agent | 役割 | mode | model |
|---|---|---|---|
| shizuka | モデルルーティング・コスト管理（司令塔） | primary | opencode-go/kimi-k3 |
| elon-pm | 第一原理PM・進捗管理 | subagent | — |
| hermes | タスク分解統合・スキル選定 | subagent | opencode-go/deepseek-v4-flash |
| mito | タイムボックス・時管理 | all | — |

### 開発
| agent | 役割 | lead |
|---|---|---|
| ryoma | 設計・複雑デバッグ | hermes |
| musashi | コーディング・実装（主力） | ryoma |
| ren | 再命名・名前整合 | musashi |
| takuboku | 軽量読取・調査 | hermes |

### 資産・守り
| agent | 役割 | lead |
|---|---|---|
| benkey (弁慶) | 装備品台帳 soubi.db | shizuka |
| yoshida (吉田松陰) | 接続管理 + セキュリティ監査 | shizuka |
| nyuro | 索引・孤児検出 | benkey |
| kimura | ゴミ掃除 | nyuro |
| goemon | メール処理 | shizuka |

### 監視・助言
| agent | 役割 |
|---|---|
| tsubame | Wi-Fi追跡・在宅判定 |
| buffett | 投資価値評価 |
| elon | 第一原理思考 |
| jobs | デザインディレクション |
| utaki | 長期ビジョン |

## 3. データモデル

実装: `org/schema.sql` (+ `org/seed.sql`)

| テーブル | 内容 |
|---|---|
| `departments` | 部署 (統括/開発/資産・守り/監視・助言) |
| `org_members` | エージェント (agent_id, cli, name, role, dept_id, mode, model, path, lead_id) |
| `delegations` | 委譲 (from, to, kind: task/design/implement/audit/cleanup/advisor) |
| `member_equipment` | エージェント × 装備 (soubi.db equipment.eq_id) |

ビュー: `v_members_by_dept` / `v_org_tree` / `v_delegations`

## 4. 運用フロー

```
定義ファイル (~/.config/opencode/agents/*.md)
        │  frontmatter (description/mode/model/permission)
        ▼
org/schema.sql + org/seed.sql  ← ここに組織としての構造 (部署・lead・委譲) を管理
        │
        ▼
soubi.db の equipment(kind=agent)  ← 装備としての視点 (弁慶)
        │
        ▼
ORGCHART.md (wiki)  ← 人間可読の組織図
```

- エージェント追加時: `org/seed.sql` に INSERT → `v_org_tree` で確認
- 役割変更時 (例: 弁慶→道具管理): `org_members.role` を更新し ORGCHART.md も更新
- 装備管理: `member_equipment` で「弁慶は soubi.db」「吉田松陰は yoshida.py」等を管理

## 5. 実体との対応

| 概念 | 実体 |
|---|---|
| エージェント定義 | `~/.config/opencode/agents/*.md` (opencode) |
| elon-pm 定義 | `~/agent/elon-pm.md` |
| 組織図 (人間可読) | `~/wiki/agent/ORGCHART.md` |
| 組織 DB (概念) | `org/schema.sql` + `org/seed.sql` (本リポジトリ) |
| 装備品台帳 | `~/soubi/soubi.db` (弁慶) |

## 6. 将来

- `member_equipment` を soubi.db と自動同期 (import スクリプト拡張)
- `v_org_tree` から ORGCHART.md を自動生成
- 組織変更の履歴 (org_log) を追加
