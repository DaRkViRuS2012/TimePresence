//
//  TimerViewController.swift
//  TaskManager
//
//  Created by Nour  on 6/3/18.
//  Copyright © 2018 NourAraar. All rights reserved.
//

import UIKit


enum TimerState{
    case work
    case pause
    case end
    case stoped
}

class TimerViewController: AbstractController {

    @IBOutlet weak var projectTitleLabel:UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
  //  @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var actionsView:UIView!
    @IBOutlet weak var stateLabel:UILabel!
    
    
    var seconds:Int = 0
    var timer:Timer = Timer()
    var currentBackgroundDate:Date?
    var isTimerRunning = false
    var resumeTapped = false
    
    var task:Task?
    var projects = ["Project 1","Project 2","project 3","Nour"]
    var projectsDropDown = DropDownViewController<Task>()
    var state:TimerState = .stoped
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.actionsView.isHidden = true
//        self.resetButton.isEnabled = false
//        self.saveButton.isEnabled = false
        
        projectsDropDown.buttonAnchor = self.startButton
        projectsDropDown.delegate = self
        projectsDropDown.list = projects
    }
    
    
    override func customizeView() {
        super.customizeView()
        self.startButton.setBackgroundColor(color: AppColors.green, forState: .normal)
        self.startButton.setBackgroundColor(color: AppColors.gray, forState: .disabled)
        
    }
    
    
    func addObserve(){
        NotificationCenter.default.addObserver(self, selector: #selector(pauseApp), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startApp), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    func removeObserve(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    
    
    func startState(){
        self.startButton.isEnabled = true
        self.actionsView.isHidden = true
        self.pauseButton.setTitle("Pause", for: .normal)
        seconds = 0
        projectTitleLabel.text = nil
        stateLabel.text = nil
        
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
       
    }
    
    
    func start(){
        if isTimerRunning == false {
            runTimer()
            stateLabel.text = "Working"
            self.startButton.isEnabled = false
            self.pauseButton.isEnabled = true
            state = .work
        }
    }
    
    func runTimer() {
        if isTimerRunning == false {
        self.saveButton.isEnabled = true
        self.actionsView.isHidden = false
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
        isTimerRunning = true
        addObserve()
        }
    }
    
    @IBAction func pauseResume(_ sender: UIButton) {
        if state == .work{
            self.timer.invalidate()
            self.timeLabel.text = DateHelper.timeString(time: TimeInterval(self.seconds))
            self.isTimerRunning = false
//            self.pauseButton.isEnabled = false
            stateLabel.text = "Paused"
            state = .pause
            removeObserve()
            self.pauseButton.setTitle("Resume",for: .normal)
        } else {
            runTimer()
            self.resumeTapped = false
            isTimerRunning = true
            state = .work
            stateLabel.text = "Working"
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
        self.pauseButton.isEnabled = false
        stateLabel.text = "Paused"
//        self.startButton.isEnabled = true
    }
    
    
    
    @objc func updateTimer() {
            seconds += 1
            timeLabel.text = DateHelper.timeString(time: TimeInterval(seconds))
    }
    
    @IBAction func save(_ sender: UIButton) {
        if isTimerRunning{
            stop()
        }
        
        let alert = UIAlertController(style: .alert, title: "Save", message: "Enter Note")
        
        alert.addTextField { (textFiled) in
            textFiled.placeholder = "Note"
            textFiled.autocapitalizationType = .none
            textFiled.autocorrectionType = .no
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            
        }
        alert.addAction(cancelAction)
        
        alert.addAction(title: "OK", style: .default) { (action) in
            if let title = alert.textFields?.first?.text{
//                var newLap  = Lap(ID: -1, taskID: self.task?.ID, seconds: self.seconds, date: Date(),title:title)
//
//                newLap.save()
                self.showMessage(message: "Done", type: .success)
//                self.popOrDismissViewControllerAnimated(animated: true)
                self.startState()
                self.state = .end
//
            }
        }
        self.present(alert, animated: true, completion: nil)
    }
}

extension TimerViewController:DropDownDelegete{
    func didClearData() {
        
    }
    
    func didSelectetItem<T>(dropDown: DropDownViewController<T>, model: T?, index: Int) where T : BaseModel {
        self.projectTitleLabel.text = self.projects[index]
        start()
    }
}
