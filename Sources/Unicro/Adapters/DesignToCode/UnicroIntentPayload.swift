//
//  UnicroIntentPayload.swift
//  Unicro
//
//  Created by Codex on 2026-05-30.
//

import Foundation

public struct UnicroIntentPayload: Hashable, Sendable {
    public var goal: IKIntent.Goal
    public var domain: IKIntent.Domain
    public var entity: IKIntent.Entity
    public var stage: IKIntent.Stage
    public var isAsync: Bool
    public var source: String?
    public var urgency: Int
    public var capability: IKIntent.Capability?

    public init(
        goal: IKIntent.Goal,
        domain: IKIntent.Domain = "generic",
        entity: IKIntent.Entity,
        stage: IKIntent.Stage,
        isAsync: Bool = false,
        source: String? = nil,
        urgency: Int = 0,
        capability: IKIntent.Capability? = nil
    ) {
        self.goal = goal
        self.domain = domain
        self.entity = entity
        self.stage = stage
        self.isAsync = isAsync
        self.source = source
        self.urgency = urgency
        self.capability = capability
    }
}
