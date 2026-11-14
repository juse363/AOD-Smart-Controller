// SPDX-License-Identifier: GPL-3.0-only
// Copyright (C) 2026 huamidev
// Adapted from GestaltX/GestaltX/Capabilities.swift at huamidev/GestaltX commit d1d5473734440e8f2e797494ac373427c02fd674.
// NEXUS changes: AOD-only read-only capability catalog and sensor-policy integration.
// The key mappings below are identifiers for research; this file does not modify MobileGestalt.

import Foundation

struct AODCapabilityEntry: Identifiable {
    let id: String
    let title: String
    let detail: String
    let mobileGestaltKeys: [String]
    let caution: Bool
}

enum AODCapabilityProfile {
    static let upstreamSource = "https://github.com/huamidev/GestaltX/blob/d1d5473734440e8f2e797494ac373427c02fd674/GestaltX/Capabilities.swift"

    static let entries: [AODCapabilityEntry] = [
        .init(
            id: "aod",
            title: "Always-On Display",
            detail: "Primary AOD capability markers; actual display support depends on hardware and iOS.",
            mobileGestaltKeys: ["2OOJf1VhaM7NxfRok3HbWQ", "j8/Omm6s1lsmTDFsXjsBfA"],
            caution: true
        ),
        .init(
            id: "aodVibrancy",
            title: "AOD Vibrancy",
            detail: "AOD rendering capability marker.",
            mobileGestaltKeys: ["ykpu7qyhqFweVMKtxNylWA"],
            caution: false
        ),
        .init(
            id: "aodHighLuminance",
            title: "AOD High Luminance",
            detail: "High-luminance AOD capability marker.",
            mobileGestaltKeys: ["7brdL5xrEUWnlF9C0kdg5A"],
            caution: true
        ),
        .init(
            id: "aodFlipbook",
            title: "AOD Flipbook",
            detail: "Lock Screen AOD flipbook capability marker.",
            mobileGestaltKeys: ["aoJSd/MXk7M40NgXTM6x+g"],
            caution: false
        ),
        .init(
            id: "aodFlipbookCount",
            title: "AOD Flipbook Count",
            detail: "Experimental flipbook count value; accepted range varies by OS build.",
            mobileGestaltKeys: ["qqrspu7CpuPdZwSDxNY+Fg"],
            caution: true
        )
    ]

    static var allMobileGestaltKeys: [String] {
        entries.flatMap(\.mobileGestaltKeys)
    }
}

struct AODSensorDecision {
    let title: String
    let detail: String
    let canRenderPreview: Bool
}

enum AODSensorPolicy {
    static func evaluate(state: AODState, researchEnabled: Bool) -> AODSensorDecision {
        guard researchEnabled else {
            return .init(
                title: "研究暂停",
                detail: "开启 AOD 研究开关后，才会显示传感器策略建议。",
                canRenderPreview: false
            )
        }

        switch state {
        case .pocket:
            return .init(
                title: "遮挡保护",
                detail: "接近传感器检测到遮挡。建议隐藏应用内 AOD 预览，避免口袋误触和无意义耗电。",
                canRenderPreview: false
            )
        case .sleep:
            return .init(
                title: "姿态保护",
                detail: "运动传感器检测到屏幕朝下。当前策略建议暂停应用内 AOD 预览。",
                canRenderPreview: false
            )
        case .dim:
            return .init(
                title: "低亮度预览",
                detail: "模拟环境光低于设定阈值。可进入应用内低亮度 AOD 样式预览；这不是系统级常亮。",
                canRenderPreview: true
            )
        case .active:
            return .init(
                title: "正常预览",
                detail: "当前没有触发遮挡或屏幕朝下保护。可显示应用内 AOD 样式预览。",
                canRenderPreview: true
            )
        case .unknown:
            return .init(
                title: "等待传感器",
                detail: "传感器状态尚未完整，暂不建议启动 AOD 样式预览。",
                canRenderPreview: false
            )
        }
    }
}
