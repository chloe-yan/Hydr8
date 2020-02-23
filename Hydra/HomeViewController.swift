//
//  HomeViewController.swift
//  Hydra
//
//  Created by Chloe Yan on 12/30/19.
//  Copyright © 2019 Chloe Yan. All rights reserved.
//
//  Manages the home page's functionality and graphics.

import UIKit
import BubbleTransition
import BAFluidView
import CoreMotion
import UserNotifications

class HomeViewController: UIViewController, UIViewControllerTransitioningDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    // MARK: OUTLETS & ACTIONS
    
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var analyticsButton: UIButton!
    @IBOutlet weak var weeklyBarChart: BasicBarChart!
    @IBOutlet weak var monthlyBarChart: BasicBarChart!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBAction func settingsButtonTapped(_ sender: Any) {
        if (settingsButton.currentImage == UIImage(named: "Settings - Gray")!) {
            scrollView.setContentOffset(CGPoint(x: settingsView.bounds.minX, y: 0), animated: true)
        }
    }
    @IBAction func analyticsButtonTapped(_ sender: Any) {
        if (analyticsButton.currentImage == UIImage(named: "Graph - Gray")! && settingsButton.currentImage == UIImage(named: "Settings - White")!) {
            scrollView.setContentOffset(CGPoint(x: scrollView.bounds.maxX*2, y: 0), animated: true)
        }
        else if (analyticsButton.currentImage == UIImage(named: "Graph - Gray")! && settingsButton.currentImage == UIImage(named: "Settings - Gray")!) {
            scrollView.setContentOffset(CGPoint(x: scrollView.bounds.maxX, y: 0), animated: true)
        }
    }
    
    // MARK: FUNCTIONS
    
    @objc func addUpdatesButtonTapped(sender: UIButton) {
        performSegue(withIdentifier: "addUpdates", sender: self)
    }
    
    @objc func setGoalButtonTapped(_ sender: Any) {
        // Exception handling for nil user input
        if (numericGoalTextField.text != Optional("") && (numericGoalTextField.text as NSString?)!.integerValue > 0) {
            defaults.set(Int(numericGoalTextField.text!)!, forKey: "dailyGoal")
            goal = Double(Int(numericGoalTextField.text!)!)
            numericGoalLabel.text = "\(goal) oz"
            numericGoalTextField.text = ""
            percentageLabel.text = "\(Int(defaults.double(forKey: "waterIntake")/defaults.double(forKey: "dailyGoal")*100))%"
            dropletOutlineLayer.removeFromSuperlayer()
            dropletFluidView.removeFromSuperview()
            dropletFluidView = BAFluidView(frame: view.frame, startElevation: NSNumber(value: ((0.37*defaults.double(forKey: "waterIntake")/defaults.double(forKey: "dailyGoal"))+0.4)))
            dropletFluidView.strokeColor = UIColor.clear
            dropletFluidView.fillColor = UIColor(red:0.64, green:0.71, blue:0.89, alpha:1.0)
            let offsetConstant = (((256/375)*(view.frame.maxX))/2)
            maskingLayer.frame = CGRect(x: (view.frame.maxX/2)-offsetConstant, y: (view.frame.maxY/2)-offsetConstant*(1+(1/2.5)), width: offsetConstant*2, height: offsetConstant*2)
            maskingLayer.contents = maskingImage?.cgImage
            dropletFluidView.layer.mask = maskingLayer
            homeView.addSubview(dropletFluidView)
            homeView.sendSubviewToBack(dropletFluidView)
            dropletOutlineLayer.frame = CGRect(x: (view.frame.maxX/2)-offsetConstant, y: (view.frame.maxY/2)-offsetConstant*(1+(1/2.5)), width: offsetConstant*2, height: offsetConstant*2)
            dropletOutlineLayer.contents = dropletOutlineImage?.cgImage
            dropletFluidView.layer.addSublayer(dropletOutlineLayer)
            
            if (defaults.double(forKey: "waterIntake") >= defaults.double(forKey: "dailyGoal") && defaults.bool(forKey: "alreadyUpdatedGoalsReached") == false) {
                defaults.set(true, forKey: "alreadyUpdatedGoalsReached")
                defaults.set(goalsReached+1, forKey: "goalsReached")
                if (defaults.integer(forKey: "goalsReached") == 1) {
                    numDailyGoalsReachedLabel.text = "Goals reached:   " + String(defaults.integer(forKey: "goalsReached")) + " day"
                }
                else {
                    numDailyGoalsReachedLabel.text = "Goals reached:   " + String(defaults.integer(forKey: "goalsReached")) + " days"
                }
            }
            if (defaults.double(forKey: "waterIntake") < defaults.double(forKey: "dailyGoal") && defaults.bool(forKey: "alreadyUpdatedGoalsReached") == true) {
                defaults.set(goalsReached-1, forKey: "goalsReached")
                defaults.set(false, forKey: "alreadyUpdatedGoalsReached")
                if (defaults.integer(forKey: "goalsReached") == 1) {
                    numDailyGoalsReachedLabel.text = "Goals reached:   " + String(defaults.integer(forKey: "goalsReached")) + " day"
                }
                else {
                    numDailyGoalsReachedLabel.text = "Goals reached:   " + String(defaults.integer(forKey: "goalsReached")) + " days"
                }
            }
            percentageDailyGoalReachedLabel.text = "Percentage of goals reached   " + "\n" + String(Int(defaults.integer(forKey: "goalsReached")/daysSinceInstalled)*100) + "%"
        }
        else if (numericGoalTextField.text != Optional("") && (numericGoalTextField.text as NSString?)!.integerValue <= 0) {
            let alert = UIAlertController(title: "Oops!", message: "Try setting a higher goal.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Oops!", message: "Please enter a goal.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func calculateGoalButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "calculateGoal", sender: self)
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
        var sum = 0
        var count = 0
        if (segmentedControl.selectedSegmentIndex == 0) {
            weeklyBarChart.isHidden = false
            monthlyBarChart.isHidden = true
            averageWaterIntakeView.isHidden = false
            totalWaterIntakeView.isHidden = false
            averageWaterIntakeLabel.isHidden = false
            totalWaterIntakeLabel.isHidden = false
            averageYearlyWaterIntakeView.isHidden = true
            numDailyGoalsReachedView.isHidden = true
            percentageDailyGoalReachedView.isHidden = true
            averageYearlyWaterIntakeLabel.isHidden = true
            numDailyGoalsReachedLabel.isHidden = true
            percentageDailyGoalReachedLabel.isHidden = true
            let weeklyDataArray = defaults.array(forKey: "weeklyWaterIntakeData")!
            for i in weeklyDataArray {
                if ((i as! Int) != 0 && i != nil) {
                    sum += (i as! Int)
                    count += 1
                }
            }
            let averageValue = Double(sum)/Double(count)
            let roundedAverage = String(format: "%.2f", averageValue)
            if (roundedAverage == "nan") {
                averageWaterIntakeLabel.text = "Daily average:   0 oz"
            }
            else {
                averageWaterIntakeLabel.text = "Daily average:   " + roundedAverage + " oz"
            }
            totalWaterIntakeLabel.text = "Total intake:   " + String(sum) + " oz"
        }
        else if (segmentedControl.selectedSegmentIndex == 1) {
            weeklyBarChart.isHidden = true
            monthlyBarChart.isHidden = false
            averageWaterIntakeView.isHidden = false
            totalWaterIntakeView.isHidden = false
            averageWaterIntakeLabel.isHidden = false
            totalWaterIntakeLabel.isHidden = false
            averageYearlyWaterIntakeView.isHidden = true
            numDailyGoalsReachedView.isHidden = true
            percentageDailyGoalReachedView.isHidden = true
            averageYearlyWaterIntakeLabel.isHidden = true
            numDailyGoalsReachedLabel.isHidden = true
            percentageDailyGoalReachedLabel.isHidden = true
            let monthlyDataArray = defaults.array(forKey: "monthlyWaterIntakeData")!
            for i in monthlyDataArray {
                if ((i as! Int) != 0 && i != nil) {
                    sum += (i as! Int)
                    count += 1
                }
            }
            let averageValue = Double(sum)/Double(count)
            let roundedAverage = String(format: "%.2f", averageValue)
            if (roundedAverage == "nan") {
                averageWaterIntakeLabel.text = "Monthly average:   0 oz"
            }
            else {
                averageWaterIntakeLabel.text = "Monthly average:   " + roundedAverage + " oz"
            }
            totalWaterIntakeLabel.text = "Total intake:   " + String(sum) + " oz"
        }
        else {
            weeklyBarChart.isHidden = true
            monthlyBarChart.isHidden = true
            averageWaterIntakeView.isHidden = true
            totalWaterIntakeView.isHidden = true
            averageWaterIntakeLabel.isHidden = true
            totalWaterIntakeLabel.isHidden = true
            averageYearlyWaterIntakeView.isHidden = false
            numDailyGoalsReachedView.isHidden = false
            percentageDailyGoalReachedView.isHidden = false
            averageYearlyWaterIntakeLabel.isHidden = false
            numDailyGoalsReachedLabel.isHidden = false
            percentageDailyGoalReachedLabel.isHidden = false
            let monthlyDataArray = defaults.array(forKey: "monthlyWaterIntakeData")!
            for i in monthlyDataArray {
                if ((i as! Int) != 0) {
                    sum += (i as! Int)
                    print("HI")
                    print("SUM: ", sum)
                    count += 1
                }
            }
            let installDate = defaults.string(forKey: "installDate")
            print("INSTALL DATE: ", installDate!)
            let updatedInstallDate = installDate!.date(format:"yyyy-MM-dd HH:mm:ss")
            print("UPDATED INSTALL DATE: ", updatedInstallDate!)
            let currentDate = Date()
            print("CURRENT DATE: ", currentDate)
            defaults.set((Calendar.current.dateComponents([.day], from: calendar.startOfDay(for: updatedInstallDate!), to: calendar.startOfDay(for: currentDate)).day ?? 5)+1, forKey: "daysSinceInstalled")
            daysSinceInstalled = (Calendar.current.dateComponents([.day], from: calendar.startOfDay(for: updatedInstallDate!), to: calendar.startOfDay(for: currentDate)).day ?? 5)+1
            print(daysSinceInstalled)
            var averageValue = 0.0
            if (daysSinceInstalled == 0) {
                averageValue = Double(sum)
            }
            else {
                averageValue = Double(sum)/Double(daysSinceInstalled)
                print("SUM: ", sum)
                print("AVERAGE VALUE: ", averageValue)
            }
            print("AV VALUE: ", averageValue)
            let roundedAverage = String(format: "%.2f", averageValue)
            averageYearlyWaterIntakeLabel.text = "Daily average:   " + roundedAverage + " oz"
            print("ROUNDED AVERAGE: ", roundedAverage)
            
            percentageDailyGoalReachedLabel.text = "Percentage of goals reached   " + "\n" + String(Int(defaults.integer(forKey: "goalsReached")/daysSinceInstalled)*100) + "%"
        }
        
    }
    
    // Updates menu control UI
    @objc func update() {
        if (scrollView.currentPage == 1) {
            settingsButton.setImage(UIImage(named: "Settings - White"), for: .normal)
            analyticsButton.setImage(UIImage(named: "Graph - Gray"), for: .normal)
        }
        else if (scrollView.currentPage == 2) {
            settingsButton.setImage(UIImage(named: "Settings - Gray"), for: .normal)
            analyticsButton.setImage(UIImage(named: "Graph - Gray"), for: .normal)
        }
        else {
            settingsButton.setImage(UIImage(named: "Settings - Gray"), for: .normal)
            analyticsButton.setImage(UIImage(named: "Graph - White"), for: .normal)
        }
    }
    
    @objc func refreshCurrentGoalLabel(notification: NSNotification) {
        numericGoalLabel.text = String(defaults.integer(forKey: "dailyGoal")) + " oz"
        dropletOutlineLayer.removeFromSuperlayer()
        dropletFluidView.removeFromSuperview()
        dropletFluidView = BAFluidView(frame: view.frame, startElevation: NSNumber(value: ((0.37*defaults.double(forKey: "waterIntake")/defaults.double(forKey: "dailyGoal"))+0.4)))
        dropletFluidView.strokeColor = UIColor.clear
        dropletFluidView.fillColor = UIColor(red:0.64, green:0.71, blue:0.89, alpha:1.0)
        let offsetConstant = (((256/375)*(view.frame.maxX))/2)
        maskingLayer.frame = CGRect(x: (view.frame.maxX/2)-offsetConstant, y: (view.frame.maxY/2)-offsetConstant*(1+(1/2.5)), width: offsetConstant*2, height: offsetConstant*2)
        maskingLayer.contents = maskingImage?.cgImage
        dropletFluidView.layer.mask = maskingLayer
        homeView.addSubview(dropletFluidView)
        homeView.sendSubviewToBack(dropletFluidView)
        
        dropletOutlineLayer.frame = CGRect(x: (view.frame.maxX/2)-offsetConstant, y: (view.frame.maxY/2)-offsetConstant*(1+(1/2.5)), width: offsetConstant*2, height: offsetConstant*2)
        dropletOutlineLayer.contents = dropletOutlineImage?.cgImage
        dropletFluidView.layer.addSublayer(dropletOutlineLayer)
    }
    
    // Manages state of notifications switch
    @objc func switchStateDidChange(_ sender:UISwitch){
        if (sender.isOn == true){
            allowNotificationsLabel.textColor = UIColor(red:0.28, green:0.37, blue:0.64, alpha:0.8)
            UIApplication.shared.registerForRemoteNotifications()
            defaults.set(sender.isOn, forKey: "switchState")
            
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound])
                { (granted, error) in
            }
            
            let content = UNMutableNotificationContent()
            content.title = "Rise and shine! ☀️"
            content.body = "Wake up with a refreshing glass of water."
            var dateInfo = DateComponents()
            dateInfo.hour = 8
            dateInfo.minute = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: true)
            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
            center.add(request)
            
            let content2 = UNMutableNotificationContent()
            content2.title = "Hey there! 😊"
            content2.body = "It's time to drink some more water."
            var dateInfo2 = DateComponents()
            dateInfo2.hour = 15
            dateInfo2.minute = 0
            let trigger2 = UNCalendarNotificationTrigger(dateMatching: dateInfo2, repeats: true)
            let request2 = UNNotificationRequest(identifier: "secondNotification", content: content2, trigger: trigger2)
            center.add(request2)
            
        }
        else{
            allowNotificationsLabel.textColor = UIColor.lightGray
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            defaults.set(false, forKey: "switchState")
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
    
    var trackIntakeButton = UIButton()
    
    var greetingLabel: UILabel = UILabel()
    var dateLabel: UILabel = UILabel()
    
    var x : CGFloat = 0
    
  //  var currentDay = Date()
    
    let settingsLabel = UILabel()
    let currentGoalLabel = UILabel()
    let numericGoalLabel = UILabel()
    let allowNotificationsSwitch = UISwitch()
    let allowNotificationsLabel = UILabel()
    
    let dailyGoalLabel = UILabel()
    let numericGoalTextField = UITextField()
    let ounceLabel = UILabel()
    let setGoalButton = UIButton()
    let calculateGoalButton = UIButton()
    
    let defaults = UserDefaults.standard
    lazy var goal = defaults.double(forKey: "dailyGoal")
    lazy var waterIntake = defaults.double(forKey: "waterIntake")
    lazy var monthlyWaterIntake = defaults.double(forKey: "monthlyWaterIntake")
    lazy var goalsReached = defaults.integer(forKey: "goalsReached")
    lazy var alreadyUpdatedGoalsReached = defaults.bool(forKey: "alreadyUpdatedGoalsReached")
    lazy var percentageDailyGoalsReached = defaults.double(forKey: "percentageDailyGoalsReached")
    lazy var daysSinceInstalled = defaults.integer(forKey: "daysSinceInstalled")
    
    lazy var currentDate = defaults.string(forKey: "currentDate")
    lazy var currentDay = defaults.integer(forKey: "currentDay")
    lazy var currentMonth = defaults.integer(forKey: "currentMonth")
    lazy var currentYear = defaults.integer(forKey: "currentYear")
    
    let homeView = UIView()
    var maskingImage = UIImage(named: "Droplet")
    var maskingLayer = CALayer()
    let dropletOutlineImage = UIImage(named: "Droplet Outline")
    let dropletOutlineLayer = CALayer()
    let percentageLabel = UILabel()
    let waterIntakeLabel = UILabel()
    
    let analyticsLabel = UILabel()
    let averageWaterIntakeView = UIView()
    let totalWaterIntakeView = UIView()
    let averageYearlyWaterIntakeView = UIView()
    let numDailyGoalsReachedView = UIView()
    let percentageDailyGoalReachedView = UIView()
    let averageWaterIntakeLabel = UILabel()
    let totalWaterIntakeLabel = UILabel()
    let averageYearlyWaterIntakeLabel = UILabel()
    let numDailyGoalsReachedLabel = UILabel()
    let percentageDailyGoalReachedLabel = UILabel()
    let segmentedControl = UISegmentedControl()
    let buttonBar = UIView()
    lazy var weeklyWaterIntakeData = defaults.array(forKey: "weeklyWaterIntakeData")
    lazy var monthlyWaterIntakeData = defaults.array(forKey: "monthlyWaterIntakeData")
    lazy var yearlyWaterIntakeData = defaults.array(forKey: "yearlyWaterIntakeData")
    lazy var installDate = defaults.string(forKey: "installDate")
    
    let analyticsView = UIView()
    let settingsView = UIView()
    
    // MARK: DEFAULT UI
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(installDate)
        // Get install date
        if (defaults.string(forKey: "installDate") == nil) {
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let string = formatter.string(from: date)
            defaults.set(string, forKey: "installDate")
            print("HI", defaults.string(forKey: "installDate"))
        }
        
        print(installDate)
        installDate = defaults.string(forKey: "installDate")
        // Get days since installed
        let updatedInstallDate = installDate!.date(format:"yyyy-MM-dd HH:mm:ss")
        let currentDate = Date()
        defaults.set((Calendar.current.dateComponents([.day], from: calendar.startOfDay(for: updatedInstallDate!), to: calendar.startOfDay(for: currentDate)).day ?? 5)+1, forKey: "daysSinceInstalled")
        
        // Update control menu
        let timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(update), userInfo: nil, repeats: true)
 
        // Bar graph appearances
        weeklyBarChart.isHidden = false
        monthlyBarChart.isHidden = true
        
        // Initialize weekly water intake data
        for i in 0...6 {
            if (weeklyWaterIntakeData?[i] == nil) {
                let initArray: Array! = [0, 0, 0, 0, 0, 0, 0]
                defaults.set(initArray, forKey: "weeklyWaterIntakeData")
            }
        }
        
        // Initialize monthly water intake data
        for i in 0...11 {
            if (monthlyWaterIntakeData?[i] == nil) {
                let monthlyInitArray: Array! = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
                defaults.set(monthlyInitArray, forKey: "monthlyWaterIntakeData")
            }
        }
        
        // Set daily goal if not set
        if (defaults.double(forKey: "dailyGoal") == 0) {
            defaults.set(64, forKey: "dailyGoal")
        }

        // Update daily water intake
        var components = calendar.dateComponents([.weekday], from: date)
        let day = components.weekday! - 1
        weeklyWaterIntakeData = defaults.array(forKey: "weeklyWaterIntakeData")
        if (day == 0) {
            weeklyWaterIntakeData![6] = Int(defaults.double(forKey: "waterIntake"))
        }
        else if (day == 1) {
            let initArray = [Int(defaults.double(forKey: "waterIntake")), 0, 0, 0, 0, 0, 0]
            defaults.set(initArray, forKey: "weeklyWaterIntakeData")
        }
        else {
            weeklyWaterIntakeData![day-1] = Int(defaults.double(forKey: "waterIntake"))
        }
        defaults.set(weeklyWaterIntakeData, forKey: "weeklyWaterIntakeData")
        
        // Update monthly water intake
        components = calendar.dateComponents([.month], from: date)
        let month = components.month!
        monthlyWaterIntakeData = defaults.array(forKey: "monthlyWaterIntakeData")
        monthlyWaterIntakeData![month-1] = Int(defaults.double(forKey: "monthlyWaterIntake"))
        defaults.set(monthlyWaterIntakeData, forKey: "monthlyWaterIntakeData")
        
        // Determine if weekly reset needed
        if (month == defaults.integer(forKey: "currentMonth") && (day - defaults.integer(forKey: "currentDay")) >= 7) {
            let initArray: Array! = [0, 0, 0, 0, 0, 0, 0]
            defaults.set(initArray, forKey: "weeklyWaterIntakeData")
        }
        defaults.set(day, forKey: "currentDay")
        
        // Determine if yearly reset needed
        components = calendar.dateComponents([.year], from: date)
        let year = components.year!
        if (year != defaults.integer(forKey: "currentYear")) {
            let monthlyInitArray: Array! = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
            defaults.set(monthlyInitArray, forKey: "monthlyWaterIntakeData")
            defaults.set(0, forKey: "goalsReached")
        }
        defaults.set(year, forKey: "currentYear")
        
        // Reset daily user data
        dateFormatter.dateStyle = .full
        dateString = dateFormatter.string(from: date)
        currentDateString = String(dateString.prefix(dateString.count - 6))
        if (currentDateString != defaults.string(forKey: "currentDate")) {
            defaults.set(0, forKey: "waterIntake")
            defaults.set(false, forKey: "alreadyUpdatedGoalsReached")
        }
        defaults.set(currentDateString, forKey: "currentDate")
        
        // Reset monthly user data
        components = calendar.dateComponents([.month], from: date)
        currentMonth = components.month!
        if (currentMonth != defaults.integer(forKey: "currentMonth")) {
            defaults.set(0, forKey: "monthlyWaterIntake")
        }
        defaults.set(currentMonth, forKey: "currentMonth")
        
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
        scrollView.frame = CGRect(x: 0, y: 60, width: view.frame.maxX, height: view.frame.maxY-((15/375)*view.frame.maxY))
        scrollView.isPagingEnabled = true
        scrollView.backgroundColor = UIColor.clear
        view.addSubview(scrollView)
        let padding : CGFloat = 0
        let viewWidth = scrollView.frame.size.width - 2 * padding
        let viewHeight = scrollView.frame.size.height - 2 * padding

        // Settings view page
        let constConverter = (view.frame.maxX+view.frame.maxY)/2
        settingsView.frame = CGRect(x: -200, y: (15/521)*constConverter + (40/521)*constConverter, width: viewWidth + 175, height: viewHeight - ((120/521)*constConverter))
        settingsView.backgroundColor = UIColor.white.withAlphaComponent(1)
        settingsView.layer.cornerRadius = 40
        scrollView.addSubview(settingsView)
        x = settingsView.frame.origin.x + viewWidth + padding + 200
       
        // Settings label
        settingsLabel.text = "Settings"
        settingsLabel.font = UIFont(name: "AvenirNext-DemiBold", size: (30/550)*(settingsView.bounds.maxX))
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
        setGoalButton.frame = CGRect(x: 250, y: 200, width: setGoalButton.intrinsicContentSize.width, height:   setGoalButton.intrinsicContentSize.height)
        settingsView.addSubview(setGoalButton)
        
        // Allow notifications switch
        allowNotificationsSwitch.frame = CGRect(x: 245, y: settingsView.bounds.maxY-104, width: 0, height: 0)
        allowNotificationsSwitch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        allowNotificationsSwitch.onTintColor = UIColor(red:0.28, green:0.37, blue:0.64, alpha:0.8)
        allowNotificationsSwitch.addTarget(self, action: #selector(switchStateDidChange(_:)), for: .valueChanged)
        allowNotificationsSwitch.setOn(true, animated: false)
        settingsView.addSubview(allowNotificationsSwitch)
        
        // Allow notifications label
        allowNotificationsLabel.text = "Allow notifications"
        allowNotificationsLabel.font = UIFont(name: "AvenirNext-Medium", size: 14)
        if (defaults.bool(forKey: "switchState") == true) {
            allowNotificationsLabel.textColor = UIColor(red:0.28, green:0.37, blue:0.64, alpha:0.8)
        }
        else {
            allowNotificationsLabel.textColor = UIColor.lightGray
        }
        allowNotificationsLabel.frame = CGRect(x: 303, y: settingsView.bounds.maxY-98, width: allowNotificationsLabel.intrinsicContentSize.width, height: allowNotificationsLabel.intrinsicContentSize.height)
        settingsView.addSubview(allowNotificationsLabel)

        // Calculate goal button
        calculateGoalButton.backgroundColor = UIColor.clear //UIColor(red:0.28, green:0.37, blue:0.64, alpha:1.0)
        calculateGoalButton.setTitle("Calculate recommended goal", for: .normal)
        calculateGoalButton.setTitleColor(UIColor(red:0.28, green:0.37, blue:0.64, alpha:0.5), for: .normal)
        calculateGoalButton.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 14)
        calculateGoalButton.addTarget(self, action: #selector(calculateGoalButtonTapped), for: .touchUpInside)
        calculateGoalButton.layer.cornerRadius = 3
        calculateGoalButton.frame = CGRect(x: 250, y: settingsView.bounds.maxY-70, width: calculateGoalButton.intrinsicContentSize.width, height:   calculateGoalButton.intrinsicContentSize.height)
        settingsView.addSubview(calculateGoalButton)
        
       
        // Home view page
        homeView.frame = CGRect(x: x + padding, y: padding, width: viewWidth, height: viewHeight)
        homeView.backgroundColor = UIColor.white.withAlphaComponent(0)
        x = homeView.frame.origin.x + viewWidth + padding
        scrollView.addSubview(homeView)
       
        // Track intake button
        trackIntakeButton = UIButton()
        trackIntakeButton.frame = CGRect(x: (homeView.bounds.maxX/2)-(((60/375)*(homeView.bounds.maxX))/2), y: homeView.bounds.maxY-((175/375)*homeView.bounds.maxX), width: ((60/375)*(homeView.bounds.maxX)), height: ((60/375)*(homeView.bounds.maxX)))
        trackIntakeButton.backgroundColor = UIColor.white
        trackIntakeButton.setTitleColor(UIColor(red:0.28, green:0.37, blue:0.64, alpha:1.0), for: .normal)
        trackIntakeButton.setTitle("+", for: .normal)
        trackIntakeButton.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 35/60*trackIntakeButton.bounds.height)!
        trackIntakeButton.layer.cornerRadius = (30/375)*(homeView.bounds.maxX)
        trackIntakeButton.addTarget(self, action: #selector(addUpdatesButtonTapped), for: .touchUpInside)
        trackIntakeButton.isEnabled = true
        homeView.addSubview(trackIntakeButton)
    
        // Greeting label
        greetingLabel.font = UIFont(name: "AvenirNext-DemiBold", size: (26/375)*view.frame.maxX)
        greetingLabel.textColor = UIColor.white
        homeView.addSubview(greetingLabel)
       
        // Date label
        dateLabel.font = UIFont(name: "AvenirNext-Medium", size: (19/375)*view.frame.maxX)
        dateLabel.textColor = UIColor.white
        homeView.addSubview(dateLabel)

        // Droplet FluidView
        // Threshold values: Min = 0.4, Max: 0.8
        dropletFluidView = BAFluidView(frame: view.frame, startElevation: NSNumber(value: ((0.37*defaults.double(forKey: "waterIntake")/defaults.double(forKey: "dailyGoal"))+0.4)))
        dropletFluidView.strokeColor = UIColor.clear
        dropletFluidView.fillColor = UIColor(red:0.64, green:0.71, blue:0.89, alpha:1.0)
        dropletFluidView.keepStationary()
        dropletFluidView.startAnimation()
        let offsetConstant = (((256/375)*(view.frame.maxX))/2)
        maskingLayer.frame = CGRect(x: (view.frame.maxX/2)-offsetConstant, y: (view.frame.maxY/2)-offsetConstant*(1+(1/2.5)), width: offsetConstant*2, height: offsetConstant*2)
        maskingLayer.contents = maskingImage?.cgImage
        dropletFluidView.layer.mask = maskingLayer
        homeView.addSubview(dropletFluidView)
        homeView.sendSubviewToBack(dropletFluidView)
        
        // Droplet outline overlay
        dropletOutlineLayer.frame = CGRect(x: (view.frame.maxX/2)-offsetConstant, y: (view.frame.maxY/2)-offsetConstant*(1+(1/2.5)), width: offsetConstant*2, height: offsetConstant*2)
        dropletOutlineLayer.contents = dropletOutlineImage?.cgImage
        dropletFluidView.layer.addSublayer(dropletOutlineLayer)

        // Percentage label
        percentageLabel.text = "\(Int(defaults.double(forKey: "waterIntake")/defaults.double(forKey: "dailyGoal")*100))%"
        percentageLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 23)
        percentageLabel.textColor = UIColor.white
        percentageLabel.frame = CGRect(x: (view.frame.maxX/2)-(percentageLabel.intrinsicContentSize.width/2), y: dropletOutlineLayer.bounds.maxY, width: percentageLabel.intrinsicContentSize.width+50, height: percentageLabel.intrinsicContentSize.height)
        homeView.addSubview(percentageLabel)
       
        // Water intake label
        waterIntakeLabel.text = "\(waterIntake) oz"
        waterIntakeLabel.font = UIFont(name: "AvenirNext-Medium", size: 18)
        waterIntakeLabel.textColor = UIColor.white
        waterIntakeLabel.frame = CGRect(x: (view.frame.maxX/2)-(waterIntakeLabel.intrinsicContentSize.width/2), y: dropletOutlineLayer.bounds.maxY+34, width: waterIntakeLabel.intrinsicContentSize.width, height: waterIntakeLabel.intrinsicContentSize.height)
        homeView.addSubview(waterIntakeLabel)
       
        // Analytics view page
        analyticsView.frame = CGRect(x: x + 20, y: viewHeight-((592/640)*viewHeight)-20, width: viewWidth - 40, height: viewHeight)
        analyticsView.backgroundColor = UIColor.white.withAlphaComponent(0)
        analyticsView.layer.cornerRadius = 40
        scrollView.addSubview(analyticsView)
        
        // Analytics background
        let analyticsBackgroundView: UIView = UIView(frame: CGRect(x: x + 20, y: analyticsButton.bounds.maxY + (100/913)*analyticsView.frame.maxY, width: viewWidth - 40, height: viewHeight))
        analyticsBackgroundView.backgroundColor = UIColor.white.withAlphaComponent(1)
        analyticsBackgroundView.layer.cornerRadius = 40
        scrollView.addSubview(analyticsBackgroundView)
        x = analyticsView.frame.origin.x + viewWidth
        scrollView.sendSubviewToBack(analyticsBackgroundView)
        
        // Average water intake view
        averageWaterIntakeView.isHidden = false
        averageWaterIntakeView.frame = CGRect(x: 35, y: 390, width: analyticsBackgroundView.frame.width-70, height: 60)
        averageWaterIntakeView.backgroundColor = UIColor(red:0.28, green:0.37, blue:0.64, alpha:0.12)
        averageWaterIntakeView.layer.cornerRadius = 16
        analyticsView.addSubview(averageWaterIntakeView)
        
        // Total water intake view
        totalWaterIntakeView.isHidden = false
        totalWaterIntakeView.frame = CGRect(x: 35, y: 475, width: analyticsBackgroundView.frame.width-70, height: 60)
        totalWaterIntakeView.backgroundColor = UIColor(red:0.28, green:0.37, blue:0.64, alpha:0.12)
        totalWaterIntakeView.layer.cornerRadius = 16
        analyticsView.addSubview(totalWaterIntakeView)
        
        // Average yearly water intake view
        averageYearlyWaterIntakeView.isHidden = true
        averageYearlyWaterIntakeView.frame = CGRect(x: 35, y: 130, width: analyticsBackgroundView.frame.width-70, height: 60)
        averageYearlyWaterIntakeView.backgroundColor = UIColor(red:0.28, green:0.37, blue:0.64, alpha:0.12)
        averageYearlyWaterIntakeView.layer.cornerRadius = 16
        analyticsView.addSubview(averageYearlyWaterIntakeView)
        
        print("ANALYTICS VIEW MAXY", analyticsView.frame.maxY)
        print("ANALYTICS VIEW MAXX", analyticsView.frame.maxX)
        
        // Number of daily goals reached view
        numDailyGoalsReachedView.isHidden = true
        numDailyGoalsReachedView.frame = CGRect(x: 35, y: 215, width: analyticsBackgroundView.frame.width-70, height: 60)
        numDailyGoalsReachedView.backgroundColor = UIColor(red:0.28, green:0.37, blue:0.64, alpha:0.12)
        numDailyGoalsReachedView.layer.cornerRadius = 16
        analyticsView.addSubview(numDailyGoalsReachedView)
        
        // Percentage of daily goals reached view
        percentageDailyGoalReachedView.isHidden = true
        percentageDailyGoalReachedView.frame = CGRect(x: 35, y: 300, width: analyticsBackgroundView.frame.width-70, height: 80)
        percentageDailyGoalReachedView.backgroundColor = UIColor(red:0.28, green:0.37, blue:0.64, alpha:0.12)
        percentageDailyGoalReachedView.layer.cornerRadius = 16
        analyticsView.addSubview(percentageDailyGoalReachedView)
        
        // Average water intake label
        var sum = 0
        var count = 0
        let weeklyDataArray = defaults.array(forKey: "weeklyWaterIntakeData")!
        for i in weeklyDataArray {
            if ((i as! Int) != 0 && i != nil) {
                sum += (i as! Int)
                count += 1
            }
        }
        averageWaterIntakeLabel.isHidden = false
        averageWaterIntakeLabel.numberOfLines = 0
        let averageValue = Double(sum)/Double(count)
        let roundedAverage = String(format: "%.2f", averageValue)
        if (roundedAverage == "nan") {
            averageWaterIntakeLabel.text = "Daily average:   0 oz"
        }
        else {
            averageWaterIntakeLabel.text = "Daily average:   " + roundedAverage + " oz"
        }
        averageWaterIntakeLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 17)
        averageWaterIntakeLabel.frame = CGRect(x: 50, y: 390+(averageWaterIntakeView.frame.height/3), width: 280, height: averageWaterIntakeLabel.intrinsicContentSize.height)
        averageWaterIntakeLabel.textColor = UIColor(red:0.28, green:0.37, blue:0.64, alpha:0.8)
        analyticsView.addSubview(averageWaterIntakeLabel)
        
        // Total water intake label
        totalWaterIntakeLabel.isHidden = false
        totalWaterIntakeLabel.numberOfLines = 0
        totalWaterIntakeLabel.text = "Total intake:   " + String(sum) + " oz"
        totalWaterIntakeLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 17)
        totalWaterIntakeLabel.frame = CGRect(x: 50, y: 475+(totalWaterIntakeView.frame.height/3), width: 280, height: totalWaterIntakeLabel.intrinsicContentSize.height)
        totalWaterIntakeLabel.textColor = UIColor(red:0.28, green:0.37, blue:0.64, alpha:0.8)
        analyticsView.addSubview(totalWaterIntakeLabel)
        
        // Average yearly water intake label
        averageYearlyWaterIntakeLabel.isHidden = true
        averageYearlyWaterIntakeLabel.numberOfLines = 0
        averageYearlyWaterIntakeLabel.text = "Daily average:   " + String(0) + " oz"
        averageYearlyWaterIntakeLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 17)
        averageYearlyWaterIntakeLabel.frame = CGRect(x: 50, y: 130+(averageYearlyWaterIntakeView.frame.height/3), width: 280, height: averageYearlyWaterIntakeLabel.intrinsicContentSize.height)
        averageYearlyWaterIntakeLabel.textColor = UIColor(red:0.28, green:0.37, blue:0.64, alpha:0.8)
        analyticsView.addSubview(averageYearlyWaterIntakeLabel)
        
        // Number of daily goals reached label
        numDailyGoalsReachedLabel.isHidden = true
        numDailyGoalsReachedLabel.numberOfLines = 0
        if (defaults.integer(forKey: "goalsReached") == 1) {
            numDailyGoalsReachedLabel.text = "Goals reached:   " + String(defaults.integer(forKey: "goalsReached")) + " day"
        }
        else {
            numDailyGoalsReachedLabel.text = "Goals reached:   " + String(defaults.integer(forKey: "goalsReached")) + " days"
        }
        numDailyGoalsReachedLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 17)
        numDailyGoalsReachedLabel.frame = CGRect(x: 50, y: 215+(numDailyGoalsReachedView.frame.height/3), width: 280, height: numDailyGoalsReachedLabel.intrinsicContentSize.height)
        numDailyGoalsReachedLabel.textColor = UIColor(red:0.28, green:0.37, blue:0.64, alpha:0.8)
        analyticsView.addSubview(numDailyGoalsReachedLabel)
        
        print(currentDate)
        
        // Percentage of daily goals reached label
        percentageDailyGoalReachedLabel.isHidden = true
        percentageDailyGoalReachedLabel.numberOfLines = 2
        percentageDailyGoalReachedLabel.text = "Percentage of goals reached   " + "\n" + String(Int(defaults.integer(forKey: "goalsReached")/daysSinceInstalled)*100) + "%"
        percentageDailyGoalReachedLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 17)
        percentageDailyGoalReachedLabel.setLineSpacing(lineSpacing: 5.0)
        percentageDailyGoalReachedLabel.frame = CGRect(x: 50, y: 300+(percentageDailyGoalReachedLabel.intrinsicContentSize.height/2-10), width: 280, height: percentageDailyGoalReachedLabel.intrinsicContentSize.height)
        print(percentageDailyGoalReachedLabel.intrinsicContentSize.height)
        percentageDailyGoalReachedLabel.textColor = UIColor(red:0.28, green:0.37, blue:0.64, alpha:0.8)
        analyticsView.addSubview(percentageDailyGoalReachedLabel)
        
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
        segmentedControl.topAnchor.constraint(lessThanOrEqualTo: analyticsView.topAnchor, constant: 0).isActive = true
        segmentedControl.widthAnchor.constraint(equalToConstant: analyticsView.bounds.maxX-40).isActive = true
        segmentedControl.leadingAnchor.constraint(equalTo: analyticsView.leadingAnchor, constant: 20).isActive = true
        segmentedControl.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        // Button bar
        buttonBar.translatesAutoresizingMaskIntoConstraints = false
        buttonBar.backgroundColor = UIColor.white
        let buttonBarXPos = ((analyticsView.bounds.maxX-40 / CGFloat(self.segmentedControl.numberOfSegments)) * CGFloat(self.segmentedControl.selectedSegmentIndex)) + ((analyticsView.bounds.maxX-40)/CGFloat(self.segmentedControl.numberOfSegments))/2
        buttonBar.frame = CGRect(x: buttonBarXPos, y: segmentedControl.bounds.maxY+40, width: 40, height: 3)
        buttonBar.layer.cornerRadius = 3
        analyticsView.addSubview(buttonBar)
        
        // Weekly bar chart
        let dataEntries = generateWeeklyDataEntries()
        weeklyBarChart.updateDataEntries(dataEntries: dataEntries, animated: false)
        weeklyBarChart.frame = CGRect(x: (analyticsView.bounds.maxX/2) - (weeklyBarChart.bounds.maxX/2), y: 30, width: 300, height: 300)
        weeklyBarChart.backgroundColor = .clear
        analyticsView.addSubview(weeklyBarChart)
        
        // Monthly bar chart
        let monthlyDataEntries = generateMonthlyDataEntries()
        monthlyBarChart.updateDataEntries(dataEntries: monthlyDataEntries, animated: false)
        monthlyBarChart.frame = CGRect(x: (analyticsView.bounds.maxX/2) - (monthlyBarChart.bounds.maxX/2 - 7), y: 30, width: 300, height: 300)
        monthlyBarChart.backgroundColor = .clear
        analyticsView.addSubview(monthlyBarChart)
        
        // Scroll view metrics
        scrollView.contentSize = CGSize(width:x+padding, height:scrollView.frame.size.height)
        scrollView.setContentOffset(CGPoint(x: homeView.bounds.maxX, y: padding), animated: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshCurrentGoalLabel), name: NSNotification.Name(rawValue: "refresh"), object: nil)
    }
    
    func generateWeeklyDataEntries() -> [DataEntry] {
        var result: [DataEntry] = []
        weeklyWaterIntakeData = defaults.array(forKey: "weeklyWaterIntakeData")
        result.append(DataEntry(color: UIColor(red:0.28, green:0.37, blue:0.64, alpha:1.0), height: 0.01 + Double(weeklyWaterIntakeData?[0] as! Int)/100, textValue: weeklyWaterIntakeData![0] as! Int == 0 ? "" : "\(weeklyWaterIntakeData![0])", title: "M"))
        result.append(DataEntry(color: UIColor(red:0.28, green:0.37, blue:0.64, alpha:1.0), height: 0.01 + Double(weeklyWaterIntakeData?[1] as! Int)/100, textValue: weeklyWaterIntakeData![1] as! Int == 0 ? "" : "\(weeklyWaterIntakeData![1])", title: "T"))
        result.append(DataEntry(color: UIColor(red:0.28, green:0.37, blue:0.64, alpha:1.0), height: 0.01 + Double(weeklyWaterIntakeData?[2] as! Int)/100, textValue: weeklyWaterIntakeData![2] as! Int == 0 ? "" : "\(weeklyWaterIntakeData![2])", title: "W"))
        result.append(DataEntry(color: UIColor(red:0.28, green:0.37, blue:0.64, alpha:1.0), height: 0.01 + Double(weeklyWaterIntakeData?[3] as! Int)/100, textValue: weeklyWaterIntakeData![3] as! Int == 0 ? "" : "\(weeklyWaterIntakeData![3])", title: "T"))
        result.append(DataEntry(color: UIColor(red:0.28, green:0.37, blue:0.64, alpha:1.0), height: 0.01 + Double(weeklyWaterIntakeData?[4] as! Int)/100, textValue: weeklyWaterIntakeData![4] as! Int == 0 ? "" : "\(weeklyWaterIntakeData![4])", title: "F"))
        result.append(DataEntry(color: UIColor(red:0.28, green:0.37, blue:0.64, alpha:1.0), height: 0.01 + Double(weeklyWaterIntakeData?[5] as! Int)/100, textValue: weeklyWaterIntakeData![5] as! Int == 0 ? "" : "\(weeklyWaterIntakeData![5])", title: "S"))
        result.append(DataEntry(color: UIColor(red:0.28, green:0.37, blue:0.64, alpha:1.0), height: 0.01 + Double(weeklyWaterIntakeData?[6] as! Int)/100, textValue: weeklyWaterIntakeData![6] as! Int == 0 ? "" : "\(weeklyWaterIntakeData![6])", title: "S"))
        
        return result
    }
    
    func generateMonthlyDataEntries() -> [DataEntry] {
        var result: [DataEntry] = []
        monthlyWaterIntakeData = defaults.array(forKey: "monthlyWaterIntakeData")
        result.append(DataEntry(color: UIColor(red:0.28, green:0.37, blue:0.64, alpha:1.0), height: 0.01 + Double(monthlyWaterIntakeData?[0] as! Int)/100, textValue: monthlyWaterIntakeData![0] as! Int == 0 ? "" : "\(monthlyWaterIntakeData![0])", title: "J"))
        result.append(DataEntry(color: UIColor(red:0.28, green:0.37, blue:0.64, alpha:1.0), height: 0.01 + Double(monthlyWaterIntakeData?[1] as! Int)/100, textValue: monthlyWaterIntakeData![1] as! Int == 0 ? "" : "\(monthlyWaterIntakeData![1])", title: "F"))
        result.append(DataEntry(color: UIColor(red:0.28, green:0.37, blue:0.64, alpha:1.0), height: 0.01 + Double(monthlyWaterIntakeData?[2] as! Int)/100, textValue: monthlyWaterIntakeData![2] as! Int == 0 ? "" : "\(monthlyWaterIntakeData![2])", title: "M"))
        result.append(DataEntry(color: UIColor(red:0.28, green:0.37, blue:0.64, alpha:1.0), height: 0.01 + Double(monthlyWaterIntakeData?[3] as! Int)/100, textValue: monthlyWaterIntakeData![3] as! Int == 0 ? "" : "\(monthlyWaterIntakeData![3])", title: "A"))
        result.append(DataEntry(color: UIColor(red:0.28, green:0.37, blue:0.64, alpha:1.0), height: 0.01 + Double(monthlyWaterIntakeData?[4] as! Int)/100, textValue: monthlyWaterIntakeData![4] as! Int == 0 ? "" : "\(monthlyWaterIntakeData![4])", title: "M"))
        result.append(DataEntry(color: UIColor(red:0.28, green:0.37, blue:0.64, alpha:1.0), height: 0.01 + Double(monthlyWaterIntakeData?[5] as! Int)/100, textValue: monthlyWaterIntakeData![5] as! Int == 0 ? "" : "\(monthlyWaterIntakeData![5])", title: "J"))
        result.append(DataEntry(color: UIColor(red:0.28, green:0.37, blue:0.64, alpha:1.0), height: 0.01 + Double(monthlyWaterIntakeData?[6] as! Int)/100, textValue: monthlyWaterIntakeData![6] as! Int == 0 ? "" : "\(monthlyWaterIntakeData![6])", title: "J"))
        result.append(DataEntry(color: UIColor(red:0.28, green:0.37, blue:0.64, alpha:1.0), height: 0.01 + Double(monthlyWaterIntakeData?[7] as! Int)/100, textValue: monthlyWaterIntakeData![7] as! Int == 0 ? "" : "\(monthlyWaterIntakeData![7])", title: "A"))
        result.append(DataEntry(color: UIColor(red:0.28, green:0.37, blue:0.64, alpha:1.0), height: 0.01 + Double(monthlyWaterIntakeData?[8] as! Int)/100, textValue: monthlyWaterIntakeData![8] as! Int == 0 ? "" : "\(monthlyWaterIntakeData![8])", title: "S"))
        result.append(DataEntry(color: UIColor(red:0.28, green:0.37, blue:0.64, alpha:1.0), height: 0.01 + Double(monthlyWaterIntakeData?[9] as! Int)/100, textValue: monthlyWaterIntakeData![9] as! Int == 0 ? "" : "\(monthlyWaterIntakeData![9])", title: "O"))
        result.append(DataEntry(color: UIColor(red:0.28, green:0.37, blue:0.64, alpha:1.0), height: 0.01 + Double(monthlyWaterIntakeData?[10] as! Int)/100, textValue: monthlyWaterIntakeData![10] as! Int == 0 ? "" : "\(monthlyWaterIntakeData![10])", title: "N"))
        result.append(DataEntry(color: UIColor(red:0.28, green:0.37, blue:0.64, alpha:1.0), height: 0.01 + Double(monthlyWaterIntakeData?[11] as! Int)/100, textValue: monthlyWaterIntakeData![11] as! Int == 0 ? "" : "\(monthlyWaterIntakeData![11])", title: "D"))
        
        // Add keyboard functionality
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        scrollView.keyboardDismissMode = .interactive
        
        return result
    }
    
    // Runs before viewDidLoad
    override func viewDidAppear(_ animated: Bool) {
        
        // Corrects location of button bar
        //viewDidLoadDefaultButtonBar()
        
        // Update user data
        waterIntake = defaults.double(forKey: "waterIntake")
        waterIntakeLabel.text = "\(waterIntake) oz"
        waterIntakeLabel.frame = CGRect(x: (view.frame.maxX/2)-(waterIntakeLabel.intrinsicContentSize.width/2), y: homeView.bounds.midY+34-60, width: waterIntakeLabel.intrinsicContentSize.width, height: waterIntakeLabel.intrinsicContentSize.height)
        percentageLabel.text = "\(Int(defaults.double(forKey: "waterIntake")/defaults.double(forKey: "dailyGoal")*100))%"
        percentageLabel.frame = CGRect(x: (view.frame.maxX/2)-(percentageLabel.intrinsicContentSize.width/2), y: homeView.bounds.midY-60, width: percentageLabel.intrinsicContentSize.width+50, height: percentageLabel.intrinsicContentSize.height)
        
        // Reset daily user data
        dateFormatter.dateStyle = .full
        dateString = dateFormatter.string(from: date)
        currentDateString = String(dateString.prefix(dateString.count - 6))
        if (currentDateString != defaults.string(forKey: "currentDate")) {
            defaults.set(0, forKey: "waterIntake")
        }
        defaults.set(currentDateString, forKey: "currentDate")
        
        // Reset monthly user data
        var components = calendar.dateComponents([.month], from: date)
        currentMonth = components.month!
        if (currentMonth != defaults.integer(forKey: "currentMonth")) {
            defaults.set(0, forKey: "monthlyWaterIntake")
        }
        defaults.set(currentMonth, forKey: "currentMonth")
        
        // Determine greeting message
        dateLabel.text = updatedDateString
        if (hour >= 0 && hour < 12) {
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
        greetingLabel.frame = CGRect(x: (view.bounds.maxX/2)-(self.greetingLabel.intrinsicContentSize.width/2), y: (35/650)*homeView.frame.maxY+15+(15/780)*homeView.frame.maxY-15, width: self.greetingLabel.intrinsicContentSize.width, height: (30/375)*view.frame.maxX)
        dateLabel.frame = CGRect(x: (view.bounds.maxX/2)-(self.dateLabel.intrinsicContentSize.width/2), y: (65/650)*homeView.frame.maxY+15+(15/780)*homeView.frame.maxY-15, width: self.dateLabel.intrinsicContentSize.width, height: (30/375)*view.frame.maxX)
        
        // Greeting animations
        let animation = CASpringAnimation(keyPath: "position")
        animation.fromValue = CGPoint(x: (homeView.bounds.maxX/2), y: 0)
        animation.toValue = CGPoint(x: (homeView.bounds.maxX/2), y: (35/650)*homeView.frame.maxY+15+(15/780)*homeView.frame.maxY)
        animation.duration = 2
        animation.damping = 7
        let animation2 = CASpringAnimation(keyPath: "position")
        animation2.fromValue = CGPoint(x: (homeView.bounds.maxX/2), y: 0)
        animation2.toValue = CGPoint(x: (homeView.bounds.maxX/2), y: (65/650)*homeView.frame.maxY+15+(15/780)*homeView.frame.maxY)
        animation2.duration = 2
        animation2.damping = 7
        greetingLabel.layer.add(animation, forKey: "basic animation")
        dateLabel.layer.add(animation2, forKey: "basic animation")
        
        // Update monthly water intake
        components = calendar.dateComponents([.month], from: date)
        let month = components.month!
        monthlyWaterIntakeData = defaults.array(forKey: "monthlyWaterIntakeData")
        monthlyWaterIntakeData![month-1] = Int(defaults.double(forKey: "monthlyWaterIntake"))
        defaults.set(monthlyWaterIntakeData, forKey: "monthlyWaterIntakeData")
        
        // Update daily water intake
        components = calendar.dateComponents([.weekday], from: date)
        let day = components.weekday! - 1
        weeklyWaterIntakeData = defaults.array(forKey: "weeklyWaterIntakeData")
        if (day == 0) {
            weeklyWaterIntakeData![6] = Int(defaults.double(forKey: "waterIntake"))
        }
        else {
            weeklyWaterIntakeData![day-1] = Int(defaults.double(forKey: "waterIntake"))
        }
        defaults.set(weeklyWaterIntakeData, forKey: "weeklyWaterIntakeData")
        
        // Update bar chart data
        let monthlyDataEntries = generateMonthlyDataEntries()
        let weeklyDataEntries = generateWeeklyDataEntries()
        
        monthlyBarChart.updateDataEntries(dataEntries: monthlyDataEntries, animated: false)
        weeklyBarChart.updateDataEntries(dataEntries: weeklyDataEntries, animated: false)
        
        // Update average/total intake analytics
        var sum = 0
        var count = 0
        print(segmentedControl.selectedSegmentIndex)
        if (segmentedControl.selectedSegmentIndex == 0) {
            let weeklyDataArray = defaults.array(forKey: "weeklyWaterIntakeData")!
            for i in weeklyDataArray {
                if ((i as! Int) != 0 && i != nil) {
                    sum += (i as! Int)
                    count += 1
                }
            }
            let averageValue = Double(sum)/Double(count)
            let roundedAverage = String(format: "%.2f", averageValue)
            if (roundedAverage == "nan") {
                averageWaterIntakeLabel.text = "Daily average:   0 oz"
            }
            else {
                averageWaterIntakeLabel.text = "Daily average:   " + roundedAverage + " oz"
            }
            totalWaterIntakeLabel.text = "Total intake:   " + String(sum) + " oz"
        }
        else if (segmentedControl.selectedSegmentIndex == 1) {
            let monthlyDataArray = defaults.array(forKey: "monthlyWaterIntakeData")!
            for i in monthlyDataArray {
                if ((i as! Int) != 0 && i != nil) {
                    sum += (i as! Int)
                    count += 1
                }
            }
            let averageValue = Double(sum)/Double(count)
            let roundedAverage = String(format: "%.2f", averageValue)
            if (roundedAverage == "nan") {
                averageWaterIntakeLabel.text = "Monthly average:   0 oz"
            }
            else {
                averageWaterIntakeLabel.text = "Monthly average:   " + roundedAverage + " oz"
            }
            totalWaterIntakeLabel.text = "Total intake:   " + String(sum) + " oz"
        }
        
        // Updates notifications switch state
        allowNotificationsSwitch.isOn = defaults.bool(forKey: "switchState")
        
    }
    
    // MARK: BUBBLETRANSITION AND EMITTER ANIMATIONS
    
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
    
    // Animates presentation of BubbleTransition
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
      transition.transitionMode = .present
        transition.startingPoint = CGPoint(x: trackIntakeButton.center.x, y: trackIntakeButton.center.y+((60/375)*homeView.bounds.maxX)) //trackIntakeButton.center
      transition.bubbleColor = trackIntakeButton.backgroundColor!
      return transition
    }
    
    // Animates dismissal of BubbleTransition
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        greetingLabel.isHidden = true
        dateLabel.isHidden = true
        
        dropletOutlineLayer.removeFromSuperlayer()
        dropletFluidView.removeFromSuperview()
        dropletFluidView = BAFluidView(frame: view.frame, startElevation: NSNumber(value: ((0.37*defaults.double(forKey: "waterIntake")/defaults.double(forKey: "dailyGoal"))+0.4)))
        dropletFluidView.strokeColor = UIColor.clear
        dropletFluidView.fillColor = UIColor(red:0.64, green:0.71, blue:0.89, alpha:1.0)
        let offsetConstant = (((256/375)*(view.frame.maxX))/2)
        maskingLayer.frame = CGRect(x: (view.frame.maxX/2)-offsetConstant, y: (view.frame.maxY/2)-offsetConstant*(1+(1/2.5)), width: offsetConstant*2, height: offsetConstant*2)
        maskingLayer.contents = maskingImage?.cgImage
        dropletFluidView.layer.mask = maskingLayer
        homeView.addSubview(dropletFluidView)
        homeView.sendSubviewToBack(dropletFluidView)
        
        dropletOutlineLayer.frame = CGRect(x: (view.frame.maxX/2)-offsetConstant, y: (view.frame.maxY/2)-offsetConstant*(1+(1/2.5)), width: offsetConstant*2, height: offsetConstant*2)
        dropletOutlineLayer.contents = dropletOutlineImage?.cgImage
        dropletFluidView.layer.addSublayer(dropletOutlineLayer)
        transition.transitionMode = .dismiss
        transition.startingPoint = CGPoint(x: trackIntakeButton.center.x, y: (trackIntakeButton.center.y)+((60/375)*homeView.bounds.maxX))  //trackIntakeButton.center
        transition.bubbleColor = trackIntakeButton.backgroundColor!
        
        if (defaults.double(forKey: "waterIntake") >= defaults.double(forKey: "dailyGoal") && defaults.bool(forKey: "alreadyUpdatedGoalsReached") == false) {
            defaults.set(true, forKey: "alreadyUpdatedGoalsReached")
            defaults.set(goalsReached+1, forKey: "goalsReached")
            if (defaults.integer(forKey: "goalsReached") == 1) {
                numDailyGoalsReachedLabel.text = "Goals reached:   " + String(defaults.integer(forKey: "goalsReached")) + " day"
            }
            else {
                numDailyGoalsReachedLabel.text = "Goals reached:   " + String(defaults.integer(forKey: "goalsReached")) + " days"
            }
        }
        percentageDailyGoalReachedLabel.text = "Percentage of goals reached   " + "\n" + String(Int(defaults.integer(forKey: "goalsReached")/daysSinceInstalled)*100) + "%"
        
        return transition
    }
    
    // Assists dismissal of BubbleTransition
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
      return interactiveTransition
    }

    // Bubble emitter
    func bubbleEmitter() {
        let emitter = BubbleEmitter.get(with: UIImage(named: "Bubble")!)
        emitter.emitterPosition = CGPoint(x: view.frame.width/2, y: view.frame.maxY)
        emitter.emitterSize = CGSize(width: view.frame.width, height: 2)
        view.layer.addSublayer(emitter)
    }
    
}

// MARK: EXTENSIONS

// Bypasses iOS 13's clear background restrictions
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
    
// Gets current page of UIScrollView
extension UIScrollView {
    var currentPage:Int{
        return Int((self.contentOffset.x+(0.5*self.frame.size.width))/self.frame.width)+1
    }
}

// String to date conversion
extension String {
func date(format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone.current
        let date = dateFormatter.date(from: self)
        return date
    }
}

// Sets line spacing for UILabels
extension UILabel {
    func setLineSpacing(lineSpacing: CGFloat = 0.0, lineHeightMultiple: CGFloat = 0.0) {
        guard let labelText = self.text else { return }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        let attributedString:NSMutableAttributedString
        if let labelattributedText = self.attributedText {
            attributedString = NSMutableAttributedString(attributedString: labelattributedText)
        } else {
            attributedString = NSMutableAttributedString(string: labelText)
        }
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        self.attributedText = attributedString
    }
}
