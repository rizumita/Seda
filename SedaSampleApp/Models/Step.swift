//
//  Step.swift
//  SedaSampleApp
//
//  Created by 和泉田 領一 on 2019/09/09.
//

import Foundation

enum Step: CustomStringConvertible {
    case up
    case down
    
    var count: Int {
        switch self {
        case .up: return 1
        case .down: return -1
        }
    }
    
    var description: String {
        switch self {
        case .up: return "Up"
        case .down: return "Down"
        }
    }
}
