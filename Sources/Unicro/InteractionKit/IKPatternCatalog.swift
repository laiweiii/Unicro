//
//  IKPatternCatalog.swift
//  Unicro
//
//  Created by Codex on 2026-03-10.
//

import Foundation

public struct IKPatternRecipe: Hashable, Sendable {
    public var interaction: IKInteraction
    public var resolvedIntent: IKIntent
    public var component: Component

    public init(
        interaction: IKInteraction,
        resolvedIntent: IKIntent,
        component: Component
    ) {
        self.interaction = interaction
        self.resolvedIntent = resolvedIntent
        self.component = component
    }
}

public extension IKPatternRecipe {
    enum Component: Hashable, Sendable {
        case incidentPreview
        case incidentDetailSheet
        case rerouteSheet
        case routeCompareSheet
        case custom(String)
    }
}

public struct IKPatternRule: Hashable, Sendable {
    public var goal: IKIntent.Goal?
    public var entity: IKIntent.Entity?
    public var stage: IKIntent.Stage?
    public var recipe: IKPatternRecipe

    public init(
        goal: IKIntent.Goal? = nil,
        entity: IKIntent.Entity? = nil,
        stage: IKIntent.Stage? = nil,
        recipe: IKPatternRecipe
    ) {
        self.goal = goal
        self.entity = entity
        self.stage = stage
        self.recipe = recipe
    }

    func matches(_ intent: IKIntent) -> Bool {
        if let goal, goal != intent.goal { return false }
        if let entity, entity != intent.entity { return false }
        if let stage, stage != intent.stage { return false }
        return true
    }
}

public struct IKPatternCatalog: Sendable {
    public var rules: [IKPatternRule]
    public var fallback: IKPatternRecipe

    public init(
        rules: [IKPatternRule] = Self.defaultRules,
        fallback: IKPatternRecipe = Self.defaultFallback
    ) {
        self.rules = rules
        self.fallback = fallback
    }

    public func recipe(for intent: IKIntent) -> IKPatternRecipe {
        for rule in rules where rule.matches(intent) {
            var recipe = rule.recipe
            if intent.context.isAsync && recipe.interaction.feedback == nil {
                recipe.interaction.feedback = .asyncState
            }
            return recipe
        }

        var recipe = fallback
        if intent.context.isAsync {
            recipe.interaction.feedback = .loading
        }
        return recipe
    }
}

public extension IKPatternCatalog {
    static let defaultRules: [IKPatternRule] = [
        IKPatternRule(
            goal: .inspect,
            entity: .pin,
            stage: .awareness,
            recipe: IKPatternRecipe(
                interaction: IKInteraction(
                    pattern: .preview,
                    gesture: .tap
                ),
                resolvedIntent: .inspectPin(),
                component: .incidentPreview
            )
        ),
        IKPatternRule(
            goal: .inspect,
            entity: .incident,
            stage: .evaluation,
            recipe: IKPatternRecipe(
                interaction: IKInteraction(
                    pattern: .sheet,
                    gesture: .tap,
                    motion: .fluidSheet
                ),
                resolvedIntent: .inspectIncident(),
                component: .incidentDetailSheet
            )
        ),
        IKPatternRule(
            goal: .manage,
            entity: .route,
            stage: .activeNavigation,
            recipe: IKPatternRecipe(
                interaction: IKInteraction(
                    pattern: .preview,
                    gesture: .tap,
                    motion: .fluidSheet,
                    feedback: .asyncState
                ),
                resolvedIntent: .rerouteTrip(),
                component: .rerouteSheet
            )
        ),
        IKPatternRule(
            goal: .compare,
            entity: .route,
            stage: .decision,
            recipe: IKPatternRecipe(
                interaction: IKInteraction(
                    pattern: .preview,
                    gesture: .tap,
                    motion: .fluidSheet,
                    feedback: .asyncState
                ),
                resolvedIntent: .compareRoutes(),
                component: .routeCompareSheet
            )
        )
    ]

    static let defaultFallback = IKPatternRecipe(
        interaction: IKInteraction(
            pattern: .preview,
            gesture: .tap
        ),
        resolvedIntent: .inspectPin(),
        component: .incidentPreview
    )
}
