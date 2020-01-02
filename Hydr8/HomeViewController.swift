//
//  HomeViewController.swift
//  Hydr8
//
//  Created by Chloe Yan on 12/30/19.
//  Copyright © 2019 Chloe Yan. All rights reserved.
//

import UIKit
import BubbleTransition
import BAFluidView
import CoreMotion

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
    var fluidView: BAFluidView!
    var fluidView2: BAFluidView!
    var fluidView3: BAFluidView!
    let motionManager = CMMotionManager()

    // MARK: DEFAULT UI
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateStyle = .full
        dateString = dateFormatter.string(from: date)
        updatedDateString = String(dateString.prefix(dateString.count - 6))
        hour = calendar.component(.hour, from: date)
        
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.3
            motionManager.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: { data, error in
                let nc = NotificationCenter.default
                var userInfo: [String : CMDeviceMotion?]? = nil
                if let data = data {
                    userInfo = ["data" : data]
                }
                nc.post(name: NSNotification.Name(rawValue: kBAFluidViewCMMotionUpdate), object: self, userInfo: userInfo!)
            })
        }

        fluidView = BAFluidView(frame: view.frame, startElevation: NSNumber(value: 0.3))
        fluidView2 = BAFluidView(frame: view.frame, startElevation: NSNumber(value: 0.33))
        fluidView3 = BAFluidView(frame: view.frame, startElevation: NSNumber(value: 0.36))
        fluidView.fillColor = UIColor(red:0.75, green:0.87, blue:0.96, alpha:0.3)
        fluidView2.fillColor = UIColor(red:0.75, green:0.87, blue:0.96, alpha:0.1)
        fluidView3.fillColor = UIColor(red:0.75, green:0.87, blue:0.96, alpha:0.2)
        fluidView.strokeColor = UIColor.clear
        fluidView2.strokeColor = UIColor.clear
        fluidView3.strokeColor = UIColor.clear
        fluidView.keepStationary()
        fluidView2.keepStationary()
        fluidView3.keepStationary()
        fluidView.startAnimation()
        fluidView2.startAnimation()
        fluidView3.startAnimation()
        fluidView.startTiltAnimation()
        fluidView2.startTiltAnimation()
        fluidView3.startTiltAnimation()
        view.addSubview(fluidView)
        view.addSubview(fluidView2)
        view.addSubview(fluidView3)
        self.view.sendSubviewToBack(fluidView)
        self.view.sendSubviewToBack(fluidView2)
        self.view.sendSubviewToBack(fluidView3)
        
        bubbleEmitter()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        dateLabel.text = updatedDateString
        if (hour >= 1 && hour < 12) {
            greetingLabel.text = "Good morning"
        }
        else if (hour >= 12 && hour < 17) {
            greetingLabel.text = "Good afternoon."
        }
        else {
            greetingLabel.text = "Good evening"
        }
        greetingLabel.isHidden = false
        dateLabel.isHidden = false
        greetingLabel.frame = CGRect(x: -200, y: 100, width: self.greetingLabel.intrinsicContentSize.width, height: 30)
        dateLabel.frame = CGRect(x: -275, y: 130, width: self.dateLabel.intrinsicContentSize.width, height: 30)
        UIView.animate(withDuration: 1.2) {
            self.greetingLabel.frame = CGRect(x: self.addUpdatesButton.center.x, y: 100, width: self.greetingLabel.intrinsicContentSize.width, height: 30)
            self.greetingLabel.centerXAnchor.constraint(equalTo: self.addUpdatesButton.centerXAnchor).isActive = true
            self.dateLabel.frame = CGRect(x: self.addUpdatesButton.center.x, y: 130, width: self.dateLabel.intrinsicContentSize.width, height: 30)
            self.dateLabel.centerXAnchor.constraint(equalTo: self.addUpdatesButton.centerXAnchor).isActive = true
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

    // MARK: BUBBLE EMITTER
    
    func bubbleEmitter() {
        let emitter = BubbleEmitter.get(with: UIImage(named: "Bubble")!)
        emitter.emitterPosition = CGPoint(x: view.frame.width/2, y: view.frame.maxY)
        emitter.emitterSize = CGSize(width: view.frame.width, height: 2)
        view.layer.addSublayer(emitter)
    }
}
