//
//  GeneratedView+Unicro.swift
//  Unicro
//
//  Created by Codex on 2026-05-30.
//

import SwiftUI

public extension View {
    func unicro(
        _ payload: UnicroIntentPayload,
        resolver: IKResolver = .init()
    ) -> some View {
        UnicroAdapter(
            content: self,
            payload: payload,
            resolver: resolver
        )
    }

    func unicro(
        _ payload: UnicroIntentPayload,
        resolver: IKResolver = .init(),
        callbacks: IKInteractionExecutionCallbacks
    ) -> some View {
        UnicroAdapter(
            content: self,
            payload: payload,
            resolver: resolver,
            callbacks: callbacks
        )
    }

    func unicro<Destination: View>(
        _ payload: UnicroIntentPayload,
        resolver: IKResolver = .init(),
        sourceUnitPoint: UnitPoint? = nil,
        behavior: IKPresentationBehavior? = nil,
        @ViewBuilder destination: @escaping (_ dismiss: @escaping () -> Void) -> Destination
    ) -> some View {
        UnicroPresentedView(
            source: self,
            payload: payload,
            resolver: resolver,
            sourceUnitPoint: sourceUnitPoint,
            behavior: behavior,
            destination: destination
        )
    }
}
