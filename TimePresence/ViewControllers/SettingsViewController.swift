//
//  SettingsViewController.swift
//  TimePresence
//
//  Created by Nour  on 5/10/19.
//  Copyright © 2019 Nour . All rights reserved.
//

import UIKit

class SettingsViewController: AbstractController {

    @IBOutlet weak var userLabel:UILabel!
    @IBOutlet weak var urlLable:UILabel!
    @IBOutlet weak var urlButton:UIButton!
    @IBOutlet weak var reminderLabel: UILabel!
    @IBOutlet weak var reminderButton: UIButton!
    
    var urlDropDown = DropDownViewController<Service>()
    var reminderDropDown = DropDownViewController<BaseModel>()
    
    var times = [36000 , 54000 , 108000]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        urlDropDown.tag = "service"
        reminderDropDown.tag = "time"
        reminderDropDown.buttonAnchor = reminderButton
        reminderDropDown.list = times.map({
            let t = $0 / 3600
            return "\(t) min"
        })
        reminderDropDown.delegate = self
        urlDropDown.buttonAnchor = urlButton
        urlDropDown.loadData = getServices
        urlDropDown.delegate = self
        if let name = DataStore.shared.me?.username {
            userLabel.text = name
        }
        if let url = DataStore.shared.currentURL{
            self.urlLable.text = url.title
        }
        let time = AppConfig.numberOfSeconds / 3600
        reminderLabel.text = "\(time) min"
        
    }
    
    func getServices(){
        let services = DatabaseManagement.shared.queryAllServices()
        urlDropDown.modelList = services
    }
    
    @IBAction func logout(_ sender : UIButton){
        ActionLogout.execute()
    }

}

extension SettingsViewController:DropDownDelegete{
    func didSelectetItem<T>(tag:String,dropDown: DropDownViewController<T>, model: T?, index: Int) where T : BaseModel {
        if tag == "service"{
        if let url = model as? Service{
            DataStore.shared.currentURL = url
            self.urlLable.text = url.title
            }
        }
        
        if tag == "time"{
            AppConfig.numberOfSeconds = times[index]
            let t = times[index] / 3600
            reminderLabel.text = "\(t) min"
        }
    }
    
    func didClearData() {
        
    }
    
    
}
