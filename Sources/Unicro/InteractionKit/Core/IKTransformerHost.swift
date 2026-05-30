//
//  IKTransformerHost.swift
//  Unicro
//
//  Created by Codex on 2026-03-11.
//

import SwiftUI

public struct IKPresentationBehavior: Hashable, Sendable {
    public var showsBackdrop: Bool
    public var backdropOpacity: Double
    public var tapOutsideToDismiss: Bool

    public init(
        showsBackdrop: Bool = true,
        backdropOpacity: Double = 0.14,
        tapOutsideToDismiss: Bool = true
    ) {
        self.showsBackdrop = showsBackdrop
        self.backdropOpacity = backdropOpacity
        self.tapOutsideToDismiss = tapOutsideToDismiss
    }
}

public extension IKInteractionRecipe.Transformer {
    var defaultPresentationBehavior: IKPresentationBehavior {
        switch self {
        case .anchoredPopup:
            return .init(showsBackdrop: true, backdropOpacity: 0.14, tapOutsideToDismiss: true)
        case .bottomReveal:
            return .init(showsBackdrop: true, backdropOpacity: 0.14, tapOutsideToDismiss: true)
        case .pushTransform, .custom:
            return .init(showsBackdrop: false, backdropOpacity: 0, tapOutsideToDismiss: false)
        }
    }
}

public struct IKTransformerHost<Source: View, Destination: View>: View {
    private let recipe: IKInteractionRecipe
    private let sourceUnitPoint: UnitPoint?
    private let behavior: IKPresentationBehavior
    private let source: () -> Source
    private let destination: (_ dismiss: @escaping () -> Void) -> Destination

    @State private var isAnchoredPopupPresented = false
    @State private var isBottomSheetPresented = false

    public init(
        recipe: IKInteractionRecipe,
        sourceUnitPoint: UnitPoint? = nil,
        behavior: IKPresentationBehavior? = nil,
        @ViewBuilder source: @escaping () -> Source,
        @ViewBuilder destination: @escaping (_ dismiss: @escaping () -> Void) -> Destination
    ) {
        self.recipe = recipe
        self.sourceUnitPoint = sourceUnitPoint
        self.behavior = behavior ?? recipe.transformer.defaultPresentationBehavior
        self.source = source
        self.destination = destination
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            source()
                .intent(recipe.resolvedIntent) { binder in
                    binder.recipe(
                        recipe,
                        callbacks: .init(
                            onTrigger: present
                        )
                    )
                }

            if behavior.showsBackdrop {
                backdrop
            }

            presentedLayer
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .sheet(isPresented: bottomSheetBinding) {
            if #available(iOS 16.0, *) {
                destination(dismiss)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            } else {
                // Fallback on earlier versions
            }
        }
    }

    @ViewBuilder
    private var backdrop: some View {
        let isVisible = isBackdropVisible

        Color.black
            .opacity(isVisible ? behavior.backdropOpacity : 0)
            .allowsHitTesting(isVisible && behavior.tapOutsideToDismiss)
            .onTapGesture {
                guard behavior.tapOutsideToDismiss else { return }
                dismiss()
            }
    }

    @ViewBuilder
    private var presentedLayer: some View {
        switch recipe.transformer {
        case .anchoredPopup:
            IKAnchoredPopupMotion(
                isExpanded: isAnchoredPopupPresented,
                sourceUnitPoint: sourceUnitPoint,
                config: recipe.transformer.defaultMotionPreset?.anchoredPopupConfiguration ?? .standard
            ) {
                destination(dismiss)
            }
            .allowsHitTesting(isAnchoredPopupPresented)
        case .bottomReveal:
            EmptyView()
        case .pushTransform, .custom:
            EmptyView()
        }
    }

    private var isBackdropVisible: Bool {
        switch recipe.transformer {
        case .anchoredPopup:
            return isAnchoredPopupPresented
        case .bottomReveal:
            return false
        case .pushTransform, .custom:
            return false
        }
    }

    private func present() {
        withAnimation(presentationAnimation) {
            switch recipe.transformer {
            case .anchoredPopup:
                isAnchoredPopupPresented = true
            case .bottomReveal:
                isBottomSheetPresented = true
            case .pushTransform, .custom:
                break
            }
        }
    }

    private func dismiss() {
        withAnimation(presentationAnimation) {
            switch recipe.transformer {
            case .anchoredPopup:
                isAnchoredPopupPresented = false
            case .bottomReveal:
                isBottomSheetPresented = false
            case .pushTransform, .custom:
                break
            }
        }
    }

    private var presentationAnimation: Animation {
        switch recipe.transformer.defaultMotionPreset {
        case .anchoredPopup(let config):
            return config.animation
        case .bottomReveal:
            return .spring(response: 0.38, dampingFraction: 0.84)
        case .custom, .none:
            return .spring(response: 0.4, dampingFraction: 0.8)
        }
    }

    private var bottomSheetBinding: Binding<Bool> {
        Binding(
            get: { recipe.transformer == .bottomReveal && isBottomSheetPresented },
            set: { isBottomSheetPresented = $0 }
        )
    }
}
