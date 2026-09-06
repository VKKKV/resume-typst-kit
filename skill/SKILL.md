---
name: resume
description: Use when creating or optimizing a technical resume.
tags: [resume, cv, typst, rendercv, github, ats, career]
related_skills: [writing, ui-design, hermes-core, git-repository-maintenance]
triggers:
  - "resume|简历|CV"
  - "更新.*简历|优化.*简历|重写.*简历"
  - "找.*简历模板|简历.*模板|resume template"
  - "RenderCV|Typst.*简历|LaTeX.*简历"
  - "GitHub.*博客.*简历|公开资料.*简历"
  - "竞赛经历.*简历|CTF.*简历"
---

# Resume — 技术简历创建与维护

适用于：从旧简历、GitHub、个人博客、竞赛平台和本地项目整理技术简历，并生成可投递的 PDF。核心原则：先核验事实，再写内容；先实测模板，再迁移；交付必须有真实编译和 PDF 检查结果。

## 1. 隐私和边界

- 默认只读取公开资料和用户明确提供的本地简历。
- 联系方式按用户要求保留；不要擅自增加电话、社交账号、住址或身份证信息。
- 不在公开简历中暴露本地绝对路径、凭据、API key、GPG key、私有仓库和知识库隐私。
- 用户明确要求时，才能加入电话、GitHub、博客或其他公开链接；个人信息区与项目链接分别处理。
- 不把同名 CTFtime/WeChall/GitHub 账号归并为用户身份，除非有明确的用户名、链接或用户确认。
- 不在博客 README 或公开资料中写入用户隐私。
- 不修改用户已有博客/知识库仓库；Blog repo 的 commit、push、文件移动由用户处理。

## 2. 资料发现顺序

1. 读取旧简历：
   ```bash
   find /home/<user>/Documents/resume -type f
   file /path/to/resume.pdf
   pdftotext -layout /path/to/resume.pdf -
   pdfinfo /path/to/resume.pdf
   ```
   文件内容用 `read_file`/`search_files`；PDF 文本用 `pdftotext`；不要把带行号的 `read_file` 输出直接写回文件。
2. 读取本地项目和仓库状态：
   ```bash
   git -C /path/to/repo remote -v
   git -C /path/to/repo status --short --branch
   git -C /path/to/repo log -1 --format='%ad %h %s' --date=short
   ```
   保护用户已有 dirty worktree；只读取，不擅自 commit/push/mv。
3. GitHub 公开资料优先使用 `gh` CLI/API：
   ```bash
   gh api user --jq '{login,name,blog,html_url,public_repos,followers}'
   gh repo list <user> --limit 100 --json name,description,url,isFork,isArchived,primaryLanguage,stargazerCount,pushedAt
   gh api repos/<user>/<repo>/readme --jq .content | base64 -d
   gh api repos/<user>/<repo>/commits?per_page=100
   ```
   读取 README、repo metadata、commit 时间和源码树；不能只凭 stars 或搜索摘要写成果数字。
4. 博客可用 `requests`/`curl` 读取 `atom.xml`、`rss2.xml`、首页和 about 页；解析标题、日期、URL、分类。博客内容只能证明公开写作主题，不能自动证明职业经验。
5. CTFtime：直接使用 `requests`/`BeautifulSoup` 或 `curl`，保存原始 HTML 后解析 scoreboard；检查事件名称、年份、Place、CTF points、Rating points。`web_extract` 失败时回退到 `requests`。
6. WeChall 遇到 Anubis/anti-bot 时，不能绕过验证或猜测 profile；记录为未核验，除非用户提供明确页面、截图或数据。

## 3. 事实核验纪律

为每个候选事实建立：`事实 | 来源 URL/path | 归属依据 | 状态`。

- 已核验：来源页面直接展示，且用户名/项目仓库/用户提供的账号一致。
- 用户提供：用户明确写入旧简历但外部无法核验；可在草稿中保留，标记为“需用户确认”。
- 存疑：同名账号、缺少年份的排名、未公开项目、无法区分个人/队伍的成绩；不编造成确定事实。
- CTFtime 的 `Place`、`CTF points`、`Rating points` 必须来自同一场赛事 scoreboard；不要把 challenge points 当作 team CTF points。
- 若只有旧简历中的名次而没有可确认的队伍/账号，不要把榜单中该名次的另一支队伍名称写入简历。积分若按名次从官方 scoreboard 读取，必须明确它是该榜单行的数值，不能借此声称队伍身份已核验。
- 非 CTFtime 赛事（例如线下赛区半决赛）没有 CTFtime points/rating 时写“无 CTFtime points/rating”或省略，不使用 0 代替未知。
- 保留用户原始赛事名称和数值；不要擅自纠正大小写、年份或排名含义。

## 4. 简历定位和内容写法

先决定目标岗位，再排序内容。全栈软件开发默认顺序：

1. 姓名、城市、邮箱、职位定位
2. 个人概述（技术范围 + 工程边界，2 句）
3. 教育经历
4. 技术能力（语言 / Web 后端 / 系统基础设施 / 工具）
5. 项目经历（倒序；项目名 + 链接 + 类型/角色 + 时间 + 技术栈 + 2–4 条贡献）
6. 开源/技术写作
7. 竞赛、证书和语言能力

项目 bullet 使用“做了什么 + 用什么实现 + 产生了什么可验证结果”。不要添加没有来源的 QPS、性能提升、用户数、团队规模、上线结果或“精通”。`Vibe Coding` 不作为正式技术栈，除非用户明确要求展示。

## 5. GitHub 模板检索与实测

先检索候选，再 clone 到 `/tmp`，不要直接在用户简历目录里试验：

```bash
gh search repos 'typst resume stars:>20' --limit 30 --json fullName,description,stargazersCount,updatedAt,license,url
git clone --depth 1 https://github.com/<owner>/<repo>.git /tmp/resume-template-<name>
git -C /tmp/resume-template-<name> ls-files
```

比较：中文字体、A4/多页分页、长项目标题、中英文混排、项目条目结构、长链接、ATS 可读性、许可证、最近更新时间、真实示例和本地编译结果。正式投递优先信息层级和可扫读性，不用卡片/标签/图标堆装饰。ATS 系统原理、平台差异与关键词工程细节见本地 KB 文档（ats-resume-optimization，关键词三位置布局、解析失败 35% 非战之罪、2026 语义/LLM 评分趋势）。

许可证与活跃度用 gh 核验，不要凭 README 推断：

```bash
gh api repos/<owner>/<repo>/license --jq .license.spdx_id   # 404 = 无 LICENSE，默认保留所有权利
gh api repos/<owner>/<repo> --jq '{pushed_at, stargazers_count}'
```

已验证候选（2026-09 核验）：

- `OrangeX4/Chinese-Resume-in-Typst`：当前默认模板；使用其中的 `simple-resume.typ` 作为基础，中文简历专用，SVG 图标资源和基础排版简单，适合左侧日期/中间内容与项目条目。默认字体可能不存在，须改为本机字体后重编译。注意：仓库**没有 LICENSE 文件**（GitHub API 返回 404），默认 all-rights-reserved；作为个人参考和本地使用没问题，不要作为自己的作品重新分发；最后推送 2025-03，模板代码已实测兼容 typst 0.15.1。
- `golixp/typst-resume-zh-cn`：MIT；模块化、中文优化、技能/项目组件丰富；示例依赖 Nerd Font，缺字体会 warning。
- `NorthSecond/Auto_Typst_Resume_Template`：许可证为 NOASSERTION（自定义/未识别 SPDX，2026-02 仍活跃，202 stars）；中英双语与 GitHub Actions 友好；使用前人工确认许可条款，再检查模板示例。
- `habaneraa/typst-resume-one-page`：MIT；适合内容已精简且明确需要单页；不要用压小字体替代内容取舍。
- RenderCV：适合 YAML 数据驱动和多版本输出；用户认为默认模板不好看时，应重新实测 GitHub 专用模板，而不是只微调 theme。

## 6. Bundled harness and compile toolchain

默认 harness(2026-09 重构为模板/内容分离结构):

- 模板（布局/样式/组件）: 工作副本见简历工作目录, 公开副本见本仓库
  example/template.typ; 内容文件 `#import "template.typ": *` +
  `#resume-template[ ... ]` 包裹正文
- `scripts/render_resume.sh` — compile Typst and render one PNG per PDF page
- `scripts/verify_resume.sh` — verify page count, required text, forbidden team names, and embedded fonts
- `references/harness.md` — harness usage and requirements
- 示例仓库（本仓库 example/）有 `build.sh` — 统一构建：
  typst compile → pdftoppm（固定 resume.pdf / resume-preview.png）→ verify

从模板新建简历（模板与内容分离）:

```bash
mkdir -p /tmp/my-resume && cd /tmp/my-resume
cp <repo>/example/template.typ .
# 或用自己简历工作目录里的 template.typ
# 新建 resume.typ:
#   #import "template.typ": *
#   #resume-template[ ...正文... ]
typst compile resume.typ resume.pdf
bash <repo>/skill/scripts/verify_resume.sh resume.pdf [EXPECTED_PAGES] [REQUIRED_TEXTS_FILE] [FORBIDDEN_TEXTS_FILE]
```

`verify_resume.sh` 的后两个参数是可选的每行一个子串的文本文件：required 文件默认是基线身份（示例姓名 / 城市 / 邮箱 / 竞赛、项目小节标题），forbidden 文件默认是占位私密标识（secret-team-alias / secret-account-alias，换成自己的真实队伍名/账号）；页数参数可省略，直接传 required 文件即可；给新简历换人核验时传自己的清单，空文件跳过对应检查。

Typst 分离时的两个坑（已踩平）:
1. 顶层 `#let` 定义的组件（item/skill/project）才会被内容 `import *` 导入；
   模板函数体内的 `set`/`show` 命令**不带 `#` 前缀**（函数体是代码模式）
2. 颜色常量（cv-color 等）必须放顶层——组件函数引用它们，放进
   resume-template 函数体内会导致组件作用域找不到

工具链实测（2026-09-05）：本机 typst 0.15.1 编译通过（示例 1 页、无字体 warning），
Noto Sans CJK SC 使用字重全部嵌入；模板/内容分离重构时已实测渲染与内嵌版一致；`verify_resume.sh`
默认模式、自定义文件模式、缺失文本负例均验证通过。

## 7. 编译工具链

系统检查：

```bash
command -v typst
python --version
fc-list :lang=zh family
command -v pdftotext pdfinfo pdffonts pdftoppm
```

RenderCV 使用隔离环境，避免破坏 Arch 的 externally-managed Python：

```bash
python -m venv /tmp/rendercv-venv
/tmp/rendercv-venv/bin/pip install 'rendercv[full]'
/tmp/rendercv-venv/bin/rendercv new '<Name>'
/tmp/rendercv-venv/bin/rendercv render '/path/CV.yaml'
```

Typst：

```bash
typst compile --root /path/to/project-dir /path/to/project-dir/resume.typ /path/to/output.pdf
```

若模板引用相对路径，使用 `--root`：它必须指向包含输入文件的**项目目录**（不是文件本身）。
字体 warning 必须处理；不要把 warning 当成功交付。

字体原则：中文正文优先使用经 `fc-list` 确认存在的 `Noto Sans CJK SC` 或 `Source Han Sans SC`。使用 SVG 图标时验证资源路径；缺图标不能用“截图看起来正常”代替。技术简历正文默认左对齐，避免英文、数字和符号被两端对齐拉伸。

## 8. PDF 和视觉验证门禁

生成后必须真实检查：

```bash
pdfinfo /path/resume.pdf | grep -E '^(Pages|Page size|File size)'
pdftotext -layout /path/resume.pdf > /tmp/resume.txt
pdffonts /path/resume.pdf
pdftoppm -png -f 1 -singlefile -r 150 /path/resume.pdf /tmp/resume-page-1
pdftoppm -png -f 2 -singlefile -r 150 /path/resume.pdf /tmp/resume-page-2   # 多页时才需要第 2 页; 单页 PDF 会报 Wrong page range
```

文本检查至少包含姓名、城市、邮箱、项目标题、技术栈、关键 URL 和所有用户要求的竞赛记录。用 Python 断言字符串存在；多页时检查每页文本和页数。项目标题折行检测必须用 `pdftotext -raw` 匹配完整标题字符串（`-layout` 下用片段 grep 会漏报——例如"输入法集成"在"集/成"之间折行时，两行都不含"输入法集成"整串），`-raw` 模式按渲染顺序出文本，折行标题会分裂成多行，完整标题匹配不到即折行。视觉检查用 `vision_analyze`，关注溢出、截断、异常空白、中文缺字、技术栈挤压、项目名/类型/日期对齐、长链接孤立换行、页码和打印可读性。

如果内容自然变为两页，允许两页；不要用极小字号或窄页边距强塞一页，除非用户明确要求一页并同意删减。

## 9. 竞赛部分

- 用户要求不显示队伍名时，只写赛事名和名次；若用户要求，才保留年份。不要显示用户队伍名。
- 默认不写 CTF points 或 Rating points，除非用户明确要求保留。
- 多场赛事按年份或时间倒序分组；不能把多场压成一条导致赛事与名次无法对应。
- 旧简历中的无年份记录不得擅自补年份；只有官方 scoreboard 能唯一匹配赛事和名次时才补年份及积分，并保留“原简历记录”的来源说明。
- 没有 CTFtime scoreboard 的线下/本地赛事记录不填虚构 points/rating。

## 10. 交付报告

最终报告只说：使用的模板仓库、许可证和实际编译结果；修改的源文件和生成的 PDF/预览路径；核验过的来源和仍需用户确认的事实；PDF 页数、字体、文本、链接和视觉检查结果；明确的分页或内容取舍。不得声称链接可点击而没有检查 PDF link annotations 或至少确认 Typst link 编译成功。
