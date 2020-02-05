//
//  AddUpdatesViewController.swift
//  Hydra
//
//  Created by Chloe Yan on 12/31/19.
//  Copyright © 2019 Chloe Yan. All rights reserved.
//
//  Tracks and manages water consumption data.

import UIKit
import BubbleTransition

class AddUpdatesViewController: UIViewController {
    
    // MARK: OUTLETS & ACTIONS

    @IBOutlet weak var addUpdateTextField: UITextField!
    @IBOutlet weak var addUpdatesButton: UIButton!
    
    // Updates weekly and monthly water intake values
    @IBAction func addUpdatesButtonTapped(_ sender: Any) {
        let homeVC = HomeViewController()
        homeVC.defaults.set((homeVC.defaults.double(forKey: "waterIntake") + ((addUpdateTextField.text as NSString?)?.doubleValue ?? 0) ), forKey: "waterIntake")
        homeVC.defaults.set((homeVC.defaults.double(forKey: "monthlyWaterIntake") + ((addUpdateTextField.text as NSString?)?.doubleValue ?? 0) ), forKey: "monthlyWaterIntake")
        self.dismiss(animated: true, completion: nil)
        interactiveTransition?.finish()
    }
    
    // Dismisses BubbleTransition to HomeViewController
    @objc func closeAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
        interactiveTransition?.finish()
    }

    // Closes the keyboard after done button is pressed
    @objc func doneButtonAction() {
        self.view.endEditing(true)
    }
    
    // MARK: VARIABLES
    
    weak var interactiveTransition: BubbleInteractiveTransition?
    var cancelButton = UIButton()
  
    // MARK: DEFAULT APPEARANCES

    override func viewDidLoad() {
      super.viewDidLoad()
        addUpdatesButton.layer.cornerRadius = 16
        cancelButton = UIButton()
        cancelButton.frame = CGRect(x: (view.bounds.maxX/2)-(((60/375)*(view.bounds.maxX))/2), y: (view.bounds.maxY+45)-((175/375)*view.bounds.maxX), width: ((60/375)*(view.bounds.maxX)), height: ((60/375)*(view.bounds.maxX)))
        cancelButton.layer.cornerRadius = (30/375)*(view.bounds.maxX)
        cancelButton.backgroundColor = UIColor(red:0.28, green:0.37, blue:0.64, alpha:1.0)
        cancelButton.setTitleColor(UIColor.white, for: .normal)
        cancelButton.setTitle("+", for: .normal)
        cancelButton.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 35)!
        cancelButton.transform = self.cancelButton.transform.rotated(by: CGFloat(M_PI_4))
        cancelButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        cancelButton.isEnabled = true
        view.addSubview(cancelButton)
        
        // Manages the done button on keyboard toolbar
        func setupTextFields() {
            let toolbar = UIToolbar(frame: CGRect(origin: .zero, size: .init(width: view.frame.size.width, height: 30)))
            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))
            toolbar.setItems([flexSpace, doneButton], animated: false)
            toolbar.sizeToFit()
            addUpdateTextField.inputAccessoryView = toolbar
        }
        setupTextFields()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
  
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: KEYBOARD FUNCTIONALITY
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
}
