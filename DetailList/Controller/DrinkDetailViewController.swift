//
//  DrinkDetailViewController.swift
//  DetailList
//
//  Created by StanislavPM on 24/01/2019.
//  Copyright © 2019 StanislavPM. All rights reserved.
//

// 0. Меняется ли currentDrink при каждом изменении Stepper?

import UIKit

class DrinkDetailViewController: UIViewController {
    // MARK: - IBOutlets
    // MARK: -
    @IBOutlet weak var imageDrink: UIImageView!
	
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var volumeLabel: UILabel!
	@IBOutlet weak var sugarQuantityLabel: UILabel!
	@IBOutlet weak var sugarAddedLabel: UILabel!
	@IBOutlet weak var impressionLabel: UILabel!
	
    @IBOutlet weak var impressionTextField: UITextField!

    @IBOutlet weak var sugarAddedSwitch: UISwitch!
    
	@IBOutlet weak var volumeStepper: UIStepper!
    @IBOutlet weak var sugarStepper: UIStepper!
    @IBOutlet weak var volumePortionSegments: UISegmentedControl!
	@IBOutlet weak var sugarPortionSegments: UISegmentedControl!
    
    @IBOutlet weak var drinkNamePicker: UIPickerView!
	
    @IBOutlet var volumeAndSugarStacks: [UIStackView]!
    
    @IBOutlet weak var impressionTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var impressionBottomConstraint: NSLayoutConstraint!
    
	// MARK: - Vars
    // MARK: -
	
    private let drinkNames = DrinkType.listOfNames // Список напитков для PickerView
    
	private var volumeValue = 0.0 {
		didSet {
            volumeLabel.text = String(format: "%.0f мл", volumeValue)
            volumeStepper.value = volumeValue
            currentDrink.volume = volumeValue
		}
	}
	private var sugarValue = 0.0 {
		didSet {
            sugarQuantityLabel.text = String(format: "%.1f г", sugarValue)
            sugarStepper.value = sugarValue
            currentDrink.sugar = sugarValue
		}
		
	}
	
    private var volumePortion: Double = 0.0 // Шаг изменения объёма напитка
    private var sugarPortion: Double = 0.0 // Шаг изменения количества сахара
    
    var currentDrink: Drink!
    
    // MARK: - System
    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drinkNamePicker.delegate = self
        drinkNamePicker.dataSource = self
        
        if currentDrink == nil { // Добавление нового напитка
            currentDrink = Drink()
        } else { // Просмотр/редактирование существующего напитка
            updateUI()
			
            self.drinkNamePicker.isHidden = true
            self.drinkNamePicker.alpha = 0.0
        }
        setupSteppers() // Начальная установка Stepper`ов
        
		setupNotificationsAndActions()
    }
	
	func setupNotificationsAndActions() {
		// Смена напитка нажатием на его имя (UILabel)
	    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.chooseDrink(_:)))
        nameLabel.isUserInteractionEnabled = true
        nameLabel.addGestureRecognizer(tapRecognizer)
        
		// Включение/выключения добавления сахара
		sugarAddedSwitch.addTarget(self, action: #selector(sugarSwitch(_:)), for: .valueChanged)
		
		// Реакция на появление клавиатуры
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
	}
    
    //MARK: - UI
    //MARK: -
    
    func updateUI() { // Приведение полей в соответствии с currentDrink
        imageDrink.image = currentDrink.type.image
		
        nameLabel.text = currentDrink.type.name
        volumeLabel.text = String(format: "%.0f мл", currentDrink.volume)
        sugarQuantityLabel.text = String(format: "%.1f г", currentDrink.sugar)
		
        impressionTextField.text = currentDrink.impression
        sugarAddedSwitch.isOn = currentDrink.sugarAdded
		
        actualizedSwich()
    }
	
	func actualizedSwich() { // Скрыть или показать управление добавления сахара
        if currentDrink.type.naturalSugar { // Уже содержит сахар, добавлять не надо
            sugarAddedSwitch.isHidden = true
            sugarAddedLabel.isHidden = true
        }
        
        sugarStepper.isHidden = !sugarAddedSwitch.isOn
        sugarPortionSegments.isHidden = !sugarAddedSwitch.isOn
    }
	
	func setupSteppers() { // Начальная установка Stepper`ов
        volumeStepper.minimumValue = 0
        volumeStepper.maximumValue = 2000
        
        sugarStepper.minimumValue = 0
        sugarStepper.maximumValue = 50
        
        volumeStepper.value = currentDrink.volume
        sugarStepper.value = currentDrink.sugar
        
        updateSteps()
    }
	
	func updateSteps() { // Обновления шага Stepper`ов
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
    
	// MARK: - Navigation
	// MARK: -
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == Constants.Segues.save.rawValue else {return}
        guard let listVC = segue.destination as? BeverageLogViewController else { return }
        
        currentDrink.type = DrinkType(rawValue: nameLabel.text!)!
        currentDrink.impression = impressionTextField.text!
        currentDrink.volume = volumeValue
        currentDrink.sugar = sugarValue 
        currentDrink.sugarAdded = sugarAddedSwitch.isOn
    }    
}

// MARK: - Actions
// MARK: -
 extension DrinkDetailViewController {   
	// Показ PickerView для выбора напитка
    @objc func chooseDrink(_ sender: UITapGestureRecognizer) {
		drinkNamePicker.showWithAnimation()
    }
	
	@IBAction func volumePortionChanged(_ sender: UISegmentedControl) { // Смена шага изменения объёма
		updateSteps()
    }
    
	@IBAction func sugarPortionChanged(_ sender: UISegmentedControl) { // Смена шага изменения сахара
		updateSteps()
    }
		
	@IBAction func volumeStepperPressed(_ sender: UIStepper) { // изменение объёма жидкости
        let volume = sender.value		
		volumeValue = volume
        
        // Может влиять на количество сахара у напитков с естественным содержанием сахара
        if currentDrink.type.naturalSugar {
			sugarValue = volume * currentDrink.type.sugarCoefficient
        }
    }
	
	@IBAction func sugarStepperPressed(_ sender: UIStepper) { // изменение количества сахара
		sugarValue = sender.value
    }
    
	@IBAction func sugarSwitch(_ sender: UISwitch) {
        actualizedSwich() // Переключатель возможности добавления сахара
		
        // обнулить сахар до стандартного значения при отключении переключателя
        if !sender.isOn {
            sugarValue = volumeValue * currentDrink.type.sugarCoefficient
        }
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
        currentDrink.type = DrinkType(rawValue: choosenDrink)!
        updateUI()
        
		drinkNamePicker.hideWithAnimation()
    }
}

//MARK: - Keyboard events
//MARK: -
 extension DrinkDetailViewController {
    
    @objc func keyboardWillChangeFrame(notification: Notification) {
        guard let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        guard let keyboardAnimationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        let keyboardHeight = keyboardSize.cgRectValue.height - self.view.safeAreaInsets.bottom
        
        self.impressionFieldMove(toHeight: keyboardHeight)
        
        UIView.animate(withDuration: keyboardAnimationDuration) {
            self.view.layoutIfNeeded()
        }
    }
	
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
}
