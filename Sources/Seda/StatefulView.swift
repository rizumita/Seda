//
//  StatefulView.swift
//  Seda
//
//  Created by 和泉田 領一 on 2019/09/09.
//

import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

#if swift(>=5.1)
@available(OSX 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public protocol StatefulView where Self: View {
    associatedtype S: StateType

    var store: Store<S> { get }
}
#endif
