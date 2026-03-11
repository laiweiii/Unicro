//
//  IKInteractionBinder.swift
//  Unicro
//
//  Created by Codex on 2026-03-10.
//

import SwiftUI

public struct InteractionBinder {
    let base: AnyView
    let intent: IKIntent

    init<Base: View>(base: Base, intent: IKIntent) {
        self.base = AnyView(base)
        self.intent = intent
    }
}

public extension View {
    func uxIntent(
        _ intent: IKIntent,
        @ViewBuilder build: (InteractionBinder) -> some View
    ) -> some View {
        let base = self.environment(\.uxIntent, intent)
        return build(InteractionBinder(base: base, intent: intent))
    }
}
