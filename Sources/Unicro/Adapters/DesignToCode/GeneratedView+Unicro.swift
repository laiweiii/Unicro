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
}
