//
//  HomeViewController.swift
//  Hydr8
//
//  Created by Chloe Yan on 12/30/19.
//  Copyright © 2019 Chloe Yan. All rights reserved.
//

import UIKit
import BubbleTransition

class HomeViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    // MARK: OUTLETS & ACTIONS
    
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addUpdatesButton: UIButton!
    
    @IBAction func analyticsSwipe(_ sender: Any) {
        greetingLabel.isHidden = true
        dateLabel.isHidden = true
        performSegue(withIdentifier: "analytics", sender: self)
    }
    
    @IBAction func settingsSwipe(_ sender: Any) {
        greetingLabel.isHidden = true
        dateLabel.isHidden = true
        performSegue(withIdentifier: "settings", sender: self)
    }
    
    // MARK: VARIABLES
    
    var date = Date()
    var dateFormatter = DateFormatter()
    var dateString = ""
    var updatedDateString = ""
    var calendar = Calendar.current
    var hour = 0

    // MARK: DEFAULT UI
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateStyle = .full
        dateString = dateFormatter.string(from: date)
        updatedDateString = String(dateString.prefix(dateString.count - 6))
        hour = calendar.component(.hour, from: date)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        dateLabel.text = updatedDateString
        if (hour >= 1 && hour < 12) {
            greetingLabel.text = "Good morning."
        }
        else if (hour >= 12 && hour < 17) {
            greetingLabel.text = "Good afternoon."
        }
        else {
            greetingLabel.text = "Good evening."
        }
        greetingLabel.isHidden = false
        dateLabel.isHidden = false
        greetingLabel.frame = CGRect(x: -200, y: 90, width: self.greetingLabel.intrinsicContentSize.width, height: 30)
        dateLabel.frame = CGRect(x: -275, y: 120, width: self.dateLabel.intrinsicContentSize.width, height: 30)
        UIView.animate(withDuration: 1.2) {
            self.greetingLabel.frame = CGRect(x: self.view.center.x+100, y: 90, width: self.greetingLabel.intrinsicContentSize.width, height: 30)
            self.greetingLabel.center.x = self.view.center.x
            self.dateLabel.frame = CGRect(x: 100, y: 120, width: self.dateLabel.intrinsicContentSize.width, height: 30)
            self.dateLabel.center.x = self.view.center.x
        }
    }
    
    let transition = BubbleTransition()
    let interactiveTransition = BubbleInteractiveTransition()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? AddUpdatesViewController {
        controller.transitioningDelegate = self
        controller.modalPresentationStyle = .custom
        controller.interactiveTransition = interactiveTransition
        interactiveTransition.attach(to: controller)
            print("override func prepare")
      }
    }
    
    // MARK: UIViewControllerTransitioningDelegate
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
      transition.transitionMode = .present
      transition.startingPoint = addUpdatesButton.center
      transition.bubbleColor = addUpdatesButton.backgroundColor!
        greetingLabel.isHidden = true
        dateLabel.isHidden = true
        print("animation controller for presented")
      return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
      transition.transitionMode = .dismiss
      transition.startingPoint = addUpdatesButton.center
      transition.bubbleColor = addUpdatesButton.backgroundColor!
        print("animation controller for dismissed")
      return transition
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        print("interaction controller for dismissal")
      return interactiveTransition
    }

}
