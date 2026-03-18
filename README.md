# 小红书数据抓取工具

一个基于 Flutter 的 Android 自动化应用，可以从剪贴板提取小红书链接，自动抓取笔记数据。

## 功能特点

- 📋 从剪贴板智能提取小红书链接
- 🔗 支持主域名和短链接
- 📊 自动抓取：点赞、评论、收藏、粉丝数
- 📝 标准化格式输出
- 📋 一键复制结果

## 安装使用

### 方法1：下载APK（推荐）

从 GitHub Actions 构建产物下载：
- [Debug版APK](https://github.com/LYY1553523602/cc-switch-minimax-auto/actions/workflows/build.yml)

### 方法2：本地开发

```bash
# 1. 克隆项目
git clone https://github.com/LYY1553523602/cc-switch-minimax-auto.git
cd cc-switch-minimax-auto

# 2. 安装Flutter
# 参考: https://flutter.dev/docs/get-started/install

# 3. 获取依赖
flutter pub get

# 4. 运行调试
flutter run
```

### 方法3：打包APK

```bash
# Debug版
flutter build apk --debug

# Release版
flutter build apk --release
```

## 使用流程

1. 复制包含小红书链接的文本
2. 打开应用，点击"粘贴剪贴板链接"
3. 预览提取到的链接
4. 点击"开始抓取"
5. 等待自动抓取完成
6. 点击"一键复制结果"

## 输出格式

```
【转发:0 评论:86 点赞:81】（粉丝量：9万）
```

## 权限说明

首次使用需要授予以下权限：
- **无障碍服务**：必须授权（用于自动化操作）
- **存储权限**：保存历史记录

## 项目结构

```
cc-switch-minimax-auto/
├── lib/
│   ├── main.dart                    # 主入口
│   ├── models/
│   │   └── crawl_result.dart       # 数据模型
│   ├── services/
│   │   ├── link_extractor_service.dart  # 链接提取
│   │   └── crawl_service.dart       # 爬虫服务
│   └── screens/
│       └── home_screen.dart         # 主界面
├── android/
│   └── app/src/main/
│       ├── kotlin/                  # 原生Android代码
│       │   ├── MainActivity.kt
│       │   └── CrawlAccessibilityService.kt
│       └── AndroidManifest.xml
├── .github/workflows/
│   └── build.yml                    # GitHub自动构建
└── pubspec.yaml                     # 项目配置
```

## GitHub自动构建

推送到 main 分支后，GitHub Actions 会自动构建 APK：
1. 进入项目的 Actions 页面
2. 查看最新的构建任务
3. 下载生成的 APK 文件

## 注意事项

1. 需要保持小红书 App 在后台运行
2. 建议使用稳定的网络环境
3. 避免频繁操作以防账号受限
4. 仅用于学习研究，请勿滥用

## 技术栈

- **前端**: Flutter
- **自动化**: Android AccessibilityService
- **构建**: GitHub Actions

## License

MIT
