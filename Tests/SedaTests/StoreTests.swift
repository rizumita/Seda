//
//  StoreTests.swift
//  SedaTests
//
//  Created by 和泉田 領一 on 2019/10/04.
//

import XCTest
import Combine
@testable import Seda

class StoreTests: XCTestCase {
    enum TestAction: ActionType {
        case up
        case noAction
        case setCount(Int)
    }

    struct TestState: StateType, Equatable {
        static func initialize() -> (Self, Command) {
            (Self(count: 0), .ofAction(TestAction.up))
        }
        
        var count: Int = 0
    }

    func reducer() -> Reducer<TestState> {
        { action, state in
            var state = state
            if let action = action as? TestAction {
                switch action {
                case .up:
                    state.count += 1
                case .setCount(let count):
                    state.count = count
                default: ()
                }
            }
            return (state, .none)
        }
    }

    func testInitWithStateInitialize() {
        let store = Store(reducer: reducer(), stateInit: TestState.initialize)
        XCTAssertEqual(store.state.count, 1)
    }
    
    func testIsEqual() {
        let store = Store(reducer: reducer(), state: TestState(), isEqual: ==)
        var cancellables = Set<AnyCancellable>()
        
        store.objectWillChange.sink { _ in
            XCTFail()
        }.store(in: &cancellables)
        
        store.dispatch(TestAction.noAction)

        cancellables = Set<AnyCancellable>()

        store.objectWillChange.sink { state in
            XCTAssertEqual(1, state.count)
        }.store(in: &cancellables)
        
        store.dispatch(TestAction.up)
    }
    
    func testQueue() {
        let store = Store(reducer: reducer(), state: TestState(), queue: .global())
        var cancellables = Set<AnyCancellable>()
        let exp = expectation(description: #function)
        
        store.objectWillChange.sink { state in
            XCTAssertEqual(1, state.count)
            exp.fulfill()
        }.store(in: &cancellables)
        
        store.dispatch(TestAction.up)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func testBinding() {
        let store = Store(reducer: reducer(), state: TestState())
        
        let binding = store.binding(TestAction.setCount, \.count)
        store.dispatch(TestAction.up)
        XCTAssertEqual(1, binding.wrappedValue)
        
        binding.wrappedValue = 100
        XCTAssertEqual(100, store.state.count)
    }
}
