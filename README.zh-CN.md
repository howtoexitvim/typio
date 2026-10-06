<div align="center">

# Typio

[English](README.md) · [简体中文](README.zh-CN.md) · [日本語](README.ja.md) · [한국어](README.ko.md)

![Platform](https://img.shields.io/badge/platform-macOS-111827?logo=apple&logoColor=white)
![输入法类型](https://img.shields.io/badge/type-English%20IME-2563eb)
![架构](https://img.shields.io/badge/architecture-local--first-059669)
[![Sponsor](https://img.shields.io/badge/sponsor-Support%20Typio-ea580c?logo=githubsponsors&logoColor=white)](https://www.shuqihere.top/archive/projects/typio)

</div>

Typio 是一个面向非母语用户的 macOS 英文输入法（English IME）。

它服务于每天都要写英文、但经常在拼写、词语选择或输入法切换上打断思路的用户。

Typio 特别适合韩语、日语、中文用户：你可以获得更干净的英文优先输入体验，而不是完整中文 IME 的交互逻辑。

Typio 坚持 local-first：不依赖云端、无需登录、没有额外干扰。你持续输入，Typio 提供实用候选，你保持写作节奏。

Typio，意为 typo 的终点。

## 为什么选择 Typio

- ✍️ **保持输入流**：候选实时更新，不打断写作。
- 🧠 **实用候选**：面向高频英文表达场景。
- 🧩 **面板样式可选**：支持横向、网格（多行）、纵向布局。
- 🔒 **默认隐私友好**：输入处理全部在本地完成。

## 截图

<div align="center">
  <img src="resources/images/readme/demo.gif" width="66.66666%" alt="Demo">
</div>

<br/>

<table>
	<tr>
		<td align="center"><strong>输入源菜单</strong></td>
		<td align="center"><strong>语言模式切换</strong></td>
	</tr>
	<tr>
		<td align="center"><img src="resources/images/readme/typio-menu-entry.png" alt="Typio 输入源菜单" height="240" /></td>
		<td align="center"><img src="resources/images/readme/typio-language-toggle.png" alt="Typio 语言切换" height="240" /></td>
	</tr>
	<tr>
		<td align="center"><strong>多行候选面板</strong></td>
		<td align="center"><strong>设置：候选面板样式</strong></td>
	</tr>
	<tr>
		<td align="center"><img src="resources/images/readme/typio-candidate-grid.png" alt="Typio 多行候选" height="240" /></td>
		<td align="center"><img src="resources/images/readme/typio-settings-panel-style.png" alt="Typio 面板样式设置" height="240" /></td>
	</tr>
</table>

## 安装

对于普通用户，请下载并运行 `Typio-<version>.pkg`，然后在“系统设置 → 键盘 → 输入法”中启用 Typio。

<div align="center">
  <img src="resources/images/readme/install-guide-1.png" alt="Allow applications from App Store & Known Developers" height="300" />
      
  <img src="resources/images/readme/install-guide-2.png" alt="Open typio-1.0.pkg anyway" height="300" />
</div>

Typio 1.1.2 恢复原来的单输入源结构，菜单栏和行内切换器统一使用圆形底、内部镂空 T 的图标，颜色由系统根据外观和选中状态调整。1.1.1 的 input mode 配置在后续重启中暴露了切换问题，已移除。

从 1.1.1 更新时，请在输入法列表中移除旧 Typio，再添加 Typio。若旧条目或图标仍未刷新，请注销并重新登录或重启 macOS。

## 构建与打包

使用 `bash scripts/build.sh` 构建应用，`bash scripts/build-and-install.sh` 用于本地开发安装，`bash scripts/package-pkg.sh` 生成安装包 `dist/Typio-<version>.pkg`。

如果需要安装包签名，请在打包前设置 `INSTALLER_SIGN_IDENTITY`。

## 支持 Typio

Typio 是为社区构建的。如果您觉得它有帮助，请考虑在我的[个人博客](https://www.shuqihere.top/archive/projects/typio)上支持它的开发。

## 项目

项目主页：https://github.com/howtoexitvim/Typio

## License and credits

Typio is a modified version of [HallelujahIM](https://github.com/dongyuwei/hallelujahIM) by Dong Yuwei and contributors, released under [GNU GPL v3](LICENSE). Typio modifications by Shuqi Wang, 2026, include the local-only engine, native settings, candidate panel layouts, branding, input-source icons, and installation flow.

See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for dependency licenses and dictionary provenance, and [BUILDING.md](BUILDING.md) for building from source.
