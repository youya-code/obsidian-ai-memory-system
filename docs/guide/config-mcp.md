# 第二步：配置 MCP 连接

## 什么是 MCP？

MCP（Model Context Protocol）是 Claude Code 与外部工具通信的协议。通过配置 Obsidian MCP 服务，Claude 可以直接读写你的 Obsidian 笔记。

## 配置文件

编辑 Claude Code 的设置文件：

| 系统 | 路径 |
|------|------|
| Windows | `C:\Users\<用户名>\.claude\settings.json` |
| macOS / Linux | `~/.claude/settings.json` |

如果文件不存在，新建即可。

## 配置内容

```json
{
  "mcpServers": {
    "obsidian": {
      "type": "http",
      "url": "http://127.0.0.1:27124/mcp",
      "headers": {
        "Content-Type": "application/json"
      }
    }
  }
}
```

::: warning 关键照
- 端口号 `27124` 必须与 Obsidian 中 Local REST API 插件的端口**完全一致**
- 如果你在插件设置中修改了端口，这里也要对应修改
- 建议使用 `127.0.0.1` 而不是 `localhost`（Windows 下更稳定）
:::

## 验证连接

1. **确保 Obsidian 正在运行**
2. 重启 Claude Code（或开启新对话）
3. 检查工具列表是否出现了 `mcp__obsidian__*` 系列工具

如果看不到，参考 [踩坑记录 - MCP 连接不上](/guide/pitfalls#坑-1-mcp-连接不上)。

## 可用的 MCP 工具

连接成功后，Claude Code 获得以下工具：

| 工具名 | 功能 |
|--------|------|
| `mcp__obsidian__search` | 全文搜索（支持上下文） |
| `mcp__obsidian__search_tags` | 按标签搜索笔记 |
| `mcp__obsidian__search_frontmatter` | 按 frontmatter 字段搜索 |
| `mcp__obsidian__read_note` | 读取笔记（支持 `section` 和 `maxChars`） |
| `mcp__obsidian__create_note` | 创建新笔记 |
| `mcp__obsidian__update_note` | 更新笔记（`append`/`replace`） |
| `mcp__obsidian__batch_create` | 批量创建笔记 |
| `mcp__obsidian__batch_read` | 批量读取笔记 |
| `mcp__obsidian__delete_note` | 删除笔记（需确认） |
| `mcp__obsidian__list_notes` | 列出笔记 |
| `mcp__obsidian__vault_stats` | vault 统计信息 |

## 下一步

MCP 连接成功后，进入 [第三步：创建记忆体系](/guide/create-memory-system)。
