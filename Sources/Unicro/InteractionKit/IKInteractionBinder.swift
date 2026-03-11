//
//  IKInteractionBinder.swift
//  Unicro
//
//  Created by Codex on 2026-03-10.
//

import SwiftUI

public struct InteractionBinder {
    let base: AnyView
    let intent: IKUXIntent

    init<Base: View>(base: Base, intent: IKUXIntent) {
        self.base = AnyView(base)
        self.intent = intent
    }
}

public extension View {
    func uxIntent(
        _ intent: IKUXIntent,
        @ViewBuilder build: (InteractionBinder) -> some View
    ) -> some View {
        let base = self.environment(\.uxIntent, intent)
        return build(InteractionBinder(base: base, intent: intent))
    }
}
