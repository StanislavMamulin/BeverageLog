//
//  UIView+Animation.swift
//  DetailList
//
//  Created by StanislavPM on 31/01/2019.
//  Copyright © 2019 StanislavPM. All rights reserved.
//

import UIKit

extension UIView {
    func showWithAnimation(_ duration: Double = 0.3) {
        DispatchQueue.main.async {
            self.isHidden = false
            UIView.animate(withDuration: duration, animations: {
                self.alpha = 1.0
            }, completion: nil)
        }
    }
    
    func hideWithAnimation(_ duration: Double = 0.2) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: duration, animations: {
                self.alpha = 0.0
            }, completion: { (finish) in
                self.isHidden = true
            })
        }
    }
}
