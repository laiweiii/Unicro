//
//  IKTapPolicy.swift
//  Unicro
//
//  Created by Lai Wei on 2026-02-20.
//

import SwiftUI

public struct TapBehavior: Sendable {
    public enum TapKind: Sendable {
        case single
        case double
    }

    public let kind: TapKind
    public let hapticsOnTrigger: Bool

    public init(
        kind: TapKind = .single,
        hapticsOnTrigger: Bool = true
    ) {
        self.kind = kind
        self.hapticsOnTrigger = hapticsOnTrigger
    }
}

public struct TapCallbacks: Sendable {
    public let onTrigger: (() -> Void)?

    public init(onTrigger: (() -> Void)? = nil) {
        self.onTrigger = onTrigger
    }
}

public struct TaskTapConfig: Sendable {
    public let behavior: TapBehavior
    public let callbacks: TapCallbacks

    public init(behavior: TapBehavior, callbacks: TapCallbacks) {
        self.behavior = behavior
        self.callbacks = callbacks
    }
}

public struct TaskTapModifier: ViewModifier {
    let enabled: Bool
    let config: TaskTapConfig

    public init(
        enabled: Bool,
        config: TaskTapConfig
    ) {
        self.enabled = enabled
        self.config = config
    }

    public func body(content: Content) -> some View {
        Group {
            if enabled {
                content
                    .contentShape(Rectangle())
                    .simultaneousGesture(tapGesture())
            } else {
                content
            }
        }
    }

    private func tapGesture() -> some Gesture {
        let count = config.behavior.kind == .single ? 1 : 2
        return TapGesture(count: count)
            .onEnded {
                config.callbacks.onTrigger?()
                hapticIfNeeded()
            }
    }

    private func hapticIfNeeded() {
        guard config.behavior.hapticsOnTrigger else { return }
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
    }
}
