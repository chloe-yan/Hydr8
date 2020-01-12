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
    
    @IBOutlet weak var closeButton: UIButton!
    @IBAction func closeAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
        interactiveTransition?.finish()
    }

    
    // MARK: VARIABLES
    
    weak var interactiveTransition: BubbleInteractiveTransition?
  
    // MARK: DEFAULT APPEARANCES

    override func viewDidLoad() {
      super.viewDidLoad()
        addUpdatesButton.layer.cornerRadius = 16
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let hvc = HomeViewController()
        closeButton.frame = CGRect(x: (view.bounds.maxX/2)-(((60/650)*(view.bounds.maxY))/2), y: view.bounds.maxY-((175/650)*view.bounds.maxY), width: ((60/650)*(view.bounds.maxY)), height: ((60/650)*(view.bounds.maxY)))
        print("hvc x", view.bounds.maxX)
        print("hvc y", view.bounds.maxY)
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
