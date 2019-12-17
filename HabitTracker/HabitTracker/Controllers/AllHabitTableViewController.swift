//
//  AllHabitTableViewController.swift
//  HabitTracker
//
//  Created by Somogyi Balázs on 2019. 12. 14..
//  Copyright © 2019. Somogyi Balázs. All rights reserved.
//

import CoreData
import UIKit

class AllHabitTableViewController: UITableViewController {
    
    private var habits = [Habit]()
    private var fetchedResultsController: NSFetchedResultsController<Habit>!
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let managedObjectContext = AppDelegate.managedContext
    
    @IBOutlet weak var searchBar: UISearchBar!
    private var query = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
   
        searchBar.searchTextField.textColor = UIColor(red:0.03, green:0.85, blue:0.84, alpha:1.0)
    searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Search for a habit", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red:0.03, green:0.85, blue:0.84, alpha:1.0)])
        
        fetchAllHabits()
        navigationItem.largeTitleDisplayMode = .never
    }
    
    // MARK: Fetch
    func fetchAllHabits() {
        let fetchRequest: NSFetchRequest<Habit> = Habit.fetchRequest()
        
        if !query.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "name contains[CD] %@", query)
        }
        
        let nameSortDescriptor: NSSortDescriptor = NSSortDescriptor(key: #keyPath(Habit.name), ascending: true)
        fetchRequest.sortDescriptors = [nameSortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)

        fetchRequest.fetchBatchSize = 20
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
        
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
            return 0
        }
        
        return sectionInfo.numberOfObjects
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllHabitCell", for: indexPath)
        
        let habit = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = habit.name
        cell.detailTextLabel?.text = habit.dateString
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditSegue" {
            let detailVC = segue.destination as! HabitDetailTableViewController
            let habit = fetchedResultsController.object(at: tableView.indexPathForSelectedRow!)
            detailVC.habitToEdit = habit
        }
    }
}

// MARK: Search Bar Delegate
extension AllHabitTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else {
            return
        }
        query = text
        fetchAllHabits()
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        query = ""
        searchBar.text = nil
        searchBar.resignFirstResponder()
        fetchAllHabits()
        tableView.reloadData()
    }
}


