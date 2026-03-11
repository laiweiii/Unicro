//
//  IKDragPolicy.swift
//  Unicro
//
//  Created by Lai Wei on 2026-02-20.
//

import SwiftUI

public struct DragBehavior: Sendable {
    public enum AxisMode: Sendable {
        case horizontal
        case vertical
        case free
    }

    public enum EndState: Sendable {
        case reset
        case keep
    }

    public let axis: AxisMode
    public let minimumDistance: CGFloat
    public let rubberBand: CGFloat
    public let endState: EndState
    public let hapticsOnEnd: Bool

    public init(
        axis: AxisMode = .free,
        minimumDistance: CGFloat = 8,
        rubberBand: CGFloat = 0.2,
        endState: EndState = .reset,
        hapticsOnEnd: Bool = false
    ) {
        self.axis = axis
        self.minimumDistance = minimumDistance
        self.rubberBand = rubberBand
        self.endState = endState
        self.hapticsOnEnd = hapticsOnEnd
    }
}

public struct DragCallbacks: Sendable {
    public let onChange: ((CGSize) -> Void)?
    public let onEnd: ((CGSize) -> Void)?

    public init(onChange: ((CGSize) -> Void)? = nil,
                onEnd: ((CGSize) -> Void)? = nil) {
        self.onChange = onChange
        self.onEnd = onEnd
    }
}

public struct TaskDragConfig: Sendable {
    public let behavior: DragBehavior
    public let callbacks: DragCallbacks

    public init(behavior: DragBehavior, callbacks: DragCallbacks) {
        self.behavior = behavior
        self.callbacks = callbacks
    }
}

public struct TaskDragModifier: ViewModifier {
    let enabled: Bool
    let config: TaskDragConfig

    @GestureState private var liveOffset: CGSize = .zero
    @State private var committedOffset: CGSize = .zero

    public init(
        enabled: Bool,
        config: TaskDragConfig
    ) {
        self.enabled = enabled
        self.config = config
    }

    public func body(content: Content) -> some View {
        Group {
            if enabled {
                content
                    .contentShape(Rectangle())
                    .offset(totalOffset)
                    .simultaneousGesture(dragGesture())
                    .animation(.snappy(duration: 0.2), value: committedOffset)
            } else {
                content
            }
        }
    }

    private var totalOffset: CGSize {
        CGSize(
            width: committedOffset.width + liveOffset.width,
            height: committedOffset.height + liveOffset.height
        )
    }

    private func dragGesture() -> some Gesture {
        DragGesture(
            minimumDistance: config.behavior.minimumDistance,
            coordinateSpace: .local
        )
        .updating($liveOffset) { value, state, _ in
            let projected = project(value.translation)
            state = applyRubberBand(projected, factor: config.behavior.rubberBand)
            config.callbacks.onChange?(CGSize(
                width: committedOffset.width + state.width,
                height: committedOffset.height + state.height
            ))
        }
        .onEnded { value in
            let projected = project(value.translation)
            let next = CGSize(
                width: committedOffset.width + projected.width,
                height: committedOffset.height + projected.height
            )

            config.callbacks.onEnd?(next)
            hapticIfNeeded()

            switch config.behavior.endState {
            case .reset:
                committedOffset = .zero
            case .keep:
                committedOffset = next
            }
        }
    }

    private func project(_ translation: CGSize) -> CGSize {
        switch config.behavior.axis {
        case .horizontal:
            return CGSize(width: translation.width, height: 0)
        case .vertical:
            return CGSize(width: 0, height: translation.height)
        case .free:
            return translation
        }
    }

    private func applyRubberBand(_ point: CGSize, factor: CGFloat) -> CGSize {
        CGSize(
            width: applyRubberBand(point.width, factor: factor),
            height: applyRubberBand(point.height, factor: factor)
        )
    }

    private func applyRubberBand(_ value: CGFloat, factor: CGFloat) -> CGFloat {
        let sign: CGFloat = value >= 0 ? 1 : -1
        let absValue = abs(value)
        return sign * (absValue / (1 + absValue * factor / 300))
    }

    private func hapticIfNeeded() {
        guard config.behavior.hapticsOnEnd else { return }
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
    }
}
