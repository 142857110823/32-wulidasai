from __future__ import annotations

import streamlit as st


FLUTTER_WEB_URL = "https://142857110823.github.io/32-wulidasai/"
GITHUB_URL = "https://github.com/142857110823/32-wulidasai"


def inject_styles() -> None:
    st.markdown(
        """
        <style>
        .stApp {
            background:
                radial-gradient(circle at top, rgba(178, 223, 216, 0.34), transparent 34%),
                linear-gradient(180deg, #f7fbf9 0%, #eef5f2 100%);
        }

        .block-container {
            max-width: 760px;
            padding-top: 4rem;
            padding-bottom: 4rem;
        }

        .migration-card {
            background: rgba(255, 255, 255, 0.92);
            border: 1px solid rgba(19, 60, 50, 0.12);
            border-radius: 30px;
            box-shadow:
                0 24px 60px rgba(16, 53, 44, 0.08),
                0 6px 16px rgba(16, 53, 44, 0.04);
            padding: 44px 38px;
            text-align: center;
        }

        .eyebrow {
            display: inline-block;
            padding: 8px 14px;
            border-radius: 999px;
            background: rgba(15, 118, 110, 0.10);
            color: #0f6f63;
            font-size: 0.92rem;
            font-weight: 650;
        }

        .title {
            margin: 18px 0 12px;
            color: #17352f;
            font-size: 2.4rem;
            line-height: 1.14;
            font-weight: 800;
        }

        .body-text {
            margin: 0 auto;
            max-width: 560px;
            color: #45635b;
            font-size: 1rem;
            line-height: 1.85;
        }

        .link-note {
            margin-top: 18px;
            color: #60756e;
            font-size: 0.94rem;
            line-height: 1.7;
        }

        .stLinkButton a {
            min-height: 46px;
            border-radius: 999px !important;
            font-weight: 650 !important;
        }
        </style>
        """,
        unsafe_allow_html=True,
    )


def main() -> None:
    st.set_page_config(
        page_title="FreshSalt Surface 迁移说明",
        page_icon="FS",
        layout="centered",
    )
    inject_styles()

    st.markdown(
        """
        <section class="migration-card">
            <div class="eyebrow">FreshSalt Surface / 入口迁移</div>
            <h1 class="title">真实 APP 已切换到 Flutter Web</h1>
            <p class="body-text">
                当前 Streamlit 页面不再承担产品展示职责。
                FreshSalt Surface 的在线主入口已经迁移到真实 Flutter Web 版本，
                后续可见更新将以该入口为准。
            </p>
        </section>
        """,
        unsafe_allow_html=True,
    )

    col1, col2 = st.columns(2)
    with col1:
        st.link_button("打开真实 APP", FLUTTER_WEB_URL, use_container_width=True)
    with col2:
        st.link_button("查看 GitHub 仓库", GITHUB_URL, use_container_width=True)

    st.markdown(
        """
        <p class="link-note">
            若新入口暂时未刷新，请等待 GitHub Pages 完成最新部署后再访问。
        </p>
        """,
        unsafe_allow_html=True,
    )


if __name__ == "__main__":
    main()
