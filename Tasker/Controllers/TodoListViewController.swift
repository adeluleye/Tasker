//
//  ViewController.swift
//  Tasker
//
//  Created by ADELU ABIDEEN ADELEYE on 8/1/18.
//  Copyright © 2018 Spantom Technologies Ltd. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let realm = try! Realm()
    
    var todoTasks: Results<Task>?
    
    var selectedCategory : Category? {
        didSet {
            loadItems()
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //print(dataFilePath!)
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        tableView.separatorStyle = .none
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationItem.title = selectedCategory?.name
        
        guard let colorHex = selectedCategory?.colour else {fatalError()}
        
        updateNavBar(withHexCode: colorHex)
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        updateNavBar(withHexCode: "#E67E22")
        
    }
    
    //MARK: NavigationBar Setup code
    func updateNavBar(withHexCode colorHexCode: String) {
        
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation controller does not exist")
        }
        
        guard let navBarColor = UIColor(hexString: colorHexCode) else {fatalError()}
        
        navBar.barTintColor = navBarColor
        
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
        
        searchBar.barTintColor = navBarColor
    }
    
    // MARK: TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoTasks?[indexPath.row] {
            
            cell.textLabel?.text = item.title
            
            //cell.backgroundColor = FlatWhite().darken(byPercentage:
                //(CGFloat(indexPath.row) / CGFloat(todoTasks?.count ?? 1)))
            
            if let retrievedColor = selectedCategory?.colour {
                cell.backgroundColor = UIColor(hexString: retrievedColor)?.darken(byPercentage: (CGFloat(indexPath.row) / CGFloat(todoTasks?.count ?? 1)))
            }
            
            
            cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
            
            cell.accessoryType = item.done ? .checkmark : .none
            
        } else {
            cell.textLabel?.text = "No Task Added Yet!"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoTasks?.count ?? 1
    }
    
    // MARK: Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let task = todoTasks?[indexPath.row] {
            
            do {
                try realm.write {
                    //realm.delete(task)  //This line deletes a task from the realm table
                    task.done = !task.done
                }
            } catch {
                print("Error while updating task \(error)")
            }
        }
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }


    // MARK:    Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Task", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Task", style: .default) { (action) in
            // what will happen when the user clicks the Add Task button on the UIAlert
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        
                        let newTask = Task()
                        newTask.title = textField.text!
                        newTask.dateCreated = Date()
                        currentCategory.tasks.append(newTask)
                        
                    }
                } catch {
                    print("Error while trying to save task to Realm \(error)")
                }
                
                
            }
            
            self.tableView.reloadData()
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new task"
            textField = alertTextField
            
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //  MARK: Model Manipulation Methods
    
    func loadItems() {
        
        todoTasks = selectedCategory?.tasks.sorted(byKeyPath: "title", ascending: false)
        
        tableView.reloadData()

    }
    
    //MARK: Delete a Task Using Swipe
    override func updateModel(at indexPath: IndexPath) {
        if let taskForDeletion = self.todoTasks?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(taskForDeletion)
                }
            } catch {
                print("Error Occured \(error)")
            }

        }
    }
    
}

extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoTasks = todoTasks?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }

        }
    }
}

