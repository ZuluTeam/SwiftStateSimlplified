//
//  Route.swift
//  SwiftStateSimlplified
//
//  Created by Ekaterina Zyryanova on 2019-06-12.
//  Copyright © 2019 ZuluTeam. All rights reserved.
//  Source code from SwiftState

import Foundation

public struct Route<S: StateType> {
    
    public let transition: Transition<S>
    public let condition: () -> Bool
    
    public init(transition: Transition<S>, condition: (() -> Bool)? = nil) {
        self.transition = transition
        self.condition = condition ?? {
            return true
        }
    }
    
}

