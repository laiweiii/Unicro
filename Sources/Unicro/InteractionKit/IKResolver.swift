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

    public init(
        intent: IKIntent,
        interaction: IKInteraction,
        resolvedIntent: IKIntent
    ) {
        self.intent = intent
        self.interaction = interaction
        self.resolvedIntent = resolvedIntent
    }
}

public struct IKResolver: Sendable {
    public init() {}

    public func resolve(_ intent: IKIntent) -> IKResolvedInteraction {
        let interaction: IKInteraction
        let resolvedIntent: IKIntent

        switch (intent.verb, intent.target) {
        case (.open, .card):
            interaction = IKInteraction(
                pattern: .expand,
                gesture: .tap,
                motion: .fluidExpand
            )
            resolvedIntent = .browse(.discover)

        case (.preview, .card), (.open, .sheet):
            interaction = IKInteraction(
                pattern: .sheet,
                gesture: .tap,
                motion: .fluidSheet
            )
            resolvedIntent = .browse(.read)

        case (.reorder, .grid), (.reorder, .canvas):
            interaction = IKInteraction(
                pattern: .gridRearrange,
                gesture: .drag,
                motion: .draggableGrid
            )
            resolvedIntent = .selection(.reorder)

        case (.manage, .item):
            interaction = IKInteraction(
                pattern: .swipeAction,
                gesture: .swipe,
                feedback: intent.context.isAsync ? .asyncState : nil
            )
            resolvedIntent = .task(.manage)

        case (.inspect, .media):
            interaction = IKInteraction(
                pattern: .inspect,
                gesture: .pinch,
                motion: .spatialDrag
            )
            resolvedIntent = .browse(.inspect)

        case (.select, _):
            interaction = IKInteraction(
                pattern: .preview,
                gesture: .tap
            )
            resolvedIntent = .selection(.pick)

        default:
            interaction = IKInteraction(
                pattern: .preview,
                gesture: .tap,
                feedback: intent.context.isAsync ? .loading : nil
            )
            resolvedIntent = .browse(.read)
        }

        return IKResolvedInteraction(
            intent: intent,
            interaction: interaction,
            resolvedIntent: resolvedIntent
        )
    }
}
