//
//  CounterView.swift
//  SedaSampleApp
//
//  Created by 和泉田 領一 on 2019/09/09.
//

import SwiftUI
import Seda

struct CounterView: StatefulView {
    typealias Action = CountAction
    
    @EnvironmentObject var store: Store<AppState>
    var stateKeyPath: KeyPath<AppState, CounterState> = \.counterState
    @State var isHistoryViewPresented = false
    
    var body: some View {
        NavigationView {
            VStack {
                Stepper(onIncrement: {
                    self.dispatch(.step(.up))
                }, onDecrement: {
                    self.dispatch(.step(.down))
                }) {
                    Text(String(self.state.count))
                }
                .frame(width: 200.0, alignment: .center)

                Spacer()
                
                HStack(alignment: .center, spacing: 20.0) {
                    Button(action: {
                        self.dispatch(.stepDelayed(.down))
                    }) {
                        Text("Decrement delayed")
                    }

                    Button(action: {
                        self.dispatch(.stepDelayed(.up))
                    }) {
                        Text("Increment delayed")
                    }
                }

                Spacer()

                NavigationLink(destination: CountHistoryView().environmentObject(self.store.substore(\.counterState, isSubscribing: false))) {
                    Text("Show history by nav")
                }
                
                Spacer()
                
                Button(action: {
                    self.isHistoryViewPresented = true
                }) {
                    Text("Show history by sheet")
                }
                
                Spacer()
                
                Button(action: {
                    self.store.unsubscribe()
                    return self.store.dispatch(OptAction.start("Optional state view text field"))
                }) {
                    Text("Optional state view")
                }
            }
            .sheet(isPresented: $isHistoryViewPresented) {
                CountHistoryView().environmentObject(self.store.substore(\.counterState))
            }
            .sheet(item: store.substoreBinding(\.counterState.optState, dismissAction: OptAction.finish), onDismiss: { self.store.subscribe() }) {
                return OptView().environmentObject($0)
            }
        }
    }
}

struct CounterView_Previews: PreviewProvider {
    static var previews: some View {
        CounterView()
    }
}
