//
//  TimerViewController.swift
//  TaskManager
//
//  Created by Nour  on 6/3/18.
//  Copyright © 2018 NourAraar. All rights reserved.
//

import UIKit

class TimerViewController: AbstractController {

    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    var seconds:Int = 0
    var timer:Timer = Timer()
    var currentBackgroundDate:Date?
    var isTimerRunning = false
    var resumeTapped = false
    
    var task:Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showNavBackButton = true
//        self.pauseButton.isEnabled = false
        //self.setNavBarTitle(title: (task?.title)!)
        self.resetButton.isEnabled = false
        self.saveButton.isEnabled = false
    }
    
    func addObserve(){
        NotificationCenter.default.addObserver(self, selector: #selector(pauseApp), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startApp), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    func removeObserve(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    
    
    
    @objc func pauseApp(){
        self.stop() //invalidate timer
        self.currentBackgroundDate = Date()
    }
    
    @objc func startApp(){
        if let date = self.currentBackgroundDate{
        let difference = date.timeIntervalSince(Date())
        seconds += abs(Int(difference))
        self.runTimer() //start timer
        self.currentBackgroundDate = nil
        }
    }
    
    override func backButtonAction(_ sender: AnyObject) {
       // self.pauseResume(self.pauseButton)
        
        let alert = UIAlertController(title: "Close..??", message: "your timer won't be saved", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default) { (actio) in
            self.stop()
            self.removeObserve()
            self.popOrDismissViewControllerAnimated(animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.pauseResume(self.pauseButton)
        }
        
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    

    @IBAction func startTimer(_ sender: UIButton) {
        if isTimerRunning == false {
            runTimer()
            self.startButton.isEnabled = false
            self.resetButton.isEnabled = true
        }
    }
    
    
    func runTimer() {
        if isTimerRunning == false {
        self.saveButton.isEnabled = true
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
        isTimerRunning = true
        addObserve()
        }
    }
    
    @IBAction func pauseResume(_ sender: UIButton) {
        if self.resumeTapped == false {
            timer.invalidate()
            isTimerRunning = false
            self.resumeTapped = true
            self.pauseButton.setTitle("Resume",for: .normal)
        } else {
            runTimer()
            self.resumeTapped = false
            isTimerRunning = true
            self.pauseButton.setTitle("Pause",for: .normal)
        }
    }
    
    @IBAction func reset(_ sender: UIButton) {
        self.stop()
        removeObserve()
    }
    
    func stop(){
        self.timer.invalidate()
        self.timeLabel.text = DateHelper.timeString(time: TimeInterval(self.seconds))
        self.isTimerRunning = false
        self.resetButton.isEnabled = false
        self.startButton.isEnabled = true
    }
    
    
    
    @objc func updateTimer() {
            seconds += 1
            timeLabel.text = DateHelper.timeString(time: TimeInterval(seconds))
    }
    
    @IBAction func save(_ sender: UIButton) {
        if isTimerRunning{
            stop()
        }
        
        let alert = UIAlertController(style: .alert, title: "Save", message: "Enter Tilte")
        
   
        
        alert.addTextField { (textFiled) in
            textFiled.placeholder = "Title"
            textFiled.autocapitalizationType = .none
            textFiled.autocorrectionType = .no
        }
        alert.addAction(title:"Cancel" , style:.cancel)
        
        alert.addAction(title: "OK", style: .default) { (action) in
            if let title = alert.textFields?.first?.text{
                var newLap  = Lap(ID: -1, taskID: self.task?.ID, seconds: self.seconds, date: Date(),title:title)
                newLap.save()
                self.showMessage(message: "Done", type: .success)
                self.popOrDismissViewControllerAnimated(animated: true)
                
            }

        }
        alert.show()
        

        
    }
}
