//
//  Constants.swift
//  Wardah
//
//  Created by Dania on 12/25/16.
//  Copyright © 2016 . All rights reserved.
//
import UIKit


// MARK: Application configuration
struct AppConfig {
    
    
    static var numberOfRecodrds:Int {
        
        get{
            return DataStore.shared.numberOfRecords == 0 ? 100 : DataStore.shared.numberOfRecords!
        }
        set{
            DataStore.shared.numberOfRecords = newValue
        }
    }
    
    static var numberOfSeconds:Int {
        get{
            return DataStore.shared.numberOfSeconds == 0  ? 36000 : DataStore.shared.numberOfSeconds!
        }
        set{
            DataStore.shared.numberOfSeconds = newValue
        }
    }

    // validation
    static let passwordLength = 6
    // current application language
    static var currentLanguage:AppLanguage {
        let locale = NSLocale.current.languageCode
        if (locale == "ar") {
            return .arabic
        }
        return .english
    }
    
    
    
    
    
    /// Set navigation bar style, text and color
    static func setNavigationStyle() {
        // set text title attributes
        let attrs = [NSAttributedStringKey.foregroundColor : UIColor.black ,
                     NSAttributedStringKey.font : AppFonts.big]
        UINavigationBar.appearance().titleTextAttributes = attrs
        // set background color
        UINavigationBar.appearance().barTintColor = .white
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().tintColor = AppColors.grayXDark
        //        UINavigationBar.appearance().height = 94
        //        UINavigationBar.appearance().frame.size = CGSize(width: UIScreen.main.bounds.width, height: 94)//UINavigationBar.appearance().sizeThatFits(CGSize(width: UIScreen.main.bounds.width, height: 94))
        // UINavigationBar().sizeThatFits(CGSize(width: UIScreen.main.bounds.width, height: 64))
        // remove under line
        //        UINavigationBar.appearance().shadowImage = UIImage()
        //        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
    }

    static func setTabBarStyle(){
        
        UITabBar.appearance().tintColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)
    }
}


// MARK: Notifications
extension Notification.Name {
    static let notificationLocationChanged = Notification.Name("NotificationLocationChanged")
    static let notificationUserChanged = Notification.Name("NotificationUserChanged")
    static let notificationFilterOpened = Notification.Name("NotificationFilterOpened")
    static let notificationFilterClosed = Notification.Name("NotificationFilterClosed")
    static let notificationRefreshStories = Notification.Name("NotificationRefreshStories")
    static let notificationRefreshProducts = Notification.Name("NotificationRefreshProducts")
    static let notificationRefreshCart  = Notification.Name("NotificationRefreshCart")
    
}

// MARK: Screen size
enum ScreenSize {
    static let isSmallScreen =  UIScreen.main.bounds.height <= 568 // iphone 4/5
    static let isMidScreen =  UIScreen.main.bounds.height <= 667 // iPhone 6 & 7
    static let isBigScreen =  UIScreen.main.bounds.height >= 736 // iphone 6Plus/7Plus
    static let isIphone = UIDevice.current.userInterfaceIdiom == .phone
}

enum ScreenSizeRatio{
    
    static let smallRatio = CGFloat(UIScreen.main.bounds.width / 750 ) * 2.0
    static let largRatio =  CGFloat(UIScreen.main.bounds.width / 750 )
}



// MARK: Application language
enum AppLanguage{
    case english
    case arabic
    
    var langCode:String {
        switch self {
        case .english:
            return "en"
        case .arabic:
            return "ar"
        }
    }
}






