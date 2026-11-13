# AOD Smart Controller 0.2.1 — 签名与 App Group 诊断版

## 本版新增
- 新增 App Group 容器诊断卡片。
- 使用 `FileManager.containerURL(forSecurityApplicationGroupIdentifier:)` 检查当前签名是否可访问候选共享容器。
- 若容器可用，在容器内创建、读取并删除唯一临时文件，验证实际读写能力。
- 保留 0.2.0 的传感器监测、决策算法和系统能力只读诊断。

## 重要签名说明
候选 Group ID 为 `group.com.aodsmart.controller`。**字符串本身不会授予权限**；它必须与签名后的应用实际获得的 App Groups entitlement 完全一致。此诊断版刻意不在 Xcode 项目中强行添加未经确认的 entitlement，以免造成 iLoader 重签名失败或安装异常。

如果检测显示“不可访问”，请先检查 iLoader 的签名/配置文件能力；不要通过修改系统文件来绕过权限检测。

## 安全边界
- 不包含 worse_query / bad_query PoC 代码。
- 不访问或修改 MobileGestalt、SpringBoard、系统容器或系统配置。
- App Group 检测成功仅证明共享容器可访问，不等于获得 MobileGestalt 或原生 AOD 控制权限。
- iPhone 13 Pro Max 不具备 iPhone 14 Pro 的 1Hz LTPO AOD 显示硬件；软件能力标记不能改变硬件。
- 普通 IPA 没有公开通用 API 控制 SpringBoard 原生 AOD；后台传感器运行也不作保证。

## 构建
GitHub Actions 在 macOS runner 上使用 XcodeGen 和 Xcode 构建未签名 IPA。下载 artifact 后，需使用 iLoader 按其当前签名流程签名安装。未签名 IPA 不能直接安装。
