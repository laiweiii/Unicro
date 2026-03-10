//
//  IKRotateBuilder.swift
//  Unicro
//
//  Created by Lai Wei on 2026-02-20.
//

import SwiftUI

public struct RotateSpec {
    var behavior: RotateBehavior = .init()
    var onChange: ((Angle) -> Void)?
    var onEnd: ((Angle) -> Void)?

    public mutating func behaviour(endState: RotateBehavior.EndState = .keep,
                                   hapticsOnEnd: Bool = false) {
        behavior = .init(endState: endState, hapticsOnEnd: hapticsOnEnd)
    }

    public mutating func onChange(_ f: @escaping (Angle) -> Void) {
        onChange = f
    }

    public mutating func onEnd(_ f: @escaping (Angle) -> Void) {
        onEnd = f
    }
}

public extension InteractionBinder {
    func rotate(build: (inout RotateSpec) -> Void) -> some View {
        var spec = RotateSpec()
        build(&spec)

        let config = TaskRotateConfig(
            behavior: spec.behavior,
            callbacks: RotateCallbacks(onChange: spec.onChange, onEnd: spec.onEnd)
        )

        let enabled = intent.allowsRotate
        return base.modifier(TaskRotateModifier(enabled: enabled, config: config))
    }
}
