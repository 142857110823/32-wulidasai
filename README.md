# 32-wulidasai

FreshSalt Surface / 表面盐影像助手，大学物理竞赛 Android 优先 Flutter APP 原型。

## Streamlit Cloud

当前仓库提供一个最小 Streamlit 展示入口，便于在 Streamlit Cloud 上部署项目说明页。

部署配置：

- Repository: `142857110823/32-wulidasai`
- Branch: `main`
- Main file path: `streamlit_app.py`

说明：Streamlit 页面只是部署展示壳，不替代 Flutter Android APP 主体。

## Flutter App

Flutter 工程位于：

```text
app/freshsalt_surface
```

Android 测试入口：

```bash
cd app/freshsalt_surface
flutter devices
flutter run -d <android-device-id>
```
