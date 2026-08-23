# COH2 World Builder 高效操作与资产图谱

本文件用于 `2p_codex_crossroads` 的连续制作。按钮像素坐标仅对应已实测的最大化窗口（约 1365 × 768）；窗口、卷展栏、相机或缩放改变后必须重新观察，语义名称始终优先于旧像素坐标。

## 一、最短操作路径

1. 从游戏根目录的资源管理器双击 `WorldBuilder_CoH_2.exe`，避免工作目录错误。
2. `Ctrl+O` 打开场景；先核对标题、场景名和全局视图。
3. gameplay 点位只在 `Object Placement` 中放置；切换 `Territory Editor` 后执行 `Add territory under new Points`，处理数必须等于新增点数，再执行 `Calculate Voronoi`。
4. 地形先用 `Terrain Height` 大笔刷建立 12–28 m 轮廓，再平滑道路和基地出口。
5. 道路先用独立地表纹理层画底，再用 `Spline > Texture` 铺正式道路。
6. 建筑按同一资源目录批量放置；墙、林篱和栅栏改用 `Spline > Object`，不要逐段摆放。
7. 每完成点位、地形、建筑、边界中的一个批次，使用 `File > Save As` 写入新版本，关闭重开后再进入下一批。

## 二、按钮与调用位置

| 功能 | 调用入口 | 当前实测位置/快捷键 | 用途与硬校验 |
| --- | --- | --- | --- |
| 打开 | `File > Open` | `Ctrl+O` | 打开后核对标题栏 basename |
| 保存 | 顶栏软盘 | 约 `(94,63)` | 仅在按钮启用且无后续错误模态时算成功 |
| 另存为 | `File > Save As` | `File` 约 `(17,40)`，菜单项约 `y=224` | 当前旧版编辑器可靠的结构规范化写入方式 |
| Object Placement | 顶部对象工具 | 约 `(289,64)` | 右侧树双击叶节点，地图上右键放置；左拖移动，`Shift+左拖` 旋转，`C+拖动` 复制 |
| Terrain Height | 顶部高度工具 | 约 `(363,64)` | 大笔刷塑造高差；LMB 抬高，RMB 平滑；道路坡面以平滑优先 |
| Territory Editor | 顶部 TER 工具 | 约 `(661,64)` | 显示分区色块、建立新 sector、计算 Voronoi |
| Calculate Voronoi | Territory 右栏 | 约 `(1288,132)` | 19 个 creator 全部处理后计算；全图必须出现 19 个可辨分区 |
| Add territory under new Points | Territory 右栏 | 约 `(1288,167)` | 返回处理数是点位落地的硬断言 |
| 分区色显示 | 顶部/Overlay | `Ctrl+F5` | 验收分区辨识度；不能用普通地表颜色替代 |
| 可玩区边界 | `Overlay > Toggle Show Playable Area` | 菜单语义导航 | 校验所有点位、建筑和主路在可玩区内 |
| 对象可见性 | 顶部 `OBJ` | 语义按钮 | 批量放置后看不到模型时先检查此项，禁止重复放置 |
| 雾 | 顶部 `Fog` | 语义按钮 | 灰盒和全局验收时关闭 |
| Texture Spline | 顶部 Spline → `Modes > Texture` | 右键连续落控制点，`Enter` 完成 | `Space` 编辑控制点；`Shift+右键` 调宽；改宽后 `Fix tiling to Width` |
| Object Spline | 顶部 Spline → `Modes > Object` | 同上 | 墙、栅栏、林篱；开启 `Wall Mode` 和 `Adjustable to Terrain`；必须留步兵与车辆缺口 |

## 三、对象树定位规则

- 正式地图物件统一从 `ebps` 放置，不再使用灰色占位方块。
- gameplay：`ebps/environment` 之外的 `ebps/gameplay`，包含出生包、资源点、VP、blocker。
- 环境建筑：`ebps/environment/art_ambient/buildings/ardenes_rural/buildings`。
- 环境小物件：`ebps/environment/art_ambient/objects`。
- 植被：`ebps/environment/art_nature`。
- 编辑模式切换会重置对象树位置；每次切回 Object Placement 都重新展开并双击叶节点，不复用旧行坐标。

## 四、已由本机归档验证的正式资产

以下路径去掉了归档中的 `attrib/` 前缀和 `.rgd` 后缀，可直接对应 World Builder 的 EBP 树。

### 建筑：统一使用 Ardennes Rural 视觉语言

- `ebps/environment/art_ambient/buildings/ardenes_rural/buildings/stone02_church_4x5x3_03/stone02_church_4x5x3_03`：教堂地标，只放 1 栋，远离中央 VP 和基地射界。
- `.../stone02_barn_3x3x2_01/stone02_barn_3x3x2_01`：农庄主仓。
- `.../stone01_4x3x2_01/stone01_4x3x2_01`、`stone01_4x3x2_02`：大型石屋/街角体量。
- `.../stone02_2x2x2_01/stone02_2x2x2_01`：小型石屋。
- `.../plaster01_2x2x2_01/02`、`plaster01_2x2x3_01`：小镇基础住宅。
- `.../plaster01_3x3x3_01/02/03/04`：较大住宅和街道界面。
- `.../plaster02_2x2x2_01/plaster02_2x2x2_01`：立面变化。
- `.../multisub_3x3x2_01/02/03`、`multisub_3x3x3_01/02/03`：镇中心复合体量，少量使用。
- `.../wood01_house_2x3x2_01/wood01_house_2x3x2_01`：外围木屋。
- `.../wood01_shed_1x1x1_01`、`1x2x1_01/02`、`2x2x2_01`、`2x3x2_01`：院落附属建筑。

### 战斗边界与装饰

- 石墙：`ebps/environment/art_ambient/objects/walls/stone/stone_low_rough`、`rough_m_01`、`rough_m_gate_01`、`ruinedwall_01..05`。
- 乡村栅栏：`ebps/environment/art_ambient/objects/walls/wood/farmfence_01/02`、`fieldfence_01`、`fieldfence_gate_01/02`、`old_world_low_horizontal_fence_01/02`。
- 林篱：`ebps/environment/art_nature/hedgerow/wild_hedge_01..04`。
- 果园：`ebps/environment/art_nature/trees_s/orchard_s_ardennes_01_summer`。
- 高树：`ebps/environment/art_nature/trees_l/elm_01/02/03`；小树使用 `trees_s/elm_s_01_summer..05_summer`。
- 灌木行：`ebps/environment/art_nature/bushes/bush_row_01_summer..04_summer`。
- 农场小物：`objects/farm_features/hay_bail_square`、`haystack_m_01`、`plow_01`、`tractor_01`、`wood_trough`。
- 镇区小物：`objects/market/crates_wood_l_01`、`milk_canisters_01`、`stand_01/04`、`wagon_01..04`。
- 车辆陈设：`objects/vehicles/civilian/belgian_farm_truck`、`objects/vehicles/farm/old_world_single_axle_horse_cart`。

## 五、本地图批量放置坐标

完整清单以 `workspace/maps/2p_codex_crossroads/european-town-asset-plan.json` 为唯一数据源。地图坐标使用中心原点的 `(x,z)`。

- 中央小镇：`x=-50..50, z=-60..60`；主路 `x≈0` 保持至少 12 m 连续车辆宽度；中央 VP 周围 16 m 禁止建筑。
- 西北教堂与住宅组团：教堂 `(-46,46)`，住宅沿西侧街界布置，形成可读天际线但不覆盖左侧 cutoff。
- 东南农庄组团：农仓、石屋和棚屋围合院落，与西北组团形成 180° 机会对称，不做视觉镜像。
- 西路林篱：围绕 `x≈-110` 形成短段错列边界，每段之间保留 8–14 m 缺口。
- 东路果园：围绕 `x≈105` 采用 4–5 行疏果树；车辆乡道和步兵横穿口必须同时存在。
- 区域交界：用“地表材质变化 + 短墙/篱笆 + 高差折线”三件套表达，不允许连续硬墙沿 sector 边界封死。

## 六、欧洲小镇生态验收

- 从全局视图能在 3 秒内辨认：左侧林篱农路、中央教堂小镇、右侧果园乡道、南北两处农庄坡地。
- 地形必须存在 12–28 m 的可见高差；中心为低鞍部，西南/东北为主起伏，基地出口和主车辆道坡度平缓。
- 建筑群必须由主建筑、附属棚屋、院墙/篱笆、农具/市场小物和相邻地表共同组成，禁止孤零零“撒房子”。
- 每个 VP、油点、cutoff 至少两个进攻方向；区域交界应清晰但可穿越。
- 高差、教堂或驻防建筑不得形成压制基地出口或覆盖唯一通路的强点。
- 最终必须提供普通全局视图、领地色块全局视图和游戏内 1v1 证据；编辑器截图不能代替运行验收。

## 七、2026-08-23 实机迭代加速规则

- 分区重建固定顺序：最大领地笔刷覆盖可玩区并 Paint Null，执行 `Add territory under new Points`，再 `Calculate Voronoi`；本图应得到 19 个独立 sector。游戏内战术图必须显示完整白色边界和彩色阵营边界。
- `RelicCoH2.exe` 运行时会锁定目标 `.sga`。每次重新封包前先退出游戏进程，再用 `Archive.exe` 构建；构建成功后重新启动 1v1 房间。
- 高度笔刷最大有效范围约 64。基地平台用高 Feather 的 `Set Value` 重叠平铺，覆盖 HQ、初始单位、出口和第一段主路；再用 RMB Smoothing 沿拼缝和坡脚过渡。禁止用孤立抬升/压低笔触制造基地盆地。
- 高差验收必须看两端出生相机：HQ 所在平面、可见出口、通往第一领地点的连续坡面都要清楚；近景山脊若遮住 HQ 或单位出口，即使战术图连通也不通过。
- 正式资产批量流程：完整 bundle 备份 → 从当前 `.sgb` 中复用已验证官方 EBP chunk → JSON 坐标审查 → 更新实体 ID 与 enclosing FOLD 长度 → World Builder 重开保存 → 封包 → 实机复验。任何一步出现占位 cube、重复 gameplay creator 或路径受阻都回退备份。
- 小镇密度不能只按“建筑数量”判断。实机相机内必须同时看到街道界面、主建筑、至少一个附属棚屋/院落元素和植被；中央 VP 16 m 净空与 12 m 车辆通道优先于填满空地。
