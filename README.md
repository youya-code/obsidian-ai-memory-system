# Obsidian AI Memory System

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Built with VitePress](https://img.shields.io/badge/Built%20with-VitePress-5C73E7)](https://vitepress.dev)

> 将 Obsidian 作为 AI 编程助手的外挂知识库与记忆系统 —— 可视化、可迁移、永不丢失。

**解决问题**：Claude Code 的原生记忆藏在隐藏目录里——不可见、不可控、不可迁移。这套方案把记忆存到 Obsidian，你随时浏览、编辑、同步，AI 按需检索。

## 🎯 核心优势

- **👁️ 完全可视化** — 记忆在 Obsidian 中随时看、随时改
- **🔍 按需加载** — 标签驱动检索，不浪费上下文
- **☁️ 跨机器同步** — git / Obsidian Sync，换电脑秒级恢复
- **🔒 数据主权** — Markdown 文件，不会被自动压缩
- **🚀 零维护扩展** — 新项目建文件夹 + 打标签，不改配置

## 📖 博客

完整方案介绍：[Claude Code + Obsidian：打造不会丢失的 AI 记忆系统](https://youya-code.github.io/obsidian-ai-memory-system/blog/)

## 🚀 快速开始

### 1. 安装 Obsidian + Local REST API 插件

[第一步：安装 Obsidian](https://youya-code.github.io/obsidian-ai-memory-system/guide/install-obsidian)

### 2. 配置 Claude Code 的 MCP 连接

编辑 `~/.claude/settings.json`：

```json
{
  "mcpServers": {
    "obsidian": {
      "type": "http",
      "url": "http://127.0.0.1:27124/mcp"
    }
  }
}
```

### 3. 使用模板搭建记忆体系

[模板下载](https://youya-code.github.io/obsidian-ai-memory-system/guide/templates)

```
记忆/<项目>/
├── 项目约定.md   ← 标签 [memory, <项目>, convention]
├── 踩坑记录.md   ← 标签 [memory, <项目>, pitfall]
└── 偏好设置.md   ← 标签 [memory, <项目>, preference]
```

### 4. 创建指针文件

在 `~/.claude/projects/<路径映射>/memory/MEMORY.md` 中写 50 字指针，指向 Obsidian 对应文件夹。

[完整搭建指南](https://youya-code.github.io/obsidian-ai-memory-system/guide/)

## 🏗️ 架构

```
CLAUDE.md（项目入口，只写检索方法）
  └── .claude/memory/MEMORY.md（指针层，~50字）
    └── Obsidian 记忆/<项目>/（数据层，你维护内容）
```

## 🛠️ 技术栈

- **Claude Code** — AI 编程助手
- **Obsidian** — 本地 Markdown 笔记软件
- **MCP** — Model Context Protocol，连接 Claude 与 Obsidian
- **VitePress** — 静态站点生成器（本文档站）

## 📁 项目结构

```
.
├── docs/                ← VitePress 文档站点
│   ├── .vitepress/      ← 站点配置
│   ├── index.md         ← 首页
│   ├── blog/            ← 博客文章
│   └── guide/           ← 搭建指南
├── templates/           ← 可复用的模板文件
│   ├── CLAUDE.md
│   ├── MEMORY.md.project
│   ├── MEMORY.md.global
│   └── settings.json
└── package.json
```

## 📄 License

MIT
