//
//  CounterState.swift
//  SedaSampleApp
//
//  Created by 和泉田 領一 on 2019/09/09.
//

import Foundation
import Seda

struct CounterState: StateType {
    var count: Int = 0
    var history: [Step] = []
    
    var optState: OptState?
}
