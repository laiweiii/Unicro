//
//  IKResolverProtocol.swift
//  Unicro
//
//  Created by Codex on 2026-03-10.
//

import Foundation

public protocol IKIntentResolving: Sendable {
    func resolve(_ intent: IKIntent) -> IKResolvedInteraction
}
