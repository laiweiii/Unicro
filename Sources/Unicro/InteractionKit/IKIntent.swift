//
//  IKIntent.swift
//  Unicro
//
//  Created by Codex on 2026-03-10.
//

import Foundation

public struct IKIntent: Hashable, Sendable {
    public var verb: Verb
    public var target: Target
    public var context: Context

    public init(
        verb: Verb,
        target: Target,
        context: Context = .init()
    ) {
        self.verb = verb
        self.target = target
        self.context = context
    }
}

public extension IKIntent {
    enum ProductGoal: Hashable, Sendable {
        case explore
        case compare
        case select
        case inspect
        case manage
        case confirm
        case custom(String)
    }

    enum Domain: Hashable, Sendable {
        case general
        case travelBooking
        case commerce
        case media
        case productivity
        case custom(String)
    }

    enum Capability: Hashable, Sendable {
        case browse(Browse = .read)
        case task(Task = .manage)
        case selection(Selection = .pick)
    }

    enum Browse: Hashable, Sendable {
        case read
        case discover
        case inspect
    }

    enum Task: Hashable, Sendable {
        case triage
        case manage
        case progress
    }

    enum Selection: Hashable, Sendable {
        case pick
        case edit
        case reorder
    }

    enum Verb: Hashable, Sendable {
        case open
        case preview
        case inspect
        case select
        case reorder
        case manage
        case custom(String)
    }

    enum Target: Hashable, Sendable {
        case card
        case sheet
        case grid
        case item
        case media
        case canvas
        case custom(String)
    }

    struct Context: Hashable, Sendable {
        public var source: String?
        public var prefersPreview: Bool
        public var isAsync: Bool
        public var capability: Capability?
        public var goal: ProductGoal?
        public var domain: Domain

        public init(
            source: String? = nil,
            prefersPreview: Bool = false,
            isAsync: Bool = false,
            capability: Capability? = nil,
            goal: ProductGoal? = nil,
            domain: Domain = .general
        ) {
            self.source = source
            self.prefersPreview = prefersPreview
            self.isAsync = isAsync
            self.capability = capability
            self.goal = goal
            self.domain = domain
        }
    }
}

public extension IKIntent {
    static func browse(_ mode: Browse = .read) -> Self {
        switch mode {
        case .read:
            return .init(
                verb: .preview,
                target: .card,
                context: .init(capability: .browse(mode), goal: .explore)
            )
        case .discover:
            return .init(
                verb: .open,
                target: .card,
                context: .init(capability: .browse(mode), goal: .explore)
            )
        case .inspect:
            return .init(
                verb: .inspect,
                target: .media,
                context: .init(capability: .browse(mode), goal: .inspect, domain: .media)
            )
        }
    }

    static func task(_ mode: Task = .manage) -> Self {
        .init(
            verb: .manage,
            target: .item,
            context: .init(capability: .task(mode), goal: .manage)
        )
    }

    static func selection(_ mode: Selection = .pick) -> Self {
        switch mode {
        case .pick, .edit:
            return .init(
                verb: .select,
                target: .item,
                context: .init(capability: .selection(mode), goal: .select)
            )
        case .reorder:
            return .init(
                verb: .reorder,
                target: .grid,
                context: .init(capability: .selection(mode), goal: .manage)
            )
        }
    }

    static func bookFlight() -> Self {
        .init(
            verb: .select,
            target: .item,
            context: .init(
                capability: .selection(.pick),
                goal: .compare,
                domain: .travelBooking
            )
        )
    }

    var capability: Capability {
        if let capability = context.capability {
            return capability
        }

        switch (verb, target) {
        case (.manage, _):
            return .task(.manage)
        case (.reorder, _):
            return .selection(.reorder)
        case (.select, _):
            return .selection(.pick)
        case (.inspect, _):
            return .browse(.inspect)
        case (.open, _):
            return .browse(.discover)
        case (.preview, _):
            return .browse(.read)
        default:
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
        if case .browse = capability { return true }
        return false
    }

    var allowsRotate: Bool {
        if case .browse(.inspect) = capability { return true }
        return false
    }
}
