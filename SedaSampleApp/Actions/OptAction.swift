//
//  OptAction.swift
//  SedaSampleApp
//
//  Created by 和泉田 領一 on 2019/10/03.
//

import Foundation
import Seda

enum OptAction: ActionType {
    case start(String)
    case finish
    case setText(String)
}
