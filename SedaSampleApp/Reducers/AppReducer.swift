//
//  AppReducer.swift
//  SedaSampleApp
//
//  Created by 和泉田 領一 on 2019/09/09.
//

import Foundation
import Seda

func appReducer(counterReducer: @escaping CounterReducer = counterReducer()) -> Reducer<AppState> {
    return { action, state in
        let (counterState, counterCommand) = counterReducer(action, state.counterState)
        
        return (AppState(counterState: counterState),
                .batch([counterCommand]))
    }
}
