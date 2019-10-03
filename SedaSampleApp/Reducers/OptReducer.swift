//
//  OptReducer.swift
//  SedaSampleApp
//
//  Created by 和泉田 領一 on 2019/10/03.
//

import Foundation
import Seda

typealias OptReducer = ReducerOpt<OptState>

func optReducer() -> OptReducer {
    { action, state in
        if var state = state {
            if let action = action as? OptAction {
                switch action {
                case .finish:
                    return (.none, .none)
                    
                case .setText(let text):
                    state.text = text
                    return (state, .none)
                    
                default: ()
                }
            }
        } else {
            if let action = action as? OptAction {
                switch action {
                case .start(let text):
                    return OptState.initialize(text: text)
                    
                default: ()
                }
            }
        }
        
        return (state, .none)
    }
}
