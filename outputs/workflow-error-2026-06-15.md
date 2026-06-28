# Workflow Error Record

Date: 2026-06-15
Scope: FreshSalt Surface UI/platform execution drift

## Error Summary

The execution repeatedly drifted away from the user's highest-priority requirement of building a browser-visible platform-first UI aligned to the provided baseline design. Work was incorrectly spent on lower-priority module expansion, service-driven validation polish, and test-led local fixes before the homepage and platform shell were visually aligned in the browser.

## Concrete Error Paths

1. Priority inversion
- The work treated passing `flutter analyze` / `flutter test` and internal route/module existence as stronger signals than the user's browser-visible platform acceptance criteria.
- This caused repeated turns where structure looked broader in code than it looked complete in the browser.

2. UI baseline under-read
- The 2026-06-12 UI design was not used early enough as the direct visual authority.
- The implementation drifted into desktop-style explanatory cards instead of the mobile-first workbench shown in the provided UI images.

3. Wrong success proxy
- The workflow used “pages exist”, “routes exist”, and “tests pass” as partial success proxies.
- The user requirement was stricter: the first screen must visibly feel like a complete platform, not a collection of test pages.

4. Module-first drift before platform lock
- Time was spent upgrading validation/history/report/analysis semantics and test anchors before the homepage visual language and platform shell were locked to the baseline.
- Some module strengthening happened before the visible platform framework was stable enough.

5. Rework from unstable browser/runtime proof
- Browser verification was weaker and slower than it should have been because the static preview and service-worker behavior were not normalized earlier.
- This increased repeated verification effort and reduced confidence in what the user was actually seeing.

## Current Remaining Defects

1. Secondary modules are still not fully aligned to the same mobile-first visual language as the corrected homepage.
2. The current history/result/report/validation stack still needs a stricter baseline-image-led redesign pass.
3. Some pages remain structurally stronger than visually convincing, which means the platform can still feel uneven even when tests are green.

## Token-Saving Rule From This Point

1. Browser-visible homepage and high-visibility module screenshots come before further module logic work.
2. Use the 2026-06-12 UI images as the direct source of truth before adding or refactoring widgets.
3. Accept small defects temporarily if they avoid broad speculative rewrites.
4. Record defects explicitly instead of padding work with low-priority polish or test-only movement.

## 2026-06-26 Direction Correction Note

- The latest execution drifted away from the user's actual goal by continuing to refine next-round acquisition assets such as checklist/template/watch-tag details.
- That work improved handoff discipline, but it did not materially reduce the distance to the final scientific result.
- The corrected priority is now explicit: review the remaining distance to the real final result first, using current evidence only.
- The current gap review has been consolidated in `outputs/grating_ai_physics_experiment/report/final_result_gap_review_2026-06-26.md`.
- From this point, new work should be ranked by whether it directly closes one of these hard gaps: model strength, feature independence, ROI cleanliness, sample expansion, label strength, mechanism confirmation, robustness, experiment thickness, or abnormal-sample formalization.
- The ranking has now been tightened further in `outputs/grating_ai_physics_experiment/report/final_result_convergence_priority_2026-06-26.md`, which explicitly marks `ROI cleanliness`, `sample/batch expansion`, `robustness evidence`, and `label-strength resolution` as the current `P0` blockers.
- A real ROI-side evidence upgrade has now been executed: the conservative ROI scan includes a shared contamination-zone hit score, not only separation and simple image-risk proxies.
- Result: the strengthened ranking still does not produce a clean strong rectangle, and instead reinforces that the present rectangular family remains trapped in the same fruit-edge / central-grid contamination belt.
- The user has now clarified a tighter delivery priority: under limited time, maximize the value of the current achieved result rather than pivoting into broader redesign work.
- Therefore current execution should prefer statement unification, evidence compression, defense consistency, and honest claim-boundary tightening over long-horizon scientific route rebuilding.


[2026-06-16 00:00:00+08:00]
- Path/encoding issue blocked a direct Python rewrite of workflow.log when using non-ASCII absolute paths.
- Resolution: rewrote the log with PowerShell using relative workspace paths and appended the takeover record in English.


[2026-06-16 22:30:00+08:00]
- Confirmed a source-level mojibake risk in multiple user-facing Dart strings, not just terminal display noise.
- Confirmed that available screenshots still show an older mode-selection entry state, so screenshot evidence and current code must not be treated as automatically aligned.


[2026-06-16 23:10:00+08:00]
## Review: Platform Audit Without Code Changes

### Issue 1: No real mobile photo capture capability is currently implemented
- Evidence: `app/freshsalt_surface/pubspec.yaml` has no `camera`, `image_picker`, or equivalent dependency.
- Evidence: `app/freshsalt_surface/lib/features/settings/settings_page.dart` explicitly describes camera and file permissions as placeholder-only.
- Evidence: `app/freshsalt_surface/lib/features/capture/image_stage_page.dart` uses simulated image paths and buttons labeled for simulated I0/I1 loading.
- Impact: Requirement ① is not satisfied. The app does not currently support mobile photo capture, and there is no real permission request flow to elevate from the user.

### Issue 2: No real image-processing pipeline is currently implemented against actual image pixels
- Evidence: `app/freshsalt_surface/lib/core/services/feature_extraction_service.dart` builds features directly from incoming `imageMetadata` fields instead of decoding or processing image files.
- Evidence: `app/freshsalt_surface/lib/core/services/quality_control_service.dart` evaluates QC entirely from provided metadata values such as `saturation_ratio`, `laplacian_variance`, and `gray_card_rsd`.
- Evidence: `app/freshsalt_surface/lib/core/orchestrator/freshsalt_app_orchestrator.dart` passes metadata through the full workflow and writes mock difference-image paths like `/mock/diff_<session>.png`.
- Impact: Requirement ② is not satisfied. The current app does not prove real image ingestion, pixel-level processing, ROI extraction from actual images, or result generation from true image content.

### Issue 3: High-visibility UI pages still contain source-level mojibake and cannot be considered design-aligned
- Evidence: user-facing strings in `app/freshsalt_surface/lib/features/home/home_page.dart`, `capture/capture_page.dart`, `capture/image_stage_page.dart`, `quality_control/quality_control_page.dart`, `roi/roi_page.dart`, `prediction/prediction_page.dart`, and `result/result_page.dart` are visibly mojibake in source review.
- Evidence: the baseline docx requires a measurement-style UI with clear homepage, capture workflow, result detail, history, and validation views. Current source strings would render unreadable or partially unreadable labels if shipped as-is.
- Evidence: available screenshots still show an older mode-selection entry page while current `AppRouter` uses `HomePage` as the default route, so screenshot evidence and current code are not fully aligned.
- Impact: Requirement ③ is not satisfied. The current UI cannot be judged as matching the intended design while text integrity and runtime-entry consistency remain unresolved.

### Issue 4: Browser/runtime evidence is incomplete and inconsistent
- Evidence: `outputs/freshsalt_web_4322.log` shows a live web-server runtime at `http://localhost:4322`.
- Evidence: `outputs/freshsalt_surface_web.log` and `outputs/freshsalt_web_4300.err.log` show the Edge debug server on port 4300 failed because the port was already occupied.
- Evidence: stored screenshots include an older first-run mode-selection screen rather than the current homepage route.
- Impact: Current browser proof is too weak to claim complete visible alignment for every module without a fresh end-to-end live review pass.


[2026-06-17 00:05:00+08:00]
## Live Audit Follow-up: Module Click Coverage and Design Fit

### Module click coverage evidence
- Home: `HomePage` exposes visible entry points to quality control, result, validation, sample, model bundle, hardware, analysis, report, and settings routes.
- Sample: `SamplePage` routes directly into `AppRouter.qualityControl` via demo cases, so sample selection is present as a simulated entry stage.
- Quality control: `QualityControlPage` runs QC from `imageMetadata` and advances to `I0` only when simulated metadata passes.
- I0/I1/ROI/Prediction: `ImageStagePage`, `RoiPage`, and `PredictionPage` all operate on `CaptureStepBundle` state and simulated paths/metadata; the click chain exists but remains demo-driven rather than real capture-driven.
- Result/history/report/analysis/model bundle/settings/demo-validation: these pages exist and expose meaningful route-level outputs, CSV/report summaries, model activation, and a validation matrix.

### What the module audit proves
- The platform does have a multi-module click chain.
- The platform does not yet prove real input acquisition from a phone camera.
- The platform does not yet prove pixel-level image processing from actual images.
- The current UI cannot be called design-aligned because multiple high-visibility pages still have source-level mojibake, and the available screenshots do not yet prove the current runtime home screen alignment.

### Remaining evidence gap
- A fresh browser-visible pass across `http://localhost:4322` is still needed to compare current runtime rendering against the baseline docx layout and the provided screenshots.
- Because Playwright browsers are not installed in this environment, a true automated browser click-through is currently blocked until browser binaries are present or another browser control path is available.


[2026-06-16 23:59:00+08:00]
## Readability Note

- A temporary encoding/path issue occurred while reading the baseline DOCX and skill files through the terminal.
- Resolution: switched to UTF-8 reads and a stable Python invocation for the DOCX text extraction, then rewrote the cognition note in clean Chinese.
- Impact: no business code was changed; this only affected documentation and evidence collection.

[2026-06-16 23:59:30+08:00]
## Log Rewrite Note

- A Python-based attempt to rewrite `workflow.log` failed because the non-ASCII workspace path was mangled in the embedded invocation.
- Resolution: rewrote the log with PowerShell only, using the literal workspace path and UTF-8 text handling.
- Impact: no business code was changed; only workflow logging and documentation evidence were affected.

[2026-06-17 00:20:00+08:00]
## Three-Core Follow-up Audit

### Issue 5: Real mobile capture is still absent at dependency and interaction level
- Evidence: `app/freshsalt_surface/pubspec.yaml` contains no `camera`, `image_picker`, or `permission_handler` dependency.
- Evidence: current visible chain pages use simulated wording such as `使用模拟 I0`, `使用模拟 I1`, `模拟数据`, and `开始质控`, but no real camera acquisition action or permission request entry was found in the inspected code paths.
- Impact: Core requirement 1 is still not satisfied. There is no current evidence for a real phone-photo capture path or a user-elevation permission flow.

### Issue 6: Real pixel processing is still replaced by metadata-driven simulation
- Evidence: `app/freshsalt_surface/lib/core/services/feature_extraction_service.dart` maps output features directly from `imageMetadata` fields and tags the extraction method as `simulated`.
- Evidence: `app/freshsalt_surface/lib/core/services/quality_control_service.dart` computes exposure, sharpness, gray-card stability, and ROI integrity entirely from incoming metadata fields rather than decoded image pixels.
- Evidence: `app/freshsalt_surface/lib/core/demo/demo_capture_bundle_factory.dart` feeds `initialCase.imageMetadata` into both quality control and feature extraction and writes mock difference-image paths such as `/mock/demo_prediction_diff.png`.
- Impact: Core requirement 2 is still not satisfied. The current app does not prove true image decoding, pixel-level QC, or image-derived feature extraction.

### Issue 7: UI design alignment is still unproven at browser-visible level, and current page text remains heavier than the baseline design brief
- Evidence: the baseline docx defines a measurement-style platform with concise homepage task entry, demo mode, recent simulated trend, result-detail charts, and image evidence, not text-heavy explanatory module prose.
- Evidence: current homepage and sample/quality/image-stage pages contain large amounts of explanatory copy such as platform-role narration and stage-description text, which increases the risk of drifting away from the baseline's cleaner measurement-app presentation.
- Evidence: the current environment still lacks a successful fresh browser-driven visible pass over `http://localhost:4322`, so the UI cannot be accepted as aligned from code inspection alone.
- Impact: Core requirement 3 is still not satisfied. The UI may be structurally closer to the baseline than before, but browser-visible alignment is still unproven and likely over-explained compared with the baseline brief.

[2026-06-17 10:25:00+08:00]
## Browser-Visible Homepage Check

### Issue 8: The current localhost homepage still fails the platform-first visible acceptance check
- Evidence: `Invoke-WebRequest http://localhost:4322/` returned HTTP 200, so the local web server is reachable.
- Evidence: a fresh headless Edge screenshot was generated at `outputs/home-4322-edge-headless.png`.
- Evidence: the screenshot shows a blank white screen rather than a visible homepage workbench, task entry, or main-chain platform shell.
- Impact: Core requirement 3 is definitively not satisfied at browser-visible level. The current runtime does not present a complete visible platform homepage, so no design-alignment claim is acceptable.

[2026-06-17 12:30:00+08:00]
## White-Screen Runtime Follow-up

### Issue 9: The current web runtime still cannot provide a visible homepage even though bootstrap resources are reachable
- Evidence: `http://localhost:4322/` returns the expected Flutter shell HTML and loads `flutter_bootstrap.js` with `main.dart.js` configured as the entry script.
- Evidence: `http://localhost:4322/main.dart.js` returns HTTP 200, so the main JavaScript bundle is reachable from the server side.
- Evidence: despite reachable shell and script resources, the fresh browser-visible screenshot at `outputs/home-4322-edge-headless.png` remains a blank white page.
- Evidence: an additional headless Edge logging attempt produced no usable runtime error output in `outputs/edge-headless-4322.log`, so the current observable failure remains "reachable shell + blank rendered page".
- Impact: Core requirement 3 remains blocked by a first-screen rendering failure. Even before comparing layout, copy, or hierarchy against the design docx, the live homepage still fails the most basic browser-visible platform gate.

[2026-06-17 12:35:00+08:00]
## Homepage Rendering Correction

### Issue 10: The homepage rendering check is unstable, but the visible UI still does not pass the design-alignment gate
- Evidence: a longer-budget headless capture generated `outputs/home-4322-edge-headless-v2.png`, and this second artifact shows that the homepage can render visible content rather than staying permanently white.
- Evidence: the earlier `outputs/home-4322-edge-headless.png` remains a blank white capture, so the current runtime/browser capture behavior is unstable across runs or timing windows.
- Evidence: the visible homepage in `home-4322-edge-headless-v2.png` is text-heavy and still does not match the baseline docx's cleaner measurement-style emphasis on concise task entry, demo mode, and recent trend presentation.
- Impact: the previous "stable white-screen" interpretation was too strong and is corrected here. Core requirement 3 is still not satisfied, but the blocking evidence is now refined to "unstable rendering evidence plus homepage visual drift", not a proven permanently blank runtime.

[2026-06-17 12:45:00+08:00]
## Homepage Design-Diff Note

### Issue 11: The current visible homepage over-explains the platform instead of reading like the baseline measurement workbench
- Evidence: the baseline docx homepage brief is concise: `任务入口、演示模式、最近模拟趋势`.
- Evidence: the visible homepage in `outputs/home-4322-edge-headless-v2.png` starts with a large explanatory paragraph under `首页工作台`, which shifts the first-screen emphasis from operational entry to descriptive text.
- Evidence: the baseline favors a measurement-style workbench, while the current homepage spends substantial vertical space on explanation cards such as current mode, data source, enabled model, and recent trend before the user reaches a sharper action-oriented main workbench rhythm.
- Impact: Core requirement 3 is still not satisfied. Even when the homepage renders, its first-screen information hierarchy is still too text-led and not yet tight enough to read as the intended platform-first measurement dashboard.

[2026-06-17 12:55:00+08:00]
## Main-Chain Browser Evidence Gap

### Issue 12: Homepage browser evidence is stronger than the rest of the visible main chain
- Evidence: direct HTTP probes to `http://localhost:4322/#/quality-control` and `http://localhost:4322/#/result` both returned HTTP 200.
- Evidence: repeated headless Edge screenshot attempts for those hash-routed pages did not produce stable screenshot artifacts in `outputs/`, unlike the homepage captures that were already obtained.
- Evidence: this means the current browser-visible evidence is still concentrated on the homepage and does not yet prove stable visible rendering for the rest of the main chain.
- Impact: Core requirement 3 remains not satisfied at the requested acceptance level. Route reachability cannot be treated as proof that quality-control and result pages are visually aligned or even stably visible in the browser.

[2026-06-17 13:05:00+08:00]
## Main-Chain Screenshot Retry

### Issue 13: Repeated targeted screenshot retries for high-visibility main-chain routes still failed to produce artifacts
- Evidence: repeated direct headless Edge captures were attempted for `http://localhost:4322/#/quality-control` and `http://localhost:4322/#/result` with longer virtual-time budgets.
- Evidence: `Test-Path` checks confirmed that neither `outputs/quality-4322-edge-headless-v2.png` nor `outputs/result-4322-edge-headless-v2.png` was created.
- Impact: Core requirement 3 remains not satisfied. The browser-visible evidence is still too weak for the main-chain routes beyond the homepage, and this weakness itself is now a documented acceptance blocker.

[2026-06-17 13:15:00+08:00]
## Quality-Control Page Visible Check

### Issue 14: The main-chain quality-control page is now visibly proven, and it still reads more like a sparse instruction card than the intended measurement workflow stage
- Evidence: a CDP-driven browser capture successfully produced `outputs/quality-4322-cdp.png` for `#/quality-control`.
- Evidence: the visible page shows the route content, so the main chain is not limited to homepage-only visual proof anymore.
- Evidence: the page is dominated by explanatory status text, a disabled `开始质控` action, and broad empty card surfaces, rather than a stronger measurement-stage composition with richer operational context, image-stage evidence, or tighter workflow framing.
- Evidence: compared with the baseline docx, which defines `采集预测` around camera preview, ROI, gray card, texture, and imaging QC, the current visible quality-control page still feels too abstract and under-instrumented.
- Impact: Core requirement 3 remains not satisfied. The visible main chain now has proof, but that proof reinforces the same design drift: high-visibility pages are still text-led and operationally thin relative to the baseline platform brief.

[2026-06-17 13:25:00+08:00]
## Result Page Browser Evidence Gap

### Issue 15: The result page still lacks stable browser-visible evidence at the same strength as the homepage and quality-control page
- Evidence: a CDP-based result-route capture attempt exceeded the turn timeout before a screenshot artifact was copied back into `outputs/`.
- Evidence: the temporary result-route text dump file existed but contained no usable visible text payload.
- Evidence: this means the current evidence still does not prove that the `#/result` page is stably visible in a way that can be compared against the baseline docx requirement of `主结果、范围标尺、历史趋势、模型解释、边界提示`.
- Impact: Core requirement 3 remains not satisfied. The visible-audit chain is now stronger for homepage and quality-control, but result-page acceptance is still evidence-incomplete.
[2026-06-17 12:56:00+08:00]
## Baseline DOCX Extraction Path Note

### Issue 16: The baseline docx could not be read directly through `python-docx` on the workspace's non-ASCII path
- Evidence: `python-docx` raised `PackageNotFoundError` when opening the baseline docx through the original workspace path.
- Evidence: copying the same file to `C:\Users\1\AppData\Local\Temp\freshsalt-baseline-2026-06-12.docx` allowed clean paragraph extraction and baseline-keyline recovery.
- Impact: This does not change the product conclusion, but it is a recurring evidence-collection blocker and confirms that Python-based document inspection should keep using an ASCII temp path in this workspace.

[2026-06-17 12:58:00+08:00]
## Result Page In-App Browser Check

### Issue 17: The `#/result` route still fails the browser-visible acceptance gate because the in-app browser renders it as a blank page
- Evidence: the in-app Browser plugin navigated to `http://localhost:4322/#/result` and stayed on that URL.
- Evidence: the tab title resolved as `freshsalt_surface`, browser logs showed only a non-fatal Dart developer warning, and no route fallback was observed.
- Evidence: the captured full-page screenshot from the in-app browser was a blank white page and the returned DOM snapshot was an empty string.
- Evidence: this is stronger than route reachability alone because it proves the result route can open yet still does not provide a visible result-detail surface for comparison with the baseline docx requirement of main result, range scale, history trend, model explanation, and boundary hint.
- Impact: Core requirement 3 remains not satisfied. The result page is now evidence-negative at browser-visible level, not merely evidence-incomplete.

[2026-06-17 13:08:00+08:00]
## Real Capture and Permission Follow-up

### Issue 18: The Android app still has no real camera-permission path, and the settings UI explicitly treats camera access as a future placeholder
- Evidence: `app/freshsalt_surface/pubspec.yaml:30-38` contains only `flutter` and `cupertino_icons`, while `camera`, `image_picker`, and `permission_handler` are all absent.
- Evidence: `app/freshsalt_surface/android/app/src/main/AndroidManifest.xml:1-45` contains no `uses-permission` entry for `android.permission.CAMERA` or storage/media access.
- Evidence: `app/freshsalt_surface/lib/features/settings/settings_page.dart:57-69` labels camera and file permissions as placeholder-only future access, stating that demo mode does not require authorization now.
- Evidence: `app/freshsalt_surface/lib/features/capture/image_stage_page.dart:88-109` still drives the I0/I1 stages with explicit `use mock I0/I1` actions rather than real capture actions.
- Impact: Core requirement 1 remains not satisfied. The workspace currently shows neither dependency-level camera support nor manifest-level camera permission declaration nor a real permission-elevation UI path.

[2026-06-17 13:10:00+08:00]
## Real Pixel Processing Follow-up

### Issue 19: The visible capture chain and core services still operate on simulated paths and metadata rather than real image content
- Evidence: `app/freshsalt_surface/lib/core/services/feature_extraction_service.dart:6-34` reads color and texture features directly from `imageMetadata` and marks the extraction method as `simulated`.
- Evidence: `app/freshsalt_surface/lib/core/services/quality_control_service.dart:15-80` computes exposure, sharpness, gray-card stability, and ROI integrity entirely from metadata fields such as `saturation_ratio`, `laplacian_variance`, `gray_card_rsd`, and `roi_area_cm2`.
- Evidence: `app/freshsalt_surface/lib/core/orchestrator/freshsalt_app_orchestrator.dart:30,43,88-105,232-256` keeps `sourceMode` on `simulated`, passes metadata through the flow, and writes `/mock/diff_*.png` paths for prediction and validation.
- Evidence: `app/freshsalt_surface/lib/core/demo/demo_capture_bundle_factory.dart:17,32-41,69-70` injects demo `imageMetadata` and mock difference-image paths into the stage bundle.
- Impact: Core requirement 2 remains not satisfied. The current implementation still does not prove real image decoding, pixel-level ROI processing, or real-image-derived result generation.

[2026-06-17 13:18:00+08:00]
## Browser Recheck: Home and Main Chain

### Issue 20: The homepage is visible, but its first-screen hierarchy still reads more like a platform explanation card than the concise measurement workbench required by the baseline
- Evidence: the in-app browser captured the live homepage at `http://localhost:4322/`, so homepage visibility is now re-confirmed.
- Evidence: the first screen is dominated by a large `首页工作台` hero card with explanatory copy, followed by platform-status cards, instead of the tighter baseline emphasis on task entry, demo mode, and recent simulated trend.
- Evidence: this still conflicts with the baseline docx homepage brief of `任务入口、演示模式、最近模拟趋势`.
- Impact: Core requirement 3 remains not satisfied. The homepage is visible, but its first-screen information hierarchy is still too descriptive and not yet sufficiently measurement-workbench-oriented.

[2026-06-17 13:20:00+08:00]
## Browser Recheck: Quality-Control Stage

### Issue 21: The visible quality-control page is still too abstract and operationally thin relative to the baseline capture workflow
- Evidence: the in-app browser captured `http://localhost:4322/#/quality-control`, proving the page is visible.
- Evidence: the page mainly shows a title, a short QC description, a disabled `开始质控` button, and sparse stage-navigation cards.
- Evidence: the baseline docx defines capture prediction around camera preview, ROI, gray card, salt-crystal texture, and imaging QC, but these visual elements are not present in the current visible stage page.
- Impact: Core requirement 3 remains not satisfied. The main chain is visible but still does not read like the intended experimental measurement flow.

[2026-06-17 13:22:00+08:00]
## Result Route Runtime Note

### Issue 22: The browser runtime also reports an initial-route navigation exception tied to `/result`
- Evidence: browser console logs include `Could not navigate to initial route.` followed by `The requested route name was: "/result"` and `"/" will be used instead.`
- Evidence: this means the current result-page problem is not only a blank visible surface; there is also a route-resolution/runtime warning in the browser session.
- Impact: Core requirement 3 remains not satisfied with stronger runtime evidence. The result-route acceptance problem now includes both visible blank-page failure and route-initialization instability.

[2026-06-17 13:28:00+08:00]
## Result Route Consistency Note

### Issue 23: The `/result` runtime warning contradicts the current route declarations, which strengthens the conclusion that result-page acceptance is unstable at runtime rather than merely absent in code
- Evidence: `app/freshsalt_surface/lib/app.dart:68-100` explicitly normalizes `Uri.base.fragment` and includes `AppRouter.result` in the supported initial-route set.
- Evidence: `app/freshsalt_surface/lib/routing/app_router.dart:90-91` explicitly maps `case result` to `ResultPage(sessionId: settings.arguments as String?)`.
- Evidence: despite those declarations, the browser session still logs `Could not navigate to initial route` for `"/result"` and falls back to `"/"`.
- Impact: Core requirement 3 remains not satisfied with a tighter explanation. The result-page failure is now evidenced as a live runtime inconsistency between declared route support and browser initialization behavior.

[2026-06-17 13:32:00+08:00]
## Result Empty-State Mismatch

### Issue 24: The blank result page cannot be explained away as a normal no-data empty state
- Evidence: `app/freshsalt_surface/lib/features/result/result_page.dart:20-41` shows that when no session is available, the page should still render a scaffold, a `结果详情` heading, and a card telling the user to complete and save a simulated prediction first.
- Evidence: the browser-visible result-route capture produced a blank white page rather than that coded empty-state card.
- Impact: Core requirement 3 remains not satisfied with stronger certainty. The result-page browser failure is not merely "there is no saved result yet"; it is a runtime rendering/route problem relative to the page's own coded fallback UI.

[2026-06-17 13:40:00+08:00]
## Result Data-Availability Clarification

### Issue 25: The current demo runtime appears to start with an empty in-memory session repository, which makes the blank result page failure even less acceptable
- Evidence: `app/freshsalt_surface/lib/core/demo/demo_app_scope.dart:55` creates an `InMemorySessionRepository`, and `app/freshsalt_surface/lib/core/demo/demo_app_scope.dart:83-109` reuses that same repository in demo mode without preloading saved sessions.
- Evidence: no preseeded mock session assets were found under `app/freshsalt_surface/assets/mock`.
- Evidence: under this runtime shape, the expected first-pass behavior for `/result` is the coded empty-state card in `result_page.dart`, not a blank white screen.
- Impact: Core requirement 3 remains not satisfied with an even tighter explanation. The result-page browser failure now contradicts the current runtime's likely empty-session condition as well as the page's coded fallback UI.

[2026-06-17 22:18:00+08:00]
## Result Route Recheck After Minimal Fix

### Issue 26: The /result deep-link bootstrap was tightened in code, but fresh browser-visible proof is still incomplete
- Evidence: `app/freshsalt_surface/lib/app.dart` was updated to build the initial route stack through `buildFreshSaltInitialRoutes`, keeping home -> /result instead of relying on direct initialRoute handoff alone.
- Evidence: `app/freshsalt_surface/test/widget_test.dart` now contains a focused route-stack regression test for /result, and `flutter test test/widget_test.dart --plain-name "buildFreshSaltInitialRoutes keeps /result in the initial route stack"` passed.
- Evidence: the existing result-page record-selection test also still passed through `flutter test test/widget_test.dart --plain-name "sessionId"`.
- Evidence: a fresh headless browser recheck did not yet produce a new screenshot, DOM dump, or console payload for `http://localhost:4322/#/result`; the new `result-4322-dumpdom.txt` and `result-4322-console.log` artifacts were created with length 0, and the new screenshot file was not created.
- Impact: Core requirement 3 is improved at code-path and focused-test level, but it is still not verified as browser-visible complete. The /result page cannot yet be claimed accepted until a fresh visible artifact proves the page is no longer blank.



[2026-06-17 22:23:00+08:00]
## Result Route Visible Recheck With Fresh Screenshot

### Issue 27: The /result page is no longer evidenced as a pure white screen, but it still fails visible acceptance because it renders the homepage workbench instead of the result detail surface
- Evidence: a fresh headless Edge screenshot was successfully generated through an ASCII temp path at C:\Users\1\AppData\Local\Temp\freshsalt-result-check\result.png and copied into outputs/result-4322-edge-headless-postfix.png.
- Evidence: the visible screenshot does not show the result-detail page. It shows the homepage workbench with sections such as 首页工作台, 平台状态, 任务入口, and 模块入口 while the browser target remained http://localhost:4322/#/result.
- Evidence: this means the previous minimal route-stack fix improved the startup path enough to avoid the prior blank-screen evidence, but the runtime still resolves the visible surface to home rather than to ResultPage.
- Impact: Core requirement 3 remains not satisfied. The result-route issue is now narrowed from lank page to isible fallback/home rendering at /result, which is a more precise browser-visible defect for the next fix.

[2026-06-17 22:36:00+08:00]
## Home First-Screen Platform Density

### Issue 28: The homepage first screen still reads as a loose explanatory landing view instead of a dense experimental platform workbench
- Evidence: the latest visible homepage screenshot shows separated light cards for 首页工作台, 平台状态, 任务入口, 主链概览, 模块入口, and 最近模拟趋势 with large vertical gaps and weak first-screen grouping.
- Evidence: the baseline homepage emphasis is on 演示模式、任务入口、最近模拟趋势 and a clear workbench feel, but the current first screen spends too much space on descriptive framing and low-density card rhythm.
- Impact: UI acceptance remains negative at the homepage shell level. The next visible fix should strengthen first-screen hierarchy and compress the main workbench into a more platform-like surface before expanding other pages.

[2026-06-17 22:45:00+08:00]
## Home First-Screen Recheck After Workbench Compression

### Issue 29: The homepage first screen is now more platform-like, but the main-chain overview still falls below the fold and the trend block is still pushed to later viewport depth
- Evidence: the fresh browser-visible homepage at `http://localhost:4330/` now shows 首页工作台 with 今日任务、核心入口、平台状态 in one combined workbench surface, improving hierarchy and density.
- Evidence: however, the visible first viewport still does not include 最近模拟趋势, and the 主链概览 is only partially implied below the fold rather than fully integrated into the top workbench.
- Impact: The homepage shell improved visibly, but baseline alignment is still incomplete. The next UI pass should decide whether the remaining highest-priority gap is trend visibility or main-chain visibility within the first screen.

[2026-06-17 22:56:00+08:00]
## Browser Runtime Regression Across Home, Quality, and Result

### Issue 30: The current live browser-visible runtime is now unstable enough that home, quality-control, and result all render as blank white surfaces in the in-app browser
- Evidence: a fresh in-app browser recheck against `http://localhost:4322/`, `http://localhost:4322/#/quality-control`, and `http://localhost:4322/#/result` all returned blank white screenshots.
- Evidence: for all three pages, the browser tab title still resolved as `freshsalt_surface`, but `tab.playwright.domSnapshot()` returned length `0` and no visible page structure was captured.
- Evidence: this is stronger than a single-page mismatch because it now affects the homepage shell, the capture main-chain entry page, and the result page in the same live browser runtime.
- Impact: Core requirement 3 remains not satisfied and the current browser-visible evidence is now runtime-unstable at the platform level, not only misaligned at the design level.

[2026-06-17 23:03:00+08:00]
## Cross-Port Browser Evidence Clarification

### Issue 31: The current UI failure evidence is stronger than a single localhost instance problem, but the exact boundary between runtime blanking and browser-inspection failure is still unresolved
- Evidence: both `http://localhost:4322/` and `http://localhost:4330/` return the normal Flutter Web HTML shell through direct HTTP fetch, so the local servers are not simply down.
- Evidence: however, fresh in-app browser checks against `4322` home, `4322/#/quality-control`, `4322/#/result`, and `4330/` all produced tab titles of `freshsalt_surface` with `domSnapshot()` length `0`.
- Evidence: the only captured browser log across those checks was the non-fatal `registerExtension() from dart:developer` warning, which is too weak to explain the full blank visible state by itself.
- Impact: Core requirement 3 remains negative on current evidence. The platform still lacks stable browser-visible proof for homepage, main chain, and result detail, and the current acceptance blocker now includes unresolved runtime-versus-inspection instability.

[2026-06-17 23:12:00+08:00]
## Fresh In-App Browser Session Confirmation

### Issue 32: A fully reset in-app browser session still reproduces blank homepage and blank result page, which rules out simple stale-tab contamination
- Evidence: after resetting the JavaScript kernel and reconnecting to the in-app browser from scratch, fresh checks against `http://localhost:4322/` and `http://localhost:4322/#/result` again produced blank white screenshots.
- Evidence: both pages still resolved the tab title as `freshsalt_surface`, while `domSnapshot()` remained length `0` and browser logs were empty.
- Impact: Core requirement 3 remains not satisfied on stronger evidence. The current browser-visible failure survives a clean browser-session reset, so it cannot be dismissed as only an old session artifact.

[2026-06-17 23:18:00+08:00]
## Server And Static-Asset Availability Clarification

### Issue 33: The current UI white-screen blocker is not explained by a dead localhost server or obviously missing Flutter Web static assets
- Evidence: active listeners still exist on `4322` and `4330`, showing separate serving processes for the current local app runtimes.
- Evidence: direct HTTP fetches for `flutter_bootstrap.js`, `main.dart.js`, `stack_trace_mapper.js`, `require.js`, and `manifest.json` all returned `200` from both `4322` and `4330`.
- Evidence: this means the current acceptance failure persists even though the app shell and key debug-mode Flutter Web resources are still being served normally.
- Impact: Core requirement 3 remains not satisfied on even tighter evidence. The browser-visible blank state is now better localized to runtime rendering / browser-surface behavior rather than a simple missing server or missing static-file failure.

[2026-06-17 23:24:00+08:00]
## Port 4322 Runtime Contamination

### Issue 34: The long-used `4322` verification target is contaminated by two different local servers listening on the same port, which weakens any claim that `4322` evidence belongs to only one runtime
- Evidence: active listeners show both `dart.exe` and `python.exe` bound to port `4322`.
- Evidence: the `dart.exe` process command line is `flutter_tools.snapshot run -d web-server --web-port 4322`, while the `python.exe` process command line is `python -m http.server 4322 --directory F:\\1.大学物理竞赛\\app\\freshsalt_surface\\build\\web`.
- Evidence: direct HTTP fetches from `http://localhost:4322/` return the static `build/web/index.html` shell, which is identical to the file under `app/freshsalt_surface/build/web/index.html` and therefore can be explained by the Python static server rather than the live Flutter web-server alone.
- Impact: Core requirement 3 remains not satisfied, and prior `4322` browser evidence must now be interpreted with extra caution because the target port is not a clean single-runtime acceptance surface.
[2026-06-17 23:33:00+08:00]
## Clean 4330 UI Verification Preparation

### Issue 35: The active UI repair loop is currently blocked by missing headless browser tooling, so the next acceptance target must first be stabilized on clean port 4330 before any single visible mismatch can be trusted
- Evidence: port `4330` remains the cleaner runtime target than `4322`, which is already contaminated by both Flutter and Python servers.
- Evidence: direct Playwright verification could not start because the required headless Chromium executable is missing from the local Playwright cache.
- Evidence: without a stable screenshot or DOM capture from `4330`, any new UI code change would still lack trustworthy browser-visible acceptance evidence.
- Impact: the immediate priority is to restore reliable visible verification on clean port `4330`, then fix only the highest-priority visible mismatch exposed there.
[2026-06-17 23:38:00+08:00]
## Clean 4330 Runtime Loss

### Issue 36: The cleaner UI acceptance target on port 4330 is no longer serving, so the current repair loop cannot rely on prior 4330 evidence
- Evidence: a fresh headless Chromium check against `http://127.0.0.1:4330/` now fails with `ERR_CONNECTION_REFUSED`.
- Evidence: this means the previously cleaner verification target is currently offline rather than merely rendering the wrong UI.
- Impact: the immediate next step must be to restart exactly one clean UI preview target before any browser-visible mismatch can be repaired or re-ranked.
[2026-06-17 23:45:00+08:00]
## Clean 4330 Homepage Visible Mismatch

### Issue 37: The homepage is rendering on clean port 4330, but the first screen still does not present a complete platform shell because the recent simulated trend remains below the fold
- Evidence: a fresh clean-port screenshot was captured at `outputs/ui-home-4330-2026-06-17.png` from `http://localhost:4330/`.
- Evidence: the page visibly renders 首页工作台, 今日任务, 核心入口, 平台状态, and 主链概览, so the current highest-priority UI problem is no longer runtime blanking on the clean target.
- Evidence: however, 最近模拟趋势 starts below the main workbench instead of being integrated into the first-screen platform shell, which weakens the baseline requirement of `任务入口 + 演示模式 + 最近模拟趋势` as one coherent landing surface.
- Impact: the next single visible fix should compress or recompose the homepage first screen so that trend visibility joins the top workbench without pushing the main chain out of focus.
[2026-06-17 23:52:00+08:00]
## 4330 Runtime Instability After Homepage Edit

### Issue 38: The clean-port homepage turned back into a white screen during immediate recheck, so runtime stability again outranks the first-screen density tweak
- Evidence: `outputs/ui-home-4330-after-trend-fix.png` is a blank white screenshot from the same clean target `http://localhost:4330/`.
- Evidence: the paired browser capture returned title `freshsalt_surface`, empty body text, and no visible homepage markers such as `首页工作台` or `最近模拟趋势`.
- Evidence: a few minutes earlier, the same clean port rendered a visible homepage workbench, so the blocker is now unstable runtime behavior rather than only homepage composition.
- Impact: the current highest-priority UI task is to stabilize the web runtime on the clean acceptance target before any further homepage layout tuning can be trusted.
[2026-06-18 00:02:00+08:00]
## 4330 Cache And Service-Worker Audit Start

### Issue 39: The next UI step must first verify whether the 4330 white-screen regression is caused by service-worker or browser-cache contamination before any further homepage repair can be trusted
- Evidence: the same clean target rendered the homepage and then regressed to a white screen within the same repair loop.
- Evidence: the served bootstrap still enables a Flutter service worker, which creates a plausible cache contamination path for unstable browser-visible acceptance.
- Impact: cache and service-worker contamination must be ruled in or out before the next UI repair step.
[2026-06-18 00:10:00+08:00]
## Result Route Verification Boundary Tightening

### Issue 40: The latest result-page recheck used a hash URL with a query suffix attached to the fragment, so that evidence is not clean enough to conclude the result UI itself is wrong
- Evidence: the checked URL form was `#/result?t=...`, which can alter fragment-based route parsing and trigger a fallback route instead of the intended result page.
- Evidence: the captured screenshot for that run visibly showed the homepage shell rather than a result-detail surface.
- Impact: result-page acceptance remains negative, but the next verification must use a clean hash route before re-ranking the visible mismatch.
[2026-06-18 00:14:00+08:00]
## Result Detail Empty-State Mismatch

### Issue 41: The clean result route now renders stably, but it still fails the baseline because the page stops at an empty-state placeholder instead of showing a result-detail surface
- Evidence: `outputs/4330-result-clean-hash.png` shows the result page title `结果详情` plus a placeholder card reading `暂无可展示结果，请先完成一次模拟预测并保存到历史。`
- Evidence: the page does not visibly present the required result-detail blocks such as main result, range scale, history trend, model explanation, or boundary prompt.
- Impact: the current highest-priority visible mismatch is no longer route instability. It is the missing demo result-detail shell on the stable result page.
[2026-06-18 00:20:00+08:00]
## Result Preview Instance Staleness

### Issue 42: The result-page code was updated, but the current browser-visible result surface still shows the old empty-state placeholder, so the active preview instance is likely stale and must be refreshed before the latest UI change can be judged
- Evidence: `result_page.dart` now builds a simulated fallback result session when no saved session exists.
- Evidence: the immediate browser screenshot `outputs/4330-result-after-demo-shell.png` still shows the old placeholder text instead of the new detail shell.
- Impact: the next step is not another result-page redesign pass. It is a clean preview restart so the latest visible result surface can be verified on a fresh runtime.
[2026-06-18 00:29:00+08:00]
## Fresh 4330 Runtime Entrypoint Failure

### Issue 43: After a clean 4330 restart, the current web runtime fails before page rendering because `web_entrypoint.dart.js` is requested but served back as HTML
- Evidence: the fresh browser logs on `http://localhost:4330/#/result` now include `Refused to execute script from 'http://localhost:4330/web_entrypoint.dart.js' because its MIME type ('text/html') is not executable`.
- Evidence: the paired RequireJS error reports `Script error for "web_entrypoint.dart"`, which means the new preview instance is currently broken at the web entrypoint layer rather than at the result-page widget layer.
- Impact: the next highest-priority task is to stabilize the Flutter web entrypoint serving on 4330 before judging any further UI page changes.
[2026-06-18 00:37:00+08:00]
## Stable Static Preview Evidence On 4331

### Issue 44: A stable static acceptance surface is now available on port 4331, which separates UI evidence from the unstable Flutter debug preview on 4330
- Evidence: `flutter build web --pwa-strategy=none` completed successfully and a new static server was started on `http://localhost:4331/`.
- Evidence: `outputs/4331-home-static.png` shows the homepage rendering stably on the static preview target.
- Evidence: `outputs/4331-result-static.png` shows the result page rendering a visible result-detail shell instead of the prior empty-state placeholder.
- Impact: UI acceptance is still not complete, but browser-visible verification is now materially stronger because homepage and result page can be judged on a stable static target.
[2026-06-18 00:45:00+08:00]
## Homepage First-Screen Still Incomplete On Stable Static Surface

### Issue 45: Even on the stable 4331 static acceptance surface, the homepage first screen still stops before showing the recent simulated trend, so the platform shell remains visually incomplete
- Evidence: `outputs/4331-home-static.png` shows 首页工作台, 今日任务, 核心入口, and 平台状态, but 最近模拟趋势 is still not visible within the first screen.
- Evidence: the baseline requires the homepage shell to read as `任务入口 + 演示模式 + 最近模拟趋势` rather than a partial workbench plus folded secondary content.
- Impact: the next single visible fix should compress the homepage first-screen composition so the trend block becomes visible without leaving the main chain unreadable.
[2026-06-18 00:52:00+08:00]
## Result Page Trend Visibility Gap

### Issue 46: On the stable 4331 static result page, the main result and range scale are visible, but the history trend still lacks a clearly readable trend presentation that matches the baseline intent
- Evidence: `outputs/4331-result-static-after-compress.png` visibly shows the main result card, range scale, input summary, and model explanation.
- Evidence: however, the history-trend area does not yet read as a real trend block with readable sequence content, so the result-detail story is still weaker than the baseline expectation of visible history trend context.
- Impact: the next single visible fix should strengthen the result-page history trend presentation without broadening into unrelated modules.
[2026-06-18 01:02:00+08:00]
## Result Trend Block Strengthened On Stable Static Surface

### Issue 47: The result-page history trend is now visibly present as an independent block on the stable 4331 static surface, but it still remains simpler than the baseline's richer trend storytelling
- Evidence: `outputs/4331-result-after-trend-block.png` now shows a dedicated 历史趋势 block with a visible plotted area and a readable current-result trend row.
- Evidence: this is stronger than the prior weak placeholder-like presentation, but it still does not yet provide a fuller multi-point history story comparable to the baseline intent.
- Impact: the result page moved closer to acceptance, while the remaining higher-priority UI gap likely shifts back to homepage first-screen polish and overall platform cohesion.
[2026-06-18 01:10:00+08:00]
## Homepage Trend Still Partially Cut By Bottom Navigation

### Issue 48: On the stable 4331 homepage, the recent simulated trend is now back on the first screen, but its block is still partially cut by the bottom navigation, so the first-screen platform shell is not yet fully readable
- Evidence: `outputs/4331-home-static-after-compress.png` shows the recent simulated trend entering the first screen, but the lower portion of that trend block is still occluded by the bottom navigation area.
- Evidence: this means the homepage moved closer to the baseline, yet the first screen still cannot be read as a fully composed platform shell in one glance.
- Impact: the next single visible fix should create enough breathing room for the entire trend block to remain readable above the bottom navigation.
[2026-06-18 01:18:00+08:00]
## Homepage Trend Still Slightly Cut After First Trim

### Issue 49: The homepage first screen is improved, but the recent trend card is still clipped by the bottom navigation, so the first-screen shell is not yet fully clean
- Evidence: `outputs/4331-home-static-after-trim.png` shows the trend card more clearly than before, but the lower right value area is still cut by the bottom navigation.
- Evidence: this means the visible composition is close, but the first screen still cannot be treated as fully resolved against the baseline.
- Impact: one final vertical reduction is still needed on the homepage before the first screen can be considered clean enough for acceptance review.
[2026-06-18 01:29:00+08:00]
## Homepage First Screen Near-Clean But Still Slightly Clipped

### Issue 50: The homepage first screen is now close to the baseline shell, but the recent trend block is still slightly clipped by the bottom navigation on the stable static surface
- Evidence: `outputs/4331-home-static-final-firstscreen.png` shows the homepage first screen with task, entry, platform state, and recent trend all visible together.
- Evidence: however, the lower edge of the trend block still overlaps visually with the bottom navigation, so the screen is near-clean rather than fully clean.
- Impact: homepage first-screen alignment is materially improved, but UI acceptance remains not fully achieved on this remaining visible edge case.
[2026-06-18 01:36:00+08:00]
## Homepage First-Screen Final Vertical Edge Case

### Issue 51: The homepage first screen is now structurally aligned, and the remaining UI gap is a narrow vertical overlap edge case between the recent trend block and the bottom navigation
- Evidence: `outputs/4331-home-static-final-firstscreen.png` already shows task, entry, state, and trend together on the first screen.
- Evidence: the remaining mismatch is no longer structural; it is limited to the trend block being slightly clipped by the bottom navigation.
- Impact: one more homepage-only vertical trim is justified, but broader UI restructuring is no longer warranted.
[2026-06-18 01:48:00+08:00]
## Homepage First Screen After Final Vertical Trim

### Issue 52: The homepage first screen now shows task, entry, state, and trend together with materially cleaner vertical fit, but the bottom navigation still remains visually close enough that full baseline alignment should be treated as near-complete rather than complete
- Evidence: `outputs/4331-home-static-postfinaltrim.png` shows the recent trend block more fully exposed above the bottom navigation than in the previous static checks.
- Evidence: the remaining difference is now a narrow visual-tightness issue rather than a missing first-screen module or broken hierarchy.
- Impact: homepage first-screen UI is materially improved again, but full UI acceptance should still remain negative until that final tightness and the broader cross-page polish standard are resolved.
[2026-06-18 01:56:00+08:00]
## Homepage Micro-Trim Closeout

### Issue 53: The homepage first screen is now effectively aligned on the stable static surface, with task, entry, state, and trend visible together and no longer clipped by the bottom navigation
- Evidence: `outputs/4331-home-static-microtrim.png` shows the full first-screen platform shell in one view.
- Evidence: the recent trend block is now fully visible enough to read as part of the same platform surface rather than a cut-off fragment.
- Impact: homepage first-screen UI is now near-final on the stable static surface, and the remaining work should move to broader UI cohesion only if the user explicitly wants further polish.
[2026-06-18 12:02:00+08:00]
## Instruction Artifact Gap

### Issue 17: `Agent.md` is missing from the workspace even though the request requires merging `AGENTS.md` and `Agent.md`
- Evidence: `F:\1.大学物理竞赛\Agent.md` does not exist during workspace inspection.
- Impact: A literal two-file merge cannot be performed from existing sources. The only safe fallback is to preserve `AGENTS.md` content and explicitly mark the missing `Agent.md` as an unresolved source gap in the merged artifact.

### Issue 18: The requested target filename `AGENTS.` may not be representable as a stable Windows filename
- Evidence: Windows commonly normalizes trailing dots in file names, and the workspace currently has neither `AGENTS.` nor `AGENTS`.
- Impact: The requested merged filename may collapse to another name at the filesystem layer. The actual created artifact name must therefore be verified after writing instead of assumed.

[2026-06-18 12:14:00+08:00]
## Current UI Acceptance Regression On Stable 4331 Surface

### Issue 19: The current stable acceptance surface no longer proves homepage visibility, while the result page still renders
- Evidence: `http://localhost:4331/` responds with HTTP 200, but the latest in-app browser screenshot renders a blank white homepage surface with empty visible text.
- Evidence: `http://localhost:4331/#/result` also responds with HTTP 200 and still renders a visible result-detail page containing the result hero and main result card.
- Impact: Core requirement 3 cannot be marked satisfied. The current browser-visible evidence is now mixed: the result page remains visible, but homepage first-screen acceptance has regressed on the same verification surface.

### Issue 20: The homepage regression is now supported by DOM-level browser evidence, not only screenshots
- Evidence: On `http://localhost:4331/`, the in-app browser reports `homeTitle = freshsalt_surface` but returns an empty `domSnapshot()` string and no visible body text.
- Evidence: In the same browser session, `http://localhost:4331/#/result` reports `resultTitle = FreshSalt Surface` and returns a non-empty DOM snapshot.
- Evidence: Console logs on both routes only show service-worker bootstrap debug lines and do not provide a positive homepage render signal.
- Impact: The current homepage state is contradicted by prior static screenshots and therefore cannot be accepted from historical image evidence alone. UI requirement 3 remains negative on stronger current runtime evidence.

### Issue 21: The homepage visibility evidence is session-sensitive and currently unstable across browser tabs
- Evidence: Rechecking `http://localhost:4331/` in a freshly created browser tab renders a visible homepage screenshot again, while an older tab session had shown a blank white homepage surface.
- Evidence: In the fresh tab, `http://localhost:4331/#/result` also remains visibly rendered, so both routes can appear alive in a clean session.
- Evidence: DOM snapshot length remains too weak to distinguish the two pages reliably in this runtime, while screenshots clearly differ.
- Impact: The current UI failure mode is better described as unstable acceptance evidence on the homepage rather than a permanently blank homepage. UI requirement 3 still remains unmet because the browser-visible proof is not yet stable enough to accept as final.

### Issue 22: The capture main-flow still does not prove baseline measurement semantics in the browser
- Evidence: `http://localhost:4331/#/capture` renders a visible "采集兼容工作台" page focused on stage navigation, compatibility entry, and step routing rather than a measurement-first surface.
- Evidence: The same fresh browser run on `http://localhost:4331/#/quality-control` produced a blank white screenshot, so the quality-control page is not currently giving stable visible proof of the baseline's required camera preview / ROI / gray-card / imaging-QC semantics.
- Evidence: The visible capture page text emphasizes that stage actions are delegated to other pages, which weakens the browser-visible impression of a direct experimental capture workflow.
- Impact: Even when homepage and result page are visible, the main-flow requirement in core task 3 still remains negative. The browser does not yet stably prove an experimental measurement flow aligned with the baseline docx.

### Issue 23: Main-flow entry actions currently fail to advance the browser-visible route
- Evidence: In a fresh browser tab on `http://localhost:4331/`, the homepage rendered as a blank white surface again.
- Evidence: Clicking the homepage CTA area did not move the URL away from `/`.
- Evidence: On `http://localhost:4331/#/capture`, clicking `进入当前阶段页面` left the browser on `#/capture` instead of advancing to the expected quality-control stage route.
- Impact: The capture main flow is not currently proven clickable end-to-end in the browser. This strengthens the negative conclusion for core task 3 beyond aesthetics alone.

### Issue 24: Capture UI image generation is proceeding without direct access to the original v3 UI board PNG references
- Evidence: Workspace inspection did not return the expected `00_ui_board_v3` or `03_result_detail_v3` image files under `docs/source/`.
- Evidence: The current image task is therefore being guided by the baseline text documents and the user's confirmed measurement-first direction, not by direct pixel comparison to the original reference boards.
- Impact: The generated capture UI pictures can align to the documented platform language and the confirmed interaction priorities, but they should still be treated as design-direction drafts pending the user's visual confirmation.

### Issue 25: Capture page file has a remaining non-blocking const lint after the v2 visual implementation
- Evidence: `dart analyze lib/features/capture/capture_page.dart` reports one `prefer_const_constructors` info at `capture_page.dart:730:13`.
- Impact: This does not block the visual preview or page compilation, but it should be cleaned up later if the file is touched again.

### Issue 26: Existing port 4330 preview is not valid evidence for the new capture page
- Evidence: Capturing `http://localhost:4330/#/capture` after the v2 implementation produced `outputs/capture-page-v2-4330.png`, a blank white 430x932 screenshot.
- Impact: The existing web-server preview cannot prove the new capture page visually. A fresh preview target is required before accepting the visible result.

### Issue 27: Fresh 4334 preview could not produce reliable browser-visible screenshot evidence in this turn
- Evidence: A fresh `flutter run -d web-server --web-port 4334` process reached HTTP 200 on `http://127.0.0.1:4334/#/capture`.
- Evidence: Edge headless screenshot attempts did not create a usable `outputs/capture-page-v2-4334.png`, and a subsequent Dart analyzer invocation failed with a Windows `VirtualAlloc failed 1455` runtime resource error.
- Impact: The capture page source has been updated and the route responds, but browser-visible acceptance remains incomplete until the local preview environment is stable enough to capture the page.

### Issue 28: Static web build is blocked by local Dart VM memory exhaustion
- Evidence: `flutter build web` failed during dart2js with `Out of memory` in the Dart VM while compiling Flutter web output.
- Evidence: The focused `dart analyze lib/features/capture/capture_page.dart` check still reports `No issues found!`, so the observed failure is not a syntax or lint failure in the edited capture page.
- Impact: A clean static web preview cannot be produced in the current resource state. Browser-visible acceptance for the implemented capture page remains pending, while source-level verification for the edited file is positive.

[2026-06-18 13:00:00+08:00]
## Bottom Navigation Scope Diagnosis

- Symptom confirmed from source structure: the bottom navigation is currently defined inside the home page instead of a shared app-level shell.
- Multiple non-home modules (nalysis, eport, esult, demo_validation) still build their own top-level Scaffold, so their route bodies replace the visible page without preserving a shared bottom bar.
- Impact: the five-tab platform shell is not structurally established yet; only the home route can guarantee bottom navigation visibility.


[2026-06-18 14:05:00+08:00]
## Preview Verification Blocker

- The shared bottom-navigation shell refactor now compiles cleanly and lutter analyze passes.
- Browser-visible verification on a fresh preview target is still blocked because the attempted local web preview did not come up on http://localhost:4332, and the existing Flutter web runner evidence shows a bind failure on port 4300 from a separate preview process.
- Impact: source-level and analyzer-level evidence support the fix, but a fresh browser-visible five-tab proof is still incomplete in this turn.


[2026-06-19 13:50:00+08:00]
## Result Preview Artifact Staleness

### Issue 29: The static 4341 preview is now stable enough for cross-page inspection, but it cannot verify the latest result-page source change because the served build artifact was not rebuilt after the edit
- Evidence: 4341 serves uild/web/main.dart.js, while the latest esult_page.dart edit happened after that artifact was copied into uild/web.
- Evidence: the refreshed 4341 result capture did not produce a new screenshot artifact, and the visible result image still reflects the older top-heavy first screen.
- Impact: the next verification step must use a fresh compiled web-server preview rather than the stale static artifact before judging the latest result-page adjustment.


[2026-06-19 14:15:00+08:00]
## Preview Chain Narrowed

### Issue 30: The current verification loop was being misled by two preview-chain defects rather than a newly proven result-page UI regression
- Evidence: the static uild/web artifact initially lacked main.dart.js, and http://127.0.0.1:4340/main.dart.js returned 404 until the file was restored from .dart_tool/flutter_build output.
- Evidence: the fresh lutter run -d web-server --web-port 4343 preview serves on http://localhost:4343, but the failed 4343-result.png capture used 127.0.0.1, which produced a connection-refused browser page despite the web-server staying alive on ::1:4343.
- Impact: the preview chain is now materially better understood, but browser-visible proof of the latest result-page source change is still incomplete because Edge headless did not emit a fresh localhost screenshot artifact in this turn.

[2026-06-20 11:10:00+08:00]
## Android Test Readiness Review

### Issue 31: Widget tests still referenced old visible UI copy after the capture/home visual pass
- Evidence: `flutter test` failed four assertions looking for old labels: `采集兼容工作台`, `任务入口`, and a former first-screen `采集主链` placement.
- Evidence: Current source uses the v2 platform labels `采集工作台`, `核心入口`, `图像入口`, and compact home cards.
- Impact: Analyzer was clean, but the automated test suite could not be used as Android release evidence until the tests were realigned with the accepted visible UI.

### Issue 32: Android runtime testing is currently blocked by missing connected Android device or emulator
- Evidence: `flutter devices` only reported Windows desktop and Edge web targets.
- Evidence: `flutter doctor -v` reported a usable Android SDK and accepted licenses, but no Android Studio installation and no connected Android device.
- Impact: Android APK build can be verified locally, but real-device `flutter run -d android` cannot be claimed in this environment.

### Issue 33: GitHub publishing cannot use the local `gh` command
- Evidence: `gh --version` returned an npm-based `gh 2.8.9`, and `gh auth status` failed with a Node interactive prompt error rather than official GitHub CLI behavior.
- Impact: GitHub publishing must use plain `git` remote push in this turn; PR creation through official `gh` is unavailable.

### Issue 34: Capture page prediction stage read the orchestrator result from the wrong level
- Evidence: After text-alignment fixes, `flutter test` had one remaining failure in `app_flow_test.dart`: the direct `CapturePage` route reached prediction but did not show `保存到历史`.
- Evidence: `FreshSaltAppOrchestrator.executeFullCaptureWorkflow()` returns `feature_vector`, `prediction`, and `pending_save_payload` under the `results` object, while `CapturePage._runPredictionWorkflow()` read `feature_vector`, `prediction_result`, and `pending_save_payload` from the top level.
- Impact: The direct capture workbench could fail to advance from prediction to save in the Android app, even though the demo bundle flow covered by other widget tests still passed.

### Issue 35: Capture page also needed to decode orchestrator JSON payloads back into model objects
- Evidence: After reading the correct `results` object, the focused test failed with `type '_Map<String, dynamic>' is not a subtype of type 'FeatureVector?'`.
- Evidence: The orchestrator serializes `FeatureVector` and `PredictionResult` through `toJson()` in the full workflow response.
- Impact: The capture page boundary must decode these maps before applying prediction state, otherwise the direct capture workflow can throw at runtime.

### Issue 36: Android debug APK build is blocked by the workspace path check on Windows
- Evidence: `flutter build apk --debug -v` failed while applying `com.android.application`.
- Evidence: Android Gradle Plugin reported: `Your project path contains non-ASCII characters` for `F:\1.大学物理竞赛\app\freshsalt_surface`.
- Impact: The project needs `android.overridePathCheck=true` in `android/gradle.properties` or a temporary ASCII build path before APK build evidence can be accepted.

### Issue 37: Flutter shader compilation still fails on the Chinese workspace path, but succeeds through an ASCII drive mapping
- Evidence: After adding `android.overridePathCheck=true`, `flutter build apk --debug` failed when `impellerc` tried to write `build/.../flutter_assets/shaders/ink_sparkle.frag` under `F:\1.大学物理竞赛\...`.
- Evidence: The same project built successfully through `subst X: F:\1.大学物理竞赛\app\freshsalt_surface`, producing `build/app/outputs/flutter-apk/app-debug.apk`.
- Impact: Android build verification is positive through the ASCII mapped path, but future direct Windows builds from the Chinese path may still hit the Flutter shader write failure.

### Issue 38: Public GitHub push must not include local system font binaries or browser profile caches
- Evidence: `assets/fonts/msyh.ttc` and `assets/fonts/msyhbd.ttc` are local Microsoft YaHei TTC files totaling about 36 MB.
- Evidence: `outputs` contains browser profile/cache directories totaling multiple GB.
- Impact: The repository needs a root ignore policy and the app should rely on platform font fallback instead of committing local system fonts.

### Issue 39: Initial PowerShell file reads displayed UTF-8 project docs as mojibake
- Evidence: The first `Get-Content -Raw` reads for the raster AGENTS/document/step files rendered Chinese text as garbled characters in terminal output.
- Evidence: Re-reading the same files with `-Encoding UTF8` produced correct Chinese text.
- Impact: Future raster-data planning or execution should explicitly use UTF-8 reads for Chinese project documents to avoid misreading scientific constraints.

### Issue 40: Python PDF reader failed on the Chinese notification PDF path
- Evidence: `pypdf.PdfReader` raised `OSError: [Errno 22] Invalid argument` when opening the Downloads PDF through a Chinese filename path.
- Impact: Copy the PDF to an ASCII temporary path before extraction so the competition-track decision is based on the actual notice text instead of memory.

### Issue 41: Initial directory creation command used an invalid PowerShell `-Path` array form
- Evidence: `New-Item -ItemType Directory -Force -Path $root, $dirs` failed with `Cannot convert 'System.Object[]' to the type 'System.String'`.
- Impact: Create the analysis directories in a loop or pass a single path at a time.

### Issue 42: First-pass fixed ROI mixed fruit-edge reflection into the grating band
- Evidence: The initial ROI overlay in `outputs/grating_ai_physics_experiment/roi/roi_overlay/roi_4_repeat_0_raw.png` showed the top edge of the rectangle touching the tomato reflection region.
- Evidence: The first stability pass only reached `between_within_ratio = 1.334` for `raw`, below the provisional 1.5 gate.
- Impact: The ROI was narrowed downward before rerunning the analysis, and modeling remains paused until ROI/data quality improves further.

### Issue 43: Current narrowed ROI still does not pass the provisional model-entry stability gate
- Evidence: `outputs/grating_ai_physics_experiment/stability/stability_group_stats.csv` shows `raw between_within_ratio = 1.409` and `focused between_within_ratio = 1.265`.
- Evidence: `outputs/grating_ai_physics_experiment/stability/stability_decision.md` keeps both image types at `risk` and sets the route decision to `pause_modeling_review_roi_or_data`.
- Impact: Do not enter grouped baseline, linear model, or PLSR until ROI or data conditions improve.

### Issue 44: Manual semantic anomaly review is still incomplete
- Evidence: `outputs/grating_ai_physics_experiment/qc/qc_summary.md` explicitly states that automated QC does not yet classify black borders, handwritten labels, fruit-edge overlap, or background pollution semantically.
- Evidence: Current anomaly outputs focus on file-size outliers and global image metrics only.
- Impact: A manual anomaly table should be added before any stronger scientific interpretation, so non-signal artifacts are not mistaken for concentration response.

### Issue 45: No leakage-safe grouped baseline or model validation has been run
- Evidence: `outputs/grating_ai_physics_experiment/model_review/model_candidate_review.md` states that no model training was performed and modeling is deferred.
- Evidence: `outputs/grating_ai_physics_experiment/report/requirement_evidence_matrix.md` marks grouped modeling evidence as `fail`.
- Impact: The project cannot currently claim model validity, predictive capability, or PLSR effectiveness.

### Issue 46: The focused image branch is currently weaker than the raw branch for route continuation
- Evidence: `outputs/grating_ai_physics_experiment/stability/stability_group_stats.csv` shows `focused between_within_ratio = 1.265`, below `raw = 1.409`.
- Evidence: `outputs/grating_ai_physics_experiment/report/track_recommendation.md` identifies `raw` as the more promising next-round refinement target.
- Impact: Further ROI and stability work should prioritize `raw`; `focused` should not be used as the primary branch for the next model-entry attempt.

### Issue 47: Selected ROI is an engineering tradeoff, not the highest total-score candidate
- Evidence: `outputs/grating_ai_physics_experiment/roi/roi_candidate_comparison.csv` shows `focused_favor` has the highest combined score (`2.694764`), while `narrow_raw_favor` has the best `raw` ratio (`1.409023`) but a lower total score (`2.674510`).
- Evidence: `outputs/grating_ai_physics_experiment/roi/roi_candidate_comparison.md` documents that the current default ROI was chosen to preserve the stronger `raw` branch, not to maximize summed branch performance.
- Impact: Future readers should not misinterpret the current ROI as globally optimal; it is only the best current choice under the branch-priority rule.

### Issue 48: Manual semantic anomaly review still exists only as an unfilled queue
- Evidence: `outputs/grating_ai_physics_experiment/qc/manual_semantic_review_queue.csv` and `.md` were created, but every row remains `review_status = pending`.
- Evidence: The queue includes required fields for handwritten text, black border, fruit-edge overlap, central grid interference, and background pollution, but no row has been adjudicated yet.
- Impact: The review mechanism now exists, but the semantic anomaly gate itself is still incomplete and must be finished before stronger interpretation or model entry.

### Issue 49: First contact-sheet export failed because the thumbnail canvas height collapsed to zero
- Evidence: The initial PIL export for `manual_review_contact_sheet.png` raised `ValueError: cannot write empty image`.
- Evidence: The contact-sheet script used a thumbnail target height smaller than the source aspect-ratio requirement for some images, producing an invalid write path during save.
- Impact: The contact-sheet generation script must use a larger thumbnail canvas and retry before semantic anomaly review can proceed efficiently.

### Issue 50: Direct Python glob on the Chinese source directory returned zero files during contact-sheet generation
- Evidence: The matplotlib retry failed with `ValueError: Number of rows must be a positive integer, not 0`, which means the script found zero PNG files before subplot creation.
- Evidence: Earlier inventory generation already proved that 30 PNG files exist, so the failure is in direct directory enumeration, not missing data.
- Impact: Contact-sheet generation should read absolute file paths from the already-validated `inventory/index.csv` instead of re-enumerating the Chinese source directory.

### Issue 51: Raw-only ROI optimization improved separation only marginally and still did not pass the provisional gate
- Evidence: `outputs/grating_ai_physics_experiment/roi/raw_roi_optimization.md` shows the best raw-only ROI candidate at `x0=350, y0=550, x1=1110, y1=610` with `raw_between_within_ratio = 1.42827`.
- Evidence: This is only a small improvement over the prior selected ROI and still remains below the provisional `1.5` model-entry gate.
- Impact: ROI optimization alone was insufficient to make the raw branch model-admissible; further data control or feature redesign is required.

### Issue 52: Ridge and multifeature linear models failed to beat the grouped mean baseline
- Evidence: `outputs/grating_ai_physics_experiment/model_review/model_evaluation_summary.csv` shows `mean_baseline rmse = 2.828`, while `ridge_alpha_10 rmse = 3.383` and `multifeature_linear rmse = 13.718`.
- Evidence: No Ridge candidate met the export rule of clearly outperforming the grouped baseline.
- Impact: The user-selected final model family (`Ridge / 轻量多特征线性回归`) is not admissible from the current data round and must not be exported into APP as the final model.

### Issue 53: Only a weak single-feature signal exists, but it is not strong enough for final APP export
- Evidence: `single_roi_mean_gray` is the best current candidate with `rmse = 2.664`, `mae = 2.395`, `r2 = 0.113`, only slightly better than the mean baseline.
- Evidence: The export script required at least a 10% gain in both RMSE and MAE plus positive `R2`; this candidate did not satisfy that rule.
- Impact: A weak correlation exists, but it is not yet defensible as the final in-app model.

### Issue 54: No final ModelBundle was exported because the current training round did not satisfy the bundle gate
- Evidence: `outputs/grating_ai_physics_experiment/model_review/final_model_report.md` explicitly states that no candidate beat the mean baseline strongly enough to justify final APP export.
- Evidence: `final_model_bundle.json` and `final_model_bundle_app_compat.json` were not generated in this round.
- Impact: APP integration must remain blocked until a future raw-only round produces a candidate that clearly exceeds the grouped baseline.

### Issue 55: APP structure can host a linear bundle, but current feature extraction service is still demo-oriented
- Evidence: `app/freshsalt_surface/lib/core/services/feature_extraction_service.dart` still emits simulated keys from `imageMetadata` and labels the extraction method as `simulated`.
- Evidence: Even if a valid bundle existed, the current APP feature pipeline would still need real ROI-derived feature values supplied by the capture/analysis path.
- Impact: Final APP deployment needs both an admissible model and a non-demo feature feed; current work only confirmed the bundle contract, not full end-to-end production readiness.

### Issue 56: First aggressive ROI grid scan spent too long without returning usable ranked output
- Evidence: A broad exploratory Python scan over many ROI candidates ran long enough to require abandonment, and the follow-up process lookup found no active process to terminate.
- Evidence: No ranked candidate list was captured from that attempt.
- Impact: Subsequent ROI search should use a smaller, more targeted candidate grid instead of broad brute-force enumeration.


### Issue 57: The current training script still does not cover the stronger two-feature Ridge route found in the follow-up manual search
- Evidence: `outputs/grating_ai_physics_experiment/scripts/train_raw_model.py` still evaluates the older feature set (`roi_mean_gray`, `roi_std_gray`, `normalized_auc`, `peak_pixel_position`, `peak_normalized_value`, `gradient_energy`, `band_mean_left`, `band_mean_mid`) and does not include the manually improved pair `band5_grad_mean` + `band2_grad_mean`.
- Evidence: The current report `outputs/grating_ai_physics_experiment/model_review/final_model_report.md` therefore only reflects the weaker scripted round rather than the later better manual Ridge candidate.
- Impact: The next modeling round should not start from scratch; it should patch the script around the improved ROI `(345, 550, 1090, 610)` and re-run the exact two-feature Ridge route first.

### Issue 58: The most promising final model family is now a lightweight Ridge with two local-band gradient features, but it is still awaiting scripted rerun confirmation
- Evidence: The follow-up manual search found a better grouped-validation candidate with `alpha=10`, subset `('band5_grad_mean', 'band2_grad_mean')`, `rmse = 2.36798`, `mae = 1.98957`, `r2 = 0.29909`.
- Evidence: This candidate outperforms the grouped mean baseline (`rmse = 2.82843`, `mae = 2.4`) by more than 10% in both RMSE and MAE, which is the current internal export gate.
- Impact: Model-family selection should now default to `Ridge / 轻量多特征线性回归`, not PLSR and not single-feature linear regression. However, final export must still wait for a scripted, reproducible rerun that regenerates all reports and bundles.

### Issue 59: APP-side bundle configuration is structurally possible, but the feature feed is still demo-metadata-driven rather than image-derived
- Evidence: `app/freshsalt_surface/lib/core/models/model_bundle.dart` and `app/freshsalt_surface/lib/core/services/prediction_service.dart` already support loading a linear coefficient bundle and computing predictions from ordered features.
- Evidence: `app/freshsalt_surface/lib/core/services/feature_extraction_service.dart` still fills features from `imageMetadata` keys and labels the extraction path as `simulated`.
- Impact: Even after a valid final bundle is exported, APP configuration is only partially ready. The bundle can be placed into the APP contract, but end-to-end scientific deployment still depends on a future real ROI-derived feature feed. This limitation must stay explicit and must not be hidden by claiming full production readiness.

### Issue 60: Recommended next-step execution order is now model-focused rather than broad exploration
- Evidence: Current evidence already rules out `focused` as the main branch and rules out PLSR as the default final route.
- Evidence: The strongest available direction is the raw-only branch with a compact two-feature Ridge candidate near the tightened ROI.
- Impact: The next work order should be: (1) patch `train_raw_model.py` to reproduce the improved ROI and local-band gradient features, (2) rerun grouped validation and regenerate `raw_roi_optimization.md`, `raw_feature_table.csv`, `model_evaluation_summary.csv`, `model_fold_predictions.csv`, `final_model_report.md`, (3) export `final_model_bundle.json` and `final_model_bundle_app_compat.json` only if the rerun still clears the baseline gate, (4) keep APP code unchanged and only prepare the bundle for later configuration.

## 2026-06-26 Current Outcome and Recommended Route

### Current progress
- The raw-only branch remains the correct continuation branch.
- The current scripted round is not the final answer, because it still reflects the weaker feature set.
- The strongest observed candidate so far is a lightweight Ridge model using two local-band gradient features.
- APP code should not be modified now; the correct target is a final bundle that is compatible with the existing `ModelBundle + PredictionService` path.

### Remaining work
- Reproduce the better Ridge result in the official training script and output files.
- Decide final admissibility only from the rerun artifacts, not from manual shell notes alone.
- Export the final bundle only after the reproducible rerun passes the current baseline-improvement gate.
- Keep the APP integration statement conservative because the feature extraction path is still simulated.

### Execution steps
- Step 1: Keep the raw-only route and lock the ROI search around `(345, 550, 1090, 610)`.
- Step 2: Rebuild a compact feature table centered on local-band gradient descriptors, especially `band5_grad_mean` and `band2_grad_mean`.
- Step 3: Re-run grouped mean baseline, single-feature linear, and Ridge subset search, with `alpha=10` included explicitly.
- Step 4: If the two-feature Ridge still beats baseline by the current gate, export the final model bundle and the APP-compat bundle.
- Step 5: Record in all reports that this is a controlled-image response model for soaking concentration labels, not a direct true fruit-surface salt-content model.

### Verification criteria
- The rerun output files must all be regenerated by the patched script.
- The selected final candidate must still beat the grouped mean baseline in both RMSE and MAE under leave-one-repeat-out validation.
- The bundle metadata must include ROI rule, training split, source branch, feature order, and warnings.
- No claim may imply food-safety judgment, production-grade deployment, or true surface-salt quantification.

### Acceptance criteria
- Accept the next round only if the better Ridge result is reproduced in official outputs and a bundle is exported.
- If the rerun fails to reproduce the gain, keep the project in a model-blocked state and do not configure a final APP model.
- APP-side acceptance for this stage means “bundle contract ready for later configuration”, not “real image-to-result pipeline completed”.

### Issue 61: The exported best Ridge bundle is structurally two-feature but effectively one-feature because `peak_normalized_value` is constant
- Evidence: `outputs/grating_ai_physics_experiment/model_review/raw_feature_table.csv` shows `peak_normalized_value` has `min = 1.0`, `max = 1.0`, `nunique = 1` across all 15 raw samples.
- Evidence: `outputs/grating_ai_physics_experiment/model_review/final_model_bundle.json` therefore exports coefficients `[0.0, 443.491476078044]`, which means the first feature contributes nothing and the practical predictive signal comes from `band2_grad_mean`.
- Impact: The final admissible model for this round is still a valid lightweight Ridge export, but it should be described as an effectively single-signal Ridge under the current normalization scheme, not as a materially richer two-feature model.

### Issue 62: The manually observed `band5_grad_mean + band2_grad_mean` route was not the final reproducible winner in the official rerun
- Evidence: The official rerun `outputs/grating_ai_physics_experiment/model_review/model_evaluation_summary.csv` ranks `ridge_alpha_3__peak_normalized_value__band2_grad_mean` first with `rmse = 2.37209`, `mae = 2.05416`, `r2 = 0.29665`.
- Evidence: The explicit `band5_grad_mean + band2_grad_mean` Ridge candidates remain weaker in the same rerun, for example `ridge_alpha_3__band5_grad_mean__band2_grad_mean` with `rmse = 2.48452`, `mae = 2.12094`, `r2 = 0.22839`.
- Impact: Future work should treat the reproducible official rerun as authoritative. The current final bundle should follow the rerun winner, while `band5_grad_mean` remains a useful exploratory feature rather than the selected final signal.

## 2026-06-26 Final Modeling Outcome

### Current progress
- The requested raw-only modeling chain was executed end to end.
- ROI was re-optimized to `x0=345, y0=550, x1=1090, y1=610`, improving raw between/within ratio to `1.43764`.
- Mean baseline, single-feature linear, and Ridge/lightweight multifeature search were all rerun under grouped validation.
- A final admissible Ridge bundle was exported: `outputs/grating_ai_physics_experiment/model_review/final_model_bundle.json` and `final_model_bundle_app_compat.json`.

### Remaining work
- Keep APP code unchanged for now.
- If later improving scientific quality, remove constant-value pseudo-features from the candidate pool and re-check whether a truly multi-feature model can beat the current export.
- Future APP-side deployment still requires a real ROI-derived feature feed instead of metadata-only simulation.

### Execution steps completed
- Re-scanned ROI around the tightened raw-only window.
- Rebuilt the low-dimensional feature table with local gradient features.
- Re-ran grouped mean baseline, single-feature regression, and subset-based Ridge/linear search.
- Exported the final Ridge bundle only after the rerun beat baseline strongly enough.

### Verification criteria satisfied
- Grouped validation was used with `repeat_id` holdout.
- Metrics were reported against the mean baseline.
- Export happened only after the final candidate improved on baseline by the current gate.
- Bundle metadata includes ROI rule, training split, source branch, and warnings.

### Acceptance criteria status
- This stage is accepted as a completed model-selection/export round.
- Acceptance at this stage means the final model bundle is ready to be configured into the APP contract.
- Acceptance does not mean the APP already has a real image-derived feature pipeline.

### Issue 63: The old exported bundle used a constant pseudo-feature and has now been corrected
- Evidence: The prior `final_model_bundle.json` exported `peak_normalized_value` plus `band2_grad_mean`, but `peak_normalized_value` had `nunique = 1` across all 15 raw samples.
- Evidence: `outputs/grating_ai_physics_experiment/scripts/test_train_raw_model.py` now includes `test_filter_candidate_feature_sets_removes_constant_features`.
- Evidence: The rerun `outputs/grating_ai_physics_experiment/model_review/final_model_bundle.json` now exports only `band2_grad_mean`.
- Impact: The official bundle is more scientifically honest, but it also makes the limitation explicit: the current model is single-signal Ridge, not a strong multi-feature model.

### Issue 64: The current model remains moderate evidence rather than a strong quantitative conclusion
- Evidence: The official rerun ranks `ridge_alpha_3__band2_grad_mean` first with `RMSE = 2.37209`, `MAE = 2.05416`, and `R2 = 0.29665`.
- Evidence: This beats `mean_baseline`, but the explained variance remains low enough that strong measurement claims would be overreach.
- Impact: The current model can support an APP-compatible demonstrator bundle and a staged experimental narrative, but not a high-confidence salt-content model.

### Issue 65: Semantic artifact handling is now specified but not yet executed as a final exclusion gate
- Evidence: `outputs/grating_ai_physics_experiment/qc/artifact_gate_rule.md` defines `pass`, `warn`, `block`, and `unknown` rules for handwritten text, black borders, fruit-edge reflection, central grid interference, and background pollution.
- Evidence: `manual_semantic_review_summary.md` still says the current screen is contact-sheet-level and not pixel-accurate.
- Impact: Before claiming a stronger model, every raw sample needs selected-ROI overlay review and artifact gate labels, followed by a gated-set model rerun.

### Issue 66: Evidence matrix previously contradicted the current modeling state
- Evidence: The old `requirement_evidence_matrix.md` still said no baseline model run had been performed even after the official grouped baseline and Ridge rerun existed.
- Evidence: The matrix has been rewritten with current evidence states, including `pass_with_risks` for grouped modeling and `fail` for true surface-salt measurement.
- Impact: Future readers should use the rewritten matrix and `evidence_strengthening_package.md` rather than older partial-completion wording when judging current model status.

### Issue 67: The first executable artifact gate classifies all raw samples as `unknown`
- Evidence: `outputs/grating_ai_physics_experiment/qc/artifact_gate_decisions.csv` contains 15 raw-sample rows and all have `gate_state = unknown`.
- Evidence: The repeated risk flags are `fruit_edge_overlap`, `central_grid_interference`, `handwritten_text`, and `background_pollution`.
- Evidence: `outputs/grating_ai_physics_experiment/qc/artifact_gate_overlay/` now contains 15 selected-ROI overlay images for pixel-level review.
- Impact: A clean artifact-gated model rerun is not currently admissible. The correct next step is pixel-level overlay review, not stronger model claims.

### Issue 69: Pixel-level ROI overlay review found no clean artifact-controlled raw subset
- Evidence: `outputs/grating_ai_physics_experiment/qc/artifact_gate_pixel_review.csv` contains 15 raw-sample rows and all have `pixel_review_state = warn`.
- Evidence: The same file sets `clean_subset_eligible = false` for all 15 raw samples.
- Evidence: `artifact_gate_pixel_review_summary.md` states that no clean `pass` sample exists under the current selected ROI.
- Impact: The current model can remain a warning-labeled stage demonstrator, but it cannot be upgraded to an artifact-controlled model without tighter ROI redesign or a cleaner acquisition batch.

### Issue 70: Artifact-aware rectangular ROI micro-tuning did not find a replacement ROI worth adopting
- Evidence: `outputs/grating_ai_physics_experiment/roi/artifact_aware_roi_scan.md` reports the best combined candidate as `x0=420, y0=605, x1=1090, y1=629` with `raw_between_within_ratio = 1.32056`, below the current ROI ratio `1.43764`.
- Evidence: The contact sheet `outputs/grating_ai_physics_experiment/roi/artifact_aware_roi_overlay_contact_sheet.png` shows top conservative candidates still near the lower reflection/grating response band.
- Impact: Do not replace the current model ROI from this scan. Stronger evidence likely requires acquisition redesign, cleaner samples, or a different physical ROI strategy rather than more rectangular micro-tuning.

### Issue 71: First artifact-aware ROI scan timed out before grid reduction
- Evidence: The initial `scan_artifact_aware_roi.py` run timed out after about 124 seconds.
- Resolution: Reduced the grid to 54 targeted candidates and reran successfully.
- Impact: Future ROI scans should stay targeted or add caching/vectorization before broadening the grid.

### Issue 68: A PowerShell command initially used bash heredoc syntax during artifact statistics
- Evidence: `python - <<'PY'` failed in PowerShell because `<` is reserved and not a valid stdin heredoc form there.
- Resolution: Re-ran the same statistics using PowerShell here-string input piped into Python.
- Impact: No data products were affected; this is a command-form issue to avoid in future Windows runs.

## 2026-06-26 Evidence Strengthening Update

### Current progress
- Constant-value candidate features are now filtered before single-feature, linear, and Ridge model evaluation.
- The final exported bundle is `ridge_alpha_3__band2_grad_mean`, with `band2_grad_mean` as the only exported feature.
- `report/evidence_strengthening_package.md` records the model claim boundary, anti-question evidence set, experiment matrix, label boundary, and semi-physical explanation chain.
- `qc/artifact_gate_rule.md` converts semantic artifact review into explicit pass/warn/block/unknown gate rules.
- `report/requirement_evidence_matrix.md` has been updated to remove the stale "no baseline model run" conclusion.
- `qc/artifact_gate_decisions.csv`, `qc/artifact_gate_decision_summary.md`, and 15 ROI overlay images now move semantic pollution from a narrative risk into an executable gate artifact.
- `qc/artifact_gate_pixel_review.csv` and `qc/artifact_gate_pixel_review_summary.md` now convert the first-pass `unknown` gate into a second-layer `warn` decision for all raw samples.

### Remaining work
- The model still needs a true second or third independent feature before it can be described as a robust multi-feature model.
- ROI separation remains moderate at `1.43764`, so stronger ROI and artifact-gated reruns are still needed.
- Current pixel-level artifact review output is 15/15 `warn` and 0/15 clean-subset eligible, so no clean gated-set model rerun should be claimed yet.
- Artifact-aware rectangular micro-tuning did not identify a replacement ROI that improves both cleanliness and separation.
- More repeats, new batches, robustness tests, and a stronger reference label are required for high-confidence claims.

### Issue 72: The new claim-boundary brief existed but was not yet linked into the official evidence chain
- Evidence: `outputs/grating_ai_physics_experiment/report/model_challenge_evidence_brief.md` was created as a defense-ready summary, but it was not yet referenced in `report/evidence_strengthening_package.md`, `report/requirement_evidence_matrix.md`, or the run logs.
- Resolution: Linked the brief into the evidence package and requirement matrix, then recorded the addition in both `workflow-error-2026-06-15.md` and `workflow.log`.
- Impact: The current model boundary, anti-question answers, and "do not overclaim" position are now part of the official evidence trail rather than a standalone side note.

### Issue 73: The evidence chain had an experiment matrix but no formal reacquisition and robustness execution standard
- Evidence: `report/evidence_strengthening_package.md` listed experiment blocks for repeat expansion, batch expansion, artifact gate, illumination robustness, angle robustness, and surface-state robustness, but there was no dedicated document defining required metadata, acquisition-stage blocking rules, minimum sample targets, rerun order, or mechanism-bridge evidence preservation.
- Resolution: Added `outputs/grating_ai_physics_experiment/report/reacquisition_and_robustness_protocol.md` and linked it from the evidence package and requirement matrix.
- Impact: The project now has a defense-ready and execution-ready protocol for the next evidence-strengthening round, rather than only a high-level matrix of suggested experiments.

### Issue 74: The protocol existed, but there was still no operator-usable capture checklist or record template
- Evidence: The new protocol defined what the next round should achieve, but it still required a human operator to manually reconstruct the capture order, metadata fields, tentative gate marks, and robustness-condition records on site.
- Resolution: Added `capture_execution_checklist.md`, `capture_metadata_template.csv`, and `robustness_record_template.csv`, then linked them from the protocol, evidence package, and requirement matrix.
- Impact: The next reacquisition round can now be executed with a concrete checklist and fill-in templates instead of relying on memory or ad hoc note-taking.

### Issue 75: The next-round data flow still lacked a formal naming and directory standard
- Evidence: The protocol and capture templates introduced `batch_id`, `repeat_id`, `file_name`, `angle_condition`, and `surface_state`, but there was still no single rule defining how new files should be named, where raw vs focused images should be placed, or how metadata files should be organized by batch.
- Resolution: Added `data_naming_and_directory_standard.md` and linked it from the checklist, protocol, evidence package, and requirement matrix.
- Impact: The next reacquisition round now has a formal data-organization standard, reducing the risk that naming ambiguity or mixed folders weakens the evidence chain before analysis even begins.

### Issue 76: The execution assets existed, but there was still no one-page summary for team handoff or defense appendix use
- Evidence: The project had a protocol, checklist, templates, and naming standard, but a teammate or judge still had to open multiple files to understand the current model ceiling, the blocking gate states, the minimum next-round sample target, and the required rerun order.
- Resolution: Added `execution_summary_sheet.md` and linked it from the evidence package and requirement matrix.
- Impact: The next-round evidence plan can now be handed off or shown in defense form as a single-page controlled standard rather than a scattered set of supporting files.

### Issue 77: The gray-box mechanism explanation existed only as scattered statements, not a defense-ready Q&A card
- Evidence: `evidence_strengthening_package.md` already contained a mechanism-bridge section, but there was still no short standalone artifact answering why `band2_grad_mean` matters, what supports that interpretation, what weakens it, and what wording is safe or unsafe in defense.
- Resolution: Added `mechanism_bridge_qa_card.md` and linked it from the evidence package and requirement matrix.
- Impact: The project now has a concise mechanism-defense artifact that strengthens the answer path from empirical feature importance to gray-box interpretation without overstating the science.

### Issue 78: The label boundary existed in reports, but there was still no standalone Q&A card for the target physical quantity question
- Evidence: The reports already stated that the current target is soaking-solution concentration response in `mg/L`, not true fruit-surface salt content, but there was still no short artifact specifically answering "what exactly are you predicting?" and "what would be needed to upgrade this into a stronger physical label?".
- Resolution: Added `label_boundary_reference_qa_card.md` and linked it from the evidence package and requirement matrix.
- Impact: The project now has a dedicated defense artifact for the label-boundary question, reducing the risk of overstating what the current `mg/L` output physically represents.

### Issue 79: Robustness requirements existed, but there was still no standalone defense card for failure-boundary questions
- Evidence: The protocol and evidence package already listed illumination, angle, surface-state, and batch robustness as required future blocks, but there was still no short artifact answering "is the current model robust?", "where does it most likely fail?", and "what evidence would count as real robustness?".
- Resolution: Added `robustness_failure_boundary_qa_card.md` and linked it from the evidence package and requirement matrix.
- Impact: The project now has a dedicated defense artifact for external-boundary and failure-axis questions, reducing the risk of accidentally overstating generalization beyond the currently tested route.

### Issue 80: The project had separate defense cards, but still lacked a one-page master speaking guide
- Evidence: Separate cards now existed for mechanism, label boundary, and robustness boundary, but a presenter still had to switch between multiple files to answer a continuous line of defense questions.
- Resolution: Added `defense_qa_master_card.md` and linked it from the evidence package and requirement matrix.
- Impact: The project now has a one-page defense speaking guide that compresses the most common continuous question chain into a single artifact.

### Issue 81: The defense artifacts existed, but there was still no appendix index or citation map
- Evidence: The project now had master and supporting cards plus execution materials, but a reviewer or teammate still had no formal index explaining which file to open first for defense, which file to open first for execution, or which artifact should be cited for specific question types.
- Resolution: Added `defense_appendix_index.md` and linked it from the evidence package and requirement matrix.
- Impact: The defense and handoff package now has a formal appendix directory and citation map instead of relying on ad hoc file discovery.

### Issue 82: The project had reacquisition standards, but still lacked a clear guide for reconnecting new data to the current scripts
- Evidence: `run_grating_analysis.py` still assumes a fixed source directory and legacy filename parser, while `train_raw_model.py` depends on the regenerated `inventory/index.csv`; there was no dedicated guide explaining how a newly structured reacquisition batch should be turned into a script-consumable analysis input set before rerun.
- Resolution: Added `reacquired_data_analysis_ingestion_guide.md` and linked it from the evidence package and requirement matrix.
- Impact: The project now has an explicit handoff note for how new experimental data should enter the current analysis chain without silent parsing drift or mislabeled reruns.

### Issue 83: The ingestion guide existed, but the first-stage script still had no structured-metadata inventory entry
- Evidence: `run_grating_analysis.py` could only build inventory from the fixed source directory plus legacy filename parser, which meant a disciplined reacquisition batch still had to be manually converted into parser-compatible names before entering the current chain.
- Resolution: Added `build_inventory_from_capture_metadata(...)` to `run_grating_analysis.py`, added `test_run_grating_analysis.py`, and updated the ingestion guide/README to reflect the new entry path.
- Impact: A filled capture metadata CSV can now generate inventory rows and raw/focused pairing directly for a structured reacquisition batch, reducing the chance of silent relabeling during the handoff into analysis.

### Issue 84: The structured-metadata entry existed only as a helper, not yet as an explicit main-script input mode
- Evidence: After the helper entry was added, the stage-1 script still defaulted to the legacy source-directory path unless a developer imported the helper manually.
- Resolution: Added `--metadata-csv <path>` to `run_grating_analysis.py`, extended tests, and updated README / ingestion guide accordingly.
- Impact: The main stage-1 command can now explicitly choose a structured reacquisition metadata file as its inventory source, reducing manual glue steps before rerun.

### Issue 85: Structured metadata inventory rows still dropped reacquisition context fields
- Evidence: `python -m pytest outputs/grating_ai_physics_experiment/scripts/test_run_grating_analysis.py -q` failed on `test_build_inventory_from_capture_metadata_preserves_reacquisition_fields` with `KeyError: 'batch_id'`.
- Root cause: `build_inventory_from_capture_metadata(...)` rebuilt each inventory row from a fixed hard-coded column subset and discarded reacquisition columns such as `batch_id`, `capture_date`, `camera_id`, `lighting_id`, `distance_id`, `angle_condition`, `surface_state`, and `tentative_gate_state`.
- Impact: Structured reacquisition batches could enter the analysis chain, but downstream inventory artifacts would silently lose the very provenance fields needed for batch-level review and robustness analysis.

### Issue 86: The current evidence chain still lacks a compact, reproducible explanation for why extra features fail and where repeat-holdout generalization breaks
- Evidence: `model_evaluation_summary.csv` shows the official winner remains `ridge_alpha_3__band2_grad_mean`, while most two-feature and three-feature candidates do not improve RMSE or R2 enough to beat the single-feature route.
- Evidence: `final_model_report.md` reports the winner, but it does not yet isolate fold-level failure structure, incremental gain over the best single feature, or whether artifact-warning samples cluster with the worst residuals.
- Impact: The project can say the current model is weak-to-moderate, but it still cannot answer the strongest review question cleanly: "why exactly do the second and third features fail to add robust information under repeat holdout?"

### Issue 87: Weakest-fold evidence still stops at aggregate RMSE and does not yet show what structurally breaks in repeat 1
- Evidence: `repeat_holdout_fold_diagnostics.csv` already shows repeat `1` is the weakest fold, but it does not yet quantify whether the failure is monotonicity loss, dynamic-range collapse, concentration-order confusion, or a repeat-specific feature-scale shift.
- Impact: Without a repeat-level feature/ordering diagnostic, the current evidence can say "repeat 1 is weak" but still cannot explain whether the next priority should be ROI cleanup, acquisition drift control, or robustness-condition logging.

### Issue 88: The new high-concentration watch rule exists in mainline capture assets, but robustness records still do not carry the same watch trace
- Evidence: `capture_metadata_template.csv`, `capture_execution_checklist.md`, `data_naming_and_directory_standard.md`, `reacquisition_and_robustness_protocol.md`, and `execution_summary_sheet.md` already reference `high_conc_watch_tag`.
- Evidence: `robustness_record_template.csv` still lacks `high_conc_watch_tag`, so a `6/8 mg/L` watch sample could still lose that trace once it enters illumination/angle/surface-state blocks.
- Impact: The next batch would be more disciplined in mainline capture, but high-concentration weak-fold attribution could still break once robustness perturbations are logged.

### Verification criteria
- Tests: `python -m pytest outputs/grating_ai_physics_experiment/scripts/test_train_raw_model.py` passed.
- Training: `python outputs/grating_ai_physics_experiment/scripts/train_raw_model.py` completed.
- Bundle check: `final_model_bundle.json` now contains only `band2_grad_mean` in `feature_order`.

### Acceptance criteria status
- Accepted for this stage: evidence is cleaner and better documented than the prior pseudo-two-feature bundle.
- Not accepted as final science: quantitative strength, robustness, artifact exclusion, and true surface-salt calibration remain unresolved.

## 2026-06-26 FreshSalt APP Runtime Recovery Update

### Issue 89: The current APP was judged as "cannot open", but the latest live runtime evidence shows the web platform can open when served from the actual localhost endpoint
- Evidence: `flutter run -d web-server --web-port 4350` successfully served the app at `http://localhost:4350`.
- Evidence: the in-app browser opened the live runtime and captured a visible homepage workbench rather than a white screen.
- Evidence: a previous failed check used `http://127.0.0.1:4350` and returned `ERR_CONNECTION_REFUSED`, while the active Flutter web-server process reported `localhost:4350`.
- Impact: the immediate "APP cannot open" conclusion was too broad for the current web runtime. The more accurate current state is that the web-served platform opens, but interactive chain verification still reveals blocking issues inside the workflow.

### Issue 90: The quality-control page trapped the main capture chain after pass, because the primary action never switched from rerun to next-stage navigation
- Evidence: from the live homepage, clicking the main entry opened `#/quality-control`, and running QC changed the stage state to passed.
- Evidence: after the pass state, the page text said the next step was `I0`, but the large primary button still performed the QC action and left the user on the same page.
- Root cause: `app/freshsalt_surface/lib/features/quality_control/quality_control_page.dart` bound the main filled button only to `_runQualityControl`, instead of switching to baseline-stage navigation after QC success.
- Resolution: rewrote `quality_control_page.dart` so the main primary action changes to `进入 I0 基线图` and navigates to `AppRouter.baselineStage` once QC has passed and the workflow state allows continuation.
- Impact: this was a real main-chain blocker. The page looked complete, but the platform flow was not actually advancing.

### Issue 91: Direct hash-route opening of the quality-control page without a capture bundle still produces a disabled action state
- Evidence: directly opening `http://localhost:4350/#/quality-control` after reload showed `未选择` sample state and a disabled primary button.
- Evidence: this route instance had no incoming `CaptureStepBundle`, so runtime context such as sample selection and QC action binding was missing.
- Impact: the route is not self-sufficient when opened in isolation. This does not block the normal homepage-driven flow, but it remains a runtime behavior difference that should be documented during click-based validation.

### Issue 92: Browser automation click evidence is still sensitive to coordinate targeting on the Flutter web canvas
- Evidence: one live verification attempt intended to continue the QC chain instead landed on `#/result`, indicating that coordinate-based canvas clicks can hit the wrong visual target when reused without fresh alignment.
- Evidence: the app rendered normally and did not throw a console exception during that jump.
- Impact: this is a verification-risk issue rather than a confirmed business-logic regression. Further click coverage should prefer tighter state-aware targeting or repeated visual alignment before treating a coordinate miss as an app logic failure.

### Issue 93: The sample-entry module is browser-visible and can reach quality-control, but it currently requires viewport-aware clicking to produce stable runtime evidence
- Evidence: `http://localhost:4350/#/sample` renders a visible sample-management page with demo case cards after a short render wait.
- Evidence: after scrolling the case list into the viewport and clicking the visible `开始该样品采集` button area, the route changed to `#/quality-control` and the sample context `sample_demo_low` appeared on the QC page.
- Evidence: earlier attempts that clicked before the case button was fully in view or used stale coordinates did not navigate.
- Impact: the sample-entry module is not blocked at business-logic level, but runtime verification is still fragile because the current Flutter web canvas flow depends on precise visible-region clicking in automation.

### Issue 94: The quality-control to I0 verification remains incomplete in the latest restarted runtime because browser automation still cannot produce a stable post-fix click trace
- Evidence: the source file `app/freshsalt_surface/lib/features/quality_control/quality_control_page.dart` now switches the primary action to `_goToBaselineStage` after QC pass.
- Evidence: after restarting the web server, browser automation could reconnect and re-open the sample page, but the subsequent multi-step automated replay did not reproduce a stable `#/quality-control -> #/capture/baseline-stage` route change in one continuous run.
- Evidence: the failure mode in this latest pass was not a console exception or visible crash; instead the automation remained on the sample page or lacked semantic locator support beyond the `Enable accessibility` overlay.
- Impact: the code-level blocker has been fixed, but runtime proof that the repaired button now advances to I0 is still not fully established. This remains an open verification gap rather than a confirmed new logic regression.

### Issue 95: The homepage still contains visible mojibake after restart, which means the platform shell remains readable only in structure, not in clean final text quality
- Evidence: in the latest live homepage screenshot after restart, multiple Chinese labels render as garbled squares/ mojibake while some English identifiers remain readable.
- Evidence: the sample page renders clean Chinese text at the same runtime, so the issue is not a global browser font failure.
- Impact: the homepage shell is visible and usable in structure, but this remains a high-visibility platform defect that weakens acceptance quality and should not be treated as a finished first-screen result.

### Issue 96: The I0 baseline-stage primary action marks simulated input but still does not advance the capture chain to I1
- Evidence: live browser verification previously reached `http://localhost:4350/#/capture/baseline-stage` from the repaired quality-control flow, but clicking the large `使用模拟 I0` primary button left the route unchanged at `#/capture/baseline-stage`.
- Evidence: `app/freshsalt_surface/lib/features/capture/image_stage_page.dart` currently binds the primary filled button only to `_useBaselineImage` or `_useSaltedImage`, and those methods only call the bundle action plus `setState()`.
- Evidence: actual stage navigation is wired separately in the lower `CaptureStageNavigation` block through `widget.nextAction`, so the high-visibility main action and the true workflow advancement are split apart.
- Root cause: the baseline/salted stage page presents a primary action that looks like the next-step button, but the handler updates readiness state without triggering the next route transition.
- Impact: this is the current top-priority capture-chain blocker. The APP can open and reach I0, but the visible main action still fails to carry the user into the next stage, so the platform remains partially assembled rather than truly usable end-to-end.

### Issue 97: The first I0 primary-button patch still failed in runtime because state advanced but immediate same-handler navigation did not land on the next route
- Evidence: after the first patch, clicking `使用模拟 I0` kept the URL at `http://localhost:4350/#/capture/baseline-stage`, but the page tag changed from `阶段 2` to `阶段 3`.
- Evidence: on the same page, clicking the lower `下一步：I1 待测图` button immediately afterwards did navigate successfully to `http://localhost:4350/#/capture/salted-stage`.
- Evidence: browser console logs showed no app exception for the failed primary-button transition.
- Root cause: the stage controller update is landing, but invoking `widget.nextAction` directly in the same primary-button handler is not producing a reliable route transition in Flutter Web runtime; the navigation needs to be decoupled from the same synchronous state update cycle.
- Impact: the current blocker is narrower than before. The route wiring itself works, but the main visible action still does not complete the user-facing flow until the navigation timing is repaired.

### Issue 98: After the post-frame navigation patch, the primary-button route timing improved, but a hot-reload revisit exposed that the salted-stage route still depends on transient passed-in args for its image context
- Evidence: after reloading the live app while the browser was on `#/capture/salted-stage`, the page reopened with `样品 未绑定` and `图像 待装载`, while the `使用模拟 I1` button and `下一步：ROI 摘要` button were both disabled.
- Evidence: the same DOM snapshot showed that the salted-stage page no longer had the incoming `bundle` or `image_path` context needed to enable the stage.
- Impact: the main route can exist without being truly usable after reload or direct revisit. This is a separate runtime-context weakness that should remain documented even if the forward click chain works in one continuous session.

### Issue 99: The first salted-stage route-recovery patch regressed direct route opening into a white-screen runtime failure after web-server restart
- Evidence: after restarting `flutter run -d web-server --web-port 4350`, directly opening `http://localhost:4350/#/capture/salted-stage` rendered a blank white page in the browser instead of the previous degraded-but-visible I1 stage shell.
- Evidence: browser console capture still showed only the prior `dart:developer registerExtension()` warning and did not surface a useful app exception in the in-app browser log feed.
- Evidence: before the restart, the same route at least rendered the I1 shell with `样品未绑定 / 图像待装载`; after the route-recovery patch plus restart, it no longer rendered the shell at all.
- Impact: the current highest-priority blocker has escalated from missing stage context to a route-level rendering regression on direct salted-stage open. This must be diagnosed before claiming the stage-recovery patch improved the platform.

### Issue 100: Earlier salted-stage validation was confounded by multiple competing web-server attempts, but the white-screen regression still reproduces on a clean single-server run
- Evidence: one background Flutter launch failed with `SocketException ... port = 4350` because another process already held the port, so part of the earlier browser behavior could have been reading from the wrong server lifecycle.
- Evidence: after stopping competing Dart processes, starting one clean `flutter run -d web-server --web-port 4350`, confirming `LISTENING` on `4350`, and reopening `#/capture/salted-stage`, the page still rendered as a blank white screen.
- Impact: the current salted-stage regression is a real app/runtime issue on the active codepath, not just a stale-server or multi-process verification artifact.

### Issue 101: The salted-stage "white screen" conclusion was too strong; direct route recovery works, but initial rendering can be slow enough to look blank in short checks
- Evidence: after a longer wait on the same clean single-server run, direct opening of `http://localhost:4350/#/capture/salted-stage` rendered a usable I1 stage with `sample_demo_medium` and `/mock/salted_medium.png` instead of remaining blank.
- Evidence: the earlier blank captures came from shorter checks that returned empty DOM snapshots and white screenshots before the stage content settled.
- Impact: the direct-route repair is partially effective. The more accurate current defect is not a persistent white screen, but slow initial rendering plus unstable short-horizon verification, so follow-up work should continue on real interaction flow (`I1 -> ROI`) rather than treating salted-stage as fully dead.

### Issue 102: The saved-prediction page exposes two different result-detail actions with the same visible label, creating automation ambiguity and potential user confusion
- Evidence: after saving a prediction on `#/prediction`, the page showed two distinct buttons that both exposed the visible label `查看结果详情`.
- Evidence: a role-based locator by button name matched count `2`, requiring explicit disambiguation before the result-detail route could be opened.
- Evidence: clicking one of those buttons did successfully open `http://localhost:4350/#/result`, so this is not a broken route, but a duplicated-action-label issue.
- Impact: the main chain is now passable through the result page, but the duplicated action label weakens clarity and makes both automation and user flow more fragile than necessary.

### Issue 103: The homepage mojibake is rooted in corrupted source literals inside `home_page.dart`, not just browser rendering noise
- Evidence: `app/freshsalt_surface/lib/features/home/home_page.dart` contains many visibly corrupted Chinese string literals such as section labels, button text, and explanatory copy.
- Evidence: the homepage runtime screenshot shows the same corrupted text patterns, while later-stage pages like ROI, feature preview, prediction, and result detail render readable Chinese content.
- Impact: the homepage text defect is a real source-file content problem. Fixing it will require targeted source-string repair in the home page rather than more runtime or font-level probing.

### Issue 104: The homepage first-screen mojibake has been repaired in runtime, but earlier Playwright role-click validation overstated a main-entry failure that is actually specific to Flutter web semantics interaction
- Evidence: after replacing the corrupted literals in `app/freshsalt_surface/lib/features/home/home_page.dart`, the live homepage at `http://localhost:4350/` now renders readable text such as `首页工作台`, `开始采集预测`, `查看结果图表`, and `打开验证台`.
- Evidence: direct browser verification shows that `查看结果图表` navigates to `#/result` and `打开验证台` navigates to `#/demo-validation`.
- Evidence: a Playwright role-based click on `开始采集预测` left the URL at `/`, but a fresh semantic DOM click on the same visible button node immediately navigated to `#/quality-control` and rendered the quality-control page with `sample_demo_medium`.
- Root cause: the previously observed homepage-CTA failure is not currently proven as app business-logic breakage; the stronger current explanation is browser-automation mismatch on Flutter web semantics for that specific interaction surface.
- Impact: the homepage platform shell is now readable and the main entry is runtime-reachable, but homepage CTA verification remains tool-sensitive and should be treated as a browser-automation fragility, not as a confirmed platform-chain regression.

### Issue 105: The homepage module-entry grid is browser-visible and route-usable, but it is not fully exposed in the current Flutter web semantics tree, which makes automation coverage partial unless the page is scrolled and clicked by visible text
- Evidence: on the live homepage, the visible DOM semantics snapshot initially exposes only the three top CTA buttons and the bottom navigation labels, not module-grid labels such as `样品管理`, `分析总览`, `报告页`, or `设置`.
- Evidence: after scrolling the homepage down, text-based browser clicks can still open the module routes successfully, including `#/sample`, `#/history`, `#/report`, `#/analysis`, and `#/settings`.
- Root cause: the module grid exists and is usable in runtime, but the current Flutter web semantics export does not provide stable first-screen semantic nodes for all grid entries.
- Impact: this is not a confirmed platform-navigation failure, but it is a real verification fragility. Browser automation cannot treat the homepage grid as fully semantics-addressable yet, so module-entry regression coverage remains less stable than the visible platform result suggests.

### Issue 106: Some Flutter web module pages still return empty DOM snapshots during short waits after route open, even when the page later renders correctly
- Evidence: directly after opening `#/sample`, the first DOM snapshot returned an empty string while the URL was already correct.
- Evidence: after an additional wait of roughly 4 to 5 seconds on the same route, the sample page rendered normally with readable content and actionable sample buttons.
- Root cause: route content settlement in the current Flutter web runtime can lag behind the first DOM snapshot on some module pages.
- Impact: short-horizon verification can overstate page failure or blank-screen regressions. Page-open checks on these routes should include a longer settle window before concluding that a page is empty or broken.

### Issue 107: The sample module uses repeated visible action labels across multiple case cards, so browser automation must disambiguate which sample entry button to click
- Evidence: on the live `#/sample` page, the locator for `开始该样品采集` resolves to multiple buttons because each sample card uses the same visible CTA label.
- Evidence: after explicitly selecting the first matching button, the route advanced successfully to `#/quality-control` with `sample_demo_low`.
- Root cause: the repeated CTA label is a UI clarity tradeoff that is acceptable for users in-card context, but it is not unique enough for automation without card-level scoping.
- Impact: this is not a main-chain business blocker, but it is a real interaction-coverage fragility. Automation and future regression scripts must scope these buttons by card or known position instead of assuming a unique global label.

### Issue 108: The remaining homepage high-visibility module pages were not broken route targets; their visible defects were primarily source-level mojibake in `model_bundle_page.dart` and `hardware_config_page.dart`
- Evidence: before repair, both `app/freshsalt_surface/lib/features/model_bundle/model_bundle_page.dart` and `app/freshsalt_surface/lib/features/hardware/hardware_config_page.dart` contained visibly corrupted Chinese literals across their headings, summaries, and button labels.
- Evidence: after targeted source repair, homepage entry clicks now open `#/model-bundle` and `#/hardware-config` successfully, and both pages render readable Chinese content with working visible controls.
- Impact: the remaining high-visibility homepage coverage gap has been closed at runtime. The issue was page text integrity rather than route-level failure, but leaving these literals corrupted would have weakened platform acceptance and masked true interaction status.

## Current APP Issue Summary

### Issue 109: The capture entry previously exposed a fake "import image" surface that never connected real user images into the workflow
- Evidence: `app/freshsalt_surface/lib/features/capture/capture_page.dart` previously wired the `导入图片 PNG / JPG` entry to open the baseline stage route rather than any real file-import action.
- Evidence: `app/freshsalt_surface/pubspec.yaml` still contains no `image_picker`, `file_picker`, or equivalent import dependency.
- Impact: the visible import entry was a shell module, not a real image-ingestion path. The user's complaint is valid.

### Issue 110: The capture workflow previously auto-consumed demo sample metadata even after image-stage interaction, which means the app could present mock-driven continuation as if it were meaningful capture progress
- Evidence: `app/freshsalt_surface/lib/features/capture/capture_page.dart` ran quality control, feature extraction, and prediction from `selectedCase.imageMetadata`.
- Evidence: `app/freshsalt_surface/lib/core/services/quality_control_service.dart` and `app/freshsalt_surface/lib/core/services/feature_extraction_service.dart` still operate entirely on metadata maps rather than decoded image pixels.
- Impact: before this turn's guardrail patch, even a user-facing "import" action could still lead the app back onto the demo metadata path, which is exactly the misleading behavior the user called out.

### Issue 111: Real-image processing is still not implemented; current repair only stops the app from silently falling back to mock after a claimed real import
- Evidence: this turn added non-simulated source tracking in `app/freshsalt_surface/lib/core/models/capture_workflow_controller.dart`.
- Evidence: this turn added explicit real-image import entry points on the capture stage page, plus hard-stop guardrails in `app/freshsalt_surface/lib/features/capture/capture_page.dart` when real images are present but pixel-level QC / feature extraction is not implemented.
- Impact: the app is now more honest and less misleading, but real acquisition is still incomplete. The current state is "real import entry and mock-fallback guardrails exist" rather than "real image pipeline is finished."

### Issue 112: The first real-image repair pass could not reach the running app because the newly added real-image service was wired incompletely, leaving the live localhost page on older behavior
- Evidence: `flutter analyze` on 2026-06-26 first failed in `app/freshsalt_surface/lib/core/demo/demo_app_scope.dart` with constructor wiring errors around `realImageAnalysisService`.
- Evidence: the in-app browser at `http://localhost:4350/` was still showing the homepage shell rather than the updated capture-stage behavior before recompilation.
- Impact: until the constructor wiring errors were removed, the browser-visible app could not reflect the new real import / pixel-analysis code, so any runtime claim before recompilation would have been false.

### Issue 113: Real-image prediction is still intentionally blocked because the downstream prediction module remains simulation-only
- Evidence: `app/freshsalt_surface/lib/features/capture/capture_page.dart` now allows real file picking and pixel-level QC / feature extraction, but still blocks `runPredictionWorkflow` for real images with an explicit stop message.
- Evidence: `app/freshsalt_surface/lib/core/orchestrator/freshsalt_app_orchestrator.dart` still executes prediction only from demo metadata and simulated model flow.
- Impact: the app now has a partial real-image chain, but it still cannot honestly produce a real-image final prediction result.

### Issue 114: The first real file-picker integration still failed on Flutter Web because it incorrectly treated `PlatformFile.path` as mandatory
- Evidence: before this turn's fix, `app/freshsalt_surface/lib/features/capture/capture_page.dart` rejected import when `file.path == null`, even though Flutter Web commonly only guarantees `bytes` and `name`.
- Evidence: the import path has now been changed to prefer `file.path` when present and otherwise fall back to `file.name`, while still requiring real bytes.
- Impact: before this fix, the browser-visible "导入图片" action could still fail in the exact local web runtime the user was testing, despite the file picker being nominally connected.

### Issue 115: The first workspace-real-sample verification attempt failed because the test referenced a non-existent baseline filename, so the failure was in test evidence wiring rather than the real-image pipeline itself
- Evidence: the initial test tried to read `原始数据-光栅/对照-0.png`, but the actual workspace file present is `原始数据-光栅/-对照-0.png`.
- Evidence: after correcting the test path to a real existing sample pair, the real-sample QC/feature-extraction test passed.
- Impact: without this correction, the audit could wrongly treat a path mistake as evidence that the real-image pipeline itself was broken.

### Issue 116: The earlier stage pages had enough encoding corruption that incremental browser-facing proof work became fragile, so the three capture-stage pages were rewritten to restore stable visible acceptance for the real-image chain
- Evidence: `app/freshsalt_surface/lib/features/quality_control/quality_control_page.dart`, `app/freshsalt_surface/lib/features/feature_preview/feature_preview_page.dart`, and `app/freshsalt_surface/lib/features/capture/image_stage_page.dart` were rewritten in this turn instead of incrementally patched.
- Evidence: the rewritten pages now expose explicit real-image source markers and metadata sections such as `real_image_pixels`, `source`, `Real Image Input`, and `Extraction Metadata`.
- Impact: this reduces the risk that the real file-import / QC / feature-extraction path remains technically present but visually indistinguishable from the old mock path during user-side runtime testing.

### Issue 117: The earlier "current app is white-screen blocked" conclusion was too strong for the active localhost runtime and was partially caused by stale browser-session evidence
- Evidence: fresh direct inspection of the active in-app browser tab at `http://localhost:4350/#/capture/salted-stage` shows a mounted Flutter view with `flt-glass-pane`, `flt-semantics-host`, and readable semantics text including `I1 待测图`, `模拟数据`, `使用模拟 I1`, and `导入真实 I1 PNG / JPG`.
- Evidence: a new runtime screenshot from the same active tab shows the stage page rendered normally rather than blank.
- Evidence: the earlier white screenshot and `require.js / web_entrypoint.dart` error came from an older browser tab/session state and must not be treated as authoritative for the current active runtime.
- Impact: the current top blocker is not "the app cannot render at all". The stronger current problem statement is: the app can render and be manually tested, but real-image import and real acquisition behavior still need route-by-route runtime validation.

### Issue 118: Browser-session instability can still create false negative runtime judgments if old in-app tabs are reused without revalidation
- Evidence: one claimed localhost tab continued to surface the old `require.js` script error and blank screenshot, while a fresh active session tab on the same `4350` app route rendered the correct Flutter semantics tree and visible stage UI.
- Evidence: the browser plugin session had transient tab-claim inconsistencies (`openTabs()` empty while `tabs.list()` still contained the active localhost tab), which increased the chance of reading stale state.
- Impact: runtime verification for this project must prefer fresh active-tab inspection and current semantics/screenshot evidence over stale tab history. Otherwise, platform status can be mis-ranked and time can be wasted fixing a blocker that is no longer active.

### Issue 119: The visible `导入真实 I1 PNG / JPG` control is still disabled on the direct salted-stage route because that route is rendering with degraded stage context rather than the full capture bundle
- Evidence: the active `http://localhost:4350/#/capture/salted-stage` page is visibly rendered, but Flutter semantics inspection shows the real-import control as `<flt-semantics aria-disabled="true" role="button">导入真实 I1 PNG / JPG</flt-semantics>`.
- Evidence: the same page text also lacks the richer stage-context signals expected from the full bundle path, such as the sample id chip, and instead behaves like a minimal stage shell.
- Evidence: source inspection confirms that real import callbacks now exist in `app/freshsalt_surface/lib/core/demo/demo_capture_bundle_factory.dart`, but the direct stage route still does not surface them in the live browser page.
- Impact: the user's complaint remains valid for the currently opened direct I1 page. The real file-import capability now exists in code, but the visible direct salted-stage route is still not receiving enough capture context to expose that capability as an enabled control.

### Issue 120: The disabled real-import judgment was accurate for one stale localhost tab but not for a fresh clean runtime tab after the web-server restart
- Evidence: after restarting the `4350` Flutter web-server and opening a brand-new in-app browser tab to `http://localhost:4350/#/capture/salted-stage`, the page rendered with full stage context (`sample_demo_medium`, stage metrics, and stage summary) and the semantics export showed `导入真实 I1 PNG / JPG` as a normal button node without `aria-disabled`.
- Evidence: clicking that button through Flutter semantics did not change the page text, but this does not prove failure because file-picker dialogs are OS-native and do not necessarily mutate the Flutter DOM/semantics tree.
- Impact: the stronger current statement is that the real-import entry is now runtime-enabled on a clean tab. The remaining verification gap is confirming native file-picker behavior and the subsequent real-image state transition, not re-proving button enablement.

### Issue 121: The stage page previously had a real runtime-visibility gap after import because the async import callback did not trigger a local rebuild
- Evidence: in `app/freshsalt_surface/lib/features/capture/image_stage_page.dart`, the simulated-image path (`_useBaselineImage` / `_useSaltedImage`) already called `setState()`, but the real import button previously delegated directly to `widget.bundle?.importBaselineImage` / `importSaltedImage` with no local rebuild step.
- Evidence: this meant that even if the file picker callback updated controller state successfully, the visible stage shell could remain in the old simulated appearance until some unrelated rebuild happened later.
- Resolution: the stage page now routes real import through local async handlers that await the import callback and then call `setState()` so the page can immediately reflect `real_image_file`, the real path, and real source markers after file selection completes.
- Impact: this closes a concrete visibility hole in the real-image chain. The remaining gap is not page refresh after callback anymore; it is proving native file selection completion end to end in live browser use.

### Issue 122: A dedicated widget proof now confirms the post-import page-state transition for the salted-stage shell
- Evidence: `app/freshsalt_surface/test/image_stage_real_import_test.dart` now verifies that after the salted-stage import callback writes a real image path and marks the source as non-simulated, the page rebuilds and visibly exposes both `real_image_file` and `user://salted_real.png`.
- Evidence: the test passes in the current workspace, which proves the stage-shell visibility transition no longer depends on some unrelated later rebuild.
- Impact: one important unknown has been removed. The remaining runtime gap is narrowed to native file-picker completion in live browser use, not whether the page knows how to present the imported real-image state after callback success.

### Issue 123: The post-import business path is now proven to use real pixel services for QC and feature extraction in the demo capture bundle
- Evidence: `app/freshsalt_surface/test/demo_capture_bundle_real_flow_test.dart` now passes two focused tests showing that once real baseline/salted bytes are present on the controller, `buildDemoCaptureBundle(scope).runQualityControl()` writes `source_mode == real_image_pixels`, and `runFeatureExtraction()` writes `metadata['extraction_method'] == real_image_pixels`.
- Evidence: this directly exercises `app/freshsalt_surface/lib/core/demo/demo_capture_bundle_factory.dart`, which is the route-level bundle factory used to supply the capture-stage workflow.
- Impact: the remaining honest gap is no longer whether the app silently falls back from imported real images to demo metadata for QC/feature extraction. That fallback risk is now substantially reduced by direct automated evidence. The main unresolved scope is still native picker completion in live browser use and the intentionally blocked real-image final prediction step.

### Issue 124: A failed QC pass previously erased the imported real-image state, making the app appear to lose the selected file and regress toward the simulated shell
- Evidence: direct debug execution showed `hasImportedRealImages == true` before `runQualityControl()`, but after a failed QC result the controller reset `baselineImagePath`, `saltedImagePath`, image bytes, and simulated-source flags back to null/true.
- Root cause: `app/freshsalt_surface/lib/core/models/capture_workflow_controller.dart` cleared imported image paths, bytes, and source flags inside `applyQualityControl()` whenever `result.isPassed == false`.
- Resolution: failed QC now clears downstream prediction/ROI outputs only, while preserving the imported real-image state itself.
- Evidence after fix: `test/demo_capture_bundle_real_flow_test.dart` now passes `failed QC does not erase imported real image state`, proving a failed QC result no longer wipes the selected real files from controller state.
- Impact: this removes a major source of user-facing deception and confusion. A real image can now fail QC honestly without making it look as though the import never happened.

### Issue 125: The staged I0/I1 pages could still feel like shell pages after a successful real import because the async import callback did not advance the visible workflow
- Evidence: in `app/freshsalt_surface/lib/features/capture/image_stage_page.dart`, `_importBaselineImage()` and `_importSaltedImage()` previously awaited the bundle callback and only called `setState()`, unlike the simulated-image path which already coupled state change with next-step progression.
- Evidence: the running route under `#/capture/salted-stage` was therefore able to accept a real import callback yet leave the user stranded on the same stage shell with no immediate forward movement, matching the user's “空壳” complaint at interaction level.
- Resolution: both real import handlers now verify stage readiness after the callback and schedule `widget.nextAction?.call()` on the next frame, so a successful import immediately advances from I0 to I1 or from I1 to ROI.
- Evidence after fix: `flutter test test/image_stage_real_import_test.dart` still passes, and the page-level import handlers now contain explicit post-import progression logic in the current workspace source.
- Impact: this closes a visible workflow gap in the real-image chain. The remaining honest gap is not “import finishes but the stage still behaves like a dead shell”; it is the broader unfinished native camera path and the intentionally blocked real-image final prediction.

### Issue 126: The Flutter Web real-import path remained too opaque to verify reliably because `file_picker` did not expose a browser-observable file-input layer in the running localhost page
- Evidence: on the live `http://localhost:4350/#/capture/salted-stage` page, the `导入真实 I1 PNG / JPG` button was present and enabled, but a direct DOM probe before and after interaction found no `input[type=file]` node in the page.
- Evidence: this made browser-side proof of file-picker hookup much weaker than it should be; the runtime behavior depended on plugin-internal bridging that was difficult to observe or inject from the browser layer.
- Resolution in progress: the real-image import path has been refactored to use a dedicated local picker service, with Flutter Web routed through an explicit browser-native `FileUploadInputElement` implementation (`local_image_picker_web.dart`) while desktop platforms continue to use `file_picker`.
- Evidence after code change: the new picker abstraction is present under `app/freshsalt_surface/lib/core/services/local_image_picker*.dart`, and the import chain still passes the focused stage and bundle tests (`image_stage_real_import_test.dart`, `demo_capture_bundle_real_flow_test.dart`).
- Remaining gap: browser-runtime proof after the picker refactor still needs to be re-collected because the in-app browser automation session timed out during the final DOM re-check.

### Issue 127: The remaining blocker is now runtime-side proof instability on the Flutter Web localhost page, not missing real-image logic
- Evidence: after the picker refactor, `flutter analyze` returns clean for the full app, and the targeted tests for stage refresh, bundle real-flow routing, and workspace real-sample QC/feature extraction all pass.
- Evidence: source inspection now proves the four requested segments exist together in the current codebase:
  - Web-native file input creation in `local_image_picker_web.dart`
  - Real image byte decode and pixel QC in `real_image_analysis_service.dart`
  - Real feature extraction branch usage in both `capture_page.dart` and `demo_capture_bundle_factory.dart`
- Evidence: the remaining failed evidence collection attempts were runtime-browser interaction failures such as webview attach timeouts, selector click timeouts, or inability to observe the final native input behavior from browser automation on the Flutter Web page.
- Impact: the project is no longer blocked by absent implementation of the four requested code paths. It is blocked by the last-mile runtime proof on the live localhost page, which is weaker and less stable than the underlying implementation evidence.

### A. Proven fixed and revalidated
- Homepage shell text corruption in `app/freshsalt_surface/lib/features/home/home_page.dart`
  - Runtime behavior: homepage now renders readable Chinese first-screen content.
  - Trigger: open `http://localhost:4350/`.
  - Scope: homepage shell.
  - Main-chain impact: yes, previously weakened platform readability.
  - Status: fixed and runtime-revalidated.

- Saved prediction page duplicate `查看结果详情` actions in `app/freshsalt_surface/lib/features/prediction/prediction_page.dart`
  - Runtime behavior: saved state now exposes one `查看结果详情` button and one `下一步：结果页` button.
  - Trigger: run prediction and save on `#/prediction`.
  - Scope: saved prediction stage.
  - Main-chain impact: medium; route worked before, but UI ambiguity affected acceptance and automation.
  - Status: fixed and runtime-revalidated.

- Main chain assembly from sample to result
  - Runtime behavior: `#/sample -> #/quality-control -> #/capture/baseline-stage -> #/capture/salted-stage -> #/roi -> #/feature-preview -> #/prediction -> #/result` now runs end to end in browser verification.
  - Trigger: start from sample selection and follow stage actions.
  - Scope: platform core flow.
  - Main-chain impact: critical.
  - Status: fixed/revalidated at full-chain level.

- Homepage high-visibility module entry pages
  - Runtime behavior: homepage entries now open `#/sample`, `#/model-bundle`, `#/hardware-config`, `#/history`, `#/analysis`, `#/report`, `#/settings`, and `#/demo-validation`.
  - Trigger: click homepage visible module entries.
  - Scope: homepage visible platform modules.
  - Main-chain impact: medium; these are platform shell acceptance surfaces.
  - Status: runtime-revalidated.

### B. Still present, but not currently proven as business-logic breakage
- Homepage CTA automation fragility
  - File/module: homepage entry interaction on Flutter web semantics.
  - Runtime behavior: role-based automation click on `开始采集预测` may leave URL at `/`, while fresh semantics DOM click can enter `#/quality-control`.
  - Trigger: Playwright role click on homepage CTA.
  - Scope: browser automation coverage, not user-visible business logic.
  - Main-chain impact: low to medium for verification, not currently proven to block users.
  - Status: not fixed as an automation-stability issue.

- Homepage module grid semantics exposure is incomplete
  - File/module: homepage module grid on Flutter web.
  - Runtime behavior: first-screen semantics snapshot exposes top CTAs and bottom nav, but not all grid items; scrolling and text-clicking still works.
  - Trigger: semantics-based automation on homepage without scrolling.
  - Scope: homepage automation coverage.
  - Main-chain impact: low.
  - Status: still present.

- Short-wait empty DOM snapshots on some routes
  - File/module: Flutter web route settlement, notably `#/sample`.
  - Runtime behavior: early DOM snapshot may be empty even when the page later renders correctly after longer waits.
  - Trigger: route open followed by short-horizon DOM capture.
  - Scope: verification reliability.
  - Main-chain impact: low for users, medium for automated verification.
  - Status: still present.

- Repeated sample-card CTA labels
  - File/module: `app/freshsalt_surface/lib/features/sample/sample_page.dart`
  - Runtime behavior: multiple `开始该样品采集` buttons require scoped or positional automation targeting.
  - Trigger: global locator by button name on sample list.
  - Scope: sample page automation.
  - Main-chain impact: low for users, medium for regression automation.
  - Status: still present.

### C. Residual cleanup risk not fully rescanned
- Low-visibility mojibake outside already repaired high-visibility routes
  - File/module: unscanned secondary pages or strings outside the repaired homepage, sample, model-bundle, hardware-config, quality-control, capture-stage, and prediction/result-facing surfaces.
  - Runtime behavior: not fully rescanned in this pass.
  - Trigger: open lower-priority or less frequently visited pages.
  - Scope: polish/acceptance quality.
  - Main-chain impact: currently unknown, but not evidenced as a core-flow blocker.
  - Status: unverified residual risk.

## 2026-06-27 Additional Real-Import Runtime Defect

- Web native picker could hang the import flow when the user cancels selection
  - File/module: `app/freshsalt_surface/lib/core/services/local_image_picker_web.dart`
  - Runtime behavior: after clicking `导入真实 I0/I1 PNG / JPG`, cancelling the browser-native file dialog could leave the pending Future unresolved, making the import button feel like a fake shell with no return path.
  - Trigger: user opens the native file chooser and closes it without selecting a file.
  - Scope: real local image import on Flutter Web.
  - Main-chain impact: medium to high, because it directly undermines trust in the real import entry and can be mistaken for a dead mock button.
  - Status: fixed by adding explicit cancel completion via focus-return detection and stale-input cleanup; still needs continued live runtime observation on user-side manual testing.

- Direct `#/capture/salted-stage` runtime still shows unstable import-entry wiring evidence
  - File/module: `app/freshsalt_surface/lib/routing/app_router.dart`, `app/freshsalt_surface/lib/features/capture/image_stage_page.dart`, Flutter web route bootstrap/runtime semantics.
  - Runtime behavior: after a fresh localhost restart, the same `导入真实 I1 PNG / JPG` entry can alternate between visible-enabled and semantics-disabled evidence across repeated live checks; in some passes Playwright click times out, while in others the button is visible but no `freshsaltPickerState` marker is emitted.
  - Trigger: opening the direct salted-stage route (`http://localhost:4350/#/capture/salted-stage`) instead of progressing through the full capture flow.
  - Scope: direct-route real import verification on Flutter Web.
  - Main-chain impact: high for runtime proof, medium for end-user trust, because the real import chain exists in code but the direct verification surface is still unstable enough to look like a shell.
  - Status: not yet resolved; current evidence points to route/bootstrap-context instability or Flutter-web semantics inconsistency rather than a missing real-image decode/QC/feature implementation.

## 2026-06-27 Runtime Correction Note

- Full `/capture` flow has now produced positive native-picker evidence for both real I0 and real I1 import entries
  - Runtime evidence: clicking `导入真实 I0 PNG / JPG` and `导入真实 I1 PNG / JPG` from `http://localhost:4350/#/capture` sets `document.body.dataset.freshsaltPickerState` to `clicked`, leaves `#freshsalt-local-image-picker` mounted, and exposes browser-native chooser UI evidence (`Choose File`) in the live Flutter-web snapshot.
  - Meaning: the main capture entry is no longer an empty shell; the real local file-picker bridge is actually wired on the full capture page.
  - Remaining gap: this does not yet prove a completed user file selection all the way through to visible `real_image_file` / downstream `real_image_pixels` state in the live browser runtime, because the native chooser still needs an actual selected file to continue.

- Full capture page previously gave no explicit user feedback when a real import was cancelled
  - File/module: `app/freshsalt_surface/lib/features/capture/capture_page.dart`
  - Runtime behavior: even after the picker-cancel Future bug was fixed, the full `/capture` page could still look unresponsive to a user who opened the native chooser and then cancelled, because the page returned silently without an on-page explanation.
  - Trigger: open `导入真实 I0/I1 PNG / JPG` from `#/capture`, then cancel the chooser.
  - Scope: main capture entry user trust / interaction honesty.
  - Main-chain impact: medium, because it can still be mistaken for a fake or broken button even though the native picker is actually wired.
  - Status: fixed by surfacing an explicit cancellation message (`未选择文件，本次真实图片导入已取消。`) when no file is selected.
## 2026-06-27 Runtime Evidence Patch Follow-up

- Main capture page now exposes explicit runtime evidence fields for the real-image path
  - File/module: `app/freshsalt_surface/lib/features/capture/capture_page.dart`, `app/freshsalt_surface/lib/core/services/local_image_picker*.dart`
  - Runtime-visible fields added: `picker_state`, `I0_source`, `I1_source`, `qc_source_mode`, `feature_extraction`.
  - Purpose: reduce the remaining “shell/fake button” ambiguity by making file-picker state, imported-file source mode, QC source mode, and feature-extraction source explicit on the main `#/capture` page.
  - Status: implemented in source and static analysis now passes.

- Focused static verification passed after the runtime-evidence patch
  - Command: `flutter analyze lib/features/capture/capture_page.dart lib/core/services/local_image_picker.dart lib/core/services/local_image_picker_web.dart lib/core/services/local_image_picker_io.dart lib/core/services/local_image_picker_stub.dart`
  - Result: passed with `No issues found!`.
  - Meaning: the new visible evidence layer compiles cleanly and does not break the patched picker abstraction.

- One focused widget regression test is now stale against repaired visible button copy, not against business logic
  - File/module: `app/freshsalt_surface/test/app_flow_test.dart`
  - Runtime/test behavior: the test `salted stage refreshes into real image state after import callback` still searches for an old mojibake button label instead of the now-correct visible text `导入真实 I1 PNG / JPG`.
  - Impact: this is a test-fixture drift caused by visible text repair, not evidence that the real import business path regressed.
  - Status: still needs a small test assertion update.

- Live in-app browser readback became unstable immediately after the localhost restart
  - Runtime behavior: after restarting the Flutter web-server on port `4350`, fresh in-app browser tabs to `http://localhost:4350/#/capture` intermittently returned empty text snapshots even though the server itself came back healthy.
  - Impact: this weakens automated browser-side proof for the newly added evidence card, so the current strongest proof is source + static analysis rather than a fresh post-restart browser text dump.
  - Status: unresolved browser-session instability; does not currently contradict the implemented runtime-evidence patch itself.
- Focused regression evidence for the real-image chain is now restored after test-selector cleanup
  - File/module: `app/freshsalt_surface/test/app_flow_test.dart`
  - Repair: stale mojibake-based widget selectors were updated to the current visible Chinese UI copy (`进入当前阶段`, `使用模拟 I0/I1`, `确认 ROI`, `提取特征`, `结果计算`, `导入真实 I0 PNG / JPG`, `保存`).
  - Verification: `flutter test test/app_flow_test.dart test/image_stage_real_import_test.dart test/demo_capture_bundle_real_flow_test.dart` now passes completely, re-proving the visible capture chain plus the real import marker, real QC metric, and real feature-extraction metadata checks.

- Fresh in-app browser localhost readback is still too weak to serve as the final proof artifact for the new Runtime Evidence card
  - Runtime behavior: after creating a brand-new in-app browser tab to `http://localhost:4350/#/capture`, `document.body.innerText` still returned an empty string even though the server itself was healthy and the source/test evidence had already been updated.
  - Impact: this remains a browser-session/runtime-readback instability, not a direct contradiction of the implemented real-image runtime evidence layer.
  - Status: unresolved; current strongest completion evidence remains source + focused passing tests rather than a fresh browser text dump.

## 2026-06-27 Direct Browser Click Audit

- Real local-image import on the main `#/capture` page still fails at the live decode stage for an actual workspace PNG
  - File/module: `app/freshsalt_surface/lib/core/services/local_image_picker_web.dart`, route `http://localhost:4350/#/capture`
  - Runtime behavior: direct browser clicking on `导入真实 I0 PNG / JPG` moves `picker_state` from `idle` to `clicked`, creates `#freshsalt-local-image-picker`, and proves the button is not an empty shell at the browser-bridge layer.
  - Runtime behavior: after selecting the real file `F:\1.大学物理竞赛\原始数据-光栅\-对照-0.png`, the page updates to `picker_state = decode_failed`, while `I0_source` stays `not_selected`.
  - Meaning: the current top defect is narrower and more concrete than “button has no response”: the native picker bridge responds, but the selected real file is rejected before app state accepts it as a usable imported image.
  - Status: reproduced directly in a live Playwright browser session on 2026-06-27; not yet resolved in runtime.

- Restarting the localhost Flutter web-server can temporarily strip the Flutter semantics tree from open verification pages
  - File/module: live Flutter web bootstrap on `http://localhost:4350/#/capture`
  - Runtime behavior: after restarting the web-server on port `4350`, both the already-open capture page and a newly opened verification page could report empty `body.innerText`, no `flutter-view`, and zero `flt-semantics` nodes during the next verification pass.
  - Impact: this introduces a second independent verification instability and can hide whether a just-applied code fix changed runtime behavior.
  - Status: reproduced on 2026-06-27; treat as browser/runtime-readback instability, separate from the real-file decode failure itself.

## 2026-06-27 Additional Capture Page Runtime Audit

- Main `#/capture` page still does not provide stable browser-visible proof for the lower half of the platform shell
  - File/module: `app/freshsalt_surface/lib/features/capture/capture_page.dart`
  - Runtime behavior: a fresh in-app browser audit on `http://localhost:4350/#/capture` showed only the upper capture sections (`当前样品`, `图像状态`, `Runtime Evidence`, `真实导入`) in the visible DOM/text snapshot, while the source code also defines later sections for `演示入口`, `主链路`, `阶段路由`, and `样品切换`.
  - Impact: this is a high-visibility platform defect because the page can look like it stops halfway through, making the capture workbench appear incomplete or shell-like even when lower-stage actions exist in source.
  - Status: reproduced on 2026-06-27 by direct in-app browser inspection; root cause still under investigation.

- Direct click on `导入真实 I0 PNG / JPG` now proves a live native picker bridge, but not a completed import-to-usable-image loop
  - File/module: `app/freshsalt_surface/lib/features/capture/capture_page.dart`, `app/freshsalt_surface/lib/core/services/local_image_picker_web.dart`
  - Runtime behavior: clicking the I0 import button from `#/capture` produced browser-native chooser evidence (`Choose File`) and changed the page state from the idle shell to a chooser-mounted state, which proves the button is not a dead mock at the first interaction boundary.
  - Remaining gap: this direct audit did not yet prove that an actually selected file becomes visible as `real_image_file` / imported I0 state on the same page.
  - Impact: user trust is still not restored, because the button now has a first response but the full visible import-success loop is still unproven in this runtime pass.
  - Status: partially reproduced and partially unresolved on 2026-06-27.

## 2026-06-27 AI+ Result Page Upgrade

- The result page previously behaved more like a numeric report than an AI-assisted experimental judgment surface
  - File/module: `app/freshsalt_surface/lib/features/result/result_page.dart`
  - Prior behavior: the page already showed the predicted value, range, trend, model-input summary, and warnings, but it did not consolidate those signals into a user-facing AI judgment layer.
  - User-facing impact: the page could still read like a calculator or dashboard instead of an `AI+` assistant, because users had to infer confidence, high/low reasons, and retake suggestions by themselves.
  - Status before fix: confirmed in source on 2026-06-27.

- Result page now includes an explicit `AI 解释卡` built from existing prediction signals
  - File/module: `app/freshsalt_surface/lib/features/result/result_page.dart`
  - New visible outputs:
    - `可信度`
    - `关键影响因子`
    - `本次结果为何偏高/偏低`
    - `是否建议重拍或补采`
  - Data source: existing `PredictionResult` fields (`confidenceLevel`, `resultStatus`, `warnings`, `predictedValue`, `validRange*`, `featureVector`) plus current model coefficients when available.
  - Meaning: the result page now presents AI-style assisted interpretation without waiting for a new backend model interface.
  - Verification: focused `flutter analyze lib/features/result/result_page.dart` passed on 2026-06-27.

- Fresh in-app browser tabs to `#/result` remain unstable even after the AI result-card upgrade
  - File/module: live Flutter web runtime on `http://localhost:4350/#/result`
  - Runtime behavior: a focused widget test now proves the `AI 解释卡` is rendered in the result page widget tree, but a brand-new in-app browser tab still produced a white page instead of a trustworthy visual confirmation artifact.
  - Meaning: the AI explanation layer is now proven at source + widget-render level, but browser-visible runtime proof is still weakened by the same localhost / in-app-browser instability seen elsewhere in this thread.
  - Status: unresolved runtime verification instability on 2026-06-27; does not currently contradict the passing widget-level evidence.

## 2026-06-27 Capture Import Recheck

- Main `#/capture` page is no longer stuck in the previous blank/empty-readback state
  - File/module: live Flutter web runtime on `http://localhost:4350/#/capture`
  - Runtime behavior: after a fresh reload and a longer wait window, the page rendered stable readable capture text again, including `进入当前阶段：成像质控`, `导入真实 I0`, `导入真实 I1`, and the runtime evidence block.
  - Meaning: the earlier blank-page / empty-body proof is not the dominant blocker on this route at the moment.
  - Status: revalidated on 2026-06-27.

- Direct live click on `导入真实 I0` from the main `#/capture` page still failed to transition the runtime evidence into picker-open state
  - File/module: `app/freshsalt_surface/lib/features/capture/capture_page.dart`, `app/freshsalt_surface/lib/core/services/local_image_picker.dart`, `app/freshsalt_surface/lib/core/services/local_image_picker_web.dart`
  - Runtime behavior: after a browser-driven click on `导入真实 I0`, the visible capture page still reported `picker_state idle`, `I0_source not_selected`, and no `#freshsalt-local-image-picker` marker was observed in the immediate post-click check.
  - Meaning: there is at least one remaining live interaction-layer defect beyond the earlier post-selection `decode_failed` path. In this pass, the import click itself did not produce the expected `clicked/opening/created` evidence.
  - Status: reproduced on 2026-06-27 after the latest localhost reload; root cause still under investigation.

- Capture-page semantics exposure for real import entries has now been repaired, but native picker triggering still does not advance
  - File/module: `app/freshsalt_surface/lib/features/capture/capture_page.dart`, route `http://localhost:4350/#/capture`
  - Runtime behavior: after promoting the real import entry to a dedicated first-screen section, both `导入真实 I0` and `导入真实 I1` now appear in the live DOM snapshot and in the Flutter semantics layer (`flt-semantics`).
  - Runtime behavior: a follow-up live click on `导入真实 I0` still left `picker_state idle` and did not create `#freshsalt-local-image-picker`.
  - Meaning: one high-visibility platform defect has been removed (the import buttons are no longer missing from the live interaction layer), but the remaining blocker is now narrower: the Web native picker trigger itself still does not advance under live runtime verification.
  - Status: partially fixed and revalidated on 2026-06-27.

## 2026-06-27 AI Capture Assistant

- A smallest-possible `AI采集助手` landing point has now been added to the main capture page
  - File/module: `app/freshsalt_surface/lib/features/capture/capture_page.dart`, `app/freshsalt_surface/lib/core/services/ai_capture_assistant_service.dart`
  - Visible behavior: after real-image import state exists, the main capture page can now surface an `AI采集助手` card with:
    - `AI质控：可用 / 建议重拍`
    - `AI建议ROI`
    - `问题原因`
  - Meaning: this is a concrete AI-in-experiment insertion point at the acquisition stage, not a late-stage empty AI label on the result page only.
  - Status: implemented on 2026-06-27 and statically verified.

- The AI capture assistant currently depends on existing real-image QC / ROI state rather than replacing the unresolved Web picker trigger
  - File/module: `app/freshsalt_surface/lib/features/capture/capture_page.dart`, `app/freshsalt_surface/lib/core/services/local_image_picker_web.dart`
  - Runtime limitation: the new AI card is ready to explain real-image QC and ROI guidance once the real-image state advances, but the live Flutter Web native picker trigger is still the gating defect on `#/capture`.
  - Meaning: the new AI card improves the platform’s experimental AI expression with minimal cost, but it does not by itself solve the still-open browser-side import-trigger blocker.
  - Status: intentionally recorded as unresolved dependency on 2026-06-27.

## 2026-06-27 Duplicate Import Entry Root Cause

- The main `#/capture` page currently contains two separate real-import entry groups, and only the garbled-text group is wired to the live picker trigger
  - File/module: `app/freshsalt_surface/lib/features/capture/capture_page.dart`
  - Runtime behavior: the visible DOM on the current localhost page exposes both:
    - a garbled pair: `瀵煎叆鐪熷疄 I0 / I1`
    - a normal Chinese pair: `导入真实 I0 / I1`
  - Runtime behavior: direct DOM/CUA click on the normal Chinese `导入真实 I0` does not change `picker_state`, while direct DOM/CUA click on the garbled `瀵煎叆鐪熷疄 I0` advances `freshsaltPickerState` to `clicked` and mounts `#freshsalt-local-image-picker`.
  - Meaning: the current user-facing “空壳” impression is now traced to a duplicate-entry mismatch: the visible clean Chinese entry is effectively dead, while the hidden/garbled sibling entry is the one still bound to the working picker trigger.
  - Status: root cause confirmed on 2026-06-27; cleanup fix still pending.

- The capture-page shell has now been rewritten to remove the duplicate import-entry design in source, but live browser proof after restart remains unstable
  - File/module: `app/freshsalt_surface/lib/features/capture/capture_page.dart`
  - Source change: the page shell was rebuilt around a single real-image import section, a visible `导入状态` section, and the `AI采集助手` card, while the simulated path was separated into its own smaller section.
  - Verification: `flutter analyze lib/features/capture/capture_page.dart` passed, and `flutter test test/app_flow_test.dart --plain-name "capture page can run through demo chain to save stage"` passed after the rewrite.
  - Runtime limitation: after restarting the localhost web-server, a fresh in-app browser verification tab again returned empty text / zero semantics instead of a stable visible page, so the final live proof for the rewritten single-entry shell is still weaker than the source and test evidence.
  - Status: partially fixed and statically revalidated on 2026-06-27; live browser readback still unstable.

- The rewritten single-entry capture shell is now live-verified in the in-app browser
  - File/module: `app/freshsalt_surface/lib/features/capture/capture_page.dart`, route `http://localhost:4350/#/capture`
  - Live behavior: the current page now exposes a single clean Chinese real-import pair in semantics:
    - `导入真实 I0`
    - `导入真实 I1`
  - Live behavior: direct DOM/CUA click on `导入真实 I0` advances the visible `导入状态` card from `picker_state: idle` to `picker_state: clicked` and mounts `#freshsalt-local-image-picker`.
  - Meaning: the previous duplicate-entry / dead-clean-entry defect on the main capture page has now been closed at the live interaction layer.
  - Remaining gap: this confirms the trigger boundary and user-visible state transition, but it does not yet prove a full manual file selection all the way through to imported real-image state and downstream AI capture assistant output on the same live page.
  - Status: fixed and live-revalidated on 2026-06-27.

## 2026-06-27 Web Real Import Fallback

- The current localhost Web picker path still lacks a stable end-to-end visible proof after `picker_state: clicked`
  - File/module: `app/freshsalt_surface/lib/core/services/local_image_picker_web.dart`, `app/freshsalt_surface/lib/features/capture/capture_page.dart`
  - Live behavior: the real import button triggers the browser file input, but this session still did not produce a reliable visible transition to `real_image_file` through the native chooser path.
  - Mitigation added: the capture page now includes `加载内置图片`, which injects two bundled PNG assets into the same real-image QC, ROI, and AI capture assistant path.
  - Status: Web native picker completion remains unresolved and recorded; visible fallback path added on 2026-06-27.

## 2026-06-27 Capture Page Frontend Sanitization

- The capture page previously exposed task-specific and potentially identifying front-end wording that was too narrow for a public-facing product surface
  - File/module: `app/freshsalt_surface/lib/features/capture/capture_page.dart`
  - Issue: visible labels such as contest-oriented sample wording, sample switching, and noisy mixed guidance made the page look internal and overfitted instead of serving general users.
  - Fix: replaced the page copy with neutral public-facing labels, removed the visible sample-switching block, simplified section text, and changed the built-in fallback entry from contest-specific wording to generic `加载内置图片`.
  - Status: capture-page front-end copy sanitized on 2026-06-27.

## 2026-06-27 Stage Shell Cleanup

- The ROI / feature / prediction stages were not actually empty, but their front-end shells were so corrupted by mojibake and clutter that they looked nonfunctional
  - File/module: `app/freshsalt_surface/lib/shared/widgets/capture_stage_shell.dart`, `app/freshsalt_surface/lib/features/roi/roi_page.dart`, `app/freshsalt_surface/lib/features/feature_preview/feature_preview_page.dart`, `app/freshsalt_surface/lib/features/prediction/prediction_page.dart`
  - Issue: stage titles, summaries, buttons, and metric labels were unreadable, which masked the existing ROI drag logic and the feature / prediction result surfaces.
  - Fix: rewrote the shared stage shell and the three stage pages into readable Chinese, kept ROI drag/resize behavior, and made feature/prediction pages show result-first cards instead of noisy text-first shells.
  - Status: stage-shell readability and visibility repaired on 2026-06-27.

## 2026-06-27 Leading Pages Shell Cleanup

- The home page and bottom navigation were still carrying large amounts of visible garbage text and mojibake, making the five leading pages feel broken even when routing still worked
  - File/module: `app/freshsalt_surface/lib/features/home/home_page.dart`, `app/freshsalt_surface/lib/features/capture/capture_page.dart`, `app/freshsalt_surface/lib/shared/widgets/platform_bottom_nav_shell.dart`
  - Fix: rewrote the front-page shell, capture shell, and bottom navigation labels into clean public-facing Chinese while preserving the current route structure and capture main flow.
  - Verification: targeted `flutter analyze` passed and the main capture-chain widget regression still passed after the shell rewrite.
  - Status: first-pass leading-page shell cleanup completed on 2026-06-27.

## 2026-06-27 Public-Facing Frontend Sanitization

- The result, history, and report surfaces still contained either mojibake, contest-oriented residue, or overly narrow experimental wording that weakened public-facing readability
  - File/module: `app/freshsalt_surface/lib/features/result/result_page.dart`, `app/freshsalt_surface/lib/features/history/history_page.dart`, `app/freshsalt_surface/lib/features/report/report_page.dart`, `app/freshsalt_surface/lib/shared/widgets/platform_module_shell.dart`
  - Fix: rewrote the history and report pages into readable public-facing Chinese, cleaned the result-page visible copy, and removed the last visible mojibake summary label in the shared module shell.
  - Verification: targeted `flutter analyze` passed for the cleaned pages and the core capture-chain widget test still passed.
  - Status: source-level sanitization completed on 2026-06-27.

- The built-in fallback sample asset names still exposed contest-oriented wording in the capture flow source
  - File/module: `app/freshsalt_surface/lib/features/capture/capture_page.dart`, `app/freshsalt_surface/assets/real_samples/public_i0.png`, `app/freshsalt_surface/assets/real_samples/public_i1.png`
  - Fix: switched the capture fallback loader from `contest_i0/i1` to neutral `public_i0/i1` copies so the visible public product path no longer depends on contest-named assets.
  - Status: fixed on 2026-06-27.

- A live runtime inconsistency still remains on `#/result`
  - Route/module: `http://localhost:4350/#/result`, `app/freshsalt_surface/lib/features/result/result_page.dart`
  - Runtime behavior: after source cleanup and a web-server restart, `#/history` and `#/report` reflected the new public-facing copy, but `#/result` still surfaced old wording in one browser-visible path; a separate fresh-tab verification then degraded to a white page instead of yielding a stable new screenshot.
  - Meaning: the result page now looks substantially usable, but one browser-runtime cache/bootstrap inconsistency remains and should be treated as unresolved until a stable fresh-tab verification consistently reflects the new copy.
  - Status: unresolved and recorded on 2026-06-27.

- The shared bottom-shell routes still have a runtime bootstrap instability on fresh-tab startup
  - Route/module: `#/result`, `#/history`, `#/report`, `app/freshsalt_surface/lib/shared/widgets/platform_bottom_nav_shell.dart`, `app/freshsalt_surface/lib/app.dart`
  - Runtime behavior: after sanitizing the bottom-nav shell and restarting the localhost web-server, a fresh in-app browser tab opened directly to `#/result?fresh=...`, `#/history?fresh=...`, and `#/report?fresh=...` rendered as white pages, even though targeted `flutter analyze` passed and earlier same-session screenshots had shown these pages normally.
  - Meaning: the current highest-confidence remaining front-end defect is no longer isolated to result-page wording. It has narrowed to a shared initialization or route-bootstrap branch affecting the bottom-shell pages on at least one fresh-tab entry path.
  - Status: unresolved and recorded on 2026-06-27.

- The white-page defect is reproducible even on clean hash routes after route parsing cleanup
  - Route/module: `#/result`, `#/history`, `#/report`, `#/`, `app/freshsalt_surface/lib/app.dart`, `app/freshsalt_surface/lib/shared/widgets/platform_bottom_nav_shell.dart`
  - Investigation: the route parser was tightened to strip query fragments from `Uri.base.fragment`, and the bottom-nav shell source was rechecked to confirm clean Chinese labels in code.
  - Verification: targeted `flutter analyze` still passed, but after restarting the localhost web-server, direct browser verification of clean hash routes still produced white pages for `#/result`, `#/history`, `#/report`, and even `#/`.
  - Meaning: this is now stronger evidence that the remaining issue is a broader runtime bootstrap or Flutter web-server rendering failure, not merely stale text, hash query parsing, or one corrupted bottom-nav source file.
  - Status: unresolved and escalated on 2026-06-27.

- The white-page perception has been reduced to a visible loading-shell state, but first-frame completion is still too slow or inconsistent
  - Route/module: `app/freshsalt_surface/web/index.html`, route `#/result`
  - Root-cause evidence: browser console previously showed `require.js` / `web_entrypoint.dart` bootstrap instability, and direct page inspection showed the page could remain visually blank before Flutter mounted.
  - Fix: added a public-facing loading shell in `web/index.html` that appears immediately and removes itself on `flutter-first-frame`.
  - Verification: browser screenshots now show the loading shell instead of a pure white page during startup.
  - Remaining gap: in the latest 10-second verification window, the page still had not advanced from the loading shell to the actual result UI, so startup slowness or bootstrap incompletion remains unresolved.
  - Status: partially fixed and still open on 2026-06-27.

- The startup issue is now better characterized as long debug bootstrap time, not a permanent blank-page failure
  - Runtime evidence: `flutter run -d web-server` log shows repeated `Waiting for connection from debug service on Web Server...` for more than 80 seconds before normal serving continues.
  - Browser evidence: after waiting longer, the actual result page mounts and shows the AI explanation card and bottom navigation; the earlier “white page” state is the pre-first-frame startup window.
  - Meaning: the pure blank-page failure has narrowed into a startup-latency problem plus poor first-screen loading feedback. The visible loading shell now masks the blank interval, but the underlying debug startup remains slow.
  - Status: narrowed and recorded on 2026-06-27.

- ROI, feature-preview, and prediction pages are now browser-visible, but their first-screen states still feel too empty before the user presses the main action
  - Route/module: `#/roi`, `#/feature-preview`, `#/prediction`
  - Browser evidence:
    - `#/roi` shows a real manual ROI canvas with drag area and confirmation flow.
    - `#/feature-preview` shows a visible “提取特征” action area instead of a dead blank page.
    - `#/prediction` shows a visible “开始结果计算” action area and result placeholder card instead of a dead blank page.
  - Remaining gap: these pages still default to “待提取 / 待计算 / 画布较空”的观感, so users may still judge them as weak or half-finished unless the first visible state is made more informative.
  - Status: partially fixed and still needs first-screen strengthening on 2026-06-27.

## 2026-06-27 Frontend Text Sanitization Follow-up

- The capture main page still contained source-level mojibake and public-facing wording drift even after earlier shell cleanup
  - File/module: `app/freshsalt_surface/lib/features/capture/capture_page.dart`
  - Issue: the main capture page still exposed garbled Chinese in section titles, buttons, notices, and stage labels, which made the app look broken even though the import, AI capture assistant, and evidence logic were already wired.
  - Fix: rebuilt the capture page with clean public-facing Chinese while preserving the existing real import, built-in image fallback, AI capture assistant, runtime evidence, and stage-routing behavior.
  - Verification: focused `flutter analyze lib/features/capture/capture_page.dart ...` now reports only one non-blocking `prefer_const_constructors` info in `feature_preview_page.dart`, and `flutter test test/app_flow_test.dart --plain-name "capture page can run through demo chain to save stage"` passed.
  - Status: source-level main-page sanitization completed on 2026-06-27.

- The feature-preview page had a real compile blocker caused by a malformed conditional expression from a prior partial edit
  - File/module: `app/freshsalt_surface/lib/features/feature_preview/feature_preview_page.dart`
  - Issue: the page contained a broken `child: featureVector == null : ...` branch and mixed mojibake copy, which blocked focused analyze and prevented safe follow-up verification.
  - Fix: rebuilt the page into a clean result-first shell with default preview features, working extraction action, and readable Chinese copy.
  - Verification: the focused analyze run no longer reports any compile error on this file.
  - Status: fixed on 2026-06-27.

- ROI, feature-preview, and prediction stage shells have been rebuilt into readable public-facing Chinese, but live browser proof for the refreshed wording still needs another manual check
  - File/module: `app/freshsalt_surface/lib/shared/widgets/capture_stage_shell.dart`, `app/freshsalt_surface/lib/features/roi/roi_page.dart`, `app/freshsalt_surface/lib/features/feature_preview/feature_preview_page.dart`, `app/freshsalt_surface/lib/features/prediction/prediction_page.dart`
  - Fix: rebuilt the shared stage shell and the three stage pages so they no longer depend on mojibake-heavy text and now present clearer first-screen summaries.
  - Remaining gap: this turn verified source and widget-regression stability, but did not complete a fresh route-by-route in-app browser proof after the rebuild.
  - Status: partially closed and still needs live browser confirmation on 2026-06-27.

- The five leading shell pages no longer fail at source-level readability, but the current in-app browser control session itself did not expose a controllable localhost tab for fresh route-by-route verification
  - File/module: `app/freshsalt_surface/lib/features/home/home_page.dart`, `app/freshsalt_surface/lib/shared/widgets/platform_bottom_nav_shell.dart`, in-app browser control session
  - Root-cause evidence: browser-client setup succeeded and the in-app browser documentation loaded, but `iab.user.openTabs()` returned `[]`, and both `iab.tabs.selected()` / `iab.tabs.new()` attempts surfaced `Tab 68 is not part of browser session ...`, so the current session could not claim or create a controllable localhost verification tab.
  - Fix on source side: rebuilt the home page and five-tab bottom navigation shell into clean Chinese so the highest-visibility public-facing entry pages no longer depend on mojibake-heavy text.
  - Remaining gap: this turn could verify the shell cleanup only through source + analyze + widget regression, not through a fresh in-app browser walkthrough of `#/`, `#/capture`, `#/roi`, `#/feature-preview`, and `#/prediction`.
  - Status: source-level shell cleanup completed; browser-session control remains an external verification blocker on 2026-06-27.

## 2026-06-27 Public-Facing Cleanup Closure

- The capture, ROI, feature-preview, and settings pages still contained public-facing wording drift and unstable interaction-proof gaps at the start of this pass
  - File/module: `app/freshsalt_surface/lib/features/capture/capture_page.dart`, `app/freshsalt_surface/lib/features/roi/roi_page.dart`, `app/freshsalt_surface/lib/features/feature_preview/feature_preview_page.dart`, `app/freshsalt_surface/lib/features/settings/settings_page.dart`
  - Issue: visible copy still mixed internal/demo-oriented phrasing with noisy explanatory text, and ROI lacked a stable widget-test hook for proving the manual drag interaction.
  - Fix: rebuilt those visible pages into neutral public-facing Chinese, removed contest/team/personnel-facing wording from the touched surfaces, added a stable ROI drag key (`roi-move-region`), and aligned the feature-preview default state with a result-first presentation.
  - Verification: `flutter analyze lib\\features\\capture\\capture_page.dart lib\\features\\roi\\roi_page.dart lib\\features\\feature_preview\\feature_preview_page.dart lib\\features\\settings\\settings_page.dart test\\app_flow_test.dart` passed; the focused widget tests `roi page supports manual drag and updates area summary` and `feature page shows default preview before extraction` both passed on 2026-06-27.
  - Remaining gap: this pass proves source integrity and focused interaction regression, but not a fresh route-by-route browser click walkthrough, because browser-session control remained externally unstable in this thread.
  - Status: source-level frontend de-sensitization and focused proof completed on 2026-06-27; live route-by-route browser proof still pending.

- The top-level platform shell still had a first-screen “broken app” impression because the home workbench and bottom navigation were visibly mojibake-heavy
  - File/module: `app/freshsalt_surface/lib/features/home/home_page.dart`, `app/freshsalt_surface/lib/shared/widgets/platform_bottom_nav_shell.dart`, `app/freshsalt_surface/lib/features/prediction/prediction_page.dart`
  - Issue: the five leading pages still exposed unreadable labels at the highest-visibility layer, and the prediction stage also looked like a corrupted empty shell before any user action.
  - Fix: rebuilt the home page, bottom navigation shell, and prediction page into readable public-facing Chinese while preserving the current route structure, capture main flow, and result-preview behavior.
  - Verification: `flutter analyze lib\\features\\home\\home_page.dart lib\\shared\\widgets\\platform_bottom_nav_shell.dart lib\\features\\prediction\\prediction_page.dart` passed; focused widget tests `prediction page shows default preview before calculation` and `capture page can run through demo chain to save stage` both passed on 2026-06-27.
  - Remaining gap: this closes the source-level “乱码即坏掉” defect for the touched leading pages, but browser-visible verification of the refreshed shell text is still weaker than source + focused regression in this turn.
  - Status: source-level leading-shell cleanup completed on 2026-06-27; fresh browser proof still pending.

- The shared module shell plus the history/report leading pages still carried enough mojibake to keep the five-page platform feeling unfinished
  - File/module: `app/freshsalt_surface/lib/shared/widgets/platform_module_shell.dart`, `app/freshsalt_surface/lib/features/history/history_page.dart`, `app/freshsalt_surface/lib/features/report/report_page.dart`
  - Issue: even after the home and bottom-nav cleanup, the next layer of high-visibility pages still exposed corrupted titles, buttons, and summary copy, which kept the app reading like a broken stitched shell.
  - Fix: rebuilt the shared platform module shell, history page, and report page into clean public-facing Chinese while preserving current repository reads, CSV/report preview behavior, and navigation into result/analysis/report flows.
  - Verification: `flutter analyze lib\\features\\history\\history_page.dart lib\\features\\report\\report_page.dart lib\\shared\\widgets\\platform_module_shell.dart` passed; focused widget tests `result page shows AI explanation card` and `capture page can run through demo chain to save stage` both passed on 2026-06-27.
  - Remaining gap: this significantly reduces the visible shell corruption in source, but this turn still does not prove that every updated leading page has been re-seen in the live browser after reload.
  - Status: source-level history/report/module-shell cleanup completed on 2026-06-27; browser-visible recheck still pending.

## 2026-06-27 Public-Facing Sanitization Follow-up

- The mode-selection page and model-management page still exposed user-visible mojibake and narrow project-facing wording after the main shell cleanup
  - File/module: `app/freshsalt_surface/lib/features/home/mode_selection_page.dart`, `app/freshsalt_surface/lib/features/model_bundle/model_bundle_page.dart`
  - Issue: both pages still contained corrupted Chinese and wording too close to internal demo/project framing, which conflicted with the new public-facing product tone.
  - Fix: rebuilt both pages in clean Chinese, removed contest/team/personnel-facing language from the visible copy, and kept only neutral product-facing entry and model-management descriptions.
  - Status: source-level sanitization completed on 2026-06-27.

- Browser-visible verification is still partially blocked by tab ownership and browser targeting instability
  - Runtime/module: in-app browser controller, Edge verification
  - Evidence: `iab.user.openTabs()` still returned `[]`, so the current in-app browser session could not claim the user-visible localhost tab.
  - Evidence: a fallback Edge readback opened or attached to existing non-local tabs and returned unrelated third-party page text instead of the local app route, which means browser automation did not yet provide a reliable route-by-route proof for `http://localhost:4350`.
  - Impact: source cleanup is ahead of live browser proof in this pass; a stable dedicated localhost browser tab still needs to be created and verified.
  - Status: unresolved and recorded on 2026-06-27.

## 2026-06-27 Startup-Shell Reclassification

- The current `APP cannot open` complaint is no longer best described as a dead localhost service
  - Runtime/module: `http://localhost:4350`, Edge live tab, headless Edge verification
  - Evidence: direct HTTP probes returned `200` for `/`, `flutter_bootstrap.js`, and `main.dart.js`.
  - Evidence: a headless Edge run against `http://localhost:4350/#/capture` mounted the real Flutter page and returned visible capture text including `图像采集`, `导入基线图`, `导入待测图`, `执行质控`, `执行特征提取`, and `执行预测`.
  - Evidence: the user-visible Edge window in this thread remained stuck on the branded loading shell, which means the current visible failure is now better characterized as a stale or blocked browser tab instance rather than a proven dead app server.
  - Impact: the highest-value recovery action is to open or refresh a clean localhost tab/window for manual testing, not to continue treating the app as globally unreachable.
  - Status: narrowed and recorded on 2026-06-27.

- Source-level startup and stage-shell mojibake was still present in the final visible入口 layer and was repaired in this pass
  - File/module: `app/freshsalt_surface/web/index.html`, `app/freshsalt_surface/lib/routing/app_router.dart`
  - Evidence: both files still contained source-level garbled Chinese around the startup shell and I0/I1 route labels when rechecked in this pass.
  - Fix: rewrote `web/index.html` into a clean loading shell and rewrote `app_router.dart` to preserve route logic while cleaning the I0/I1 visible stage copy.
  - Impact: this removes one more visible “broken app” signal from the homepage/main-flow layer, even though the old Edge tab can still remain stuck on a stale startup shell.
  - Status: fixed on 2026-06-27.

## 2026-06-27 Capture Main-Flow Readability Follow-up

- The capture main page was still the single biggest visible mismatch because the first screen of the core import -> ROI -> feature -> prediction flow remained source-level mojibake-heavy
  - File/module: `app/freshsalt_surface/lib/features/capture/capture_page.dart`
  - Issue: users could not reliably understand the real-image import, AI capture assistant, main-chain actions, or stage-entry buttons because the visible shell was still garbled.
  - Fix: rebuilt the capture page in clean public-facing Chinese while preserving the existing import, ROI, feature, prediction, save, and evidence logic.
  - Verification: focused `flutter analyze lib/features/capture/capture_page.dart` passed on 2026-06-27.
  - Status: source-level shell readability repaired on 2026-06-27.

- The shared capture-stage shell was still contaminating ROI / feature-preview / prediction with mojibake even after page-specific cleanup
  - File/module: `app/freshsalt_surface/lib/shared/widgets/capture_stage_shell.dart`
  - Issue: the shared stage summary labels remained garbled, which meant every downstream capture-stage page still looked partially broken at the shell layer.
  - Fix: rebuilt the shared stage shell into clean public-facing Chinese so the common header and stage-summary surface no longer inject broken text into ROI, feature-preview, or prediction pages.
  - Verification: focused `flutter analyze lib/features/capture/capture_page.dart lib/shared/widgets/capture_stage_shell.dart` passed on 2026-06-27.
  - Remaining gap: ROI, feature-preview, and prediction pages still need another pass for their page-local copy plus live browser proof.
  - Status: partially closed on 2026-06-27.

- The ROI / feature-preview / prediction pages were not actually empty-shell modules, but their page-local copy still looked broken enough for users to judge them as unusable
  - File/module: `app/freshsalt_surface/lib/features/roi/roi_page.dart`, `app/freshsalt_surface/lib/features/feature_preview/feature_preview_page.dart`, `app/freshsalt_surface/lib/features/prediction/prediction_page.dart`
  - Issue: source-level mojibake in page titles, summaries, buttons, and status text made the manual ROI drag flow and the default feature/result preview states look fake or nonfunctional.
  - Fix: rebuilt all three pages into clean public-facing Chinese while preserving the manual ROI drag/resize behavior, the default feature preview, and the default result-preview/save flow.
  - Verification:
    - `flutter analyze lib/features/roi/roi_page.dart lib/features/feature_preview/feature_preview_page.dart lib/features/prediction/prediction_page.dart lib/features/capture/capture_page.dart lib/shared/widgets/capture_stage_shell.dart`
    - `flutter test test/app_flow_test.dart --plain-name "roi page supports manual drag and updates area summary"`
    - `flutter test test/app_flow_test.dart --plain-name "feature page shows default preview before extraction"`
    - `flutter test test/app_flow_test.dart --plain-name "prediction page shows default preview before calculation"`
  - Remaining gap: this proves source integrity and focused interaction regression, but not a fresh browser-visible route-by-route walkthrough in a stable localhost tab.
  - Status: source-level main-flow readability and focused regression repaired on 2026-06-27.

- Real-image prediction remains intentionally incomplete even after the result-computation page cleanup
  - File/module: `app/freshsalt_surface/lib/features/capture/capture_page.dart`
  - Evidence: when real images are imported, the current flow still returns the explicit message that prediction is kept in demo state and does not continue to output a real prediction result.
  - Impact: the visible result-calculation page is no longer an empty shell, but end-to-end real-image prediction is still not achieved and must not be misrepresented as complete.
  - Status: unresolved and still recorded on 2026-06-27.

- The five leading platform pages still had a broken first-screen impression because the home shell, history shell, report shell, and bottom navigation continued to inject mojibake at the highest-visibility layer
  - File/module: `app/freshsalt_surface/lib/features/home/home_page.dart`, `app/freshsalt_surface/lib/features/history/history_page.dart`, `app/freshsalt_surface/lib/features/report/report_page.dart`, `app/freshsalt_surface/lib/shared/widgets/platform_bottom_nav_shell.dart`
  - Issue: even after the capture main-flow cleanup, users could still hit obviously broken shell text and noisy hierarchy in the top-level workbench and the four most visible follow-up pages, which kept the app reading like a stitched demo rather than a usable platform.
  - Fix: rebuilt those four files into clean public-facing Chinese while preserving the current routing, trend summary, history filtering, report preview, and five-tab shell structure.
  - Verification: `flutter analyze lib/features/home/home_page.dart lib/features/history/history_page.dart lib/features/report/report_page.dart lib/shared/widgets/platform_bottom_nav_shell.dart lib/features/result/result_page.dart`
  - Browser proof: a dedicated Edge localhost window (`FreshSalt Surface - Microsoft Edge`) was opened and read successfully on 2026-06-27. Visible text was confirmed for `#/`, `#/result`, `#/history`, and `#/report`.
  - Browser proof details:
    - `#/` shows `FreshSalt Surface 图像采集 / 质控分析 / AI辅助判断`, `开始采集流程`, and the cleaned five-tab navigation labels.
    - `#/result` shows the AI explanation card with `可信度`, `关键影响因子`, `本次结果为何偏高/偏低`, and `是否建议重拍或补采`.
    - `#/history` shows the cleaned history shell, filter entry, overview cards, and empty-state guidance.
    - `#/report` shows the cleaned report shell and empty-state actions.
  - Remaining gap: browser-visible proof is now substantially stronger for the leading routes, but route-by-route proof still does not cover every secondary page and real-image prediction remains demo-only.
  - Status: browser-visible acceptance substantially advanced on 2026-06-27; only partial runtime gaps remain.

- The main flow still had two last visible mojibake sources even after the capture / ROI / feature / prediction cleanup
  - File/module: `app/freshsalt_surface/lib/routing/app_router.dart`, `app/freshsalt_surface/lib/features/capture/image_stage_page.dart`, `app/freshsalt_surface/web/index.html`
  - Issue: the I0 / I1 route labels, stage descriptions, navigation buttons, and the startup loading shell still exposed broken text, which meant the homepage could look clean while the first real capture stages still degraded into garbage text during startup or stage transitions.
  - Fix: rebuilt the route-visible labels in `app_router.dart`, rebuilt the I0/I1 stage page in clean public-facing Chinese, and rewrote the web loading shell text in `web/index.html` while preserving the existing startup and service-worker logic.
  - Verification: `flutter analyze lib/routing/app_router.dart lib/features/capture/image_stage_page.dart lib/features/capture/capture_page.dart lib/features/roi/roi_page.dart lib/features/feature_preview/feature_preview_page.dart lib/features/prediction/prediction_page.dart lib/features/home/home_page.dart`
  - Remaining gap: the main-page and main-flow source cleanup is now substantially closed, but real-image prediction is still demo-only and live proof is still stronger for top routes than for every intermediate stage route.
  - Status: main-page and main-flow source cleanup substantially closed on 2026-06-27.

## 2026-06-27 Homepage Workbench Simplification

- The homepage workbench still felt visually cluttered even after earlier text cleanup
  - File/module: `app/freshsalt_surface/lib/features/home/home_page.dart`, `app/freshsalt_surface/lib/shared/widgets/platform_bottom_nav_shell.dart`
  - Evidence: the visible homepage structure still stacked too many status cards, explanatory lines, and secondary entry points above the fold, which diluted the primary capture entry and made the workbench read as noisy rather than task-led.
  - Fix: rebuilt the homepage into a tighter workbench structure centered on one main action (`开始采集流程`), three compact summary chips, a smaller state/trend pair, and a reduced six-item common-entry grid; also rewrote the bottom navigation labels in clean Chinese.
  - Verification: `flutter analyze lib/features/home/home_page.dart lib/shared/widgets/platform_bottom_nav_shell.dart`
  - Remaining gap: this pass improves hierarchy and readability in source, but a fresh browser-visible confirmation of the new homepage layout is still pending.
  - Status: fixed in source on 2026-06-27 and awaiting live browser confirmation.

## 2026-06-27 Default Focused Shell Rollout

- The focused workbench rule was still limited to the homepage and had not yet become the default structure for all main pages
  - File/module: `app/freshsalt_surface/lib/shared/widgets/platform_module_shell.dart`, `app/freshsalt_surface/lib/shared/widgets/capture_stage_shell.dart`, `app/freshsalt_surface/lib/features/history/history_page.dart`, `app/freshsalt_surface/lib/features/report/report_page.dart`, `app/freshsalt_surface/lib/features/result/result_page.dart`
  - Evidence: history/report/result still carried older stacked structures with too many first-screen explanations, and the shared module/stage shells did not enforce the same compact hierarchy as the simplified homepage.
  - Fix: rewrote the shared module shell and capture-stage shell into a common focused pattern (`title + short subtitle + few tags + <=3 summary items`), then compressed history/report/result to prioritize one clear action area, compact status summary, and smaller follow-up sections.
  - Verification: `flutter analyze lib\\shared\\widgets\\platform_module_shell.dart lib\\shared\\widgets\\capture_stage_shell.dart lib\\features\\history\\history_page.dart lib\\features\\report\\report_page.dart lib\\features\\result\\result_page.dart`
  - Remaining gap: this completes the source-level default-shell unification for the main visible pages, but a fresh browser-visible route recheck is still needed to confirm the new hierarchy at runtime.
  - Status: fixed in source and focused analyze-verified on 2026-06-27.

## 2026-06-27 Real Import Boundary Recheck

- The current strongest unresolved gap is no longer “real PNG files cannot enter the real-image chain” at source level
  - File/module: `app/freshsalt_surface/lib/features/capture/capture_page.dart`, `app/freshsalt_surface/lib/features/capture/image_stage_page.dart`, `app/freshsalt_surface/lib/core/services/real_image_analysis_service.dart`, `app/freshsalt_surface/test/core_services_test.dart`, `app/freshsalt_surface/test/app_flow_test.dart`, `app/freshsalt_surface/test/demo_capture_bundle_real_flow_test.dart`
  - Evidence: the workspace-real-sample test using `原始数据-光栅` passed; the salted-stage import callback test passed; the real-image QC/feature bundle tests passed; all of them prove that real PNG bytes can decode, enter `real_image_pixels`, and refresh stage UI into `real_image_file` state in the current code/test environment.
  - New blocker evidence: this turn's Windows Computer Use session was forcibly stopped before file-dialog interaction because it could not determine the current browser URL with enough confidence to enforce policy, so no new browser-visible end-to-end chooser proof was obtained in this turn.
  - Meaning: the remaining unresolved scope is now narrower and more honest: live browser-side native file selection proof is still missing in this turn, but current evidence does not support claiming that the real-image decode/QC/feature path is still fundamentally broken in source.
  - Remaining gap: still need one stable browser-visible run on `#/capture` showing `导入真实 I0/I1` -> actual selected file -> `real_image_file` / `qc_source_mode=real_image_pixels` / `AI采集助手` visible on the live page.
  - Status: source/test boundary reclassified and desktop-proof gap preserved on 2026-06-27.

## 2026-06-27 Browser-Visible Real Import Proof

- The live browser-side proof gap for the real-image import chain is now substantially closed
  - Runtime/module: `http://localhost:4350/#/capture`, `http://localhost:4350/#/quality-control`
  - Browser-visible evidence:
    - On `#/capture`, after waiting for the Flutter page to mount, the page exposed `picker_state: idle`, `导入基线图`, and `导入待测图`.
    - Uploading two real PNG files from `F:\1.大学物理竞赛\原始数据-光栅` changed the page-visible import state to `picker_state: loaded` and `real_image_ready`.
    - The same page also exposed the `AI采集助手` section with `AI质控：待分析`.
    - Clicking `进入成像质控` after the uploads opened the QC page with visible `real_image_pixels` and `Real Image Input real_image_pixels -1.对照-0.png`.
  - Meaning: the browser-visible chain now proves that the real file chooser returns usable file bytes to the app and that the downstream QC route is reading the session as real-pixel input rather than simulated-only import state.
  - Remaining gap: this proof does not yet close the user's broader complaints about ROI background image rendering, result-page usefulness, mock-path removal, or the current prediction page still being demo-only for real images.
  - Status: live browser-visible real import + QC-source proof obtained on 2026-06-27.

## 2026-06-27 ROI Real Background Proof

- The highest-priority remaining visible defect after the import/QC proof was the ROI canvas still looking like an empty shell
  - Runtime/module: `http://localhost:4350/#/roi`, `app/freshsalt_surface/lib/features/roi/roi_page.dart`
  - Root-cause evidence:
    - Real imports on `#/capture` still reached `picker_state: loaded`, `real_image_ready`, `I0_source real_image_file`, and `I1_source real_image_file`.
    - QC still showed `real_image_pixels`, so the real-image bytes were already entering the controller and downstream QC route.
    - ROI page still rendered only the grid and drag box when reached from the capture route, which proved the remaining defect was ROI-side rendering/visibility rather than file picking or QC source tagging.
  - Fix:
    - Kept the ROI page bound to imported image bytes and changed the ROI canvas background to a more stable memory-backed decoration render path.
    - Added an explicit browser-visible line `当前底图：真实图片` inside the ROI interaction card so the image source is visible without relying only on the header summary shell.
  - Verification:
    - `flutter analyze lib/features/roi/roi_page.dart`
    - `flutter test test/app_flow_test.dart --plain-name "salted stage refreshes into real image state after import callback"`
    - Browser-visible replay on `#/capture` using real PNG files from `F:\1.大学物理竞赛\原始数据-光栅`, then entering `ROI`.
  - Browser proof details:
    - The capture page still showed `picker_state: loaded`, `real_image_ready`, `AI采集助手`, `I0_source real_image_file`, and `I1_source real_image_file`.
    - After entering `ROI`, the page showed `当前底图：真实图片`.
    - The ROI canvas displayed the imported real image beneath the ROI overlay instead of a blank placeholder.
  - Remaining gap:
    - Real-image result calculation is still demo-only and must not be claimed as a real prediction workflow.
    - QC-to-I0 automatic continuation can still be blocked by QC state, so this turn's ROI proof used the visible ROI entry on the capture page rather than claiming the full standard stage progression is now perfect.
  - Status: live ROI real-background proof obtained on 2026-06-27.

## 2026-06-27 Real Prediction Root-Cause Recheck

- The remaining “0.3500 / simulated replacement” complaint is not just a user impression; the current source still contained an explicit real-image prediction stop
  - File/module: `app/freshsalt_surface/lib/features/capture/capture_page.dart`, `app/freshsalt_surface/lib/core/services/prediction_service.dart`
  - Root-cause evidence:
    - `capture_page.dart` had a hardcoded early return in `_runPredictionWorkflow()` that showed the message “真实图片已接入质控与特征提取，但结果计算仍是演示状态，当前不会继续输出真实预测结果。” whenever imported real images were present.
    - `prediction_service.dart` only forces the fixed demo calibration values such as `0.35` when `sourceMode == 'simulated'`; it does not force `0.35` for `real_image_pixels`.
  - Meaning:
    - The main remaining prediction blocker was not hidden math silently replacing the real result with `0.35`.
    - The real-image path was being explicitly blocked before prediction, while the fixed `0.35` behavior belongs to the simulated prediction branch.
  - Fix:
    - Removed the real-image early-return stop from `_runPredictionWorkflow()`.
    - Routed imported real images into the existing `realImageAnalysisService.extractFeatures()` + `predictionService.predict()` path with `sourceMode: 'real_image_pixels'`.
  - Verification:
    - `flutter analyze lib/features/capture/capture_page.dart`
    - `flutter test test/app_flow_test.dart --plain-name "salted stage refreshes into real image state after import callback"`
  - Remaining gap:
    - A fresh browser-visible proof of the full post-ROI prediction route is still incomplete in this turn because the late-stage route progression check timed out while probing the exact feature/prediction button states after ROI confirmation.
    - Therefore this turn proves the previous real-image prediction stop existed in source and has been removed in source, but does not yet prove the full real-image prediction screen end-to-end at runtime.
  - Status: source-level real-prediction hard stop removed on 2026-06-27; runtime proof still pending.

## 2026-06-27 Prediction Runtime Recheck After Unblocking

- The real-image prediction runtime is no longer blocked by the old explicit demo-only message, but the prediction page still falls back to the default preview card
  - Runtime/module: `http://localhost:4350/#/prediction`, `app/freshsalt_surface/lib/features/prediction/prediction_page.dart`, `app/freshsalt_surface/lib/features/capture/capture_page.dart`
  - Browser-visible evidence:
    - The old real-image block message no longer appeared after the source fix.
    - The prediction page still rendered the default preview state with `0.3500`, `preview`, and `simulated`.
    - The same runtime snapshot also showed that the capture page had lost the imported image state after the ROI round-trip in that probe (`I0_source not_selected`, `I1_source not_selected`, `feature_extraction not_run`), which means the browser-visible prediction view was still not backed by a preserved real-image workflow state in that run.
  - Meaning:
    - The previous hard stop was real and is now removed from source.
    - The remaining runtime blocker has shifted to workflow-state persistence / propagation into the prediction screen, not the same early-return stop.
  - Remaining gap:
    - Still need one browser-visible run where imported real-image state survives through ROI confirmation, feature extraction, and prediction, so the prediction page replaces the preview card with a real computed result.
  - Status: old source-level stop cleared, but runtime real-prediction proof still not achieved on 2026-06-27.

## 2026-06-27 Windows Computer Use URL-Gating Retry

- A second direct Windows-control attempt was blocked before any capture-page interaction could occur
  - Runtime/module: Edge desktop window titled `freshsalt_surface - 个人 - Microsoft Edge`
  - Evidence:
    - A clean new Edge window was launched directly to `http://localhost:4350/#/capture`.
    - `sky.list_apps()` then showed two Edge windows, including the dedicated `freshsalt_surface` window.
    - When Computer Use attempted to activate and snapshot that dedicated window, it stopped with the same policy message that it could not determine the current browser URL with enough confidence to enforce policy.
  - Meaning:
    - This turn does not add new browser-visible import proof.
    - The repeated blocker remains desktop-browser URL confidence gating, not a newly proven regression of the real-image import chain itself.
  - Remaining gap:
    - Still need one desktop-controlled run where Edge is presented in a state Computer Use can confidently classify, so the real I0/I1 chooser flow can be completed and read back from the live page.
  - Status: unresolved external blocker re-confirmed on 2026-06-27.

## 2026-06-27 Real Import Copy Cleanup Scope

- The current real-image import chain still contains source-level mojibake and prompt drift in the highest-priority public-facing copy
  - File/module: `app/freshsalt_surface/lib/core/services/real_image_analysis_service.dart`, `app/freshsalt_surface/lib/core/services/ai_capture_assistant_service.dart`, `app/freshsalt_surface/lib/features/capture/image_stage_page.dart`, `app/freshsalt_surface/test/image_stage_real_import_test.dart`
  - Evidence:
    - QC failure reasons in `real_image_analysis_service.dart` are still mojibake in source, so a real-image QC failure would surface unreadable Chinese to the user.
    - `ai_capture_assistant_service.dart` still returns mojibake quality labels, retake suggestions, and ROI guidance.
    - `image_stage_page.dart` still exposes mojibake stage titles, tags, metrics, and import guidance on the I0/I1 public-facing stage shell.
  - Impact:
    - The real-image chain is functionally wired, but the current copy still degrades the visible quality gate and AI guidance into unreadable text.
  - Planned fix:
    - Limit the change to the four user-specified files, keep logic and thresholds unchanged, and only repair public-facing Chinese copy plus the matching widget test assertions.

## 2026-06-28 Research Report Draft Constraints

- The current task requires a competition-facing research report draft that matches the user's screenshot-based structure while staying aligned with the actual FreshSalt Surface project state
  - Evidence:
    - The user explicitly requested a natural-language, lower-AIGC draft and provided screenshots for both the report framework and the formatting expectation.
    - The baseline project materials confirm that the current system is still in a prototype stage with simulated-data validation and later real-experiment integration, so the report cannot claim finished real calibration results.
    - The workspace also contains a Blender scene for the experiment setup, which should raise presentation quality but must not be misrepresented as completed physical validation.
  - Constraint:
    - The report must keep all simulation-dependent statements explicitly marked as simulated or current-stage validation.
    - The wording should stay flexible enough for later APP optimization, model updates, and real-data integration.
  - Planned handling:
    - Generate an editable draft plus a Word-formatted output with Song font defaults, then leave references and placeholders open for later factual fill-in.

## 2026-06-29 Report Figure Insertion Constraint

- The report now needs embedded figures, including two Blender scene screenshots and one platform runtime screenshot, but live takeover of the existing Windows Edge localhost tab was blocked by Computer Use policy
  - Evidence:
    - The user explicitly requested using computer-use and browser control to add two Blender images plus one platform interface image captured after platform launch.
    - Browser control setup succeeded, but Windows Computer Use stopped with a policy message that it could not determine the current browser URL with enough confidence to enforce policy on the existing Edge window titled `FreshSalt Surface - 个人 - Microsoft Edge`.
    - The workspace already contains an earlier verified runtime homepage screenshot (`outputs/4343-home-final.png`) from the local FreshSalt platform.
  - Handling:
    - Use the two user-provided Blender screenshots directly.
    - Use the existing verified runtime platform screenshot from the workspace as the platform figure source for this report package.
  - Remaining gap:
    - A fresh same-turn live recapture of the runtime platform page is still not proven under the current Windows takeover policy.
