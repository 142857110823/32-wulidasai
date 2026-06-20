# FreshSalt Surface Bootstrap Design

**日期**: 2026-06-14

## 目标

在当前工作区内新建 `app/freshsalt_surface` 标准 Flutter 工程，作为 `FreshSalt Surface / 表面盐影像助手` 的唯一 APP 主线；同时仅从 `repo_reference/12122` 中按限定范围迁入可有限参考的 Dart 核心层草稿，形成后续开发可继续演进的初始骨架。

## 依据

本设计统一以以下三份基准文档为主：

- `大学物理竞赛-app.txt`
- `FreshSalt_Surface_APP框架决策树_输入交互模型输出_2026-06-13.md`
- `FreshSalt_Surface_APP平台方案与点击式模拟验证规划_2026-06-12.docx`

同时受以下治理文件约束：

- `AGENTS.md`
- `Agent.md`
- `rules/freshsalt.rules.md`
- `docs/planning/2026-06-14-new-chat-starter-prompt.md`
- `docs/planning/2026-06-14-github-reference-audit.md`

## 明确边界

### 做什么

- 新建标准 Flutter 工程。
- 建立与基准文档一致的目录结构、主题、路由和最小页面骨架。
- 迁入并校正允许有限参考的 `core` 草稿：
  - `models`
  - `services`
  - `repositories`
  - `export`
  - `demo`
  - `orchestrator`
  - 对应两份测试
- 让后续开发可以在新工程内继续完成演示模式、采集预测、结果详情、历史、导出、点击验证台。

### 不做什么

- 不把 `repo_reference/12122` 当主项目基线。
- 不迁入 `README.md`、`AGENTS.md`、`app.py`、`.streamlit/`、`scripts/`、`utils/`、`config/`、`prompts/` 等旧仓库根资产。
- 不引入 `water_erosion_mvp`、Python、Streamlit、食品安全判定、执法检测、遥感/水蚀方向。
- 不在本轮实现复杂 UI、真实相机、真实图像处理或真实模型训练。

## 参考仓库使用策略

`repo_reference/12122` 只作为受限参考源，且仅限文件级参考。迁入时遵循以下原则：

1. 先保留职责，再修正文案、字段、单位和命名。
2. 所有模拟数据保留 `simulated` 标记，并在后续 UI 中持续可见。
3. 以基准文档为准，必要时重命名或删减草稿中的不合适内容。
4. 对存在乱码或表述不清的注释，不原样继承。

## 新工程结构

目标结构：

```text
app/freshsalt_surface/
  lib/
    app.dart
    main.dart
    routing/
      app_router.dart
    theme/
      app_theme.dart
    core/
      demo/
      export/
      models/
      orchestrator/
      repositories/
      services/
    features/
      home/
      capture/
      result/
      history/
      report/
      demo_validation/
    shared/
      widgets/
  test/
```

## 首轮页面骨架范围

本轮只建立最小页面骨架，不做完整业务 UI：

- `HomePage`
- `CapturePage`
- `ResultPage`
- `HistoryPage`
- `ReportPage`
- `DemoValidationPage`

页面职责仅限：

- 展示当前模块存在
- 提供基础导航入口
- 预留后续接线点
- 明确演示/模拟边界提示

模型、图像处理、推理、导出逻辑不进入页面层。

## 核心层迁移策略

### models

直接迁入并按基准文档校正：

- `ModelBundle`
- `FeatureVector`
- `PredictionResult`
- `QualityControlResult`
- `ClickValidationCase`

校正点：

- 单位统一向 `mg/cm2 NaCl eq.` 靠拢。
- JSON 字段保持与基准文档一致。
- `source_mode`、`model_id`、`valid_range`、`hardware_profile_id` 等边界字段必须保留。

### services

迁入以下服务作为纯 Dart 业务层初稿：

- `ModelBundleService`
- `QualityControlService`
- `FeatureExtractionService`
- `PredictionService`
- `ClickValidationService`

校正点：

- 不依赖 UI。
- 不写与 Flutter 页面耦合的逻辑。
- 保留“模拟数据优先”的第一阶段行为。

### repositories

迁入内存仓储实现：

- `SessionRepository`
- `ClickValidationRepository`

作用仅为本地演示和测试，不在本轮引入 SQLite/Drift。

### export

迁入 `ExportService`，保留 CSV 文本和报告预览生成能力。输出字段以基准文档要求为准。

### demo

迁入 mock 数据与点击验证模板，作为演示模式和测试输入源。

### orchestrator

迁入并校正 `FreshSaltAppOrchestrator`，把它作为首轮“全链路编排入口”，用于串联模型包、质控、特征、推理、保存与点击验证。

## 测试策略

迁入并修正两份测试：

- `test/core_services_test.dart`
- `test/orchestrator_test.dart`

本轮目标：

- 让测试基于新工程路径可运行。
- 修正导入路径、中文乱码注释和必要字段。
- 不额外扩张测试范围，只优先确保参考草稿中的核心行为可以在新工程落地。

## 错误处理与风险

### 已知风险

- 参考草稿不是完整 Flutter 工程。
- 草稿中的部分注释和字符串存在乱码。
- 当前工作区不是 git 仓库，无法按 superpowers 文档执行 commit。
- Flutter 版本可用，但工程创建后可能暴露依赖或 API 兼容问题。

### 对应处理

- 把迁移限制在核心层和最小页面骨架。
- 对乱码注释做最小清理，不影响逻辑。
- 明确记录“未 commit”的事实，不伪造 git 结果。
- 以 `flutter create` 生成的标准结构为准，必要时对参考草稿做兼容性修正。

## 完成标准

本轮完成以以下结果为准：

1. `app/freshsalt_surface` Flutter 工程创建成功。
2. 页面骨架、主题、路由存在并可通过 `flutter analyze` 检查。
3. 允许参考范围内的 `core` 草稿与两份测试已迁入并完成基本校正。
4. 模拟数据与边界提示没有丢失。
5. 未混入 `water_erosion_mvp` 或旧仓库根目录资产。
6. `workflow.log` 已记录本轮关键动作。

## 说明

当前工作区不是 git 仓库，因此本轮不会执行 spec/plan commit；该偏差来自环境事实，不是省略。
