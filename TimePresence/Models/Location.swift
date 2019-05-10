//
//  Location.swift
//  Wardah
//
//  Created by Dania on 1/7/17.
//
//

import SwiftyJSON
import CoreLocation

class Location:BaseModel,CustomStringConvertible {
    // MARK: Properties
//    public var id:Int!
    public var googleID:String?
    public var name:String?
    public var city:String?
    public var photo:String?
    public var lat:Double?
    public var long:Double?
    public var latitiued:String?
    public var longtiued:String?
    public var flat:String?
    public var firstAddress:String?
    public var secondAddress:String?
    public var thirdAddress:String?
    public var comment:String?
    public var customerID:String?
    public var districtID:String?
    public var floor:String?
 
    
    public var addressName:String{
        if let value = name{
            return value
        }
        if let value = firstAddress{
            return value
        }
        
        return ""
    }
    
    //Keys for API TODO: read about keyPath in swift3
    private let kId = "id"
    private let kGoogleID = "google_place_id"
    private let kName = "name"
    private let kLat = "lat"
    private let kLong = "lng"
    private let kPhoto = "photo"
    private let kAddress = "address"
    private let kFlat = "flat"
    private let KDistrictId = "district"
    private let KthirdAddress = "third_address"
    private let KSecondAddress = "second_address"
    private let KComment = "comment"
    private let KFloor = "floor"
    private let KFirstAddress = "first_address"
    private let KCustomerId = "customer_id"
    
    public var distanceInKm : Double {
        let currentLocation = LocationHelper.shared.myLocation
        var coordinate0 : CLLocation?
        var coordinate1 : CLLocation?
        
        if let lattitude = lat, let longitude = long {
            coordinate0 = CLLocation(latitude: lattitude , longitude: longitude)
        }
        if let lat2 = currentLocation?.lat , let long2 = currentLocation?.long {
            coordinate1 = CLLocation(latitude: lat2, longitude: long2)
        }
        if let point0 = coordinate0 , let point1 = coordinate1 {
            let distanceInMeters = point0.distance(from: point1)
            return distanceInMeters / 1000
        }
        return 0
    }
    
    // MARK: Location initializer
    override init() {
        super.init()
        lat = 0
        long = 0
    }
    
    init(lat:Double,long:Double) {
        self.lat = lat
        self.long = long
        super.init()
    }
    
    
    public static func modelsFromJSONArray(array:[JSON]) -> [Location]
    {
        var models:[Location] = []
        for item in array
        {
            models.append(Location(json: item))
        }
        return models
    }
    
    // MARK: SwiftyJSON Initalizers
    /**
     Initates the instance based on the object
     - parameter object: The object of either Dictionary or Array kind that was passed.
     - returns: An initalized instance of the class.
     */
    public convenience init(object: Any) {
        self.init(json: JSON(object))
    }
    
    /**
     Initates the instance based on the JSON that was passed.
     - parameter json: JSON object from SwiftyJSON.
     - returns: An initalized instance of the class.
     */
    public required init(json: JSON) {
        super.init(json: json)
//        id = json[kId].int
        lat = json[kLat].double
        long = json[kLong].double
        latitiued = json[kLat].string
        longtiued = json[kLong].string
        flat = json[kFlat].string
        districtID = json[KDistrictId].string
        firstAddress = json[KFirstAddress].string
        customerID = json[KCustomerId].string
        thirdAddress = json[KthirdAddress].string
        secondAddress = json[KSecondAddress].string
        comment = json[KComment].string
        floor = json[KFloor].string
        name = json[kName].string
    }
    
    /**
     Generates description of the object in the form of a NSDictionary.
     - returns: A Key value pair containing all valid values in the object.
     */
    public override func dictionaryRepresentation() -> [String: Any] {
        var dictionary = super.dictionaryRepresentation()
//        if let value = id { dictionary[kId] = value }
        if let value = googleID { dictionary[kGoogleID] = value }
        if let value = name { dictionary[kName] = value }
        if let value = latitiued { dictionary[kLat] = value}
        if let value  = longtiued { dictionary[kLong] = value}
        if let value = lat { dictionary[kLat] = value}
        if let value  = long { dictionary[kLong] = value}
        if let value  = photo { dictionary[kPhoto] = value}
        if let value = city { dictionary[kAddress] = value}
        return dictionary
    }
    
    public func getAddressFromCordinates(onDone:@escaping (String?,String?)->Void) {
        guard let lat = self.lat , let long = self.long else {
            onDone(nil,nil)
            return
        }
        let location = CLLocation(latitude: lat, longitude: long)
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            print(location)
            
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                onDone(nil,nil)
                return
            }
            
            if let marks = placemarks, marks.count > 0 {
                let pm:CLPlacemark = marks[0]
                var title = ""
                var country = ""
                var city = ""
                var countryCode = ""
                if let val = pm.country , val.length > 0 {
                    country = val
                    if(title.length > 0) {
                        title = String(format: "%@, %@", title , val)
                    } else {
                        title = val
                    }
                }
                if let val = pm.locality , val.length > 0 {
                    city = val
                    if (title.length > 0) {
                        title = String(format: "%@, %@", title , val)
                    } else {
                        title = val
                    }
                }
                if let val = pm.isoCountryCode , val.length > 0 {
                    countryCode = val
                    if (title.length > 0) {
                        title = String(format: "%@, %@", title , val)
                    } else {
                        title = val
                    }
                }
                var address = ""
                if let val = pm.name , val.length > 0 {address = val}
                if let val = pm.thoroughfare , val.length > 0 {
                    if (address.length > 0) {
                        address = String(format: "%@, %@", address , val)
                    } else {
                        address = val
                    }
                }
                if let val = pm.subLocality , val.length > 0 {
                    if (address.length > 0) {
                        address = String(format: "%@, %@", address , val)
                    } else {
                        address = val
                    }
                }
                onDone(title, address)
                print("\(country) + \(city) + \(countryCode)")
            } else {
                print("Problem with the data received from geocoder")
                onDone(nil,nil)
            }
        })
    }
    
    
    var description: String{
        return "The Location Lat is \(self.lat) \n long is \(self.long)"
    }
    
}
