//
//  Command.swift
//  Seda
//
//  Created by 和泉田 領一 on 2019/09/09.
//

import Foundation

public typealias Dispatch = (BaseActionType) -> ()
public typealias Sub = (@escaping Dispatch) -> ()

public struct Command {
    var value: [Sub]

    public static var none: Command { return Command(value: []) }

    public static func ofAction(_ action: BaseActionType) -> Command {
        return Command(value: [{ dispatch in dispatch(action) }])
    }

    public static func ofActionOptional(_ action: BaseActionType?) -> Command {
        return Command(value: [{ dispatch in action.map(dispatch) }])
    }

    public static func batch(_ cmds: [Command]) -> Command {
        return Command(value: cmds.flatMap { cmd in cmd.value })
    }

    public static func ofSub(_ sub: @escaping Sub) -> Command {
        return Command(value: [sub])
    }

    public static func dispatch(_ dispatch: @escaping Dispatch) -> (Command) -> () {
        return { cmd in cmd.value.forEach { (sub: Sub) in sub(dispatch) } }
    }

    public func dispatch(_ dispatch: @escaping Dispatch) {
        Command.dispatch(dispatch)(self)
    }

    public static func ofAsyncAction(_ async: @escaping (@escaping (BaseActionType) -> ()) -> ()) -> Command {
        return Command(value: [{ dispatch in
            async { action in
                DispatchQueue.main.async { dispatch(action) }
            }
        }])
    }

    public static func ofAsyncActionOptional(_ async: @escaping (@escaping (BaseActionType?) -> ()) -> ()) -> Command {
        return Command(value: [{ dispatch in
            async { action in
                guard let action = action else { return }
                DispatchQueue.main.async { dispatch(action) }
            }
        }])
    }

    public static func ofAsyncCommand(_ async: @escaping (@escaping (Command) -> ()) -> ()) -> Command {
        return Command(value: [{ dispatch in
            async { command in
                DispatchQueue.main.async { command.dispatch(dispatch) }
            }
        }])
    }

    public static func ofAsyncCommandOptional(_ async: @escaping (@escaping (Command?) -> ()) -> ()) -> Command {
        return Command(value: [{ dispatch in
            async { command in
                guard let command = command else { return }
                DispatchQueue.main.async { command.dispatch(dispatch) }
            }
        }])
    }
    
    public mutating func append(action: BaseActionType) {
        value += [{ dispatch in dispatch(action) }]
    }
    
    public mutating func append(command: Command) {
        value += command.value
    }
    
    public static func +(lhs: Command, rhs: Command) -> Command {
        Command(value: lhs.value + rhs.value)
    }
}
