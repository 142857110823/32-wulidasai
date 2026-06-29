from __future__ import annotations

import streamlit as st


GITHUB_URL = "https://github.com/142857110823/32-wulidasai"
APP_PATH = "app/freshsalt_surface"


def inject_styles() -> None:
    st.markdown(
        """
        <style>
        .stApp {
            background:
                radial-gradient(circle at top, rgba(183, 228, 220, 0.38), transparent 32%),
                linear-gradient(180deg, #f7fbf9 0%, #edf4f1 100%);
        }

        .block-container {
            max-width: 1080px;
            padding-top: 3rem;
            padding-bottom: 4rem;
        }

        .hero-shell,
        .panel-shell {
            background: rgba(255, 255, 255, 0.9);
            border: 1px solid rgba(20, 58, 48, 0.12);
            border-radius: 28px;
            box-shadow:
                0 24px 60px rgba(15, 53, 43, 0.08),
                0 6px 18px rgba(15, 53, 43, 0.04);
        }

        .hero-shell {
            padding: 44px 42px;
            text-align: center;
            margin-bottom: 22px;
        }

        .eyebrow {
            display: inline-block;
            padding: 8px 14px;
            border-radius: 999px;
            background: rgba(16, 130, 114, 0.10);
            color: #0f6f63;
            font-size: 0.9rem;
            font-weight: 600;
            letter-spacing: 0.02em;
        }

        .hero-title {
            margin: 18px 0 10px;
            color: #18352f;
            font-size: 2.6rem;
            font-weight: 800;
            line-height: 1.16;
            text-wrap: balance;
        }

        .hero-subtitle {
            max-width: 760px;
            margin: 0 auto;
            color: #47635c;
            font-size: 1.05rem;
            line-height: 1.85;
            text-wrap: pretty;
        }

        .panel-shell {
            padding: 28px 28px 24px;
            margin-top: 18px;
        }

        .panel-title {
            margin: 0 0 14px;
            color: #1d312c;
            font-size: 1.25rem;
            font-weight: 750;
            text-align: center;
        }

        .metric-card {
            min-height: 168px;
            padding: 24px 22px;
            border-radius: 22px;
            background: linear-gradient(180deg, #ffffff 0%, #f8fbfa 100%);
            box-shadow:
                inset 0 0 0 1px rgba(14, 45, 37, 0.10),
                0 14px 30px rgba(18, 48, 41, 0.06);
            text-align: center;
        }

        .metric-label {
            color: #60756e;
            font-size: 0.95rem;
            margin-bottom: 14px;
        }

        .metric-value {
            color: #1c2f2a;
            font-size: 2rem;
            font-weight: 800;
            font-variant-numeric: tabular-nums;
            margin-bottom: 10px;
        }

        .metric-note {
            color: #516660;
            font-size: 0.98rem;
            line-height: 1.7;
            text-wrap: pretty;
        }

        .list-shell {
            color: #304640;
            font-size: 1rem;
            line-height: 1.9;
        }

        .list-shell ul {
            margin: 0;
            padding-left: 1.2rem;
        }

        .footer-note {
            text-align: center;
            color: #60756e;
            font-size: 0.95rem;
            margin-top: 14px;
            line-height: 1.8;
            text-wrap: pretty;
        }

        div[data-testid="stHorizontalBlock"] > div {
            align-self: stretch;
        }

        .stButton button,
        .stLinkButton a {
            min-height: 44px;
            border-radius: 999px !important;
            font-weight: 650 !important;
        }
        </style>
        """,
        unsafe_allow_html=True,
    )


def render_metric_card(label: str, value: str, note: str) -> None:
    st.markdown(
        f"""
        <div class="metric-card">
            <div class="metric-label">{label}</div>
            <div class="metric-value">{value}</div>
            <div class="metric-note">{note}</div>
        </div>
        """,
        unsafe_allow_html=True,
    )


def main() -> None:
    st.set_page_config(
        page_title="FreshSalt Surface",
        page_icon="FS",
        layout="centered",
    )

    inject_styles()

    st.markdown(
        """
        <section class="hero-shell">
            <div class="eyebrow">FreshSalt Surface / 平台入口</div>
            <h1 class="hero-title">大学物理竞赛表面盐影像助手</h1>
            <p class="hero-subtitle">
                该页面用于集中展示当前项目的定位、交付状态和代码入口。
                它不是 Android APP 本体，而是一个清晰、稳定的网页说明界面，
                方便在线查看项目进展与后续接手。
            </p>
        </section>
        """,
        unsafe_allow_html=True,
    )

    action_left, action_mid, action_right = st.columns([1, 1, 1])
    with action_left:
        st.link_button("查看 GitHub 仓库", GITHUB_URL, use_container_width=True)
    with action_mid:
        st.link_button(
            "查看 APP 工程目录",
            f"{GITHUB_URL}/tree/main/{APP_PATH}",
            use_container_width=True,
        )
    with action_right:
        st.link_button(
            "查看规划文档",
            f"{GITHUB_URL}/tree/main/docs/planning",
            use_container_width=True,
        )

    st.markdown(
        '<section class="panel-shell"><h2 class="panel-title">项目摘要</h2></section>',
        unsafe_allow_html=True,
    )
    col1, col2, col3 = st.columns(3)
    with col1:
        render_metric_card(
            "平台属性",
            "Android 优先",
            "核心主体为 Flutter APP，当前网页仅承担在线展示与入口说明。",
        )
    with col2:
        render_metric_card(
            "当前阶段",
            "原型推进",
            "围绕受控成像、ROI 质控、结果展示与后续实验接入持续完善。",
        )
    with col3:
        render_metric_card(
            "数据状态",
            "阶段验证",
            "当前仍以阶段性验证材料和原型结果为主，不输出执法或食品安全结论。",
        )

    st.markdown(
        """
        <section class="panel-shell">
            <h2 class="panel-title">平台说明</h2>
            <div class="list-shell">
                <ul>
                    <li>项目聚焦受控 RGB 成像、灰卡与 ROI 质控、半物理 / 灰箱模型，以及后续真实实验接入。</li>
                    <li>线上展示页只保留必要说明，不再堆砌零散按钮和低质量状态块。</li>
                    <li>代码主目录位于 <code>app/freshsalt_surface</code>，可在 GitHub 中继续查看和维护。</li>
                </ul>
            </div>
        </section>
        """,
        unsafe_allow_html=True,
    )

    st.markdown(
        """
        <section class="panel-shell">
            <h2 class="panel-title">本地运行方式</h2>
            <div class="list-shell">
                <ul>
                    <li>Web 预览：<code>flutter build web</code> 或 <code>flutter run -d chrome</code></li>
                    <li>Android 调试：<code>flutter devices</code> 后执行 <code>flutter run -d &lt;android-device-id&gt;</code></li>
                    <li>本页面部署入口文件：<code>streamlit_app.py</code></li>
                </ul>
            </div>
            <div class="footer-note">
                当前网页用于项目展示与信息汇总，不替代移动端 APP 的真实交互能力。
            </div>
        </section>
        """,
        unsafe_allow_html=True,
    )

    st.info(
        "边界说明：本项目不输出食品安全结论、执法性质判断或未经真实实验验证的强结论。"
    )


if __name__ == "__main__":
    main()
