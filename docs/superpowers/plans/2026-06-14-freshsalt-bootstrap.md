# FreshSalt Surface Bootstrap Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在当前工作区中创建 `app/freshsalt_surface` Flutter 工程，并按限定范围迁入 FreshSalt 核心层草稿作为后续开发底座。

**Architecture:** 先用 `flutter create` 建立标准 APP 骨架，再补入主题、路由和最小页面框架；随后只迁移允许参考的 `core` 纯 Dart 层与测试，并按三份基准文档修正字段、边界和目录。UI 页面仅作导航与承载，核心业务继续放在 `lib/core`。

**Tech Stack:** Flutter 3.22.0, Dart 3.4.0, Flutter Material 3, 本地内存 repository, 纯 Dart service/model 层

---

### Task 1: 创建 Flutter 工程

**Files:**
- Create: `app/freshsalt_surface/**`

- [ ] **Step 1: 创建目标目录的父目录**

Run: `New-Item -ItemType Directory -Force app | Out-Null`
Expected: `app/` 存在

- [ ] **Step 2: 用 Flutter 创建标准工程**

Run: `flutter create app/freshsalt_surface`
Expected: 标准 Flutter 工程生成，包含 `lib/`, `test/`, `pubspec.yaml`

- [ ] **Step 3: 进入工程拉取依赖**

Run: `flutter pub get`
Expected: 依赖解析成功

### Task 2: 建立 APP 主题、路由与页面骨架

**Files:**
- Modify: `app/freshsalt_surface/lib/main.dart`
- Create: `app/freshsalt_surface/lib/app.dart`
- Create: `app/freshsalt_surface/lib/routing/app_router.dart`
- Create: `app/freshsalt_surface/lib/theme/app_theme.dart`
- Create: `app/freshsalt_surface/lib/features/home/home_page.dart`
- Create: `app/freshsalt_surface/lib/features/capture/capture_page.dart`
- Create: `app/freshsalt_surface/lib/features/result/result_page.dart`
- Create: `app/freshsalt_surface/lib/features/history/history_page.dart`
- Create: `app/freshsalt_surface/lib/features/report/report_page.dart`
- Create: `app/freshsalt_surface/lib/features/demo_validation/demo_validation_page.dart`

- [ ] **Step 1: 用统一入口替换默认 `main.dart`**

目标：`main.dart` 只做 `runApp(const FreshSaltApp())`

- [ ] **Step 2: 创建 `app.dart`，挂载 MaterialApp**

要求：
- 标题为 `FreshSalt Surface`
- 使用 `AppTheme.light()`
- 使用 `AppRouter.onGenerateRoute`
- 默认首页为 `HomePage`

- [ ] **Step 3: 创建主题文件**

要求：
- Material 3
- 主色贴近基准文档中的深青绿色
- 不做复杂视觉

- [ ] **Step 4: 创建路由文件**

要求：
- 提供首页、采集、结果、历史、报告、点击验证台的命名路由

- [ ] **Step 5: 创建最小页面骨架**

要求：
- 每页为独立 `Scaffold`
- 页面内明确显示当前页面名称
- 首页提供跳转按钮
- 页面中显示“模拟数据/实验验证用途”边界提示

### Task 3: 迁入并校正 core 模型层

**Files:**
- Create: `app/freshsalt_surface/lib/core/models/model_bundle.dart`
- Create: `app/freshsalt_surface/lib/core/models/feature_vector.dart`
- Create: `app/freshsalt_surface/lib/core/models/prediction_result.dart`
- Create: `app/freshsalt_surface/lib/core/models/quality_control_result.dart`
- Create: `app/freshsalt_surface/lib/core/models/click_validation_case.dart`

- [ ] **Step 1: 从允许参考文件迁入模型定义**

来源：
- `repo_reference/12122/lib/core/models/*.dart`

要求：
- 保留核心字段
- 去除乱码注释
- 不引入无关依赖

- [ ] **Step 2: 校正字段与单位**

要求：
- 保留 `model_id`、`source_mode/source`、`hardware_profile_id`、`valid_range`
- 结果单位对外统一为 `mg/cm2 NaCl eq.`

### Task 4: 迁入并校正 service/repository/export/demo/orchestrator

**Files:**
- Create: `app/freshsalt_surface/lib/core/services/model_bundle_service.dart`
- Create: `app/freshsalt_surface/lib/core/services/quality_control_service.dart`
- Create: `app/freshsalt_surface/lib/core/services/feature_extraction_service.dart`
- Create: `app/freshsalt_surface/lib/core/services/prediction_service.dart`
- Create: `app/freshsalt_surface/lib/core/services/click_validation_service.dart`
- Create: `app/freshsalt_surface/lib/core/repositories/session_repository.dart`
- Create: `app/freshsalt_surface/lib/core/repositories/click_validation_repository.dart`
- Create: `app/freshsalt_surface/lib/core/export/export_service.dart`
- Create: `app/freshsalt_surface/lib/core/demo/mock_data.dart`
- Create: `app/freshsalt_surface/lib/core/demo/click_validation_template.dart`
- Create: `app/freshsalt_surface/lib/core/orchestrator/freshsalt_app_orchestrator.dart`

- [ ] **Step 1: 迁入服务层并修正导入**

要求：
- 路径改为新工程内相对路径
- 不依赖旧仓库结构

- [ ] **Step 2: 迁入 repository 和 export**

要求：
- 保持内存实现
- CSV 字段符合基准文档

- [ ] **Step 3: 迁入 demo 数据**

要求：
- 保留低/中/高负载和异常 mock 数据
- 保留 `simulated` 标记

- [ ] **Step 4: 迁入 orchestrator**

要求：
- 文件名改为 `freshsalt_app_orchestrator.dart`
- 保留全链路编排职责
- 修正导入路径与必要命名

### Task 5: 迁入并修正测试

**Files:**
- Create: `app/freshsalt_surface/test/core_services_test.dart`
- Create: `app/freshsalt_surface/test/orchestrator_test.dart`

- [ ] **Step 1: 迁入两份测试**

来源：
- `repo_reference/12122/test/core_services_test.dart`
- `repo_reference/12122/test/orchestrator_test.dart`

- [ ] **Step 2: 修正导入路径和类型名**

要求：
- 导入指向 `lib/core/**`
- 与新文件名保持一致

- [ ] **Step 3: 保留最小测试目标**

要求：
- 模型包加载/激活
- 质控通过/失败
- 特征提取
- 预测结果
- orchestrator 全链路

### Task 6: 运行验证并记录

**Files:**
- Modify: `workflow.log`

- [ ] **Step 1: 运行格式与静态检查**

Run: `dart format lib test`
Expected: 代码格式化完成

- [ ] **Step 2: 运行分析**

Run: `flutter analyze`
Expected: 无 error；若有 warning 如实记录

- [ ] **Step 3: 运行测试**

Run: `flutter test`
Expected: 测试输出明确；通过或失败均如实记录

- [ ] **Step 4: 更新 `workflow.log`**

要求：
- 记录创建 Flutter 工程
- 记录迁入限定 core 草稿
- 记录验证结果
- 如当前工作区不是 git 仓库，明确写明未 commit

## 自检

- Spec 覆盖：工程创建、页面骨架、限定迁移、测试、验证、日志均已覆盖。
- Placeholder 检查：无 `TODO` / `TBD` 占位。
- 类型一致性：计划中统一使用 `FreshSaltAppOrchestrator` / `freshsalt_app_orchestrator.dart` 作为新工程编排入口命名。

Plan complete and saved to `docs/superpowers/plans/2026-06-14-freshsalt-bootstrap.md`. Two execution options:

1. Subagent-Driven (recommended) - I dispatch a fresh subagent per task, review between tasks, fast iteration

2. Inline Execution - Execute tasks in this session using executing-plans, batch execution with checkpoints

默认执行方式：Inline Execution。
