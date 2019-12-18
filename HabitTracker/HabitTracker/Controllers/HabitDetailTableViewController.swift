//
//  HabitDetailTableViewController.swift
//  HabitTracker
//
//  Created by Somogyi Balázs on 2019. 12. 09..
//  Copyright © 2019. Somogyi Balázs. All rights reserved.
//

import UIKit
import CoreData

class HabitDetailTableViewController: UITableViewController {
    
    var habitToEdit: Habit?
    var newHabitFromTemplate: Habit?
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let managedObjectContext = AppDelegate.managedContext

    @IBOutlet weak var habitNameTextField: UITextField!
    @IBOutlet weak var periodSegmentedControl: UISegmentedControl!
    @IBOutlet weak var timeOfDaySegmentedControl: UISegmentedControl!
    @IBOutlet weak var streakLabel: UILabel!
    
    private var periodType: Period?
    private var timeOfDayType: TimeOfDay?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let habit = habitToEdit {
            loadExistingHabit(with: habit)
        } else {
            initializeNewHabit()
        }
        navigationItem.largeTitleDisplayMode = .never
        
        hideKeyboardWhenTappedAround()
    }
    
    func loadExistingHabit(with habit: Habit) {
        title = "Edit Habit"
        habitNameTextField.text = habit.name
        if let period = habit.periodValue {
            periodType = period
            periodSegmentedControl.selectedSegmentIndex = Int(period.rawValue)
        }
        if let timeOfDay = habit.timeOfDayValue {
            timeOfDayType = timeOfDay
            timeOfDaySegmentedControl.selectedSegmentIndex = Int(timeOfDay.rawValue)
        }
        streakLabel.text = String(habit.streak)
    }
    
    func initializeNewHabit() {
        title = "New Habit"
        habitNameTextField.placeholder = "Name of the habit"
        habitNameTextField.attributedPlaceholder = NSAttributedString(string: "Name of the habit", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red:0.03, green:0.85, blue:0.84, alpha:1.0)])
        periodType = .daily
        periodSegmentedControl.selectedSegmentIndex = 0
        timeOfDaySegmentedControl.selectedSegmentIndex = 0
        streakLabel.text = "0"
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        if let habit = habitToEdit, let text = habitNameTextField.text {
            habit.name = text
            changePeriodType(to: habit)
            changeTimeOfDayType(to: habit)
            print(habit.timeOfDay)
        } else {
            let habit = Habit(context: managedObjectContext)
            
            setupHabit(habit)
            changePeriodType(to: habit)
            changeTimeOfDayType(to: habit)
            print(habit.timeOfDay)
        }
        
        appDelegate.saveContext()
        if habitToEdit == nil {
            self.navigationController?.popToRootViewController(animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    fileprivate func setupHabit(_ habit: Habit) {
        if let textFieldText = habitNameTextField.text {
            habit.name = textFieldText
        }
        
        let habitDate = Date()
        habit.date = habitDate
        let calendar = Calendar.current
        habit.dayOfMonth = Int16(calendar.component(.day, from: habitDate))
        habit.dayOfWeek = Int16(habitDate.dayNumberOfWeek()!)
    }
    
    fileprivate func changePeriodType(to habit: Habit) {
        switch periodType {
        case .daily:
            habit.periodValue = .daily
        case .weekly:
            habit.periodValue = .weekly
        case .monthly:
            habit.periodValue = .monthly
        default:
            habit.periodValue = .daily
        }
    }
    
    func changeTimeOfDayType(to habit: Habit) {
        switch timeOfDayType {
        case .morning:
            habit.timeOfDayValue = .morning
        case .afternoon:
            habit.timeOfDayValue = .afternoon
        case .evening:
            habit.timeOfDayValue = .evening
        case .any:
            habit.timeOfDayValue = .any
        default:
            habit.timeOfDayValue = .morning
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
      habitNameTextField.becomeFirstResponder()
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
      return nil
    }
    
    @IBAction func periodValueChanged(_ sender: Any) {
        switch periodSegmentedControl.selectedSegmentIndex {
        case 0:
            periodType = .daily
        case 1:
            periodType = .weekly
        case 2:
            periodType = .monthly
        default:
            return
        }
    }
    
    @IBAction func timeOfDayValueChanged(_ sender: Any) {
        switch timeOfDaySegmentedControl.selectedSegmentIndex {
        case 0:
            timeOfDayType = .morning
        case 1:
            timeOfDayType = .afternoon
        case 2:
            timeOfDayType = .evening
        case 3:
            timeOfDayType = .any
        default:
            return
        }
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    @IBAction func keyboardReturnButtonTapped(_ sender: Any) {
        habitNameTextField.resignFirstResponder()
    }
    
    // MARK: Navigation
    @IBAction func newReminderTimeCellTapped(_ sender: Any) {
        performSegue(withIdentifier: "DatePickerSegue", sender: self)
    }
    @IBAction func newReminderLocationCellTapped(_ sender: Any) {
        performSegue(withIdentifier: "LocationSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DatePickerSegue" {
            let dateNotificationVC = segue.destination as! DateNotificationViewController
            dateNotificationVC.text = habitNameTextField.text
        } else if segue.identifier == "LocationSegue" {
            let locationNotificationVC = segue.destination as! LocationNotificationViewController
            locationNotificationVC.text = habitNameTextField.text
        }
    }
    
    // MARK: Header + footer
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor(red:1.00, green:0.18, blue:0.39, alpha:1.0)
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor(red:0.99, green:0.98, blue:0.95, alpha:1.0)
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = UIColor(red:0.15, green:0.16, blue:0.20, alpha:1.0)
    }
}
