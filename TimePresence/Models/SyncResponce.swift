//
//  SyncResponse.swift
//  TimePresence
//
//  Created by Nour  on 5/28/19.
//  Copyright © 2019 Nour . All rights reserved.
//

import Foundation
import SwiftyJSON

public class SyncResponce:BaseModel{

    public var error:Bool?
    public var message:String?
    
    public required init(json: JSON) {
        super.init(json: json)
        error = json["error"].bool
        message = json["message"].string
    
    }
    
    override public func dictionaryRepresentation() -> [String:Any] {
        let dictionary = super.dictionaryRepresentation()
        return dictionary
    }
    
}
