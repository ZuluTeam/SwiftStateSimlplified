//
//  StateType.swift
//  SwiftStateSimlplified
//
//  Created by Ekaterina Zyryanova on 2019-06-12.
//  Copyright © 2019 ZuluTeam. All rights reserved.
//  Source code from SwiftState

import Foundation

public protocol StateType: Hashable { }

public enum State<S: StateType> {
    case Some(S)
    case `Any`
    
    public func contains(_ value: State) -> Bool {
        switch self {
        case .Any:
            return true
        default:
            return value.rawValue == self.rawValue
        }
    }
    
    public func contains(_ value: S) -> Bool {
        switch self {
        case .Any:
            return true
        default:
            return value == self.rawValue
        }
    }
}

extension State: Hashable {
    public var hashValue: Int {
        switch self {
        case .Some(let value):
            return value.hashValue
        default:
            return Int.min
        }
    }
}

extension State: RawRepresentable {
    
    public init(rawValue: S?) {
        if let rawValue = rawValue {
            self = .Some(rawValue)
        } else {
            self = .Any
        }
    }
    
    public var rawValue: S? {
        switch self {
        case .Some(let value):
            return value
        default:
            return nil
        }
    }
    
}

// MARK: - Equatable

extension State {
    public static func == <StateType>(left: State<StateType>, right: State<StateType>) -> Bool {
        switch (left, right) {
        case (.Some(let leftValue), .Some(let rightValue)):
            return leftValue == rightValue
        case (.Any, .Any):
            return true
        default:
            return false
        }
    }
    
    public static func == <StateType>(left: State<StateType>, right: StateType) -> Bool {
        switch left {
        case .Some(let value):
            return value == right
        default:
            return false
        }
    }
    
    public static func == <StateType>(left: StateType, right: State<StateType>) -> Bool {
        switch right {
        case .Some(let value):
            return value == left
        default:
            return false
        }
    }
}
