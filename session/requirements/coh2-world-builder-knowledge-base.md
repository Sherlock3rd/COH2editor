# COH2 World Builder Skill/Spec 知识库

## 需求

- 用户要求先建立对应的 Skill 库和 Spec 库，整理 COH2 World Builder 快速制作与可玩地图相关内容。
- 允许检索 GitHub 是否存在可复用资料。

## 范围

- 本地 Skill：`skills/coh2-world-builder/`。
- 项目 Spec：`spec/coh2-world-builder/`。
- 项目入口、术语表、错误记录与总控会话的知识路由。
- 只读检索公开资料；本次不克隆第三方仓库，不执行远端写入。

## 已完成

- 建立 Skill 入口、UI 元数据、来源索引、快速灰盒流程、编辑器操作参考与玩法对象目录。
- 建立可玩 1v1、快速生产和验收规范。
- 记录“空白骨架被误报为可玩地图”的错误与防呆清单。
- 将 Skill/Spec 接入项目 `AGENTS.md`、`rules/rules.md` 与术语表。
- GitHub 检索未发现可直接采用的 Codex Skill 或完整自动地图生成器；相关局部资料已记录在 Skill 来源索引。

## 关键决定

- Skill 负责“如何做”，Spec 负责“什么算完成”。
- 地图必须先完成可玩灰盒，再进入美术细化。
- 编辑器、构建产物和真实游戏运行是三层独立证据。
- 未完成实际 1v1 AI 对局验收时，不得宣称地图可玩。
- 当前仅保存在 `D:\charlie\COH2`，未注册为全局 Codex Skill，也未推送 GitHub/GitLab。

## 继承指引

- 后续地图任务先读取 `skills/coh2-world-builder/SKILL.md`，再按任务类型读取对应 reference。
- 完成声明前逐项执行 `spec/coh2-world-builder/acceptance-spec.md`。
- 若要远端发布 Skill，必须先书面确认使用个人 GitHub/origin 还是公司 GitLab/company。

## 状态

- 状态：完成。
- 日期：2026-08-19。
