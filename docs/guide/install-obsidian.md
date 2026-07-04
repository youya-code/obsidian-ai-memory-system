# 第一步：安装 Obsidian

## 下载安装

Obsidian 是完全免费的本地 Markdown 笔记软件。

[下载 Obsidian](https://obsidian.md/download)

| 平台 | 安装方式 |
|------|---------|
| **Windows** | 下载 `.exe` 双击安装，或 `winget install Obsidian.Obsidian` |
| **macOS** | 下载 `.dmg`，或 `brew install --cask obsidian` |
| **Linux** | 下载 AppImage，或 `flatpak install md.obsidian.Obsidian` |

## 创建 Vault

首次启动 Obsidian 后，选择一个文件夹作为你的 **Vault（知识库）**。

建议放在一个安全、不会被误删的位置：

- Windows: `D:/ObsidianVault` 或 `~/Documents/ObsidianVault`
- macOS: `~/Documents/ObsidianVault`

## 安装必需插件

`Local REST API` 插件是让 Claude Code 能读写 Obsidian 的核心桥梁。

**安装步骤**：

1. 打开 Obsidian
2. 进入 **设置** → **第三方插件**
3. 如果提示"安全模式"，点击**关闭安全模式**
4. 点击 **浏览（Browse）**
5. 搜索 `Local REST API`
6. 找到作者为 `coddingtonbear` 的插件，点击**安装**
7. 安装完成后点击**启用**
8. 进入插件设置，确认端口为 **27124**（默认）

## 推荐插件

这些插件非必需，但强烈推荐：

| 插件 | 用途 | 为什么推荐 |
|------|------|-----------|
| **Dataview** | 按标签、字段查询笔记 | 配合 frontmatter 使用，帮你管理记忆库 |
| **Tag Wrangler** | 批量管理标签 | 标签多了以后重命名和合并很方便 |
| **Periodic Notes** | 日记、周记模板 | 配合记忆系统做时间线记录 |

## 下一步

安装完成后，进入 [第二步：配置 MCP 连接](/guide/config-mcp)。
