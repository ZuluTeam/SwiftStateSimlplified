//
//  EventType.swift
//  SwiftStateSimlplified
//
//  Created by Ekaterina Zyryanova on 2019-06-12.
//  Copyright © 2019 ZuluTeam. All rights reserved.
//  Source code from SwiftState

import Foundation

public protocol EventType: Hashable {}

public enum MachineEvent<E: EventType> {
    case Some(E)
    case `Any`
}

extension MachineEvent: Hashable {
    public var hashValue: Int {
        switch self {
        case .Some(let value):
            return value.hashValue
        default:
            return Int.min
        }
    }
}

extension MachineEvent: RawRepresentable {
    public init(rawValue: E?) {
        if let rawValue = rawValue {
            self = .Some(rawValue)
        } else {
            self = .Any
        }
    }
    
    public var rawValue: E? {
        switch self {
        case .Some(let value):
            return value
        default:
            return nil
        }
    }
}

// MARK: Equatable

extension MachineEvent {
    
    public static func == <EventType>(left: MachineEvent<EventType>, right: MachineEvent<EventType>) -> Bool {
        switch (left, right) {
        case (.Some(let leftValue), .Some(let rightValue)):
            return leftValue == rightValue
        case (.Any, .Any):
            return true
        default:
            return false
        }
    }
    
    public static func == <EventType>(left: MachineEvent<EventType>, right: EventType) -> Bool {
        switch left {
        case .Some(let value):
            return value == right
        default:
            return false
        }
    }
    
    public static func == <EventType>(left: EventType, right: MachineEvent<EventType>) -> Bool {
        switch right {
        case .Some(let value):
            return value == left
        default:
            return false
        }
    }
}
