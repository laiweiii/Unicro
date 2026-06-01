//
//  UnicroIntentFactory.swift
//  Unicro
//
//  Created by Codex on 2026-05-30.
//

import Foundation

public enum UnicroIntentFactory {
    public static func makeIntent(from payload: UnicroIntentPayload) -> IKIntent {
        IKIntent(
            goal: payload.goal,
            domain: payload.domain,
            entity: payload.entity,
            stage: payload.stage,
            context: .init(
                source: payload.source,
                isAsync: payload.isAsync,
                urgency: payload.urgency,
                capability: payload.capability
            )
        )
    }
}
