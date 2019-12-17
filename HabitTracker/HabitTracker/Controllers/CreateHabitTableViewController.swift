//
//  CreateHabitTableViewController.swift
//  HabitTracker
//
//  Created by Somogyi Balázs on 2019. 12. 15..
//  Copyright © 2019. Somogyi Balázs. All rights reserved.
//

import UIKit

class CreateHabitTableViewController: UITableViewController {
    
    let habits: [String] = ["Eat a healthy meal", "Drink water", "Read",
                            "Meditate", "Do morning excersises"]
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let managedObjectContext = AppDelegate.managedContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor(red:1.00, green:0.18, blue:0.39, alpha:1.0)
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor(red:0.99, green:0.98, blue:0.95, alpha:1.0)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if let _ = tableView.cellForRow(at: indexPath) {
                let item = habits[indexPath.row]
                createHabit(with: item)
                tableView.deselectRow(at: indexPath, animated: true)
                navigationController?.popViewController(animated: true)
            }
        }
        
    }
    
    func createHabit(with text: String) {
        let habit = Habit(context: managedObjectContext)
        habit.name = text
        habit.date = Date()
    }
}
