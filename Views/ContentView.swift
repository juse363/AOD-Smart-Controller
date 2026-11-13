import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var proximity: ProximityMonitor
    @EnvironmentObject private var motion: MotionMonitor
    @EnvironmentObject private var engine: AODDecisionEngine
    @EnvironmentObject private var systemInspector: SystemCapabilityInspector
    @StateObject private var appGroupDiagnostics = AppGroupDiagnostics()

    private let maxContentWidth: CGFloat = 1120

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let isWide = geometry.size.width >= 760
                let sideInset: CGFloat = isWide ? 28 : 18
                let columns = Array(
                    repeating: GridItem(.flexible(), spacing: 16, alignment: .top),
                    count: isWide ? 2 : 1
                )

                ScrollView {
                    VStack(spacing: 18) {
                        heroSection
                        statusOverview

                        LazyVGrid(columns: columns, alignment: .center, spacing: 16) {
                            capabilityCard
                            appGroupCard
                            sensorCard
                            algorithmCard
                            futureFeaturesCard
                            limitationCard
                        }
                    }
                    .padding(.horizontal, sideInset)
                    .padding(.top, 18)
                    .padding(.bottom, 36)
                    .frame(maxWidth: maxContentWidth)
                    .frame(maxWidth: .infinity)
                }
                .background {
                    ZStack {
                        Color(uiColor: .systemBackground)
                        LinearGradient(
                            colors: [
                                Color.blue.opacity(0.13),
                                Color.purple.opacity(0.08),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .ignoresSafeArea()
                    }
                }
            }
            .navigationTitle("NEXUS")
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(.dark)
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("NEXUS 灵枢工作台")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .minimumScaleFactor(0.78)
                        .lineLimit(1)
                    Text("连接 · 智能 · 掌控未来")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 8)
                Text("0.4.2")
                    .font(.caption.weight(.bold))
                    .monospacedDigit()
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.blue.opacity(0.2), in: Capsule())
                    .overlay(Capsule().strokeBorder(.white.opacity(0.16)))
            }

            HStack(spacing: 10) {
                Image(systemName: "iphone.gen3")
                    .font(.title2)
                    .foregroundStyle(.cyan)
                VStack(alignment: .leading, spacing: 3) {
                    Text("设备已识别")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(systemInspector.deviceIdentifier)
                        .font(.headline.monospaced())
                }
                Spacer()
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundStyle(.purple)
            }
            .padding(14)
            .glassCard(cornerRadius: 20)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var statusOverview: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(statusTint.opacity(0.16))
                    .frame(width: 54, height: 54)
                Image(systemName: "waveform.path.ecg")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(statusTint)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("当前算法状态")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(engine.state.rawValue)
                    .font(.title3.bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(engine.reason)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
            Circle()
                .fill(statusTint)
                .frame(width: 9, height: 9)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(cornerRadius: 24)
        .accessibilityElement(children: .combine)
    }

    private var statusTint: Color {
        proximity.isCovered ? .orange : .cyan
    }

    private var capabilityCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            cardHeading("系统能力", subtitle: "设备与原生接口", icon: "cpu")
            infoRow("设备标识", systemInspector.deviceIdentifier)
            infoRow("iOS 版本", systemInspector.systemVersion)
            infoRow("设备能力", systemInspector.summary)
            infoRow("原生 AOD", systemInspector.aodControlStatus)
            noteText("只读诊断：不会修改 MobileGestalt，也不会伪装硬件能力。", tint: .orange)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }

    private var appGroupCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            cardHeading("签名与权限", subtitle: "实际签名与 App Group 诊断", icon: "checkmark.shield")
            infoRow("签名 Entitlements", appGroupDiagnostics.entitlementStatus)\n            infoRow("实际 Group IDs", appGroupDiagnostics.groupIdentifiersText)
            infoRow("检测状态", appGroupDiagnostics.status)
            infoRow("容器", appGroupDiagnostics.containerStatus)
            infoRow("文件读写", appGroupDiagnostics.fileTestStatus)
            infoRow("最近检测", appGroupDiagnostics.lastChecked)
            Text(appGroupDiagnostics.detail)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                appGroupDiagnostics.runCheck()
            } label: {
                HStack(spacing: 9) {
                    if appGroupDiagnostics.isChecking {
                        ProgressView().tint(.white)
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }
                    Text(appGroupDiagnostics.isChecking ? "正在检测…" : "重新检测签名与容器")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 5)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .disabled(appGroupDiagnostics.isChecking)

            noteText("只在应用自己的共享容器内执行临时文件测试。", tint: .orange)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }

    private var sensorCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            cardHeading("传感器中心", subtitle: "实时状态概览", icon: "sensor")
            sensorStatusRow(
                title: "接近传感器",
                value: proximity.isSupported ? (proximity.isCovered ? "检测到遮挡" : "未遮挡") : "不可用",
                symbol: "dot.radiowaves.left.and.right",
                tint: proximity.isCovered ? .orange : .cyan
            )
            sensorStatusRow(
                title: "接近监测",
                value: proximity.status,
                symbol: "viewfinder",
                tint: .cyan
            )
            sensorStatusRow(
                title: "设备姿态",
                value: motion.description,
                symbol: "rotate.3d",
                tint: .purple
            )
            sensorStatusRow(
                title: "环境光",
                value: "尚未接入公开硬件数据源",
                symbol: "sun.max",
                tint: .yellow
            )
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }

    private var algorithmCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            cardHeading("智能场景实验室", subtitle: "调整算法模拟参数", icon: "slider.horizontal.3")

            Toggle("使用模拟环境光", isOn: $engine.useSimulatedLux)
                .tint(.cyan)
                .onChange(of: engine.useSimulatedLux) { _, _ in engine.recalculate() }

            sliderControl(
                title: "模拟环境光",
                value: $engine.previewLux,
                range: 0...2000,
                suffix: "lx"
            ) { value in
                engine.setPreviewLux(value)
            }

            sliderControl(
                title: "暗环境阈值",
                value: $engine.darkThresholdLux,
                range: 1...100,
                suffix: "lx"
            ) { _ in
                engine.recalculate()
            }

            Button {
                engine.recalculate()
            } label: {
                Label("重新计算状态", systemImage: "arrow.trianglehead.2.clockwise")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }

    private var futureFeaturesCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            cardHeading("扩展功能规划", subtitle: "为后续模块预留入口", icon: "square.grid.2x2")
            roadmapRow(
                title: "电池详细信息",
                detail: "电量、充电状态与可公开读取的电池信息",
                symbol: "battery.100percent",
                tint: .green
            )
            roadmapRow(
                title: "灵动岛风格组件",
                detail: "针对 iPhone 13 Pro Max 屏幕布局设计的应用内交互组件",
                symbol: "capsule",
                tint: .cyan
            )
            roadmapRow(
                title: "动态交互壁纸",
                detail: "应用内动态场景与壁纸预览体验",
                symbol: "sparkles.rectangle.stack",
                tint: .purple
            )
            Text("以上均为规划占位入口，尚未实现；后续会按系统公开 API 和设备限制逐项开发。")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }

    private var limitationCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            cardHeading("能力边界", subtitle: "当前版本说明", icon: "info.circle")
            Text("普通 IPA 没有公开 API 可以关闭 iOS 系统 AOD。环境光滑块仅用于算法验证，不是真实 lux 读数。传感器监听不能保证在应用进入后台或锁屏后持续运行。App Group 检测成功也不代表获得 MobileGestalt 或 SpringBoard 权限。")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }

    private func cardHeading(_ title: String, subtitle: String, icon: String) -> some View {
        HStack(spacing: 11) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(.cyan)
                .frame(width: 36, height: 36)
                .background(.cyan.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
    }

    private func infoRow(_ title: String, _ value: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer(minLength: 8)
            Text(value)
                .multilineTextAlignment(.trailing)
                .textSelection(.enabled)
        }
        .font(.subheadline)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func sensorStatusRow(title: String, value: String, symbol: String, tint: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.body.weight(.semibold))
                .foregroundStyle(tint)
                .frame(width: 38, height: 38)
                .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.subheadline.weight(.medium))
                Text(value)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
    }

    private func roadmapRow(title: String, detail: String, symbol: String, tint: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(tint)
                .frame(width: 42, height: 42)
                .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 7) {
                    Text(title).font(.subheadline.weight(.semibold))
                    Text("规划中")
                        .font(.system(size: 10, weight: .semibold))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(.white.opacity(0.08), in: Capsule())
                }
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
    }

    private func sliderControl(
        title: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        suffix: String,
        onChange: @escaping (Double) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Text(title).font(.subheadline)
                Spacer()
                Text("\(Int(value.wrappedValue)) \(suffix)")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            Slider(value: value, in: range, step: 1)
                .tint(.cyan)
                .onChange(of: value.wrappedValue) { _, newValue in
                    onChange(newValue)
                }
        }
    }

    private func noteText(_ text: String, tint: Color) -> some View {
        Text(text)
            .font(.caption2)
            .foregroundStyle(tint.opacity(0.9))
            .fixedSize(horizontal: false, vertical: true)
    }
}
