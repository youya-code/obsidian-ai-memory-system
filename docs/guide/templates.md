# 第四步：模板下载

下面的模板可以直接复制使用。将 `<项目名>` 替换为你的实际项目名称。

## CLAUDE.md 模板

放到项目根目录，追加到已有 `CLAUDE.md` 的末尾：

```markdown
## 知识库

项目知识与记忆在 Obsidian vault 中：
- 知识笔记标签：`[knowledge, <项目名>]`
- 项目记忆标签：`[memory, <项目名>]`

查阅方式：mcp__obsidian__search_tags 检索，mcp__obsidian__read_note 读取。
项目内同名 .md 文档优先使用，Obsidian 笔记作为补充。
```

## 项目级 MEMORY.md 模板

放到 `~/.claude/projects/<路径映射>/memory/MEMORY.md`：

```markdown
# 记忆存储规则（本作用域）

所有长期记忆写入 Obsidian，不写 .claude/memory/。

| 记忆类型 | Obsidian 路径 | 标签 |
|----------|--------------|------|
| 项目约定 | 记忆/<项目名>/项目约定.md | [memory, <项目名>, convention] |
| 踩坑记录 | 记忆/<项目名>/踩坑记录.md | [memory, <项目名>, pitfall] |
| 偏好设置 | 记忆/<项目名>/偏好设置.md | [memory, <项目名>, preference] |

读取：mcp__obsidian__search_tags tags: [memory, <项目名>]
写入：mcp__obsidian__update_note mode="append"
规则：同类记忆追加到同一文件，不新建碎片文件
```

## 全局级 MEMORY.md 模板

放到 `~/.claude/projects/C--Users-<用户名>/memory/MEMORY.md`：

```markdown
# 记忆存储规则（全局）

Obsidian vault 中 记忆/ 文件夹按项目隔离存放：
- 记忆/README.md — 系统说明
- 记忆/<项目>/ — 各项目记忆

通用跨项目记忆标签：[memory, global]
```

## Obsidian 记忆笔记模板

### 项目约定.md

```yaml
---
tags: [memory, <项目名>, convention]
project: <项目名>
---

# <项目名> 项目约定

## 构建与运行
- ...

## 代码规范
- ...

## 开发流程
- ...
```

### 踩坑记录.md

```yaml
---
tags: [memory, <项目名>, pitfall]
project: <项目名>
---

# <项目名> 踩坑记录

## <坑的名称>
- 现象：
- 原因：
- 解决：

## <另一个坑>
- ...
```

### 偏好设置.md

```yaml
---
tags: [memory, <项目名>, preference]
project: <项目名>
---

# <项目名> 偏好设置

## 开发偏好
- ...

## 学习路径
- ...
```

## Obsidian MCP 配置参考

`~/.claude/settings.json`：

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

---

所有模板文件也可在 [GitHub 仓库](https://github.com/youya-code/obsidian-ai-memory-system/tree/main/templates) 中直接下载。
