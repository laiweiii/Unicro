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

private struct InteractionIntentKey: EnvironmentKey {
    static let defaultValue = IKIntent(
        goal: .inspect,
        domain: "generic",
        entity: IKTransformerMapping.item,
        stage: .discovery,
        context: .init(
            capability: .browse(.read)
        )
    )
}

public extension EnvironmentValues {
    var interactionIntent: IKIntent {
        get { self[InteractionIntentKey.self] }
        set { self[InteractionIntentKey.self] = newValue }
    }
}

public extension View {
    func intent(_ intent: IKIntent) -> some View {
        environment(\.interactionIntent, intent)
    }

    func intent(
        _ intent: IKIntent,
        @ViewBuilder build: (InteractionBinder) -> some View
    ) -> some View {
        let base = self.environment(\.interactionIntent, intent)
        return build(InteractionBinder(base: base, intent: intent))
    }
}
