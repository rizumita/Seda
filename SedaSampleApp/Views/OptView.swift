//
//  OptView.swift
//  SedaSampleApp
//
//  Created by 和泉田 領一 on 2019/10/03.
//

import SwiftUI
import Seda

struct OptView: View, StatefulView {
    @EnvironmentObject var store: Store<OptState>
    
    var body: some View {
        TextField("Text", text: self.binding(\.text, set: OptAction.setText))
    }
}

struct OptView_Previews: PreviewProvider {
    static var previews: some View {
        OptView()
    }
}
