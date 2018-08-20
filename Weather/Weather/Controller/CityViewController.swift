//
//  CityViewController.swift
//  Weather
//
//  Created by Chuck Fishman on 18/08/18.
//  Copyright © 2018 Chuck Fishman. All rights reserved.
//

import UIKit
import CoreData

protocol CityDelegate {
    func searchByCity(input: String, completion: @escaping (String) -> Void)
}

class CityViewController: UIViewController {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let MAX_RECENT_SEARCHES = 5
    
    var delegate: CityDelegate?
    var searches = [Search]()
    var recentSearchTableViewLocked = false

    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var topContainer: UIView!
    @IBOutlet weak var cityInput: UITextField!
    @IBOutlet weak var recentSearchTableView: UITableView!

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
        loadData()
        
        print(FileManager.default.urls(for: .documentationDirectory, in: .userDomainMask))
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func searchButtonPressed(_ sender: UIButton) {
        let input = cityInput.text ?? ""
        
        if input == "" {
            return
        }

        search(input: input)
    }
    
    func search(input: String) {
        
        startLoading()
        
        delegate?.searchByCity(input: input, completion: { (cityName) in

            self.deleteExtraSearches(newSearch: cityName)

            let newSearch = Search(context: self.context)
            newSearch.name = cityName

            self.searches.insert(newSearch, at: 0)

            self.saveData()

            self.goBack()


        })
        
        cityInput.text = ""
        cityInput.resignFirstResponder()
    }

    
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        goBack()
    }
    
    func goBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func deleteExtraSearches(newSearch: String) {
        
        for i in (0..<searches.count).reversed() {
            if searches[i].name == newSearch {
               deleteSearch(index: i)
            }
        }
        
        if searches.count >= MAX_RECENT_SEARCHES {
            deleteSearch(index: searches.count - 1)
        }
    }
    
    func deleteSearch(index: Int) {
        context.delete(searches[index])
        searches.remove(at: index)
    }
    
    
    func saveData() {
        do {
            try context.save()

            recentSearchTableView.reloadData()
        }
        catch {
            print("Error saveData:", error)
        }
        
    }
    
    func loadData() {
        let request: NSFetchRequest<Search> = Search.fetchRequest()
        
        do {
            searches = (try context.fetch(request)).reversed()
        }
        catch {
            print("Error loadData:", error)
        }
    }
    
    func startLoading() {
        loadingView.alpha = 0
        
        view.bringSubview(toFront: loadingView)
        
        UIView.animate(withDuration: 0.1) {
            self.loadingView.alpha = 0.5
        }
        
        view.layoutIfNeeded()
    }
    
    func finishLoading() {
        UIView.animate(withDuration: 0.5, animations: {
            self.loadingView.alpha = 0
        }) { (finished) in
            self.view.bringSubview(toFront: self.mainView)
        }
        
        
    }
}


extension CityViewController: UITableViewDelegate, UITableViewDataSource {
    
    func configureTableView() {
        
        recentSearchTableView.delegate = self
        recentSearchTableView.dataSource = self
        
        recentSearchTableView.separatorStyle = .none
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap))
        topContainer.addGestureRecognizer(tap)
        
    }
    
    @objc func onTap() {
        cityInput.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return searches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell = tableView.dequeueReusableCell(withIdentifier: "recentSearchCell")!
        cell = formatCell(cell: cell)
        
        let search = searches[indexPath.row]
        
        cell.textLabel?.text = search.name ?? "Not Found"
        
        return cell
    }
    
    func formatCell(cell: UITableViewCell) -> UITableViewCell {
        
        cell.textLabel?.font = UIFont.systemFont(ofSize: 20 )
        cell.textLabel?.textColor = UIColor.lightGray
        cell.textLabel?.textAlignment = NSTextAlignment.center
        
        let selectionView = UIView()
        selectionView.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = selectionView
        cell.textLabel?.highlightedTextColor = UIColor.white
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        search(input: searches[indexPath.row].name!)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    

}
