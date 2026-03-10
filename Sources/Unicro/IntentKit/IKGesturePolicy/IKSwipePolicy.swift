//
//  SwipePolicy.swift
//  Unicro
//
//  Created by Lai Wei on 2026-01-23.
//

// MARK: - Swipe Policy
import SwiftUI

public struct SwipePolicy: Sendable {
    public enum Style: Sendable {
        case peek        // 信息层：滑一下露出更多信息/预览
        case navigate    // 信息层：快速滑动切换/翻页
        case actions     // 任务层：露出按钮 actions
        case destructive // 任务层：直接 destructive（建议仍可撤销）
    }

    public var style: Style
    public var triggerThreshold: CGFloat     // 触发 action 的阈值
    public var rubberBand: CGFloat           // 回弹系数
    public var allowsFullSwipe: Bool         // 是否允许 full swipe 直接触发
    public var hapticsOnTrigger: Bool

    public init(
        style: Style,
        triggerThreshold: CGFloat = 90,
        rubberBand: CGFloat = 0.25,
        allowsFullSwipe: Bool = false,
        hapticsOnTrigger: Bool = true
    ) {
        self.style = style
        self.triggerThreshold = triggerThreshold
        self.rubberBand = rubberBand
        self.allowsFullSwipe = allowsFullSwipe
        self.hapticsOnTrigger = hapticsOnTrigger
    }
}

public enum DefaultSwipePolicies: IntentPolicyProviding {
    public static var infoPolicy: SwipePolicy {
        // Info：轻量，阈值更低，偏 peek/navigate，不建议 full swipe destructive
        SwipePolicy(style: .peek, triggerThreshold: 60, rubberBand: 0.35, allowsFullSwipe: false)
    }

    public static var taskPolicy: SwipePolicy {
        // Task：更明确，阈值更高，可 full swipe，actions/destructive
        SwipePolicy(style: .actions, triggerThreshold: 90, rubberBand: 0.2, allowsFullSwipe: true)
    }
}

