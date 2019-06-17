//
//  LocationHelper.swift
//  Wardah
//
//  Created by Dania on 6/11/17.
//  Copyright © 2017 BrainSocket. All rights reserved.
//

import CoreLocation
import UIKit
// MARK: Default location >> UAE Capital Coordinates
enum DefaultLocation {
    static let latitude = 24.4539
    static let longitude = 54.3773
}

//MARK: Current location stuff
class LocationHelper : NSObject,CLLocationManagerDelegate
{
    // singelton
    public static let shared:LocationHelper = LocationHelper()
    
    private override init() {
        super.init()
    }
    
    // MARK: location stuff
    var locationManager = CLLocationManager()
    var myLocation:Location? = nil{
        didSet {
            print(myLocation)
            DataStore.shared.myLocation = myLocation
            NotificationCenter.default.post(name: .notificationLocationChanged, object: nil)
        }
    }
    
    func startUpdateLocation() {
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = 500
            locationManager.startUpdatingLocation()
         //   locationManager.allowsBackgroundLocationUpdates = true
            locationManager.pausesLocationUpdatesAutomatically = false
        }
    }
    
    func stopUpdateLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0]
        let lat : Double = Double(userLocation.coordinate.latitude)
        let long : Double = Double(userLocation.coordinate.longitude)
        myLocation = Location(lat:lat, long:long)
//        manager.stopUpdatingLocation()
//        stopUpdateLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        //myLocation = Location()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.authorizedWhenInUse) {
            manager.startUpdatingLocation()
        }
        
        if status == CLAuthorizationStatus.authorizedAlways{
            manager.startUpdatingLocation()
        }
        
        if status == CLAuthorizationStatus.denied{
            goToSettings()
        }
        
        if status == CLAuthorizationStatus.restricted {
            goToSettings()
        }
        
    }
    
    
    func goToSettings(){
        let alertController = UIAlertController(title: "I can not locate your location", message: "Please go to Settings and turn on the permissions to be able to use this app", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.openURL(settingsUrl)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        UIApplication.visibleViewController()?.present(alertController, animated: true, completion: nil)
    }
    
    func checkAvilablity() -> Bool{
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways , .authorizedWhenInUse:
            return true
        default:
            return false
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
