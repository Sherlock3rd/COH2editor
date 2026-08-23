# 2p_codex_crossroads

这是 COH2 1v1 欧洲小镇战斗地图。当前 World Builder/运行时 basename 为 `2p_codex_crossroads_rebuild`；仓库 `scenario/2p_codex_crossroads.sgb` 与本机最终源 `.sgb` 内容完全一致，`package/2p_codex_crossroads_rebuild.sga` 是 2026-08-23 实机验收使用的封包。

## 当前状态

- 已完成双人起始包、两端基地领地和 entry point；实机双方都能离开基地。
- 已完成 19 个连续领地区、3 VP、2 油、2 弹药、10 个普通领地点；实机战术地图显示边界与双方颜色，AI 能连续占领至中路 VP。
- 已完成三路骨架和约 4–28 m 的可读高差；东南基地平台与出口已在实机中重新整平。
- 已用正式 `ardenes_rural` 石屋、灰泥住宅、农仓、木棚、林篱和树列建立中央小镇及区域交界；没有占位方块。
- 已通过 `.sga` 载入、开局、HQ/单位生成、占领、资源图标和 VP 计分冒烟验收。
- 尚未完成中型车辆全路线和交换人工出生侧的完整 G7 长局测试，因此不把当前版本标成最终平衡版。

## 文件

- `layout.json`：灰盒规划数据。
- `graybox-blueprint.svg`：俯视规划图。
- `terrain-sector-plan.json`：等高线、分区、补给连接与氛围方向数据。
- `terrain-sector-masterplan.png`：包含等高线、点位、规划分区和补给关系的总平面预览。
- `acceptance-progress.md`：按项目验收规范记录的当前进度。
- `scenario/`：World Builder 实际保存并同步出的场景源文件与基础生成产物。
- `package/2p_codex_crossroads_rebuild.sga`：本轮实机验收所用可安装封包。
- `checksums.sha256`：最终源、仓库 `.sgb` 与实机 `.sga` 的哈希证明。

![2p_codex_crossroads 地形与分区总平面](terrain-sector-masterplan.png)

## 2026-08-23 交付状态

最终源 bundle 已从游戏目录回同步，`.sgb` 与本机源 SHA-256 完全一致；`.sga` 也与本机实际加载文件完全一致。验收截图位于仓库 `artifacts/runtime-tactical-final.jpg` 与 `artifacts/runtime-base-final.jpg`。
