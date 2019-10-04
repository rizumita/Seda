//
//  OptState.swift
//  SedaSampleApp
//
//  Created by 和泉田 領一 on 2019/10/03.
//

import Foundation
import Seda

struct OptState: StateType {
    static func initialize(text: String) -> (Self, Command) {
        (OptState(text: text), .none)
    }

    var text: String
}
