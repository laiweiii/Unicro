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
    public var transformer: IKInteractionRecipe.Transformer

    public init(
        intent: IKIntent,
        interaction: IKInteraction,
        resolvedIntent: IKIntent,
        transformer: IKInteractionRecipe.Transformer
    ) {
        self.intent = intent
        self.interaction = interaction
        self.resolvedIntent = resolvedIntent
        self.transformer = transformer
    }

    public var recipe: IKInteractionRecipe {
        IKInteractionRecipe(
            interaction: interaction,
            resolvedIntent: resolvedIntent,
            transformer: transformer
        )
    }
}

public struct IKResolver: IKIntentResolving, Sendable {
    public var engine: IKRuleEngine

    public init(engine: IKRuleEngine = .init()) {
        self.engine = engine
    }

    public func resolve(_ intent: IKIntent) -> IKResolvedInteraction {
        let recipe = engine.resolve(
            intent: intent,
            rules: TrafficIntentMapping.rules,
            fallback: TrafficIntentMapping.fallback
        )

        return IKResolvedInteraction(
            intent: intent,
            interaction: recipe.interaction,
            resolvedIntent: recipe.resolvedIntent,
            transformer: recipe.transformer
        )
    }
}
