//
//  HomeViewController.swift
//  Hydr8
//
//  Created by Chloe Yan on 12/30/19.
//  Copyright © 2019 Chloe Yan. All rights reserved.
//
//  Manages the home page's functionality and graphics.

import UIKit
import BubbleTransition
import BAFluidView
import CoreMotion

class HomeViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    // MARK: OUTLETS & ACTIONS
    
    @IBOutlet weak var addUpdatesButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var analyticsButton: UIButton!
    
    @objc func addUpdatesButtonTapped(sender: UIButton) {
        performSegue(withIdentifier: "addUpdates", sender: self)
    }
    
    @objc func setGoalButtonTapped(_ sender: Any) {
        // Exception handling for nil user input
        if (numericGoalTextField.text != Optional("")) {
            defaults.set(Int(numericGoalTextField.text!)!, forKey: "dailyGoal")
            goal = Double(Int(numericGoalTextField.text!)!)
            numericGoalLabel.text = "\(goal) oz"
            numericGoalTextField.text = ""
            percentageLabel.text = "\(Int(defaults.double(forKey: "waterIntake")/defaults.double(forKey: "dailyGoal")*100))%"
        }
        else {
            let alert = UIAlertController(title: "Please enter a goal", message: "Sorry! We couldn't understand your input.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // Keyboard functionality
    @objc func doneButtonAction() {
        self.view.endEditing(true)
    }
    
    // Button bar response
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        UIView.animate(withDuration: 0.3) {
            self.buttonBar.frame.origin.x = (self.segmentedControl.frame.width / CGFloat(self.segmentedControl.numberOfSegments)) * CGFloat(self.segmentedControl.selectedSegmentIndex) + ((self.segmentedControl.frame.width/CGFloat(self.segmentedControl.numberOfSegments))/2)
        }
    }
    
    func viewDidLoadDefaultButtonBar() {
        UIView.animate(withDuration: 0.3) {
            self.buttonBar.frame.origin.x = (self.segmentedControl.frame.width / CGFloat(self.segmentedControl.numberOfSegments)) * CGFloat(self.segmentedControl.selectedSegmentIndex) + ((self.segmentedControl.frame.width/CGFloat(self.segmentedControl.numberOfSegments))/2)
        }
    }
    
    // MARK: VARIABLES
    
    var date = Date()
    var dateFormatter = DateFormatter()
    var dateString = ""
    var updatedDateString = ""
    var currentDateString = ""
    
    var calendar = Calendar.current
    var hour = 0
    
    var fluidView: BAFluidView!
    var fluidView2: BAFluidView!
    
    var dropletFluidView: BAFluidView!
    var dropletFluidView2: BAFluidView!
    
    let motionManager = CMMotionManager()
    
    var trackIntakeButton: UIButton = UIButton()
    
    var greetingLabel: UILabel = UILabel()
    var dateLabel: UILabel = UILabel()
    
    var x : CGFloat = 0
    
    var currentDay = Date()
    
    let settingsLabel = UILabel()
    let currentGoalLabel = UILabel()
    let numericGoalLabel = UILabel()
    
    let dailyGoalLabel = UILabel()
    let numericGoalTextField = UITextField()
    let ounceLabel = UILabel()
    let setGoalButton = UIButton()
    
    let defaults = UserDefaults.standard
    lazy var goal = defaults.double(forKey: "dailyGoal")
    lazy var waterIntake = defaults.double(forKey: "waterIntake")
    
    lazy var currentDate = defaults.string(forKey: "currentDate")
    
    var maskingImage = UIImage(named: "Droplet")
    var maskingLayer = CALayer()
    let dropletOutlineImage = UIImage(named: "Droplet Outline")
    let dropletOutlineLayer = CALayer()
    let percentageLabel = UILabel()
    let waterIntakeLabel = UILabel()
    
    let analyticsLabel = UILabel()
    let segmentedControl = UISegmentedControl()
    let buttonBar = UIView()

    // MARK: DEFAULT UI
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // New animation
        let animation = CASpringAnimation(keyPath: "position")
        animation.fromValue = CGPoint(x: (view.bounds.maxX/2), y: 0)
        animation.toValue = CGPoint(x: (view.bounds.maxX/2), y: 45)
        animation.duration = 2
        animation.damping = 7
        let animation2 = CASpringAnimation(keyPath: "position")
        animation2.fromValue = CGPoint(x: (view.bounds.maxX/2), y: 0)
        animation2.toValue = CGPoint(x: (view.bounds.maxX/2), y: 75)
        animation2.duration = 2
        animation2.damping = 7
        greetingLabel.layer.add(animation, forKey: "basic animation")
        dateLabel.layer.add(animation2, forKey: "basic animation")

        
        // Reset user data
        dateFormatter.dateStyle = .full
        dateString = dateFormatter.string(from: date)
        currentDateString = String(dateString.prefix(dateString.count - 6))
        if (currentDateString != defaults.string(forKey: "currentDate")) {
            defaults.set(0, forKey: "waterIntake")
        }
        defaults.set(currentDateString, forKey: "currentDate")
        
        // Date greeting
        updatedDateString = String(dateString.prefix(dateString.count - 6))
        hour = calendar.component(.hour, from: date)
       
       // Accelerometer management
       if motionManager.isDeviceMotionAvailable {
           motionManager.deviceMotionUpdateInterval = 0.3
           motionManager.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: { data, error in
               let nc = NotificationCenter.default
               var userInfo: [String : CMDeviceMotion?]? = nil
               if let data = data {
                   userInfo = ["data" : data]
               }
               nc.post(name: NSNotification.Name(rawValue: kBAFluidViewCMMotionUpdate), object: self, userInfo: userInfo! as [AnyHashable : Any])
           })
       }

       // Background FluidView customizations
       fluidView = BAFluidView(frame: view.frame, startElevation: NSNumber(value: 0.23))
       fluidView2 = BAFluidView(frame: view.frame, startElevation: NSNumber(value: 0.26))
       
       fluidView.fillColor = UIColor(red:0.75, green:0.87, blue:0.96, alpha:0.3)
       fluidView2.fillColor = UIColor(red:0.75, green:0.87, blue:0.96, alpha:0.1)
       
       fluidView.strokeColor = UIColor.clear
       fluidView2.strokeColor = UIColor.clear
       
       fluidView.keepStationary()
       fluidView2.keepStationary()
       
       fluidView.startAnimation()
       fluidView2.startAnimation()
       
       fluidView.startTiltAnimation()
       fluidView2.startTiltAnimation()
       
       view.addSubview(fluidView)
       view.addSubview(fluidView2)
       
       self.view.sendSubviewToBack(fluidView)
       self.view.sendSubviewToBack(fluidView2)
       
       // Bubble animation
       bubbleEmitter()

       // Scroll view
       let scrollView : UIScrollView = UIScrollView(frame: CGRect(x: 0, y: 60, width: view.frame.maxX, height: view.frame.maxY-15))
       scrollView.isPagingEnabled = true
       scrollView.backgroundColor = UIColor.clear
       view.addSubview(scrollView)
       let padding : CGFloat = 0
       let viewWidth = scrollView.frame.size.width - 2 * padding
       let viewHeight = scrollView.frame.size.height - 2 * padding

       // Settings view page
       let settingsView: UIView = UIView(frame: CGRect(x: x - 200, y: padding + 40, width: viewWidth + 175, height: viewHeight - 120))
       settingsView.backgroundColor = UIColor.white.withAlphaComponent(1)
       settingsView.layer.cornerRadius = 40
       scrollView.addSubview(settingsView)
       x = settingsView.frame.origin.x + viewWidth + padding + 200
       
       // Settings label
       settingsLabel.text = "Settings"
       settingsLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 30)
       settingsLabel.textColor = UIColor(red:0.28, green:0.37, blue:0.64, alpha:1.0)
       settingsLabel.frame = CGRect(x: 250, y: 50, width: settingsLabel.intrinsicContentSize.width, height: settingsLabel.intrinsicContentSize.height
       )
       settingsView.addSubview(settingsLabel)
       
       // Current goal label
       currentGoalLabel.text = "Current Goal: "
       currentGoalLabel.font = UIFont(name: "AvenirNext-Medium", size: 18)
       currentGoalLabel.textColor = UIColor(red:0.28, green:0.37, blue:0.64, alpha:1.0)
       currentGoalLabel.frame = CGRect(x: 250, y: 120, width: currentGoalLabel.intrinsicContentSize.width, height: currentGoalLabel.intrinsicContentSize.height)
       settingsView.addSubview(currentGoalLabel)
       
       // Numeric goal label
       numericGoalLabel.text = "\(Int(goal)) oz"
       numericGoalLabel.font = UIFont(name: "AvenirNext-Medium", size: 18)
       numericGoalLabel.textColor = UIColor(red:0.28, green:0.37, blue:0.64, alpha:1.0)
       numericGoalLabel.frame = CGRect(x: 370, y: 120, width: numericGoalLabel.intrinsicContentSize.width + 50, height: numericGoalLabel.intrinsicContentSize.height)
       settingsView.addSubview(numericGoalLabel)
       
       // Daily goal label
       dailyGoalLabel.text = "Daily Goal: "
       dailyGoalLabel.font = UIFont(name: "AvenirNext-Medium", size: 18)
       dailyGoalLabel.textColor = UIColor(red:0.28, green:0.37, blue:0.64, alpha:1.0)
       dailyGoalLabel.frame = CGRect(x: 250, y: 155, width: dailyGoalLabel.intrinsicContentSize.width, height: dailyGoalLabel.intrinsicContentSize.height)
       settingsView.addSubview(dailyGoalLabel)
       
       // Numeric goal text field
       numericGoalTextField.font = UIFont(name: "AvenirNext-Medium", size: 16)
       numericGoalTextField.attributedPlaceholder = NSAttributedString(string: "ex. 64", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
       numericGoalTextField.textColor = UIColor.darkGray
       numericGoalTextField.borderStyle = UITextField.BorderStyle.roundedRect
       numericGoalTextField.keyboardType = UIKeyboardType.numberPad
       numericGoalTextField.frame = CGRect(x: 347, y: 150, width: numericGoalTextField.intrinsicContentSize.width, height: numericGoalTextField.intrinsicContentSize.height)
       settingsView.addSubview(numericGoalTextField)
       
       // Keyboard functionality
       func setupTextFields() {
           let toolbar = UIToolbar(frame: CGRect(origin: .zero, size: .init(width: settingsView.frame.size.width, height: 30)))
           let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
           let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))
           toolbar.setItems([flexSpace, doneButton], animated: false)
           toolbar.sizeToFit()
           numericGoalTextField.inputAccessoryView = toolbar
       }
       setupTextFields()
       
       // Ounce label
       ounceLabel.text = "oz"
       ounceLabel.font = UIFont(name: "AvenirNext-Medium", size: 18)
       ounceLabel.textColor = UIColor(red:0.28, green:0.37, blue:0.64, alpha:1.0)
       ounceLabel.frame = CGRect(x: 427, y: 155, width: ounceLabel.intrinsicContentSize.width, height: ounceLabel.intrinsicContentSize.height)
       settingsView.addSubview(ounceLabel)
       
       // Set goal button
       setGoalButton.backgroundColor = UIColor(red:0.28, green:0.37, blue:0.64, alpha:1.0)
       setGoalButton.setTitle("       Set goal       ", for: .normal)
       setGoalButton.setTitleColor(UIColor.white, for: .normal)
       setGoalButton.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 16)
       setGoalButton.addTarget(self, action: #selector(setGoalButtonTapped), for: .touchUpInside)
       setGoalButton.layer.cornerRadius = 17
       setGoalButton.frame = CGRect(x: 250, y: 200, width: setGoalButton.intrinsicContentSize.width, height: setGoalButton.intrinsicContentSize.height)
       settingsView.addSubview(setGoalButton)
       
       // Home view page
       let homeView: UIView = UIView(frame: CGRect(x: x + padding, y: padding, width: viewWidth, height: viewHeight))
       homeView.backgroundColor = UIColor.white.withAlphaComponent(0)
       x = homeView.frame.origin.x + viewWidth + padding
       scrollView.addSubview(homeView)
       
       // Track intake button
       trackIntakeButton = UIButton()
       trackIntakeButton.frame = CGRect(x: (view.frame.maxX/2)-30, y: view.frame.maxY/2+150, width: 60, height: 60)
       trackIntakeButton.backgroundColor = UIColor.white
       trackIntakeButton.setTitleColor(UIColor(red:0.28, green:0.37, blue:0.64, alpha:1.0), for: .normal)
       trackIntakeButton.setTitle("+", for: .normal)
       trackIntakeButton.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 35)!
       trackIntakeButton.layer.cornerRadius = 30
       trackIntakeButton.addTarget(self, action: #selector(addUpdatesButtonTapped), for: .touchUpInside)
       trackIntakeButton.isEnabled = true
       homeView.addSubview(trackIntakeButton)
    
       // Greeting label
       greetingLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 26)
       greetingLabel.textColor = UIColor.white
       homeView.addSubview(greetingLabel)
       
       // Date label
       dateLabel.font = UIFont(name: "AvenirNext-Medium", size: 19)
       dateLabel.textColor = UIColor.white
       homeView.addSubview(dateLabel)
       
       // Droplet FluidView
       // Threshold values: Min = 0.4, Max: 0.8
        dropletFluidView = BAFluidView(frame: view.frame, startElevation: NSNumber(value: ((0.37*defaults.double(forKey: "waterIntake")/defaults.double(forKey: "dailyGoal"))+0.4)))
       dropletFluidView.strokeColor = UIColor.clear
       dropletFluidView.fillColor = UIColor(red:0.64, green:0.71, blue:0.89, alpha:1.0)
       dropletFluidView.keepStationary()
       dropletFluidView.startAnimation()
       maskingLayer.frame = CGRect(x: (view.frame.maxX/2)-128, y: 150, width: maskingImage?.size.width ?? 0.0, height: maskingImage?.size.height ?? 0.0)
       maskingLayer.contents = maskingImage?.cgImage
       dropletFluidView.layer.mask = maskingLayer
       homeView.addSubview(dropletFluidView)
       homeView.sendSubviewToBack(dropletFluidView)

       // Droplet outline overlay
       dropletOutlineLayer.frame = CGRect(x: (view.frame.maxX/2)-128, y: 150, width: dropletOutlineImage!.size.width, height: dropletOutlineImage!.size.height)
       dropletOutlineLayer.contents = dropletOutlineImage?.cgImage
       dropletFluidView.layer.addSublayer(dropletOutlineLayer)
       
       // Percentage label
        percentageLabel.text = "\(Int(defaults.double(forKey: "waterIntake")/defaults.double(forKey: "dailyGoal")*100))%"
       percentageLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 23)
       percentageLabel.textColor = UIColor.white
       percentageLabel.frame = CGRect(x: (view.frame.maxX/2)-(percentageLabel.intrinsicContentSize.width/2), y: 265, width: percentageLabel.intrinsicContentSize.width+50, height: percentageLabel.intrinsicContentSize.height)
       homeView.addSubview(percentageLabel)
       
       // Water intake label
       waterIntakeLabel.text = "\(waterIntake) oz"
       waterIntakeLabel.font = UIFont(name: "AvenirNext-Medium", size: 18)
       waterIntakeLabel.textColor = UIColor.white
       waterIntakeLabel.frame = CGRect(x: (view.frame.maxX/2)-(waterIntakeLabel.intrinsicContentSize.width/2), y: 290, width: waterIntakeLabel.intrinsicContentSize.width, height: waterIntakeLabel.intrinsicContentSize.height)
       homeView.addSubview(waterIntakeLabel)
       
       // Analytics view page
       let analyticsView: UIView = UIView(frame: CGRect(x: x + 20, y: padding + 10, width: viewWidth - 40, height: viewHeight))
       analyticsView.backgroundColor = UIColor.white.withAlphaComponent(0)
       analyticsView.layer.cornerRadius = 40
       scrollView.addSubview(analyticsView)
        
        // Analytics background
        let analyticsBackgroundView: UIView = UIView(frame: CGRect(x: x + 20, y: padding + 90, width: viewWidth - 40, height: viewHeight))
        analyticsBackgroundView.backgroundColor = UIColor.white.withAlphaComponent(1)
        analyticsBackgroundView.layer.cornerRadius = 40
        scrollView.addSubview(analyticsBackgroundView)
        
        x = analyticsView.frame.origin.x + viewWidth
        
        // Segmented control
        segmentedControl.insertSegment(withTitle: "Week", at: 0, animated: true)
        segmentedControl.insertSegment(withTitle: "Month", at: 1, animated: true)
        segmentedControl.insertSegment(withTitle: "Year", at: 2, animated: true)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = .clear
        segmentedControl.tintColor = .clear
        segmentedControl.selectedSegmentTintColor = .clear
        
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "AvenirNext-Medium", size: 18) ?? nil!, NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "AvenirNext-Bold", size: 18) ?? nil!, NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        let responder = HomeViewController()
        segmentedControl.addTarget(responder, action: #selector(responder.segmentedControlValueChanged(_:)), for: UIControl.Event.valueChanged)
        segmentedControl.removeBorders()
        analyticsView.addSubview(segmentedControl)
        
        // Segmented control constraints
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.topAnchor.constraint(lessThanOrEqualTo: analyticsView.topAnchor, constant: 10).isActive = true
        segmentedControl.widthAnchor.constraint(equalToConstant: analyticsView.bounds.maxX-40).isActive = true
        segmentedControl.leadingAnchor.constraint(equalTo: analyticsView.leadingAnchor, constant: 20).isActive = true
        segmentedControl.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        // Button bar
        buttonBar.translatesAutoresizingMaskIntoConstraints = false
        buttonBar.backgroundColor = UIColor.white
        analyticsView.addSubview(buttonBar)
        
        // Button bar constraints
        buttonBar.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor).isActive = true
        buttonBar.heightAnchor.constraint(equalToConstant: 3).isActive = true
        buttonBar.leadingAnchor.constraint(equalTo: segmentedControl.leadingAnchor, constant: (segmentedControl.frame.width / CGFloat(segmentedControl.numberOfSegments) / 4)).isActive = true
        print("leading anchor: \(buttonBar.leadingAnchor)")
        print("other stuff: \((segmentedControl.frame.width / CGFloat(segmentedControl.numberOfSegments) / 4))")
        print("stuff: \(segmentedControl.frame.width)")
        print("stuff2: \(segmentedControl.bounds.maxX)")
        buttonBar.widthAnchor.constraint(equalToConstant: 40).isActive = true
        buttonBar.layer.cornerRadius = 3
        
       // Analytics label
       analyticsLabel.text = "Analytics"
       analyticsLabel.textColor = UIColor.black
       analyticsLabel.font = UIFont(name: "montserrat-bold", size: 30)
       analyticsLabel.frame = CGRect(x: 770, y: 30, width: analyticsLabel.intrinsicContentSize.width, height: analyticsLabel.intrinsicContentSize.height)
       analyticsView.addSubview(analyticsLabel)

       // Scroll view metrics
       scrollView.contentSize = CGSize(width:x+padding, height:scrollView.frame.size.height)
       scrollView.setContentOffset(CGPoint(x: 375, y: padding), animated: true)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        viewDidLoadDefaultButtonBar()
        
        // Reset user data
        dateFormatter.dateStyle = .full
        dateString = dateFormatter.string(from: date)
        currentDateString = String(dateString.prefix(dateString.count - 6))
        if (currentDateString != defaults.string(forKey: "currentDate")) {
            defaults.set(0, forKey: "waterIntake")
        }
        defaults.set(currentDateString, forKey: "currentDate")
        
        // Update user data
        waterIntake = defaults.double(forKey: "waterIntake")
        waterIntakeLabel.text = "\(waterIntake) oz"
        percentageLabel.text = "\(Int(defaults.double(forKey: "waterIntake")/defaults.double(forKey: "dailyGoal")*100))%"
        dropletFluidView = BAFluidView(frame: view.frame, startElevation: NSNumber(value: ((0.37*defaults.double(forKey: "waterIntake")/defaults.double(forKey: "dailyGoal"))+0.4)))

        // Determine greeting message
        dateLabel.text = updatedDateString
        if (hour >= 1 && hour < 12) {
            greetingLabel.text = "Good morning"
        }
        else if (hour >= 12 && hour < 17) {
            greetingLabel.text = "Good afternoon"
        }
        else {
            greetingLabel.text = "Good evening"
        }
        
        // Hide greeting messages
        greetingLabel.isHidden = false
        dateLabel.isHidden = false
        
        // Greeting message metrics
        greetingLabel.frame = CGRect(x: (view.bounds.maxX/2)-(self.greetingLabel.intrinsicContentSize.width/2), y: 30, width: self.greetingLabel.intrinsicContentSize.width, height: 30)
        dateLabel.frame = CGRect(x: (view.bounds.maxX/2)-(self.dateLabel.intrinsicContentSize.width/2), y: 60, width: self.dateLabel.intrinsicContentSize.width, height: 30)
        
        // New animation
        let animation = CASpringAnimation(keyPath: "position")
        animation.fromValue = CGPoint(x: (view.bounds.maxX/2), y: 0)
        animation.toValue = CGPoint(x: (view.bounds.maxX/2), y: 45)
        animation.duration = 2
        animation.damping = 7
        let animation2 = CASpringAnimation(keyPath: "position")
        animation2.fromValue = CGPoint(x: (view.bounds.maxX/2), y: 0)
        animation2.toValue = CGPoint(x: (view.bounds.maxX/2), y: 75)
        animation2.duration = 2
        animation2.damping = 7
        greetingLabel.layer.add(animation, forKey: "basic animation")
        dateLabel.layer.add(animation2, forKey: "basic animation")
    
    }
    
    // Initialize BubbleTransition
    let transition = BubbleTransition()
    let interactiveTransition = BubbleInteractiveTransition()
    
    // BubbleTransition to AddUpdatesViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? AddUpdatesViewController {
        controller.transitioningDelegate = self
        controller.modalPresentationStyle = .custom
        controller.interactiveTransition = interactiveTransition
        interactiveTransition.attach(to: controller)
      }
    }
    
    // MARK: UIViewControllerTransitioningDelegate
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
      transition.transitionMode = .present
        transition.startingPoint = CGPoint(x: trackIntakeButton.center.x, y: view.frame.maxY-100) //trackIntakeButton.center
        print("transition starting point: \(transition.startingPoint)")
      transition.bubbleColor = trackIntakeButton.backgroundColor!
        greetingLabel.isHidden = true
        dateLabel.isHidden = true
      return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
      transition.transitionMode = .dismiss
        transition.startingPoint = CGPoint(x: trackIntakeButton.center.x, y: view.frame.maxY-100) //trackIntakeButton.center
      transition.bubbleColor = trackIntakeButton.backgroundColor!
      return transition
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
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

extension UISegmentedControl {
    func removeBorders() {
        setBackgroundImage(imageWithColor(color: UIColor.clear), for: .normal, barMetrics: .default)
        setBackgroundImage(imageWithColor(color: UIColor.clear), for: .selected, barMetrics: .default)
        setDividerImage(imageWithColor(color: UIColor.clear), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
    }

    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor);
        context!.fill(rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!
    }
}
