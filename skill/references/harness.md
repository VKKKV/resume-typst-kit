# Resume harness

This file documents the harness bundled with the resume skill.

- 模板（布局/样式/组件）：工作副本在简历工作目录, 公开副本在本仓库
  example/template.typ。
  内容文件用法：`#import "template.typ": *` + `#resume-template[ ... ]`。
- `scripts/render_resume.sh` — compile Typst and render one PNG per PDF page (PNG 输出到 PDF 同级目录,不再落 cwd)。
- `scripts/verify_resume.sh` — verify page count, required text, forbidden team names, and embedded fonts.
- 组件：`item(a,b,c)` 三列条目（左名称/中内容/右日期, 列宽 38%/1fr/auto, 日期 box 防折行）,
  `skill(label, details)` 技术能力紧凑行, `tech(stack)` 项目技术栈小号主色,
  `project(title, period, stack, desc, details, role:)` 项目条目。
- 样式参数（2026-09 实测基线）：左对齐正文、9.2pt、par spacing 0.85em、列表 spacing 0.55em、
  页边距 x1.35cm y1.4cm、小节标题加粗+蓝色分割线、单页隐藏页码多页才显示。
- 模板函数体内 `set`/`show` 不带 `#` 前缀（代码模式）；颜色常量放顶层（组件共享）。
- 示例仓库（本仓库 example/）有 `build.sh` 统一构建：
  typst compile → pdftoppm（固定 resume.pdf / resume-preview.png）→ verify
- 分页策略：内容自然流动, 不设强制分页; 加内容须删等量内容, 小节完整性优先。

Upstream template: https://github.com/OrangeX4/Chinese-Resume-in-Typst

模板只含布局/样式, 不含简历内容（内容在 resume.typ）。新简历: 复制 template.typ
到工作目录, 新建 resume.typ 用 `#import` + `#resume-template[ ... ]`, 产物留在工作目录。

## Workspace workflow (本仓库 example/, 2026-09 起)

- 示例内容权威源: `example/resume.typ`; 模板: `example/template.typ`(与简历工作目录同步)
- example/ 属于本仓库, **不是独立 git 仓库**; 构建产物 `resume.pdf` / `resume-preview.png` 被忽略, 不弄脏工作区
- 每次编辑 resume.typ 后立即渲染并校验:
  ```bash
  cd example
  ./build.sh            # 编译 + 首页 PNG + verify(1 页基线)
  # 或手动: bash ../skill/scripts/verify_resume.sh resume.pdf 1
  git add resume.typ template.typ && git commit -m "resume: <改动摘要>"
  ```
- 审查顺序:先读 typ 源码(格式/结构/事实),再渲染;不要频繁用视觉模型检查 PDF 输出
- 模板不随 skill 分发; 新建简历从 example/template.typ 复制

## Commands

基于示例新建自己的简历（全部命令在仓库根执行）:

```bash
cd <repo>
mkdir -p /tmp/my-resume && cd /tmp/my-resume
cp <repo>/example/template.typ .
cp <repo>/example/resume.typ resume.typ   # 以此为底稿改写, 或手写内容
# 编辑 resume.typ: 替换姓名/城市/邮箱/教育/技能/项目/竞赛为真实信息
typst compile resume.typ resume.pdf
bash <repo>/skill/scripts/verify_resume.sh resume.pdf [EXPECTED_PAGES] [REQUIRED_TEXTS_FILE] [FORBIDDEN_TEXTS_FILE]
# 需要每页 PNG 预览时: bash <repo>/skill/scripts/render_resume.sh resume.typ resume.pdf
```

`render_resume.sh` — typst compile + 每页 PNG 渲染（PNG 落在 PDF 同级目录）:
`render_resume.sh INPUT.typ OUTPUT.pdf [PNG_PREFIX]`，PNG_PREFIX 只取 basename。

`verify_resume.sh` 的第 3、4 个参数是可选的文本文件（每行一个子串）：
`EXPECTED_PAGES` 可省略——直接传必需文本文件时脚本会按内容识别。
- REQUIRED_TEXTS_FILE — 必须存在的文本（默认：示例姓名 / 城市 / 邮箱 / 竞赛经历 / 项目经历）。换人时传自己的核对清单，空文件跳过检查。
- FORBIDDEN_TEXTS_FILE — 禁止出现的文本（默认占位：secret-team-alias / secret-account-alias，换成自己的真实队伍名/账号）。空文件跳过检查。

## Verified toolchain (2026-09-04)

- typst 0.15.1：`scripts/render_resume.sh` 编译示例（1 页输出），无字体 warning。
- Noto Sans CJK SC 已安装；`pdffonts` 确认实际使用字重（Regular/Bold/Light）全部嵌入。
- `verify_resume.sh` 默认模式、自定义文件模式与缺失文本负例（exit 1）均已实测。

Requirements: `typst`, `pdfinfo`, `pdftotext`, `pdffonts`, and `pdftoppm`. The template uses `Noto Sans CJK SC`, which must be available in the system font catalog.