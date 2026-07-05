# 自动初始化机制

新项目首次打开 Claude Code 时，SessionStart hook 自动创建记忆基础设施。

## 工作原理

```
Claude Code 启动
  → SessionStart hook 触发
    → auto-memory-init.ps1
      ├─ 检查 .claude/projects/<sanitized>/memory/MEMORY.md 是否存在
      ├─ 已存在 → 跳过
      └─ 不存在 → 自动创建：
           ├─ MEMORY.md 指针文件（含项目名、技术栈、git remote）
           └─ Obsidian 记忆/<项目名>/（3个模板文件）
```

## 配置方式

在 `~/.claude/settings.local.json` 中（不是 settings.json，避免被 ccswitch 覆盖）：

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "powershell -ExecutionPolicy Bypass -File C:/Users/<你的用户名>/.claude/hooks/auto-memory-init.ps1"
          }
        ]
      }
    ]
  }
}
```

## 脚本部署

将 `scripts/auto-memory-init.ps1` 复制到 `~/.claude/hooks/` 目录：

```powershell
cp scripts/auto-memory-init.ps1 ~/.claude/hooks/
```

## 脚本功能

1. 自动检测当前项目路径，计算 Claude Code 的 sanitized 名称
2. 检查 memory/MEMORY.md 是否已存在，存在则跳过
3. 首次创建 MEMORY.md 指针（含项目名称、自动检测的技术栈、git remote）
4. 在 Obsidian 中创建 `记忆/<项目名>/` 文件夹及 3 个模板文件
5. 全局作用域（用户目录）不会触发，避免多余操作
