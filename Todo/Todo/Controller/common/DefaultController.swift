//
//  DefaultController.swift
//  Todo
//
//  Created by Chuck Fishman on 20/08/18.
//  Copyright © 2018 Chuck Fishman. All rights reserved.
//

import UIKit
import SwipeCellKit
import ChameleonFramework

class DefaultController: UIViewController {

    let BLACK = UIColor(hexString: "#1F2833")!
    let AQUA = UIColor(hexString: "#66FCF1")!
    let WHITE = UIColor.white
    
    var loadingView: UIView?
    var mainView: UIView?
    var dataTableView: UITableView?
    var noDataLabel: UILabel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startLoading()
        
        configureTableView()
        
        loadData()
        
        finishLoading()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    
    func startLoading() {
        
        if loadingView != nil {
            loadingView!.alpha = 0
            view.bringSubview(toFront: loadingView!)
        }
    
        
        UIView.animate(withDuration: 0.5, animations: {
            self.loadingView?.alpha = 0.5
        })
    }
    
    func finishLoading() {
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.loadingView?.alpha = 0
        
        }) { (finished) in
            
            if self.mainView != nil {
                self.view.bringSubview(toFront: self.mainView!)
            }
            
        }
    }
    
    func showAddDataPopup(title: String, placeholder: String ) {
        
        var input: UITextField?

        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)

        let action = UIAlertAction(title: "Add", style: .default) { (action) in

            let name = input?.text ?? ""

            if name == "" { return }

            self.addData(name: name)
        }

        alert.addAction(action)
        alert.addTextField { (field) in
            field.placeholder = placeholder
            input = field
        }

        present(alert, animated: true, completion: nil)
    }

    func addData(name: String) {
        print("default addData:")
    }
    
    func loadData() {
        print("default loadData")
    }
    
    func deleteData(row: Int) {
        print("default deleteData")
    }
    
    func updateTableUI(initial: Bool = false, reload: Bool = true) {
        
        if reload == true {
            dataTableView?.reloadData()
        }
        
        let hideNoDataMessage = countData() > 0
        
        if initial == false && hideNoDataMessage != noDataLabel?.isHidden {
            
            noDataLabel?.alpha = hideNoDataMessage ? 1: 0
            noDataLabel?.isHidden = false
            
            UIView.animate(withDuration: 0.5, animations: {
                self.noDataLabel?.alpha = hideNoDataMessage ? 0 : 1
            }) { (finished) in
                self.noDataLabel?.isHidden = hideNoDataMessage
            }
        }
            
        else {
            noDataLabel?.isHidden = hideNoDataMessage
        }
        
    }
    
    func countData() -> Int {
        return 0
    }
}

extension DefaultController: UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate {
    
    func configureTableView() {
        
        dataTableView?.delegate = self
        dataTableView?.dataSource = self
        
        dataTableView?.separatorStyle = .none
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! SwipeTableViewCell
        cell.delegate = self
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            self.deleteData(row: indexPath.row)
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete")
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
}

extension DefaultController {
    
    func formatNavigationBar(
            back: UIColor? = nil,
            icons: UIColor? = nil,
            title: UIColor? = nil
        ) {
        
        let backgroundColor = back ?? BLACK
        let iconsColor = icons ?? AQUA
        let titleColor = title ?? AQUA
        
        if let bar = navigationController?.navigationBar {
            bar.barTintColor = backgroundColor
            bar.tintColor = iconsColor
            bar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: titleColor]
        }
    }
    
    func genRandomColorHex() -> String {
        return UIColor.randomFlat.hexValue()
    }
    
    func getColorFromHex(hex: String) -> UIColor {
        return UIColor(hexString: hex) ?? AQUA
    }
    
    func getContrastColorFromHex(hex: String) -> UIColor {
        return ContrastColorOf(UIColor(hexString: hex) ?? AQUA, returnFlat: true)
    }
    
    func getContrastColor(color: UIColor) -> UIColor {
        return ContrastColorOf(color, returnFlat: true)
    }
    
    func getDarkenColor(hex: String, level: Int, total: Int) -> UIColor {
        let color = getColorFromHex(hex: hex)
        
        let percentage = CGFloat(level + 1)/CGFloat(total) * 0.5
        
        return isDark(color: color) ? color.lighten(byPercentage: percentage)! : color.darken(byPercentage: percentage)!

    }
    
    func isDark(color: UIColor) -> Bool {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        // algorithm from: http://www.w3.org/WAI/ER/WD-AERT/#color-contrast
        brightness = ((r * 299) + (g * 587) + (b * 114)) / 1000;
       
        return brightness < 0.5
    }
}




