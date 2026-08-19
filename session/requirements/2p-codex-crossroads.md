# 需求会话：2p_codex_crossroads 地图制作

## 状态

- 状态：部分完成，等待 World Builder 录入阶段。
- 日期：2026-08-19。

## 用户要求

- 在后台继续制作地图，不抢占鼠标。

## 执行边界

- 不启动 World Builder，不操控前台窗口或鼠标。
- 不修改游戏安装目录和创意工坊订阅地图。
- 未发现可继续编辑的自有 `.sgb`，因此采用项目 Spec 的默认 1v1 参数制作独立规划试验。
- 用户已确认 `2p_codex_crossroads` 为正式地图名。
- 用户已书面确认欧洲乡村主题和默认三路布局。
- 用户指定个人 GitHub 仓库 `https://github.com/Sherlock3rd/COH2editor` 作为当前及后续实际地图的提交目标。

## 已完成

- 建立 384 x 384 地形、320 x 320 可玩区的规划数据。
- 布置双人起点、三路、3 VP、2 油、2 弹药和 10 个标准领地点。
- 使用 180 度旋转对称作为首轮灰盒机会对称基线。
- 建立 SVG 俯视图、分层验收进度和后台数据检查器。
- 完成欧洲乡村三路职责、道路、掩体、LOS、建筑风险与地表方向说明。
- 正式名称由 `2p_background_trial` 更新为 `2p_codex_crossroads`。
- 配置个人 GitHub 远端 `Sherlock3rd/COH2editor` 和 COH2 二进制 Git LFS 规则。
- 本机环境配置已排除出公开提交，并提供可复制的示例配置。
- 已将首批项目文件推送到 `Sherlock3rd/COH2editor` 的 `main` 分支。

## 未完成与阻断原因

- `.sgb`、sector polygon、起始包、交互边界、路径网格和场景产物需要 World Builder 生成或录入。
- 在保持“不抢鼠标”的约束下，本轮不进行编辑器 GUI 操作。
- 未完成真实游戏内 1v1 AI 验收，不得称为可玩地图。

## 继承指引

- 后续可由用户手动打开 World Builder，或在用户明确允许的独占时段进行 GUI 录入。
- 录入前先确认正式场景名，并核对 World Builder 坐标原点。
- 完成后逐项执行 `spec/coh2-world-builder/acceptance-spec.md`。
