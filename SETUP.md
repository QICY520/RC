# Flutter 项目运行指南 (Windows)

由于您的电脑从未配置过 Flutter 环境，请按照以下步骤进行从零配置。

## 1. 安装 Flutter SDK

1.  **下载 SDK**：
    *   访问 [Flutter 官网安装页面](https://docs.flutter.dev/get-started/install/windows)。
    *   下载最新的 **Stable Channel** (Windows) 压缩包。

2.  **解压**：
    *   将压缩包解压到一个路径简单且**不包含特殊字符或中文**的目录。
    *   推荐目录：`C:\src\flutter` 或 `D:\src\flutter`（**任意盘符均可**）。
    *   *重要原则：*
        1.  **路径不能太深**（避免 Windows 长路径限制）。
        2.  **路径不能包含特殊字符、中文或空格**（例如不要装在 `Program Files` 或 `User/张三` 下）。
        3.  **不要使用需要管理员权限的文件夹**。

3.  **配置环境变量 (Path)**：
    *   在 Windows 搜索栏输入 “编辑系统环境变量”。
    *   点击“环境变量”。
    *   在“用户变量”一栏中找到 `Path`，选中并点击“编辑”。
    *   点击“新建”，输入你解压后的 `bin` 目录路径（例如 `C:\src\flutter\bin`）。
    *   一路点击“确定”保存。
    *   *小知识：配置在“用户变量”比较安全，只会影响当前登录的用户。如果您希望所有用户都能用，也可以配置在“系统变量”中，但那需要管理员权限。*

## 2. 检查环境

1.  打开一个新的 PowerShell 或 CMD 窗口（确保环境变量生效）。
2.  运行命令：
    ```powershell
    flutter doctor
    ```
3.  它会列出你当前环境的缺失项。通常你需要关注以下两点之一（取决于你想运行在这个项目的哪个平台上）：

    *   **方案 A (推荐新手)：运行在 Windows 桌面端**
        *   需要安装 **Visual Studio 2022** (注意不是 VS Code)。
        *   下载 Visual Studio Installer，安装时勾选 **“使用 C++ 的桌面开发”** 工作负载。

    *   **方案 B：运行在 Android 模拟器/真机**
        *   需要安装 **Android Studio**。
        *   安装后打开 Android Studio，进入 SDK Manager 安装 Android SDK Command-line Tools。
        *   同意许可证：运行 `flutter doctor --android-licenses` 并一路输入 `y`。

## 3. 配置开发工具 (VS Code)

既然您已经在使用 IDE，建议安装以下插件以获得最佳体验：
*   **Flutter** (Dart 插件会自动随之安装)

## 4. 运行本项目

1.  **安装依赖**：
    在项目根目录（包含 `pubspec.yaml` 的文件夹）打开终端，运行：
    ```powershell
    flutter pub get
    ```

2.  **启动项目**：
    *   确保你的设备已连接（运行 `flutter devices` 查看）。
        *   如果是 Windows 开发，如果不显示 windows，可能需要运行 `flutter config --enable-windows-desktop`。
    *   运行：
    ```powershell
    flutter run
    ```
    *   或者在 VS Code 中按下 `F5` 调试运行。

---

## 常见问题
*   **网络问题**：如果下载依赖慢，可以在环境变量中配置国内镜像：
    *   `PUB_HOSTED_URL` = `https://pub.flutter-io.cn`
    *   `FLUTTER_STORAGE_BASE_URL` = `https://storage.flutter-io.cn`
