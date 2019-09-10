//
//  CountHistoryView.swift
//  SedaSampleApp
//
//  Created by 和泉田 領一 on 2019/09/09.
//

import SwiftUI
import Seda

struct CountHistoryView: View, StatefulView {
    @EnvironmentObject var store: Store<CounterState>

    var body: some View {
        List {
            ForEach(self.store.state.history, id: \.self) { step in
                Text(step.description)
            }
            .onDelete { indexSet in
                self.store.dispatch(CountAction.remove(indexSet))
            }
        }
    }
}

struct CountHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        CountHistoryView()
    }
}