//
//  CommandTests.swift
//  SedaTests
//
//  Created by 和泉田 領一 on 2019/10/04.
//

import XCTest
@testable import Seda

class CommandTests: XCTestCase {
    enum Action: ActionType, Equatable {
        enum Internal: InternalActionType, Equatable {
            case update(Int)
        }
        
        case up
        case down
    }
    
    func testNone() {
        XCTAssertEqual(0, Command.none.value.count)
    }
    
    func testOfAction() {
        Command.ofAction(Action.up).dispatch { action in
            guard let action = action as? Action else { XCTFail(); return }
            XCTAssertEqual(Action.up, action)
        }

        Command.ofAction(Action.Internal.update(100)).dispatch { action in
            guard let action = action as? Action.Internal else { XCTFail(); return }
            XCTAssertEqual(Action.Internal.update(100), action)
        }
    }
    
    func testOfActionOptional() {
        Command.ofActionOptional(.none).dispatch { _ in
            XCTFail()
        }

        Command.ofActionOptional(Action.up).dispatch { action in
            guard let action = action as? Action else { XCTFail(); return }
            XCTAssertEqual(Action.up, action)
        }
    }
    
    func testBatch() {
        var actions = [Action]()
        Command.batch([.ofAction(Action.up), .ofAction(Action.down)]).dispatch { action in
            guard let action = action as? Action else { return }
            actions.append(action)
        }
        XCTAssertEqual([Action.up, Action.down], actions)
    }
    
    func testOfSub() {
        Command.ofSub { dispatch in
            dispatch(Action.up)
        }.dispatch { action in
            guard let action = action as? Action else { XCTFail(); return }
            XCTAssertEqual(Action.up, action)
        }
    }

    func testOfAsyncAction() {
        let exp = expectation(description: #function)
        
        Command.ofAsyncAction { fulfill in
            fulfill(Action.up)
        }.dispatch { action in
            guard let action = action as? Action else { XCTFail(); return }
            XCTAssertEqual(Action.up, action)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func testOfAsyncActionOptional() {
        let exp = expectation(description: #function)

        Command.ofAsyncActionOptional { fulfill in
            fulfill(.none)
        }.dispatch { action in
            XCTFail()
        }

        Command.ofAsyncActionOptional { fulfill in
            fulfill(Action.up)
        }.dispatch { action in
            guard let action = action as? Action else { XCTFail(); return }
            XCTAssertEqual(Action.up, action)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func testOfAsyncCommand() {
        let exp = expectation(description: #function)
        
        Command.ofAsyncCommand { fulfill in
            fulfill(.ofAction(Action.up))
        }.dispatch { action in
            guard let action = action as? Action else { XCTFail(); return }
            XCTAssertEqual(Action.up, action)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func testOfAsyncCommandOptional() {
        let exp = expectation(description: #function)

        Command.ofAsyncCommandOptional { fulfill in
            fulfill(Command?.none)
        }.dispatch { action in
            XCTFail()
        }

        Command.ofAsyncCommandOptional { fulfill in
            fulfill(.ofAction(Action.up))
        }.dispatch { action in
            guard let action = action as? Action else { XCTFail(); return }
            XCTAssertEqual(Action.up, action)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func testAppendAction() {
        var command = Command.ofAction(Action.up)
        command.append(action: Action.down)
        
        var upCalled = false
        var downCalled = false
        
        command.dispatch { action in
            guard let action = action as? Action else { return }
            upCalled = upCalled || action == Action.up
            downCalled = downCalled || action == Action.down
        }
        
        XCTAssertTrue(upCalled)
        XCTAssertTrue(downCalled)
    }
    
    func testAppendCommand() {
        var command = Command.ofAction(Action.up)
        command.append(command: .ofAction(Action.down))

        var upCalled = false
        var downCalled = false
        
        command.dispatch { action in
            guard let action = action as? Action else { return }
            upCalled = upCalled || action == Action.up
            downCalled = downCalled || action == Action.down
        }
        
        XCTAssertTrue(upCalled)
        XCTAssertTrue(downCalled)
    }
    
    func testAddOperator() {
        let command = Command.ofAction(Action.up) + Command.ofAction(Action.down)
        
        var upCalled = false
        var downCalled = false
        
        command.dispatch { action in
            guard let action = action as? Action else { return }
            upCalled = upCalled || action == Action.up
            downCalled = downCalled || action == Action.down
        }
        
        XCTAssertTrue(upCalled)
        XCTAssertTrue(downCalled)
    }
}
