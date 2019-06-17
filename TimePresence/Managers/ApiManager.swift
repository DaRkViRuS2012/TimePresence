//
//  ApiManager.swift
//
//  Created by Molham Mahmoud on 25/04/16.
//  Copyright © 2016. All rights reserved.
//


import Alamofire
import CoreLocation
import SwiftyJSON

/// - Api store do all Networking stuff
///     - build server request 
///     - prepare params
///     - and add requests headers
///     - parse Json response to App data models
///     - parse error code to Server error object
///
class ApiManager: NSObject {

    typealias Payload = (MultipartFormData) -> Void
    
    /// frequent request headers
    var headers: HTTPHeaders{
        get{
//            let token = ((DataStore.shared.me?.token) != nil) ? "Bearer \((DataStore.shared.me?.token)!)" : ""
            let httpHeaders:[String:String] = [:]
            return httpHeaders
        }
    }
    
    let baseURL = DataStore.shared.currentURL?.url ?? ""
    //let baseURL = "http://192.168.1.116:8000/api"
    let imageUrl = ""
    let error_domain = ""
    
    //MARK: Shared Instance
    static let shared: ApiManager = ApiManager()
    
    private override init(){
        super.init()
    }    
   
    // MARK: Authorization

    
    
    /// User facebook login request
    func userFacebookLogin(facebookId: String, completionBlock: @escaping (_ success: Bool, _ error: ServerError?, _ user:AppUser?) -> Void) {
        // url & parameters
        let signInURL = "\(baseURL)auth/facebook/login"
        let parameters : [String : Any] = [
            "id": facebookId,
            ]
        // build request
        Alamofire.request(signInURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess {
                let jsonResponse = JSON(responseObject.result.value!)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let serverError = ServerError(json: jsonResponse) ?? ServerError.unknownError
                    completionBlock(false , serverError, nil)
                } else {
                    // parse response to data model >> user object
                    let user = AppUser(json: jsonResponse["user"])
                    DataStore.shared.me = user
                    completionBlock(true , nil, user)
                }
            }
            // Network error request time out or server error with no payload
            if responseObject.result.isFailure {
                if let code = responseObject.response?.statusCode, code >= 400 {
                    completionBlock(false, ServerError.unknownError, nil)
                } else {
                    completionBlock(false, ServerError.connectionError, nil)
                }
            }
        }
    }
    
    
    
    /// User login request
    func userLogin(email: String, password: String, completionBlock: @escaping (_ success: Bool, _ error: ServerError?, _ user:AppUser?) -> Void) {
        // url & parameters
        let signInURL = "\(baseURL)/login"
        let parameters : [String : Any] = [
            "email": email,
            "password": password
        ]
        
        
        print(signInURL)
        // build request
        Alamofire.request(signInURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess {
                let jsonResponse = JSON(responseObject.result.value!)
                print(jsonResponse)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let serverError = ServerError(json: jsonResponse) ?? ServerError.unknownError
                    completionBlock(false , serverError, nil)
                } else {
                    // parse response to data model >> user object
                    let user = AppUser(json: jsonResponse)
                    DataStore.shared.me = user
                    completionBlock(true , nil, user)
                }
            }
            // Network error request time out or server error with no payload
            if responseObject.result.isFailure {
                 if let code = responseObject.response?.statusCode, code >= 400 {
                    completionBlock(false, ServerError.unknownError, nil)
                 } else {
                    completionBlock(false, ServerError.connectionError, nil)
                }
            }
        }
    }
    
    
    
    /// User Signup request
    func userSignup(user: AppUser, password: String,image:UIImage?, completionBlock: @escaping (_ success: Bool, _ error: ServerError?, _ user:AppUser?) -> Void) {
        // url & parameters
        guard password.length>0,
            let _ = user.email
            else {
                return
        }
        
        let signUpURL = "\(baseURL)/register"
        
        var parameters : [String : Any] = [
            "email": user.email!,
            "password": password,
            "first_name":user.firstName!,
            "last_name":user.lastName!
        ]
        
    
        
        if let _ = image{
        let payload : Payload = { multipartFormData in
            
            if let photo = image, let imageData = UIImageJPEGRepresentation(photo, 0.1){
                multipartFormData.append(imageData, withName: "hk_id", fileName: "file.jpg", mimeType: "image/jpg")
                
            }
            
            for (key, value) in parameters{
             multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }
            
        }
        
        Alamofire.upload(multipartFormData: payload, to: signUpURL, method: .post, headers: headers,
                         encodingCompletion: { encodingResult in
                            print(encodingResult)
                            switch encodingResult {
                            case .success(let upload, _, _):
                                upload.responseJSON { responseObject in
                                    
                                    //Request success
                                    if responseObject.result.isSuccess {
                                        let jsonResponse = JSON(responseObject.result.value!)
                            if let code = responseObject.response?.statusCode, code >= 400 {
                                            let serverError = ServerError(json: jsonResponse) ?? ServerError.unknownError
                                            completionBlock(false , serverError, nil)
                                        } else {
                                            //parse user object and save it
                                            let user = AppUser(json: jsonResponse)
                                            DataStore.shared.me = user
                                            completionBlock(true , nil,user)
                                        }
                                    }
                                    //Network error
                                    if responseObject.result.isFailure {
                                        if let code = responseObject.response?.statusCode, code >= 400 {
                                            completionBlock(false, ServerError.unknownError, nil)
                                        } else {
                                            completionBlock(false, ServerError.connectionError, nil)
                                        }
                                    }
                                }
                            case .failure(let encodingError):
                                completionBlock(false, ServerError.unknownError,nil)
                            }
        })
        }
        else{
        // build request
        Alamofire.request(signUpURL, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { (responseObject) -> Void in
            print(responseObject)
            if responseObject.result.isSuccess {
                let jsonResponse = JSON(responseObject.result.value!)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let serverError = ServerError(json: jsonResponse) ?? ServerError.unknownError
                    completionBlock(false , serverError, nil)
                } else {
                    // parse response to data model >> user object
//                    let user = AppUser(json: jsonResponse["user"])
//                    DataStore.shared.me = user
                    completionBlock(true , nil, user)
                }
            }
            // Network error request time out or server error with no payload
            if responseObject.result.isFailure {
                if let code = responseObject.response?.statusCode, code >= 400 {
                    completionBlock(false, ServerError.unknownError, nil)
                } else {
                    completionBlock(false, ServerError.connectionError, nil)
                }
            }
            }
            
        }
    }
    
    
    
    
    // update Profile
    
    func updateProfile(user: AppUser, completionBlock: @escaping (_ success: Bool, _ error: ServerError?, _ user:AppUser?) -> Void) {
        // url & parameters
        guard let _ = user.email
            else {
                return
        }

        let signUpURL = "\(baseURL)/updateProfile"

        var parameters : [String : String] = [
            "email": user.email!,
            "first_name":user.firstName!,
            "last_name":user.lastName!,
            "_method" : "put"
        ]
        
     
        // build request
        Alamofire.request(signUpURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
            print(responseObject)
            if responseObject.result.isSuccess {
                let jsonResponse = JSON(responseObject.result.value!)
                print(jsonResponse)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let serverError = ServerError(json: jsonResponse) ?? ServerError.unknownError
                    completionBlock(false , serverError, nil)
                } else {
                    // parse response to data model >> user object
                    let user = AppUser(json: jsonResponse)
                    
                    DataStore.shared.me = user
                    completionBlock(true , nil, user)
                }
            }
            // Network error request time out or server error with no payload
            if responseObject.result.isFailure {
                if let code = responseObject.response?.statusCode, code >= 400 {
                    completionBlock(false, ServerError.unknownError, nil)
                } else {
                    completionBlock(false, ServerError.connectionError, nil)
                }
            }
        }
    }
    
    
    
    func registerWithImage( image:UIImage?, completionBlock: @escaping (_ sucess: Bool, _ error: NSError?) -> Void) {
        
        let signUpURL = "\(baseURL)/setProfilePhoto"
        
        //        var parameters : [String : Any] = [
        //            "profile_photo": image
        //            ]
        //
        let payload : Payload = { multipartFormData in
            
            if let photo = image, let imageData = UIImageJPEGRepresentation(photo, 0.1){
                multipartFormData.append(imageData, withName: "profile_photo", fileName: "file.jpg", mimeType: "image/jpg")
                
            }
            
            //            for (key, value) in parameters{
            //                multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            //            }
            
        }
        
        Alamofire.upload(multipartFormData: payload, to: signUpURL, method: .post, headers: headers,
                         encodingCompletion: { encodingResult in
                            switch encodingResult {
                            case .success(let upload, _, _):
                                upload.responseJSON { responseObject in
                                    //Request success
                                    if responseObject.result.isSuccess {
                                        let jsonResponse = JSON(responseObject.result.value!)
                                        if let _ = jsonResponse["error"].string {
                                            let errCode = jsonResponse["code"].intValue
                                            let errObj = NSError(domain: self.error_domain, code: errCode, userInfo: nil)
                                            completionBlock(false, errObj)
                                        } else {
                                            //parse user object and save it
                                            let user = AppUser(json: jsonResponse)
                                            DataStore.shared.me = user
                                            completionBlock(true , nil)
                                        }
                                    }
                                    //Network error
                                    if responseObject.result.isFailure {
                                        let error : NSError = responseObject.result.error! as NSError
                                        completionBlock(false, error)
                                    }
                                }
                            case .failure(let encodingError):
                                completionBlock(false, encodingError as NSError?)
                            }
        })
    }
    
    
    
    
    /// setProfilePhoto
    func setProfilePhoto( image:UIImage?, completionBlock: @escaping (_ sucess: Bool, _ error: NSError?) -> Void) {
    
        let signUpURL = "\(baseURL)/setProfilePhoto"
        
//        var parameters : [String : Any] = [
//            "profile_photo": image
//            ]
//
        let payload : Payload = { multipartFormData in
            
            if let photo = image, let imageData = UIImageJPEGRepresentation(photo, 0.1){
                multipartFormData.append(imageData, withName: "profile_photo", fileName: "file.jpg", mimeType: "image/jpg")

            }
            
//            for (key, value) in parameters{
//                multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
//            }
            
        }
        
        Alamofire.upload(multipartFormData: payload, to: signUpURL, method: .post, headers: headers,
                         encodingCompletion: { encodingResult in
                            switch encodingResult {
                            case .success(let upload, _, _):
                                upload.responseJSON { responseObject in
                                    //Request success
                                    if responseObject.result.isSuccess {
                                        let jsonResponse = JSON(responseObject.result.value!)
                                        if let _ = jsonResponse["error"].string {
                                            let errCode = jsonResponse["code"].intValue
                                            let errObj = NSError(domain: self.error_domain, code: errCode, userInfo: nil)
                                            completionBlock(false, errObj)
                                        } else {
                                            //parse user object and save it
                                            print(jsonResponse)
                                            let user = AppUser(json: jsonResponse)
                                            
                                            DataStore.shared.me = user
                                            completionBlock(true , nil)
                                        }
                                    }
                                    //Network error
                                    if responseObject.result.isFailure {
                                        let error : NSError = responseObject.result.error! as NSError
                                        completionBlock(false, error)
                                    }
                                }
                            case .failure(let encodingError):
                                completionBlock(false, encodingError as NSError?)
                            }
        })
    }
    
    
 
    
    /// Verify user using confirmation code
    func userVerify(code: String, completionBlock: @escaping (_ success: Bool, _ error: ServerError?, _ user:AppUser?) -> Void) {
        
        let signUpURL = "\(baseURL)auth/confirm_code"
        let parameters : [String : String] = [
            "code": code
        ]
        
        // build request
        Alamofire.request(signUpURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess {
                let jsonResponse = JSON(responseObject.result.value!)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let serverError = ServerError(json: jsonResponse) ?? ServerError.unknownError
                    completionBlock(false , serverError, nil)
                } else {
                    // parse response to data model >> user object
                    let user = AppUser(json: jsonResponse["user"])
                    DataStore.shared.me = user
                    completionBlock(true , nil, user)
                }
            }
            // Network error request time out or server error with no payload
            if responseObject.result.isFailure {
                if let code = responseObject.response?.statusCode, code >= 400 {
                    completionBlock(false, ServerError.unknownError, nil)
                } else {
                    completionBlock(false, ServerError.connectionError, nil)
                }
            }
        }
    }
    
    func requestResendVerify(completionBlock: @escaping (_ success: Bool, _ error: ServerError?) -> Void) {
        
        let signUpURL = "\(baseURL)auth/resend_code"
        
        // build request
        Alamofire.request(signUpURL, method: .post, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess {
                let jsonResponse = JSON(responseObject.result.value!)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let serverError = ServerError(json: jsonResponse) ?? ServerError.unknownError
                    completionBlock(false , serverError)
                } else {
                    completionBlock(true , nil)
                }
            }
            // Network error request time out or server error with no payload
            if responseObject.result.isFailure {
                if let code = responseObject.response?.statusCode, code >= 400 {
                    completionBlock(false, ServerError.unknownError)
                } else {
                    completionBlock(false, ServerError.connectionError)
                }
            }
        }
    }
    
    // MARK: Reset Password
    /// User forget password
    func forgetPassword(email: String, completionBlock: @escaping (_ success: Bool, _ error: ServerError?) -> Void) {
        // url & parameters
        let signInURL = "\(baseURL)/resetPassword"
        let parameters : [String : Any] = [
            "email": email,
        ]
        // build request
        Alamofire.request(signInURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
            print(responseObject)
            if responseObject.result.isSuccess {
                let jsonResponse = JSON(responseObject.result.value!)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let serverError = ServerError(json: jsonResponse) ?? ServerError.unknownError
                    completionBlock(false , serverError)
                } else {
                    completionBlock(true , nil)
                }
            }
            // Network error request time out or server error with no payload
            if responseObject.result.isFailure {
                if let code = responseObject.response?.statusCode, code >= 400 {
                    completionBlock(false, ServerError.unknownError)
                } else {
                    completionBlock(false, ServerError.connectionError)
                }
            }
        }
    }
    
    
   
    /// Confirm forget password  
    func confirmForgetPassword(email: String, code: String, password: String, completionBlock: @escaping (_ success: Bool, _ error: ServerError?) -> Void) {
        // url & parameters
        let signInURL = "\(baseURL)auth/confirm_forgot_password"
        let parameters : [String : Any] = [
            "email": email,
            "code": code,
            "password": password
            ]
        // build request
        Alamofire.request(signInURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess {
                let jsonResponse = JSON(responseObject.result.value!)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let serverError = ServerError(json: jsonResponse) ?? ServerError.unknownError
                    completionBlock(false , serverError)
                } else {
                    // parse response to data model >> user object
                    let user = AppUser(json: jsonResponse["user"])
                    DataStore.shared.me = user
                    completionBlock(true , nil)
                }
            }
            // Network error request time out or server error with no payload
            if responseObject.result.isFailure {
                if let code = responseObject.response?.statusCode, code >= 400 {
                    completionBlock(false, ServerError.unknownError)
                } else {
                    completionBlock(false, ServerError.connectionError)
                }
            }
        }
    }
    
    // MARK: User
    /// Get current user information "me"
    func getProfile(completionBlock: @escaping (_ success: Bool, _ error: ServerError?) -> Void) {
        let categoriesListURL = "\(baseURL)/getProfile"
        print(headers)
        Alamofire.request(categoriesListURL, method: .get, headers: headers).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess {
                let jsonResponse = JSON(responseObject.result.value!)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let serverError = ServerError(json: jsonResponse) ?? ServerError.unknownError
                    completionBlock(false , serverError)
                } else {
                    // parse response to data model >> user object
                    let user = AppUser(json: jsonResponse)
                    
                    DataStore.shared.me = user
                    completionBlock(true , nil)
                }
            }
            // Network error request time out or server error with no payload
            if responseObject.result.isFailure {
                if let code = responseObject.response?.statusCode, code >= 400 {
                    completionBlock(false, ServerError.unknownError)
                } else {
                    completionBlock(false, ServerError.connectionError)
                }
            }
        }
    }
    
   
    
    // change passord
    
    func changePassword(currentPassword: String,newPassword:String, completionBlock: @escaping (_ success: Bool, _ error: ServerError?) -> Void) {
        // url & parameters
        let signInURL = "\(baseURL)/changePassword"
        let parameters : [String : Any] = [
            "current_password": currentPassword,
            "new_password": newPassword,
            "_method": "put"
        ]
        // build request
        Alamofire.request(signInURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess {
                let jsonResponse = JSON(responseObject.result.value!)
                print(jsonResponse)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let serverError = ServerError(json: jsonResponse) ?? ServerError.unknownError
                    completionBlock(false , serverError)
                } else {
                    // parse response to data model >> user object
                    completionBlock(true , nil)
                }
            }
            // Network error request time out or server error with no payload
            if responseObject.result.isFailure {
                if let code = responseObject.response?.statusCode, code >= 400 {
                    completionBlock(false, ServerError.unknownError)
                } else {
                    completionBlock(false, ServerError.connectionError)
                }
            }
        }
    }
    
    
    //  getProfilePhoto
    func getProfilePhoto(completionBlock: @escaping (_ success: Bool, _ error: ServerError?) -> Void) {
        let categoriesListURL = "\(baseURL)/getProfilePhoto"
        Alamofire.request(categoriesListURL, method: .get, headers: headers).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess {
                let jsonResponse = JSON(responseObject.result.value!)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let serverError = ServerError(json: jsonResponse) ?? ServerError.unknownError
                    completionBlock(false , serverError)
                } else {
                    // parse response to data model >> user object
                    
                    completionBlock(true , nil)
                }
            }
            // Network error request time out or server error with no payload
            if responseObject.result.isFailure {
                if let code = responseObject.response?.statusCode, code >= 400 {
                    completionBlock(false, ServerError.unknownError)
                } else {
                    completionBlock(false, ServerError.connectionError)
                }
            }
        }
    }
    
    
    
    // get companies
    
    func getCompanies(completionBlock: @escaping (_ success: Bool, _ error: ServerError?,_ response:[Company]) -> Void) {
        let categoriesListURL = "\(DataStore.shared.currentURL?.url ?? "")/MobileApp/CompanyList"
        Alamofire.request(categoriesListURL, method: .get, headers: headers).responseJSON { (responseObject) -> Void in
            print(responseObject)
            if responseObject.result.isSuccess {
                // let resJson = JSON(responseObject.result.value!)
                
                let jsonResponse = JSON(responseObject.result.value!)
                print(jsonResponse)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let serverError = ServerError(json: jsonResponse) ?? ServerError.unknownError
                    completionBlock(false , serverError,[])
                } else {
                    let resultObject = APIResult<Company>(json:jsonResponse)
                    if let haserror = resultObject.has_Error,!haserror {
                        let result = resultObject.data
                        completionBlock(true, nil,result ?? [])
                    }else{
                        let error = ServerError(json: jsonResponse) ?? ServerError.unknownError
                        completionBlock(false, error,[])
                    }
                    
                }
            }
            if responseObject.result.isFailure {
                
                if let code = responseObject.response?.statusCode, code >= 400 {
                    completionBlock(false, ServerError.unknownError,[])
                } else {
                    completionBlock(false, ServerError.connectionError,[])
                }
            }
        }
    }

    
    // get project List
    func getProjectList(companyDB:String,username:String,password:String,completionBlock: @escaping (_ success: Bool, _ error: ServerError?,_ response:[Task]) -> Void) {
        let categoriesListURL = "\(DataStore.shared.currentURL?.url ?? "")/MobileApp/ProjectList"
        
        let parameters : [String : Any] = [
            "companydb": companyDB,
            "username": username,
            "password": password
        ]
        Alamofire.request(categoriesListURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
            print(responseObject)
            if responseObject.result.isSuccess {
                // let resJson = JSON(responseObject.result.value!)
                
                let jsonResponse = JSON(responseObject.result.value!)
                print(jsonResponse)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let serverError = ServerError(json: jsonResponse) ?? ServerError.unknownError
                    completionBlock(false , serverError,[])
                } else {
                    let resultObject = APIResult<Task>(json:jsonResponse)
                    if let haserror = resultObject.has_Error,!haserror {
                        let result = resultObject.data
                        if let parm = resultObject.param , let interval = parm.interval{
                            DataStore.shared.locationSyncPeriod = interval
                        }
                        completionBlock(true, nil,result ?? [])
                    }else{
                        let error = ServerError(json: jsonResponse) ?? ServerError.unknownError
                        completionBlock(false, error,[])
                    }
                    
                }
            }
            if responseObject.result.isFailure {
                
                if let code = responseObject.response?.statusCode, code >= 400 {
                    completionBlock(false, ServerError.unknownError,[])
                } else {
                    completionBlock(false, ServerError.connectionError,[])
                }
            }
        }
    }

   
   

    
    // sync

    func syncLogs(companyDB:String,username:String,password:String,logs:[Lap],completionBlock: @escaping (_ success: Bool, _ error: ServerError?,_ response:[SyncResponce]) -> Void) {
        let categoriesListURL = "\(DataStore.shared.currentURL?.url ?? "")/MobileApp/SaveLog"
        
        
        var logsDictionary:[[String:Any]] = []
        for log in logs{
            var dic = log.dictionaryRepresentation()
            dic["id"] = nil
            dic["latitudes"] = nil
            dic["longitude"] = nil
            logsDictionary.append(dic)
            
        }
        

        
        let parameters : [String : Any] = [
            "companydb": companyDB,
            "username": username,
            "password": password,
            "logs":logsDictionary
        ]
        print(parameters)
        Alamofire.request(categoriesListURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
            print(responseObject)
            if responseObject.result.isSuccess {
                // let resJson = JSON(responseObject.result.value!)
                
                let jsonResponse = JSON(responseObject.result.value!)
                print(jsonResponse)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let serverError = ServerError(json: jsonResponse) ?? ServerError.unknownError
                    completionBlock(false , serverError,[])
                } else {
                    if let array = jsonResponse.array{
                        let result = array.map{SyncResponce(json:$0)}
                        completionBlock(true, nil,result)
                    }else{
                        completionBlock(true, ServerError.unknownError,[])
                    }
                    
                }
            }
            if responseObject.result.isFailure {
                
                if let code = responseObject.response?.statusCode, code >= 400 {
                    completionBlock(false, ServerError.unknownError,[])
                } else {
                    completionBlock(false, ServerError.connectionError,[])
                }
            }
        }
    }
    
    
    func syncLocations(companyDB:String,username:String,password:String,locations:[Lap],completionBlock: @escaping (_ success: Bool, _ error: ServerError?,_ response:[SyncResponce]) -> Void) {
        let categoriesListURL = "\(DataStore.shared.currentURL?.url ?? "")/MobileApp/SaveLocation"
        
        var logsDictionary:[[String:Any]] = []
        for log in locations{
            var dic = log.dictionaryRepresentation()
            let time = dic["startTime"]
            dic["startTime"] = nil
            dic["currentTime"] = time
            logsDictionary.append(dic)
        }
        
        let parameters : [String : Any] = [
            "companydb": companyDB,
            "username": username,
            "password": password,
            "locations" :logsDictionary
        ]
        print(parameters)
        Alamofire.request(categoriesListURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
            print(responseObject)
            if responseObject.result.isSuccess {
                // let resJson = JSON(responseObject.result.value!)
                
                let jsonResponse = JSON(responseObject.result.value!)
                print(jsonResponse)
                if let code = responseObject.response?.statusCode, code >= 400 {
                    let serverError = ServerError(json: jsonResponse) ?? ServerError.unknownError
                    completionBlock(false , serverError,[])
                } else {
                    if let array = jsonResponse.array{
                        let result = array.map{SyncResponce(json:$0)}
                        completionBlock(true, nil,result)
                    }else{
                        completionBlock(true, ServerError.unknownError,[])
                    }
                }
            }
            if responseObject.result.isFailure {
                
                if let code = responseObject.response?.statusCode, code >= 400 {
                    completionBlock(false, ServerError.unknownError,[])
                } else {
                    completionBlock(false, ServerError.connectionError,[])
                }
            }
        }
    }
    
    
}

/**
 Server error represents custome errors types from back end
 */
struct ServerError {
    
    static let errorCodeConnection = 50
    
    public var errorName:String?
    public var status: Int?
    public var code:Int!
    
    public var type:ErrorType {
        get{
            return  .unknown //ErrorType(rawValue: code) ?? .unknown
        }
    }
    
    /// Server erros codes meaning according to backend
    enum ErrorType:Int {
        case connection = 50
        case unknown = -111
        case authorization = 900
        case alreadyExists = 101
        case socialLoginFailed = -110
		case notRegistred = 102
        case missingInputData = 104
        case expiredVerifyCode = 107
        case invalidVerifyCode = 108
        case userNotFound = 109
        
        /// Handle generic error messages
        /// **Warning:** it is not localized string
        var errorMessage:String {
            switch(self) {
                case .unknown:
                    return "Some thing went wrong please try again or connect the admin".localized
                case .connection:
                    return "Can't Connect please check Enternet and make sure you entered a correct URL".localized
                case .authorization:
                    return "ERROR_NOT_AUTHORIZED".localized
                case .alreadyExists:
                    return "ERROR_SIGNUP_EMAIL_EXISTS".localized
				case .notRegistred:
                    return "ERROR_SIGNIN_WRONG_CREDIST".localized
                case .missingInputData:
                    return "ERROR_MISSING_INPUT_DATA".localized
                case .expiredVerifyCode:
                    return "ERROR_EXPIRED_VERIFY_CODE".localized
                case .invalidVerifyCode:
                    return "ERROR_INVALID_VERIFY_CODE".localized
                case .userNotFound:
                    return "ERROR_RESET_WRONG_EMAIL".localized
                default:
                    return "ERROR_UNKNOWN".localized
            }
        }
    }
    
    public static var connectionError: ServerError{
        get {
            var error = ServerError()
            error.errorName = "Can't Connect please check Internet and make sure you entered a correct URL"
            return error
        }
    }
    
    public static var unknownError: ServerError{
        get {
            var error = ServerError()
            error.errorName = "Some thing went wrong please try again or connect the admin"
            return error
        }
    }
    
    public static var socialLoginError: ServerError{
        get {
            var error = ServerError()
            error.code = ErrorType.socialLoginFailed.rawValue
            return error
        }
    }
    
    public init() {
    }
    
    public init?(json: JSON) {

        errorName = ""
        if let msg = json["message"].string{
            errorName = msg
        }
        
        if let msg = json["Data"].string{
            errorName = msg
        }
        
    
        
        if let statusCode = json["status"].int{ status = statusCode}
    }
}


