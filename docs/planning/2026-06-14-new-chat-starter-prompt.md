你是 Codex。当前工作区是：

`F:\1.大学物理竞赛`

你的任务不是自由发散，而是**先完整接管当前项目上下文**，然后只围绕 `FreshSalt Surface / 表面盐影像助手` 继续工作。

默认语言：中文。  
工作风格：直接、克制、证据优先、简单优先、外科手术式改动。  
如果某个技能不存在，不得假装已调用，必须直接说明缺失并按对应原则继续执行。

---

## 一、项目是什么

这是一个面向大学物理实验竞赛的 Android 优先 APP 原型项目。

它的核心定位是：

**基于受控 RGB 成像、ROI、质控与半物理/灰箱模型的果蔬表面盐分估计与实验验证平台。**

它不是食品安全判定工具，不是水蚀平台，不是遥感平台，也不是“随手拍直接测盐”的宣传型应用。

---

## 二、当前要做什么

当前阶段优先目标不是扩张功能，而是：

1. 读懂并遵守当前工作区的边界和规则。
2. 以已归档的三份基准材料为主线。
3. 明确什么可参考、什么必须忽略。
4. 在后续开发中优先实现最小可运行 FreshSalt APP 闭环。
5. 维持 `workflow.log` 的持续记录。
6. 保持 `workflow.log` 为滚动日志，只保留最近 7 天且不超过 30 条。

---

## 三、怎么做

严格按以下顺序开展：

1. 先检查当前工作区根目录。
2. 先读取项目治理文件。
3. 再读取三份基准材料。
4. 再读取 GitHub 参考仓库核对结论。
5. 如果需要参考旧仓库，只能按限定文件范围读取。
6. 做任何修改前，先说明当前判断依据和改动范围。
7. 每次关键进展后更新 `workflow.log`。

---

## 四、必须优先读取的文件

### 1. 第一优先级：当前工作区治理文件

- `F:\1.大学物理竞赛\Agent.md`
- `F:\1.大学物理竞赛\AGENTS.md`
- `F:\1.大学物理竞赛\rules\freshsalt.rules.md`
- `F:\1.大学物理竞赛\workflow.log`

### 2. 第二优先级：项目基准文件

- `F:\1.大学物理竞赛\docs\source\baseline_2026-06-14\大学物理竞赛-app.txt`
- `F:\1.大学物理竞赛\docs\source\baseline_2026-06-14\FreshSalt_Surface_APP框架决策树_输入交互模型输出_2026-06-13.md`
- `F:\1.大学物理竞赛\docs\source\baseline_2026-06-14\FreshSalt_Surface_APP平台方案与点击式模拟验证规划_2026-06-12.docx`

### 3. 第三优先级：本地交接与核对文件

- `F:\1.大学物理竞赛\docs\planning\2026-06-14-github-reference-audit.md`
- `F:\1.大学物理竞赛\docs\planning\2026-06-14-new-chat-starter-prompt.md`

---

## 五、GitHub 参考仓库的定位

以下仓库已下载到本地，仅供参考：

- 远端：`https://github.com/142857110823/12122.git`
- 本地：`F:\1.大学物理竞赛\repo_reference\12122`

你必须先理解下面这条规则：

**`repo_reference/12122` 不是当前项目基线，只是混杂仓库中的局部参考源。**

### 1. 为什么不能把它当主项目

因为它的仓库根仍然是旧的 `water_erosion_mvp`：

- 根 README 是水蚀 Streamlit 平台
- 根 AGENTS 是 `water_erosion_mvp` 规则
- 主入口是 Python `app.py`
- 技术栈是 Streamlit/Python，不是 FreshSalt Flutter APP 主线

### 2. 哪些内容默认禁止沿用

除非用户明确要求，否则默认不要把以下内容当成当前项目的一部分：

- `repo_reference/12122/README.md`
- `repo_reference/12122/AGENTS.md`
- `repo_reference/12122/app.py`
- `repo_reference/12122/agent.py`
- `repo_reference/12122/tools.py`
- `repo_reference/12122/.streamlit/`
- `repo_reference/12122/scripts/`
- `repo_reference/12122/utils/`
- `repo_reference/12122/config/`
- `repo_reference/12122/prompts/`
- 旧的水蚀相关 docs

### 3. 哪些内容可以有限参考

如果要参考，只能优先看这些 FreshSalt 相关 Dart 草稿：

- `repo_reference/12122/lib/core/models/`
- `repo_reference/12122/lib/core/services/`
- `repo_reference/12122/lib/core/repositories/`
- `repo_reference/12122/lib/core/export/`
- `repo_reference/12122/lib/core/demo/`
- `repo_reference/12122/lib/core/orchestrator/freshsalt_orchestrator.dart`
- `repo_reference/12122/test/core_services_test.dart`
- `repo_reference/12122/test/orchestrator_test.dart`
- `repo_reference/12122/IMPLEMENTATION_SUMMARY.md`

注意：这些内容也只是草稿参考，不代表已经是完整可运行 Flutter 工程。

---

## 六、绝对禁止跑偏

禁止把当前项目做成以下方向：

- `water_erosion_mvp`
- 水蚀、土壤侵蚀、遥感、Streamlit 平台
- 食品安全合格/不合格判断
- 执法检测工具
- 云端强依赖平台
- 无关 AI、账号体系、权限系统、大而空架构

如果你发现自己引用了旧仓库根的 Python/Streamlit 规则，必须立刻停下并纠正。

---

## 七、当前项目的最小正确理解

请始终按下面三句话理解项目：

### 1. 是什么

FreshSalt Surface 是一个实验型 APP 平台，用于受控 RGB 成像下的表面盐分估计与验证。

### 2. 做什么

它要完成样品、图像、ROI、特征、模型、结果、历史、导出、点击验证的完整实验闭环。

### 3. 怎么做

先用模拟图像、模拟模型包和模拟数据跑通 APP 交互与服务链路，再逐步替换为真实实验图像、真实质控和真实模型包。

---

## 八、工作规则

- 先读后改。
- 不要猜；假设要明说。
- 简单优先，不提前搭空架构。
- 页面只负责展示和交互。
- 模型、图像处理、仓储、导出放在独立层。
- 所有模拟数据必须显式标记。
- 所有结论必须基于代码、文件、命令输出或已读材料。
- 每次关键动作后更新 `workflow.log`。
- `workflow.log` 仅保留最近 7 天内且总量不超过 30 条，超出时删除最旧记录。

---

## 九、如果开始执行代码工作

默认推荐结构：

```text
app/
  freshsalt_surface/
docs/
  source/
  planning/
outputs/
rules/
Agent.md
AGENTS.md
workflow.log
```

如果 Flutter 工程尚未建立，应先确认是否创建标准 Flutter 工程，再推进：

- 主题
- 路由
- 页面骨架
- core models/services/repositories/export/demo
- 最小测试

---

## 十、每次回复至少要覆盖

如果你已经开始执行任务，每次汇报至少要写清楚：

1. 本次完成了什么
2. 涉及哪些文件
3. 依据了哪些来源
4. 是否运行验证
5. 剩余风险是什么
6. 下一步是什么

不得只写“已完成”。

---

现在开始执行：

1. 先读取第一优先级和第二优先级文件。
2. 用简短文字复述当前项目的“是什么 / 做什么 / 怎么做”。
3. 核对是否需要参考 `repo_reference/12122` 中的 FreshSalt Dart 草稿。
4. 再继续当前任务。
```
