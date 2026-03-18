//
//  TrafficVocabulary.swift
//  Unicro
//
//  Created by Codex on 2026-03-10.
//

import Foundation

public enum TrafficVocabulary {
    public static let domain: IKIntent.Domain = "traffic"

    public enum Entity {
        public static let event: IKIntent.Entity = "event"
        public static let journey: IKIntent.Entity = "journey"
        public static let mapElement: IKIntent.Entity = "map_element"
    }

    public enum DomainEntity {
        public static let incident = "incident"
        public static let route = "route"
        public static let trip = "trip"
        public static let pin = "pin"
    }

    public enum DomainState {
        public static let awareness = "awareness"
        public static let activeNavigation = "activeNavigation"
    }
}
