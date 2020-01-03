//
//  SettingsViewController.swift
//  Hydr8
//
//  Created by Chloe Yan on 12/30/19.
//  Copyright © 2019 Chloe Yan. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    // MARK: OUTLETS & ACTIONS
    
    @IBOutlet weak var currentGoalLabel: UILabel!
    @IBOutlet weak var dailyGoalTextField: UITextField!
    @IBOutlet weak var setGoalButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBAction func setGoalButtonTapped(_ sender: Any) {
        // Exception handling for nil user input
        if (dailyGoalTextField.text != Optional("")) {
            goal = Int(dailyGoalTextField.text!)!
            errorLabel.isHidden = false
            errorLabel.text = "Goal set!"
            currentGoalLabel.text = String(goal)
        }
        else {
            errorLabel.isHidden = false
            errorLabel.text = "Please enter a value for your daily goal."
        }
    }
    
    // MARK: VARIABLES
    
    var goal: Int = 64
    
    // MARK: DEFAULT APPEARANCES
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentGoalLabel.text = String(goal)
        errorLabel.isHidden = true
        setGoalButton.layer.cornerRadius = 16
    }
    
    // MARK: KEYBOARD FUNCTIONALITY
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
}
