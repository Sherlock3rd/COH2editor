# 需求会话：2p_codex_crossroads 地图制作

## 状态

- 状态：G0 进行中；错误尺寸场景已备份并重建，尚未完成重开复核和 G1–G7。
- 日期：2026-08-19。

## 用户要求

- 在后台继续制作地图，不抢占鼠标。
- 将 `Sherlock3rd/COH2editor` 拉取到当前工作区并继续开发。
- 用户指出当前开发地图位于本机 COH2 `CoH2\Data\Scenarios`，且本地打开失败。
- 用户要求将本次制作迟缓的反思、全部操作方法和完成标准沉淀到 Skill 与 Spec。

## 执行边界

- 本轮已按用户继续开发要求启动并后台检查 World Builder；不修改创意工坊订阅地图。
- 只补齐正式场景缺失的同名配套文件，不覆盖现有 `.sgb`。
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
- 按用户要求继续完成包含等高线、点位、19 个规划分区、补给连接和欧洲乡村氛围的平面设计。
- 从远端灰盒交付分支恢复真实场景 bundle，并验证 Git LFS 文件完整。
- 定位本地打开崩溃原因为安装目录缺少 `.info` 等同名配套文件；补齐后成功打开。
- 新增安全同步脚本，默认只补缺失文件，拒绝静默覆盖不同内容。

## 未完成与阻断原因

- 原 `.info` 地图尺寸为 `160 x 128`，用户已授权快速重建；原 bundle 已备份，新场景已保存为 `384 x 384` 地形、`320 x 320` 可玩区。
- 新场景尚未完成关闭并重开复核，因此不能把 G0 标为通过。
- sector polygon、起始包赋权、交互边界、路径网格仍需在 World Builder 中生成或录入。
- 未完成真实游戏内 1v1 AI 验收，不得称为可玩地图。

## 继承指引

- 后续同步场景时先运行 `scripts/sync-map-scenario.ps1`，不得只复制 `.sgb`。
- 录入前先确认正式场景名，并核对 World Builder 坐标原点。
- 按已确认的 `384 x 384` 地形、`320 x 320` 可玩区继续，不再沿用原 `160 x 128` 布局。
- 完成后逐项执行 `spec/coh2-world-builder/acceptance-spec.md`。
- 后续实施必须先读 `skills/coh2-world-builder/references/end-to-end-operations.md`，并使用 `spec/coh2-world-builder/production-gates-spec.md` 的 G0–G7 报告进度。
