






import Foundation
import SQLite

class DatabaseManagement {
    
    
    static let shared:DatabaseManagement = DatabaseManagement()
    
    
    private let db: Connection?
    

    private init() {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        do {
            db = try Connection("\(path)/db.sqlite3")
            createTableUser()
            createServicesTable()
            createCompanyTable()
            createTasksTable()
            createLapTable()
            
        } catch {
            db = nil
            print ("Unable to open database")
        }
    }
    
    /////// Services /////////
    private let tblServicss = Table("Services")
    private let serviceID = Expression<Int64>("id")
    private let serviceUserCode = Expression<String>("UserCode")
    private let serviceTitle = Expression<String>("title")
    private let serviceURL = Expression<String>("url")
    private let serviceCreatedDate = Expression<Date>("CreatedDate")
    
    
    func createServicesTable() {
        do {
            try db!.run(tblServicss.create(ifNotExists: false) { table in
                table.column(serviceID, primaryKey: true)
                table.column(serviceUserCode)
                table.column(serviceTitle ,unique: true)
                table.column(serviceCreatedDate)
                table.column(serviceURL)
            })
            print("create Services table successfully")
        } catch {
            print("Unable to create Services table")
        }
    }
    
    
    func addService(service:Service) -> Int64 {
        do {
            let insert = tblServicss.insert(serviceTitle <- service.title!,serviceCreatedDate <- service.date!,serviceUserCode <- service.userCode!,serviceURL <- service.url!)
            if let id = try db?.run(insert){
                print("Insert to tblService successfully userid \(id)")
                return id
            }
            return -1
        } catch {
            print("Cannot insert to tblService ")
            print(error)
            return -1
        }
    }
    
    
    
    func queryAllServices() -> [Service] {
        var services = [Service]()
        
        do {
            for service in try db!.prepare(self.tblServicss) {
                
                let newService = Service(ID: service[serviceID], title: service[serviceTitle], url: service[serviceURL], date: service[serviceCreatedDate],userCode:service[serviceUserCode])
                services.append(newService)
            }
        } catch {
            print("Cannot get list of product")
        }
        for service in services {
            print("each service = \(service)")
        }
        return services
    }
    
    func queryServiceById(id:Int64) -> Service? {
        do{
            let tbl  = tblServicss.filter(serviceID == id)
            if let service  = try db?.pluck(tbl){
                let newService = Service(ID: service[serviceID], title: service[serviceTitle], url: service[serviceURL], date: service[serviceCreatedDate],userCode:service[serviceUserCode])
                return newService
            }
            return nil
        }catch{
            return nil
        }
        
    }

//    func updateTask(id:Int64, task: Task) -> Bool {
//        let headertbl = tblTasks.filter(taskID == id)
//        do {
//            let update = headertbl.update([
//                taskTitle <- task.title
//                ])
//            if try db!.run(update) > 0 {
//                print("Update item successfully")
//                return true
//            }
//        } catch {
//            print("Update failed: \(error)")
//        }
//
//        return false
//    }
    
    
    
//    func queryServiceTasks(serviceId:Int64)->[Task]{
//        var tasks:[Task] = []
//        do {
//            for task in try db!.prepare(self.tblTasks.filter(taskServiceID == serviceId)) {
//                let newTask = Task(ID: task[taskID], name:     task[taskTitle],date:task[taskCreatedDate],projectId:task[taskProjectID],companyId:task[taskCompanyID])
//                tasks.append(newTask)
//            }
//        } catch {
//            print("Cannot get list of Laps")
//        }
//        return tasks
//    }
    
    
    func deleteService(Id: Int64) -> Bool {
        do {
            let tbl = tblServicss.filter(serviceID == Id)
            try db!.run(tbl.delete())
            print("delete sucessfully")
            return true
        } catch {
            print("Delete failed")
        }
        return false
    }
    
    /////// End of Services /////////
    ////// Company ////////
    private let tblCompanies = Table("Companies")
    private let companyID = Expression<Int64>("id")
    private let companyTitle = Expression<String>("title")
    private let companyDB = Expression<String>("DB")
    private let companyURLID = Expression<Int64>("serviceId")
    
    func createCompanyTable() {
        do {
            try db!.run(tblCompanies.create(ifNotExists: false) { table in
                table.column(serviceID, primaryKey: true)
                table.column(serviceTitle ,unique: true)
                table.column(companyDB ,unique: true)
                table.column(companyURLID, references: tblServicss,serviceID)
            })
            print("create Company table successfully")
        } catch {
            print("Unable to create Company table")
        }
    }
    
    
    func addCompany(company:Company) -> Int64 {
        do {
            let insert = tblCompanies.insert(companyTitle <- company.title ?? "",companyURLID <- company.urlId!,companyDB <- company.DB ?? "")
            if let id = try db?.run(insert){
                print("Insert to tblCompanies successfully userid \(id)")
                return id
            }
            return -1
        } catch {
            print("Cannot insert to tblCompanies ")
            print(error)
            return -1
        }
    }
    
    
    
    func queryAllCompanies() -> [Company] {
        var companies = [Company]()
        
        do {
            for company in try db!.prepare(self.tblCompanies) {
                
                let newCompany = Company(ID: company[companyID], title: company[companyTitle],DB: company[companyDB], urlId: company[companyURLID])
                companies.append(newCompany)
            }
        } catch {
            print("Cannot get list of companies")
        }
        for company in companies {
            print("each company = \(company)")
        }
        return companies
    }
    
    func queryCompanyById(id:Int64) -> Company? {
        do{
            let tbl  = tblCompanies.filter(companyID == id)
            if let company  = try db?.pluck(tbl){
               let newCompany =  Company(ID: company[companyID], title: company[companyTitle],DB: company[companyDB], urlId: company[companyURLID])
                return newCompany
            }
            return nil
        }catch{
            return nil
        }
        
    }
    
    
    func queryCompanyProjects(companyId:Int64)->[Task]{
        var tasks:[Task] = []
        do {
            for task in try db!.prepare(self.tblTasks.filter(taskCompanyID == companyId)) {
                let newTask = Task(ID: task[taskID], name: task[taskTitle],date:task[taskCreatedDate],projectId:task[taskProjectID],companyId:task[taskCompanyID])
                tasks.append(newTask)
            }
        } catch {
            print("Cannot get list of Laps")
        }
        return tasks
    }
    
    
    func deleteCompany(Id: Int64) -> Bool {
        do {
            let tbl = tblCompanies.filter(companyID == Id)
            try db!.run(tbl.delete())
            print("delete sucessfully")
            return true
        } catch {
            print("Delete failed")
        }
        return false
    }
    
    
    ////// End Company ////////
 
    /////////////// Tasks ///////////
    
    
    private let tblTasks = Table("Tasks")
    private let taskID = Expression<Int64>("id")
    private let taskCompanyID = Expression<Int64>("companyID")
    private let taskProjectID = Expression<Int>("projectId")
    private let taskTitle = Expression<String>("title")
    private let taskCreatedDate = Expression<Date>("CreatedDate")
    
    
    func createTasksTable() {
        do {
            try db!.run(tblTasks.create(ifNotExists: false) { table in
                table.column(taskID, primaryKey: true)
                table.column(taskCompanyID, references: tblCompanies,companyID)
                table.column(taskTitle ,unique: true)
                table.column(taskProjectID)
                table.column(taskCreatedDate)
            })
            print("create Tasks table successfully")
        } catch {
            print("Unable to create Tasks table")
        }
    }
    
    
    func addTask(task:Task) -> Int64 {
        do {
            let insert = tblTasks.insert(taskTitle <- task.name!,taskProjectID <- task.projectId!,taskCompanyID <- task.companyId!,taskCreatedDate <- task.date!)
            if let id = try db?.run(insert){
                print("Insert to tblHeader successfully userid \(id)")
                return id
            }
        return -1
        } catch {
            print("Cannot insert to tblHeader ")
            print(error)
            return -1
        }
    }
    

    
    func queryAllTasks() -> [Task] {
        var tasks = [Task]()
        
        do {
            for task in try db!.prepare(self.tblTasks) {
            
                let newTask = Task(ID: task[taskID], name:     task[taskTitle],date:task[taskCreatedDate],projectId:task[taskProjectID],companyId:task[taskCompanyID])
                tasks.append(newTask)
            }
        } catch {
            print("Cannot get list of tasks")
        }
        for task in tasks {
            print("each task = \(task)")
        }
        return tasks
    }

    func queryTaskById(id:Int64) -> Task? {
        do{
            let tbl  = tblTasks.filter(taskID == id)
            if let task  = try db?.pluck(tbl){
            let newTask = Task(ID: task[taskID], name:     task[taskTitle],date:task[taskCreatedDate],projectId:task[taskProjectID],companyId:task[taskCompanyID])
                return newTask
            }
            return nil
        }catch{
            return nil
        }
        
    }
    
    
    func deleteTask(Id: Int64) -> Bool {
        do {
            let tbl = tblTasks.filter(taskID == Id)
            try db!.run(tbl.delete())
            print("delete sucessfully")
            return true
        } catch {
            
            print("Delete failed")
        }
        return false
    }
    
    
    ///////////////// End Of Tasks //////////
    
    ///////////////// USER //////////////////
    
    //Mark: Users
    
    private let tblUser = Table("Users")
    private let UserId = Expression<Int64>("id")
    private let UserFirstName = Expression<String?>("FirstName")
    private let UserLastName = Expression<String?>("LastName")
//    private let UserEmail = Expression<String>("Email")
    private let UserName = Expression<String>("UserName")
//    private let UserImage = Expression<String?>("Image")
    private let UserPWD = Expression<String>("Password")
//    private let UserisActive = Expression<Bool>("isActive")
    private let UserCode = Expression<String?>("code")
//
//
//
//
    func createTableUser() {
        do {
            try db!.run(tblUser.create(ifNotExists: false) { table in
                table.column(UserId, primaryKey: true)
                table.column(UserFirstName)
                table.column(UserLastName)
                table.column(UserName,unique: true)
                table.column(UserPWD)
                table.column(UserCode)
            })
            print("create User table successfully")
        } catch {
            print("Unable to create User table")
        }
    }

    func addUser(user:AppUser) -> Int64? {
        do {
            let insert = tblUser.insert(UserName <- user.username!,UserPWD <- user.password!,UserCode <- user.code!)
            let id = try db!.run(insert)
            print("Insert to tblUser successfully")
            return id
        } catch {
            print("Cannot insert to tblUser ")
            print(error)
            return nil
        }
    }

    func queryUserById(id:Int64) -> AppUser? {
        do{
            let userid  = try tblUser.filter(UserId == id)
            let user  = try db!.pluck(userid)
            let newuser = AppUser(uid: user?[UserId], username: user?[UserName], pwd: user?[UserPWD], code: user?[UserCode])
            return newuser
        }catch{
            return nil
        }

    }
//
//
//    func queryUserbyNameandPass(username:String,pass:String) ->AppUser?{
//
//
//        do{
//            let userid  =  tblUser.filter(UserName == username && UserPWD == pass)
//
//            if  let user  = try db?.pluck(userid){
//                let newuser =  User(id: (user[UserId]), UserFirstName: (user[UserName]), UserLastName: (user[UserLastName]),UserEmail:user[UserEmail], UserName: (user[UserName]), UserImage: (user[UserImage]!), UserPWD: (user[UserPWD]), UserisActive: (user[UserisActive]), UserVendorCode: user[UserVendorCode])
//                    return newuser
//                }else{
//            return nil
//            }
//        }catch{
//            return nil
//        }
//    }
//
//
//
//    func updateUser(id:Int64, user: AppUser) -> Bool {
//        let Usertbl = tblUser.filter(UserId == id)
//        do {
//            let update = Usertbl.update([
//                UserFirstName <- user.UserFirstName,UserLastName <- user.UserLastName,UserEmail <- user.UserEmail,UserName <- user.UserName , UserImage <- user.UserImage
//                ,UserPWD <- user.UserPWD , UserisActive <- user.UserisActive
//                ])
//            if try db!.run(update) > 0 {
//                print("Update item successfully")
//                return true
//            }
//        } catch {
//            print("Update failed: \(error)")
//        }
//
//        return false
//    }
    
    
//    func login(username:String,pass:String)-> Bool{
//        
//        
//    
//    }
    
    
    
    //////////// End of User //////////////
    
    
    
    /*
     1-    ID.
     2-    URL
     3-    Company Name
     4-    Project ID
     5-    Start Time
     6-    End Time
     7-    type
     8-    Total Minutes.
     9-    MAC ID + Client type
     10-    User Location
     11-    User IP.
*/
    //////// Laps //////////////
    /*
     1-    ID.
     2-    SessionKey
     3-    URL
     4-    Company Name
     5-    Project ID
     6-    Start Time
     7-    End Time
     8-    Total Minutes.
     9-    MAC ID +
     10-    ClientType (IOS, android, web
     11-    UserLocation
     a.    Lang
     b.    lat
     12-    UserIP.
     13-    WorkType
     14-    syncStatus
     Approved
     */
    
    private let tblLap = Table("Lap")
    private let LapId = Expression<Int64>("id")
    private let lapKey = Expression<String>("SessionKey")
    private let lapURL = Expression<String>("URL")
    private let lapCompany = Expression<String>("Company")
    private let lapTaskId  = Expression<Int64>("taskId")
    private let lapProjectId  = Expression<Int>("projectId")
    private let lapStartTime = Expression<Date>("startTime")
    private let lapEndTime = Expression<Date?>("endTime")
    private let seconds = Expression<Int?>("seconds")
    private let lapMac = Expression<String?>("MAC")
    private let lapClient = Expression<String>("clientType")
    private let lapLat = Expression<String?>("Lat")
    private let lapLong = Expression<String?>("Long")
    private let lapIP = Expression<String?>("IP")
    private let lapType = Expression<String>("type")
    private let lapSynced = Expression<Bool>("synced")
    private let lapApproved = Expression<Bool>("approved")
    
    func createLapTable() {
        do {
            try db!.run(tblLap.create(ifNotExists: false) { table in
                table.column(LapId, primaryKey: true)
                table.column(lapKey)
                table.column(lapURL)
                table.column(lapCompany)
                table.column(lapTaskId,references:tblTasks,taskID)
                table.column(lapProjectId)
                table.column(lapStartTime)
                table.column(lapEndTime)
                table.column(seconds)
                table.column(lapMac)
                table.column(lapClient)
                table.column(lapLat)
                table.column(lapLong)
                table.column(lapIP)
                table.column(lapType)
                table.column(lapSynced,defaultValue:false)
                table.column(lapApproved,defaultValue:false)
            })
            print("create Lab table successfully")
        } catch {
            print("Unable to create Lab table")
            print(error)
        }
    }
    
    
    
    func addLap(lap:Lap) -> Int64? {
        do {
            let insert = tblLap.insert(lapKey <- lap.SessionKey!,lapURL <- lap.url!, lapCompany <- lap.company! , lapTaskId <- lap.taskID!,lapStartTime <- lap.startTime! , lapEndTime <- lap.endTime ,seconds <- lap.seconds , lapMac <- lap.mac,lapClient <- lap.clientType ?? "ios",lapLat <- lap.lat ?? "" , lapLong <- lap.long ?? "", lapIP <- lap.userIP, lapType <- lap.type ?? "work" , lapSynced <- lap.synced ?? false , lapApproved <- lap.approved ?? false, lapProjectId <- lap.projectID! )
            let id = try db?.run(insert)
            print("Insert to tblLine successfully")
            return id
        } catch {
            print("Cannot insert to tblLine ")
            print(error)
            return nil
        }
    }
    
    
    func queryLapById(id:Int64) -> Lap? {
        do{
            let laptbl  = tblLap.filter(LapId == id)
            let lap  = try db?.pluck(laptbl)
            let newLap = Lap(ID: lap?[LapId], SessionKey: lap?[lapKey], url: lap?[lapURL], company: lap?[lapCompany], taskID: lap?[lapTaskId], projectID: lap?[lapProjectId], startTime: lap?[lapStartTime], endTime: lap?[lapEndTime], seconds: lap?[seconds] ?? 0, mac: lap?[lapMac], clientType: lap?[lapClient], lat: lap?[lapLat], long: lap?[lapLong], userIP: lap?[lapIP], type: lap?[lapType], synced: lap?[lapSynced], approved: lap?[lapApproved])
            return newLap
        }catch{
            return nil
        }
        
    }
    

    func queryTaskLaps(taskId:Int64)->[Lap]{
        var laps:[Lap] = []
            do {
                for lap in try db!.prepare(self.tblLap.filter(lapTaskId == taskId)) {
                    let newLap =  Lap(ID: lap[LapId], SessionKey: lap[lapKey], url: lap[lapURL], company: lap[lapCompany], taskID: lap[lapTaskId], projectID: lap[lapProjectId], startTime: lap[lapStartTime], endTime: lap[lapEndTime], seconds: lap[seconds] ?? 0, mac: lap[lapMac], clientType: lap[lapClient], lat: lap[lapLat], long: lap[lapLong], userIP: lap[lapIP], type: lap[lapType], synced: lap[lapSynced], approved: lap[lapApproved])
                    laps.append(newLap)
                }
            } catch {
                print("Cannot get list of Laps")
            }
            return laps
    }
    
    
    func queryUnSyncedLaps(url:String,companyDB:String) -> [Lap]{
        var laps:[Lap] = []
        do {
            for lap in try db!.prepare(self.tblLap.filter(lapURL == url && lapCompany == companyDB  && lapSynced == false)) {
                let newLap =  Lap(ID: lap[LapId], SessionKey: lap[lapKey], url: lap[lapURL], company: lap[lapCompany], taskID: lap[lapTaskId], projectID: lap[lapProjectId], startTime: lap[lapStartTime], endTime: lap[lapEndTime], seconds: lap[seconds] ?? 0, mac: lap[lapMac], clientType: lap[lapClient], lat: lap[lapLat], long: lap[lapLong], userIP: lap[lapIP], type: lap[lapType], synced: lap[lapSynced], approved: lap[lapApproved])
                laps.append(newLap)
            }
        } catch {
            print("Cannot get list of Laps")
        }
        return laps
    }
    
    
        func updateLap(id:Int64, lap: Lap) -> Bool {
            let tbl = tblLap.filter(LapId == id)
            do {
                let update = tbl.update([
                    lapKey <- lap.SessionKey!,lapURL <- lap.url!, lapCompany <- lap.company! , lapTaskId <- lap.taskID!,lapStartTime <- lap.startTime! , lapEndTime <- lap.endTime! ,seconds <- lap.seconds , lapMac <- lap.mac!,lapClient <- lap.clientType ?? "ios",lapLat <- lap.lat ?? "" , lapLong <- lap.long ?? "", lapIP <- lap.userIP ?? "", lapType <- lap.type ?? "work" , lapSynced <- lap.synced ?? false , lapApproved <- lap.approved ?? false, lapProjectId <- lap.projectID! ])
                if try db!.run(update) > 0 {
                    print("Update Lab successfully")
                    return true
                }
            } catch {
                print("Update failed: \(error)")
            }
    
            return false
        }
    
    
    
    func deleteLap(Id: Int64) -> Bool {
        do {
            let tblFilterLap = tblLap.filter(LapId == Id)
            try db?.run(tblFilterLap.delete())
            print("delete sucessfully")
            return true
        } catch {
            
            print("Delete failed")
        }
        return false
    }
    
    
    ///////////// End of Laps ////////
    
  
    
}
