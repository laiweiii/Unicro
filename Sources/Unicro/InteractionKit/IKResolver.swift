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
    public var uxIntent: IKUXIntent

    public init(
        intent: IKIntent,
        interaction: IKInteraction,
        uxIntent: IKUXIntent
    ) {
        self.intent = intent
        self.interaction = interaction
        self.uxIntent = uxIntent
    }
}

public struct IKResolver: Sendable {
    public init() {}

    public func resolve(_ intent: IKIntent) -> IKResolvedInteraction {
        let interaction: IKInteraction
        let uxIntent: IKUXIntent

        switch (intent.verb, intent.target) {
        case (.open, .card):
            interaction = IKInteraction(
                pattern: .expand,
                gesture: .tap,
                motion: .fluidExpand
            )
            uxIntent = .browse(.discover)

        case (.preview, .card), (.open, .sheet):
            interaction = IKInteraction(
                pattern: .sheet,
                gesture: .tap,
                motion: .fluidSheet
            )
            uxIntent = .browse(.read)

        case (.reorder, .grid), (.reorder, .canvas):
            interaction = IKInteraction(
                pattern: .gridRearrange,
                gesture: .drag,
                motion: .draggableGrid
            )
            uxIntent = .selection(.reorder)

        case (.manage, .item):
            interaction = IKInteraction(
                pattern: .swipeAction,
                gesture: .swipe,
                feedback: intent.context.isAsync ? .asyncState : nil
            )
            uxIntent = .task(.manage)

        case (.inspect, .media):
            interaction = IKInteraction(
                pattern: .inspect,
                gesture: .pinch,
                motion: .spatialDrag
            )
            uxIntent = .browse(.inspect)

        case (.select, _):
            interaction = IKInteraction(
                pattern: .preview,
                gesture: .tap
            )
            uxIntent = .selection(.pick)

        default:
            interaction = IKInteraction(
                pattern: .preview,
                gesture: .tap,
                feedback: intent.context.isAsync ? .loading : nil
            )
            uxIntent = .browse(.read)
        }

        return IKResolvedInteraction(
            intent: intent,
            interaction: interaction,
            uxIntent: uxIntent
        )
    }
}
