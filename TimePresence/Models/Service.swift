//
//  Service.swift
//  TimePresence
//
//  Created by Nour  on 5/6/19.
//  Copyright © 2019 Nour . All rights reserved.
//

import Foundation
import SwiftyJSON
class  Service:BaseModel {
    var ID:Int64?
    var title:String?
    var url:String?
    var date:Date?
    var userCode:String?
    
    
    override init() {
        super.init()
    }
    
    init(ID:Int64?,title:String?,url:String?,date:Date?,userCode:String?) {
        self.ID = ID
        self.title = title
        self.url = url
        self.date = date
        self.userCode = userCode
        super.init()
        self.modelTitle = self.title
    }
    
    public required init(json: JSON) {
        super.init(json: json)
        ID = json["ID"].int64
        title = json["title"].string
        url = json["url"].string
        if let value = json["date"].string{
            date = DateHelper.getDateFromString(value)
        }
        userCode = json["userCode"].string
        self.modelTitle = title
    }
    override func dictionaryRepresentation() -> [String : Any] {
        var dictionary = super.dictionaryRepresentation()
        dictionary["ID"] = ID
        dictionary["title"] = title
        dictionary["url"] = url
        if let value = date{
            dictionary["date"] = DateHelper.getStringFromDate(value)
        }
        dictionary["userCode"] = userCode
        
        return dictionary
    }
    
    func save(){
        self.ID = DatabaseManagement.shared.addService(service: self)
    }
    
    var projects:[Task]{
        return DatabaseManagement.shared.queryServiceTasks(serviceId: self.ID!)
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
    
    
    static func all() -> [Service]{
        return DatabaseManagement.shared.queryAllServices()
    }
    
    func delete(){
        for lap in laps{
            lap.delete()
        }
        DatabaseManagement.shared.deleteTask(Id: self.ID!)
    }
    
}
