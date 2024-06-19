//
//  AlertMapVC.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 18/6/2567 BE.
//

import UIKit
import GoogleMaps

class AlertMapVC : UIViewController {
    
    var userLocationMarker = GMSMarker()
    var zoomLevel:Float = 17.0;
    
    var firstTime = true
    
    @IBOutlet weak var myMap: GMSMapView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    var alertTitle = String()
    var alertActionButtonTitle = String()
    
    var alertLat = String()
    var alertLong = String()
    
    var complete: (() -> Void)?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if firstTime {
            setupMap()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    func setupView() {
        titleLabel.text = alertTitle
        actionButton.setTitle(alertActionButtonTitle, for: .normal)
        
        myMap.isMyLocationEnabled = false
        myMap.settings.myLocationButton = false
        myMap.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func setupMap() {
        myMap.isMyLocationEnabled = false
        myMap.settings.myLocationButton = false
        myMap.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        if let lat = Double(alertLat), let long = Double(alertLong) {
            let markerLocation = CLLocation(latitude: lat , longitude: long)
            
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: markerLocation.coordinate.latitude, longitude: markerLocation.coordinate.longitude)
            //marker.title = ""
            marker.snippet = alertTitle
            marker.map = myMap
            
            myMap.camera = GMSCameraPosition.camera(withLatitude: markerLocation.coordinate.latitude,longitude: markerLocation.coordinate.longitude,
                                                    zoom: zoomLevel)
            
            print(lat)
            print(long)
        }
        firstTime = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func didTapDone(_ sender: UIButton) {
        dismiss(animated: true)
        complete?()
    }
}


