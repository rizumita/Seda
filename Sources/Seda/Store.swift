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
                DispatchQueue.main.async { [weak self] in
                    self?.objectWillChange.send(newValue)
                }
            }
        }
    }
    private let queue: DispatchQueue
    private var parent: AnyStore?
    private var substores = [AnyKeyPath : AnyStore]()

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
        if let parent = parent {
            parent.dispatch(action)
        } else {
            let label = String(cString: __dispatch_queue_get_label(.none), encoding: .utf8)
            let d: () -> () = { [weak self] in
                guard let `self` = self else { return }
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
    
    public func substore<SubState: StateType>(_ keyPath: KeyPath<S, SubState>) -> Store<SubState> {
        if let store = substores[keyPath]?.store as? Store<SubState> {
            return store
        }
        
        let result = Store<SubState>(reducer: { _, _ in fatalError() }, state: state[keyPath: keyPath], queue: queue)
        result.parent = AnyStore(self)
        
        $state.map(keyPath).receive(on: queue).sink { [weak result] state in
            result?.state = state
        }.store(in: &result.cancellables)
        
        return result
    }
    
    public func substore<SubState: StateType>(_ keyPath: KeyPath<S, SubState?>) -> Store<SubState>? {
        guard let subState = state[keyPath: keyPath] else { return .none }
        
        if let store = substores[keyPath]?.store as? Store<SubState> {
            return store
        }
        
        let result = Store<SubState>(reducer: { _, _ in fatalError() }, state: subState, queue: queue)
        result.parent = AnyStore(self)
        
        $state.map(keyPath).receive(on: queue).sink { [weak self, weak result] state in
            guard let state = state else {
                self?.substores.removeValue(forKey: keyPath)
                return
            }
            result?.state = state
        }.store(in: &result.cancellables)
        
        substores[keyPath] = AnyStore(result)
        
        return result
    }
}

@available(OSX 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
struct AnyStore {
    let dispatch: (BaseActionType) -> ()
    let store: Any
    
    init<S: StateType>(_ store: Store<S>) {
        self.dispatch = store.dispatchBase
        self.store = store
    }
}
