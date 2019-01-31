//
//  Constants.swift
//  DetailList
//
//  Created by StanislavPM on 30/01/2019.
//  Copyright © 2019 StanislavPM. All rights reserved.
//

import Foundation

struct Constants {

    struct DrinkField {
        static let name = "name"
        static let volume = "volume"
        static let sugar = "sugar"
        static let impression = "impression"
        static let timestamp = "timestamp"
        static let sugarAdded = "sugarAdded"
    }
    
    static var dateFormatter: DateFormatter {
        get {
            let df = DateFormatter()
            df.dateFormat = "dd/MM/yy HH:mm"
            
            return df
        }
    }
	
	enum Segues: String {
        case AddNewDrink, ShowDetail, save
    }
	
    enum Identifiers: String {
		case drinkCell
	}
}
