//
//  IKPatternCatalog.swift
//  Unicro
//
//  Created by Codex on 2026-03-10.
//

import Foundation

public struct IKPatternRecipe: Hashable, Sendable {
    public var pattern: IKInteraction.Pattern
    public var interaction: IKInteraction
    public var resolvedIntent: IKIntent
    public var component: Component

    public init(
        pattern: IKInteraction.Pattern,
        interaction: IKInteraction,
        resolvedIntent: IKIntent,
        component: Component
    ) {
        self.pattern = pattern
        self.interaction = interaction
        self.resolvedIntent = resolvedIntent
        self.component = component
    }
}

public extension IKPatternRecipe {
    enum Component: Hashable, Sendable {
        case expandCard
        case bottomSheet
        case draggableGrid
        case swipeRow
        case mediaInspector
        case custom(String)
    }
}

public struct IKPatternCatalog: Sendable {
    public init() {}

    public func recipe(for intent: IKIntent) -> IKPatternRecipe {
        switch (intent.context.domain, intent.context.goal, intent.verb, intent.target) {
        case (.travelBooking, .compare?, _, _):
            return IKPatternRecipe(
                pattern: .preview,
                interaction: IKInteraction(
                    pattern: .preview,
                    gesture: .tap,
                    motion: .fluidSheet
                ),
                resolvedIntent: .selection(.pick),
                component: .bottomSheet
            )

        case (_, .inspect?, _, .media), (.media, _, _, _):
            return IKPatternRecipe(
                pattern: .inspect,
                interaction: IKInteraction(
                    pattern: .inspect,
                    gesture: .pinch,
                    motion: .spatialDrag
                ),
                resolvedIntent: .browse(.inspect),
                component: .mediaInspector
            )

        case (_, .manage?, _, .item), (_, _, .manage, .item):
            return IKPatternRecipe(
                pattern: .swipeAction,
                interaction: IKInteraction(
                    pattern: .swipeAction,
                    gesture: .swipe,
                    feedback: intent.context.isAsync ? .asyncState : nil
                ),
                resolvedIntent: .task(.manage),
                component: .swipeRow
            )

        case (_, _, .open, .card):
            return IKPatternRecipe(
                pattern: .expand,
                interaction: IKInteraction(
                    pattern: .expand,
                    gesture: .tap,
                    motion: .fluidExpand
                ),
                resolvedIntent: .browse(.discover),
                component: .expandCard
            )

        case (_, _, .preview, .card), (_, _, .open, .sheet):
            return IKPatternRecipe(
                pattern: .sheet,
                interaction: IKInteraction(
                    pattern: .sheet,
                    gesture: .tap,
                    motion: .fluidSheet
                ),
                resolvedIntent: .browse(.read),
                component: .bottomSheet
            )

        case (_, _, .reorder, .grid), (_, _, .reorder, .canvas):
            return IKPatternRecipe(
                pattern: .gridRearrange,
                interaction: IKInteraction(
                    pattern: .gridRearrange,
                    gesture: .drag,
                    motion: .draggableGrid
                ),
                resolvedIntent: .selection(.reorder),
                component: .draggableGrid
            )

        case (_, _, .select, _):
            return IKPatternRecipe(
                pattern: .preview,
                interaction: IKInteraction(
                    pattern: .preview,
                    gesture: .tap
                ),
                resolvedIntent: .selection(.pick),
                component: .expandCard
            )

        default:
            return IKPatternRecipe(
                pattern: .preview,
                interaction: IKInteraction(
                    pattern: .preview,
                    gesture: .tap,
                    feedback: intent.context.isAsync ? .loading : nil
                ),
                resolvedIntent: .browse(.read),
                component: .expandCard
            )
        }
    }
}
