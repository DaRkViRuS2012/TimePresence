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
    
    var urlDropDown = DropDownViewController<Service>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        urlDropDown.buttonAnchor = urlButton
        urlDropDown.loadData = getServices
        urlDropDown.delegate = self
        if let url = DataStore.shared.currentURL{
            self.urlLable.text = url.title
        }
    }
    
    func getServices(){
        let services = DatabaseManagement.shared.queryAllServices()
        urlDropDown.modelList = services
    }

}

extension SettingsViewController:DropDownDelegete{
    func didSelectetItem<T>(dropDown: DropDownViewController<T>, model: T?, index: Int) where T : BaseModel {
        if let url = model as? Service{
            DataStore.shared.currentURL = url
            self.urlLable.text = url.title
        }
    }
    
    func didClearData() {
        
    }
    
    
}
