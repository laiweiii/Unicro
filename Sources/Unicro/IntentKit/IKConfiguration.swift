//
//  IKConfiguration.swift
//  Unicro
//
//  Created by Lai Wei on 2026-01-23.
//

import SwiftUI

// MARK: - Intent Model

public enum IKUXIntent: Hashable, Sendable {
    case browse(BrowseIntent = .read)
    case task(TaskIntent = .manage)
    case selection(SelectionIntent = .pick) // 可先不用，但建议留着
}

public enum BrowseIntent: Hashable, Sendable {
    case read
    case discover
    case inspect
}

public enum TaskIntent: Hashable, Sendable {
    case triage
    case manage
    case progress
}

public enum SelectionIntent: Hashable, Sendable {
    case pick
    case edit
    case reorder
}

public extension IKUXIntent {
    var allowsTaskSwipe: Bool {
        if case .task = self { return true }
        return false
    }

    var allowsStandardTap: Bool {
        true
    }

    var allowsLongPress: Bool {
        switch self {
        case .task, .selection:
            return true
        case .browse:
            return false
        }
    }

    var allowsDragPan: Bool {
        switch self {
        case .task, .selection:
            return true
        case .browse:
            return false
        }
    }

    var allowsPinch: Bool {
        if case .browse = self { return true }
        return false
    }

    var allowsRotate: Bool {
        if case .browse(.inspect) = self { return true }
        return false
    }
}

private struct UXIntentKey: EnvironmentKey {
    static let defaultValue: IKUXIntent = .browse(.read)
}

public extension EnvironmentValues {
    var uxIntent: IKUXIntent {
        get { self[UXIntentKey.self] }
        set { self[UXIntentKey.self] = newValue }
    }
}

public extension View {
    func uxIntent(_ intent: IKUXIntent) -> some View {
        environment(\.uxIntent, intent)
    }
}
