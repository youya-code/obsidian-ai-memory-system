# Auto-Memory Init Hook
# 每次 Claude Code 启动时自动检查并初始化项目记忆基础设施
# 放在 ~/.claude/hooks/auto-memory-init.ps1
# 通过 SessionStart hook 触发

param([string]$cwd = $pwd.Path)

$ErrorActionPreference = "SilentlyContinue"

# === Obsidian 配置 ===
$OBSIDIAN_API = "https://127.0.0.1:27124"
$OBSIDIAN_KEY = "06da7e6e35e0731f752b96e426fe66ecdeffe07ac12b94cd57636da1d41946f1"
$VAULT_MEMORY_PREFIX = "记忆"

# === 路径清理（匹配 Claude Code 的 sanitize 规则） ===
$sanitized = $cwd.Replace(":", "--").Replace("\", "-").Replace("/", "-").TrimEnd("-")
$memoryDir = "$env:USERPROFILE\.claude\projects\$sanitized\memory"
$memoryFile = "$memoryDir\MEMORY.md"

# === 如果是全局作用域（用户目录）就跳过 ===
if ($cwd -eq $env:USERPROFILE) {
    # 全局作用域已有 MEMORY.md，不需要初始化
    exit 0
}

# === 已有 MEMORY.md 就跳过 ===
if (Test-Path $memoryFile) {
    exit 0
}

# === 提取项目名称 ===
$projectName = Split-Path $cwd -Leaf
if ([string]::IsNullOrEmpty($projectName)) {
    $projectName = $sanitized
}

# === 检测项目语言/技术栈 ===
$techStack = ""
if (Test-Path "$cwd\pom.xml") { $techStack += "Maven " }
if (Test-Path "$cwd\build.gradle") { $techStack += "Gradle " }
if (Test-Path "$cwd\package.json") { $techStack += "Node.js " }
if (Test-Path "$cwd\Cargo.toml") { $techStack += "Rust " }
if (Test-Path "$cwd\MANIFEST.MF") { $techStack += "OSGi " }
if ((Get-ChildItem $cwd -Filter "*.java" -Recurse -Depth 2).Count -gt 0) { $techStack += "Java " }
if ((Get-ChildItem $cwd -Filter "*.py" -Recurse -Depth 2).Count -gt 0) { $techStack += "Python " }
if ([string]::IsNullOrEmpty($techStack)) { $techStack = "通用" }

# === 检测是否有 git remote ===
$gitRemote = ""
try {
    $gitRemote = git -C $cwd remote get-url origin 2>$null
} catch {}

# === 生成项目标签（中文名取首字母简拼或直接用文件夹名） ===
$tagSafeName = $projectName.ToLower() -replace '[^\w\-]', '-'
$projectTag = "memory, $tagSafeName"

# === 创建 MEMORY.md 指针 ===
New-Item -ItemType Directory -Path $memoryDir -Force | Out-Null
@"
# 记忆存储规则（本作用域：$cwd）

所有长期记忆写入 Obsidian，不写此处。

| 记忆类型 | Obsidian 路径 | 标签 |
|----------|--------------|------|
| 项目约定（架构/规范/流程） | `$VAULT_MEMORY_PREFIX/$projectName/项目约定.md` | `[$projectTag, convention]` |
| 踩坑记录（bug/坑/注意事项） | `$VAULT_MEMORY_PREFIX/$projectName/踩坑记录.md` | `[$projectTag, pitfall]` |
| 偏好设置（用户习惯/偏好） | `$VAULT_MEMORY_PREFIX/$projectName/偏好设置.md` | `[$projectTag, preference]` |

## 项目信息
- 路径：$cwd
- 技术栈：$techStack
$(if ($gitRemote) { "- 远程仓库：$gitRemote" } else { "" })
## 读取方式
- Obsidian MCP 工具按标签检索
- \`search_tags tags: [$projectTag]\` 检出本项目全部记忆

## 规则
- 此处只保留本指针文件
- 新记忆追加到 Obsidian 对应文件末尾
- Claude 自主通过 Obsidian MCP 控制记忆读写
"@ | Out-File -FilePath $memoryFile -Encoding utf8

Write-Host "[auto-memory] 已创建项目记忆指针: $memoryFile" -ForegroundColor Green

# === 在 Obsidian 中创建记忆文件夹 ===
$obsidianFolder = [uri]::EscapeDataString("$VAULT_MEMORY_PREFIX/$projectName")
$apiBase = "$OBSIDIAN_API/vault/$obsidianFolder"
$authHeader = @{ Authorization = "Bearer $OBSIDIAN_KEY" }

# 创建项目约定
$refContent = "# 项目约定`n`n## 项目信息`n- 路径：$cwd`n- 技术栈：$techStack$(if ($gitRemote) { \"`n- 远程仓库：$gitRemote\" } else { '' })`n`n## 架构原则`n`n待补充`n`n## 代码规范`n`n待补充`n`n## 构建与运行`n`n待补充`n"
$refFile = [uri]::EscapeDataString("项目约定.md")
try {
    Invoke-RestMethod -Uri "$apiBase/$refFile" -Method Put -Headers $authHeader -Body $refContent -ContentType "text/markdown" -SkipCertificateCheck | Out-Null
} catch {}

# 创建踩坑记录
$pitContent = "# 踩坑记录`n`n## $projectName 开发记录`n`n待记录第一坑~`n"
$pitFile = [uri]::EscapeDataString("踩坑记录.md")
try {
    Invoke-RestMethod -Uri "$apiBase/$pitFile" -Method Put -Headers $authHeader -Body $pitContent -ContentType "text/markdown" -SkipCertificateCheck | Out-Null
} catch {}

# 创建偏好设置
$prefContent = "# 偏好设置`n`n## $projectName 个人偏好`n`n待补充`n"
$prefFile = [uri]::EscapeDataString("偏好设置.md")
try {
    Invoke-RestMethod -Uri "$apiBase/$prefFile" -Method Put -Headers $authHeader -Body $prefContent -ContentType "text/markdown" -SkipCertificateCheck | Out-Null
} catch {}

Write-Host "[auto-memory] 已初始化 Obsidian 记忆: $VAULT_MEMORY_PREFIX/$projectName/" -ForegroundColor Green
