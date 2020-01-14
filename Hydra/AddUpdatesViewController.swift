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
    
    var localWaterIntake = 0
    @IBAction func addUpdatesButtonTapped(_ sender: Any) {
        let homeVC = HomeViewController()
        homeVC.defaults.set((homeVC.defaults.double(forKey: "waterIntake") + ((addUpdateTextField.text as NSString?)?.doubleValue ?? 0) ), forKey: "waterIntake")
        homeVC.defaults.set((homeVC.defaults.double(forKey: "monthlyWaterIntake") + ((addUpdateTextField.text as NSString?)?.doubleValue ?? 0) ), forKey: "monthlyWaterIntake")
        self.dismiss(animated: true, completion: nil)
        interactiveTransition?.finish()
    }
    
    @objc func closeAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
        interactiveTransition?.finish()
    }

    
    // MARK: VARIABLES
    
    weak var interactiveTransition: BubbleInteractiveTransition?
    var cancelButton = UIButton()
  
    // MARK: DEFAULT APPEARANCES

    override func viewDidLoad() {
      super.viewDidLoad()
        print("view bounds x", view.bounds.maxX)
        print("view bounds y", view.bounds.maxY)
        print("x: ", (view.bounds.maxX/2)-(((60/650)*(view.bounds.maxY))/2))
        print("y: ", view.bounds.maxY-((175/650)*view.bounds.maxY))
        addUpdatesButton.layer.cornerRadius = 16
        cancelButton = UIButton()
        let xVal = (view.bounds.maxX/2)-(((60/650)*(view.bounds.maxY))/2)
        let yVal = (view.bounds.maxY-16)-((175/650)*(view.bounds.maxY-15))
        let cbWidth = ((60/650)*(view.bounds.maxY))
        let cbHeight = ((60/650)*(view.bounds.maxY))
        cancelButton.frame = CGRect(x: xVal, y: yVal, width: cbWidth, height: cbHeight)
        cancelButton.backgroundColor = UIColor(red:0.28, green:0.37, blue:0.64, alpha:1.0)
        cancelButton.setTitleColor(UIColor.white, for: .normal)
        cancelButton.setTitle("+", for: .normal)
        cancelButton.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 35)!
        cancelButton.layer.cornerRadius = (30/650)*(view.bounds.maxY)
        cancelButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        cancelButton.isEnabled = true
        view.addSubview(cancelButton)
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
