//
//  IKDragBuilder.swift
//  Unicro
//
//  Created by Lai Wei on 2026-02-20.
//

import SwiftUI

public struct DragSpec {
    var behavior: DragBehavior = .init()
    var onChange: ((CGSize) -> Void)?
    var onEnd: ((CGSize) -> Void)?

    public mutating func behaviour(_ axis: DragBehavior.AxisMode = .free,
                                   minimumDistance: CGFloat = 8,
                                   rubberBand: CGFloat = 0.2,
                                   endState: DragBehavior.EndState = .reset,
                                   hapticsOnEnd: Bool = false) {
        behavior = .init(
            axis: axis,
            minimumDistance: minimumDistance,
            rubberBand: rubberBand,
            endState: endState,
            hapticsOnEnd: hapticsOnEnd
        )
    }

    public mutating func onChange(_ f: @escaping (CGSize) -> Void) {
        onChange = f
    }

    public mutating func onEnd(_ f: @escaping (CGSize) -> Void) {
        onEnd = f
    }
}

public extension InteractionBinder {
    func drag(build: (inout DragSpec) -> Void) -> some View {
        var spec = DragSpec()
        build(&spec)

        let config = TaskDragConfig(
            behavior: spec.behavior,
            callbacks: DragCallbacks(onChange: spec.onChange, onEnd: spec.onEnd)
        )

        let enabled = intent.allowsDragPan
        return base.modifier(TaskDragModifier(enabled: enabled, config: config))
    }
}
