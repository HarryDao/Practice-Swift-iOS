//
//  ViewController.swift
//  Todo
//
//  Created by Chuck Fishman on 19/08/18.
//  Copyright © 2018 Chuck Fishman. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: DefaultController {
    
    let realm = try! Realm()
    
    var categories: Results<Category>?
    var selectedCategory: Category?
    
    @IBOutlet weak var loadingCategoryView: UIView!
    @IBOutlet weak var mainCategoryView: UIView!
    @IBOutlet weak var noCategoryLabel: UILabel!
    @IBOutlet weak var categoryTableView: UITableView!
    
    override func viewDidLoad() {
        
        loadingView = loadingCategoryView
        mainView = mainCategoryView
        noDataLabel = noCategoryLabel
        dataTableView = categoryTableView
        
        super.viewDidLoad()
        
        formatNavigationBar()
    }
    
    override func countData() -> Int {
        return categories?.count ?? 0
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        showAddDataPopup(title: "Add New Category", placeholder: "enter category name...")
    }
    
    override func addData(name: String) {
        do {
            try realm.write {
                let newData = Category()
                newData.name = name
                newData.color = genRandomColorHex()

                realm.add(newData)

                updateTableUI()
            }
        }
        catch {
            print("Error addData:", error)
        }
    }
    
    
    override func loadData() {
        categories = realm.objects(Category.self)
        
        updateTableUI(initial: true)
    }
    
    override func deleteData(row: Int) {
        if let category = categories?[row] {

            do {
                try realm.write {
                    realm.delete(category)

                    updateTableUI(initial: false, reload: false)
                }
            }
            catch {
                print("Error deleteData:", error)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showItems" {
            let destinationVC = segue.destination as! ItemViewController
            
            destinationVC.selectedCategory = selectedCategory
        }
    }
}

extension CategoryViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categories?[indexPath.row] {
            
            cell.backgroundColor = getColorFromHex(hex: category.color)
            cell.textLabel?.text = category.name
            cell.textLabel?.textColor = getContrastColorFromHex(hex: category.color)
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let category = categories?[indexPath.row] {
            
            selectedCategory = category
            
            performSegue(withIdentifier: "showItems", sender: self)
        }
    }
}
