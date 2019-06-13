//
//  Machine.swift
//  SwiftStateSimlplified
//
//  Created by Ekaterina Zyryanova on 2019-06-12.
//  Copyright © 2019 ZuluTeam. All rights reserved.
//

import Foundation
import RxSwift

class Machine<S: StateType, E: EventType> {
    
    struct Context {
        let event: E?
        let fromState: S?
        let toState: S?
        var userInfo: Any? = nil
    }
    
    private var routes: [MachineEvent<E> : [Route<S>]] = [:]
    private(set) var state: S
    
    private let willChangeSubject : BehaviorSubject<Context>
    private let didChangeSubject: BehaviorSubject<Context>
    
    var willChange: Observable<Context> {
        return willChangeSubject.asObservable()
    }
    
    var didChange: Observable<Context> {
        return didChangeSubject.asObservable()
    }
    
    init(state: S, configure: ((Machine) -> ())? = nil) {
        let context = Context(event: nil, fromState: nil, toState: state)
        willChangeSubject = BehaviorSubject(value: context)
        self.state = state
        didChangeSubject = BehaviorSubject(value: context)
        configure?(self)
    }
    
    deinit {
        willChangeSubject.onCompleted()
        didChangeSubject.onCompleted()
        
    }
    
    func configure(_ closure: (Machine) -> ()) {
        closure(self)
    }
    
    // MARK: - Routes
    
    private func hasRoute(for event: E) -> Bool {
        return hasRoute(for: event, fromState: state, toState: nil)
    }
    
    private func hasRoute(for event: E, toState: S) -> Bool {
        return hasRoute(for: event, fromState: state, toState: toState)
    }
    
    private func hasRoute(for event: E, fromState: S, toState: S?) -> Bool {
        var state : State<S>? = nil
        if let toState = toState {
            state = .Some(toState)
        }
        return hasRoute(for: .Some(event), fromState: .Some(fromState), toState: state)
    }
    
    private func availableRoutes(for event: E) -> [Route<S>] {
        return availableRoutes(for: .Some(event))
    }
    
    private func availableRoutes(for event: MachineEvent<E>) -> [Route<S>] {
        return routes[event] ?? []
    }
    
    private func availableRoutes(for event: E, fromState: S) -> [Route<S>] {
        let routes = availableRoutes(for: event)
        return routes.filter({ $0.transition.fromState.contains(fromState) })
    }
    
    private func availableRoutes(fromState: S) -> [Route<S>] {
        let routes = availableRoutes(for: .Any)
        return routes.filter({ $0.transition.fromState.contains(fromState) })
    }
    
    // MARK: - Add route
    
    private func hasRoute(for event: MachineEvent<E>, transition: Transition<S>) -> Bool {
        return hasRoute(for: event, fromState: transition.fromState , toState: transition.toState)
    }
    
    private func hasRoute(for event: MachineEvent<E>, fromState: State<S>, toState: State<S>?) -> Bool {
        let transitions = availableRoutes(for: event)
        guard transitions.count > 0  else {
            return false
        }
        for route in transitions {
            let fromAvailable = route.transition.fromState.contains(fromState)
            guard let toState = toState else {
                return fromAvailable
            }
            if fromAvailable && route.transition.toState.contains(toState) {
                return true
            }
        }
        return false
    }
    
    public func addRoute(_ event: E, _ transition: Transition<S>, condition: (() -> Bool)? = nil) {
        self.addRoute(.Some(event), transition, condition: condition)
    }
    
    public func addRoute(_ transition: Transition<S>, condition: (() -> Bool)? = nil) {
        self.addRoute(.Any, transition, condition: condition)
    }
    
    public func addRoute(_ event: MachineEvent<E> = .Any, _ transition: Transition<S>, condition: (() -> Bool)? = nil) {
        if !hasRoute(for: event, transition: transition) {
            let route = Route(transition: transition, condition: condition)
            if self.routes[event] == nil {
                self.routes[event] = []
            }
            self.routes[event]?.append(route)
        }
    }
    
    public func addRoutes(_ event: E, transitions: [Transition<S>]) {
        for transition in transitions {
            addRoute(event, transition)
        }
    }
    
    // MARK: - Event Handling
    
    private func nextState(for event: E) -> S? {
        let availableRoutes = self.availableRoutes(for: event, fromState: state)
        for route in availableRoutes {
            if route.condition() {
                return route.transition.toState.rawValue
            }
        }
        return nil
    }
    
    private func nextState() -> S? {
        let availableRoutes = self.availableRoutes(fromState: state)
        for route in availableRoutes {
            if route.condition() {
                return route.transition.toState.rawValue
            }
        }
        return nil
    }
    
    // if state do not require event to go further it will be changed automatically to next one
    func handleEvent(_ event: E, with userInfo: Any? = nil) {
        if let nextState = nextState(for: event) {
            var context = Context(event: event, fromState: state, toState: nextState)
            context.userInfo = userInfo
            willChangeSubject.onNext(context)
            state = nextState
            didChangeSubject.onNext(context)
            
            setNextStateIfAvailable()
        } else {
            var context = Context(event: event, fromState: state, toState: nil)
            context.userInfo = userInfo
            willChangeSubject.onNext(context)
            didChangeSubject.onNext(context)
        }
    }
    
    func setNextStateIfAvailable() {
        if let nextState = nextState() {
            let context = Context(event: nil, fromState: state, toState: nextState)
            willChangeSubject.onNext(context)
            state = nextState
            didChangeSubject.onNext(context)
            
            setNextStateIfAvailable()
        }
    }
}
