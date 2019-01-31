//
//  Drink.swift
//  DetailList
//
//  Created by StanislavPM on 24/01/2019.
//  Copyright © 2019 StanislavPM. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

struct Drink {
    var type: DrinkType
    var impression: String
    var sugar: Double
    var timestamp: Date
    var volume: Double
    var sugarAdded: Bool
	
	// Firebase section
	let ref: DatabaseReference?
	let key: String
	// ----------
	
//    var photo: UIImage {
//        return UIImage(named: self.name.rawValue)!
//    }
    
    init(type: DrinkType, impression: String, sugar: Double, timestamp: Date, volume: Double, sugarAdded: Bool = false, key: String = "") {
        self.type = type
        self.impression = impression
        self.sugar = sugar
        self.timestamp = timestamp
        self.volume = volume
        self.sugarAdded = sugarAdded
		
		self.ref = nil
		self.key = key
    }
    
    init() {
        self.type = .Other
        self.impression = ""
        self.sugar = 0.0
        self.timestamp = Date()
        self.volume = 0.0
        self.sugarAdded = false
		
		self.ref = nil
        self.key = ""
    }
	
	init?(snapshot: DataSnapshot) {
		guard
			let value = snapshot.value as? [String: AnyObject],
			let name = value["name"] as? String,
			let impression = value["impression"] as? String,
			let sugar = value["sugar"] as? Double,
			let volume = value["volume"] as? Double,
			let timestampString = value["timestamp"] as? String,
			let sugarAdded = value["sugarAdded"] as? Bool else
		{ return nil }
		
        let timestamp = Constants.dateFormatter.date(from: timestampString)!
        
		self.type = DrinkType.init(rawValue: name)!
        self.impression = impression
        self.sugar = sugar
        self.volume = volume
		self.timestamp = timestamp
        self.sugarAdded = sugarAdded
		
		self.ref = snapshot.ref
		self.key = snapshot.key
	}
	
	func toAnyObject() -> Any {
        let timestampString = Constants.dateFormatter.string(from: timestamp)
        
        let anyData: [String: Any] = [
			"name": type.name,
			"impression": impression,
			"sugar": sugar,
			"volume": volume,
			"timestamp": timestampString,
			"sugarAdded": sugarAdded,
		]
        
        return anyData
	}
}

enum DrinkType: String, CaseIterable {
    case Water, Juice, Tee, Coffee, Other
    
    var name: String {
        return self.rawValue
    }
    
    var image: UIImage {
        guard let image = UIImage(named: self.rawValue) else { return  UIImage() }
        
        return image
    }
    
    var naturalSugar: Bool {
        switch self{
        case .Juice:
            return true
        default:
            return false
        }
    }
    
    var sugarCoefficient: Double {
        switch self{
        case .Juice:
            return 0.2
        default:
            return 0
        }
    }
    
    static var listOfNames: [String] {
        var names = [String]()
        for name in self.allCases {
            names.append(name.rawValue)
        }
        
        return names
    }
}
