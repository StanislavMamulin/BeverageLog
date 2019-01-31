//
//  ListViewController.swift
//  DetailList
//
//  Created by StanislavPM on 22/01/2019.
//  Copyright © 2019 StanislavPM. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class BeverageLogViewController: UITableViewController {
   
    var ref: DatabaseReference! // ссылка на БД Firebase
    var drinks: [Drink]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureFirebase()
    }
	
	// MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == Constants.Segues.ShowDetail.rawValue else { return }
        guard let drinkDetailVC = segue.destination as? DrinkDetailViewController else { return }
        guard let row = tableView.indexPathForSelectedRow?.row else { return }
        
        let selectedDrink = drinks[row]
        drinkDetailVC.currentDrink = selectedDrink
        
        drinkDetailVC.navigationItem.title = "Редактирование"
    }
    
    @IBAction func unwindFromDetail(segue: UIStoryboardSegue) {
        guard segue.identifier == Constants.Segues.save.rawValue else { return }
        guard let detailVC = segue.source as? DrinkDetailViewController else { return }
        
        guard let drink = detailVC.currentDrink else { return }
        
        if let path = tableView.indexPathForSelectedRow { // редактирование
            tableView.deselectRow(at: path, animated: false)

            drink.ref?.setValue(drink.toAnyObject())
            drinks[path.row] = drink
        } else { // новый дринк
            let drinkRef = self.ref.childByAutoId()
            drinkRef.setValue(drink.toAnyObject())
            drinks.append(drink)
        }        
        
        tableView.reloadData()
    } 
}

// MARK: - Table view data source
extension BeverageLogViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drinks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.drinkCell.rawValue, for: indexPath) as? DrinkCell else { return UITableViewCell() }

        let drink = drinks[indexPath.row]
        
        cell.imageDrink.image = drink.type.image
        cell.name.text = drink.type.name
        cell.volume.text = String(format: "%.0f мл", drink.volume)
        cell.sugar.text = String(format: "Сахар: %.0f г", drink.sugar)
        cell.date.text = Constants.dateFormatter.string(from: drink.timestamp)
        
        return cell
    }
	
	// Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let drinkForDelete = drinks[indexPath.row]
            drinkForDelete.ref?.removeValue()
        }
    }
}

// MARK: -  Table view delegate
extension BeverageLogViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88.0
    }
}

// MARK: - Firebase
extension BeverageLogViewController {
    func configureFirebase() {
        ref = Database.database().reference(withPath: "Drinks") // ссылка на корневой узел
        
		// слежение за изменениями в БД
        ref.observe(.value, with: { snapshot in
            var newDrinks: [Drink] = []
            
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let drink = Drink(snapshot: snapshot) {
                    newDrinks.append(drink)
                }
            }
            
            self.drinks = newDrinks
            self.tableView.reloadData()
        })
    }
}
