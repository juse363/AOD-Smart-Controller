import SwiftUI

private enum DashboardTab: String, CaseIterable, Identifiable {
    case overview = "总览"
    case sensors = "传感"
    case laboratory = "签名与权限"
    case system = "系统"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .overview: "square.grid.2x2.fill"
        case .sensors: "sensor.fill"
        case .laboratory: "checkmark.shield.fill"
        case .system: "gearshape.2.fill"
        }
    }
}

struct ContentView: View {
    @EnvironmentObject private var proximity: ProximityMonitor
    @EnvironmentObject private var motion: MotionMonitor
    @EnvironmentObject private var engine: AODDecisionEngine
    @EnvironmentObject private var systemInspector: SystemCapabilityInspector
    @StateObject private var appGroupDiagnostics = AppGroupDiagnostics()
    @State private var selectedTab: DashboardTab = .overview
    @State private var ambientMotion = false

    var body: some View {
        TabView(selection: $selectedTab) {
            navigationPage(title: "功能介绍") {
                featureIntroContent
            }
            .tabItem { Label("功能介绍", systemImage: "sparkles") }
            .tag(DashboardTab.overview)

            navigationPage(title: "传感") {
                sensorWorkspaceContent
            }
            .tabItem { Label("传感", systemImage: "sensor") }
            .tag(DashboardTab.sensors)

            navigationPage(title: "签名与权限") {
                appGroupCard
            }
            .tabItem { Label("签名与权限", systemImage: "checkmark.shield") }
            .tag(DashboardTab.laboratory)

            navigationPage(title: "系统能力") {
                capabilityCard
            }
            .tabItem { Label("系统", systemImage: "gearshape") }
            .tag(DashboardTab.system)
        }
        .tint(.cyan)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
        .background(atmosphericBackground)
        .preferredColorScheme(.dark)
        .onAppear {
            ambientMotion = true
        }
    }

    @ViewBuilder
    private func navigationPage<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationStack {
            VStack(spacing: 0) {
                pageHeader(title: title)

                ScrollView(showsIndicators: false) {
                    content()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.top, 9)
                        .padding(.bottom, 30)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .scrollBounceBehavior(.basedOnSize)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(atmosphericBackground.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private func pageHeader(title: String) -> some View {
        HStack(spacing: 11) {
            ZStack {
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.cyan.opacity(0.88), .blue.opacity(0.72), .purple.opacity(0.68)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Image(systemName: "point.3.connected.trianglepath.dotted")
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(width: 39, height: 39)
            .overlay {
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .strokeBorder(.white.opacity(0.24), lineWidth: 0.8)
            }
            .shadow(color: .cyan.opacity(0.18), radius: 9, y: 3)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text("NEXUS · 灵枢工作台")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white.opacity(0.48))
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 3) {
                Text("0.4.5")
                    .font(.system(size: 11, weight: .bold, design: .rounded).monospaced())
                    .foregroundStyle(.white.opacity(0.9))
                Text("BUILD 13")
                    .font(.system(size: 8, weight: .semibold, design: .rounded).monospaced())
                    .tracking(0.5)
                    .foregroundStyle(.cyan.opacity(0.9))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().strokeBorder(.white.opacity(0.14), lineWidth: 0.8))
        }
        .padding(.horizontal, 18)
        .padding(.top, 7)
        .padding(.bottom, 10)
        .background {
            Rectangle()
                .fill(.ultraThinMaterial.opacity(0.42))
                .overlay(alignment: .bottom) {
                    Rectangle().fill(.white.opacity(0.07)).frame(height: 0.5)
                }
                .ignoresSafeArea(edges: .top)
        }
    }

    private var atmosphericBackground: some View {
        GeometryReader { proxy in
            ZStack {
                Color(red: 0.025, green: 0.045, blue: 0.09)
                RadialGradient(
                    colors: [Color.cyan.opacity(0.19), .clear],
                    center: .topTrailing,
                    startRadius: 10,
                    endRadius: proxy.size.width * 0.95
                )
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 260, height: 260)
                    .blur(radius: 70)
                    .offset(x: ambientMotion ? proxy.size.width * 0.48 : proxy.size.width * 0.18,
                            y: ambientMotion ? -proxy.size.height * 0.18 : -proxy.size.height * 0.04)
                Circle()
                    .fill(Color.purple.opacity(0.11))
                    .frame(width: 240, height: 240)
                    .blur(radius: 75)
                    .offset(x: ambientMotion ? -proxy.size.width * 0.48 : -proxy.size.width * 0.2,
                            y: proxy.size.height * 0.52)
            }
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 9).repeatForever(autoreverses: true), value: ambientMotion)
        }
        .ignoresSafeArea()
    }

    private var topBar: some View {
        HStack(spacing: 11) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(LinearGradient(
                        colors: [.cyan.opacity(0.9), .blue.opacity(0.75), .purple.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                Image(systemName: "point.3.connected.trianglepath.dotted")
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(width: 42, height: 42)
            .shadow(color: .cyan.opacity(0.24), radius: 12, y: 4)

            VStack(alignment: .leading, spacing: 1) {
                Text("NEXUS")
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                    .tracking(1.4)
                Text("灵枢工作台 · 连接智能")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white.opacity(0.55))
            }

            Spacer()

            HStack(spacing: 5) {
                Circle().fill(.green).frame(width: 6, height: 6)
                Text("BUILD 12")
                    .font(.system(size: 9, weight: .bold, design: .rounded).monospaced())
                    .tracking(0.6)
            }
            .foregroundStyle(.white.opacity(0.75))
            .padding(.horizontal, 9)
            .padding(.vertical, 7)
            .background(.white.opacity(0.07), in: Capsule())
            .overlay(Capsule().strokeBorder(.white.opacity(0.09)))
        }
        .padding(.horizontal, 18)
        .padding(.top, 7)
        .padding(.bottom, 11)
    }

    @ViewBuilder
    private var selectedContent: some View {
        switch selectedTab {
        case .overview:
            overviewContent
        case .sensors:
            sensorCard
        case .laboratory:
            algorithmCard
        case .system:
            VStack(spacing: 13) {
                appGroupCard
                capabilityCard
                futureFeaturesCard
                limitationCard
            }
        }
    }

    private var sensorWorkspaceContent: some View {
        VStack(spacing: 13) {
            overviewContent
            sensorCard
        }
    }

    private var featureIntroContent: some View {
        VStack(spacing: 13) {
            featureIntroHero
            VStack(alignment: .leading, spacing: 13) {
                sectionIntro("核心功能", detail: "围绕 iPhone 13 Pro Max 持续扩展", symbol: "square.grid.2x2")
                featureIntroRow(title: "强开 AOD", detail: "持续研究原生息屏显示的兼容路径与状态策略；普通 IPA 暂无公开接口直接开启 iOS 原生 AOD。", symbol: "moon.stars.fill", tint: .cyan, status: "研究中")
                featureIntroRow(title: "iPhone 13 Pro Max 定制灵动岛", detail: "针对 428 pt 逻辑宽度打造应用内灵动岛视觉与交互体验。", symbol: "capsule", tint: .purple, status: "规划中")
                featureIntroRow(title: "电池检测", detail: "整合系统公开可读取的电量、充电状态与电池信息。", symbol: "battery.100percent", tint: .green, status: "规划中")
                featureIntroRow(title: "动态交互壁纸", detail: "加入动态场景、交互效果与应用内壁纸预览。", symbol: "sparkles.rectangle.stack", tint: .pink, status: "规划中")
                featureIntroRow(title: "更多功能", detail: "持续扩展设备状态、个性化组件与智能控制相关模块。", symbol: "ellipsis.circle.fill", tint: .orange, status: "持续更新")
            }
            .padding(15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassCard()
        }
    }

    private var featureIntroHero: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(LinearGradient(
                    colors: [Color(red: 0.06, green: 0.25, blue: 0.38).opacity(0.98),
                             Color(red: 0.12, green: 0.10, blue: 0.29).opacity(0.98)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
            Circle()
                .stroke(.cyan.opacity(0.14), lineWidth: 1)
                .frame(width: 190, height: 190)
                .overlay(Circle().stroke(.cyan.opacity(0.08), lineWidth: 1).padding(20))
                .offset(x: 238, y: 8)
            VStack(alignment: .leading, spacing: 9) {
                Text("NEXUS · FEATURE OVERVIEW")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .tracking(1.5)
                    .foregroundStyle(.cyan.opacity(0.92))
                Text("为 iPhone 13 Pro Max\n打造的智能扩展工作台")
                    .font(.system(size: 23, weight: .bold, design: .rounded))
                    .lineSpacing(2)
                    .foregroundStyle(.white)
                Text("从设备感知到个性化交互，逐步解锁更多可能。")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.62))
            }
            .padding(19)
        }
        .frame(height: 158)
        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 25, style: .continuous).strokeBorder(.white.opacity(0.12)))
        .shadow(color: .blue.opacity(0.13), radius: 18, y: 8)
    }

    private func featureIntroRow(title: String, detail: String, symbol: String, tint: Color, status: String) -> some View {
        HStack(alignment: .top, spacing: 11) {
            Image(systemName: symbol)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 41, height: 41)
                .background(tint.opacity(0.13), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 7) {
                    Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(.white)
                    Text(status)
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(tint)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(tint.opacity(0.12), in: Capsule())
                }
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.55))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
    }

    private var overviewContent: some View {
        VStack(spacing: 13) {
            heroPanel
            statusOverview

            HStack(spacing: 11) {
                compactMetric(
                    title: "接近传感器",
                    value: proximity.isSupported ? (proximity.isCovered ? "已遮挡" : "正常") : "不可用",
                    symbol: "dot.radiowaves.left.and.right",
                    tint: proximity.isCovered ? .orange : .cyan
                )
                compactMetric(
                    title: "设备姿态",
                    value: motion.description,
                    symbol: "rotate.3d",
                    tint: .purple
                )
            }

            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(.cyan)
                Text("快速查看设备状态；传感器与算法参数可在下方导航中展开。")
                    .foregroundStyle(.white.opacity(0.62))
                Spacer(minLength: 0)
            }
            .font(.caption)
            .padding(.horizontal, 3)
        }
    }

    private var heroPanel: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(LinearGradient(
                    colors: [Color(red: 0.06, green: 0.25, blue: 0.38).opacity(0.96),
                             Color(red: 0.10, green: 0.12, blue: 0.30).opacity(0.96)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
            Circle()
                .stroke(.cyan.opacity(0.12), lineWidth: 1)
                .frame(width: 180, height: 180)
                .overlay(Circle().stroke(.cyan.opacity(0.08), lineWidth: 1).padding(18))
                .offset(x: 235, y: 5)
            Circle()
                .fill(.cyan.opacity(0.13))
                .frame(width: 110, height: 110)
                .blur(radius: 28)
                .offset(x: 250, y: -38)

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("SMART CONTROL CENTER")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .tracking(1.6)
                        .foregroundStyle(.cyan.opacity(0.9))
                    Text("让设备状态\n尽在掌握")
                        .font(.system(size: 25, weight: .bold, design: .rounded))
                        .lineSpacing(1)
                        .foregroundStyle(.white)
                    Text(systemInspector.deviceIdentifier)
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.58))
                }
                Spacer(minLength: 0)
                ZStack {
                    Circle().fill(.cyan.opacity(0.10)).frame(width: 76, height: 76)
                    Circle().stroke(.cyan.opacity(0.28), lineWidth: 1).frame(width: 76, height: 76)
                    Image(systemName: "wave.3.right")
                        .font(.system(size: 30, weight: .light))
                        .foregroundStyle(.cyan)
                        .shadow(color: .cyan.opacity(0.65), radius: 12)
                }
                .padding(.trailing, 5)
            }
            .padding(.horizontal, 19)
            .padding(.vertical, 18)
        }
        .frame(height: 145)
        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 25, style: .continuous).strokeBorder(.white.opacity(0.12)))
        .shadow(color: .blue.opacity(0.13), radius: 18, y: 8)
    }

    private var statusOverview: some View {
        HStack(spacing: 13) {
            ZStack {
                Circle().fill(statusTint.opacity(0.13)).frame(width: 48, height: 48)
                Circle().stroke(statusTint.opacity(0.35), lineWidth: 1).frame(width: 48, height: 48)
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(statusTint)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("当前算法状态")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.55))
                Text(engine.state.rawValue)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(engine.reason)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.55))
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
            HStack(spacing: 5) {
                Circle().fill(statusTint).frame(width: 7, height: 7)
                Text("LIVE")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .tracking(0.8)
            }
            .foregroundStyle(statusTint)
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(statusTint.opacity(0.10), in: Capsule())
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(cornerRadius: 21)
        .accessibilityElement(children: .combine)
    }

    private var recognizedDeviceName: String {
        switch systemInspector.deviceIdentifier {
        case "iPhone14,3": "iPhone 13 Pro Max"
        default: systemInspector.deviceIdentifier
        }
    }

    private var statusTint: Color {
        proximity.isCovered ? .orange : .cyan
    }

    private func compactMetric(title: String, value: String, symbol: String, tint: Color) -> some View {
        HStack(spacing: 9) {
            Image(systemName: symbol)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 34, height: 34)
                .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.system(size: 10)).foregroundStyle(.white.opacity(0.52))
                Text(value)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            Spacer(minLength: 0)
        }
        .padding(11)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(cornerRadius: 17)
    }

    private var bottomNavigation: some View {
        HStack(spacing: 5) {
            ForEach(DashboardTab.allCases) { tab in
                Button {
                    withAnimation(.spring(response: 0.34, dampingFraction: 0.78)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: tab.symbol)
                            .font(.system(size: 17, weight: .semibold))
                            .symbolRenderingMode(.hierarchical)
                        Text(tab.rawValue)
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundStyle(selectedTab == tab ? .cyan : .white.opacity(0.48))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .background {
                        if selectedTab == tab {
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .fill(.cyan.opacity(0.12))
                                .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous)
                                    .strokeBorder(.cyan.opacity(0.18)))
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .padding(.bottom, 5)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) { Rectangle().fill(.white.opacity(0.08)).frame(height: 0.5) }
    }

    private var capabilityCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            cardHeading("系统能力", subtitle: "设备与原生接口", icon: "cpu")
            infoRow("识别机型", recognizedDeviceName)
            infoRow("设备标识", systemInspector.deviceIdentifier)
            infoRow("iOS 版本", systemInspector.systemVersion)
            infoRow("应用状态", systemInspector.appState)
            noteText("这里只展示系统实际识别到的设备型号与基础系统信息。", tint: .cyan)
        }
        .padding(15).frame(maxWidth: .infinity, alignment: .leading).glassCard()
    }

    private var appGroupCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            cardHeading("签名与权限", subtitle: "实际签名与 App Group 诊断", icon: "checkmark.shield")
            infoRow("签名 Entitlements", appGroupDiagnostics.entitlementStatus)
            infoRow("实际 Group IDs", appGroupDiagnostics.groupIdentifiersText)
            infoRow("检测状态", appGroupDiagnostics.status)
            infoRow("容器", appGroupDiagnostics.containerStatus)
            infoRow("文件读写", appGroupDiagnostics.fileTestStatus)
            infoRow("最近检测", appGroupDiagnostics.lastChecked)
            Text(appGroupDiagnostics.detail)
                .font(.caption2).foregroundStyle(.white.opacity(0.55))
                .fixedSize(horizontal: false, vertical: true)

            Button { appGroupDiagnostics.runCheck() } label: {
                HStack(spacing: 8) {
                    if appGroupDiagnostics.isChecking { ProgressView().tint(.white) }
                    else { Image(systemName: "arrow.clockwise") }
                    Text(appGroupDiagnostics.isChecking ? "正在检测…" : "重新检测签名与容器")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity).padding(.vertical, 5)
            }
            .buttonStyle(.borderedProminent).tint(.blue)
            .disabled(appGroupDiagnostics.isChecking)
            noteText("只在应用自己的共享容器内执行临时文件测试。", tint: .orange)
        }
        .padding(15).frame(maxWidth: .infinity, alignment: .leading).glassCard()
    }

    private var sensorCard: some View {
        VStack(alignment: .leading, spacing: 13) {
            sectionIntro("传感器中心", detail: "设备状态与实时感知", symbol: "sensor")
            sensorStatusRow(title: "接近传感器",
                            value: proximity.isSupported ? (proximity.isCovered ? "检测到遮挡" : "未遮挡") : "不可用",
                            symbol: "dot.radiowaves.left.and.right",
                            tint: proximity.isCovered ? .orange : .cyan)
            sensorStatusRow(title: "接近监测", value: proximity.status, symbol: "viewfinder", tint: .cyan)
            sensorStatusRow(title: "设备姿态", value: motion.description, symbol: "rotate.3d", tint: .purple)
            sensorStatusRow(title: "环境光", value: "尚未接入公开硬件数据源", symbol: "sun.max", tint: .yellow)
        }
        .padding(15).frame(maxWidth: .infinity, alignment: .leading).glassCard()
    }

    private var algorithmCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionIntro("智能场景实验室", detail: "调整算法模拟参数", symbol: "slider.horizontal.3")
            Toggle("使用模拟环境光", isOn: $engine.useSimulatedLux)
                .tint(.cyan)
                .onChange(of: engine.useSimulatedLux) { _, _ in engine.recalculate() }
            sliderControl(title: "模拟环境光", value: $engine.previewLux, range: 0...2000, suffix: "lx") {
                engine.setPreviewLux($0)
            }
            sliderControl(title: "暗环境阈值", value: $engine.darkThresholdLux, range: 1...100, suffix: "lx") { _ in
                engine.recalculate()
            }
            Button { engine.recalculate() } label: {
                Label("重新计算状态", systemImage: "arrow.trianglehead.2.clockwise")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .padding(15).frame(maxWidth: .infinity, alignment: .leading).glassCard()
    }

    private var futureFeaturesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionIntro("扩展功能规划", detail: "为后续模块预留入口", symbol: "square.grid.2x2")
            roadmapRow(title: "电池详细信息", detail: "电量、充电状态与可公开读取的电池信息", symbol: "battery.100percent", tint: .green)
            roadmapRow(title: "灵动岛风格组件", detail: "针对 iPhone 13 Pro Max 屏幕布局设计的应用内交互组件", symbol: "capsule", tint: .cyan)
            roadmapRow(title: "动态交互壁纸", detail: "应用内动态场景与壁纸预览体验", symbol: "sparkles.rectangle.stack", tint: .purple)
            Text("以上均为规划占位入口，尚未实现；后续会按系统公开 API 和设备限制逐项开发。")
                .font(.caption2).foregroundStyle(.white.opacity(0.52))
        }
        .padding(15).frame(maxWidth: .infinity, alignment: .leading).glassCard()
    }

    private var limitationCard: some View {
        VStack(alignment: .leading, spacing: 9) {
            sectionIntro("能力边界", detail: "当前版本说明", symbol: "info.circle")
            Text("普通 IPA 没有公开 API 可以关闭 iOS 系统 AOD。环境光滑块仅用于算法验证，不是真实 lux 读数。传感器监听不能保证在应用进入后台或锁屏后持续运行。App Group 检测成功也不代表获得 MobileGestalt 或 SpringBoard 权限。")
                .font(.footnote).foregroundStyle(.white.opacity(0.58))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(15).frame(maxWidth: .infinity, alignment: .leading).glassCard()
    }

    private func sectionIntro(_ title: String, detail: String, symbol: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.headline).foregroundStyle(.cyan)
                .frame(width: 35, height: 35)
                .background(.cyan.opacity(0.12), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline).foregroundStyle(.white)
                Text(detail).font(.caption2).foregroundStyle(.white.opacity(0.48))
            }
            Spacer(minLength: 0)
        }
    }

    private func cardHeading(_ title: String, subtitle: String, icon: String) -> some View {
        sectionIntro(title, detail: subtitle, symbol: icon)
    }

    private func infoRow(_ title: String, _ value: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(title).foregroundStyle(.white.opacity(0.52))
            Spacer(minLength: 8)
            Text(value).foregroundStyle(.white.opacity(0.88))
                .multilineTextAlignment(.trailing).textSelection(.enabled)
        }
        .font(.subheadline).frame(maxWidth: .infinity, alignment: .leading)
    }

    private func sensorStatusRow(title: String, value: String, symbol: String, tint: Color) -> some View {
        HStack(spacing: 11) {
            Image(systemName: symbol).font(.body.weight(.semibold)).foregroundStyle(tint)
                .frame(width: 37, height: 37)
                .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.subheadline.weight(.medium)).foregroundStyle(.white)
                Text(value).font(.caption).foregroundStyle(.white.opacity(0.54))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
    }

    private func roadmapRow(title: String, detail: String, symbol: String, tint: Color) -> some View {
        HStack(spacing: 11) {
            Image(systemName: symbol).font(.title3).foregroundStyle(tint)
                .frame(width: 40, height: 40)
                .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 7) {
                    Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(.white)
                    Text("规划中").font(.system(size: 9, weight: .semibold))
                        .padding(.horizontal, 7).padding(.vertical, 3)
                        .background(.white.opacity(0.08), in: Capsule())
                }
                Text(detail).font(.caption).foregroundStyle(.white.opacity(0.52))
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
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title).font(.subheadline).foregroundStyle(.white.opacity(0.85))
                Spacer()
                Text("\(Int(value.wrappedValue)) \(suffix)")
                    .font(.subheadline.monospacedDigit()).foregroundStyle(.cyan)
            }
            Slider(value: value, in: range, step: 1)
                .tint(.cyan)
                .onChange(of: value.wrappedValue) { _, newValue in onChange(newValue) }
        }
    }

    private func noteText(_ text: String, tint: Color) -> some View {
        Text(text).font(.caption2).foregroundStyle(tint.opacity(0.9))
            .fixedSize(horizontal: false, vertical: true)
    }
}
