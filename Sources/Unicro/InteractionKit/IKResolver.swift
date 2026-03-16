//
//  IKResolver.swift
//  Unicro
//
//  Created by Codex on 2026-03-10.
//

import Foundation

public struct IKResolvedInteraction: Hashable, Sendable {
    public var intent: IKIntent
    public var interaction: IKInteraction
    public var resolvedIntent: IKIntent
    public var component: IKPatternRecipe.Component

    public init(
        intent: IKIntent,
        interaction: IKInteraction,
        resolvedIntent: IKIntent,
        component: IKPatternRecipe.Component
    ) {
        self.intent = intent
        self.interaction = interaction
        self.resolvedIntent = resolvedIntent
        self.component = component
    }
}

public struct IKResolver: IKIntentResolving, Sendable {
    public var catalog: IKPatternCatalog

    public init(catalog: IKPatternCatalog = .init()) {
        self.catalog = catalog
    }

    public func resolve(_ intent: IKIntent) -> IKResolvedInteraction {
        let recipe = catalog.recipe(for: intent)

        return IKResolvedInteraction(
            intent: intent,
            interaction: recipe.interaction,
            resolvedIntent: recipe.resolvedIntent,
            component: recipe.component
        )
    }
}
