# Beagle 专有名词术语表

## 使用说明

- 本文件按基础规范建立，作为项目术语的单点引用。
- 当前尚无已确认的 COH2 项目术语，不预填未经确认的定义。
- 后续新增术语时，记录术语、定义、使用场景和关键流程链接。

## 术语

| 术语 | 定义 | 使用场景 | 关键流程链接 |
| --- | --- | --- | --- |
| World Builder | COH2 随游戏安装的地图编辑器，当前入口为 `WorldBuilder_CoH_2.exe` | 地图创建、编辑与检查 | [工作区指南](workspace-guide.md#已识别的本机入口) |
| 地图工作副本 | 放入本项目 `workspace/maps/`、用于分析或修改的地图副本；不等同于游戏目录中的原文件 | 避免直接覆盖源地图 | [目录约定](workspace-guide.md#目录约定) |
| 用户地图目录 | COH2 用户数据下的 `mods/scenarios` 目录，可能包含本地或订阅地图 | 定位地图来源与运行时数据 | [工作区指南](workspace-guide.md#已识别的本机入口) |
| 生成产物 | 助手生成的报告、预览和临时导出，统一放入 `artifacts/` | 分离源数据与可重建文件 | [目录约定](workspace-guide.md#目录约定) |
| 可玩灰盒 | 已具备双方开局、领地补给、资源与 VP、有效路径，并通过实际游戏加载验证的最低美术地图版本 | 在美术细化前验证核心对局结构 | [1v1 地图规范](../spec/coh2-world-builder/playable-1v1-map-spec.md) |
| 起始包 | World Builder 为一名玩家生成的一组起始领地、基地上下文、进入点及队伍对象，移动时应保持整体关系 | 配置双方出生与基地 | [对象目录](../skills/coh2-world-builder/references/gameplay-object-catalog.md#player-setup) |
| 补给链 | 从己方 HQ 经相邻己方领地连接到资源点的领地网络；断开后资源收益受影响 | 设计领地、资源与 cutoff | [1v1 地图规范](../spec/coh2-world-builder/playable-1v1-map-spec.md#目标与经济) |
| cutoff | 能切断一段重要补给链、但仍应存在可反制路径的关键领地点 | 构造战略争夺与侧翼价值 | [1v1 地图规范](../spec/coh2-world-builder/playable-1v1-map-spec.md#目标与经济) |
| 运行验收 | 在 COH2 自定义 1v1 对局中与 AI 实际加载地图并验证开局、占点、VP 和路径 | 证明地图真正可玩 | [验收规范](../spec/coh2-world-builder/acceptance-spec.md#c-游戏内-1v1-验收) |
