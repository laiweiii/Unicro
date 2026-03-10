//
//  IKTapBuilder.swift
//  Unicro
//
//  Created by Lai Wei on 2026-02-20.
//

import SwiftUI

public struct TapSpec {
    var behavior: TapBehavior = .init()
    var onTrigger: (() -> Void)?

    public mutating func behaviour(_ kind: TapBehavior.TapKind = .single,
                                   haptics: Bool = true) {
        behavior = .init(kind: kind, hapticsOnTrigger: haptics)
    }

    public mutating func onTrigger(_ f: @escaping () -> Void) {
        onTrigger = f
    }
}

public extension InteractionBinder {
    func tap(build: (inout TapSpec) -> Void) -> some View {
        var spec = TapSpec()
        build(&spec)

        let config = TaskTapConfig(
            behavior: spec.behavior,
            callbacks: TapCallbacks(onTrigger: spec.onTrigger)
        )

        let enabled = intent.allowsStandardTap
        return base.modifier(TaskTapModifier(enabled: enabled, config: config))
    }
}
