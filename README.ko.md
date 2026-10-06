<div align="center">

# Typio

[English](README.md) · [简体中文](README.zh-CN.md) · [日本語](README.ja.md) · [한국어](README.ko.md)

![Platform](https://img.shields.io/badge/platform-macOS-111827?logo=apple&logoColor=white)
![Input Method](https://img.shields.io/badge/type-English%20IME-2563eb)
![Architecture](https://img.shields.io/badge/architecture-local--first-059669)
[![Sponsor](https://img.shields.io/badge/sponsor-Support%20Typio-ea580c?logo=githubsponsors&logoColor=white)](https://www.shuqihere.top/archive/projects/typio)

</div>

Typio는 비원어민 사용자를 위한 macOS 영어 입력기(English IME)입니다.

매일 영어로 글을 쓰지만, 철자·단어 선택·입력 방식 전환 때문에 흐름이 끊기는 사용자를 위해 설계되었습니다.

Typio는 완전한 중국어 IME 동작보다, 영어 우선의 깔끔한 타이핑 경험을 원하는 한국어·일본어·중국어 사용자에게 특히 유용합니다.

Typio는 local-first 원칙을 따릅니다. 클라우드 의존 없음, 로그인 없음, 불필요한 방해 없음. 계속 입력하면 Typio가 실용적인 후보를 제안합니다.

Typio는 typo의 끝을 의미합니다.

## Typio를 선택하는 이유

- ✍️ **입력 흐름 유지**: 입력을 멈추지 않고 후보가 즉시 갱신됩니다.
- 🧠 **실용적인 후보 제안**: 자주 쓰는 영어 표현에 맞춰 설계되었습니다.
- 🧩 **유연한 패널 스타일**: 가로형, 그리드(다중 행), 세로형을 지원합니다.
- 🔒 **기본 프라이버시 중심**: 입력 처리는 모두 로컬에서 완료됩니다.

## 스크린샷

<div align="center">
  <img src="resources/images/readme/demo.gif" width="66.66666%" alt="Demo">
</div>

<br/>

<table>
	<tr>
		<td align="center"><strong>입력 소스 메뉴</strong></td>
		<td align="center"><strong>언어 모드 전환</strong></td>
	</tr>
	<tr>
		<td align="center"><img src="resources/images/readme/typio-menu-entry.png" alt="Typio 입력 소스 메뉴" height="240" /></td>
		<td align="center"><img src="resources/images/readme/typio-language-toggle.png" alt="Typio 언어 모드 전환" height="240" /></td>
	</tr>
	<tr>
		<td align="center"><strong>다중 행 후보 패널</strong></td>
		<td align="center"><strong>설정: 후보 패널 스타일</strong></td>
	</tr>
	<tr>
		<td align="center"><img src="resources/images/readme/typio-candidate-grid.png" alt="Typio 다중 행 후보 패널" height="240" /></td>
		<td align="center"><img src="resources/images/readme/typio-settings-panel-style.png" alt="Typio 패널 스타일 설정" height="240" /></td>
	</tr>
</table>

## 설치

일반 사용자는 `Typio-<version>.pkg`를 다운로드해 실행한 뒤, 시스템 설정의 "키보드 → 입력 소스"에서 Typio를 활성화하세요.

<div align="center">
  <img src="resources/images/readme/install-guide-1.png" alt="Allow applications from App Store & Known Developers" height="300" />
      
  <img src="resources/images/readme/install-guide-2.png" alt="Open typio-1.0.pkg anyway" height="300" />
</div>

Typio 1.1.2는 원래의 단일 입력 소스 구성으로 돌아가며, 메뉴 막대와 인라인 전환기에 T 모양을 뚫은 원형 아이콘을 사용합니다. 색상은 시스템 모양과 선택 상태에 따라 조정됩니다. 1.1.1의 입력 모드 구성은 이후 재시동에서 전환 문제가 확인되어 제거했습니다.

1.1.1에서 업데이트할 때는 입력 소스에서 기존 Typio를 제거하고 다시 추가하세요. 이전 항목이나 아이콘이 남아 있으면 로그아웃 후 다시 로그인하거나 macOS를 재시동하세요.

## 빌드 및 패키징

`bash scripts/build.sh`로 앱을 빌드하고, `bash scripts/build-and-install.sh`로 로컬 개발 설치를 진행하며, `bash scripts/package-pkg.sh`로 `dist/Typio-<version>.pkg` 설치 패키지를 생성합니다.

설치 패키지 서명이 필요하면 패키징 전에 `INSTALLER_SIGN_IDENTITY`를 설정하세요.

## Typio 후원

Typio는 커뮤니티를 위해 제작되었습니다. 이 프로젝트가 유용하다면 제 [개인 블로그](https://www.shuqihere.top/archive/projects/typio)에서 개발을 후원해 주시면 감사하겠습니다.

## 프로젝트

Project home: https://github.com/howtoexitvim/Typio

## License and credits

Typio is a modified version of [HallelujahIM](https://github.com/dongyuwei/hallelujahIM) by Dong Yuwei and contributors, released under [GNU GPL v3](LICENSE). Typio modifications by Shuqi Wang, 2026, include the local-only engine, native settings, candidate panel layouts, branding, input-source icons, and installation flow.

See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for dependency licenses and dictionary provenance, and [BUILDING.md](BUILDING.md) for building from source.
