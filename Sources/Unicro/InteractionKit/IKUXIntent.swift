//
//  IKUXIntent.swift
//  Unicro
//
//  Created by Lai Wei on 2026-01-23.
//

import SwiftUI

@available(*, deprecated, renamed: "IKIntent")
public typealias IKUXIntent = IKIntent

private struct UXIntentKey: EnvironmentKey {
    static let defaultValue: IKIntent = .browse(.read)
}

public extension EnvironmentValues {
    var uxIntent: IKIntent {
        get { self[UXIntentKey.self] }
        set { self[UXIntentKey.self] = newValue }
    }
}

public extension View {
    func uxIntent(_ intent: IKIntent) -> some View {
        environment(\.uxIntent, intent)
    }
}
