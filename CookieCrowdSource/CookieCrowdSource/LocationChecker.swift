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
    var coord = CLLocationCoordinate2D()
    
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        coord = CLLocationCoordinate2D()
        coord.latitude = 39.691483              //coordinates for our apartment
        coord.longitude = -84.101717
        
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
    
    //add a region with the given coordinates
    public func doesRegionIncludeCurrentLocation() -> Bool {
        let region = CLCircularRegion(center: coord, radius: 5632.7, identifier:  "id")        // 3.5 miles in meters
        
        return region.contains(currentLocation)
    }
}
