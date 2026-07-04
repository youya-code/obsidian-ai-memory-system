# 踩坑记录

在 Windows 11 上搭建这套系统时踩过的坑，按出现频率排序。

## 坑 1：MCP 连接不上

**现象**：Claude Code 中看不到 `mcp__obsidian__*` 工具，或调用时报 `ECONNREFUSED 127.0.0.1:27124`。

**按顺序排查**：

1. **Obsidian 是否正在运行？** ← 80% 是这个原因。Local REST API 是 Obsidian 内部插件，Obsidian 关了服务就停了。
2. Local REST API 插件是否安装并启用？
3. 端口号是否一致？默认 27124，检查 `settings.json` 和插件设置
4. Windows 防火墙可能拦截：首次启动时弹窗，点击"允许访问"
5. 端口冲突：`netstat -ano | findstr 27124` 检查
6. API 密钥：如果插件设置了 API Key，`settings.json` 也需要对应配置

## 坑 2：认证问题

**现象**：`list_notes` 能列出笔记，但 `create_note` 或 `update_note` 失败。

**解决**：`settings.json` 中统一使用 `127.0.0.1`，不要用 `localhost`。

```json
{
  "url": "http://127.0.0.1:27124/mcp"
}
```

## 坑 3：工具名对不上

**现象**：在 prompt 中写了"搜索笔记"，但 Claude 说找不到对应工具。

**原因**：MCP 工具的真实名称带 `mcp__obsidian__` 前缀。

**常用工具**：

| 真实名称 | 你想的可能 |
|----------|-----------|
| `mcp__obsidian__search` | search_notes |
| `mcp__obsidian__search_tags` | find_by_tag |
| `mcp__obsidian__read_note` | read_note ✅ |
| `mcp__obsidian__create_note` | create_note ✅ |
| `mcp__obsidian__update_note` | update_note ✅ |

## 坑 4：prepend 模式失败

**现象**：`update_note(mode="prepend")` 给已有笔记加 frontmatter 时报错。

**解决**：用 `create_note(overwrite=true)` 重新创建文件，或者首次创建时就写好 frontmatter。

## 坑 5：list_notes 不显示子文件夹

**现象**：`list_notes` 只返回根目录的 3 篇笔记，看不到 `记忆/` 文件夹。

**解决**：用 `search_tags` 按标签搜索替代 `list_notes`。标签搜索不依赖目录结构，更可靠。

## 坑 6：Windows 路径分隔符

**现象**：frontmatter 中 `E:\Projects\my-app` 解析出错。

**原因**：YAML 中 `\` 是转义字符。

**解决**：路径统一用正斜杠：

```yaml
# ❌
scope: E:\Projects\my-app

# ✅
scope: E:/Projects/my-app
```

## 坑 7：Obsidian 关闭后 MCP 不可用

这是这套方案的**前置条件**——Obsidian 必须保持运行。建议：

- 将 Obsidian 设为开机自启
- 启动后最小化到系统托盘
- 把 vault 路径固定到快速访问
