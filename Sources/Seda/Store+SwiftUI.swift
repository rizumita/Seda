//
//  Store+SwiftUI.swift
//  Seda
//
//  Created by 和泉田 領一 on 2019/09/10.
//

import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

@available(OSX 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension Store {
    public func binding<Value>(_ keyPath: KeyPath<S, Value>,
                               set: @escaping (Value) -> ActionType) -> Binding<Value> {
        Binding(get: { [weak self] in
            guard let this = self else { fatalError() }
            return this.state[keyPath: keyPath]
            }, set: { [weak self] value in
                self?.dispatch(set(value))
        })
    }
    
    public func binding<Value>(_ keyPath: KeyPath<S, Value>, unset: ActionType? = .none) -> Binding<Value> {
        Binding(get: { [weak self] in
            guard let this = self else { fatalError() }
            return this.state[keyPath: keyPath]
            }, set: { [weak self] value in
                guard let unset = unset else { return }
                self?.dispatch(unset)
        })
    }
    
    public func binding<Value>(_ keyPath: KeyPath<S, Value?>,
                               set: @escaping (Value?) -> ActionType,
                               defaultValue: Value) -> Binding<Value> {
        Binding(get: { [weak self] in
            guard let this = self else { fatalError() }
            return this.state[keyPath: keyPath] ?? defaultValue
            }, set: { [weak self] value in
                self?.dispatch(set(value))
        })
    }
    
    public func binding<Value>(_ keyPath: KeyPath<S, Value?>,
                               setAction: ActionType? = .none,
                               defaultValue: Value) -> Binding<Value> {
        Binding(get: { [weak self] in
            guard let this = self else { fatalError() }
            return this.state[keyPath: keyPath] ?? defaultValue
            }, set: { [weak self] value in
                guard let unset = setAction else { return }
                self?.dispatch(unset)
        })
    }

    public func substoreBinding<SubState: StateType>(_ keyPath: KeyPath<S, SubState>) -> Binding<Store<SubState>> {
        return Binding(get: { [weak self] in
            guard let this = self else { fatalError() }
            return this.substore(keyPath)
        }) { _ in }
    }

    public func substoreBinding<SubState: StateType>(_ keyPath: KeyPath<S, SubState?>, dismissAction: ActionType) -> Binding<Store<SubState>?> {        
        return Binding(get: { [weak self] in
            self?.substore(keyPath)
        }) { store in
            if store == nil {
                self.dispatch(dismissAction)
            }
        }
    }
}
