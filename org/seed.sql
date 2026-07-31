-- soshiki seed — 現状の組織 (2026-08-01) を投入
-- 元データ: ~/.config/opencode/agents/*.md + ~/wiki/agent/ORGCHART.md

-- 部署
INSERT OR REPLACE INTO departments(dept_id, name, purpose) VALUES
  ('統括',     '統括',       'モデルルーティング・タスク配分・時管理'),
  ('開発',     '開発',       '設計・実装・調査・命名'),
  ('資産・守り','資産・守り', '装備・セキュリティ・索引・掃除・メール'),
  ('監視・助言','監視・助言', 'トラッキング・評価・アドバイザー');

-- メンバー (18 人格)
INSERT OR REPLACE INTO org_members(agent_id, cli, name, role, dept_id, mode, model, path, lead_id, active) VALUES
  ('shizuka', 'opencode', 'しずか',   'モデルルーティング・コスト管理（司令塔）', '統括', 'primary', 'opencode-go/kimi-k3',        '~/.config/opencode/agents/shizuka.md', NULL, 1),
  ('elon-pm', 'opencode', 'マスク',   '第一原理PM・進捗管理・スコープ削減',       '統括', 'subagent', '',                          '~/agent/elon-pm.md', 'shizuka', 1),
  ('hermes',  'opencode', 'へルメス', 'タスク分解統合・スキル選定',              '統括', 'subagent', 'opencode-go/deepseek-v4-flash', '~/.config/opencode/agents/hermes.md',  'shizuka', 1),
  ('mito',    'opencode', 'ミト',     'タイムボックス・時管理',                  '統括', 'all',      '',                          '~/.config/opencode/agents/mito.md',    'shizuka', 1),

  ('ryoma',    'opencode', '竜馬',    '設計・複雑デバッグ（最高品質）',          '開発', 'subagent', 'opencode-go/grok-4.5',      '~/.config/opencode/agents/ryoma.md',   'hermes', 1),
  ('musashi',  'opencode', '武蔵',    'コーディング・実装（主力）',              '開発', 'subagent', 'opencode-go/kimi-k3',       '~/.config/opencode/agents/musashi.md', 'ryoma', 1),
  ('ren',      'opencode', 'レン',    '再命名・名前整合',                        '開発', 'subagent', '',                          '~/.config/opencode/agents/ren.md',     'musashi', 1),
  ('takuboku', 'opencode', '啄木',    '軽量読取・調査',                          '開発', 'subagent', '',                          '~/.config/opencode/agents/takuboku.md','hermes', 1),

  ('benkey',  'opencode', '弁慶',     '装備品台帳 soubi.db（道具管理）',          '資産・守り', 'subagent', 'opencode-go/grok-4.5', '~/.config/opencode/agents/benkey.md', 'shizuka', 1),
  ('yoshida', 'opencode', '吉田松陰', '接続管理 + セキュリティ監査',              '資産・守り', 'subagent', '',                   '~/.config/opencode/agents/yoshida.md','shizuka', 1),
  ('nyuro',   'opencode', 'にゅろ',   '索引・孤児検出・生成物管理',               '資産・守り', 'subagent', '',                   '~/.config/opencode/agents/nyuro.md',  'benkey', 1),
  ('kimura',  'opencode', '木村',     'ゴミ・不要物掃除',                        '資産・守り', 'subagent', '',                   '~/.config/opencode/agents/kimura.md', 'nyuro', 1),
  ('goemon',  'opencode', '五右衛門', 'メール処理・整理',                        '資産・守り', 'subagent', '',                   '~/.config/opencode/agents/goemon.md', 'shizuka', 1),

  ('tsubame', 'opencode', 'つばめ',   'Wi-Fi追跡・在宅判定',                     '監視・助言', 'subagent', '',                   '~/.config/opencode/agents/tsubame.md','shizuka', 1),
  ('buffett', 'opencode', 'バフェット','投資価値評価',                           '監視・助言', 'subagent', '',                   '~/.config/opencode/agents/buffett.md','shizuka', 1),
  ('elon',    'opencode', 'イーロン', '第一原理思考',                            '監視・助言', 'subagent', '',                   '~/.config/opencode/agents/elon.md',   'shizuka', 1),
  ('jobs',    'opencode', 'ジョブズ', 'デザインディレクション',                  '監視・助言', 'subagent', '',                   '~/.config/opencode/agents/jobs.md',   'shizuka', 1),
  ('utaki',   'opencode', 'ウタキ',   '長期ビジョン',                           '監視・助言', 'subagent', '',                   '~/.config/opencode/agents/utaki.md',  'shizuka', 1);

-- 委譲関係
INSERT OR REPLACE INTO delegations(from_agent, to_agent, kind, note) VALUES
  ('shizuka', 'hermes',   'task',     '複雑タスクは分解してから配分'),
  ('shizuka', 'takuboku', 'task',     '読み取り・git確認・軽量調査'),
  ('shizuka', 'musashi',  'implement','コード生成・実装'),
  ('shizuka', 'ryoma',    'design',   '設計・複雑デバッグ'),
  ('ryoma',   'musashi',  'implement','設計後に実装を委譲'),
  ('hermes',  'ryoma',    'design',   '分解後の設計は竜馬へ'),
  ('hermes',  'takuboku', 'task',     '下調べは啄木へ'),
  ('benkey',  'nyuro',    'audit',    '装備棚卸で索引と連携'),
  ('nyuro',   'kimura',   'cleanup',  '孤児検出 → 木村が削除'),
  ('yoshida', 'benkey',   'audit',    'セキュリティ監査結果を装備棚卸に反映'),
  ('musashi', 'ren',      'task',     '実装中の命名はレンへ');
