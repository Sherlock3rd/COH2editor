# COH2 项目执行入口

## 规则优先级

- 执行本项目任务前，先完整读取 `rules/rules.md`。
- 开始任务前，先检索 `mistakes/`；若无相关记录，再检索 `D:\charlie\Workbencch\mistakes\`。
- 基础规则源为 `spec/rules-bootstrap-spec.md`；通用规则更新以 `D:\charlie\Workbencch\spec\rules-bootstrap-spec.md` 最新版本为准。
- 当前用户角色默认为“游戏系统策划”，助手角色默认为“策划工具开发助手”。
- 自动记忆仅作补充，不覆盖本文件、`rules/rules.md` 或用户当前书面指令。

## 沟通与变更

- 默认使用简体中文，所有回复以 `you majesty` 开头。
- 不确定事项不得主观臆断；仅当不同选择会实质改变设计结果时向用户确认。
- 设计、交互意图、命名规则或产出格式的变更必须先获得用户书面确认。
- 文档、脚手架、目录结构和不影响设计的环境配置可直接执行，并记录到 `session/session.md`。

## COH2 World Builder 知识路由

- 研究、规划、制作或验收 COH2 多人地图时，使用 `skills/coh2-world-builder/SKILL.md`。
- 项目级完成标准以 `spec/coh2-world-builder/index.md` 及其子规范为准。
- 不得把空白地形、自动生成出生位、单独 `.sgb` 保存或仅编辑器检查称为“可玩地图”。
- 宣称地图可玩前，必须完成 `spec/coh2-world-builder/acceptance-spec.md` 中的编辑器、产物和游戏内 1v1 验收。
