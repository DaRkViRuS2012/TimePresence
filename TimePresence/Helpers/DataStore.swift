//
//  DataStore.swift
//  
//
//  Created by AlphaApps on 14/11/16.
//  Copyright © 2016 BrainSocket. All rights reserved.
//

import SwiftyJSON

/**This class handle all data needed by view controllers and other app classes
 
 It deals with:
 - Userdefault for read/write cached data
 - Any other data sources e.g social provider, contacts manager, etc..
 **Usag:**
 - to write something to chach add constant key and a computed property accessors (set,get) and use the according method  (save,load)
 */
class DataStore :NSObject {
    
    //MARK: Cache keys
    private let CACHE_KEY_USER = "user"
    private let CACHE_KEY_CATEGORIES = "categories"
    private let CACHE_KEY_STORIES = "stories"
    private let CACHE_KEY_FEATURE = "feature"
    private let CACHE_KEY_CART = "cart"
    private let CACHE_KEY_PRODUCTS = "products"
    private let CACHE_KEY_SEARCH_PRODUCTS = "searchproducts"
    private let CACHE_KEY_LATEST_SEARCH_RESULTS = "latestSearchrResults"
    private let CACHE_KEY_FCM_TOKEN = "FCM_TOKEN"
    private let CACHE_KEY_MY_LOCATION = "myLocation"
    private let CACHE_KEY_ON_GOING_ORDER = "onGoingOrderId"
    private let CACHE_KEY_URL = "url"
    private let CACHE_KEY_COMPANY = "company"
    private let CACHE_KEY_PROJECTS = "projects"
    private let CACHE_KEY_LOGGED = "logged"
    private let CACHE_KEY_CURRENT_SESSION = "currentSession"
    private let CACHE_KEY_CURRENT_PROJECT = "currentProject"
    private let CACHE_KEY_CURRENT_NUMBER_OF_RECORDS = "numberOfRecords"
    private let CACHE_KEY_CURRENT_TIME = "time"
    private let CACHE_KEY_LOGS_SYNC_PERIOD = "logPeriod"
    private let CACHE_KEY_LOCATIONS_SYNC_PERIOD = "locationsPeriod"
    private let CACHE_KEY_CURRENT_SYNC_TIME = "Synctime"
    private let CACHE_KEY_CURRENT_LOCATIONS = "locations"
    //MARK: Temp data holders
    //keep reference to the written value in another private property just to prevent reading from cache each time you use this var
    private var _me:AppUser?
    private var _my_location:Location?
    private var _service:Service?
    private var _logged:Int?
    private var _company:Company?
    private var _projects:[Task] = []
    private var _current_project:Task?
    private var _current_session:Lap?
    private var _number_of_records:Int?
    private var _number_of_seconds:Int?
    private var _log_sync_period:Int?
    private var _location_sync_period:Int?
    private var _sync_time:String?
    private var _locations:[Lap] = []

    // user loggedin flag
    var isLoggedin: Bool {
        if let token = logged, token == 1 {
            return true
        }
        return false
    }

    
    public var logged:Int?{
        set{
            _logged = newValue
            saveIntWithKey(intToStore: _logged!, key: CACHE_KEY_LOGGED)
        }
        
        get{
            _logged = loadIntForKey(key: CACHE_KEY_LOGGED)
            return _logged
        }
    }

    
    
    // MARK: Cached data
    public var me:AppUser?{
        set {
            _me = newValue
            saveBaseModelObject(object: _me, withKey: CACHE_KEY_USER)
            NotificationCenter.default.post(name: .notificationUserChanged, object: nil)
        }
        get {
            if (_me == nil) {
                _me = loadBaseModelObjectForKey(key: CACHE_KEY_USER)
            }
            return _me
        }
    }
    
    
    public var numberOfRecords:Int?{
        set {
            _number_of_records = newValue
            saveIntWithKey(intToStore: _number_of_records!, key: CACHE_KEY_CURRENT_NUMBER_OF_RECORDS)
        }
        get {
            if (_number_of_records == nil) {
                _number_of_records = loadIntForKey(key: CACHE_KEY_CURRENT_NUMBER_OF_RECORDS)
            }
            return _number_of_records
        }
    }
    
    public var numberOfSeconds:Int?{
        set {
            _number_of_seconds = newValue
            saveIntWithKey(intToStore: _number_of_seconds!, key: CACHE_KEY_CURRENT_TIME)
        }
        get {
            if (_number_of_seconds == nil) {
                _number_of_seconds = loadIntForKey(key: CACHE_KEY_CURRENT_TIME)
            }
            return _number_of_seconds
        }
    }
    
    public var logSyncPeriod:Int?{
        set {
            _log_sync_period = newValue
            saveIntWithKey(intToStore: _log_sync_period!, key: CACHE_KEY_LOGS_SYNC_PERIOD)
        }
        get {
            if (_log_sync_period == nil) {
                _log_sync_period = loadIntForKey(key: CACHE_KEY_LOGS_SYNC_PERIOD)
            }
            return _log_sync_period
        }
    }
    
    
    public var locationSyncPeriod:Int?{
        set {
            _location_sync_period = newValue
            saveIntWithKey(intToStore: _location_sync_period!, key: CACHE_KEY_LOCATIONS_SYNC_PERIOD)
        }
        get {
            if (_location_sync_period == nil) {
                _location_sync_period = loadIntForKey(key: CACHE_KEY_LOCATIONS_SYNC_PERIOD)
            }
            return _location_sync_period
        }
    }
    
    public var syncTime:String?{
        set {
            _sync_time = newValue
            saveStringWithKey(stringToStore: _sync_time, key: CACHE_KEY_CURRENT_SYNC_TIME)
        }
        
        get {
            if (_sync_time == nil) {
                _sync_time = loadStringForKey(key: CACHE_KEY_CURRENT_SYNC_TIME)
            }
            return _sync_time
        }
    }
    
    public var myLocation:Location?{
        set{
            _my_location = newValue
            saveBaseModelObject(object: _my_location, withKey: CACHE_KEY_MY_LOCATION)
            NotificationCenter.default.post(name: .notificationUserChanged, object: nil)
        }
        
        get{
            if (_my_location == nil) {
                _my_location = loadBaseModelObjectForKey(key: CACHE_KEY_MY_LOCATION)
            }
            return _my_location
        }
    }
    
    public var currentURL:Service?{
        set{
            _service = newValue
            saveBaseModelObject(object: _service, withKey: CACHE_KEY_URL)
        }
        get{
            if (_service == nil) {
                _service = loadBaseModelObjectForKey(key: CACHE_KEY_URL)
            }
            return _service
        }
    }
    
    public var currentCompany:Company?{
        set{
            _company = newValue
            saveBaseModelObject(object: _company, withKey: CACHE_KEY_COMPANY)
        }
        get{
            if (_company == nil) {
                _company = loadBaseModelObjectForKey(key: CACHE_KEY_COMPANY)
            }
            return _company
        }
    }
    
    
    
    
    public var currentSession:Lap?{
        set{
            _current_session = newValue
            saveBaseModelObject(object: _current_session, withKey: CACHE_KEY_CURRENT_SESSION)
        }
        get{
//            if (_current_session == nil) {
                _current_session = loadBaseModelObjectForKey(key: CACHE_KEY_CURRENT_SESSION)
//            }
            return _current_session
        }
    }
    
    public var currentProject:Task?{
        set{
            _current_project = newValue
            saveBaseModelObject(object: _current_project, withKey: CACHE_KEY_CURRENT_PROJECT)
        }
        get{
            if (_current_project == nil) {
                _current_project = loadBaseModelObjectForKey(key: CACHE_KEY_CURRENT_PROJECT)
            }
            return _current_project
        }
    }
    
    
    public var projects:[Task] {
        set{
            _projects = newValue
            saveBaseModelArray(array: _projects, withKey: CACHE_KEY_PROJECTS)
        }
        get{
            if _projects.isEmpty{
                _projects = loadBaseModelArrayForKey(key: CACHE_KEY_PROJECTS)
            }
            return _projects
        }
    }

    
    
    
    public var locations :[Lap]{

        set{
            _locations = newValue
            saveBaseModelArray(array: _locations , withKey: CACHE_KEY_CURRENT_LOCATIONS)
        }
        get {
            if _locations.isEmpty{
                _locations = loadBaseModelArrayForKey(key: CACHE_KEY_CURRENT_LOCATIONS)
            }
            return _locations
        }
    }
    
   
    
    
    
    
    
   
    
    
    
    //MARK: Singelton
    public static var shared: DataStore = DataStore()
    
    private override init(){
        super.init()
    }
   
    //MARK: Cache Utils
    private func saveBaseModelArray(array: [BaseModel] , withKey key:String){
        let data : [[String:Any]] = array.map{$0.dictionaryRepresentation()}
        UserDefaults.standard.set(data, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    private func loadBaseModelArrayForKey<T:BaseModel>(key: String)->[T]{
        var result : [T] = []
        if let arr = UserDefaults.standard.array(forKey: key) as? [[String: Any]]
        {
            result = arr.map{T(json: JSON($0))}
        }
        return result
    }
    
    public func saveBaseModelObject<T:BaseModel>(object:T?, withKey key:String)
    {
        UserDefaults.standard.set(object?.dictionaryRepresentation(), forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    public func loadBaseModelObjectForKey<T:BaseModel>(key:String) -> T?
    {
        if let object = UserDefaults.standard.object(forKey: key)
        {
            return T(json: JSON(object))
        }
        return nil
    }
    
    private func loadStringForKey(key:String) -> String?{
        let storedString = UserDefaults.standard.object(forKey: key) as? String
        return storedString;
    }
    
    private func saveStringWithKey(stringToStore: String?, key: String){
        UserDefaults.standard.set(stringToStore, forKey: key);
        UserDefaults.standard.synchronize();
    }
    
    private func loadIntForKey(key:String) -> Int{
        let storedInt = UserDefaults.standard.object(forKey: key) as? Int ?? 0
        return storedInt;
    }
    
    private func saveIntWithKey(intToStore: Int, key: String){
        UserDefaults.standard.set(intToStore, forKey: key);
        UserDefaults.standard.synchronize();
    }
    
    public func clearCache()
    {
        if let bundle = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundle)
        }
    }

    public func saveUser(notify: Bool) {
        saveBaseModelObject(object: _me, withKey: CACHE_KEY_USER)
        if notify {
            NotificationCenter.default.post(name: .notificationUserChanged, object: nil)
        }
    }
    
  
    public func logout() {
        clearCache()
        me = nil
        logged = 0
        
    }
}





