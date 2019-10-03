//
//  AppReducer.swift
//  SedaSampleApp
//
//  Created by 和泉田 領一 on 2019/09/09.
//

import Foundation
import Seda

func appReducer(counterReducer: @escaping CounterReducer = counterReducer(),
                optReducer: @escaping OptReducer = optReducer()) -> Reducer<AppState> {
    return { action, state in
        var state = state
        
        let (counterState, counterCommand) = counterReducer(action, state.counterState)
        state.counterState = counterState
        
        let (optState, optCommand) = optReducer(action, state.counterState.optState)
        state.counterState.optState = optState
        
        return (state,
                .batch([counterCommand, optCommand]))
    }
}
