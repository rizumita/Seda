//
//  Middleware.swift
//  Seda
//
//  Created by 和泉田 領一 on 2019/10/08.
//

import Foundation

public typealias Middleware<State> = (@escaping Dispatch, @escaping () -> State) -> (@escaping Dispatch) -> Dispatch
