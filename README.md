# 32-wulidasai

FreshSalt Surface / 表面盐影像助手，大学物理竞赛 Android 优先 Flutter APP 原型。

## 主入口

真实在线 APP 入口：

- GitHub Pages: `https://142857110823.github.io/32-wulidasai/`

说明：

- 该地址承载的是 `app/freshsalt_surface` 的 Flutter Web 构建产物。
- 后续线上可见更新应以 Flutter Web 页面为准，而不是 Streamlit 页面。

## Flutter App

Flutter 工程位于：

```text
app/freshsalt_surface
```

本地常用命令：

```bash
cd app/freshsalt_surface
flutter pub get
flutter build web --release --base-href /32-wulidasai/
flutter run -d <android-device-id>
```

## GitHub Pages 部署

仓库已改为通过 GitHub Actions 自动构建并发布 Flutter Web：

- Workflow: `.github/workflows/deploy-flutter-web.yml`
- 发布分支来源：`main`
- 发布产物目录：`app/freshsalt_surface/build/web`
- Pages 路径前缀：`/32-wulidasai/`

为保证静态托管下的单页路由刷新可用，部署时会额外生成 `404.html` 作为同壳回退页。

## Streamlit 旧入口

当前仓库仍保留一个最小 Streamlit 页面，但它只用于迁移说明，不再承担产品页角色。

部署配置：

- Repository: `142857110823/32-wulidasai`
- Branch: `main`
- Main file path: `streamlit_app.py`

说明：

- Streamlit 页面只显示“真实 APP 已迁移”及新入口按钮。
- 不再使用 Streamlit 承载 APP 本体，因为该项目的真实交互、路由和页面状态都在 Flutter APP / Flutter Web 中。
