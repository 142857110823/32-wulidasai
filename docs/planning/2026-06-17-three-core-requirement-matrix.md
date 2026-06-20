# FreshSalt Surface 三大核心需求-证据-判定矩阵

日期：2026-06-17  
用途：把三大核心从“口头结论”收敛为“需求-证据-判定”矩阵，供后续续跑直接复用。

## 1. 手机拍照能力

| 需求 | 当前证据 | 判定 |
|---|---|---|
| 存在真实相机依赖 | [pubspec.yaml](F:/1.大学物理竞赛/app/freshsalt_surface/pubspec.yaml:30) 到 [38](F:/1.大学物理竞赛/app/freshsalt_surface/pubspec.yaml:38) 无 `camera` / `image_picker` / `permission_handler` | 未满足 |
| 存在 Android 权限声明 | [AndroidManifest.xml](F:/1.大学物理竞赛/app/freshsalt_surface/android/app/src/main/AndroidManifest.xml:1) 到 [45](F:/1.大学物理竞赛/app/freshsalt_surface/android/app/src/main/AndroidManifest.xml:45) 无相机权限声明 | 未满足 |
| 存在权限提权路径 | [settings_page.dart](F:/1.大学物理竞赛/app/freshsalt_surface/lib/features/settings/settings_page.dart:57) 到 [69](F:/1.大学物理竞赛/app/freshsalt_surface/lib/features/settings/settings_page.dart:69) 将权限描述为占位/预留，而非真实请求链路 | 未满足 |
| 存在真实拍照入口 | [image_stage_page.dart](F:/1.大学物理竞赛/app/freshsalt_surface/lib/features/capture/image_stage_page.dart:88) 到 [109](F:/1.大学物理竞赛/app/freshsalt_surface/lib/features/capture/image_stage_page.dart:88) 到 [109](F:/1.大学物理竞赛/app/freshsalt_surface/lib/features/capture/image_stage_page.dart:109) 仍是“使用模拟 I0/I1” | 未满足 |
| 浏览器或设备可见真实拍照 | 当前无任何真实预览、真实拍照、真实权限弹窗证据 | 未满足 |

### 小结

手机拍照能力当前是完整负面结论，不存在“部分满足”空间。

## 2. 真实图片处理能力

| 需求 | 当前证据 | 判定 |
|---|---|---|
| 真实图片被解码 | 当前未发现图像解码入口；服务侧直接消费 metadata | 未满足 |
| ROI 来自真实图像区域 | [quality_control_service.dart](F:/1.大学物理竞赛/app/freshsalt_surface/lib/core/services/quality_control_service.dart:43) 到 [80](F:/1.大学物理竞赛/app/freshsalt_surface/lib/core/services/quality_control_service.dart:80) 只检查 metadata 中的 ROI 字段 | 未满足 |
| QC 来自真实像素 | [quality_control_service.dart](F:/1.大学物理竞赛/app/freshsalt_surface/lib/core/services/quality_control_service.dart:15) 到 [80](F:/1.大学物理竞赛/app/freshsalt_surface/lib/core/services/quality_control_service.dart:15) 到 [80](F:/1.大学物理竞赛/app/freshsalt_surface/lib/core/services/quality_control_service.dart:80) 的曝光、清晰度、灰卡全部来自 metadata | 未满足 |
| 特征提取来自真实图像 | [feature_extraction_service.dart](F:/1.大学物理竞赛/app/freshsalt_surface/lib/core/services/feature_extraction_service.dart:6) 到 [34](F:/1.大学物理竞赛/app/freshsalt_surface/lib/core/services/feature_extraction_service.dart:34) 从 `imageMetadata` 直接取值，并标 `simulated` | 未满足 |
| 结果输入不是 mock 链路 | [freshsalt_app_orchestrator.dart](F:/1.大学物理竞赛/app/freshsalt_surface/lib/core/orchestrator/freshsalt_app_orchestrator.dart:88) 到 [105](F:/1.大学物理竞赛/app/freshsalt_surface/lib/core/orchestrator/freshsalt_app_orchestrator.dart:105) 与 [232](F:/1.大学物理竞赛/app/freshsalt_surface/lib/core/orchestrator/freshsalt_app_orchestrator.dart:232) 到 [256](F:/1.大学物理竞赛/app/freshsalt_surface/lib/core/orchestrator/freshsalt_app_orchestrator.dart:256) 仍写 `/mock/diff_*.png`；[demo_capture_bundle_factory.dart](F:/1.大学物理竞赛/app/freshsalt_surface/lib/core/demo/demo_capture_bundle_factory.dart:17) 到 [41](F:/1.大学物理竞赛/app/freshsalt_surface/lib/core/demo/demo_capture_bundle_factory.dart:41) 注入 demo metadata | 未满足 |

### 小结

真实图片处理能力当前也是完整负面结论，不存在“虽然没相机但处理是真的”这种绕开结论。

## 3. UI 是否符合设计图

### 基准需求

| 基准项 | 来源 |
|---|---|
| 首页应突出任务入口、演示模式、最近模拟趋势 | 基准 docx |
| 采集预测应具备相机预览、ROI、灰卡、盐晶体纹理、成像质控 | 基准 docx |
| 结果详情应具备主结果、范围标尺、历史趋势、模型解释、边界提示 | 基准 docx |

### 当前证据矩阵

| 需求 | 当前证据 | 判定 |
|---|---|---|
| 首页第一屏像测量型工作台 | 浏览器可见首页存在，但第一屏是解释型“首页工作台”大卡片，而非更紧凑的任务入口与趋势导向 | 未满足 |
| 主链具备相机/ROI/灰卡/纹理测量语义 | 浏览器可见 `#/quality-control` 主要是标题、简述、禁用按钮和导航卡，缺少相机预览、ROI、灰卡、纹理等基准要素 | 未满足 |
| 结果页稳定可见 | 浏览器打开 `http://localhost:4322/#/result` 时为空白页 | 未满足 |
| 结果页至少显示空状态 fallback | [result_page.dart](F:/1.大学物理竞赛/app/freshsalt_surface/lib/features/result/result_page.dart:20) 到 [41](F:/1.大学物理竞赛/app/freshsalt_surface/lib/features/result/result_page.dart:41) 规定无数据时应显示标题和空状态卡片；浏览器实际未显示 | 未满足 |
| 结果路由初始化稳定 | 浏览器日志报 `Could not navigate to initial route "/result"`；但 [app.dart](F:/1.大学物理竞赛/app/freshsalt_surface/lib/app.dart:68) 到 [100](F:/1.大学物理竞赛/app/freshsalt_surface/lib/app.dart:100) 与 [app_router.dart](F:/1.大学物理竞赛/app/freshsalt_surface/lib/routing/app_router.dart:90) 到 [91](F:/1.大学物理竞赛/app/freshsalt_surface/lib/routing/app_router.dart:90) 到 [91](F:/1.大学物理竞赛/app/freshsalt_surface/lib/routing/app_router.dart:91) 又表明路由在代码中已声明 | 未满足 |
| 结果页空白可用“无数据”解释 | [demo_app_scope.dart](F:/1.大学物理竞赛/app/freshsalt_surface/lib/core/demo/demo_app_scope.dart:55) 创建空的 `InMemorySessionRepository`，且 demo 模式未预置 saved session；这只会触发代码定义的空状态卡片，不应触发纯白页 | 未满足 |

### 小结

UI 设计符合度当前不是“证据不足”，而是“证据充足地未满足”，其中结果页问题最强。

## 总体判定

| 核心 | 判定 |
|---|---|
| 手机拍照能力 | 未满足 |
| 真实图片处理能力 | 未满足 |
| UI 是否符合设计图 | 未满足 |

## 后续使用方法

后续任何续跑都应按以下顺序使用本矩阵：

1. 先看某一核心的需求列表。
2. 找到对应证据是否被新状态推翻。
3. 只有当“原反证失效，且出现更强正证据”时，才允许把判定从未满足改成满足。
