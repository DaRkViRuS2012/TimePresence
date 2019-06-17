//
//  APIResult.swift
//  TimePresence
//
//  Created by Nour  on 5/18/19.
//  Copyright © 2019 Nour . All rights reserved.
//

import Foundation
import SwiftyJSON
/* For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar */

public class APIResult<T:BaseModel>:BaseModel{
    public var has_Error : Bool?
    public var error_Message : String?
    public var data : Array<T>?
    public var error:Bool?
    public var message:String?
    public var param:Param?

    public required init(json: JSON) {
        super.init(json: json)
        has_Error = json["Error"].bool
        error_Message = json["Data"].string
        if let array = json["Data"].array{
            data =  array.map{T(json:$0)}
        }
        if json["Params"] != JSON.null{
            param = Param(json:json["Params"])
        }
    }

    override public func dictionaryRepresentation() -> [String:Any] {
        let dictionary = super.dictionaryRepresentation()
        return dictionary
    }
    
}



