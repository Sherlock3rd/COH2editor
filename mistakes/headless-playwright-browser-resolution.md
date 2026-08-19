# 后台可视化渲染的 Playwright 浏览器与 iframe 定位

## 基本信息

- 日期：2026-08-19
- 分类：environment / visualization
- 关联需求：COH2 地形与分区平面图

## 客观事实

- 已安装 Playwright Node 包，但其默认 Chromium 可执行文件不存在，首次后台截图无法启动。
- 改用本机 Microsoft Edge 后，首次等待顶层页面中的地图节点超时；渲染器实际把可视化放在 sandbox iframe 内。

## 修复

- 后台截图显式使用已安装的 Edge `executablePath`，不启动前台窗口。
- 查询地图节点、尺寸与交互时切换到渲染器生成的 iframe。
- 为稳定检查，将允许的 D3 CDN 脚本缓存到临时可视化目录并仅在测试请求中本地响应。

## 防呆

- 使用 Playwright 前同时检查 Node 包和浏览器可执行文件，不能只检查包是否存在。
- 使用可视化渲染器生成的 standalone 文件时，先检查是否由 iframe 承载内容。
- 后台截图避免无限等待 `networkidle`；等待明确的地图节点数量和交互状态。
