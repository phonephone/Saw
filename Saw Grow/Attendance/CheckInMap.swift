//
//  CheckInMap.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 23/11/2564 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import GoogleMaps
import CoreLocation

class CheckInMap: UIViewController {
    
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    var zoomLevel:Float = 17.0;
    //var placesClient: GMSPlacesClient!
    //var preciseLocationZoomLevel: Float = 15.0
    //var approximateLocationZoomLevel: Float = 10.0
    
    var userLocationMarker = GMSMarker()
    var userCircle = GMSCircle()
    
    var mapJSON:JSON?
    
    @IBOutlet weak var gpsBtn: MyButton!
    @IBOutlet weak var qrCodeBtn: MyButton!
    
    @IBOutlet weak var myMap: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("CHECK IN MAP")
        
        self.hideKeyboardWhenTappedAround()
        
        // Initialize the location manager.
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 2.0 //minimun distance to update in meters
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        //placesClient = GMSPlacesClient.shared()
        
        let defaultLocation = CLLocation(latitude: -33.86 , longitude: 151.20)//Office 13.805997, 100.619981

        //let zoomLevel = locationManager.accuracyAuthorization == .fullAccuracy ? preciseLocationZoomLevel : approximateLocationZoomLevel
        myMap.camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude,
                                                longitude: defaultLocation.coordinate.longitude,
                                                zoom: zoomLevel)
        myMap.isMyLocationEnabled = true
        myMap.settings.myLocationButton = true
        myMap.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        if UIDevice.current.hasNotch
        {//iphone X or upper
            myMap.padding = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        }
        else{
            myMap.padding = UIEdgeInsets(top: 0, left: 0, bottom: 110, right: 0)
        }
//        if UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height > 2208 {//iPhone 12 and upper
//        }
        
        loadMap()
    }
    
    func loadMap() {
        let parameters:Parameters = [:]
        loadRequest(method:.get, apiName:"attendance/getemplocation", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                //ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                //print("SUCCESS MAP1\(json)")
                
                self.mapJSON = json["data"][0]["worklocation"]
                self.plotMarker()
            }
        }
    }
    
    func plotMarker() {
        myMap.clear()
        //userCircle.map = nil
        
        if (mapJSON != nil) {
            if (mapJSON!.count > 0) {
                for i in 0..<mapJSON!.count {
                    let markerArray = self.mapJSON![i]
                    
                    let markerLocation = CLLocation(latitude: CLLocationDegrees(markerArray["latitude"].doubleValue), longitude: CLLocationDegrees(markerArray["longitude"].doubleValue))
                    
                    let marker = GMSMarker(position: markerLocation.coordinate)
                    //marker.position = markerLocation.coordinate
                    marker.icon = UIImage(named: "checkin_pin")
                    marker.title = markerArray["worklocation_name"].stringValue
                    marker.snippet = markerArray["address"].stringValue
                    marker.map = myMap
                    
                    let markerCircle = GMSCircle(position: markerLocation.coordinate, radius: CLLocationDistance(markerArray["radius"].doubleValue))
                    //markerCircle.radius = CLLocationDistance(mapJSON!["radius"].doubleValue) // radius in meters
                    markerCircle.fillColor = UIColor.systemBlue.withAlphaComponent(0.2)
                    markerCircle.strokeWidth = 5
                    markerCircle.strokeColor = UIColor.white
                    markerCircle.map = myMap
                }
            }
        }
    }
    
    @IBAction func gpsClick(_ sender: UIButton) {
        qrCodeBtn.segmentOff()
        gpsBtn.segmentOn()
    }
    
    @IBAction func qrCodeClick(_ sender: UIButton) {
        gpsBtn.segmentOff()
        qrCodeBtn.segmentOn()
    }
    
    @IBAction func back(_ sender: UIButton) {
        locationManager.stopUpdatingLocation()
        self.navigationController!.popViewController(animated: true)
    }
}

// MARK: - CLLocation Delegate
extension CheckInMap: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")

        userLocationMarker.map = nil
        
        //userLocationMarker = GMSMarker(position: location.coordinate)
        //userLocationMarker.icon = UIImage(named: "checkin_pin")
        //userLocationMarker.map = myMap
        //userLocationMarker.title = "Sydney"
        //userLocationMarker.snippet = "Australia"
        
        //let zoomLevel = locationManager.accuracyAuthorization == .fullAccuracy ? preciseLocationZoomLevel : approximateLocationZoomLevel
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: myMap.camera.zoom)
        
        myMap.animate(to: camera)
        
        NotificationCenter.default.post(name: Notification.Name("sendMapInfo"), object: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Handle authorization status
        
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            //myMap.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        @unknown default:
            fatalError()
        }
    }
    
    // Check accuracy authorization
    
//    let accuracy = manager.accuracyAuthorization
//    switch accuracy {
//    case .fullAccuracy:
//    print("Location accuracy is precise.")
//    case .reducedAccuracy:
//    print("Location accuracy is not precise.")
//    @unknown default:
//    fatalError()
//    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}
