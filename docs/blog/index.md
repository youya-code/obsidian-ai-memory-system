# Claude Code + Obsidian：打造不会丢失的 AI 记忆系统

> 将 Obsidian 作为 Claude Code 的外挂知识库与记忆系统，解决原生记忆机制的三大痛点：不可见、不可控、不可迁移。本文包含完整的安装配置指南和 Windows 环境踩坑记录。

---

## 一、问题：Claude Code 的原生记忆够用吗？

Claude Code 内置了一套记忆系统，存放在 `~/.claude/projects/<项目>/memory/` 目录下。每次对话开始时，harness 会自动将 `MEMORY.md` 注入到系统提示中，让 Claude "记住" 之前的约定和偏好。

这套机制在**单项目、轻量使用**时运转良好。但当你深入使用后，三个问题会逐渐浮现：

### 痛点 1：你不可见

记忆文件藏在 `~/.claude/` 的隐藏目录里。你很难随时浏览、编辑、重组这些记忆。每一次修改都要通过 Claude 代劳，或者手动找到路径用编辑器打开。

### 痛点 2：你不可控

所有记忆在每次对话中**全量注入上下文**。当记忆积累到几十条、上百条后，harness 会触发自动压缩——而你完全不知道哪些被压缩了、哪些被截断了。可能一条关键的踩坑记录就在某次压缩中消失了，你甚至不会察觉。

### 痛点 3：不可迁移

换了一台电脑，所有记忆归零。`.claude/` 目录不在版本控制里，也不在云同步范围内。你的项目约定、踩坑经验、偏好设置全部留在了旧机器上。

---

## 二、思路：把 Obsidian 变成 Claude 的外挂大脑

Obsidian 天然具备几个优势：

- **完全可视化** — 你随时可以浏览、搜索、编辑每一篇笔记
- **你拥有数据** — 文件就是本地 Markdown，不会被任何系统"压缩"或"优化掉"
- **可同步** — Obsidian Sync 或 git，换机器无缝迁移
- **可检索** — 全文搜索、标签系统、图谱视图
- **MCP 可访问** — Claude Code 通过 MCP 协议可以直接读写 Obsidian

**核心思路很简单：指针放 `.claude/memory/`，内容放 Obsidian。**

---

## 三、环境准备：Obsidian 安装与 MCP 连接

### 3.1 安装 Obsidian

Obsidian 是一个完全免费的本地 Markdown 笔记软件。

**下载地址**：https://obsidian.md/download

| 平台 | 安装方式 |
|------|---------|
| **Windows** | 下载 `.exe` 安装包，双击安装。也可用 `winget install Obsidian.Obsidian` |
| **macOS** | 下载 `.dmg` 安装包，或 `brew install --cask obsidian` |
| **Linux** | 下载 AppImage，或 `flatpak install md.obsidian.Obsidian` |

安装后首次启动，选择一个文件夹作为你的 **Vault（知识库）**——这就是你所有笔记的根目录。建议放在一个不会被意外删除的位置，比如 `D:/ObsidianVault` 或 `~/Documents/ObsidianVault`。

### 3.2 安装必需插件

要让 Claude Code 能读写 Obsidian，需要为 Obsidian 安装一个关键插件：

#### Local REST API 插件（核心）

这是连接 Claude Code 和 Obsidian 的桥梁。它将 Obsidian 暴露为一个本地 HTTP 服务，Claude Code 通过 MCP 协议调用它。

**安装步骤**：

1. 打开 Obsidian
2. 进入 **设置（齿轮图标）** → **第三方插件（Community plugins）**
3. 如果提示"安全模式"，点击**关闭安全模式**
4. 点击 **浏览（Browse）**，搜索 `Local REST API`
5. 找到由 `coddingtonbear` 开发的 **Local REST API** 插件，点击安装
6. 安装后**启用**该插件
7. 进入插件设置，确认以下配置：
   - **端口（Port）**：默认 `27124`（记下这个端口号）
   - **API 密钥（API Key）**：可以留空（本地访问不需要），也可以生成一个用于安全
   - **非安全模式 HTTP**：保持默认开启

> **注意**：这个插件需要 Obsidian **正在运行**才能工作。如果 Obsidian 关闭了，Claude Code 将无法访问你的笔记。

#### 推荐插件（非必需，但强烈建议）

| 插件 | 用途 |
|------|------|
| **Dataview** | 按标签、字段索引和查询笔记，配合 frontmatter 使用极佳 |
| **Tag Wrangler** | 批量管理标签，重命名/合并标签更方便 |
| **Periodic Notes** | 日记、周记模板，可以配合记忆系统做时间线 |

### 3.3 配置 Claude Code 的 Obsidian MCP

Claude Code 通过 MCP（Model Context Protocol）连接 Obsidian。MCP 配置写在 Claude Code 的设置文件中。

**配置文件位置**：

| 系统 | 路径 |
|------|------|
| Windows | `C:\Users\<用户名>\.claude\settings.json` |
| macOS / Linux | `~/.claude/settings.json` |

**添加以下配置**（如果文件不存在则新建）：

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

> **关键点**：端口号 `27124` 必须与 Obsidian 中 Local REST API 插件设置的端口一致。如果你的插件用了不同端口，这里也要对应修改。

如果你已经在使用 Claude Code，可以用 `/config` 命令快速打开设置文件，或者直接命令行：

```bash
# Windows (Git Bash)
notepad "$HOME/.claude/settings.json"

# 或者让 Claude 帮你直接写入
# "帮我配置 Obsidian MCP，端口是 27124"
```

**验证连接**：重启 Claude Code（或新开会话），Claude 应该能看到 `mcp__obsidian__*` 系列工具可用。如果看不到，参考第九章的踩坑记录。

### 3.4 全局 MCP 配置 —— 解决项目切换失效

**问题**：如果你只在某个项目的 `.claude.json` 中配置 Obsidian MCP，切到其他项目时 Obsidian 工具就不可用了。每次新项目都要重新配置，非常麻烦。

**解决方案**：用 `claude mcp add --scope user` 全局注册，让所有项目都能用。

```bash
claude mcp add --scope user obsidian -- npx -y obsidian-notes-mcp
```

这条命令会将 Obsidian MCP 写入 `~/.claude.json` 的全局配置区，之后不管在哪个目录打开 Claude Code，Obsidian 工具都始终可用。

---

## 四、架构设计

### 4.1 三层结构

```
┌──────────────────────────────────────────────┐
│  第一层：项目入口（CLAUDE.md）                  │
│  → 只写检索方法，不列笔记清单                   │
│  → "用 mcp__obsidian__search_tags 检索"        │
└──────────────────┬───────────────────────────┘
                   │ 自动加载
                   ▼
┌──────────────────────────────────────────────┐
│  第二层：指针层（.claude/memory/MEMORY.md）     │
│  → harness 自动注入，零成本                     │
│  → 只写：标签名 + 文件路径 + 读写规则（~50字）    │
│  → 不写任何具体内容                            │
└──────────────────┬───────────────────────────┘
                   │ 指向
                   ▼
┌──────────────────────────────────────────────┐
│  第三层：数据层（Obsidian Vault）               │
│                                               │
│  📁 知识/   ← 学习笔记、架构分析、技术文档       │
│     ├── 项目架构与快速学习指南.md                │
│     ├── 二次开发完全指南.md                     │
│     └── 终端与多智能体协作实现原理.md            │
│                                               │
│  📁 记忆/   ← 项目约定、踩坑记录、偏好设置       │
│     ├── README.md                             │
│     └── qwen-code/                            │
│         ├── 项目约定.md                        │
│         ├── 踩坑记录.md                        │
│         └── 偏好设置.md                        │
│                                               │
│  📁 方案与模式/  ← 可复用的方法论与最佳实践      │
│     └── Claude-Code-知识记忆系统集成方案.md      │
└──────────────────────────────────────────────┘
```

### 4.2 数据流

```
打开项目
  │
  ├── Claude Code 自动加载 CLAUDE.md
  │     └── "本项目知识在 Obsidian，按 qwen-code 标签检索"
  │
  └── Claude Code 自动加载 .claude/memory/MEMORY.md
        └── "记忆在 Obsidian/记忆/qwen-code/，标签 [memory, qwen-code]"

你提问
  │
  ├── 知识类："架构是什么？"
  │     → 项目内文档优先，没有再搜 Obsidian 标签 [qwen-code]
  │
  ├── 记忆类："测试怎么跑？"
  │     → mcp__obsidian__search_tags [memory, qwen-code]
  │     → 定位到 项目约定.md → 读取 → 回答
  │
  └── 写入类："记住：X 有个坑"
        → mcp__obsidian__update_note("记忆/qwen-code/踩坑记录.md", append)
```

### 4.3 项目作用域隔离

Claude Code 的 harness 按**工作目录路径**自动隔离记忆：

```
~/.claude/projects/
├── E--PycharmProjects-qwen-code/    ← 只在 qwen-code 项目加载
│   └── memory/MEMORY.md
├── E--PycharmProjects-project-B/    ← 只在 project-B 加载
│   └── memory/MEMORY.md
└── C--Users-yangpengjie/            ← 兜底作用域
    └── memory/MEMORY.md
```

路径映射规则：工作目录 `E:\PycharmProjects\qwen-code` → 目录名 `E--PycharmProjects-qwen-code`。项目间完全隔离，A 项目的约定永远不会污染 B 项目。

---

## 五、标签体系设计

标签是这套系统的**检索中枢**。每次查询不靠硬编码路径，而是靠标签发现：

| 标签 | 用途 | 示例 |
|------|------|------|
| `knowledge, <项目>` | 知识笔记 | `knowledge, qwen-code` |
| `memory, <项目>` | 项目记忆（根标签） | `memory, qwen-code` |
| `memory, global` | 跨项目通用记忆 | `memory, global` |
| `convention` | 约定类（构建/规范/流程） | 项目约定.md |
| `pitfall` | 踩坑类（bug/陷阱） | 踩坑记录.md |
| `preference` | 偏好类（习惯/配置） | 偏好设置.md |

**为什么不用文件夹路径直接读？** 因为标签是松耦合的——文件改名、移动、拆分都不影响检索。新增一篇记忆只需打上标签，不需要改任何配置文件。

---

## 六、核心优势分析

### 优势 1：你的记忆你做主

| 维度 | 原生 .claude/memory/ | 本方案 |
|------|---------------------|--------|
| 可见性 | ❌ 隐藏目录，不可视 | ✅ Obsidian 中完整可见 |
| 可编辑 | ❌ 只能通过 Claude | ✅ 随手改，所见即所得 |
| 可重组 | ❌ 受限的文件结构 | ✅ 拖拽、拆分、合并、重命名 |
| 可搜索 | ❌ 无全文搜索 | ✅ Obsidian 全文搜索 + 标签过滤 |

### 优势 2：告别上下文膨胀

原生机制每次将所有记忆**全量注入系统提示**。假设你有 10 个项目，每个 5 条记忆，每条 200 字——那就是 10,000 字的固定开销，每次对话都吃掉宝贵的上下文窗口。

本方案的核心区别：

```
原生：全量注入 → 不看不行的固定成本
本方案：标签搜索 → 按需读取 → 不相关的不占上下文
```

一个实际对比：

| 场景 | 原生方案 | 本方案 |
|------|---------|--------|
| 问测试命令 | 加载全部 20 条记忆（~4,000 字） | 搜 `test` → 只读 1 条（~200 字） |
| 问架构设计 | 同上，全量加载 | 不读记忆，直接查知识笔记 |
| 新增记忆 | 写文件，下次全量注入 | append 到 Obsidian，不增加固定成本 |

### 优势 3：不会丢失内容

原生机制在上下文窗口紧张时，harness 会**自动压缩**记忆——截断、摘要、甚至丢弃。这个过程你完全看不到，也无法干预。

Obsidian 中，文件就是文件。不存在"系统自动压缩"这回事。你可以：

- 用 git 做版本控制，每次修改都有历史
- 用 Obsidian Sync 跨机器同步
- 定期归档旧内容（折叠，不删除），保留完整记录
- 用 `maxChars` 参数控制单次读取量，但文件本身完好无损

**你永远可以回去翻完整的记忆。**

### 优势 4：跨机器无缝迁移

```
原生方案：换电脑 → 记忆全部丢失 → 从头积累
本方案：  git pull / Obsidian Sync → 所有记忆秒级恢复
```

甚至可以在不同机器上用不同 Claude Code 客户端（桌面版 / CLI / IDE 插件），只要 vault 同步，记忆就同步。

### 优势 5：知识与记忆统一管理

这也是这套方案最独特的地方——**你的学习笔记（知识）和 AI 工作记忆存在同一个系统里**。

当你写了一篇《Qwen Code 二次开发完全指南》，Claude 可以直接查阅它来辅助你写代码。当你踩了一个坑、总结了一条约定，Claude 下次会自动规避。

整个循环是闭合的：

```
你学习 → 写 Obsidian 笔记 → Claude 查阅 → 辅助你工作
你工作 → 产生新经验 → Claude 写入 Obsidian 记忆 → 下次生效
```

### 优势 6：零维护扩展

新增一个项目？只需：

1. Obsidian 中建 `记忆/<新项目>/` 文件夹，打上标签
2. `.claude/memory/` 写一句指针

不需要改 CLAUDE.md（它只写"搜标签"的方法，不列具体清单），不需要改任何配置。新增笔记、拆分文件、重组结构——Claude 通过标签自动发现。

---

## 七、记忆膨胀管理

你可能会担心："文件越来越多，会不会又回到全量加载的老路？"

不会。这套方案有三层防护：

### 第一层：搜了再读

```
❌ 旧方式：read_note("踩坑记录.md") → 5000 字全读
✅ 新方式：search("vitest mock") → 定位到第 3 节 → read_note(section="vitest")
```

每次只加载几百字的相关内容。

### 第二层：适时拆分

```
踩坑记录.md（50 条，太大）
  → 拆分为：
     踩坑记录/
       ├── vitest.md
       ├── 构建相关.md
       └── 集成测试.md
```

拆分时标签不变，Claude 无感知——`search_tags [memory, qwen-code, pitfall]` 照样能搜到所有子文件。

### 第三层：定期归档

```markdown
## 当前有效
- vi.hoisted() 包裹 mock 参数

## 已解决（折叠区）
<details>
- ~~vitest 3.x breaking change~~ → 已升级到 4.x，不再适用
</details>
```

历史记录不删，但 Claude 只读"当前有效"区域。

---

## 八、踩坑实录

### 坑 1：Obsidian MCP 只在当前项目可用

**现象**：在项目 A 配好了 Obsidian MCP，切到项目 B 后 `mcp__obsidian__*` 工具全部消失。

**原因**：MCP 配置只写在了单个项目的 `.claude.json` projects 节点下，不是全局的。

**解决方案**：
```bash
claude mcp add --scope user obsidian -- npx -y obsidian-notes-mcp
```
这条命令将 Obsidian MCP 注册到全局配置区，所有项目共享。

### 坑 2：settings.json 被代理软件覆盖

**现象**：配好的 hook 或自定义配置，用了几天后发现消失了。

**原因**：ccswitch 等代理工具会整体覆盖 `settings.json`，不合并。

**解决方案**：将持久配置（hooks 等）写入 `settings.local.json`。该文件行为与 settings.json 完全一致，但不会被任何工具覆盖。

### 坑 3：Obsidian REST API 中文乱码

**现象**：用 `curl -d "中文内容"` 直接上传，Obsidian 中显示乱码。

**原因**：Windows 终端编码导致 `-d` 参数中的中文被错误编码。

**解决方案**：先用 Write 写到本地临时文件，再用 `--data-binary "@file"` 上传：
```bash
# 1. 先写本地文件
# 2. 用 --data-binary 上传
curl -sk -X PUT --data-binary "@local_file.md" "https://127.0.0.1:27124/vault/path/to/note.md"
```

### 坑 4：update_note prepend 模式失败

**现象**：`update_note(mode="prepend")` 给已有笔记加 frontmatter 时报错。

**解决**：用 `create_note(overwrite=true)` 重建文件，或者首次创建时就写好 frontmatter。

### 坑 5：list_notes 不显示子文件夹内容

**现象**：`list_notes` 只返回根目录笔记，看不到 `记忆/` 子文件夹内容。

**解决**：用 `search_tags` 按标签搜索替代 `list_notes`。标签搜索不依赖目录结构，更可靠。

### 坑 6：Windows 路径分隔符

**现象**：frontmatter 中 `E:\Projects\my-app` 解析出错。

**原因**：YAML 中 `\` 是转义字符。

**解决**：路径统一用正斜杠：`E:/Projects/my-app`

---

## 九、实战：一个完整的接入过程

假设你有一个项目 `my-app`，已经用 Obsidian 做笔记。下面是完整接入步骤：

### Step 1：在 Obsidian 中创建记忆文件夹

```
记忆/my-app/
├── 项目约定.md    ← 标签 [memory, my-app, convention]
├── 踩坑记录.md    ← 标签 [memory, my-app, pitfall]
└── 偏好设置.md    ← 标签 [memory, my-app, preference]
```

### Step 2：在 CLAUDE.md 中添加一段

```markdown
## 知识库

项目知识与记忆在 Obsidian vault 中：
- 知识笔记标签：`[knowledge, my-app]`
- 项目记忆标签：`[memory, my-app]`

查阅方式：`mcp__obsidian__search_tags` 检索，`mcp__obsidian__read_note` 读取。
注意：项目内同名 .md 文档优先使用，Obsidian 作为补充。
```

### Step 3：创建 .claude/memory/MEMORY.md

```markdown
# 记忆存储规则（本作用域：<项目路径>）

所有长期记忆写入 Obsidian，不写 .claude/memory/。

| 类型 | 路径 | 标签 |
|------|------|------|
| 约定 | `记忆/my-app/项目约定.md` | `[memory, my-app, convention]` |
| 踩坑 | `记忆/my-app/踩坑记录.md` | `[memory, my-app, pitfall]` |
| 偏好 | `记忆/my-app/偏好设置.md` | `[memory, my-app, preference]` |

读取：`mcp__obsidian__search_tags tags: [memory, my-app]`
写入：`mcp__obsidian__update_note mode="append"`
规则：同类记忆追加到同一文件，不新建碎片文件
```

### Step 4：开始使用

打开项目，Claude 自动加载上述配置。之后的每一次记忆读写都会自动路由到 Obsidian。

---

## 十、踩坑记录：Windows 环境常见问题

在 Windows 上搭建这套系统时，我们遇到了几个典型的坑。这里一并记录。

### 坑 1：Obsidian MCP 连接不上（Connection Refused）

**现象**：Claude Code 中看不到 `mcp__obsidian__*` 工具，或调用时报 `ECONNREFUSED 127.0.0.1:27124`。

**排查清单**（按顺序检查）：

| # | 检查项 | 怎么做 |
|---|--------|--------|
| 1 | Obsidian 是否在运行？ | 任务栏看看 Obsidian 图标在不在。**必须打开 Obsidian**，MCP 才工作 |
| 2 | Local REST API 插件是否安装并启用？ | Obsidian 设置 → 第三方插件 → 找到 Local REST API → 确认已启用 |
| 3 | 端口是否正确？ | 插件设置中查看端口号（默认 27124），与 `settings.json` 中 `url` 的端口一致 |
| 4 | 防火墙是否拦截？ | 首次启动时 Windows 防火墙可能弹窗拦截，**点击"允许访问"** |
| 5 | 是否有端口冲突？ | `netstat -ano | findstr 27124` 检查端口是否被其他程序占用 |
| 6 | API 密钥是否设置了？ | 如果插件中设置了 API Key，`settings.json` 中也需要加上对应的认证头 |

**最常见的原因**：**Obsidian 没有打开。** 这是新手最容易忽略的——Local REST API 是 Obsidian 内部插件，Obsidian 关了服务就停了。

### 坑 2：MCP 工具显示但不工作（认证/权限问题）

**现象**：`mcp__obsidian__list_notes` 能列出笔记，但 `create_note` 或 `update_note` 失败。

**原因**：Windows 下 `127.0.0.1` 和 `localhost` 可能有解析差异。

**解决方案**：在 `settings.json` 中统一使用 `127.0.0.1`，不要用 `localhost`。

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

### 坑 3：Obsidian MCP 工具的名称与你预期不同

**现象**：你在 prompt 中写了"搜索笔记"，但 Claude 说找不到对应工具。

**原因**：MCP 工具的真实名称是带 `mcp__obsidian__` 前缀的，而不是你想的 `search_notes`。

**实际可用工具**：

| 真实工具名 | 功能 |
|-----------|------|
| `mcp__obsidian__search` | 全文搜索（支持上下文） |
| `mcp__obsidian__search_tags` | 按标签搜索 |
| `mcp__obsidian__search_frontmatter` | 按 frontmatter 字段搜索 |
| `mcp__obsidian__read_note` | 读取单篇笔记（支持 `section` 和 `maxChars`） |
| `mcp__obsidian__create_note` | 创建新笔记 |
| `mcp__obsidian__update_note` | 更新笔记（`append` / `prepend` / `replace`） |
| `mcp__obsidian__batch_create` | 批量创建笔记 |
| `mcp__obsidian__batch_read` | 批量读取笔记 |
| `mcp__obsidian__delete_note` | 删除笔记（需 `confirm: true`） |
| `mcp__obsidian__list_notes` | 列出笔记（支持分页） |
| `mcp__obsidian__vault_stats` | 查看 vault 统计信息 |

### 坑 4：Obsidian update_note 的 prepend 模式失败

**现象**：用 `update_note(mode="prepend")` 给笔记加 frontmatter 时报错。

**原因**：某些版本的 Local REST API 对 prepend 模式处理有 bug，尤其是对已有 frontmatter 的文件。

**解决方案**：
- 用 `create_note(overwrite=true)` 重新创建整个文件来添加/修改 frontmatter
- 或者用 `replace` 模式替换整个文件内容（先在 Obsidian 中备份）
- 首次创建笔记时就写好 frontmatter，避免事后添加

### 坑 5：list_notes 不显示子文件夹中的笔记

**现象**：`mcp__obsidian__list_notes` 只返回根目录下的 3 篇笔记，看不到 `记忆/` 文件夹的内容。

**原因**：`list_notes` 默认只列根目录，子文件夹中的笔记不会自动展开。

**解决方案**：
- 使用 `mcp__obsidian__search_tags` 按标签搜索（推荐，不依赖目录结构）
- 或者带 `folder` 参数：`mcp__obsidian__list_notes(folder="记忆/qwen-code")`
- 不要依赖 `list_notes` 发现笔记，用标签搜索更可靠

### 坑 6：Windows 路径分隔符问题

**现象**：在 Obsidian 笔记 frontmatter 中写 `E:\PycharmProjects\qwen-code` 后，部分工具解析出错。

**原因**：Windows 用反斜杠 `\`，而 YAML 中 `\` 是转义字符。

**解决方案**：路径统一用正斜杠 `/`：

```yaml
# ❌ 错误
scope: E:\PycharmProjects\qwen-code

# ✅ 正确
scope: E:/PycharmProjects/qwen-code
```

---

## 十一、方案边界

这套方案不是银弹，有几个适用前提：

**适合你，如果你：**
- 有多个项目需要 AI 辅助
- 已经在用 Obsidian 做笔记
- 希望记忆跨机器同步
- 想对自己的数据有完全掌控

**不太适合，如果你：**
- 只有一个简单项目，记忆不超过 5 条
- 不用 Obsidian（可以用其他 MCP 可访问的存储替代）
- 完全不想维护任何额外结构

**每次多一次 MCP 调用的开销** — 这是这套方案唯一的"代价"。指针文件的内容（约 50 字）仍然零成本自动注入，但真正读取记忆内容时需要主动调用 MCP。在实际使用中，这个延迟通常不超过 1 秒，与带来的可控性相比完全可以接受。

---

## 十二、设计哲学

最后，聊聊这套方案背后的设计原则：

1. **不改变现有机制，只改变数据流向** — `.claude/memory/` 该怎么用还怎么用，只是内容从"详细记录"变成了"检索指针"

2. **只教方法，不列清单** — CLAUDE.md 写"搜标签 `[memory, my-app]`"，而不是逐一列出 12 篇笔记的文件名

3. **标签驱动发现** — 新增笔记、重命名、拆分——上层无感知，标签不变检索就不受影响

4. **数据主权归你** — 记忆存在 Obsidian，你随时看、改、删、同步，不会被任何"智能压缩"黑箱操作

5. **搜后读，不全读** — 先 search 定位，再用 section/maxChars 精准加载，上下文永远只花在刀刃上

6. **指针与数据分离** — `.claude/memory/` 只有一句话指针，真正的数据在 Obsidian。两层之间通过标签松散耦合，互不依赖

---

## 四.5 自动初始化 —— 新项目零配置

光有全局 MCP 还不够——新项目的 `.claude/memory/MEMORY.md` 还是空的，Obsidian 里也没有对应的记忆文件夹。每次新项目都要手动创建，太麻烦。

**最终方案：SessionStart Hook + 自动初始化脚本**

```
Claude Code 启动
  → SessionStart hook 触发
    → auto-memory-init.ps1
      ├─ 检查项目 memory/MEMORY.md 是否已存在
      ├─ 已存在 → 跳过
      └─ 不存在 → 自动创建：
           ├─ .claude/.../memory/MEMORY.md（指针文件，含项目名、技术栈、git remote）
           └─ Obsidian 记忆/<项目名>/（3个模板文件：项目约定、踩坑记录、偏好设置）
```

**配置方式**（在 `~/.claude/settings.local.json` 中，用 `settings.local.json` 而不是 `settings.json`，因为代理软件可能会覆盖 settings.json）：

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "powershell -ExecutionPolicy Bypass -File C:/Users/yangpengjie/.claude/hooks/auto-memory-init.ps1"
          }
        ]
      }
    ]
  }
}
```

**完整脚本**（`~/.claude/hooks/auto-memory-init.ps1`）：

```powershell
# 核心逻辑：
# 1. 计算当前项目的 sanitized 路径名
# 2. 检查 ~/.claude/projects/<sanitized>/memory/MEMORY.md 是否存在
# 3. 不存在时自动创建指针文件 + Obsidian 记忆文件夹
# 4. 自动检测项目技术栈（Java/Node/Python/Rust 等）和 git remote

# 完整脚本见 GitHub: scripts/auto-memory-init.ps1
# https://github.com/youya-code/obsidian-ai-memory-system
```

**Hook 配置**（`~/.claude/settings.local.json`）：
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

> **为什么用 `settings.local.json`**：避免被 ccswitch 等代理工具覆盖（见踩坑实录第 2 条）。

---

## 十三、总结

这套方案解决了一个朴素但关键的问题：**AI 的记忆应该和你的笔记一样，是你拥有的、可控的、持久的数据资产。**

不是藏在隐藏目录里、随时可能被压缩的黑箱，而是你 Obsidian 图谱中的一个节点，你可以搜索它、链接它、版本控制它、跨机器同步它。

而实现这一切，只需要在 `.claude/memory/` 里写 50 个字，在 Obsidian 里装一个插件。

---

## 附录：完整技术栈速查

| 组件 | 说明 | 链接 |
|------|------|------|
| Claude Code | AI 编程助手 CLI | https://claude.ai/code |
| Obsidian | 本地 Markdown 笔记软件 | https://obsidian.md/download |
| Local REST API | Obsidian 插件，暴露 HTTP API | Obsidian 插件市场搜索 |
| MCP 协议 | Model Context Protocol | https://modelcontextprotocol.io |
| Obsidian MCP Server | Claude Code 的 Obsidian 连接器 | 通过 settings.json 配置 |

---

*本文基于 Claude Code + Obsidian MCP 在 Windows 11 上的实际搭建经验。方案技术文档见 Obsidian `方案与模式/Claude-Code-知识记忆系统集成方案.md`。*
