//
//  SwipePolicy.swift
//  Unicro
//
//  Created by Lai Wei on 2026-01-23.
//

// MARK: - Swipe Policy
import SwiftUI



public struct SwipeBehavior: Sendable {
    public enum CommitLevel: Sendable {
        case revealOnly
        case commitOnThreshold
        case commitOnFull
    }

    public let commitLevel: CommitLevel
    public let triggerThreshold: CGFloat
    public let rubberBand: CGFloat
    public let hapticsOnTrigger: Bool

    public init(
        commitLevel: CommitLevel = .revealOnly,
        triggerThreshold: CGFloat = 90,
        rubberBand: CGFloat = 0.25,
        hapticsOnTrigger: Bool = true
    ) {
        self.commitLevel = commitLevel
        self.triggerThreshold = triggerThreshold
        self.rubberBand = rubberBand
        self.hapticsOnTrigger = hapticsOnTrigger
    }
}

public struct SwipeCallbacks: Sendable {
    public let onReveal: (() -> Void)?
    public let onCommit: (() -> Void)?

    public init(onReveal: (() -> Void)? = nil, onCommit: (() -> Void)? = nil) {
        self.onReveal = onReveal
        self.onCommit = onCommit
    }
}

public struct TaskSwipeConfig: Sendable {
    public let behavior: SwipeBehavior
    public let callbacks: SwipeCallbacks

    public init(behavior: SwipeBehavior, callbacks: SwipeCallbacks) {
        self.behavior = behavior
        self.callbacks = callbacks
    }
}


public struct TaskSwipeModifier: ViewModifier {
    let enabled: Bool
    let config: TaskSwipeConfig

    let leftRevealWidth: CGFloat
    let rightRevealWidth: CGFloat
    let leftView: AnyView
    let rightView: AnyView

    @GestureState private var dragX: CGFloat = 0
    @State private var offsetX: CGFloat = 0

    public init(
        enabled: Bool,
        config: TaskSwipeConfig,
        leftRevealWidth: CGFloat = 0,
        rightRevealWidth: CGFloat = 0,
        leftView: AnyView = AnyView(EmptyView()),
        rightView: AnyView = AnyView(EmptyView())
    ) {
        self.enabled = enabled
        self.config = config
        self.leftRevealWidth = leftRevealWidth
        self.rightRevealWidth = rightRevealWidth
        self.leftView = leftView
        self.rightView = rightView
    }

    public func body(content: Content) -> some View {
        ZStack {
            HStack(spacing: 0) {
                leftView
                    .frame(width: leftRevealWidth, alignment: .leading)
                Spacer(minLength: 0)
                rightView
                    .frame(width: rightRevealWidth, alignment: .trailing)
            }

            content
                .contentShape(Rectangle())
                .offset(x: enabled ? (offsetX + dragX) : 0)
                .gesture(enabled ? dragGesture() : nil)
                .animation(.snappy(duration: 0.22), value: offsetX)
        }
        .clipped()
    }

    private func dragGesture() -> some Gesture {
        DragGesture(minimumDistance: 8, coordinateSpace: .local)
            .updating($dragX) { value, state, _ in
                state = applyRubberBand(value.translation.width, factor: config.behavior.rubberBand)
            }
            .onEnded { value in
                handleEnd(x: value.translation.width)
            }
    }

    private func applyRubberBand(_ x: CGFloat, factor: CGFloat) -> CGFloat {
        let sign: CGFloat = x >= 0 ? 1 : -1
        let absX = abs(x)
        return sign * (absX / (1 + absX * factor / 300))
    }

    private func revealOffset(for x: CGFloat) -> CGFloat {
        if x >= 0 { return leftRevealWidth }
        else { return -rightRevealWidth }
    }

    private func handleEnd(x: CGFloat) {
        let absX = abs(x)

        switch config.behavior.commitLevel {
        case .revealOnly:
            if absX >= config.behavior.triggerThreshold {
                config.callbacks.onReveal?()
                hapticIfNeeded()
                offsetX = revealOffset(for: x)   // ✅ 停住
            } else {
                offsetX = 0
            }

        case .commitOnThreshold:
            if absX >= config.behavior.triggerThreshold {
                config.callbacks.onCommit?()
                hapticIfNeeded()
            }
            offsetX = 0

        case .commitOnFull:
            let fullThreshold = config.behavior.triggerThreshold * 1.8
            let revealWidth = x < 0 ? rightRevealWidth : leftRevealWidth
            let revealTrigger = min(config.behavior.triggerThreshold, revealWidth)

            if absX >= fullThreshold {
                config.callbacks.onCommit?()
                hapticIfNeeded()
                offsetX = 0
            } else if absX >= revealTrigger {
                config.callbacks.onReveal?()
                hapticIfNeeded()
                offsetX = revealOffset(for: x)
            } else {
                offsetX = 0
            }

        }
    }

    private func hapticIfNeeded() {
        guard config.behavior.hapticsOnTrigger else { return }
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
    }
}




