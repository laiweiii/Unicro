//
//  UnicroAdapter.swift
//  Unicro
//
//  Created by Codex on 2026-05-30.
//

import SwiftUI

public struct UnicroAdapter<Content: View>: View {
    private let content: Content
    private let payload: UnicroIntentPayload
    private let resolver: IKResolver
    private let callbacks: IKInteractionExecutionCallbacks

    public init(
        content: Content,
        payload: UnicroIntentPayload,
        resolver: IKResolver = .init(),
        callbacks: IKInteractionExecutionCallbacks = .init()
    ) {
        self.content = content
        self.payload = payload
        self.resolver = resolver
        self.callbacks = callbacks
    }

    public var body: some View {
        UnicroResolvedView(
            content: content,
            payload: payload,
            resolver: resolver,
            callbacks: callbacks
        )
    }
}
