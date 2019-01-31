//
//  DrinkDetailViewController.swift
//  DetailList
//
//  Created by StanislavPM on 24/01/2019.
//  Copyright © 2019 StanislavPM. All rights reserved.
//

import UIKit

class DrinkDetailViewController: UIViewController {
    //MARK: - Vars
    // MARK: -
    @IBOutlet weak var imageDrink: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var volumeLabel: UILabel!
    @IBOutlet weak var impressionTextField: UITextField!
    
    @IBOutlet weak var sugarAddedLabel: UILabel!
    @IBOutlet weak var sugarQuantityLabel: UILabel!
    @IBOutlet weak var sugarAddedSwitch: UISwitch!
    @IBOutlet weak var sugarPortionSegments: UISegmentedControl!
    @IBOutlet weak var sugarStepper: UIStepper!
    
    @IBOutlet weak var volumeStepper: UIStepper!
    @IBOutlet weak var volumePortionSegments: UISegmentedControl!
    
    @IBOutlet weak var drinkNamePicker: UIPickerView!
    @IBOutlet var volumeAndSugarStacks: [UIStackView]!
    
    @IBOutlet weak var impressionTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var impressionBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var impressionLabel: UILabel!
    
    let drinkNames = DrinkType.listOfNames
    
    var volumePortion: Double = 0.0
    var sugarPortion: Double = 0.0
    
    var currentDrink: Drink!
    
    // MARK: - System
    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sugarAddedSwitch.addTarget(self, action: #selector(sugarSwitch(_:)), for: .valueChanged)
        
        drinkNamePicker.delegate = self
        drinkNamePicker.dataSource = self
        
        if currentDrink == nil {
            currentDrink = Drink()
            // не скрывать Picker
        } else {
            fillFields()
            // Скрыть Picker
            self.drinkNamePicker.isHidden = true
            self.drinkNamePicker.alpha = 0.0
        }
        
        // choose drink type for new
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.chooseDrink(_:)))
        nameLabel.isUserInteractionEnabled = true
        nameLabel.addGestureRecognizer(tapRecognizer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    //MARK: - UpdateUI
    //MARK: -
    
    func actualizedSwich() {
        if currentDrink.type.naturalSugar == true {
            sugarAddedSwitch.isHidden = true
            sugarAddedLabel.isHidden = true
        }
        
        sugarStepper.isHidden = !sugarAddedSwitch.isOn
        sugarPortionSegments.isHidden = !sugarAddedSwitch.isOn
    }
    
    func updateSegmentedControl() {
        switch volumePortionSegments.selectedSegmentIndex {
        case 0:
            volumePortion = 50
        case 1:
            volumePortion = 200
        case 2:
            volumePortion = 300
        default:
            volumePortion = 0.0
        }
        
        switch sugarPortionSegments.selectedSegmentIndex {
        case 0:
            sugarPortion = 5.5
        case 1:
            sugarPortion = 5
        case 2:
            sugarPortion = 10
        default:
            sugarPortion = 0
        }
        
        sugarStepper.stepValue = sugarPortion
        volumeStepper.stepValue = volumePortion
    }
    
    func fillFields() {
        imageDrink.image = currentDrink.type.image
        nameLabel.text = currentDrink.type.name
        volumeLabel.text = "\(currentDrink.volume) мл"
        sugarQuantityLabel.text = "\(currentDrink.sugar) г"
        impressionTextField.text = currentDrink.impression
        sugarAddedSwitch.isOn = currentDrink.sugarAdded
        actualizedSwich()
        setupSteppers()
    }
    
    func setupSteppers() {
        volumeStepper.minimumValue = 0
        volumeStepper.maximumValue = 2000
        
        sugarStepper.minimumValue = 0
        sugarStepper.maximumValue = 50
        
        volumeStepper.value = currentDrink.volume
        sugarStepper.value = currentDrink.sugar
        
        updateSegmentedControl()
    }
    
    @objc func chooseDrink(_ sender: UITapGestureRecognizer) {
//        showPicker()
        showView(drinkNamePicker)
    }
    
    func showView(_ view: UIView) {
        DispatchQueue.main.async {
            view.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                view.alpha = 1.0
            }, completion: nil)
        }
    }
    
    func hideView(_ view: UIView) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, animations: {
                view.alpha = 0.0
            }, completion: { (finish) in
                view.isHidden = true
            })
        }
    }
    
    func showPicker() {
        DispatchQueue.main.async {
            self.drinkNamePicker.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.drinkNamePicker.alpha = 1.0
            }, completion: nil)
        }
    }
    
    func hidePicker() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, animations: {
                self.drinkNamePicker.alpha = 0.0
            }, completion: { (finish) in
                self.drinkNamePicker.isHidden = true
            })
        }
    }
    
    func hideThemAll() {
        nameLabel.isHidden = true
        volumeLabel.isHidden = true
        impressionTextField.isHidden = true
        
        sugarQuantityLabel.isHidden = true
        sugarAddedSwitch.isHidden = true
        sugarPortionSegments.isHidden = true
        
    }
    
// MARK: - Navigation
//MARK: -
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "saveSegue" else {return}
        guard let listVC = segue.destination as? BeverageLogViewController else { return }
        
        currentDrink.type = DrinkType(rawValue: nameLabel.text!)!
        currentDrink.impression = impressionTextField.text!
        currentDrink.volume = volumeStepper.value
        currentDrink.sugar = sugarStepper.value
        currentDrink.sugarAdded = sugarAddedSwitch.isOn
    }
    
    
}

// MARK: - Picker View
// MARK: -
extension DrinkDetailViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return drinkNames.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return drinkNames[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard currentDrink != nil else { return }
        
        let choosenDrink = drinkNames[row]
        let choosenDrinkPhoto = UIImage(named: choosenDrink)!

        currentDrink.type = DrinkType(rawValue: choosenDrink)!
//        currentDrink.photo = choosenDrinkPhoto
        fillFields()
        
        hidePicker()
    }
    
    // MARK: - IBActions
    // MARK: -
    
    @IBAction func volumePortionChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            volumePortion = 50
        case 1:
            volumePortion = 200
        case 2:
            volumePortion = 300
        default:
            volumePortion = 0.0
        }
        
        volumeStepper.stepValue = volumePortion
    }
    
    @IBAction func volumeStepperPressed(_ sender: UIStepper) {
//        volumeLabel.text = "\(volumeStepper.value) мл"
        
        let volume = volumeStepper.value
        volumeLabel.text = "\(volume) мл"
        
        // напиток с естественным содержанием сахара
        if currentDrink.type.naturalSugar == true {
            updateSugarTo(volume * currentDrink.type.sugarCoefficient)
        }
    }
    
    func updateSugarTo(_ weight: Double) {
        // label
        sugarQuantityLabel.text = "\(weight) г"
        
        // stepper - возможно не надо - stepper скрыт
        sugarStepper.value = weight
        
        // currentDrink - не надо? - при передаче записывается из полей в currentDrink
//        currentDrink.sugar = weight
    }
    
    @IBAction func sugarPortionChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            sugarPortion = 5.5
        case 1:
            sugarPortion = 5
        case 2:
            sugarPortion = 10
        default:
            sugarPortion = 0
        }
        
        sugarStepper.stepValue = sugarPortion
    }
    
    @IBAction func sugarStepperPressed(_ sender: UIStepper) {
        sugarQuantityLabel.text = "\(sugarStepper.value) г"
    }
    
    @IBAction func sugarSwitch(_ sender: UISwitch) {
        // Убрать +/-, порции(сегменты)
        actualizedSwich()
        
        // обнулить сахар до стандартного значения при отключении переключателя
        if sender.isOn == false {
            updateSugarTo(volumeStepper.value * currentDrink.type.sugarCoefficient)
        }
    }
}


//MARK: - Keyboard events
//MARK: -
extension DrinkDetailViewController {
    
    func impressionFieldMove(toHeight: CGFloat) {
        if toHeight != 0 { // клавиатура появляется
            let spacer: CGFloat = 8.0
            impressionTopConstraint.isActive = false
            impressionBottomConstraint.isActive = true
            impressionBottomConstraint.constant = -toHeight - spacer
            stacks(show: false)
        } else { // клавиатура исчезает
            impressionTopConstraint.isActive = true
            impressionBottomConstraint.isActive = false
            impressionBottomConstraint.constant = toHeight
            stacks(show: true)
        }
    }
    
    func stacks(show: Bool) {
        volumeAndSugarStacks.forEach { show ? $0.showWithAnimation() : $0.hideWithAnimation() }
        show ? impressionLabel.showWithAnimation() : impressionLabel.hideWithAnimation()
    }
    
    @objc func keyboardWillChangeFrame(notification: Notification) {
        guard let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        guard let keyboardAnimationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        guard let keyboardAnimationCurve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int else { return }
        
        let keyboardHeight = keyboardSize.cgRectValue.height - self.view.safeAreaInsets.bottom
        
        self.impressionFieldMove(toHeight: keyboardHeight)
        
        UIView.animate(withDuration: keyboardAnimationDuration) {
            self.view.layoutIfNeeded()
        }
        
    }
    
}
