//
//  Service.swift
//  TimePresence
//
//  Created by Nour  on 5/6/19.
//  Copyright © 2019 Nour . All rights reserved.
//

import Foundation

struct  Service {
    var ID:Int64
    var title:String
    var url:String
    var date:Date
    var userCode:String
    
    mutating func save(){
        self.ID = DatabaseManagement.shared.addService(service: self)
    }
    
    var projects:[Task]{
        return DatabaseManagement.shared.queryServiceTasks(serviceId: self.ID)
    }
    
    var laps:[Lap]{
        return DatabaseManagement.shared.queryTaskLaps(taskId: self.ID)
    }
    
    var totalseconds:Int {
        var res:Int = 0
        for lap in self.laps{
            res += lap.seconds
        }
        return res
    }
    
    
    static func all() -> [Service]{
        return DatabaseManagement.shared.queryAllServices()
    }
    
    func delete(){
        for lap in laps{
            lap.delete()
        }
        DatabaseManagement.shared.deleteTask(Id: self.ID)
    }
    
}
