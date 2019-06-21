//
//  Lap.swift
//  TimePresence
//
//  Created by Nour  on 5/25/19.
//  Copyright © 2019 Nour . All rights reserved.
//

import Foundation
import SwiftyJSON

class Lap:BaseModel{
    
    var ID:Int64?
    var SessionKey:String?
    var url:String?
    var company:String?
    var taskID:Int64?
    var projectID:String?
    var startTime:Date?
    var endTime:Date?
    var seconds:Int = 0
    var mac:String?
    var clientType:String?
    var lat:String?
    var long:String?
    var userIP:String?
    var type:String?
    var synced:Bool?
    var approved:Bool?
    var userLocation:Location?
    
    override init() {
        super.init()
    }
    
    init(ID:Int64?,SessionKey:String?,url:String?,company:String?
        ,taskID:Int64?,projectID:String?,startTime:Date?,endTime:Date?
        ,seconds:Int,mac:String?,clientType:String?,lat:String?,long:String?
        ,userIP:String?,type:String?,synced:Bool?,approved:Bool?) {
        self.ID = ID
        self.SessionKey = SessionKey
        self.url = url
        self.company = company
        self.taskID = taskID
        self.projectID = projectID
        self.startTime = startTime
        self.endTime = endTime
        self.seconds = seconds
        self.mac = mac
        self.clientType = clientType
        self.lat = lat
        self.long = long
        self.userIP = userIP
        self.type = type
        self.synced = synced
        self.approved = approved
        if let l = lat,let lt = Double(l) ,let lng = long , let lg = Double(lng){
            let location = Location(lat: lt, long: lg)
            userLocation = location
        }
        super.init()
    }
    
    required init(json: JSON) {
        super.init(json: json)
        ID = json["ID"].int64
        SessionKey = json["sessionKey"].string
        url = json["url"].string
        company = json["companyDB"].string
        taskID = json["taskID"].int64
        projectID = json["projectId"].string
        if let time = json["startTime"].string{
            startTime = DateHelper.getDateFromISOString(time)
        }
        if let time = json["endTime"].string{
            endTime = DateHelper.getDateFromISOString(time)
        }
        seconds = json["totalMinutes"].int ?? 0
        mac = json["macId"].string
        clientType = json["clientType"].string
        long = json["longitude"].string
        lat = json["latitudes"].string
        if json["userLocation"] != JSON.null{
            userLocation = Location(json: json["userLocation"])
            if userLocation?.latitiued != nil{
                lat = userLocation?.latitiued
            }
            if userLocation?.longtiued != nil{
                long = userLocation?.longtiued
            }
        }
        userIP = json["userIP"].string
        type = json["workType"].string
        if let value = json["syncStatus"].string{
            synced = value == "1"
        }
        if let value = json["approved"].string{
            approved = value == "1"
        }
        
    }
    
    override func dictionaryRepresentation() -> [String : Any] {
        var dictionary = super.dictionaryRepresentation()
        if let value = ID {
            dictionary["ID"] = value
        }
        if let value = SessionKey{
            dictionary["sessionKey"] = value
        }
        if let value = url{
            dictionary["url"] = value
        }
        if let value = company{
            dictionary["companyDB"] = value
        }
        if let value = taskID{
            dictionary["taskID"] = value
        }
        if let value = projectID{
            dictionary["projectId"] = value
        }
        if let time = startTime,let  date = DateHelper.getISOStringFromDate(time){
            dictionary["startTime"] = date
        }
        if let time = endTime,let  date = DateHelper.getISOStringFromDate(time){
            dictionary["endTime"] = date
        }
        
        dictionary["totalMinutes"] = seconds
        
        if let value = mac{
            dictionary["macId"] = value
        }
        if let value = clientType{
            dictionary["clientType"] = value
        }
        if let value = long {
            dictionary["longitude"] = value
        }
        if let value = lat{
            dictionary["latitudes"] = value
        }
        if let value = userIP{
            dictionary["userIP"] = value
        }
        if let value = type{
            dictionary["workType"] = value
        }
        if let value = synced {
            dictionary["syncStatus"] = value ? "1" : "0"
        }
        
        if let value = userLocation{
            dictionary["userLocation"] = value.dictionaryRepresentation()
        }
        
        if let value = approved {
            dictionary["approved"] = value ? "1" : "0"
        }
        return dictionary
    }
    
    var task:Task? {
        return DatabaseManagement.shared.queryTaskById(id: self.taskID!)
    }
    
    
    func save(value:String){
        print(value)
        print(self)
        if self.ID == nil{
            self.ID = DatabaseManagement.shared.addLap(lap: self)
        }else{
            _ = DatabaseManagement.shared.updateLap(id: self.ID!, lap: self)
        }
    }
    
    
    func delete(){
        _ = DatabaseManagement.shared.deleteLap(Id: self.ID!)
    }
    
    
    
    override var description: String{
        return "\(SessionKey) \(url) \(company) Synced = \(synced) start=\(startTime) end=\(endTime) type=\(type) lat=\(lat) long= \(long) userloction lat=\(userLocation?.latitiued) long= \(userLocation?.longtiued)"
    }
}
