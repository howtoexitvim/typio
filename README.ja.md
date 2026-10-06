<div align="center">

# Typio

[English](README.md) · [简体中文](README.zh-CN.md) · [日本語](README.ja.md) · [한국어](README.ko.md)

![Platform](https://img.shields.io/badge/platform-macOS-111827?logo=apple&logoColor=white)
![Input Method](https://img.shields.io/badge/type-English%20IME-2563eb)
![Architecture](https://img.shields.io/badge/architecture-local--first-059669)
[![Sponsor](https://img.shields.io/badge/sponsor-Support%20Typio-ea580c?logo=githubsponsors&logoColor=white)](https://www.shuqihere.top/archive/projects/typio)

</div>

Typio は、英語を母語としないユーザー向けの macOS 用 English IME です。

毎日英語を書く中で、スペル、語彙選択、入力方式の切り替えによって思考の流れが途切れてしまう人のために設計されています。

Typio は、完全な中国語 IME 的な挙動ではなく、英語優先でクリーンな入力体験を求める韓国語・日本語・中国語ユーザーに特に適しています。

Typio は local-first を徹底しています。クラウド依存なし、サインイン不要、余計なノイズなし。入力を続けるだけで、Typio が実用的な候補を提示します。

Typio は「typo の終わり」を意味します。

## Typio を選ぶ理由

- ✍️ **入力フローを維持**：候補がその場で更新され、作業を止めません。
- 🧠 **実用的な候補提示**：高頻度の英語表現に最適化。
- 🧩 **柔軟なパネル表示**：横並び・グリッド（複数行）・縦並びに対応。
- 🔒 **プライバシー重視**：入力処理はすべてローカルで完結。

## スクリーンショット

<div align="center">
  <img src="resources/images/readme/demo.gif" width="66.66666%" alt="Demo">
</div>

<br/>

<table>
	<tr>
		<td align="center"><strong>入力ソースメニュー</strong></td>
		<td align="center"><strong>言語モード切り替え</strong></td>
	</tr>
	<tr>
		<td align="center"><img src="resources/images/readme/typio-menu-entry.png" alt="Typio 入力ソースメニュー" height="240" /></td>
		<td align="center"><img src="resources/images/readme/typio-language-toggle.png" alt="Typio 言語モード切り替え" height="240" /></td>
	</tr>
	<tr>
		<td align="center"><strong>複数行候補パネル</strong></td>
		<td align="center"><strong>設定：候補パネルスタイル</strong></td>
	</tr>
	<tr>
		<td align="center"><img src="resources/images/readme/typio-candidate-grid.png" alt="Typio 複数行候補パネル" height="240" /></td>
		<td align="center"><img src="resources/images/readme/typio-settings-panel-style.png" alt="Typio パネルスタイル設定" height="240" /></td>
	</tr>
</table>

## インストール

一般ユーザーは `Typio-<version>.pkg` をダウンロードして実行し、システム設定の「キーボード → 入力ソース」で Typio を有効化してください。

<div align="center">
  <img src="resources/images/readme/install-guide-1.png" alt="Allow applications from App Store & Known Developers" height="300" />
      
  <img src="resources/images/readme/install-guide-2.png" alt="Open typio-1.0.pkg anyway" height="300" />
</div>

Typio 1.1.2 は元の単一入力ソース構成に戻し、メニューバーとインライン切替で、T をくり抜いた円形アイコンを使用します。色は外観と選択状態に応じてシステムが調整します。1.1.1 の入力モード構成は、その後の再起動で切替の問題が生じたため削除しました。

1.1.1 から更新する場合は、古い Typio を入力ソースから削除して再追加してください。古い項目やアイコンが残る場合は、ログアウト後に再ログインするか、macOS を再起動してください。

## ビルドとパッケージ

`bash scripts/build.sh` でビルド、`bash scripts/build-and-install.sh` でローカル開発用インストール、`bash scripts/package-pkg.sh` で `dist/Typio-<version>.pkg` を生成します。

インストーラ署名が必要な場合は、パッケージ化前に `INSTALLER_SIGN_IDENTITY` を設定してください。

## Typio を支援する

Typio はコミュニティのために作られています。もし役に立つと感じたら、私の[個人ブログ](https://www.shuqihere.top/archive/projects/typio)での開発支援をご検討ください。

## プロジェクト

Project home: https://github.com/howtoexitvim/Typio

## License and credits

Typio is a modified version of [HallelujahIM](https://github.com/dongyuwei/hallelujahIM) by Dong Yuwei and contributors, released under [GNU GPL v3](LICENSE). Typio modifications by Shuqi Wang, 2026, include the local-only engine, native settings, candidate panel layouts, branding, input-source icons, and installation flow.

See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for dependency licenses and dictionary provenance, and [BUILDING.md](BUILDING.md) for building from source.
