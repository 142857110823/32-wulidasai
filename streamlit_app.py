from __future__ import annotations

import streamlit as st


GITHUB_URL = "https://github.com/142857110823/32-wulidasai"


def main() -> None:
    st.set_page_config(
        page_title="FreshSalt Surface",
        page_icon="FS",
        layout="centered",
    )

    st.title("FreshSalt Surface / 表面盐影像助手")
    st.caption("大学物理竞赛 Android 优先 Flutter APP 原型")

    st.info(
        "当前 Streamlit 页面是部署展示入口，不替代 Flutter Android APP 主体。"
        "核心 APP 工程位于 app/freshsalt_surface。"
    )

    st.subheader("项目定位")
    st.write(
        "FreshSalt Surface 面向受控 RGB 成像、灰卡与 ROI 质控、"
        "半物理 / 灰箱模型和模拟数据验证。当前阶段优先验证 APP 点击闭环，"
        "后续再接入真实实验数据。"
    )

    st.subheader("当前交付状态")
    st.markdown(
        """
        - Flutter Android 原型已提交到 GitHub。
        - 当前结果与历史记录仍以“模拟数据”作为阶段性验证材料。
        - Android debug APK 已在本地通过 ASCII 路径构建验证。
        - 真实 Android 设备运行仍需要连接手机或模拟器后再执行。
        """
    )

    st.subheader("Android 测试入口")
    st.code(
        "cd app/freshsalt_surface\n"
        "flutter devices\n"
        "flutter run -d <android-device-id>",
        language="bash",
    )

    st.subheader("Streamlit Cloud 设置")
    st.write("部署时主文件路径填写：")
    st.code("streamlit_app.py", language="text")

    st.link_button("打开 GitHub 仓库", GITHUB_URL)

    st.warning(
        "边界说明：本项目不输出食品安全或执法性质结论；"
        "当前展示不代表真实实验验证结果。"
    )


if __name__ == "__main__":
    main()
