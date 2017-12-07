//
//  LocationManager.swift
//  CookieCrowdSource
//
//  Created by Noah Bragg on 8/26/17.
//  Copyright © 2017 Noah Bragg. All rights reserved.
//

import Foundation
import CoreLocation

class LocationChecker : NSObject, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var currentLocation = CLLocationCoordinate2D()
    
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = manager.location!.coordinate
        print("locations = \(currentLocation.latitude) \(currentLocation.longitude)")
    }
    
    public func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    public func isLocationAuthorized() -> Bool {
        return CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) &&
                                        CLLocationManager.authorizationStatus() != .denied;
    }
    
    public func getCurrentLocation() -> CLLocationCoordinate2D {
        return currentLocation
    }
}
