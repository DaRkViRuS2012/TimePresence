//
//  TimerViewController.swift
//  TaskManager
//
//  Created by Nour  on 6/3/18.
//  Copyright © 2018 NourAraar. All rights reserved.
//

import UIKit


enum TimerState:String{
    case work = "work"
    case pause = "break"
    case stoped = "stoped"
}

class TimerViewController: AbstractController {

    @IBOutlet weak var projectTitleLabel:UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var actionsView:UIView!
    @IBOutlet weak var stateLabel:UILabel!
    
    
    var seconds:Int = 0
    var timer:Timer = Timer()
    var currentBackgroundDate:Date?
    var isTimerRunning = false
    var resumeTapped = false
    var isRunningSession:Bool {
        return currentSession?.SessionKey != nil
    }
    
    var task:Task?
    var projects:[Task] = []
    var selectedProject:Task?{
        get{
            return DataStore.shared.currentProject
        }
        
        set{
            DataStore.shared.currentProject = newValue
        }
    }
    var projectsDropDown = DropDownViewController<Task>()
    var state:TimerState = .stoped{
        didSet{
            if state == .work{
                if !isRunningSession{
                    seconds = 0
                    sessionKey = UUID().uuidString
                    createNewSession(type:.work)
                }else{
                    if currentSession?.type != TimerState.work.rawValue{
                        endCurrnetSession()
                        seconds = 0
                        createNewSession(type:.work)
                    }
                }
                NotificationHelper.shared.cancelAll()
                NotificationHelper.shared.scheduleNotification(notificationType: "Work",timeInterval: Double(AppConfig.numberOfSeconds))
                self.projectTitleLabel.text = selectedProject?.name
                runTimer()
                stateLabel.text = state.rawValue
                self.saveButton.isEnabled = true
                self.actionsView.isHidden = false
                self.startButton.isEnabled = false
                self.pauseButton.isEnabled = true
                self.pauseButton.setTitle("Pause",for: .normal)
            }
            if state == .pause{
                if !isRunningSession{
                    seconds = 0
                    sessionKey = UUID().uuidString
                    createNewSession(type:.pause)
                }else{
                    if currentSession?.type != TimerState.pause.rawValue{
                        endCurrnetSession()
                        seconds = 0
                        createNewSession(type:.pause)
                    }
                }
                
                NotificationHelper.shared.cancelAll()
                NotificationHelper.shared.scheduleNotification(notificationType: "Break",timeInterval: Double(AppConfig.numberOfSeconds))
                self.projectTitleLabel.text = selectedProject?.name
                self.saveButton.isEnabled = true
                self.actionsView.isHidden = false
                self.startButton.isEnabled = false
                self.pauseButton.isEnabled = true
                stateLabel.text = state.rawValue
                runTimer()
                self.pauseButton.setTitle("Resume",for: .normal)
            }
            
            if state == .stoped{
                NotificationHelper.shared.cancelAll()
                endCurrnetSession()
                startState()
                self.timer.invalidate()
                seconds = 0
                self.timeLabel.text = DateHelper.timeString(time: TimeInterval(self.seconds))
                self.isTimerRunning = false
                self.pauseButton.isEnabled = false
                stateLabel.text = nil
                currentSession = nil
                selectedProject = nil
            }
        }
    }
    
    
    
    var currentSession:Lap?{
        get{
            return DataStore.shared.currentSession
        }
        
        set{
            DataStore.shared.currentSession = newValue
        }
    }
    
    var sessionKey:String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.actionsView.isHidden = true
        getCompanyProjects()
        projectsDropDown.buttonAnchor = self.startButton
        projectsDropDown.delegate = self
        projectsDropDown.tag = "projects"
        projectsDropDown.loadData = getCompanyProjects
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchProjectListFormAPI()
        startApp()
        ActionSyncLocations.execute()
    }

    func getCompanyProjects(){
        guard let company = DataStore.shared.currentCompany else {return}
        projects = company.projects
        projectsDropDown.list = projects.map{$0.name ?? ""}
    }
    
    func fetchProjectListFormAPI(){
        guard let user = DataStore.shared.me?.username , let pass = DataStore.shared.me?.password , let db = DataStore.shared.currentCompany?.DB else {return}
        ApiManager.shared.getProjectList(companyDB: db, username: user, password: pass) { (success, error, resutl) in
            if success{
                self.projects = resutl
                DataStore.shared.currentCompany?.projects = resutl
                self.getCompanyProjects()
            }
            
            if error != nil{
                
            }
        }
        
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
    }
    
    @objc func pauseApp(){
        self.currentBackgroundDate = Date()
    }
    
    @objc func startApp(){
        if let date = self.currentSession?.startTime{
        let difference = date.timeIntervalSince(Date())
        state = TimerState(rawValue: currentSession?.type ?? "work") ?? .work
        seconds = abs(Int(difference))
        self.sessionKey = self.currentSession?.SessionKey
        }
    }
    
    override func backButtonAction(_ sender: AnyObject) {
       // self.pauseResume(self.pauseButton)
        
        let alert = UIAlertController(title: "Close..??", message: "your timer won't be saved", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default) { (actio) in
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
    
    
    func start(){
        if isTimerRunning == false {
            state = .work
        }
       
    }
    
    func createNewSession(type:TimerState){
        guard let url = DataStore.shared.currentURL?.url ,
            let companyDb = DataStore.shared.currentCompany?.DB,
            let taskId = selectedProject?.ID,
            let projectId = selectedProject?.projectId,
            let ip = WifiHelper.getIP(),
            let mac = WifiHelper.getDeviceID(),
            let sessionKey = self.sessionKey else{return}
        
        let location = DataStore.shared.myLocation ?? Location()
        let newSession = Lap()
        newSession.url = url
        newSession.company = companyDb
        newSession.projectID = projectId
        newSession.SessionKey = sessionKey
        newSession.startTime = Date()
        newSession.type = type.rawValue
        newSession.userIP = ip
        newSession.lat = location.latitiued ?? ""
        newSession.long = location.longtiued ?? ""
        newSession.userLocation = location
        newSession.clientType = "ios"
        newSession.mac = mac
        newSession.taskID = taskId
        newSession.save()
        currentSession = newSession
    }
    
    func endCurrnetSession(){
        if let newSession = currentSession{
            newSession.endTime = Date()
            newSession.seconds = seconds
            newSession.save()
        }
        currentSession = nil
        
    }
    
    func runTimer() {
        if isTimerRunning == false {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
        isTimerRunning = true
        addObserve()
        }
    }
    
    @IBAction func pauseResume(_ sender: UIButton) {
        if state == .work{
            state = .pause
        } else {
            state = .work
        }
    }
    
    @IBAction func reset(_ sender: UIButton) {
        state = .stoped
        removeObserve()
    }
    

    
    @objc func updateTimer() {
            seconds += 1
            timeLabel.text = DateHelper.timeString(time: TimeInterval(seconds))
    }
    
    @IBAction func save(_ sender: UIButton) {

        
        let alert = UIAlertController(style: .alert, title: "End Your Session", message: "Sure ?")
    
        let cancelAction = UIAlertAction(title: "No", style: .cancel) { (_) in
            
        }
        alert.addAction(cancelAction)
        
        alert.addAction(title: "Yes", style: .default) { (action) in
//            if let title = alert.textFields?.first?.text{
//
//
//            }
               self.showMessage(message: "Done", type: .success)
            self.state = .stoped
        }
        self.present(alert, animated: true, completion: nil)
    }
}

extension TimerViewController:DropDownDelegete{
    func didClearData() {
        
    }
    
    func didSelectetItem<T>(tag:String,dropDown: DropDownViewController<T>, model: T?, index: Int) where T : BaseModel {
        self.projectTitleLabel.text = self.projects[index].name
        selectedProject = self.projects[index]
        start()
    }
}
