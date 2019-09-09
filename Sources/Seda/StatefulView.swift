//
//  StatefulView.swift
//  Seda
//
//  Created by 和泉田 領一 on 2019/09/09.
//

import Foundation
import SwiftUI

public protocol StatefulView where Self: View {
    associatedtype S: StateType

    var store: Store<S> { get }
}
