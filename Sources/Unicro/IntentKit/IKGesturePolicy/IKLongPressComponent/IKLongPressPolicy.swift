//
//  IKLongPressPolicy.swift
//  Unicro
//
//  Created by Lai Wei on 2026-02-20.
//

import SwiftUI

public struct LongPressBehavior: Sendable {
    public let minimumDuration: Double
    public let maximumDistance: CGFloat
    public let hapticsOnTrigger: Bool

    public init(
        minimumDuration: Double = 0.5,
        maximumDistance: CGFloat = 10,
        hapticsOnTrigger: Bool = true
    ) {
        self.minimumDuration = minimumDuration
        self.maximumDistance = maximumDistance
        self.hapticsOnTrigger = hapticsOnTrigger
    }
}

public struct LongPressCallbacks: Sendable {
    public let onTrigger: (() -> Void)?

    public init(onTrigger: (() -> Void)? = nil) {
        self.onTrigger = onTrigger
    }
}

public struct TaskLongPressConfig: Sendable {
    public let behavior: LongPressBehavior
    public let callbacks: LongPressCallbacks

    public init(behavior: LongPressBehavior, callbacks: LongPressCallbacks) {
        self.behavior = behavior
        self.callbacks = callbacks
    }
}

public struct TaskLongPressModifier: ViewModifier {
    let enabled: Bool
    let config: TaskLongPressConfig

    public init(
        enabled: Bool,
        config: TaskLongPressConfig
    ) {
        self.enabled = enabled
        self.config = config
    }

    public func body(content: Content) -> some View {
        Group {
            if enabled {
                content
                    .contentShape(Rectangle())
                    .simultaneousGesture(longPressGesture())
            } else {
                content
            }
        }
    }

    private func longPressGesture() -> some Gesture {
        LongPressGesture(
            minimumDuration: config.behavior.minimumDuration,
            maximumDistance: config.behavior.maximumDistance
        )
        .onEnded { _ in
            config.callbacks.onTrigger?()
            hapticIfNeeded()
        }
    }

    private func hapticIfNeeded() {
        guard config.behavior.hapticsOnTrigger else { return }
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        #endif
    }
}
