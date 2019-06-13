//
//  Transition.swift
//  SwiftStateSimlplified
//
//  Created by Ekaterina Zyryanova on 2019-06-12.
//  Copyright © 2019 ZuluTeam. All rights reserved.
//  Source code from SwiftState

import Foundation

public struct Transition<S: StateType>: Hashable {
    
    public let fromState: State<S>
    public let toState: State<S>
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(hashValue(fromState) &+ hashValue(toState).byteSwapped)
    }
    
    private func hashValue(_ state: State<S>) -> Int {
        return state.hashValue
    }
    
    private func hashValue(_ states: [State<S>]) -> Int {
        return states.reduce(5381) {
            ($0.hashValue << 5) &+ $0.hashValue &+ Int($1.hashValue)
        }
    }
}

public func == <StateType>(left: Transition<StateType>, right: Transition<StateType>) -> Bool {
    return left.fromState == right.fromState && left.toState == right.toState
}

// MARK: Custom Operators


precedencegroup TransitionPrecedence {
    lowerThan: TernaryPrecedence
    associativity: left
}
infix operator =>: TransitionPrecedence

public func => <StateType>(left: State<StateType>, right: State<StateType>) -> Transition<StateType> {
    return Transition(fromState: left, toState: right)
}

public func => <StateType>(left: State<StateType>, right: StateType) -> Transition<StateType> {
    return left => .Some(right)
}

public func => <StateType>(left: StateType, right: State<StateType>) -> Transition<StateType> {
    return .Some(left) => right
}

public func => <StateType>(left: StateType, right: StateType) -> Transition<StateType> {
    return .Some(left) => .Some(right)
}
