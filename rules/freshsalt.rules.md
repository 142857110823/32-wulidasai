# FreshSalt Surface Rules

## 1. 真实优先

- 不装懂，不硬猜，不掩盖不确定性。
- 假设必须说清楚；拿不准就先核对文件和命令结果。
- 没验证过的内容，不写成“已完成”。

## 2. 简单优先

- 用最少的东西解决当前问题。
- 不做现阶段不需要的功能。
- 不为一次性问题提前搭通用框架。
- 不为“灵活性”增加无效配置。

## 3. 外科手术式改动

- 只改必须改的内容。
- 不顺手改无关格式、命名和结构。
- 优先沿用当前项目已经成立的风格和分层。
- 看到无关冗余，先标注，再决定是否清理。

## 4. 先检查再执行

- 先检查当前项目、相关代码、关键配置、已有约定、`AGENTS.md`、规则文件、可运行命令。
- 优先复用现有模式、模块、结构和工作流。
- 能直接落地的工作，直接落地，不停留在空方案阶段。

## 5. 项目唯一边界

本项目只围绕以下目标展开：
- 大学物理竞赛 APP
- 受控 RGB 成像
- ROI 与灰卡质控
- 半物理/灰箱模型
- 模拟数据点击验证
- 后续真实实验接入接口

明确不做：
- `water_erosion_mvp`
- 水蚀、土壤侵蚀、遥感、Streamlit 平台
- 食品安全判定
- 执法检测工具
- 云端强依赖和无关大架构

## 6. 数据与结果规则

- 当前真实实验未开展前，结果、历史、报告可使用模拟数据。
- 所有模拟数据必须显式标记，不得伪装成真实实验结果。
- 结果至少绑定 `model_id`、`source_mode`、`valid_range`、`hardware_profile_id`。
- 单位统一保持可解释，例如 `mg/cm2 NaCl eq.`。
- 风险说明必须存在，且不得写成食品安全结论。

## 7. 分层规则

- UI 页面层：展示状态、接收输入、承载点击流程。
- Service 层：编排业务流程和状态流转。
- Vision / Feature 层：图像处理、ROI、特征提取。
- Model 层：模型输入整理、推理、范围判定、置信度。
- Repository / Export 层：历史记录、CSV、报告输出。

## 8. 记录与验证

- 关键动作必须更新 `workflow.log`。
- 记录至少包含：
  - timestamp
  - touched files
  - progress or issue
  - notes or risks
- `workflow.log` 从现在开始默认只用英文记录。
- 不再向 `workflow.log` 写中文内容。
- 后续进入开发或修复阶段时，优先给出最小验证证据。
- `workflow.log` 只保留最近 7 天以内且总量不超过 30 条记录。
- 超限时必须滚动删除最旧日志，禁止无限追加。

## 9. 停止条件

出现以下情况先停下并说明：
- 基准文件互相冲突
- 需求偏离 FreshSalt Surface 项目边界
- 需要覆盖或迁移大量既有文件
- 需要写入工作区外路径
- 需要引入高风险依赖

## 10. Plan Output Default

When providing a plan, proposal, or next-step outline, use this default structure:
- Current progress
- Remaining work
- Execution steps
- Verification criteria
- Acceptance criteria
