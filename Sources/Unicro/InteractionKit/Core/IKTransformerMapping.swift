//
//  IKTransformerMapping.swift
//  Unicro
//
//  Created by Codex on 2026-03-11.
//

import Foundation

public enum IKTransformerMapping {
    public static let item: IKIntent.Entity = "item"

    public static let rules: [IKInteractionRule] = [
        IKInteractionRule(
            goal: .inspect,
            entity: item,
            stage: .discovery,
            recipe: IKInteractionRecipe(
                interaction: IKInteraction(
                    pattern: .preview,
                    gesture: .tap
                ),
                resolvedIntent: IKIntent(
                    goal: .inspect,
                    domain: "generic",
                    entity: item,
                    stage: .discovery,
                    context: .init(
                        capability: .browse(.read)
                    )
                ),
                transformer: .anchoredPopup
            )
        ),
        IKInteractionRule(
            goal: .manage,
            entity: item,
            stage: .execution,
            recipe: IKInteractionRecipe(
                interaction: IKInteraction(
                    pattern: .preview,
                    gesture: .tap,
                    feedback: .asyncState
                ),
                resolvedIntent: IKIntent(
                    goal: .manage,
                    domain: "generic",
                    entity: item,
                    stage: .execution,
                    context: .init(
                        isAsync: true,
                        capability: .task(.manage)
                    )
                ),
                transformer: .bottomReveal
            )
        ),
    ]

    public static let fallback = IKInteractionRecipe(
        interaction: IKInteraction(
            pattern: .preview,
            gesture: .tap
        ),
        resolvedIntent: IKIntent(
            goal: .inspect,
            domain: "generic",
            entity: item,
            stage: .discovery,
            context: .init(
                capability: .browse(.read)
            )
        ),
        transformer: .anchoredPopup
    )
}
