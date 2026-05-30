//
//  UnicroResolvedView.swift
//  Unicro
//
//  Created by Codex on 2026-05-30.
//

import SwiftUI

public struct UnicroResolvedView<Content: View>: View {
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
        let intent = UnicroIntentFactory.makeIntent(from: payload)
        let resolved = resolver.resolve(intent)

        return content.intent(intent) { binder in
            binder.recipe(resolved.recipe, callbacks: callbacks)
        }
    }
}
