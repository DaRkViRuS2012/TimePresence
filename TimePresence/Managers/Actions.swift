//
//  Actions.swift
//  Wardah
//
//  Created by Dania on 7/5/17.
//  Copyright © 2017 BrainSocket. All rights reserved.
//

import Foundation
import UIKit
/**
 Repeated and generic actions to be excuted from any context of the app such as show alert
 */
class Action: NSObject {
    class func execute() {
    }
    class func execute(_ show:Bool) {
    }
    
    
}

class ActionLogout:Action
{
    override class func execute() {
        let cancelButton = UIAlertAction(title: "No".localized, style: .cancel, handler: nil)
        let okButton = UIAlertAction(title: "Yes".localized, style: .default, handler: {
            (action) in
            //clear user
            DataStore.shared.logout()
            ActionShowStart.execute()
        })
        
        
        let alert = UIAlertController(title: "Log out".localized, message: "Are you sure?".localized, preferredStyle: .alert)
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        if let controller = UIApplication.visibleViewController()
        {
            controller.present(alert, animated: true, completion: nil)
        }
    }
    
}



class ActionSyncLaps: Action{
    override class func execute(_ show:Bool) {
        guard let url = DataStore.shared.currentURL?.url,
            let company = DataStore.shared.currentCompany?.DB,
            let username = DataStore.shared.me?.username,
            let password = DataStore.shared.me?.password
            else {return}
        var hasError = false
        let laps = DatabaseManagement.shared.queryUnSyncedLaps(url: url, companyDB: company)
        let chuncks = laps.chunk(size: AppConfig.numberOfRecodrds)
        for chunk in chuncks{
            (UIApplication.visibleViewController() as! AbstractController).showActivityLoader(show)
            ApiManager.shared.syncLogs(companyDB: company, username: username, password: password, logs: chunk) { (success, error, results) in
                
                (UIApplication.visibleViewController() as! AbstractController).showActivityLoader(false)
                if success{
                    
                    DataStore.shared.syncTime = DateHelper.getISOStringFromDate(Date())
                    var i = 0
                    for res in results{
                        if let err = res.error,!err{
                            chunk[i].synced = true
                            chunk[i].save(value: "sync")
                        }else{
                            hasError = true
                        }
                        i += 1
                    }
                    if hasError{
                        (UIApplication.visibleViewController() as! AbstractController).showMessage(message: "There is some errors in the sync process please contact the admin", type: .error)
                    }else{
                        if show{
                            (UIApplication.visibleViewController() as! AbstractController).showMessage(message: "Synced Successfully", type: .success)
                        }
                    }
                }
            }
        }
    }
    
}


class ActionSyncLocations: Action{
    override class func execute() {
        guard let company = DataStore.shared.currentCompany?.DB,
            let username = DataStore.shared.me?.username,
            let password = DataStore.shared.me?.password
            else {return}
        
        let laps = DataStore.shared.locations
//            (UIApplication.visibleViewController() as! AbstractController).showActivityLoader(true)
            ApiManager.shared.syncLocations(companyDB: company, username: username, password: password,locations: laps) { (success, error,results) in
//                (UIApplication.visibleViewController() as! AbstractController).showActivityLoader(false)
                if success{
//                    DataStore.shared.syncTime = DateHelper.getISOStringFromDate(Date())
                    var i = 0
                    for res in results{
                        if let err = res.error,!err{
                            DataStore.shared.locations[i].synced = true
                        }
                        i += 1
                    }
                     DataStore.shared.locations = DataStore.shared.locations.filter({$0.synced == false})
                    
                }
            }
        
    }
    
}


class ActionShowStart: Action {
    override class func execute() {
        UIApplication.appWindow().rootViewController = UIStoryboard.startStoryboard.instantiateViewController(withIdentifier: StartViewController.className)
    }
}
