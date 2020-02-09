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
    @IBAction func setGoalButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGoalButton.layer.cornerRadius = 16
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
