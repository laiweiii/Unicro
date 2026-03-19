//
//  IKInteractionExecutor.swift
//  Unicro
//
//  Created by Codex on 2026-03-10.
//

import SwiftUI

public struct IKInteractionExecutionCallbacks: Sendable {
    public var onTrigger: (() -> Void)?
    public var onReveal: (() -> Void)?
    public var onCommit: (() -> Void)?

    public init(
        onTrigger: (() -> Void)? = nil,
        onReveal: (() -> Void)? = nil,
        onCommit: (() -> Void)? = nil
    ) {
        self.onTrigger = onTrigger
        self.onReveal = onReveal
        self.onCommit = onCommit
    }
}

public extension IKInteractionRecipe.Transformer {
    var defaultTapBehavior: TapBehavior {
        switch self {
        case .anchoredPopup, .bottomReveal, .pushTransform, .custom:
            return .init(kind: .single, hapticsOnTrigger: true)
        }
    }

    var defaultSwipeBehavior: SwipeBehavior {
        switch self {
        case .anchoredPopup:
            return .init(commitLevel: .revealOnly, triggerThreshold: 72, rubberBand: 0.18, hapticsOnTrigger: true)
        case .bottomReveal:
            return .init(commitLevel: .revealOnly, triggerThreshold: 88, rubberBand: 0.22, hapticsOnTrigger: true)
        case .pushTransform, .custom:
            return .init()
        }
    }
}

public extension InteractionBinder {
    func recipe(
        _ interactionRecipe: IKInteractionRecipe,
        callbacks: IKInteractionExecutionCallbacks = .init()
    ) -> some View {
        switch interactionRecipe.interaction.gesture {
        case .tap:
            return AnyView(
                tap { spec in
                    let behavior = interactionRecipe.transformer.defaultTapBehavior
                    spec.behaviour(behavior.kind, haptics: behavior.hapticsOnTrigger)
                    if let onTrigger = callbacks.onTrigger {
                        spec.onTrigger(onTrigger)
                    }
                }
            )
        case .swipe:
            return AnyView(
                swipe { spec in
                    let behavior = interactionRecipe.transformer.defaultSwipeBehavior
                    spec.behaviour(
                        behavior.commitLevel,
                        threshold: behavior.triggerThreshold,
                        rubberBand: behavior.rubberBand,
                        haptics: behavior.hapticsOnTrigger
                    )
                    if let onReveal = callbacks.onReveal {
                        spec.onReveal(onReveal)
                    }
                    if let onCommit = callbacks.onCommit {
                        spec.onCommit(onCommit)
                    }
                }
            )
        case .drag:
            return AnyView(
                drag { spec in
                    spec.onEnd { _ in
                        callbacks.onCommit?()
                    }
                }
            )
        case .pinch:
            return AnyView(
                pinch { spec in
                    spec.onEnd { _ in
                        callbacks.onCommit?()
                    }
                }
            )
        case .longPress:
            return AnyView(
                longPress { spec in
                    spec.onTrigger {
                        callbacks.onTrigger?()
                    }
                }
            )
        case .rotate:
            return AnyView(
                rotate { spec in
                    spec.onEnd { _ in
                        callbacks.onCommit?()
                    }
                }
            )
        }
    }

    func recipe(
        _ interactionRecipe: IKInteractionRecipe,
        trailingRevealWidth: CGFloat,
        @ViewBuilder trailingReveal: () -> some View,
        callbacks: IKInteractionExecutionCallbacks = .init()
    ) -> some View {
        guard interactionRecipe.interaction.gesture == .swipe else {
            return AnyView(recipe(interactionRecipe, callbacks: callbacks))
        }

        return AnyView(
            swipe { spec in
                let behavior = interactionRecipe.transformer.defaultSwipeBehavior
                spec.behaviour(
                    behavior.commitLevel,
                    threshold: behavior.triggerThreshold,
                    rubberBand: behavior.rubberBand,
                    haptics: behavior.hapticsOnTrigger
                )
                spec.reveal(edge: .trailing, width: trailingRevealWidth) {
                    trailingReveal()
                }
                if let onReveal = callbacks.onReveal {
                    spec.onReveal(onReveal)
                }
                if let onCommit = callbacks.onCommit {
                    spec.onCommit(onCommit)
                }
            }
        )
    }
}
