# 2p_codex_crossroads

这是正式命名为 `2p_codex_crossroads` 的 COH2 1v1 灰盒地图项目。

## 当前状态

- 已完成：尺寸、双人起点、三路、3 VP、2 油、2 弹药、10 个标准领地点的数据草案。
- 已完成：点位边界、数量、双边 180 度机会对称和路线数量的后台检查。
- 已完成：首份真实 World Builder 场景保存，并生成 `.sgb`、`.info`、`.options`、`.scenariomarker`、`_ID.scar`、战术地图等基础场景文件。
- 已完成：备份原错误尺寸场景，并按确认方案新建 `384 x 384` 地形、`320 x 320` 可玩区。
- 已完成：补齐安装目录中的场景配套文件并验证 World Builder 可正常打开该 `.sgb`。
- 未完成：规划等高线细化、实际领地绘制、完整起始包、交互边界、路径网格、道路与掩体，以及游戏内对局。
- 当前按生产阶段规范为 `G0 进行中`；新场景已保存，但尚未完成关闭并重开复核。
- 未保存的资源点界面操作不计入已完成；G1 点位完整及其后阶段均未通过。

本目录已经包含可由 World Builder 打开的场景源文件，但尚未达到“可玩地图”验收。`layout.json` 使用以地图中心为原点的规划坐标；继续录入前仍需核对编辑器坐标与地形原点。

## 文件

- `layout.json`：灰盒规划数据。
- `graybox-blueprint.svg`：俯视规划图。
- `terrain-sector-plan.json`：等高线、分区、补给连接与氛围方向数据。
- `terrain-sector-masterplan.png`：包含等高线、点位、规划分区和补给关系的总平面预览。
- `acceptance-progress.md`：按项目验收规范记录的当前进度。
- `scenario/`：World Builder 实际保存并同步出的场景源文件与基础生成产物。

![2p_codex_crossroads 地形与分区总平面](terrain-sector-masterplan.png)

## 2026-08-20 交付状态

World Builder 灰盒现已具备三路道路、连续领地区、对称灰盒掩体和林带点，并通过保存、关闭、重新打开后的全局视觉复核。仓库中的 `scenario/` 是本次复核后从游戏目录回同步的完整九文件 bundle。游戏内 1v1 AI、计分与车辆寻路仍需单独完成 G7 运行时验收。
