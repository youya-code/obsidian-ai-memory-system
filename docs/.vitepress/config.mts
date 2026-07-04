import { defineConfig } from 'vitepress'

export default defineConfig({
  lang: 'zh-CN',
  title: 'Obsidian AI Memory System',
  description: '将 Obsidian 作为 AI 编程助手的外挂知识库与记忆系统',

  head: [['link', { rel: 'icon', href: '/favicon.ico' }]],

  themeConfig: {
    logo: '/logo.svg',
    nav: [
      { text: '博客', link: '/blog/' },
      { text: '搭建指南', link: '/guide/' },
      { text: '模板下载', link: '/guide/templates' },
      {
        text: '资源',
        items: [
          { text: 'Claude Code', link: 'https://claude.ai/code' },
          { text: 'Obsidian', link: 'https://obsidian.md' },
          { text: 'MCP 协议', link: 'https://modelcontextprotocol.io' },
        ]
      }
    ],

    sidebar: {
      '/blog/': [
        {
          text: '博客',
          items: [
            { text: 'Claude Code + Obsidian：打造不会丢失的 AI 记忆系统', link: '/blog/' }
          ]
        }
      ],
      '/guide/': [
        {
          text: '搭建指南',
          items: [
            { text: '概述', link: '/guide/' },
            { text: '第一步：安装 Obsidian', link: '/guide/install-obsidian' },
            { text: '第二步：配置 MCP 连接', link: '/guide/config-mcp' },
            { text: '第三步：创建记忆体系', link: '/guide/create-memory-system' },
            { text: '第四步：模板下载', link: '/guide/templates' },
            { text: '踩坑记录', link: '/guide/pitfalls' },
          ]
        }
      ]
    },

    socialLinks: [
      { icon: 'github', link: 'https://github.com/youya-code/obsidian-ai-memory-system' }
    ],

    search: {
      provider: 'local',
      options: {
        translations: {
          button: { buttonText: '搜索' },
          modal: {
            noResultsText: '没有找到结果',
            resetButtonTitle: '清除',
            footer: { selectText: '选择', navigateText: '切换' }
          }
        }
      }
    },

    outline: {
      level: [2, 3],
      label: '本页目录'
    },

    docFooter: {
      prev: '上一篇',
      next: '下一篇'
    },

    darkModeSwitchLabel: '主题',
    sidebarMenuLabel: '菜单',
    returnToTopLabel: '回到顶部',
    lastUpdated: {
      text: '最后更新于'
    }
  },

  markdown: {
    lineNumbers: true
  }
})
