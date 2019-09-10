//
//  LegacyStore.swift
//  Seda
//
//  Created by 和泉田 領一 on 2019/09/10.
//

import Foundation

public class LegacyStore<S> where S: StateType {
    private let reducer: Reducer<S>
    public private(set) var state: S {
        willSet {
            DispatchQueue.main.async {
                self.pipe.send(newValue)
            }
        }
    }
    private let queue: DispatchQueue
    private let pipe = opipe(S.self)
    
    public init(reducer: @escaping Reducer<S>, state: S, queue: DispatchQueue = DispatchQueue(label: "Seda.Store.queue")) {
        self.reducer = reducer
        self.state = state
        self.queue = queue
    }
    
    public func observe(_ f: @escaping (S) -> ()) -> ObserveToken {
        defer {
            let s = state
            state = s
        }
        return pipe.observe(f)
    }
    
    public func observe<SubState>(_ keyPath: KeyPath<S, SubState>, _ f: @escaping (SubState) -> ()) -> ObserveToken {
        defer {
            let s = state
            state = s
        }
        return pipe.observe { state in
            f(state[keyPath: keyPath])
        }
    }
    
    public func dispatch(_ action: ActionType) {
        queue.async {
            let (newState, command) = self.reducer(action, self.state)
            self.state = newState
            command.dispatch(self.dispatch)
        }
    }
}

public typealias Send<A> = (A) -> ()
public typealias Receive<A> = (A) -> ()
public typealias Observe<A> = (@escaping Receive<A>) -> (ObserveToken)
public typealias OPipe<A> = (send: Send<A>, observe: Observe<A>)

public class ObserveToken: Hashable {
    let uuid = UUID()
    let receive: Any
    
    init<A>(_ receive: @escaping Receive<A>) {
        self.receive = receive
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
    
    public static func ==(_ lhs: ObserveToken, _ rhs: ObserveToken) -> Bool {
        if lhs.uuid != rhs.uuid { return false }
        return true
    }
}

public func opipe<A>(_ type: A.Type = A.self) -> OPipe<A> {
    let tokens = NSHashTable<ObserveToken>.weakObjects()
    
    let observe: Observe<A> = { [weak tokens] receive in
        let token = ObserveToken(receive)
        tokens?.add(token)
        return token
    }
    
    let send: Send<A> = { a in
        tokens.allObjects.forEach { token in
            guard let receive = token.receive as? Receive<A> else { return }
            receive(a)
        }
    }
    
    return (send, observe)
}

public func withPrevious<A>(_ f: @escaping (A, A) -> ()) -> (A) -> () {
    var prev: A?
    
    return { a in
        defer { prev = a }
        guard let prev = prev else { return }
        f(prev, a)
    }
}
