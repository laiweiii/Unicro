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
        domain: Domain = "generic",
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
    struct Domain: Hashable, Sendable, RawRepresentable, ExpressibleByStringLiteral {
        public var rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public init(stringLiteral value: StringLiteralType) {
            self.rawValue = value
        }
    }

    struct Entity: Hashable, Sendable, RawRepresentable, ExpressibleByStringLiteral {
        public var rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public init(stringLiteral value: StringLiteralType) {
            self.rawValue = value
        }
    }

    enum Goal: Hashable, Sendable {
        case inspect
        case manage
        case compare
        case select
        case confirm
        case custom(String)
    }

    enum Stage: Hashable, Sendable {
        case discovery
        case evaluation
        case decision
        case execution
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
    var capability: Capability {
        if let capability = context.capability {
            return capability
        }

        switch goal {
        case .inspect:
            return .browse(stage == .discovery ? .read : .inspect)
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
