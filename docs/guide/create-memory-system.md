# 第三步：创建记忆体系

## 架构回顾

在开始之前，回顾一下三层结构：

```
CLAUDE.md（项目入口）
  → .claude/memory/MEMORY.md（指针层，~50 字）
    → Obsidian 记忆/<项目>/（数据层，你维护内容）
```

## 步骤 1：在 Obsidian 中创建记忆文件夹

在 Obsidian vault 中建立如下结构：

```
记忆/<你的项目名>/
├── 项目约定.md
├── 踩坑记录.md
└── 偏好设置.md
```

每篇笔记必须打上 frontmatter 标签：

```yaml
---
tags: [memory, <项目名>]
project: <项目名>
---
```

## 步骤 2：更新项目 CLAUDE.md

在项目根目录的 `CLAUDE.md` 中添加一段：

```markdown
## 知识库

项目知识与记忆在 Obsidian vault 中：
- 知识笔记标签：`[knowledge, <项目名>]`
- 项目记忆标签：`[memory, <项目名>]`

查阅方式：mcp__obsidian__search_tags 检索，mcp__obsidian__read_note 读取。
项目内同名 .md 文档优先使用。
```

::: tip 提示
只写**检索方法**，不列具体笔记清单。笔记增删不需要改配置文件。
:::

## 步骤 3：创建 .claude/memory/MEMORY.md

这是 Claude Code 自动加载的指针文件，放到项目作用域下。

**路径**：`~/.claude/projects/<项目路径映射>/memory/MEMORY.md`

::: details 如何找到映射路径？

Claude Code 将工作目录路径中的特殊字符转换：

```
E:\Projects\my-app  →  E--Projects-my-app
```

完整路径为：`~/.claude/projects/E--Projects-my-app/memory/MEMORY.md`

如果不存在此目录，创建之。
:::

**内容**：

```markdown
# 记忆存储规则（本作用域：<项目路径>）

所有长期记忆写入 Obsidian，不写 .claude/memory/。

| 记忆类型 | Obsidian 路径 | 标签 |
|----------|--------------|------|
| 项目约定 | 记忆/<项目>/项目约定.md | [memory, <项目>, convention] |
| 踩坑记录 | 记忆/<项目>/踩坑记录.md | [memory, <项目>, pitfall] |
| 偏好设置 | 记忆/<项目>/偏好设置.md | [memory, <项目>, preference] |

读取：mcp__obsidian__search_tags tags: [memory, <项目>]
写入：mcp__obsidian__update_note mode="append"
规则：同类记忆追加到同一文件，不新建碎片文件
```

## 步骤 4：验证

打开项目，Claude 会自动加载上述配置。之后每次对话：

- 你问"测试怎么跑？" → Claude 自动查 Obsidian 记忆 → 返回约定
- 你说"记住：X 有个坑" → Claude 自动 append 到 Obsidian 踩坑记录
- 你问"这是什么架构？" → Claude 先查项目文档，没有再搜 Obsidian 知识笔记

## 可选：全局兜底作用域

在 `~/.claude/projects/C--Users-<用户名>/memory/MEMORY.md` 中保留全局指针：

```markdown
# 记忆存储规则（全局）

Obsidian vault 中 记忆/ 文件夹按项目隔离存放：
- 记忆/README.md — 系统说明
- 记忆/<项目>/ — 各项目记忆

通用跨项目记忆标签：[memory, global]
```

## 下一步

框架搭好了，去 [模板下载](/guide/templates) 获取现成模板即可快速上手。

## 自动初始化（推荐）

手动创建 MEMORY.md 和 Obsidian 文件夹太麻烦。推荐使用 SessionStart hook 自动化。

详见 [自动初始化机制](./auto-init.md)。
