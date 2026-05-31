//
//  UnicroPresentedView.swift
//  Unicro
//
//  Created by Codex on 2026-05-30.
//

import SwiftUI

public struct UnicroPresentedView<Source: View, Destination: View>: View {
    private let source: Source
    private let payload: UnicroIntentPayload
    private let resolver: IKResolver
    private let sourceUnitPoint: UnitPoint?
    private let behavior: IKPresentationBehavior?
    private let destination: (_ dismiss: @escaping () -> Void) -> Destination

    public init(
        source: Source,
        payload: UnicroIntentPayload,
        resolver: IKResolver = .init(),
        sourceUnitPoint: UnitPoint? = nil,
        behavior: IKPresentationBehavior? = nil,
        @ViewBuilder destination: @escaping (_ dismiss: @escaping () -> Void) -> Destination
    ) {
        self.source = source
        self.payload = payload
        self.resolver = resolver
        self.sourceUnitPoint = sourceUnitPoint
        self.behavior = behavior
        self.destination = destination
    }

    public var body: some View {
        let intent = UnicroIntentFactory.makeIntent(from: payload)
        let resolved = resolver.resolve(intent)

        // This is the full design-to-code bridge: a static source view becomes
        // interactive only after the payload is resolved into a runtime recipe.
        return IKTransformerHost(
            recipe: resolved.recipe,
            sourceUnitPoint: sourceUnitPoint,
            behavior: behavior
        ) {
            source
        } destination: { dismiss in
            destination(dismiss)
        }
    }
}
