# FreshSalt Surface 三大核心续跑提示词

```markdown
[$superpowers:using-superpowers] [$freshsalt-platform-priority-guard] [$documents:documents] [$superpowers:verification-before-completion]

项目定位：FreshSalt Surface / 表面盐影像助手，只围绕大学物理竞赛实验型 Flutter APP 展开，不混入 `water_erosion_mvp` 或任何其他平台。

本轮只围绕三大核心推进，禁止再做细节缝补、无关测试补强、次级模块扩张或代码结构自我说服：

1. 手机拍照能力
2. 真实图片处理能力
3. UI 是否符合设计图

## 必须先做的事

1. 检查当前目录、已有文件、规则文件、可运行命令。
2. 读取并遵守：
   - `F:\1.大学物理竞赛\AGENTS.md`
   - `F:\1.大学物理竞赛\rules\freshsalt.rules.md`
   - `F:\1.大学物理竞赛\docs\source\baseline_2026-06-14\大学物理竞赛-app.txt`
   - `F:\1.大学物理竞赛\docs\source\baseline_2026-06-14\FreshSalt_Surface_APP框架决策树_输入交互模型输出_2026-06-13.md`
   - `F:\1.大学物理竞赛\docs\source\baseline_2026-06-14\FreshSalt_Surface_APP平台方案与点击式模拟验证规划_2026-06-12.docx`
3. 使用 `documents` 技能理解基准 docx。
4. 浏览器可见结果优先于代码结构自洽。

## 三项任务与各自要求

### 任务 1：手机拍照能力

要求：
- 判断当前 APP 是否支持真实手机拍照。
- 核对依赖、权限声明、权限请求、真实预览、真实 I0/I1 输入链路。
- 如果需要提权，必须明确提权路径是否存在。
- 如果只有模拟图片、mock path、占位文案，直接判定未满足。

调用重点：
- `using-superpowers`
- `freshsalt-platform-priority-guard`
- `verification-before-completion`

验收标准：
- 必须同时具备真实相机依赖、权限链路、真实预览/拍照、真实文件输入和可见证据。

### 任务 2：真实图片处理能力

要求：
- 判断是否真的处理图像像素，而不是只消费 metadata。
- 核对输入图像、ROI、质控、特征提取、差分图、结果输入是否来自真实图像内容。
- 如果仍是 metadata 驱动或 mock diff 路径驱动，直接判定未满足。

调用重点：
- `using-superpowers`
- `verification-before-completion`

验收标准：
- 必须同时具备真实图像解码、真实 ROI 裁剪、真实像素级质控、真实特征提取、真实结果输入链路。

### 任务 3：UI 设计符合度

要求：
- 完整理解基准 docx 的首页、采集预测、结果详情设计意图。
- 先核首页与主链，再核结果页与整体统一性。
- 重点看平台第一屏、主链叙事、文案密度、层级、间距、模块观感。
- 不接受“路由存在/页面存在/组件存在”作为前端完成证据。
- 结果页若空白或证据不稳定，直接判定 UI 未满足。

调用重点：
- `freshsalt-platform-priority-guard`
- `documents`
- `verification-before-completion`

验收标准：
- 首页第一屏可见对齐。
- 主链可见且具备实验测量流程感。
- 结果页稳定可见，具备主结果、范围标尺、历史趋势、模型解释、边界提示。
- 浏览器可见证据强于代码结构证明。

## 过程约束

- 不改代码，除非用户明确要求进入修复阶段。
- 不补无关测试。
- 不扩无关模块。
- 每发现一个偏差或阻塞，先写入：
  - `F:\1.大学物理竞赛\outputs\workflow-error-2026-06-15.md`
- 每个关键步骤同步更新：
  - `F:\1.大学物理竞赛\workflow.log`
- `workflow.log` 只用英文，且只保留最近 7 天内最多 30 条。

## 输出要求

- 如果三项都未满足，按三项分别给出结论、证据、影响。
- 如果某项满足，必须给出当前状态下的直接证据。
- 最终输出优先给浏览器可见结论，再给文件级/代码级结论。
- 方案输出默认使用五段：
  - 当前进度
  - 待完成工作
  - 执行步骤
  - 验证标准
  - 验收条件
```
