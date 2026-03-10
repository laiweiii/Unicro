//
//  IKPinchBuilder.swift
//  Unicro
//
//  Created by Lai Wei on 2026-02-20.
//

import SwiftUI

public struct PinchSpec {
    var behavior: PinchBehavior = .init()
    var onChange: ((CGFloat) -> Void)?
    var onEnd: ((CGFloat) -> Void)?

    public mutating func behaviour(minScale: CGFloat = 0.5,
                                   maxScale: CGFloat = 3.0,
                                   endState: PinchBehavior.EndState = .keep,
                                   hapticsOnEnd: Bool = false) {
        behavior = .init(
            minScale: minScale,
            maxScale: maxScale,
            endState: endState,
            hapticsOnEnd: hapticsOnEnd
        )
    }

    public mutating func onChange(_ f: @escaping (CGFloat) -> Void) {
        onChange = f
    }

    public mutating func onEnd(_ f: @escaping (CGFloat) -> Void) {
        onEnd = f
    }
}

public extension InteractionBinder {
    func pinch(build: (inout PinchSpec) -> Void) -> some View {
        var spec = PinchSpec()
        build(&spec)

        let config = TaskPinchConfig(
            behavior: spec.behavior,
            callbacks: PinchCallbacks(onChange: spec.onChange, onEnd: spec.onEnd)
        )

        let enabled = intent.allowsPinch
        return base.modifier(TaskPinchModifier(enabled: enabled, config: config))
    }
}
