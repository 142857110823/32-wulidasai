# GitHub 参考仓库核对结论

日期：2026-06-14  
参考仓库：`https://github.com/142857110823/12122.git`  
本地下载位置：`repo_reference/12122/`

## 结论

该仓库**不整体符合**当前 FreshSalt Surface 项目边界，原因是仓库根定位仍然是 `water_erosion_mvp` 的 Python + Streamlit 平台，而不是本项目要求的 FreshSalt Surface Android 优先 Flutter APP。

但仓库中**存在局部可参考内容**，主要集中在 `lib/`、`test/` 和 `IMPLEMENTATION_SUMMARY.md` 这几个 FreshSalt 相关文件上，可作为业务分层和服务接口草稿参考。

因此处理原则应为：

1. **禁止把整个仓库当作当前项目基线。**
2. **禁止把 Python/Streamlit/water_erosion 根资产复制进当前 FreshSalt 工作区。**
3. **只允许按文件级别参考 FreshSalt 相关 Dart 核心层内容。**

## 明确不符合本项目的部分

以下内容说明该仓库根仍然属于旧方向：

- [README.md](F:/1.大学物理竞赛/repo_reference/12122/README.md:1) 将项目定义为 `Black Soil Water Erosion Intelligent Prediction and Evidence-Based Evaluation Platform v0.3`。
- [README.md](F:/1.大学物理竞赛/repo_reference/12122/README.md:3) 明确写的是 `Single-base Streamlit platform for black-soil water erosion research.`。
- [README.md](F:/1.大学物理竞赛/repo_reference/12122/README.md:17) 启动方式是 `streamlit run app.py`。
- [AGENTS.md](F:/1.大学物理竞赛/repo_reference/12122/AGENTS.md:11) 将仓库边界固定为 `D:\空\water_erosion_mvp`。
- [AGENTS.md](F:/1.大学物理竞赛/repo_reference/12122/AGENTS.md:12) 要求 `Streamlit app as the only frontend entry point`。
- [app.py](F:/1.大学物理竞赛/repo_reference/12122/app.py:1368) 和 [app.py](F:/1.大学物理竞赛/repo_reference/12122/app.py:2424) 仍保留 `water_erosion_mvp` 相关标识。

这些内容与当前项目的以下要求直接冲突：

- 当前项目不是水蚀平台。
- 当前项目不是 Streamlit 单前端。
- 当前项目不是 Python 平台主线。
- 当前项目必须围绕 FreshSalt Surface 受控 RGB 实验型 APP 展开。

## 可有限参考的部分

以下内容可作为“业务逻辑草稿”参考，但不能直接视为已完成：

- [IMPLEMENTATION_SUMMARY.md](F:/1.大学物理竞赛/repo_reference/12122/IMPLEMENTATION_SUMMARY.md:1)
- [lib/core/orchestrator/freshsalt_orchestrator.dart](F:/1.大学物理竞赛/repo_reference/12122/lib/core/orchestrator/freshsalt_orchestrator.dart:1)
- [lib/core/services](F:/1.大学物理竞赛/repo_reference/12122/lib/core/services)
- [lib/core/models](F:/1.大学物理竞赛/repo_reference/12122/lib/core/models)
- [lib/core/repositories](F:/1.大学物理竞赛/repo_reference/12122/lib/core/repositories)
- [lib/core/export](F:/1.大学物理竞赛/repo_reference/12122/lib/core/export)
- [lib/core/demo](F:/1.大学物理竞赛/repo_reference/12122/lib/core/demo)
- [test/core_services_test.dart](F:/1.大学物理竞赛/repo_reference/12122/test/core_services_test.dart:1)
- [test/orchestrator_test.dart](F:/1.大学物理竞赛/repo_reference/12122/test/orchestrator_test.dart:1)

## 参考时的风险

这些 FreshSalt Dart 文件也只能作为草稿参考，原因如下：

- 仓库没有 `pubspec.yaml`，不是完整可运行 Flutter 工程。
- 部分中文注释和文案存在乱码或错字。
- 目前看到的是核心层片段，不是完整 UI、路由、主题和可运行 APP。
- 它们与旧仓库根共存，容易在新对话中造成“项目边界误判”。

## 新对话中的使用规则

新对话如果需要读取这个参考仓库，必须按以下限制执行：

1. 先读取当前工作区的 `Agent.md`、`AGENTS.md`、`rules/freshsalt.rules.md` 和基准文件。
2. 明确声明：`repo_reference/12122` 只是参考仓库，不是当前项目基线。
3. 优先读取 `repo_reference/12122/lib/` 与 `repo_reference/12122/test/` 下 FreshSalt 相关 Dart 文件。
4. 默认忽略以下目录和文件，除非用户明确要求核查：
   - `app.py`
   - `agent.py`
   - `tools.py`
   - `.streamlit/`
   - `scripts/`
   - `utils/`
   - `config/`
   - `prompts/`
   - 旧的 `docs/figma_handoff/`
   - 旧的 `README.md`
5. 不允许把旧仓库根的规则文件覆盖当前工作区规则。

## 建议结论

如果后续要继续开发 FreshSalt Surface：

- 当前工作区应继续以本地 `docs/source/baseline_2026-06-14/` 三份基准材料为主。
- `repo_reference/12122` 只能作为“可拆解参考”，不能作为“可继承基线”。
- 若真正进入编码阶段，建议直接在当前工作区新建标准 Flutter 工程，而不是清洗旧仓库后继续沿用。
