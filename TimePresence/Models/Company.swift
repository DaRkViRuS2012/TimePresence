//
//  Company.swift
//  TimePresence
//
//  Created by Nour  on 5/18/19.
//  Copyright © 2019 Nour . All rights reserved.
//

import Foundation
import SwiftyJSON

class Company:BaseModel{
    
    
    var ID:Int64?
    var title:String?
    var DB:String?
    var urlId:Int64?
    
    override init() {
        super.init()
    }
    
    init(ID:Int64?,title:String?,DB:String?,urlId:Int64?) {
        self.ID = ID
        self.title = title
        self.urlId = urlId
        self.DB = DB
        super.init()
        self.modelTitle = self.title
    }
    
    public required init(json: JSON) {
        super.init(json: json)
        ID = json["ID"].int64
        title = json["CompanyName"].string
        urlId = json["urlId"].int64
        DB = json["CompanyDB"].string
        self.modelTitle = title
    }
    
    override func dictionaryRepresentation() -> [String : Any] {
        var dictionary = super.dictionaryRepresentation()
        dictionary["ID"] = ID
        dictionary["CompanyName"] = title
        dictionary["urlId"] = urlId
        dictionary["CompanyDB"] = DB
        return dictionary
    }
    
    func save(){
        if ID == nil{
            self.ID = DatabaseManagement.shared.addCompany(company: self)
        }
    }
    
    var projects:[Task]{
        get{
            guard let id = self.ID else {return []}
            return DatabaseManagement.shared.queryCompanyProjects(companyId: id)
        }
        set{
            guard let id = self.ID else {return}
            for project in newValue{
                if project.companyId == nil{
                    project.companyId = id
                    project.save()
                }
            }
        }
    }
    
    var laps:[Lap]{
        guard let id = self.ID else {return []}
        return DatabaseManagement.shared.queryTaskLaps(taskId: id)
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
        _ = DatabaseManagement.shared.deleteTask(Id: self.ID!)
    }

    
}
