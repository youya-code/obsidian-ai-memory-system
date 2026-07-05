# 踩坑记录

在 Windows 11 上搭建这套系统时踩过的坑，持续更新。

## 坑 1：MCP 连接不上

**现象**：Claude Code 中看不到 `mcp__obsidian__*` 工具，或调用时报 `ECONNREFUSED 127.0.0.1:27124`。

**按顺序排查**：

1. **Obsidian 是否正在运行？** ← 80% 是这个原因
2. Local REST API 插件是否安装并启用？
3. 端口号是否一致？默认 27124
4. Windows 防火墙可能拦截
5. API 密钥：如果插件设置了 API Key，需要对应配置

## 坑 2：Obsidian MCP 只在当前项目可用

**现象**：在项目 A 配好了 Obsidian MCP，切到项目 B 后工具消失。

**原因**：MCP 配置只写在了单个项目的 `.claude.json` projects 节点下。

**解决**：全局注册：
```bash
claude mcp add --scope user obsidian -- npx -y obsidian-notes-mcp
```
这会将配置写入 `~/.claude.json` 全局区，所有项目共享。

## 坑 3：settings.json 被代理软件覆盖

**现象**：配好的 hook 或 MCP 配置重启后消失了。

**原因**：ccswitch 等代理软件会重写 `settings.json`。

**解决**：将 hook 等持久配置写入 `settings.local.json`，该文件不会被覆盖。

## 坑 4：Obsidian REST API 中文乱码

**现象**：用 `curl -d` 直接上传中文内容，Obsidian 中显示乱码。

**解决**：用 `--data-binary "@file"` 先写本地文件再上传：
```bash
curl.exe -sk -X PUT -H "Authorization: Bearer <key>" --data-binary "@local_file.md" "https://127.0.0.1:27124/vault/path/to/note.md"
```

## 坑 5：Windows 路径分隔符

**现象**：frontmatter 中 `E:\Projects\my-app` 解析出错。

**原因**：YAML 中 `\` 是转义字符。

**解决**：路径统一用正斜杠：`E:/Projects/my-app`

## 坑 6：Obsidian 关闭后 MCP 不可用

这是这套方案的**前置条件**——Obsidian 必须保持运行。建议将 Obsidian 设为开机自启。
