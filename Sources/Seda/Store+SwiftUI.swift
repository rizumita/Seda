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
    public func binding<Value>(_ actionable: @escaping (Value) -> ActionType,
                               _ keyPath: KeyPath<S, Value>) -> Binding<Value> {
        Binding(get: { [weak self] in
            guard let this = self else { fatalError() }
            return this.state[keyPath: keyPath]
            }, set: { [weak self] value in
                self?.dispatch(actionable(value))
        })
    }
    
    public func selectedBinding<SubState: StateType>(_ keyPath: KeyPath<S, SubState?>, dismissAction: ActionType) -> Binding<Store<SubState>?> {
        Binding(get: {
            self.selected(keyPath)
        }) { store in
            if store == nil {
                self.dispatch(dismissAction)
            }
        }
    }
}
