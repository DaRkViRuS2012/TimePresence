//
//  Task.swift
//  TaskManager
//
//  Created by Nour  on 6/3/18.
//  Copyright © 2018 NourAraar. All rights reserved.
//

import Foundation
import SwiftyJSON

class Task:BaseModel {
    
    var ID:Int64?
    var name:String?
    var projectId:String?
    var userCode:String?
    var serviceId:Int64?
    var companyId:Int64?
    
    init(ID:Int64?,name:String?,projectId:String?,companyId:Int64?) {
        self.ID = ID
        self.name = name
        self.companyId = companyId
        self.projectId = projectId
        super.init()
        self.modelTitle = name
    }
    
    override init() {
        super.init()
    }
    required init(json: JSON) {
        super.init(json: json)
        self.ID = json["ID"].int64
        self.name = json["Name"].string
        self.projectId = json["ProjectId"].string
        
    }
    
    override func dictionaryRepresentation() -> [String : Any] {
        var dictionary = super.dictionaryRepresentation()
        dictionary["ID"] = self.ID
        dictionary["ProjectId"] = projectId
        dictionary["Name"] = name

        return dictionary
    }
     func save(){
      self.ID = DatabaseManagement.shared.addTask(task: self)
    }
    
    var laps:[Lap]{
        return DatabaseManagement.shared.queryTaskLaps(taskId: self.ID!)
    }
    
    var totalseconds:Int {
        var res:Int = 0
        for lap in self.laps{
            res += lap.seconds
        }
        return res
    }
    
    
    static func all() -> [Task]{
        return DatabaseManagement.shared.queryAllTasks()
    }
    
     func delete(){
        for lap in laps{
            lap.delete()
        }
        _ = DatabaseManagement.shared.deleteTask(Id: self.ID!)
    }
    
    override var description: String{
        return "\(id) \(name) \(projectId)"
    }
}



public class Param:BaseModel {
    
    var interval:Int?
 
    override init() {
        super.init()
    }
    required init(json: JSON) {
        super.init(json: json)
        self.interval = json["Interval"].int
    }
    
    override public func dictionaryRepresentation() -> [String : Any] {
        var dictionary = super.dictionaryRepresentation()
        dictionary["Interval"] = self.interval
        return dictionary
    }
}
