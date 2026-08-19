# COH2 地图制作助手

本工作区用于辅助《Company of Heroes 2》地图制作、资料整理、问题诊断和交付检查。

## 快速开始

1. 复制 `config/environment.example.json` 为 `config/environment.json`，填写本机 COH2 路径；该文件默认不提交。
2. 在 PowerShell 中运行 `scripts/check-environment.ps1`，确认本机游戏、World Builder、地图目录和日志目录均可访问。
3. 运行 `scripts/sync-map-scenario.ps1`，将完整场景 bundle 安全同步到 World Builder 的 `Data\Scenarios`；默认不会覆盖不同内容。
4. 运行 `scripts/start-worldbuilder.ps1` 启动 World Builder。
5. 将自主制作地图的工作副本放在 `workspace/maps/`；外部参考资料放在 `workspace/references/`。
6. 让助手生成的报告、预览和导出文件分别进入 `artifacts/reports/`、`artifacts/previews/` 和 `artifacts/exports/`。

## 当前正式地图

- `workspace/maps/2p_codex_crossroads/`：欧洲乡村 1v1 三路地图，当前处于规划灰盒阶段，尚未完成 `.sgb` 与游戏内验收。

详细边界和目录说明见 `docs/workspace-guide.md`。

## 安全边界

- 默认只读取 COH2 安装目录、用户地图目录和日志目录。
- 未经明确要求，不改动游戏安装文件，不覆盖现有地图，不操作创意工坊订阅内容。
- 对地图规则、胜利条件、资源布局和交互逻辑的设计变更，先取得用户书面确认。
- COH2 二进制地图文件通过 Git LFS 管理；提交前仍需检查 GitHub LFS 配额和单文件大小。
- 不要只复制 `.sgb`；World Builder 打开场景时还依赖同名 `.info` 等配套文件。
