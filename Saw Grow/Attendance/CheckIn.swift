//
//  CheckIn.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 23/11/2564 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import GoogleMaps
import LocalAuthentication
import Localize_Swift

enum actionType {
    case checkIn
    case update
    case checkedOut
}

class CheckIn: UIViewController, UITextViewDelegate {
    
    var mapJSON:JSON?
    
    var mode:actionType = .checkIn
    var empstatus:String?
    var inArea = false
    var isWFH = false
    var isBioScan = false
    
    var userLat = ""
    var userLong = ""
    
    let remarkStr = "CHECKIN_Note".localized()
    
    var timer: Timer?
    
    let alertService = AlertService()
    
    @IBOutlet weak var sheetView: UIView!
    
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var remarkText: MyTextView!
    
    @IBOutlet weak var uploadImage: UIImageView!
    @IBOutlet weak var uploadLabel: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    @IBOutlet weak var checkInBtn: MyButton!
    @IBOutlet weak var updateBtn: MyButton!
    @IBOutlet weak var checkOutBtn: MyButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("CHECK IN BOTTOMSHEET")
        
        self.view.layer.shadowColor = UIColor.gray.cgColor
        self.view.layer.shadowOffset = CGSize(width: 0, height: -1)
        self.view.layer.shadowRadius = 5;
        self.view.layer.shadowOpacity = 0.5;
        
        remarkText.delegate = self
        remarkText.contentInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        remarkText.contentOffset = CGPoint(x: 0, y: -10)
        remarkText.text = remarkStr
        remarkText.textColor = UIColor.lightGray
        
        clearAttachFile()
        
        self.hideKeyboardWhenTappedAround()
        
        placeLabel.text = "CHECKIN_Place_Loading".localized()
        changeBtnDisplay()
        
        NotificationCenter.default.addObserver(self, selector: #selector(recieveMapInfo), name: Notification.Name("sendMapInfo"), object: nil)
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTimeDisplay), userInfo: nil, repeats: true)
        loadMap(withLoadingHUD: true)
        
        NotificationCenter.default.addObserver(self, selector:#selector(reloadMap),name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
    }
    
    @objc func reloadMap() {
        print("RELOAD CHECKIN")
        loadMap(withLoadingHUD: true)
    }
    
    @objc func loadMap(withLoadingHUD:Bool) {
        let parameters:Parameters = [:]
        loadRequest(method:.get, apiName:"attendance/getemplocation", authorization:true, showLoadingHUD:withLoadingHUD, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS MAP2\(json)")
                
                self.mapJSON = json["data"][0]["worklocation"]
                self.empstatus = json["data"][0]["profile"][0]["empstatus"].stringValue
                self.isWFH = json["data"][0]["iswfh"].boolValue
                self.isBioScan = json["data"][0]["isbioscan"].boolValue
                self.updateEmpStatus()
            }
        }
    }
    
    func updateEmpStatus() {
        switch self.empstatus {
        case ""://Show Check In
            self.mode = .checkIn
            
        case "checkin"://Show Check Out & Update
            self.mode = .update
            
        case "checkout"://Show Check In
            self.mode = .checkedOut
            
        default:
            break
        }
        self.changeBtnDisplay()
    }
    
    func changeBtnDisplay() {
        if inArea || isWFH {
            checkInBtn.enableBtn()
//            updateBtn.enableBtn()
//            checkOutBtn.enableBtn()
//            checkOutBtn.backgroundColor = .buttonRed
        }
        else
        {
            checkInBtn.disableBtn()
//            updateBtn.disableBtn()
//            checkOutBtn.disableBtn()
        }
        
        if mode == .checkIn {
            checkInBtn.isHidden = false
            updateBtn.isHidden = true
            checkOutBtn.isHidden = true
            
        }
        else if mode == .update {
            checkInBtn.isHidden = true
            updateBtn.isHidden = false
            checkOutBtn.isHidden = false
            
            updateBtn.enableBtn()//เปิด update นอกวงกลม
            checkOutBtn.enableBtn()//เปิด checkout นอกวงกลม
            checkOutBtn.backgroundColor = .buttonRed
        }
        else if mode == .checkedOut {
            checkInBtn.isHidden = false
            updateBtn.isHidden = true
            checkOutBtn.isHidden = true
            
            checkInBtn.disableBtn()//ปิด Checkin ไม่ให้วน
        }
    }
    
    @objc func updateTimeDisplay() {
        let todayDate = appStringFromDate(date: Date(), format: "EEE, dd MMM yyyy  HH:mm")
        dateLabel.text = todayDate
    }
    
    @objc func recieveMapInfo (notification: NSNotification){
        updateTimeDisplay()
        
        //placeLabel.text = notification.object as? String
        //print("Recieve User Location\(notification.object!)")
        
        if let userLocation = notification.object! as? CLLocation {
            userLat = userLocation.coordinate.latitude.description
            userLong = userLocation.coordinate.longitude.description
            
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(userLocation) { (placemarksArray, error) in
                //print("Place \(placemarksArray)\nError \(error)")
                if placemarksArray != nil {//(placemarksArray?.count)! > 0 {

                    let placemark = placemarksArray?.first
    //                let number = placemark!.subThoroughfare
    //                let bairro = placemark!.subLocality
    //                let street = placemark!.thoroughfare
                    
                    let placeName = placemark!.name
                    
                    if self.inArea {
                        
                    }
                    else{
                        self.placeLabel.text = placeName
                    }
                }
                else{
                    self.placeLabel.text = "CHECKIN_Place_Unknow".localized()
                }
            }
            
            if (mapJSON != nil) {
                if (mapJSON!.count > 0) {
                    for i in 0..<mapJSON!.count {
                        let markerArray = self.mapJSON![i]
                        let markerLocation = CLLocation(latitude: CLLocationDegrees(markerArray["latitude"].doubleValue), longitude: CLLocationDegrees(markerArray["longitude"].doubleValue))
                        let distance: CLLocationDistance = userLocation.distance(from: markerLocation)
                        print("distance = \(distance)")
                        
                        
                        if distance <= markerArray["radius"].doubleValue {
                            inArea = true
                            self.placeLabel.text = markerArray["worklocation_name"].stringValue
                        }
                        else{
                            inArea = false
                        }
                        self.changeBtnDisplay()
                    }
                }
            }
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == remarkStr {
            textView.text = ""
            textView.textColor = .textDarkGray
        }
        
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView.text == "" {
            textView.text = remarkStr
            textView.textColor = UIColor.lightGray
        }
        return true
    }
    
    @IBAction func attachmentAdd(_ sender: UIButton) {
        DispatchQueue.main.async {
            AttachmentHandler.shared.showAttachmentActionSheet(vc: self, allowEdit: false)
            AttachmentHandler.shared.imagePickedBlock = { (image) in
                /* get your image here */
                self.uploadImage.image = image
                self.uploadImage.isHidden = false
                self.uploadLabel.text = "image.jpg"
                self.addBtn.isHidden = true
                self.deleteBtn.isHidden = false
            }
        }
    }
    
    @IBAction func attachmentDelete(_ sender: UIButton) {
        clearAttachFile()
    }
    
    func clearAttachFile() {
        self.uploadImage.image = nil
        self.uploadImage.isHidden = true
        self.uploadLabel.text = "CHECKIN_Upload".localized()
        self.addBtn.isHidden = false
        self.deleteBtn.isHidden = true
    }
    
    @IBAction func btnClick(_ sender: UIButton) {
        
        if sender.tag == 1 {//CHECKIN
            if isBioScan {
                let context = LAContext()
                    var error: NSError?

                    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                        
                        let reason = "CHECKIN_TouchID".localized()

                        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                            [weak self] success, authenticationError in

                            DispatchQueue.main.async {
                                if success {
                                    print("SUCCESS")
                                    switch sender.tag {
                                    case 1://Check In
                                        self!.loadCheckIn(action: "in")
                                        
                                    case 2://Update
                                        self!.loadCheckIn(action: "update")
                                        
                                    case 3://Check Out
                                        self!.loadCheckIn(action: "out")
                                        
                                    default:
                                        break
                                    }
                                } else {
                                    // error
                                    print("CANCLE")
                                }
                            }
                        }
                    } else {
                        // no biometry
                        print("NO BIO")
                        confirmAsk(sender)
                    }
            }
            else{
                confirmAsk(sender)
            }
        }
        else {//UPDATE & CHECKOUT
            confirmAsk(sender)
        }
    }
    
    func confirmAsk(_ sender: UIButton) {
        var alert = UIAlertController()
        
//        //to change font of title and message.
//            let titleFont = [NSFontAttributeName: UIFont(name: "ArialHebrew-Bold", size: 18.0)!]
//            let messageFont = [NSFontAttributeName: UIFont(name: "Avenir-Roman", size: 12.0)!]
//
//            let titleAttrString = NSMutableAttributedString(string: "Title Here", attributes: titleFont)
//            let messageAttrString = NSMutableAttributedString(string: "Message Here", attributes: messageFont)
//
//            alertController.setValue(titleAttrString, forKey: "attributedTitle")
//            alertController.setValue(messageAttrString, forKey: "attributedMessage")
        
//        alertController.view.tintColor = UIColor.blue
//            alertController.view.backgroundColor = UIColor.black
//            alertController.view.layer.cornerRadius = 40
        
        alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .default, handler: { action in
            
        }))
        alert.actions.last?.titleTextColor = .textDarkGray
        
        switch sender.tag {
        case 1://Check In
            alert.title = "CHECKIN_Confirm_In".localized()
            //alert.message = "plaes make sure before..."
            alert.addAction(UIAlertAction(title: "CHECKIN_In".localized(), style: .default, handler: { action in
                self.loadCheckIn(action: "in")
            }))
            alert.actions.last?.titleTextColor = .themeColor
            
        case 2://Update
            alert.title = "CHECKIN_Confirm_Update".localized()
            alert.addAction(UIAlertAction(title: "CHECKIN_Update".localized(), style: .default, handler: { action in
                self.loadCheckIn(action: "update")
            }))
            alert.actions.last?.titleTextColor = .themeColor
            
        case 3://Check Out
            let alertSlide = alertService.alertSlide(title: "CHECKIN_Confirm_Out".localized(), slideTitle: "CHECKIN_Confirm_Swipe".localized()){
                self.loadCheckIn(action: "out")
            }
            present(alertSlide, animated: true)
            
//            alert.title = "CHECKIN_Confirm_Out".localized()
//            alert.addAction(UIAlertAction(title: "CHECKIN_Out".localized(), style: .default, handler: { action in
//                self.loadCheckIn(action: "out")
//            }))
//            alert.actions.last?.titleTextColor = .buttonRed
            
        default:
            break
        }
        
        alert.setColorAndFont()
        
        self.present(alert, animated: true)
    }
    
    
    func loadCheckIn(action:String) {
        
        let timeStamp = appStringFromDate(date: Date(), format: "yyyy-MM-dd HH:mm:ss")//2021-11-24 08:08:08
        
        var descriptionStr:String
        if remarkText.text == remarkStr {
            descriptionStr = ""
        }
        else{
            descriptionStr = remarkText.text
        }
        
        var parameters:Parameters = ["timestamp":timeStamp ,
                                     "source":"gps" ,//gps, qr
                                     "type":action ,//in, update, out
                                     "latitude":userLat ,
                                     "longitude":userLong ,
                                     "description":descriptionStr
        ]
        
        if uploadImage.image != nil {
            let base64Image = uploadImage.image!.convertImageToBase64String()
            parameters.updateValue(base64Image, forKey: "image")
        }
        //print(parameters)
        
        loadRequest(method:.post, apiName:"attendance/settimesheets", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS CHECK IN\(json)")
                
                self.clearAttachFile()
                
                self.remarkText.text = self.remarkStr
                self.remarkText.textColor = UIColor.lightGray
                
                self.submitSuccess()
                self.loadMap(withLoadingHUD: false)
                
                //self.empstatus = json["data"][0]["profile"][0]["empstatus"].stringValue
            }
        }
    }
}
