//
//  CalculateGoalViewController.swift
//  Hydra
//
//  Created by Chloe Yan on 2/8/20.
//  Copyright © 2020 Chloe Yan. All rights reserved.
//

import UIKit

class CalculateGoalViewController: UIViewController {

    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var setGoalButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBAction func setGoalButtonTapped(_ sender: Any) {
        if (ageTextField.text != Optional("") && (ageTextField.text as NSString?)!.integerValue > 0 && weightTextField.text != Optional("") && (weightTextField.text as NSString?)!.integerValue > 0) {
            let age = Int(ageTextField.text!)
            let weight = Int(weightTextField.text!)!
            var goal = Double(weight)/2.2
            if (age! < 30) {
                goal *= 40
            }
            else if (age! >= 30 && age! <= 55) {
                goal *= 35
            }
            else {
                goal *= 30
            }
            let finalGoal = Int(goal/28.3)
            let hvc = HomeViewController()
            hvc.defaults.set(finalGoal, forKey: "dailyGoal")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refresh"), object: nil, userInfo: nil)
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // Keyboard functionality
    @objc func doneButtonAction() {
        self.view.endEditing(true)
    }
    
    func setupTextFields() {
        let toolbar = UIToolbar(frame: CGRect(origin: .zero, size: .init(width: view.frame.size.width, height: 30)))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))
        toolbar.setItems([flexSpace, doneButton], animated: false)
        toolbar.sizeToFit()
        ageTextField.inputAccessoryView = toolbar
        weightTextField.inputAccessoryView = toolbar
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGoalButton.layer.cornerRadius = 16
        cancelButton.transform = self.cancelButton.transform.rotated(by: CGFloat(M_PI_4))
        setupTextFields()
    }

}
