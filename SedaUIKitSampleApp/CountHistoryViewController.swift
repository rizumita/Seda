//
//  CountHistoryViewController.swift
//  SedaUIKitSampleApp
//
//  Created by 和泉田 領一 on 2019/09/10.
//

import UIKit
import Combine
import Seda

class CountHistoryViewController: UITableViewController {
    private var history = [Step]() {
        didSet {
            tableView.reloadData()
        }
    }
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        store.$state.map(\.counterState).sink { [weak self] state in
            self?.history = state.history
        }.store(in: &cancellables)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StepCell", for: indexPath)

        let step = history[indexPath.row]
        
        cell.textLabel?.text = step.description
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { action, view, completion in
            store.dispatch(CountAction.remove(IndexSet(integer: indexPath.row)))
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
}
