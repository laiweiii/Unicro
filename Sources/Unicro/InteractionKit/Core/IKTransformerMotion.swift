//
//  IKTransformerMotion.swift
//  Unicro
//
//  Created by Codex on 2026-03-10.
//

import SwiftUI

public struct IKAnchoredPopupMotionConfiguration: Sendable {
    public var collapsedWidthRatio: CGFloat
    public var collapsedHeightRatio: CGFloat
    public var collapsedOpacity: CGFloat
    public var collapsedYOffset: CGFloat
    public var animation: Animation

    public static let standard = IKAnchoredPopupMotionConfiguration(
        collapsedWidthRatio: 0.5,
        collapsedHeightRatio: 0.5,
        collapsedOpacity: 0,
        collapsedYOffset: 140,
        animation: .spring(response: 0.4, dampingFraction: 0.8)
    )

    public init(
        collapsedWidthRatio: CGFloat = 0.5,
        collapsedHeightRatio: CGFloat = 0.5,
        collapsedOpacity: CGFloat = 0,
        collapsedYOffset: CGFloat = 140,
        animation: Animation = .spring(response: 0.4, dampingFraction: 0.8)
    ) {
        self.collapsedWidthRatio = collapsedWidthRatio
        self.collapsedHeightRatio = collapsedHeightRatio
        self.collapsedOpacity = collapsedOpacity
        self.collapsedYOffset = collapsedYOffset
        self.animation = animation
    }
}

public struct IKBottomRevealMotionConfiguration: Sendable {
    public var maxExpandedHeightRatio: CGFloat
    public var minTopSpacing: CGFloat
    public var settleThresholdTravelRatio: CGFloat
    public var upwardVelocityThreshold: CGFloat
    public var downwardVelocityThreshold: CGFloat
    public var animation: Animation

    public static let standard = IKBottomRevealMotionConfiguration(
        maxExpandedHeightRatio: 0.72,
        minTopSpacing: 24,
        settleThresholdTravelRatio: 0.18,
        upwardVelocityThreshold: -20,
        downwardVelocityThreshold: 20,
        animation: .spring(response: 0.38, dampingFraction: 0.84)
    )

    public init(
        maxExpandedHeightRatio: CGFloat = 0.72,
        minTopSpacing: CGFloat = 24,
        settleThresholdTravelRatio: CGFloat = 0.18,
        upwardVelocityThreshold: CGFloat = -20,
        downwardVelocityThreshold: CGFloat = 20,
        animation: Animation = .spring(response: 0.38, dampingFraction: 0.84)
    ) {
        self.maxExpandedHeightRatio = maxExpandedHeightRatio
        self.minTopSpacing = minTopSpacing
        self.settleThresholdTravelRatio = settleThresholdTravelRatio
        self.upwardVelocityThreshold = upwardVelocityThreshold
        self.downwardVelocityThreshold = downwardVelocityThreshold
        self.animation = animation
    }
}

public enum IKTransformerMotionPreset: Sendable {
    case anchoredPopup(IKAnchoredPopupMotionConfiguration = .standard)
    case bottomReveal(IKBottomRevealMotionConfiguration = .standard)
    case custom(String)
}

public extension IKInteractionRecipe.Transformer {
    var defaultMotionPreset: IKTransformerMotionPreset? {
        switch self {
        case .anchoredPopup:
            return .anchoredPopup(.standard)
        case .bottomReveal:
            return .bottomReveal(.standard)
        case .pushTransform, .custom:
            return nil
        }
    }
}

public extension IKTransformerMotionPreset {
    var anchoredPopupConfiguration: IKAnchoredPopupMotionConfiguration? {
        guard case .anchoredPopup(let config) = self else { return nil }
        return config
    }

    var bottomRevealConfiguration: IKBottomRevealMotionConfiguration? {
        guard case .bottomReveal(let config) = self else { return nil }
        return config
    }
}

public struct IKAnchoredPopupMotion<Content: View>: View {
    let isExpanded: Bool
    let config: IKAnchoredPopupMotionConfiguration
    let content: Content

    public init(
        isExpanded: Bool,
        config: IKAnchoredPopupMotionConfiguration = .standard,
        @ViewBuilder content: () -> Content
    ) {
        self.isExpanded = isExpanded
        self.config = config
        self.content = content()
    }

    public var body: some View {
        content
            .opacity(isExpanded ? 1 : config.collapsedOpacity)
            .scaleEffect(
                x: isExpanded ? 1 : max(config.collapsedWidthRatio, 0.01),
                y: isExpanded ? 1 : max(config.collapsedHeightRatio, 0.01),
                anchor: .bottom
            )
            .offset(y: isExpanded ? 0 : config.collapsedYOffset)
            .clipped()
            .animation(config.animation, value: isExpanded)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
}

public struct IKBottomRevealMotion<Content: View>: View {
    @Binding var position: SheetPosition
    let config: IKBottomRevealMotionConfiguration
    let content: Content

    @GestureState private var dragOffset: CGFloat = 0
    @State private var contentHeight: CGFloat = 0

    public init(
        position: Binding<SheetPosition>,
        config: IKBottomRevealMotionConfiguration = .standard,
        @ViewBuilder content: () -> Content
    ) {
        self._position = position
        self.config = config
        self.content = content()
    }

    public var body: some View {
        GeometryReader { geo in
            let screenHeight = geo.size.height
            let measuredHeight = max(contentHeight, 1)
            let expandedHeight = min(measuredHeight, screenHeight * config.maxExpandedHeightRatio)
            let expandedY = max(screenHeight - expandedHeight, config.minTopSpacing)
            let hiddenY = screenHeight
            let targetY = targetOffset(hiddenY: hiddenY, expandedY: expandedY)
            let sheetY = max(expandedY, min(hiddenY, targetY + dragOffset))
            let travelDistance = max(hiddenY - expandedY, 1)
            let settleThreshold = travelDistance * config.settleThresholdTravelRatio

            VStack(spacing: 0) {
                content
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .preference(key: IKBottomRevealMeasuredHeightKey.self, value: proxy.size.height)
                        }
                    )
                Spacer(minLength: 0)
            }
            .frame(width: geo.size.width)
            .offset(y: sheetY)
            .gesture(
                DragGesture(minimumDistance: 10)
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation.height
                    }
                    .onEnded { value in
                        let velocity = value.predictedEndLocation.y - value.location.y
                        let dragDistance = abs(value.translation.height)

                        let finalPosition: SheetPosition
                        if value.translation.height < 0 &&
                            (velocity < config.upwardVelocityThreshold || dragDistance > settleThreshold) {
                            finalPosition = .expanded
                        } else if value.translation.height > 0 &&
                            (velocity > config.downwardVelocityThreshold || dragDistance > settleThreshold) {
                            finalPosition = .collapsed
                        } else {
                            finalPosition = position
                        }

                        withAnimation(config.animation) {
                            position = finalPosition
                        }
                    }
            )
            .onPreferenceChange(IKBottomRevealMeasuredHeightKey.self) { contentHeight = $0 }
            .animation(nil, value: position)
        }
    }

    private func targetOffset(hiddenY: CGFloat, expandedY: CGFloat) -> CGFloat {
        switch position {
        case .collapsed:
            return hiddenY
        case .expanded:
            return expandedY
        case .custom(let ratio):
            let customHeightRatio = max(0, min(1, ratio))
            return max(expandedY, hiddenY * (1 - customHeightRatio))
        }
    }
}

private struct IKBottomRevealMeasuredHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
