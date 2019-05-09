//
//  User.swift
//  Wardah
//
//  Created by Dania on 6/12/17.
//  Copyright © 2017 BrainSocket. All rights reserved.
//

import SwiftyJSON



class AppUser: BaseModel {
    // MARK: Keys
    private let kUserFirstNameKey = "first_name"
    private let kUserLastNameKey = "last_name"
    private let kUserEmailKey = "email"
    private let kUserNameKey = "username"
    private let kUserPasswordKey = "password"
    private let kUserCodeKey = "code"
    private let kUserIdKey = "id"
    
    
    // MARK: Properties
    public var firstName: String?
    public var lastName: String?
    public var email: String?
    public var username: String?
    public var UId:Int64?
    public var code: String?
    public var password:String?
    
    
    // user full name
    public var fullName: String {
        if let fName = firstName, !fName.isEmpty {
            if let lName = lastName, !lName.isEmpty {
                return  fName + " " + lName
            }
            return fName
        }
        return lastName ?? ""
    }
    
    // MARK: User initializer
    public override init(){
        super.init()
    }
    
    public init(uid:Int64?,username:String?,pwd:String?,code:String?) {
        super.init()
        self.UId = uid
        self.username = username
        self.password = pwd
        self.code = code
    }
    
    public required init(json: JSON) {
        super.init(json: json)
        if let value = json[kUserIdKey].int64{
            UId = value
        }
        firstName = json[kUserFirstNameKey].string
        lastName = json[kUserLastNameKey].string
        email = json[kUserEmailKey].string
        username = json[kUserNameKey].string
        code = json[kUserCodeKey].string
        password = json[kUserPasswordKey].string

    }
    
    public override func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = super.dictionaryRepresentation()
        if let value = UId{
            dictionary[kUserIdKey] = value
        }
        // first name
        if let value = firstName {
            dictionary[kUserFirstNameKey] = value
        }
        // last name
        if let value = lastName {
            dictionary[kUserLastNameKey] = value
        }
        // email
        if let value = email {
            dictionary[kUserEmailKey] = value
        }

        if let value = password {
            dictionary[kUserPasswordKey] = value
        }
        
        if let value = username{
            dictionary[kUserNameKey] = value
        }
       
        return dictionary
    }
    
}
