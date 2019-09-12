//
//  Reducer.swift
//  Seda
//
//  Created by 和泉田 領一 on 2019/09/09.
//

import Foundation

public typealias Reducer<S: StateType> = (BaseActionType, S?) -> (S, Command)
