//
//  IKRotatePolicy.swift
//  Unicro
//
//  Created by Lai Wei on 2026-02-20.
//

import SwiftUI

public struct RotateBehavior: Sendable {
    public enum EndState: Sendable {
        case reset
        case keep
    }

    public let endState: EndState
    public let hapticsOnEnd: Bool

    public init(
        endState: EndState = .keep,
        hapticsOnEnd: Bool = false
    ) {
        self.endState = endState
        self.hapticsOnEnd = hapticsOnEnd
    }
}

public struct RotateCallbacks: Sendable {
    public let onChange: ((Angle) -> Void)?
    public let onEnd: ((Angle) -> Void)?

    public init(onChange: ((Angle) -> Void)? = nil,
                onEnd: ((Angle) -> Void)? = nil) {
        self.onChange = onChange
        self.onEnd = onEnd
    }
}

public struct TaskRotateConfig: Sendable {
    public let behavior: RotateBehavior
    public let callbacks: RotateCallbacks

    public init(behavior: RotateBehavior, callbacks: RotateCallbacks) {
        self.behavior = behavior
        self.callbacks = callbacks
    }
}

public struct TaskRotateModifier: ViewModifier {
    let enabled: Bool
    let config: TaskRotateConfig

    @GestureState private var gestureRotation: Angle = .zero
    @State private var baseRotation: Angle = .zero

    public init(
        enabled: Bool,
        config: TaskRotateConfig
    ) {
        self.enabled = enabled
        self.config = config
    }

    public func body(content: Content) -> some View {
        let currentRotation = Angle.radians(baseRotation.radians + gestureRotation.radians)
        return Group {
            if enabled {
                content
                    .contentShape(Rectangle())
                    .rotationEffect(currentRotation)
                    .simultaneousGesture(rotationGesture())
                    .animation(.snappy(duration: 0.2), value: baseRotation)
            } else {
                content
            }
        }
    }

    private func rotationGesture() -> some Gesture {
        RotationGesture()
            .updating($gestureRotation) { value, state, _ in
                state = value
                let current = Angle.radians(baseRotation.radians + value.radians)
                config.callbacks.onChange?(current)
            }
            .onEnded { value in
                let finalRotation = Angle.radians(baseRotation.radians + value.radians)
                config.callbacks.onEnd?(finalRotation)
                hapticIfNeeded()

                switch config.behavior.endState {
                case .reset:
                    baseRotation = .zero
                case .keep:
                    baseRotation = finalRotation
                }
            }
    }

    private func hapticIfNeeded() {
        guard config.behavior.hapticsOnEnd else { return }
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
    }
}
