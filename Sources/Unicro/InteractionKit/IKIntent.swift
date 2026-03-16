//
//  IKIntent.swift
//  Unicro
//
//  Created by Codex on 2026-03-10.
//

import Foundation

public struct IKIntent: Hashable, Sendable {
    public var goal: Goal
    public var domain: Domain
    public var entity: Entity
    public var stage: Stage
    public var context: Context

    public init(
        goal: Goal,
        domain: Domain = .traffic,
        entity: Entity,
        stage: Stage,
        context: Context = .init()
    ) {
        self.goal = goal
        self.domain = domain
        self.entity = entity
        self.stage = stage
        self.context = context
    }
}

public extension IKIntent {
    enum Goal: Hashable, Sendable {
        case inspect
        case manage
        case compare
        case select
        case confirm
        case custom(String)
    }

    enum Domain: Hashable, Sendable {
        case traffic
        case custom(String)
    }

    enum Entity: Hashable, Sendable {
        case incident
        case route
        case trip
        case pin
        case custom(String)
    }

    enum Stage: Hashable, Sendable {
        case awareness
        case evaluation
        case decision
        case activeNavigation
        case confirmation
        case custom(String)
    }

    enum Capability: Hashable, Sendable {
        case browse(Browse = .read)
        case task(Task = .manage)
        case selection(Selection = .pick)
    }

    enum Browse: Hashable, Sendable {
        case read
        case inspect
    }

    enum Task: Hashable, Sendable {
        case manage
        case progress
    }

    enum Selection: Hashable, Sendable {
        case pick
    }

    struct Context: Hashable, Sendable {
        public var source: String?
        public var isAsync: Bool
        public var urgency: Int
        public var capability: Capability?

        public init(
            source: String? = nil,
            isAsync: Bool = false,
            urgency: Int = 0,
            capability: Capability? = nil
        ) {
            self.source = source
            self.isAsync = isAsync
            self.urgency = urgency
            self.capability = capability
        }
    }
}

public extension IKIntent {
    static func inspectIncident() -> Self {
        .init(
            goal: .inspect,
            entity: .incident,
            stage: .evaluation,
            context: .init(capability: .browse(.read))
        )
    }

    static func inspectPin() -> Self {
        .init(
            goal: .inspect,
            entity: .pin,
            stage: .awareness,
            context: .init(capability: .browse(.read))
        )
    }

    static func rerouteTrip(isAsync: Bool = true) -> Self {
        .init(
            goal: .manage,
            entity: .route,
            stage: .activeNavigation,
            context: .init(isAsync: isAsync, capability: .task(.manage))
        )
    }

    static func compareRoutes(isAsync: Bool = true) -> Self {
        .init(
            goal: .compare,
            entity: .route,
            stage: .decision,
            context: .init(isAsync: isAsync, capability: .selection(.pick))
        )
    }

    var capability: Capability {
        if let capability = context.capability {
            return capability
        }

        switch goal {
        case .inspect:
            return .browse(stage == .awareness ? .read : .inspect)
        case .manage, .confirm:
            return .task(.manage)
        case .compare, .select:
            return .selection(.pick)
        case .custom:
            return .browse(.read)
        }
    }

    var allowsTaskSwipe: Bool {
        if case .task = capability { return true }
        return false
    }

    var allowsStandardTap: Bool {
        true
    }

    var allowsLongPress: Bool {
        switch capability {
        case .task, .selection:
            return true
        case .browse:
            return false
        }
    }

    var allowsDragPan: Bool {
        switch capability {
        case .task, .selection:
            return true
        case .browse:
            return false
        }
    }

    var allowsPinch: Bool {
        if case .browse(.inspect) = capability { return true }
        return false
    }

    var allowsRotate: Bool {
        false
    }
}
