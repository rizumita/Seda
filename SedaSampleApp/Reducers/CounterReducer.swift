//
//  CounterReducer.swift
//  SedaSampleApp
//
//  Created by 和泉田 領一 on 2019/09/09.
//

import Foundation
import Seda

typealias CounterReducer = Reducer<CounterState>

func counterReducer() -> CounterReducer {
    return { action, state in
        var state = state ?? CounterState()
        var command = Command.none
        
        switch action {
        case CountAction.step(let step):
            state.count += step.count
            state.history.append(step)
        
        case CountAction.stepDelayed(let step):
            command = .ofAsyncAction { fulfill in
                DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(2)) {
                    fulfill(CountAction.step(step))
                }
            }
            
        case CountAction.remove(let indexSet):
            indexSet.forEach { index in state.history.remove(at: index) }
            state.count = state.history.reduce(into: 0) { result, step in result += step.count }

        default: ()
        }
        
        return (state, command)
    }
}
