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

        public init(
            source: String? = nil,
            prefersPreview: Bool = false,
            isAsync: Bool = false
        ) {
            self.source = source
            self.prefersPreview = prefersPreview
            self.isAsync = isAsync
        }
    }
}
