//
//  StatefulView.swift
//  Seda
//
//  Created by 和泉田 領一 on 2019/09/09.
//

import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

@available(OSX 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public protocol StatefulView: View {
    associatedtype State: StateType
    associatedtype Substate: StateType = State
    associatedtype Action: BaseActionType = _DummyAction
    
    var store: Store<State> { get }
    var stateKeyPath: KeyPath<State, Substate> { get }
    var state: Substate { get }
}

@available(OSX 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public extension StatefulView {
    var state: Substate { store.state[keyPath: stateKeyPath] }
    
    func binding<Value>(_ keyPath: KeyPath<Substate, Value>,
                        set: @escaping (Value) -> ActionType) -> Binding<Value> {
        let compoundKeyPath = stateKeyPath.appending(path: keyPath)
        return store.binding(compoundKeyPath, set: set)
    }
    
    func binding<Value>(_ keyPath: KeyPath<Substate, Value>, unset: ActionType? = .none) -> Binding<Value> {
        let compoundKeyPath = stateKeyPath.appending(path: keyPath)
        return store.binding(compoundKeyPath, unset: unset)
    }
    
    func binding<Value>(_ keyPath: KeyPath<Substate, Value?>,
                        set: @escaping (Value?) -> ActionType,
                        defaultValue: Value) -> Binding<Value> {
        let compoundKeyPath = stateKeyPath.appending(path: keyPath)
        return store.binding(compoundKeyPath, set: set, defaultValue: defaultValue)
    }
    
    func binding<Value>(_ keyPath: KeyPath<Substate, Value?>,
                        unset: ActionType? = .none,
                        defaultValue: Value) -> Binding<Value> {
        let compoundKeyPath = stateKeyPath.appending(path: keyPath)
        return store.binding(compoundKeyPath, setAction: unset, defaultValue: defaultValue)
    }
}

@available(OSX 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public extension StatefulView where State == Substate {
    var stateKeyPath: KeyPath<State, Substate> { \State.self }
}

@available(OSX 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public extension StatefulView where Action == _DummyAction {
    func dispatch(_ action: ActionType) {
        store.dispatch(action)
    }
}

@available(OSX 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public extension StatefulView where Action: ActionType {
    func dispatch(_ action: Action) {
        store.dispatch(action)
    }
}

@available(OSX 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public struct _DummyAction: BaseActionType {}
