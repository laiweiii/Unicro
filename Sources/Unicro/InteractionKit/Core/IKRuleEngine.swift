//
//  IKRuleEngine.swift
//  Unicro
//
//  Created by Codex on 2026-03-10.
//

import Foundation

public struct IKInteractionRecipe: Hashable, Sendable {
    public var interaction: IKInteraction
    public var resolvedIntent: IKIntent
    public var transformer: Transformer

    public init(
        interaction: IKInteraction,
        resolvedIntent: IKIntent,
        transformer: Transformer
    ) {
        self.interaction = interaction
        self.resolvedIntent = resolvedIntent
        self.transformer = transformer
    }
}

public extension IKInteractionRecipe {
    enum Transformer: Hashable, Sendable {
        case anchoredPopup
        case bottomReveal
        case pushTransform
        case custom(String)
    }
}

public extension IKInteractionRecipe.Transformer {
    var defaultMotion: IKInteraction.MotionPrimitive? {
        switch self {
        case .anchoredPopup:
            return .fluidExpand
        case .bottomReveal:
            return .fluidSheet
        case .pushTransform, .custom:
            return nil
        }
    }
}

public struct IKInteractionRule: Hashable, Sendable {
    public var goal: IKIntent.Goal?
    public var entity: IKIntent.Entity?
    public var stage: IKIntent.Stage?
    public var domainEntity: String?
    public var domainState: String?
    public var recipe: IKInteractionRecipe

    public init(
        goal: IKIntent.Goal? = nil,
        entity: IKIntent.Entity? = nil,
        stage: IKIntent.Stage? = nil,
        domainEntity: String? = nil,
        domainState: String? = nil,
        recipe: IKInteractionRecipe
    ) {
        self.goal = goal
        self.entity = entity
        self.stage = stage
        self.domainEntity = domainEntity
        self.domainState = domainState
        self.recipe = recipe
    }

    public func matches(_ intent: IKIntent) -> Bool {
        if let goal, goal != intent.goal { return false }
        if let entity, entity != intent.entity { return false }
        if let stage, stage != intent.stage { return false }
        if let domainEntity, domainEntity != intent.context.domainEntity { return false }
        if let domainState, domainState != intent.context.domainState { return false }
        return true
    }
}

public struct IKRuleEngine: Sendable {
    public init() {}

    public func resolve(
        intent: IKIntent,
        rules: [IKInteractionRule],
        fallback: IKInteractionRecipe
    ) -> IKInteractionRecipe {
        for rule in rules where rule.matches(intent) {
            var recipe = rule.recipe
            if recipe.interaction.motion == nil {
                recipe.interaction.motion = recipe.transformer.defaultMotion
            }
            if intent.context.isAsync && recipe.interaction.feedback == nil {
                recipe.interaction.feedback = .asyncState
            }
            return recipe
        }

        var recipe = fallback
        if recipe.interaction.motion == nil {
            recipe.interaction.motion = recipe.transformer.defaultMotion
        }
        if intent.context.isAsync {
            recipe.interaction.feedback = .loading
        }
        return recipe
    }
}
