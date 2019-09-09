//
//  CounterView.swift
//  SedaSampleApp
//
//  Created by 和泉田 領一 on 2019/09/09.
//

import SwiftUI
import Seda

struct CounterView: View, StatefulView {
    @EnvironmentObject var store: Store<CounterState>
    @State var isHistoryViewPresented = false
    
    var body: some View {
        NavigationView {
            VStack {
                Stepper(onIncrement: {
                    self.store.dispatch(CountAction.step(.up))
                }, onDecrement: {
                    self.store.dispatch(CountAction.step(.down))
                }) {
                    Text(String(self.store.state.count))
                }
                .frame(width: 200.0, alignment: .center)

                Spacer()
                
                HStack(alignment: .center, spacing: 20.0) {
                    Button(action: {
                        self.store.dispatch(CountAction.stepDelayed(.down))
                    }) {
                        Text("Decrement delayed")
                    }

                    Button(action: {
                        self.store.dispatch(CountAction.stepDelayed(.up))
                    }) {
                        Text("Increment delayed")
                    }
                }

                Spacer()

                NavigationLink(destination: CountHistoryView()) {
                    Text("Show history by nav")
                }
                
                Spacer()
                
                Button(action: {
                    self.isHistoryViewPresented = true
                }) {
                    Text("Show history by sheet")
                }
                
                Spacer()
            }
        }
        .sheet(isPresented: $isHistoryViewPresented) {
            CountHistoryView().environmentObject(self.store)
        }
    }
}

struct CounterView_Previews: PreviewProvider {
    static var previews: some View {
        CounterView()
    }
}
