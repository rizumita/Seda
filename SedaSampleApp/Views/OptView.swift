//
//  OptView.swift
//  SedaSampleApp
//
//  Created by 和泉田 領一 on 2019/10/03.
//

import SwiftUI
import Seda

struct OptView: StatefulView {
    @EnvironmentObject var store: Store<OptState>

    var body: some View {
        VStack {
            Spacer()

            TextField("Text", text: self.binding(\.text, set: OptAction.setText))

            Spacer()

            Button(action: {
                self.store.dispatch(CountAction.step(.up))
            }) {
                Text("Up")
            }

            Spacer()
        }
    }
}

struct OptView_Previews: PreviewProvider {
    static var previews: some View {
        OptView()
    }
}
