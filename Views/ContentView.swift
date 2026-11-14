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
    @AppStorage("NEXUS.feature.aodEnabled") private var aodEnabled = false
    @AppStorage("NEXUS.feature.dynamicIslandEnabled") private var dynamicIslandEnabled = false
    @State private var showResetConfirmation = false
    @State private var showLogoutInfo = false
    @State private var batteryLevel: Float = UIDevice.current.batteryLevel
    @State private var selectedWallpaperScene = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            atmosphericBackground

            Group {
                switch selectedTab {
                case .overview:
                    navigationPage(title: "功能介绍") { featureIntroContent }
                case .sensors:
                    navigationPage(title: "传感") { sensorWorkspaceContent }
                case .laboratory:
                    navigationPage(title: "签名与权限") { appGroupCard }
                case .system:
                    navigationPage(title: "系统能力") { capabilityCard }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            bottomNavigation
                .padding(.bottom, 4)
                .zIndex(2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.container, edges: .all)
        .tint(.cyan)
        .preferredColorScheme(.dark)
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
        .onAppear {
            ambientMotion = true
        }
    }

    @ViewBuilder
    private func navigationPage<Content: View>(
        title: String,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        NavigationStack {
            VStack(spacing: 0) {
                pageHeader(title: title)

                ScrollView(showsIndicators: false) {
                    content()
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .padding(.horizontal, 12)
                        .padding(.top, 4)
                        .padding(.bottom, 96)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .scrollBounceBehavior(.basedOnSize)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(atmosphericBackground.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.container, edges: .all)
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
                Text("0.4.9")
                    .font(.system(size: 11, weight: .bold, design: .rounded).monospaced())
                    .foregroundStyle(.white.opacity(0.9))
                Text("BUILD 17")
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
        .padding(.top, 2)
        .padding(.bottom, 7)
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
        VStack(spacing: 16) {
            featureIntroHero
            VStack(alignment: .leading, spacing: 18) {
                sectionIntro("核心研发", detail: "NEXUS 后续版本只聚焦以下两个方向", symbol: "sparkles")
                featureToggleRow(title: "强开 AOD", detail: "围绕 iOS 27.2 与 iPhone 13 Pro Max 开展兼容性、传感器策略和可行性研究；开关目前仅保存应用内状态。", symbol: "moon.stars.fill", tint: .cyan, status: "核心研发", isOn: $aodEnabled)
                Divider().overlay(.white.opacity(0.10))
                featureToggleRow(title: "iPhone 13 Pro Max 定制灵动岛", detail: "专注本机屏幕形态、动态布局和应用内实时交互体验。", symbol: "capsule", tint: .purple, status: "核心研发", isOn: $dynamicIslandEnabled)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassCard()
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }

    private func featureToggleRow(title: String, detail: String, symbol: String, tint: Color, status: String, isOn: Binding<Bool>) -> some View {
        HStack(alignment: .center, spacing: 11) {
            featureIcon(symbol, tint: tint)
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 7) {
                    Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(.white)
                    featureStatus(status, tint: tint)
                }
                Text(detail).font(.caption).foregroundStyle(.white.opacity(0.56))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 5)
            liquidGlassSwitch(isOn: isOn)
        }
        .padding(.vertical, 3)
    }

    private func featureNavigationRow(title: String, detail: String, symbol: String, tint: Color, status: String) -> some View {
        HStack(alignment: .center, spacing: 11) {
            featureIcon(symbol, tint: tint)
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 7) {
                    Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(.white)
                    featureStatus(status, tint: tint)
                }
                Text(detail).font(.caption).foregroundStyle(.white.opacity(0.56))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 5)
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white.opacity(0.45))
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }

    private func featureIcon(_ symbol: String, tint: Color) -> some View {
        Image(systemName: symbol)
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(tint)
            .frame(width: 43, height: 43)
            .background(tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func featureStatus(_ status: String, tint: Color) -> some View {
        Text(status)
            .font(.system(size: 9, weight: .semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(tint.opacity(0.12), in: Capsule())
    }

    private func liquidGlassSwitch(isOn: Binding<Bool>) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.72)) {
                isOn.wrappedValue.toggle()
            }
        } label: {
            ZStack(alignment: isOn.wrappedValue ? .trailing : .leading) {
                Capsule().fill(.ultraThinMaterial)
                Capsule()
                    .fill(isOn.wrappedValue
                          ? LinearGradient(colors: [.cyan.opacity(0.9), .blue.opacity(0.78)], startPoint: .topLeading, endPoint: .bottomTrailing)
                          : LinearGradient(colors: [.white.opacity(0.10), .white.opacity(0.04)], startPoint: .top, endPoint: .bottom))
                    .padding(2)
                Circle()
                    .fill(.regularMaterial)
                    .overlay(Circle().strokeBorder(.white.opacity(0.52), lineWidth: 0.8))
                    .shadow(color: .black.opacity(0.24), radius: 4, y: 2)
                    .frame(width: 25, height: 25)
                    .padding(4)
            }
            .frame(width: 57, height: 33)
            .overlay(Capsule().strokeBorder(.white.opacity(0.23), lineWidth: 0.8))
            .shadow(color: isOn.wrappedValue ? .cyan.opacity(0.28) : .clear, radius: 8, y: 2)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isOn.wrappedValue ? "已开启" : "已关闭")
    }

    private var batteryDetailView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                detailHero(title: "电池检测", subtitle: "读取 iOS 公开提供的电量与充电状态", symbol: "battery.100percent", tint: .green)
                VStack(alignment: .leading, spacing: 12) {
                    sectionIntro("实时状态", detail: "数据由系统公开接口提供", symbol: "waveform.path.ecg")
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(batteryLevel >= 0 ? "\(Int(batteryLevel * 100))%" : "—")
                            .font(.system(size: 38, weight: .bold, design: .rounded)).foregroundStyle(.green)
                        Text("当前电量").font(.caption).foregroundStyle(.white.opacity(0.55))
                    }
                    infoRow("充电状态", batteryStateDescription)
                    infoRow("电池健康度", "iOS 未向普通应用开放精确读取")
                    infoRow("真实最大容量", "无法通过公开 API 直接读取")
                }
                .padding(16).glassCard()
                VStack(alignment: .leading, spacing: 10) {
                    sectionIntro("电池与续航参考", detail: "机型规格，不等同于当前电池健康值", symbol: "clock")
                    infoRow("出厂标称容量", "约 4,352 mAh（参考值）")
                    infoRow("视频播放续航", "最高约 28 小时（官方标称条件）")
                    infoRow("实时耗电预测", "需要持续采样后才能计算")
                    infoRow("充电功率", "实时瓦数未开放读取；约 27W 峰值为第三方参考")
                    noteText("电池容量会随老化下降；标称容量、系统电池健康度和实时可用容量是不同指标。", tint: .orange)
                }
                .padding(16).glassCard()
            }
            .padding(16)
        }
        .background(atmosphericBackground.ignoresSafeArea())
        .navigationTitle("电池检测")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            UIDevice.current.isBatteryMonitoringEnabled = true
            batteryLevel = UIDevice.current.batteryLevel
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.batteryLevelDidChangeNotification)) { _ in
            batteryLevel = UIDevice.current.batteryLevel
        }
    }

    private var batteryStateDescription: String {
        switch UIDevice.current.batteryState {
        case .charging: "正在充电"
        case .full: "已充满"
        case .unplugged: "未连接电源"
        case .unknown: "系统暂未提供"
        @unknown default: "未知"
        }
    }

    private var wallpaperDetailView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                detailHero(title: "动态交互壁纸", subtitle: "NEXUS 壁纸实验室 · 交互预览", symbol: "sparkles.rectangle.stack", tint: .pink)
                ZStack {
                    let palettes: [[Color]] = [
                        [Color(red: 0.02, green: 0.38, blue: 0.52), Color(red: 0.18, green: 0.10, blue: 0.42), .black],
                        [Color(red: 0.48, green: 0.12, blue: 0.35), Color(red: 0.12, green: 0.12, blue: 0.38), .black],
                        [Color(red: 0.10, green: 0.42, blue: 0.28), Color(red: 0.03, green: 0.16, blue: 0.34), .black]
                    ]
                    LinearGradient(colors: palettes[selectedWallpaperScene % palettes.count], startPoint: .topLeading, endPoint: .bottomTrailing)
                    Circle().fill(.white.opacity(0.18)).frame(width: 145, height: 145).blur(radius: 34).offset(x: 78, y: -52)
                    Circle().stroke(.white.opacity(0.25), lineWidth: 1).frame(width: 190, height: 190)
                    Circle().stroke(.white.opacity(0.13), lineWidth: 1).frame(width: 145, height: 145)
                    Image(systemName: "sparkle").font(.system(size: 44, weight: .ultraLight)).foregroundStyle(.white.opacity(0.9))
                }
                .frame(height: 285)
                .clipShape(RoundedRectangle(cornerRadius: 27, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 27, style: .continuous).strokeBorder(.white.opacity(0.18)))
                .glassCard()
                VStack(alignment: .leading, spacing: 12) {
                    sectionIntro("交互场景", detail: "切换不同的动态视觉主题", symbol: "slider.horizontal.3")
                    HStack(spacing: 9) {
                        ForEach(0..<3, id: \.self) { index in
                            Button {
                                withAnimation(.easeInOut(duration: 0.45)) { selectedWallpaperScene = index }
                            } label: {
                                Text(["深海极光", "暮色星云", "森林脉冲"][index])
                                    .font(.caption.weight(.semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 11)
                                    .background(selectedWallpaperScene == index ? .cyan.opacity(0.2) : .white.opacity(0.06), in: Capsule())
                                    .overlay(Capsule().strokeBorder(selectedWallpaperScene == index ? .cyan.opacity(0.45) : .white.opacity(0.1)))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    noteText("当前为 NEXUS 应用内效果预览，不会直接替换 iOS 锁屏或主屏幕壁纸。", tint: .orange)
                }
                .padding(16).glassCard()
            }
            .padding(16)
        }
        .background(atmosphericBackground.ignoresSafeArea())
        .navigationTitle("动态交互壁纸")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var moreFunctionsDetailView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                detailHero(title: "更多功能", subtitle: "设备维护与 NEXUS 扩展中心", symbol: "square.grid.2x2.fill", tint: .orange)
                VStack(alignment: .leading, spacing: 12) {
                    sectionIntro("设备维护", detail: "后续版本逐步开放", symbol: "wrench.and.screwdriver")
                    HStack(spacing: 11) {
                        featureIcon("internaldrive", tint: .cyan)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("清理设备缓存").font(.subheadline.weight(.semibold)).foregroundStyle(.white)
                            Text("规划中；普通 IPA 无法清理 iOS 系统级缓存。").font(.caption).foregroundStyle(.white.opacity(0.55))
                        }
                        Spacer()
                        Text("规划中").font(.caption2.weight(.semibold)).foregroundStyle(.orange)
                    }
                    .padding(12).background(.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 15))
                }
                .padding(16).glassCard()

                VStack(alignment: .leading, spacing: 12) {
                    sectionIntro("应用操作", detail: "只影响 NEXUS 自身，不修改系统文件", symbol: "gearshape.2")
                    Button { showLogoutInfo = true } label: {
                        Label("注销 / 重启 SpringBoard", systemImage: "rectangle.portrait.and.arrow.right")
                            .frame(maxWidth: .infinity).padding(.vertical, 5)
                    }
                    .buttonStyle(.bordered)
                    .tint(.orange)
                    .alert("注销功能暂不可用", isPresented: $showLogoutInfo) {
                        Button("知道了", role: .cancel) {}
                    } message: {
                        Text("GestaltX 的“注销”实际是通过 NeoSpring 尝试重启 SpringBoard。NEXUS 当前是普通未越狱 IPA，没有这项系统级能力，因此这里只保留入口，不会假装执行成功。")
                    }

                    Button(role: .destructive) { showResetConfirmation = true } label: {
                        Label("重置 NEXUS", systemImage: "arrow.counterclockwise")
                            .frame(maxWidth: .infinity).padding(.vertical, 5)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .confirmationDialog("重置 NEXUS 设置？", isPresented: $showResetConfirmation, titleVisibility: .visible) {
                        Button("恢复默认设置", role: .destructive) { resetNEXUSSettings() }
                        Button("取消", role: .cancel) {}
                    } message: {
                        Text("仅重置 NEXUS 内保存的开关与算法参数，不会清理设备缓存、删除照片或修改 iOS 系统设置。")
                    }
                }
                .padding(16).glassCard()
            }
            .padding(16)
        }
        .background(atmosphericBackground.ignoresSafeArea())
        .navigationTitle("更多功能")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detailHero(title: String, subtitle: String, symbol: String, tint: Color) -> some View {
        HStack(spacing: 13) {
            Image(systemName: symbol)
                .font(.system(size: 25, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 55, height: 55)
                .background(tint.opacity(0.15), in: RoundedRectangle(cornerRadius: 17, style: .continuous))
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(.title3.weight(.bold)).foregroundStyle(.white)
                Text(subtitle).font(.caption).foregroundStyle(.white.opacity(0.58))
            }
            Spacer(minLength: 0)
        }
        .padding(17).frame(maxWidth: .infinity, alignment: .leading).glassCard()
    }

    private func resetNEXUSSettings() {
        aodEnabled = false
        dynamicIslandEnabled = false
        engine.useSimulatedLux = false
        engine.previewLux = 20
        engine.darkThresholdLux = 10
        engine.recalculate()
        ambientMotion = true
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
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.78)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: tab.symbol)
                            .font(.system(size: 17, weight: .medium))
                            .symbolRenderingMode(.hierarchical)
                        Text(tab.rawValue)
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundStyle(selectedTab == tab ? .white : .white.opacity(0.56))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .frame(maxWidth: .infinity)
        // Keep only the native transparent Liquid Glass surface: no tint, gradient, rim or glow.
        .glassEffect(.regular.interactive(), in: Capsule())
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }

    private var capabilityCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            cardHeading("系统能力", subtitle: "设备与原生接口", icon: "cpu")
            infoRow("识别机型", recognizedDeviceName)
            infoRow("设备标识", systemInspector.deviceIdentifier)
            infoRow("iOS 版本", systemInspector.systemVersion)
            infoRow("应用状态", systemInspector.appState)
            Divider().overlay(.white.opacity(0.10))
            cardHeading("设备规格", subtitle: "iPhone 13 Pro Max 硬件信息与参考数据", icon: "iphone")
            infoRow("屏幕尺寸", "6.7 英寸")
            infoRow("机身尺寸", "160.8 × 78.1 × 7.65 mm")
            infoRow("机身重量", "约 238 g")
            infoRow("屏幕分辨率", "2778 × 1284 像素")
            infoRow("逻辑分辨率", "428 × 926 pt")
            infoRow("运行内存", "6 GB")
            noteText("本页仅展示设备识别信息与硬件规格。", tint: .cyan)
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
