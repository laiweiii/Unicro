//
//  IKInteraction.swift
//  Unicro
//
//  Created by Codex on 2026-03-10.
//

import Foundation

public struct IKInteraction: Hashable, Sendable {
    public var pattern: Pattern
    public var gesture: GesturePrimitive
    public var motion: MotionPrimitive?
    public var feedback: FeedbackPrimitive?

    public init(
        pattern: Pattern,
        gesture: GesturePrimitive,
        motion: MotionPrimitive? = nil,
        feedback: FeedbackPrimitive? = nil
    ) {
        self.pattern = pattern
        self.gesture = gesture
        self.motion = motion
        self.feedback = feedback
    }
}

public extension IKInteraction {
    enum Pattern: Hashable, Sendable {
        case expand
        case sheet
        case preview
        case drag
        case gridRearrange
        case swipeAction
        case inspect
        case custom(String)
    }

    enum GesturePrimitive: Hashable, Sendable {
        case tap
        case longPress
        case drag
        case pinch
        case rotate
        case swipe
    }

    enum MotionPrimitive: Hashable, Sendable {
        case fluidExpand
        case fluidSheet
        case draggableGrid
        case spatialDrag
    }

    enum FeedbackPrimitive: Hashable, Sendable {
        case loading
        case shimmer
        case asyncState
    }
}
