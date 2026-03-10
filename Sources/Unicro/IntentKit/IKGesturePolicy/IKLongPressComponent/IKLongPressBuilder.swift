//
//  IKLongPressBuilder.swift
//  Unicro
//
//  Created by Lai Wei on 2026-02-20.
//

import SwiftUI

public struct LongPressSpec {
    var behavior: LongPressBehavior = .init()
    var onTrigger: (() -> Void)?

    public mutating func behaviour(minimumDuration: Double = 0.5,
                                   maximumDistance: CGFloat = 10,
                                   haptics: Bool = true) {
        behavior = .init(
            minimumDuration: minimumDuration,
            maximumDistance: maximumDistance,
            hapticsOnTrigger: haptics
        )
    }

    public mutating func onTrigger(_ f: @escaping () -> Void) {
        onTrigger = f
    }
}

public extension InteractionBinder {
    func longPress(build: (inout LongPressSpec) -> Void) -> some View {
        var spec = LongPressSpec()
        build(&spec)

        let config = TaskLongPressConfig(
            behavior: spec.behavior,
            callbacks: LongPressCallbacks(onTrigger: spec.onTrigger)
        )

        let enabled = intent.allowsLongPress
        return base.modifier(TaskLongPressModifier(enabled: enabled, config: config))
    }
}
