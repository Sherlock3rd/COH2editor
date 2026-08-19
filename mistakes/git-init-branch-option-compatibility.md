# 旧版 Git 不支持 init -b

## 基本信息

- 日期：2026-08-19
- 分类：environment / git
- 关联需求：首次提交 `Sherlock3rd/COH2editor`

## 客观事实

- 本机 Git 的 `git init` 不支持 `-b` 参数。
- 首次尝试因此退出，未创建仓库、提交或远端变更。

## 修复

- 使用 `git init` 初始化。
- 再用 `git symbolic-ref HEAD refs/heads/main` 将初始分支设为 `main`。
- 完成远端、身份和 Git LFS 配置后重新核对状态。

## 防呆

- 在旧版 Windows Git 环境中，不假设 `git init -b <branch>` 可用。
- 需要兼容初始化时，优先使用 `git init` 加 `git symbolic-ref`。
