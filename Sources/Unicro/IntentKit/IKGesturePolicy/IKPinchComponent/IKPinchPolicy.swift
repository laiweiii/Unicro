//
//  IKPinchPolicy.swift
//  Unicro
//
//  Created by Lai Wei on 2026-02-20.
//

import SwiftUI

public struct PinchBehavior: Sendable {
    public enum EndState: Sendable {
        case reset
        case keep
    }

    public let minScale: CGFloat
    public let maxScale: CGFloat
    public let endState: EndState
    public let hapticsOnEnd: Bool

    public init(
        minScale: CGFloat = 0.5,
        maxScale: CGFloat = 3.0,
        endState: EndState = .keep,
        hapticsOnEnd: Bool = false
    ) {
        self.minScale = minScale
        self.maxScale = maxScale
        self.endState = endState
        self.hapticsOnEnd = hapticsOnEnd
    }
}

public struct PinchCallbacks: Sendable {
    public let onChange: ((CGFloat) -> Void)?
    public let onEnd: ((CGFloat) -> Void)?

    public init(onChange: ((CGFloat) -> Void)? = nil,
                onEnd: ((CGFloat) -> Void)? = nil) {
        self.onChange = onChange
        self.onEnd = onEnd
    }
}

public struct TaskPinchConfig: Sendable {
    public let behavior: PinchBehavior
    public let callbacks: PinchCallbacks

    public init(behavior: PinchBehavior, callbacks: PinchCallbacks) {
        self.behavior = behavior
        self.callbacks = callbacks
    }
}

public struct TaskPinchModifier: ViewModifier {
    let enabled: Bool
    let config: TaskPinchConfig

    @GestureState private var gestureScale: CGFloat = 1
    @State private var baseScale: CGFloat = 1

    public init(
        enabled: Bool,
        config: TaskPinchConfig
    ) {
        self.enabled = enabled
        self.config = config
    }

    public func body(content: Content) -> some View {
        let currentScale = clamp(baseScale * gestureScale)
        return Group {
            if enabled {
                content
                    .contentShape(Rectangle())
                    .scaleEffect(currentScale)
                    .simultaneousGesture(pinchGesture())
                    .animation(.snappy(duration: 0.2), value: baseScale)
            } else {
                content
            }
        }
    }

    private func pinchGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureScale) { value, state, _ in
                state = value
                config.callbacks.onChange?(clamp(baseScale * state))
            }
            .onEnded { value in
                let finalScale = clamp(baseScale * value)
                config.callbacks.onEnd?(finalScale)
                hapticIfNeeded()

                switch config.behavior.endState {
                case .reset:
                    baseScale = 1
                case .keep:
                    baseScale = finalScale
                }
            }
    }

    private func clamp(_ value: CGFloat) -> CGFloat {
        min(max(value, config.behavior.minScale), config.behavior.maxScale)
    }

    private func hapticIfNeeded() {
        guard config.behavior.hapticsOnEnd else { return }
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
    }
}
