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

#if swift(>=5.1)
@available(OSX 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public class Store<S>: ObservableObject where S: StateType {
    public var objectWillChange = PassthroughSubject<S, Never>()
    private var parent: AnyStore?
    private var cancellables = Set<AnyCancellable>()
    
    private let reducer: Reducer<S>
    @Published public private(set) var state: S {
        willSet {
            DispatchQueue.main.async {
                self.objectWillChange.send(self.state)
            }
        }
    }
    private let queue: DispatchQueue
    
    public init(reducer: @escaping Reducer<S>, state: S, queue: DispatchQueue = DispatchQueue(label: "Seda.Store.queue")) {
        self.reducer = reducer
        self.state = state
        self.queue = queue
    }
    
    public func dispatch(_ action: ActionType) {
        dispatchBase(action)
    }
    
    fileprivate func dispatchBase(_ action: BaseActionType) {
        if let parent = parent {
            parent.dispatch(action)
        } else {
            queue.async {
                let (newState, command) = self.reducer(action, self.state)
                self.state = newState
                command.dispatch(self.dispatchBase)
            }
        }
    }
    
    public func selected<SubState: StateType>(_ keyPath: KeyPath<S, SubState>) -> Store<SubState> {
        let result = Store<SubState>(reducer: { _, _ in fatalError() }, state: state[keyPath: keyPath], queue: queue)
        result.parent = AnyStore(self)
        
        $state.map(keyPath).receive(on: queue).sink { state in
            result.state = state
        }.store(in: &cancellables)
        
        return result
    }
}

@available(OSX 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
struct AnyStore {
    let dispatch: (BaseActionType) -> ()
    
    init<S: StateType>(_ store: Store<S>) {
        self.dispatch = store.dispatchBase
    }
}
#endif
