//
//  AddUpdatesViewController.swift
//  Hydr8
//
//  Created by Chloe Yan on 12/31/19.
//  Copyright © 2019 Chloe Yan. All rights reserved.
//

import UIKit
import BubbleTransition

class AddUpdatesViewController: UIViewController {
    
    // MARK: OUTLETS & ACTIONS

    @IBOutlet weak var addUpdateTextField: UITextField!
    @IBOutlet weak var addUpdatesButton: UIButton!
    @IBAction func addUpdatesButtonTapped(_ sender: Any) {
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
        UIView.animate(withDuration: 1.0, animations: {
            self.closeButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4)
            print("transforming")
        })
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
    }
  
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
    }
    
    // MARK: KEYBOARD FUNCTIONALITY
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
}
