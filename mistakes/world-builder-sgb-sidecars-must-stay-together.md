# World Builder 只同步 `.sgb` 导致打开时崩溃

## 基本信息

- 日期：2026-08-19
- 分类：environment / delivery / world-builder
- 关联需求：`2p_codex_crossroads` 本地继续开发

## 客观事实

- 仓库工作副本包含 `.sgb`、`.info`、`.options`、`.scenariomarker`、`_ID.scar`、战术地图等完整场景文件。
- World Builder 的 `CoH2\Data\Scenarios` 目录最初只有 `2p_codex_crossroads.sgb`。
- 编辑器日志已识别并开始打开 `.sgb`，随后因找不到同目录的 `2p_codex_crossroads.info` 退出，错误码为 `1129468744`。
- 将仓库中现有的同名配套文件补齐后，同一 `.sgb` 成功打开。

## 原因判断

- 同步流程把 `.sgb` 错当成可独立交付的地图源文件，没有把场景配套文件视为一个不可拆分的 bundle。

## 修复与验证

- 新增 `scripts/sync-map-scenario.ps1`，在复制前验证完整文件集。
- 默认只安装缺失文件；目标存在不同内容时拒绝覆盖，必须显式使用 `-Overwrite`。
- 修复后 World Builder 标题显示 `2p_codex_crossroads.sgb`，未再触发 BugSplat。

## 防呆清单

- [ ] 同步前是否验证 `.sgb` 与 `.info` 同时存在？
- [ ] 是否同时检查 `.options`、`.scenariomarker`、`_ID.scar` 与战术地图产物？
- [ ] 目标中已有不同文件时是否停止并确认覆盖？
- [ ] 是否用 World Builder 真实打开，而不只检查文件存在？
