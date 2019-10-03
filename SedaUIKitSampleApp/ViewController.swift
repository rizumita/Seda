//
//  ViewController.swift
//  SedaUIKitSampleApp
//
//  Created by 和泉田 領一 on 2019/09/10.
//

import UIKit
import Combine
import Seda

class ViewController: UIViewController {
    @IBOutlet weak var countLabel: UILabel!
    var cancellables = Set<AnyCancellable>()
    var oldStepperValue = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countLabel.text = "0"
        
        store.$state.map(\.counterState).sink { [weak self] state in
            self?.countLabel.text = String(state.count)
        }.store(in: &cancellables)
    }
    
    @IBAction func stepperButtonTapped(_ sender: UIStepper) {
        defer { oldStepperValue = sender.value }
        
        let step: Step = sender.value > oldStepperValue ? .up : .down
        store.dispatch(CountAction.step(step))
    }
}
