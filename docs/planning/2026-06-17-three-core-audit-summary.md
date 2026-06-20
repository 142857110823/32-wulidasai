# FreshSalt Surface 三大核心审查总表

日期：2026-06-17  
范围：只审查三大核心，不改业务代码

## 1. 手机拍照能力

### 当前结论

未满足。

### 核心证据

- 依赖缺失：
  [pubspec.yaml](F:/1.大学物理竞赛/app/freshsalt_surface/pubspec.yaml:30) 到 [38](F:/1.大学物理竞赛/app/freshsalt_surface/pubspec.yaml:38) 未声明 `camera`、`image_picker`、`permission_handler`。
- Android 权限缺失：
  [AndroidManifest.xml](F:/1.大学物理竞赛/app/freshsalt_surface/android/app/src/main/AndroidManifest.xml:1) 到 [45](F:/1.大学物理竞赛/app/freshsalt_surface/android/app/src/main/AndroidManifest.xml:45) 未声明 `android.permission.CAMERA` 或媒体读取权限。
- 设置页直接写成占位：
  [settings_page.dart](F:/1.大学物理竞赛/app/freshsalt_surface/lib/features/settings/settings_page.dart:57) 到 [69](F:/1.大学物理竞赛/app/freshsalt_surface/lib/features/settings/settings_page.dart:69) 明确把相机权限、文件权限写成后续预留与占位说明。
- 主链入口仍是模拟：
  [image_stage_page.dart](F:/1.大学物理竞赛/app/freshsalt_surface/lib/features/capture/image_stage_page.dart:88) 到 [109](F:/1.大学物理竞赛/app/freshsalt_surface/lib/features/capture/image_stage_page.dart:109) 仍提供“使用模拟 I0/I1”。

### 影响

当前不存在真实拍照依赖、权限声明、权限提权路径，也不存在真实拍照动作证据，因此不能判定支持真实手机拍照。

### 后续验证口径

只有当“依赖 + Manifest 权限 + 权限请求 UI + 真实拍照动作 + 可见证据”同时成立，才可改判为满足。

## 2. 真实图片处理能力

### 当前结论

未满足。

### 核心证据

- 特征提取由 metadata 驱动：
  [feature_extraction_service.dart](F:/1.大学物理竞赛/app/freshsalt_surface/lib/core/services/feature_extraction_service.dart:6) 到 [34](F:/1.大学物理竞赛/app/freshsalt_surface/lib/core/services/feature_extraction_service.dart:34) 直接从 `imageMetadata` 取特征，并标记 `extraction_method: simulated`。
- 质控由 metadata 驱动：
  [quality_control_service.dart](F:/1.大学物理竞赛/app/freshsalt_surface/lib/core/services/quality_control_service.dart:15) 到 [80](F:/1.大学物理竞赛/app/freshsalt_surface/lib/core/services/quality_control_service.dart:80) 的曝光、清晰度、灰卡稳定性、ROI 完整性全部来自 metadata。
- 编排器持续写 mock 差分图路径：
  [freshsalt_app_orchestrator.dart](F:/1.大学物理竞赛/app/freshsalt_surface/lib/core/orchestrator/freshsalt_app_orchestrator.dart:88) 到 [105](F:/1.大学物理竞赛/app/freshsalt_surface/lib/core/orchestrator/freshsalt_app_orchestrator.dart:105) 以及 [232](F:/1.大学物理竞赛/app/freshsalt_surface/lib/core/orchestrator/freshsalt_app_orchestrator.dart:232) 到 [256](F:/1.大学物理竞赛/app/freshsalt_surface/lib/core/orchestrator/freshsalt_app_orchestrator.dart:256) 仍写 `/mock/diff_*.png`。
- demo 工厂持续注入模拟 metadata：
  [demo_capture_bundle_factory.dart](F:/1.大学物理竞赛/app/freshsalt_surface/lib/core/demo/demo_capture_bundle_factory.dart:17) 到 [41](F:/1.大学物理竞赛/app/freshsalt_surface/lib/core/demo/demo_capture_bundle_factory.dart:41) 以及 [69](F:/1.大学物理竞赛/app/freshsalt_surface/lib/core/demo/demo_capture_bundle_factory.dart:69) 到 [70](F:/1.大学物理竞赛/app/freshsalt_surface/lib/core/demo/demo_capture_bundle_factory.dart:70)。

### 影响

当前没有证据证明真实图像被解码、真实 ROI 被裁剪、真实像素被用于 QC 和特征提取，因此不能判定具备真实图片处理能力。

### 后续验证口径

只有当“真实图像解码 + 真实 ROI + 像素级 QC + 真实特征提取 + 非 mock 结果输入”同时成立，才可改判为满足。

## 3. UI 是否符合设计图

### 当前结论

未满足。

### 基准设计要点

- 首页：任务入口、演示模式、最近模拟趋势
- 采集预测：相机预览、ROI、灰卡、盐晶体纹理、成像质控
- 结果详情：主结果、范围标尺、历史趋势、模型解释、边界提示

### 核心证据

- 首页浏览器可见，但第一屏仍过度解释平台：
  浏览器实测首页显示“首页工作台”大卡片与较长说明文案，仍弱于基准要求的任务导向第一屏。
- 质控页浏览器可见，但主链测量语义不足：
  浏览器实测 `#/quality-control` 主要是标题、简述、禁用按钮与导航卡，不具备相机预览、ROI、灰卡、纹理等基准要素。
- 结果页浏览器空白：
  in-app browser 打开 `http://localhost:4322/#/result` 时出现空白页。
- 结果页运行时还伴随初始路由异常：
  浏览器日志报 `Could not navigate to initial route`，并指向 `"/result"`。
- 结果页空白不能解释为“正常无数据空状态”：
  [result_page.dart](F:/1.大学物理竞赛/app/freshsalt_surface/lib/features/result/result_page.dart:20) 到 [41](F:/1.大学物理竞赛/app/freshsalt_surface/lib/features/result/result_page.dart:41) 表明即使没有 session，也应渲染标题和空状态卡片；实际浏览器却是空白页。
- 路由代码与运行时表现不一致：
  [app.dart](F:/1.大学物理竞赛/app/freshsalt_surface/lib/app.dart:68) 到 [100](F:/1.大学物理竞赛/app/freshsalt_surface/lib/app.dart:100) 支持 `AppRouter.result` 作为初始路由；
  [app_router.dart](F:/1.大学物理竞赛/app/freshsalt_surface/lib/routing/app_router.dart:90) 到 [91](F:/1.大学物理竞赛/app/freshsalt_surface/lib/routing/app_router.dart:91) 明确映射 `/result` 到 `ResultPage`；
  但浏览器仍报路由初始化失败并回退到 `/`。

### 影响

当前 UI 不仅没有完全对齐基准，还在结果页这一高优先级页面上出现了浏览器可见空白和路由初始化异常，因此不能判定符合设计图。

### 后续验证口径

只有当“首页第一屏对齐 + 主链具备测量流程感 + 结果页稳定可见且包含基准五要素 + 整体统一性成立”同时满足，才可改判为满足。
