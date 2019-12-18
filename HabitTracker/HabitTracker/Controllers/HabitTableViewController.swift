//
//  ViewController.swift
//  HabitTracker
//
//  Created by Somogyi Balázs on 2019. 12. 09..
//  Copyright © 2019. Somogyi Balázs. All rights reserved.
//

import UIKit
import CoreData
import SwiftMessages

class HabitTableViewController: UITableViewController {
    
    let userNotificationCenter = UNUserNotificationCenter.current()
    
    private let DAILYPERIODCODE = 0
    private let WEEKLYPERIODCODE = 1
    private let MONTHLYPERIODCODE = 2
    
    private var habits = [Habit]()
    private var fetchedResultsController: NSFetchedResultsController<Habit>!
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let managedObjectContext = AppDelegate.managedContext

    override func viewDidLoad() {
        super.viewDidLoad()
        userNotificationCenter.delegate = self
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        fetchHabits()
        setupLongPressGesture()
    }
    
    // MARK: Fetch
    func fetchHabits() {
        let fetchRequest: NSFetchRequest<Habit> = Habit.fetchRequest()
        
        let nameSortDescriptor: NSSortDescriptor = NSSortDescriptor(key: #keyPath(Habit.name), ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        let timeOfDaySortDescriptor = NSSortDescriptor(key: #keyPath(Habit.timeOfDay), ascending: true)
        fetchRequest.sortDescriptors = [timeOfDaySortDescriptor, nameSortDescriptor]
        
        let allPredicates = setupPredicates()
        fetchRequest.predicate = allPredicates
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: #keyPath(Habit.timeOfDay), cacheName: nil)
    
        fetchedResultsController.delegate = self
        fetchRequest.fetchBatchSize = 20
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    func setupPredicates() -> NSCompoundPredicate {
        let today = Date()
        let calendar = Calendar.current
        let todayDayDate = calendar.component(.day, from: today)
        let currentWeekDay = today.dayNumberOfWeek()!

        let dailyPredicate = NSPredicate(format: "period == \(DAILYPERIODCODE)")

        let weeklyPredicate = NSPredicate(format: "period == \(WEEKLYPERIODCODE)")
        let currentDayPredicate = NSPredicate(format: "dayOfWeek ==  \(currentWeekDay)")
        let weekPredicate = NSCompoundPredicate(type: .and, subpredicates: [weeklyPredicate, currentDayPredicate])
        
        let monthlyDayOfMonthPredicate = NSPredicate(format: "dayOfMonth = \(todayDayDate)")
        let monthlyCodePredicate = NSPredicate(format: "period == \(MONTHLYPERIODCODE)")
        let monthlyPredicate = NSCompoundPredicate(type: .and, subpredicates: [monthlyDayOfMonthPredicate, monthlyCodePredicate])
        
        print(currentWeekDay)
        print(todayDayDate)
        
        return NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: [dailyPredicate, weekPredicate, monthlyPredicate])
    }
    
    // MARK: Long press gesture
    func setupLongPressGesture() {
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        longPressGesture.minimumPressDuration = 1.0
        self.view.addGestureRecognizer(longPressGesture)
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == .ended {
            let touchPoint = gestureRecognizer.location(in: self.view)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let habitDone = fetchedResultsController.object(at: indexPath)
                
                if habitDone.checkedForToday {
                    habitDone.streak -= 1
                } else {
                    habitDone.streak += 1
                }
                
                habitDone.checkedForToday = !habitDone.checkedForToday
                
                appDelegate.saveContext()
                tableView.reloadData()
                
                showMessage(to: habitDone)
            }
        }
    }
    
    func showMessage(to habit: Habit) {
        if habit.checkedForToday {
            showSuccessMessage()
        } else {
            showWarning()
        }
    }
    
    func showSuccessMessage() {
        let view = MessageView.viewFromNib(layout: .cardView)
        view.configureTheme(.success)
        view.configureDropShadow()
        view.configureContent(title: "Success", body: "Keep up the good work!", iconText: "😍")
        view.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        (view.backgroundView as? CornerRoundingView)?.cornerRadius = 10
        view.button?.isHidden = true

        SwiftMessages.show(view: view)
    }
    
    func showWarning() {
        let view = MessageView.viewFromNib(layout: .cardView)
        view.configureTheme(.warning)
        view.configureDropShadow()
        view.configureContent(title: "Warning", body: "Ouch, that doesn't look good", iconText: "😩")
        view.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        (view.backgroundView as? CornerRoundingView)?.cornerRadius = 10
        view.button?.isHidden = true

        SwiftMessages.show(view: view)
    }
    
    // MARK: Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections, let objects = sections[section].objects else {
          return 0
        }
        return objects.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionInfo = fetchedResultsController?.sections?[section] else {
            return nil
        }
        switch sectionInfo.name {
        case "0":
            return "Morning habits"
        case "1":
            return "Afternoon habits"
        case "2":
            return "Evening habits"
        case "3":
            return "Anytime habits"
        default:
            return "Morning habits"
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HabitCell", for: indexPath)
        
        let habit = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = habit.name
        cell.detailTextLabel?.text = habit.dateString
        if habit.checkedForToday {
            cell.imageView?.image = UIImage(systemName: "checkmark")
        } else {
            cell.imageView?.image = nil
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor(red:1.00, green:0.18, blue:0.39, alpha:1.0)
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor(red:0.99, green:0.98, blue:0.95, alpha:1.0)
    }

    
    // MARK: Table view delegates
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let habitToDelete = fetchedResultsController.object(at: indexPath)
            managedObjectContext.delete(habitToDelete)
            appDelegate.saveContext()
        } 
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditSegue" {
            let detailVC = segue.destination as! HabitDetailTableViewController
            let habit = fetchedResultsController.object(at: tableView.indexPathForSelectedRow!)
            detailVC.habitToEdit = habit
        }
    }
    
}

//MARK: NSFetchedResultsControllerDelegate
extension HabitTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            let cell = tableView.cellForRow(at: indexPath!)
            let habit = fetchedResultsController.object(at: indexPath!)
            cell?.textLabel?.text = habit.name
        case .move:
            self.tableView.insertRows(at: [newIndexPath!], with: .fade)
            self.tableView.deleteRows(at: [indexPath!], with: .fade)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch (type) {
        case .insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
            break
        case .delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
            break
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

// MARK: NotificationDelegate
extension UITableViewController: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .sound, .badge])
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}
