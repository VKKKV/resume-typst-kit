#!/usr/bin/env bash
# ============================================================================
# 示例简历构建脚本 — 模板/内容分离后的统一工作流
# 输入: resume.typ (内容) + template.typ (模板)
# 输出: resume.pdf          — 最终 PDF (git 忽略)
#       resume-preview.png  — 第一页预览 PNG (git 忽略)
# 注: 渲染产物一律不入库 (.gitignore 已忽略 *.pdf/*.png);
#     typst 在 PDF 内嵌创建时间戳, 每次构建二进制都不同,
#     忽略产物后 build.sh 可反复执行且 git status 保持干净。
# 校验: 调用仓库内 skill/scripts/verify_resume.sh (示例版, 默认基线=虚构示例);
#       校验脚本缺失时视为坏检出, 构建失败而不是静默跳过。
#
# 用法: ./build.sh
# 注意: 依赖 typst / pdftoppm / pdfinfo，需先安装
# ============================================================================
set -euo pipefail

# 软链安全: 无论以真实路径还是软链调用, 都以脚本真实位置为根
SELF="$(readlink -f "${BASH_SOURCE[0]:-$0}")"
cd "$(dirname "$SELF")"

ROOT="$(cd .. && pwd)"
OUT="resume.pdf"
PNG="resume-preview.png"

echo "==> typst compile resume.typ -> $OUT"
typst compile resume.typ "$OUT"

echo "==> pdftoppm -> $PNG"
# -singlefile 只输出第一页; 多页简历想预览全部页时去掉该参数
pdftoppm -png -f 1 -singlefile -r 150 "$OUT" "resume-preview"

PAGES="$(pdfinfo "$OUT" | awk '/^[[:space:]]*Pages:/{print $2}')"
echo "==> PDF pages: $PAGES"

VERIFY="$ROOT/skill/scripts/verify_resume.sh"
if [[ -f "$VERIFY" ]]; then
  echo "==> verify_resume.sh"
  bash "$VERIFY" "$OUT" 1
else
  echo "==> 错误: 未找到 $VERIFY (坏检出?)" >&2
  exit 1
fi

echo "==> done: $OUT + $PNG"
ls -la "$OUT" "$PNG"