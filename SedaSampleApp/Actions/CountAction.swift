//
//  CountAction.swift
//  SedaSampleApp
//
//  Created by 和泉田 領一 on 2019/09/09.
//

import Foundation
import Seda

enum CountAction: ActionType {
    case step(Step)
    case stepDelayed(Step)
    case remove(IndexSet)
}
