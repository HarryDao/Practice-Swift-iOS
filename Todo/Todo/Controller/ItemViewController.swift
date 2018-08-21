//
//  ItemViewController.swift
//  Todo
//
//  Created by Chuck Fishman on 20/08/18.
//  Copyright © 2018 Chuck Fishman. All rights reserved.
//

import UIKit
import RealmSwift


class ItemViewController: DefaultController {

    let realm = try! Realm()
    
    var items: Results<Item>?
    var selectedCategory: Category? {
        didSet {
            configureNavigationBar()
            loadData()
        }
    }
    
    var didUpdateNavigation = false
    var activeSearchInput = false
    
    @IBOutlet weak var loadingItemView: UIView!
    @IBOutlet weak var mainItemView: UIView!
    @IBOutlet weak var itemTableView: UITableView!
    @IBOutlet weak var noItemLabel: UILabel!
    @IBOutlet weak var searchInput: UISearchBar!
    
    
    
    override func viewDidLoad() {

        loadingView = loadingItemView
        mainView = mainItemView
        dataTableView = itemTableView
        noDataLabel = noItemLabel
        
        super.viewDidLoad()
        
        configureSearchBar()
        configureNavigationBar()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.formatNavigationBar()

    }
    
    func configureNavigationBar() {
        if didUpdateNavigation == true {
            return
        }
        
        guard let _ = navigationController?.navigationBar else {
            return
        }
        
        didUpdateNavigation = true
        
        if let hex = selectedCategory?.color, let category = selectedCategory {
            
            title = category.name
            
            let color = getColorFromHex(hex: hex)
            let contrast = getContrastColorFromHex(hex: hex)
    
            searchInput.backgroundColor = color
            
            formatNavigationBar(back: color, icons: contrast, title: contrast)
        }
    }

    override func countData() -> Int {
        
        return items?.count ?? 0
    }
    
    func updateUI(initial: Bool = false, reload: Bool = true) {

        items = items?.sorted(byKeyPath: "title").sorted(byKeyPath: "done")

        super.updateTableUI(initial: initial, reload: reload)
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        showAddDataPopup(title: "Add New Task", placeholder: "enter task name...")
    }
    
    override func addData(name: String) {
        if let category = selectedCategory {
            do {
                try realm.write {
                    let newItem = Item()
                    newItem.title = name
                    newItem.done = false
                    
                    category.items.append(newItem)

                    updateUI()
                }
            }
            catch {
                print("Error addData:", error)
            }
        }

    }
    
    override func loadData() {
        
        if let category = selectedCategory {
            items = category.items.sorted(byKeyPath: "title")
            
            updateUI(initial: true)
        }
    }
    
    override func deleteData(row: Int) {
        if let item = items?[row] {
            
            do {
                try realm.write {
                    realm.delete(item)
                }
            }
            catch {
                print("Error deleteData:", error)
            }
        }
    }
    
    func updateData(row: Int) {
        
        if let item = items?[row] {
            
            do {
                try realm.write {
                    item.done = !item.done
                    
                    updateUI()
                }
            }
            catch {
                print("Error updateItem:", error)
            }
        }
    }

    func filterData(search: String) {
        if let category = selectedCategory {
            
            if search == "" {
                
                items = category.items.sorted(byKeyPath: "title")
                updateUI()
                
                return
            }
            
            
            let conditions = NSPredicate(format: "title CONTAINS %@", search)
            
            let newItems = category.items.filter(conditions)
            
            if newItems.count > 0 {
                items = newItems
                updateUI()
            }
        }
    }
    
}

extension ItemViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        var cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell = formatCell(cell: cell, row: indexPath.row)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if activeSearchInput {
            endEditing()
        }
        else {
            updateData(row: indexPath.row)
        }
    }
    
    func formatCell(cell: UITableViewCell, row: Int) -> UITableViewCell {
        
        if let item = items?[row], let hex = selectedCategory?.color {
            
            cell.textLabel?.text = item.title
            cell.selectionStyle = .none
            
            let color = getDarkenColor(hex: hex, level: row, total: items!.count)
            let contrast = getContrastColor(color: color)
            
            cell.accessoryType = item.done ? .checkmark : .none
            cell.backgroundColor = item.done ? UIColor.clear : color
            cell.textLabel?.textColor = item.done ? UIColor.gray : contrast
        }
        
        return cell
    }
}

extension ItemViewController: UISearchBarDelegate {
    
    func configureSearchBar() {
        searchInput.delegate = self
        
        if let hex = selectedCategory?.color {
            let color = getColorFromHex(hex: hex)
            
            searchInput.barTintColor = color
            searchInput.tintColor = color
        }
    }

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterData(search: searchText)
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        activeSearchInput = true
    }

    func endEditing() {
        activeSearchInput = false
        searchInput.endEditing(true)
    }
    

    
}
