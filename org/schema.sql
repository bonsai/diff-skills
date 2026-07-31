-- soshiki (組織) — エージェント組織の管理スキーマ
-- diff-skills の一部: CLI エージェント資産のうち「組織」次元を管理する
-- 実体 (エージェント定義 .md) は ~/.config/opencode/agents/ にあり、
-- ここでは組織としての構造 (部署・役割・階層・委譲・装備) を一元管理する。

-- 部署 (部門)
CREATE TABLE IF NOT EXISTS departments (
  dept_id TEXT PRIMARY KEY,          -- 統括 | 開発 | 資産・守り | 監視・助言
  name    TEXT NOT NULL,
  purpose TEXT NOT NULL DEFAULT ''
);

-- 組織メンバー (エージェント)
CREATE TABLE IF NOT EXISTS org_members (
  agent_id TEXT PRIMARY KEY,         -- 定義ファイル名 (benkey, musashi, ...)
  cli      TEXT NOT NULL DEFAULT 'opencode',  -- opencode | hermes | kilo | soubi
  name     TEXT NOT NULL,            -- 表示名 (弁慶, 武蔵, ...)
  role     TEXT NOT NULL DEFAULT '', -- 役割
  dept_id  TEXT REFERENCES departments(dept_id),
  mode     TEXT NOT NULL DEFAULT 'subagent',  -- primary | subagent | all
  model    TEXT NOT NULL DEFAULT '', -- 使用モデル
  path     TEXT NOT NULL DEFAULT '', -- 定義ファイルパス
  lead_id  TEXT REFERENCES org_members(agent_id),  -- 直属リーダー
  active   INTEGER NOT NULL DEFAULT 1,
  note     TEXT NOT NULL DEFAULT ''
);

-- 委譲関係 (誰が誰に任せるか)
CREATE TABLE IF NOT EXISTS delegations (
  from_agent TEXT NOT NULL REFERENCES org_members(agent_id),
  to_agent   TEXT NOT NULL REFERENCES org_members(agent_id),
  kind       TEXT NOT NULL,          -- task | design | implement | audit | cleanup | advisor
  note       TEXT NOT NULL DEFAULT '',
  PRIMARY KEY (from_agent, to_agent, kind)
);

-- 装備所有 (エージェント × soubi.db equipment)
CREATE TABLE IF NOT EXISTS member_equipment (
  agent_id TEXT NOT NULL REFERENCES org_members(agent_id),
  eq_id    INTEGER NOT NULL,         -- soubi.db equipment.eq_id を参照
  note     TEXT NOT NULL DEFAULT '',
  PRIMARY KEY (agent_id, eq_id)
);

-- ビュー: 部署別メンバー
CREATE VIEW IF NOT EXISTS v_members_by_dept AS
SELECT d.name AS dept, m.agent_id, m.name AS member, m.role, m.mode, m.model,
       lead.name AS lead
FROM org_members m
LEFT JOIN departments d ON m.dept_id = d.dept_id
LEFT JOIN org_members lead ON m.lead_id = lead.agent_id
ORDER BY d.name, m.agent_id;

-- ビュー: 組織ツリー (直属リーダー基準)
CREATE VIEW IF NOT EXISTS v_org_tree AS
WITH RECURSIVE tree(agent_id, name, role, dept_id, lead_id, depth) AS (
  SELECT agent_id, name, role, dept_id, lead_id, 0 FROM org_members WHERE lead_id IS NULL
  UNION ALL
  SELECT m.agent_id, m.name, m.role, m.dept_id, m.lead_id, t.depth + 1
  FROM org_members m JOIN tree t ON m.lead_id = t.agent_id
)
SELECT agent_id, name, role, dept_id, lead_id, depth FROM tree ORDER BY depth, name;

-- ビュー: 委譲マトリクス
CREATE VIEW IF NOT EXISTS v_delegations AS
SELECT f.name AS from_agent, t.name AS to_agent, d.kind, d.note
FROM delegations d
JOIN org_members f ON d.from_agent = f.agent_id
JOIN org_members t ON d.to_agent = t.agent_id
ORDER BY d.kind, f.name, t.name;
