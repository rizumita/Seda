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
public protocol StatefulView where Self: View {
    associatedtype S: StateType
    associatedtype SS: StateType = S
    associatedtype Action: BaseActionType = _DummyAction
    
    var store: Store<S> { get }
    var stateKeyPath: KeyPath<S, SS> { get }
    var state: SS { get }
}

@available(OSX 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public extension StatefulView {
    var state: SS { store.state[keyPath: stateKeyPath] }
    
    func binding<Value>(_ keyPath: KeyPath<SS, Value>,
                        set: @escaping (Value) -> ActionType) -> Binding<Value> {
        let compoundKeyPath = stateKeyPath.appending(path: keyPath)
        return store.binding(compoundKeyPath, set: set)
    }
    
    func binding<Value>(_ keyPath: KeyPath<SS, Value>, unset: ActionType? = .none) -> Binding<Value> {
        let compoundKeyPath = stateKeyPath.appending(path: keyPath)
        return store.binding(compoundKeyPath, unset: unset)
    }
    
    func binding<Value>(_ keyPath: KeyPath<SS, Value?>,
                        set: @escaping (Value?) -> ActionType,
                        defaultValue: Value) -> Binding<Value> {
        let compoundKeyPath = stateKeyPath.appending(path: keyPath)
        return store.binding(compoundKeyPath, set: set, defaultValue: defaultValue)
    }
    
    func binding<Value>(_ keyPath: KeyPath<SS, Value?>,
                        unset: ActionType? = .none,
                        defaultValue: Value) -> Binding<Value> {
        let compoundKeyPath = stateKeyPath.appending(path: keyPath)
        return store.binding(compoundKeyPath, unset: unset, defaultValue: defaultValue)
    }
}

@available(OSX 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public extension StatefulView where S == SS {
    var stateKeyPath: KeyPath<S, SS> { \S.self }
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
