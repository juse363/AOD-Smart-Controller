# AOD Smart Controller 0.2.0 — 研发说明

## 本版方向
- 采用 GestaltX 的能力清单/配置分层设计思路，独立实现，不复制 GPL-3.0-or-later 源码。
- 保留 0.1.0 的接近、CoreMotion、模拟环境光和决策状态机。
- 新增只读设备能力盘点与系统联动边界层。
- 系统联动层目前明确返回 unsupported，不伪装成已经关闭原生 AOD。

## 安全与平台边界
- 不修改 MobileGestalt 缓存、不调用私有 SpringBoard API。
- 设备能力标记不等于硬件能力；iPhone 13 Pro Max 不会因修改软件标记获得 iPhone 14 Pro 的 1Hz LTPO AOD 硬件。
- 普通 App 没有通用公开 lux 读取接口；环境光仍是模拟输入。
- iOS 可能在后台挂起普通 App，传感器持续监听不作保证。
- AODSystemBridge 是明确的适配边界，不代表已实现系统 AOD 开关。

## 验收目标
1. App 可正常启动并显示设备/系统诊断信息。
2. 传感器状态仍能驱动内部决策状态。
3. 系统 AOD 状态始终标记为“未受本 App 控制”，避免误导。
4. GitHub Actions 编译通过后，再由用户在设备上进行实际测试。
