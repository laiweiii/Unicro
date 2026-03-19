//
//  TrafficIntentMapping.swift
//  Unicro
//
//  Created by Codex on 2026-03-10.
//

import Foundation

public enum TrafficIntentMapping {
    public static let rules: [IKInteractionRule] = [
        IKInteractionRule(
            goal: .inspect,
            entity: TrafficVocabulary.Entity.mapElement,
            stage: .discovery,
            domainEntity: TrafficVocabulary.DomainEntity.pin,
            domainState: TrafficVocabulary.DomainState.awareness,
            recipe: IKInteractionRecipe(
                interaction: IKInteraction(
                    pattern: .preview,
                    gesture: .tap
                ),
                resolvedIntent: IKIntent(
                    goal: .inspect,
                    domain: TrafficVocabulary.domain,
                    entity: TrafficVocabulary.Entity.mapElement,
                    stage: .discovery,
                    context: .init(
                        capability: .browse(.read),
                        domainEntity: TrafficVocabulary.DomainEntity.pin,
                        domainState: TrafficVocabulary.DomainState.awareness
                    )
                ),
                transformer: .anchoredPopup
            )
        ),
        
        IKInteractionRule(
            goal: .manage,
            entity: TrafficVocabulary.Entity.journey,
            stage: .execution,
            domainEntity: TrafficVocabulary.DomainEntity.route,
            domainState: TrafficVocabulary.DomainState.activeNavigation,
            recipe: IKInteractionRecipe(
                interaction: IKInteraction(
                    pattern: .preview,
                    gesture: .tap,
                    feedback: .asyncState
                ),
                resolvedIntent: IKIntent(
                    goal: .manage,
                    domain: TrafficVocabulary.domain,
                    entity: TrafficVocabulary.Entity.journey,
                    stage: .execution,
                    context: .init(
                        isAsync: true,
                        capability: .task(.manage),
                        domainEntity: TrafficVocabulary.DomainEntity.route,
                        domainState: TrafficVocabulary.DomainState.activeNavigation
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
            domain: TrafficVocabulary.domain,
            entity: TrafficVocabulary.Entity.mapElement,
            stage: .discovery,
            context: .init(
                capability: .browse(.read),
                domainEntity: TrafficVocabulary.DomainEntity.pin,
                domainState: TrafficVocabulary.DomainState.awareness
            )
        ),
        transformer: .anchoredPopup
    )
}
