//
//  Store.swift
//  Seda
//
//  Created by 和泉田 領一 on 2019/09/09.
//

import Foundation
#if canImport(Combine)
import Combine
#endif

@available(OSX 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public class Store<S>: ObservableObject, Identifiable where S: StateType {
    public let id = UUID()
    public let objectWillChange = PassthroughSubject<S, Never>()
    private var isEqualState: ((S, S) -> Bool)?
    private var cancellables = Set<AnyCancellable>()
    
    private let reducer: Reducer<S>
    @Published public private(set) var state: S {
        willSet {
            if let isEqualState = isEqualState,
                isEqualState(state, newValue) {
                return
            }
            
            let label = String(cString: __dispatch_queue_get_label(.none), encoding: .utf8)

            if label == DispatchQueue.main.label {
                objectWillChange.send(newValue)
            } else {
                DispatchQueue.main.async {
                    self.objectWillChange.send(newValue)
                }
            }
        }
    }
    private let queue: DispatchQueue
    
    public init(reducer: @escaping Reducer<S>,
                stateInit: () -> (S, Command),
                isEqual: ((S, S) -> Bool)? = .none,
                queue: DispatchQueue = .main) {
        let (state, command) = stateInit()
        
        self.reducer = reducer
        self.state = state
        self.isEqualState = isEqual
        self.queue = queue
        
        command.dispatch(self.dispatchBase)
    }
    
    public init(reducer: @escaping Reducer<S>,
                state: S,
                isEqual: ((S, S) -> Bool)? = .none,
                queue: DispatchQueue = .main) {
        self.reducer = reducer
        self.state = state
        self.isEqualState = isEqual
        self.queue = queue
    }
    
    public func dispatch(_ action: ActionType) {
        dispatchBase(action)
    }
    
    fileprivate func dispatchBase(_ action: BaseActionType) {
        let label = String(cString: __dispatch_queue_get_label(.none), encoding: .utf8)
        let d: () -> () = {
            let (newState, command) = self.reducer(action, self.state)
            self.state = newState
            command.dispatch(self.dispatchBase)
        }

        if queue.label == label {
            d()
        } else {
            queue.async {
                d()
            }
        }
    }
}
