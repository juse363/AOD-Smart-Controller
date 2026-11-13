import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var proximity: ProximityMonitor
    @EnvironmentObject private var motion: MotionMonitor
    @EnvironmentObject private var engine: AODDecisionEngine

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    header
                    stateCard
                    sensorCard
                    algorithmCard
                    limitationCard
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("AOD Smart Controller")
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("智能息屏控制中心")
                    .font(.title2.bold())
                Spacer()
                Text("0.1.0")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 9).padding(.vertical, 5)
                    .background(.blue.opacity(0.2), in: Capsule())
            }
            Text("iPhone 13 Pro Max · 传感器与算法原型")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var stateCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("算法判断状态", systemImage: "sparkles")
                .font(.headline)
            Text(engine.state.rawValue)
                .font(.system(size: 28, weight: .bold))
            Text(engine.reason)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("这是应用内部判断，不代表 iOS 原生 AOD 已关闭。")
                .font(.caption)
                .foregroundStyle(.orange)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18))
    }

    private var sensorCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("传感器状态").font(.headline)
            sensorRow("接近传感器", value: proximity.isSupported ? (proximity.isCovered ? "检测到遮挡" : "未遮挡") : "不可用")
            sensorRow("接近监测", value: proximity.status)
            sensorRow("设备姿态", value: motion.description)
            sensorRow("环境光", value: "未连接公开硬件数据源")
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18))
    }

    private var algorithmCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("算法实验室").font(.headline)
            Toggle("使用模拟环境光", isOn: $engine.useSimulatedLux)
                .tint(.blue)
                .onChange(of: engine.useSimulatedLux) { _, _ in engine.recalculate() }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("模拟环境光")
                    Spacer()
                    Text("\(Int(engine.previewLux)) lx")
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
                Slider(value: $engine.previewLux, in: 0...2000, step: 1)
                    .onChange(of: engine.previewLux) { _, value in engine.setPreviewLux(value) }
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("暗环境阈值")
                    Spacer()
                    Text("\(Int(engine.darkThresholdLux)) lx")
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
                Slider(value: $engine.darkThresholdLux, in: 1...100, step: 1)
                    .onChange(of: engine.darkThresholdLux) { _, _ in engine.recalculate() }
            }

            Button("重新计算状态") { engine.recalculate() }
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18))
    }

    private var limitationCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("重要限制", systemImage: "info.circle")
                .font(.headline)
            Text("普通 IPA 没有公开 API 可以关闭 iOS 系统 AOD。环境光滑块仅用于验证算法，不是实际 lux 读数。传感器监听也不能保证在应用进入后台或锁屏后持续运行。")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18))
    }

    private func sensorRow(_ title: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
            Spacer(minLength: 12)
            Text(value)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
    }
}
