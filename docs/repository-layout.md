# Repository layout / 仓库目录

```text
src/DaFeiYi/   Application source, grouped by feature / 按功能分类的程序源码
tests/         Self tests, UI, integration and manual live checks / 分类测试
scripts/       Build, package, install and asset tools / 构建、打包、安装和资源工具
Assets/        Whale artwork and reading resources / 肥鱼及阅读资源
Libraries/     Bundled third-party dependencies and notices / 第三方依赖及声明
docs/          User guides, screenshots and development notes / 使用指南与开发记录
.github/       GitHub issue templates / GitHub 问题模板
build.ps1      Compatible build entry point / 原有构建命令入口
verify.ps1     Compatible verification entry point / 原有验证命令入口
```

Source modules / 源码模块：App, Capture, Companion, Core, Platform, Reading, Rendering, Terms, Translation, UI, Website

`src/DaFeiYi/app.config`, `app.manifest` and `app.ico` hold Windows application configuration, DPI/access settings and the application icon. Source filenames and the `LightTranslate` namespace are retained. The Windows package keeps its existing executable, Assets and Libraries layout.

程序配置、Windows 清单和图标位于 `src/DaFeiYi/`。文件分类不改变命名空间或程序的发行包布局。根目录保留 README、许可证、安全说明、依赖声明和两个兼容入口。

## Build and package / 构建与打包

Run from the repository root on Windows with .NET Framework 4.8:

```powershell
.\build.ps1 -Test -OutputDirectory .\outputs\build
.\scripts\package.ps1 -OutputDirectory .\outputs\release-package
```

`package.ps1` builds a fresh package, adds installers and licensing files, and writes a SHA-256 manifest. Its output directory must be new or empty. It copies an explicit set of program files; test reports, local settings, keys, browser profiles and history are excluded.

`package.ps1` 生成完整发行目录及文件校验清单，不直接上传。输出目录必须新建或为空；只复制指定程序文件，不包含测试报告、个人配置、Key、浏览器登录或历史。安装工具源码位于 `scripts/install/`，打包后仍放在发行目录根部。

## Tests / 测试

- `tests/SelfTest/`: `--self-test`; deterministic checks plus local HTTP/Windows integration checks.
- `tests/UI/`: WPF controls and native window interactions; run on an interactive Windows desktop.
- `tests/Integration/`: update, runtime, website bridge and process integration fixtures.
- `tests/ManualLive/`: explicitly requested real-service checks; excluded from automatic verification.

The CLI checks are compiled alongside the app because its existing test entry points reference them. This reorganization preserves those entry points. Test mode uses isolated fixtures; it does not load a user's normal settings or browser profile.

命令行测试入口仍与程序一起编译。自动检查使用隔离数据及本地假服务；真实服务测试须明确调用。完整本机检查仍可运行 `verify.ps1`，UI 检查需要可交互 Windows 桌面。