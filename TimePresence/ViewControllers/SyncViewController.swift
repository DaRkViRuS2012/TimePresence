//
//  SyncViewController.swift
//  TimePresence
//
//  Created by Nour  on 5/25/19.
//  Copyright © 2019 Nour . All rights reserved.
//

import UIKit

class SyncViewController: AbstractController {

    @IBOutlet weak var nubmerOfRecordsLabel: UILabel!
    @IBOutlet weak var numberOfRecordsButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    var recordsDropDown = DropDownViewController<BaseModel>()
    var records = [10,50,100]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        recordsDropDown.tag = "records"
        recordsDropDown.buttonAnchor = numberOfRecordsButton
        recordsDropDown.delegate = self
        recordsDropDown.list = records.map{"\($0)"}
        let rec = AppConfig.numberOfRecodrds
        nubmerOfRecordsLabel.text =  "\(rec)"
        timeLabel.text = DataStore.shared.syncTime
    }
    
    
    @IBAction func sync(){

        ActionSyncLaps.execute()
        ActionSyncLocations.execute()
      self.timeLabel.text = DateHelper.getISOStringFromDate(Date())
    }
    
}


extension SyncViewController:DropDownDelegete{
    func didSelectetItem<T>(tag: String, dropDown: DropDownViewController<T>, model: T?, index: Int) where T : BaseModel {
        if tag == "records"{
            let rec = records[index]
            nubmerOfRecordsLabel.text = "\(rec)"
            AppConfig.numberOfRecodrds = rec
        }
    }
    
    func didClearData() {
        
    }
    
    
}
