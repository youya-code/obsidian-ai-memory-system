# Claude Code + Obsidian：打造不会丢失的 AI 记忆系统

> 将 Obsidian 作为 Claude Code 的外挂知识库与记忆系统，解决原生记忆机制的三大痛点：不可见、不可控、不可迁移。

## 一、问题：Claude Code 的原生记忆够用吗？

Claude Code 内置了一套记忆系统，存放在 `~/.claude/projects/<项目>/memory/` 目录下。每次对话开始时，harness 会自动将 `MEMORY.md` 注入到系统提示中，让 Claude "记住" 之前的约定和偏好。

这套机制在**单项目、轻量使用**时运转良好。但当你深入使用后，三个问题会逐渐浮现：

### 痛点 1：你不可见

记忆文件藏在 `~/.claude/` 的隐藏目录里。你很难随时浏览、编辑、重组这些记忆。每一次修改都要通过 Claude 代劳，或者手动找到路径用编辑器打开。

### 痛点 2：你不可控

所有记忆在每次对话中**全量注入上下文**。当记忆积累到几十条、上百条后，harness 会触发自动压缩——而你完全不知道哪些被压缩了、哪些被截断了。可能一条关键的踩坑记录就在某次压缩中消失了，你甚至不会察觉。

### 痛点 3：不可迁移

换了一台电脑，所有记忆归零。`.claude/` 目录不在版本控制里，也不在云同步范围内。你的项目约定、踩坑经验、偏好设置全部留在了旧机器上。

## 二、思路：把 Obsidian 变成 Claude 的外挂大脑

Obsidian 天然具备几个优势：

- **完全可视化** — 你随时可以浏览、搜索、编辑每一篇笔记
- **你拥有数据** — 文件就是本地 Markdown，不会被任何系统"压缩"或"优化掉"
- **可同步** — Obsidian Sync 或 git，换机器无缝迁移
- **可检索** — 全文搜索、标签系统、图谱视图
- **MCP 可访问** — Claude Code 通过 MCP 协议可以直接读写 Obsidian

**核心思路很简单：指针放 `.claude/memory/`，内容放 Obsidian。**

## 三、环境准备：Obsidian 安装与 MCP 连接

### 3.1 安装 Obsidian

Obsidian 是一个完全免费的本地 Markdown 笔记软件。

**下载地址**：https://obsidian.md/download

| 平台 | 安装方式 |
|------|---------|
| **Windows** | 下载 `.exe` 安装包，双击安装。也可用 `winget install Obsidian.Obsidian` |
| **macOS** | 下载 `.dmg` 安装包，或 `brew install --cask obsidian` |
| **Linux** | 下载 AppImage，或 `flatpak install md.obsidian.Obsidian` |

安装后首次启动，选择一个文件夹作为你的 **Vault（知识库）**——这就是你所有笔记的根目录。

### 3.2 安装必需插件

#### Local REST API 插件（核心）

这是连接 Claude Code 和 Obsidian 的桥梁。它将 Obsidian 暴露为一个本地 HTTP 服务，Claude Code 通过 MCP 协议调用它。

**安装步骤**：

1. 打开 Obsidian → 设置（齿轮图标） → 第三方插件 → 关闭安全模式
2. 点击 **浏览**，搜索 `Local REST API`（作者 `coddingtonbear`）
3. 安装并启用
4. 确认端口配置：默认 **27124**（记下这个端口号）

::: warning 重要
这个插件需要 Obsidian **正在运行**才能工作。如果 Obsidian 关闭了，Claude Code 将无法访问你的笔记。
:::

#### 推荐插件

| 插件 | 用途 |
|------|------|
| **Dataview** | 按标签、字段索引和查询笔记 |
| **Tag Wrangler** | 批量管理标签 |
| **Periodic Notes** | 日记、周记模板 |

### 3.3 配置 Claude Code 的 Obsidian MCP

**配置文件**：`~/.claude/settings.json`

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

::: tip 关键
端口号 `27124` 必须与 Obsidian 中 Local REST API 插件设置的端口一致。
:::

## 四、架构设计

### 4.1 三层结构

```
┌──────────────────────────────────────────────┐
│  第一层：项目入口（CLAUDE.md）                  │
│  → 只写检索方法，不列笔记清单                   │
│  → "用 mcp__obsidian__search_tags 按标签检索"   │
└──────────────────┬───────────────────────────┘
                   │ harness 自动加载
                   ▼
┌──────────────────────────────────────────────┐
│  第二层：指针层（.claude/memory/MEMORY.md）     │
│  → harness 自动注入，零 token 成本              │
│  → 只写：标签名 + 文件路径 + 读写规则（~50字）    │
│  → 不写任何具体内容                            │
└──────────────────┬───────────────────────────┘
                   │ MCP 调用（按需）
                   ▼
┌──────────────────────────────────────────────┐
│  第三层：数据层（Obsidian Vault，你自由设计）     │
│                                               │
│  📁 知识笔记（你写的学习文档，打项目标签）        │
│     ├── React 源码分析.md       [react]        │
│     ├── Docker 网络原理.md      [docker]       │
│     └── ...                                    │
│                                               │
│  📁 记忆/（AI 自动读写的工作记忆）              │
│     ├── my-project/            [memory,react]  │
│     │   ├── 项目约定.md          [convention]  │
│     │   ├── 踩坑记录.md          [pitfall]     │
│     │   └── 偏好设置.md          [preference]  │
│     └── ...（按项目扩展，结构自由设计）          │
└──────────────────────────────────────────────┘
```

> 以上为示例。文件夹结构完全由你决定——只需要 `知识笔记` 和 `记忆` 两类核心文件夹即可。你也可以扩展出其他分类。**核心只依赖标签**：标签打对了，文件放哪里不影响检索。

### 4.2 数据流

```
打开项目
  │
  ├── 自动加载 CLAUDE.md → "知识在 Obsidian，按标签检索"
  └── 自动加载 MEMORY.md → "记忆在 记忆/<项目>/，标签 [memory, <项目>]"

你提问
  ├── 知识类 → 项目文档优先，没有再搜 Obsidian
  ├── 记忆类 → search_tags → 定位 → read_note(section="...")
  └── 写入类 → update_note(mode="append")
```

### 4.3 项目作用域隔离

Claude Code 的 harness 按**工作目录路径**自动隔离记忆：

```
~/.claude/projects/
├── E--PycharmProjects-project-A/   ← 只在项目 A 加载
├── E--PycharmProjects-project-B/   ← 只在项目 B 加载
└── C--Users-<用户名>/              ← 兜底作用域
```

A 项目的约定永远不会污染 B 项目。每个项目的指针文件指向 Obsidian 中对应的记忆文件夹。

### 4.4 记忆的自动化管理 —— 这套系统的灵魂

传统方式下，你需要手动打开文件、手动加内容。而这套方案的真正威力在于：**Claude 通过 MCP 工具自动完成记忆的创建、追加和检索，你只需要像平常一样对话。**

#### Claude 自动写入记忆

当你说"记住：测试必须在包目录里跑"时，Claude 的判断和执行流程：

```
你: "记住：测试必须在包目录里跑"
        │
        ▼
Claude 判断类型: 项目约定（convention）
        │
        ▼
第一步: 按标签检索已有记忆
  mcp__obsidian__search_tags tags: [memory, qwen-code]
        │
        ▼
第二步: 定位目标文件
  → "记忆/qwen-code/项目约定.md" (tag: convention)
        │
        ▼
第三步: 追加内容（不是覆盖！）
  mcp__obsidian__update_note(
    path: "记忆/qwen-code/项目约定.md",
    mode: "append",
    content: "## 测试规则\n- 必须在包目录内运行\n...")
        │
        ▼
完成 ✅ 下次对话自动生效
```

**不同类型的记忆自动路由到不同文件**：

| 你说的内容 | Claude 判断类型 | 写入目标 |
|-----------|----------------|---------|
| "测试必须在包里跑" | convention（约定） | `记忆/<项目>/项目约定.md` |
| "vi.mock 时序不对" | pitfall（踩坑） | `记忆/<项目>/踩坑记录.md` |
| "优先用 dev 模式" | preference（偏好） | `记忆/<项目>/偏好设置.md` |
| "这个设计决策是..." | 新类型记忆 | `记忆/<项目>/<描述>.md` |

#### Claude 自动创建记忆文件夹

如果你是新项目，Obsidian 中还没有记忆文件夹，Claude 会**自动创建**：

```
你: "帮我初始化这个项目的记忆体系"
        │
        ▼
Claude 执行:
  1. mcp__obsidian__create_note("记忆/<项目>/项目约定.md")
     frontmatter: { tags: [memory, <项目>, convention] }
  2. mcp__obsidian__create_note("记忆/<项目>/踩坑记录.md")
     frontmatter: { tags: [memory, <项目>, pitfall] }
  3. mcp__obsidian__create_note("记忆/<项目>/偏好设置.md")
     frontmatter: { tags: [memory, <项目>, preference] }
        │
        ▼
完成 ✅ 三篇空白记忆笔记，frontmatter 标签已打好
```

整个过程你不需要碰 Obsidian，不需要建文件夹，不需要写任何配置。**Claude 通过 MCP 工具链自主完成全部操作。**

#### Claude 自动读取记忆

```
你: "这个项目的测试怎么跑？"
        │
        ▼
Claude 执行:
  1. search_tags [memory, qwen-code] → 找到 3 篇记忆
  2. search("测试") → 定位到 项目约定.md 的 "## 构建与运行" 段落
  3. read_note(section="构建与运行", maxChars=500) → 只读 500 字
        │
        ▼
回答: "测试要在包目录内运行：cd packages/cli && npx vitest..."
```

**每次只加载几百字的相关内容，不浪费上下文。** 这是和原生记忆全量注入的根本区别。

## 五、标签体系设计

标签是这套系统的**检索中枢**：

| 标签 | 用途 |
|------|------|
| `memory, <项目>` | 项目记忆根标签 |
| `memory, global` | 跨项目通用记忆 |
| `convention` | 约定类（构建/规范/流程） |
| `pitfall` | 踩坑类（bug/陷阱） |
| `preference` | 偏好类（习惯/配置） |

**为什么是标签而不是路径？** 文件改名、移动、拆分都不影响检索。新增记忆只需打标签，零维护。

## 六、核心优势

### 优势 1：你的记忆你做主

| 维度 | 原生 .claude/memory/ | 本方案 |
|------|---------------------|--------|
| 可见性 | ❌ 隐藏目录 | ✅ Obsidian 完整可见 |
| 可编辑 | ❌ 只能通过 Claude | ✅ 随手改 |
| 可搜索 | ❌ 无全文搜索 | ✅ 全文搜索 + 标签过滤 |
| 可同步 | ❌ 不跟随 | ✅ git / Obsidian Sync |

### 优势 2：告别上下文膨胀

原生机制每次**全量注入**。10 个项目 × 5 条记忆 × 200 字 = 10,000 字固定开销。

```
原生：全量注入 → 不看也占 token
本方案：标签搜索 → 按需读取 → 不相关不占上下文
```

| 场景 | 原生 | 本方案 |
|------|------|--------|
| 问测试命令 | 全量 4,000 字 | 搜 `test` → 只读 200 字 |
| 问架构设计 | 全量 4,000 字 | 直接查知识笔记，不读记忆 |

### 优势 3：不会丢失内容

Obsidian 中文件就是文件，不存在"系统自动压缩"。你可以用 git 做版本控制、Obsidian Sync 同步、定期归档旧内容。

### 优势 4：跨机器无缝迁移

```
原生方案：换电脑 → 记忆全部丢失
本方案：  git pull / Obsidian Sync → 秒级恢复
```

### 优势 5：知识与记忆统一管理

这也是这套方案最独特的地方——**你的学习笔记（知识）和 AI 工作记忆（记忆）存在同一个系统里，形成完整的闭环**。

```
┌─────────────────────────────────────────────────────────┐
│                    学习与编码闭环                         │
│                                                          │
│  你学习源码                                               │
│     │                                                    │
│     ▼                                                    │
│  在 Obsidian 写分析笔记（知识）                             │
│     ├── 项目架构与快速学习指南                              │
│     ├── 二次开发完全指南                                  │
│     └── 终端多智能体协作原理                              │
│     │                                                    │
│     ▼                                                    │
│  Claude 查阅知识笔记 → 辅助你写代码                        │
│     │                                                    │
│     ▼                                                    │
│  你踩坑、总结约定                                          │
│     │                                                    │
│     ▼                                                    │
│  Claude 自动写入 Obsidian 记忆/ 文件夹                      │
│     ├── 项目约定.md（构建规范、代码风格）                    │
│     ├── 踩坑记录.md（bug、陷阱、注意事项）                  │
│     └── 偏好设置.md（用户习惯）                            │
│     │                                                    │
│     ▼                                                    │
│  下次对话，Claude 自动读取记忆 → 规避已知问题               │
│     │                                                    │
│     └──────────────────────────────────────→ 循环         │
└─────────────────────────────────────────────────────────┘
```

同一个 vault 既是你的笔记本，也是 AI 的长时记忆。你在 Obsidian 中可以随时浏览、搜索、编辑 Claude 写入的记忆——它是你的数据，不是黑箱。

### 优势 6：零维护扩展

新增项目只需：建文件夹 + 打标签 + 一句指针。不改 CLAUDE.md，不改任何配置。

## 七、记忆膨胀管理

### 第一层：搜了再读

```
❌ read_note("踩坑记录.md") → 5000 字全读
✅ search("vitest mock") → 定位 → read_note(section="vitest")
```

### 第二层：适时拆分

文件太大就拆，标签不变，Claude 无感知。

### 第三层：定期归档

```markdown
## 当前有效
- vi.hoisted() 包裹 mock 参数

## 已解决（折叠）
<details>
- ~~vitest 3.x 问题~~ → 已升级
</details>
```

## 八、实战：从零到完整接入

假设你有一个项目 `my-app`，已经用 Obsidian 做笔记。下面是从零开始的全部步骤。

### Step 1：在 Obsidian 中初始化记忆体系

**自动化方式（推荐）**：直接对 Claude 说：

> "帮我为 my-app 项目初始化 Obsidian 记忆体系"

Claude 会自动在 Obsidian 中创建完整的记忆文件夹和初始笔记：

```
记忆/my-app/
├── 项目约定.md    ← 标签 [memory, my-app, convention]
├── 踩坑记录.md    ← 标签 [memory, my-app, pitfall]
└── 偏好设置.md    ← 标签 [memory, my-app, preference]
```

每篇笔记的 frontmatter 标签已自动打好，内容空白，等待后续追加。

**手动方式**：在 Obsidian 中手动建文件夹，每篇笔记填好 frontmatter：

```yaml
---
tags: [memory, my-app, convention]
project: my-app
---
```

### Step 2：在项目 CLAUDE.md 中添加知识库引用

```markdown
## 知识库

项目知识与记忆在 Obsidian vault 中：
- 知识笔记标签：`[knowledge, my-app]`
- 项目记忆标签：`[memory, my-app]`

查阅方式：mcp__obsidian__search_tags 检索
```

### Step 3：创建 .claude/memory/MEMORY.md

```markdown
# 记忆存储规则

所有长期记忆写入 Obsidian，不写 .claude/memory/。

| 类型 | Obsidian 路径 | 标签 |
|------|--------------|------|
| 约定 | 记忆/my-app/项目约定.md | [memory, my-app, convention] |
| 踩坑 | 记忆/my-app/踩坑记录.md | [memory, my-app, pitfall] |
| 偏好 | 记忆/my-app/偏好设置.md | [memory, my-app, preference] |

读取：mcp__obsidian__search_tags tags: [memory, my-app]
写入：mcp__obsidian__update_note mode="append"
```

### Step 4：验证闭环

打开项目，开始对话。验证整个系统是否工作：

```
场景 A：存入记忆
  你: "记住：这个项目构建前必须先 npm run typecheck"
  Claude: → 自动 append 到 记忆/my-app/项目约定.md ✅

场景 B：读取记忆
  你（新对话）: "构建前要做什么？"
  Claude: → search_tags [memory, my-app]
         → 读取 项目约定.md
         → "构建前请先运行 npm run typecheck" ✅

场景 C：查找知识
  你: "这个项目的 MCP 工具怎么用？"
  Claude: → 先在项目文档中找
         → 没有则 search_tags [knowledge, my-app]
         → 读取 Obsidian 知识笔记 ✅

场景 D：踩坑记录
  你: "刚刚发现 vitest 在 Windows 上有路径编码问题，记住"
  Claude: → 判断类型: pitfall
         → append 到 记忆/my-app/踩坑记录.md ✅
```

四个场景验证通过后，你的记忆系统就完整运作了。之后的每一项约定、每一个坑、每一种偏好都会自动沉淀到 Obsidian 中，不会丢失。

## 九、踩坑记录：Windows 环境常见问题

### 坑 1：MCP 连接不上（最常见）

**现象**：看不到 `mcp__obsidian__*` 工具，或 `ECONNREFUSED 127.0.0.1:27124`。

**按顺序排查**：

1. **Obsidian 是否正在运行？** ← 80% 是这个原因
2. Local REST API 插件是否安装并启用？
3. 端口号是否一致？（默认为 27124）
4. Windows 防火墙是否拦截？检查防火墙设置
5. 是否有其他程序占用了 27124 端口？

### 坑 2：认证/权限问题

**解决**：`settings.json` 中统一使用 `127.0.0.1`，不用 `localhost`。

### 坑 3：工具名称与你预期不同

MCP 工具的真实名称都带 `mcp__obsidian__` 前缀：

| 工具名 | 功能 |
|--------|------|
| `mcp__obsidian__search` | 全文搜索 |
| `mcp__obsidian__search_tags` | 按标签搜索 |
| `mcp__obsidian__read_note` | 读取笔记（支持 `section` 和 `maxChars`） |
| `mcp__obsidian__create_note` | 创建笔记 |
| `mcp__obsidian__update_note` | 更新笔记（`append`/`replace`） |
| `mcp__obsidian__list_notes` | 列出笔记 |

### 坑 4：update_note 的 prepend 模式失败

**解决**：用 `create_note(overwrite=true)` 重新创建文件来修改 frontmatter。

### 坑 5：list_notes 不显示子文件夹内容

**解决**：用 `search_tags` 代替，不要依赖 `list_notes` 发现笔记。

### 坑 6：Windows 路径分隔符

**解决**：frontmatter 中路径统一用正斜杠 `/`，不用反斜杠 `\`。

```yaml
# ❌
scope: E:\Projects\my-app

# ✅
scope: E:/Projects/my-app
```

## 十、方案边界

**适合你，如果你：**

- 有多个项目需要 AI 辅助
- 已经在用 Obsidian 做笔记
- 希望记忆跨机器同步
- 想对自己的数据有完全掌控

**不太适合，如果你：**

- 只有一个简单项目，记忆不超过 5 条
- 不用 Obsidian

**唯一代价**：每次读记忆时多一次 MCP 调用（< 1 秒延迟）。

## 十一、设计哲学

1. **不改变现有机制，只改变数据流向**
2. **只教方法，不列清单**
3. **标签驱动发现**
4. **数据主权归你**
5. **搜后读，不全读**
6. **指针与数据分离**

## 十二、总结

这套方案解决了一个朴素但关键的问题：**AI 的记忆应该和你的笔记一样，是你拥有的、可控的、持久的数据资产。**

不是藏在隐藏目录里、随时可能被压缩的黑箱，而是你 Obsidian 图谱中的一个节点，你可以搜索它、链接它、版本控制它、跨机器同步它。

而实现这一切，只需要在 `.claude/memory/` 里写 50 个字，在 Obsidian 里装一个插件。

---

*本文基于 Claude Code + Obsidian MCP 在 Windows 11 上的实际搭建经验。*
