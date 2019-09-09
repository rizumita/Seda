//
//  Store.swift
//  Seda
//
//  Created by 和泉田 領一 on 2019/09/09.
//

import Foundation
import Combine

public class Store<S>: ObservableObject where S: StateType {
    public var objectWillChange = PassthroughSubject<S, Never>()
    private var parent: AnyStore?
    private var cancellables = Set<AnyCancellable>()
    
    private let reducer: Reducer<S>
    @Published public var state: S {
        willSet {
            DispatchQueue.main.sync {
                objectWillChange.send(state)
            }
        }
    }
    private let queue: DispatchQueue
    
    public init(reducer: @escaping Reducer<S>, state: S, queue: DispatchQueue = DispatchQueue(label: "Store.queue")) {
        self.reducer = reducer
        self.state = state
        self.queue = queue
    }
    
    public func dispatch(_ action: ActionType) {
        if let parent = parent {
            parent.dispatch(action)
        } else {
            queue.async {
                let (newState, command) = self.reducer(action, self.state)
                self.state = newState
                command.dispatch(self.dispatch)
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

struct AnyStore {
    let dispatch: (ActionType) -> ()

    init<S: StateType>(_ store: Store<S>) {
        self.dispatch = store.dispatch
    }
}
