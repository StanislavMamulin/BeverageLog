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
   
    var ref: DatabaseReference!
    var drinks: [Drink]! = []
    
    
    enum Segues: String {
        case AddNewDrinkSegue, ShowDetailSegue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureFirebase()

    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drinks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "drinkCell", for: indexPath) as! DrinkCell

        let drink = drinks[indexPath.row]
        
        cell.imageDrink.image = drink.type.image
        cell.name.text = drink.type.name
        cell.volume.text = "\(String(drink.volume)) мл"
        cell.sugar.text = "Сахар: \(String(drink.sugar)) г"
        cell.date.text = Constants.dateFormatter.string(from: drink.timestamp)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88.0
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
 
    
    
     // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let drinkForDelete = drinks[indexPath.row]
            drinkForDelete.ref?.removeValue()
//            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
 
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == Segues.ShowDetailSegue.rawValue else { return }
        guard let drinkDetailVC = segue.destination as? DrinkDetailViewController else { return }
        guard let row = tableView.indexPathForSelectedRow?.row else { return }
        
        let selectedDrink = drinks[row]
        drinkDetailVC.currentDrink = selectedDrink
        
        drinkDetailVC.navigationItem.title = "Редактирование"
    }
    
    @IBAction func unwindFromDetail(segue: UIStoryboardSegue) {
        guard segue.identifier == "saveSegue" else { return }
        guard let detailVC = segue.source as? DrinkDetailViewController else { return }
        
        guard let drink = detailVC.currentDrink else { return }
        
        // saveDrinkToDB(drink)
        
        
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

// MARK: - Firebase
extension BeverageLogViewController {
    func configureFirebase() {
        ref = Database.database().reference(withPath: "Drinks")
        
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
    
//    func saveDrinkToDB(_ drink: Drink) {
//        let fireDrink = drinkToDictionary(drink)
//
//        self.ref.child("drinks").childByAutoId().setValue(fireDrink)
//    }
//
//    func drinkToDictionary(_ drink: Drink) -> [String: Any] {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd/MM/yy"
//
//        var drinkDictionary = [String: Any]()
//
//        drinkDictionary[Constants.DrinkField.name] = drink.type.name
//        drinkDictionary[Constants.DrinkField.volume] = drink.volume
//        drinkDictionary[Constants.DrinkField.sugar] = drink.sugar
//        drinkDictionary[Constants.DrinkField.timestamp] = drink.timestamp
//        drinkDictionary[Constants.DrinkField.impression] = drink.impression
//        drinkDictionary[Constants.DrinkField.sugarAdded] = drink.sugarAdded
//
//        return drinkDictionary
//    }
//
//    func dictionaryToDrink(_ drinkDictionary: [String: Any]) -> Drink {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd/MM/yy"
//
//        var drink: Drink = Drink()
//
//        let name = drinkDictionary[Constants.DrinkField.name] as! String
//        drink.type = DrinkType(rawValue: name)!
//
//        let volume = drinkDictionary[Constants.DrinkField.volume] as! Double
//        drink.volume = volume
//
//        let sugar = drinkDictionary[Constants.DrinkField.sugar] as! Double
//        drink.sugar = sugar
//
//        let timestamp = drinkDictionary[Constants.DrinkField.timestamp] as! Date
//        drink.timestamp = timestamp
//
//        drink.impression = drinkDictionary[Constants.DrinkField.impression] as! String
//
//        let sugarAdded = drinkDictionary[Constants.DrinkField.sugarAdded] as! Bool
//        drink.sugarAdded = sugarAdded
//
//        return drink
//    }
}
