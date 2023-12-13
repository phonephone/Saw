//
//  Home.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 4/11/2564 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import SDWebImage
import OverlayContainer
import CoreLocation
import FirebaseMessaging
import Localize_Swift

class Home: UIViewController, OverlayContainerViewControllerDelegate, UIScrollViewDelegate {
    
    var profileJSON : JSON?
    var quickMenuJSON:JSON?
    var categoryJSON:JSON?
    var annoucementJSON:JSON?
    var recommendJSON:JSON?
    
    var announcementTimer: Timer?
    var announcementIndex: Int = 0
    
    @IBOutlet weak var categoryStack: UIStackView!
    
    @IBOutlet weak var annoucementStack: UIStackView!
    @IBOutlet weak var announcementPageControl: UIPageControl!
    
    @IBOutlet weak var recommendStack: UIStackView!
    
    var firstTime: Bool = true
    
    var showMood = false
    var popupShown = "0"
    
    var locationManager: CLLocationManager!
    
    @IBOutlet weak var sideMenuBtn: UIButton!
    @IBOutlet weak var userPic: MyButton!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userPosition: UILabel!
    
    @IBOutlet weak var qiuckActionView: UIView!
    @IBOutlet weak var quickBtn1: UIButton!
    @IBOutlet weak var quickBtn2: UIButton!
    @IBOutlet weak var quickBtn3: UIButton!
    @IBOutlet weak var quickBtn4: UIButton!
    @IBOutlet weak var quickLabel1: UILabel!
    @IBOutlet weak var quickLabel2: UILabel!
    @IBOutlet weak var quickLabel3: UILabel!
    @IBOutlet weak var quickLabel4: UILabel!
    
    @IBOutlet weak var myScrollView: UIScrollView!
    
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var announcementCollectionView: UICollectionView!
    @IBOutlet weak var recommendCollectionView: UICollectionView!
    
    var feelingView: UIView!
    @IBOutlet var feelingView1: UIView!
    @IBOutlet var feelingView2: UIView!
    @IBOutlet var feelingView3: UIView!
    @IBOutlet var feelingBtn1: [UIButton]!
    @IBOutlet var feelingBtn2: [UIButton]!
    @IBOutlet var feelingBtn3: [UIButton]!
    @IBOutlet var feelingBtn4: [UIButton]!
    
    @IBOutlet var feelingTitle1: [UILabel]!
    @IBOutlet var feelingTitle2: [UILabel]!
    @IBOutlet var feelingTitle3: [UILabel]!
    @IBOutlet var feelingTitle4: [UILabel]!
    
    @IBOutlet var popupView: UIView!
    @IBOutlet weak var popupPic: UIImageView!
    @IBOutlet weak var popupTitle: UILabel!
    @IBOutlet weak var popupDescription: UILabel!
    @IBOutlet weak var popupXBtn: UIButton!
    @IBOutlet weak var popupDoneBtn: UIButton!
    
    var blurView : UIVisualEffectView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadHome()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("HOME")
        
        myScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        
        // CollectionView
        categoryStack.isHidden = true
        annoucementStack.isHidden = true
        recommendStack.isHidden = true
        announcementPageControl.isHidden = true
        
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        categoryCollectionView.backgroundColor = .clear
        
        recommendCollectionView.delegate = self
        recommendCollectionView.dataSource = self
        
        announcementCollectionView.delegate = self
        announcementCollectionView.dataSource = self
        //self.announcementCollectionView.backgroundColor = .clear
        
        announcementPageControl.currentPage = 0
        
        // Register CollectionView Cell
        //self.announcementCollectionView.register(CategoryCell.nib, forCellReuseIdentifier: categoryCell.identifier)
        //self.announcementCollectionView.register(AnnouncementCell.nib, forCellReuseIdentifier: announcementCell.identifier)
        
        blurView = blurViewSetup()
        //        let feelingWidth = self.view.bounds.width*0.9
        //        let feelingHeight = feelingWidth*0.5
        //feelingView.frame = CGRect(x: (self.view.bounds.width-feelingWidth)/2, y: qiuckActionView.frame.origin.y, width: feelingWidth, height: feelingHeight)
        //feelingView.center = qiuckActionView.center
        
        let randomInt = Int.random(in: 0...2)
        switch randomInt {
        case 0:
            feelingView = feelingView1
            feelingView.frame = CGRect(x: 0, y: 180, width: 388, height: 190)
        case 1:
            feelingView = feelingView2
            feelingView.frame = CGRect(x: 0, y: 0, width: 300, height: 512)
            feelingView.center.y = self.view.center.y
        case 2:
            feelingView = feelingView3
            feelingView.frame = CGRect(x: 0, y: 180, width: 300, height: 308)
            
        default:
            break
        }
        feelingView.center.x = self.view.center.x
        
        let popupWidth = self.view.bounds.width*0.9
        let popupHeight = popupWidth*1.4
        popupView.frame = CGRect(x: (self.view.bounds.width-popupWidth)/2, y: (self.view.bounds.height/2)-(popupHeight/2), width: popupWidth, height: popupHeight)
        //popupView.frame = CGRect(x: (self.view.bounds.width-popupWidth)/2, y: qiuckActionView.frame.origin.y, width: popupWidth, height: popupHeight)
        
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        
        //        Messaging.messaging().token { token, error in
        //          if let error = error {
        //            print("Error fetching FCM registration token: \(error)")
        //          } else if let token = token {
        //            print("FCM registration token: \(token)")
        //          }
        //        }
    }
    
    @IBAction func leftMenuShow(_ sender: UIButton) {
        self.sideMenuController!.revealMenu()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        stopAutoScroll()
    }
    
    func loadHome() {
        stopAutoScroll()
        //announcementIndex = 0
        
        var parameters:Parameters = [:]
        let fcmToken = UserDefaults.standard.string(forKey:"fcm_token")
        if  fcmToken != nil {
            parameters = ["fcmtoken":fcmToken!]
        }
        //print(parameters)
        
        loadRequest(method:.post, apiName:"auth/gethome", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ [self] result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS HOME\(json)")
                
                self.profileJSON = json["data"][0]["profile"][0]
                self.userPic.sd_setImage(with: URL(string:self.profileJSON!["profile_photo"].stringValue), for: .normal, placeholderImage: UIImage(named: "logo_circle"))
                self.userName.text = "\(self.profileJSON![self.firstNameKey()].stringValue) \(self.profileJSON![self.lastNameKey()].stringValue)"// as AnyObject as? String
                self.userPosition.text = self.profileJSON!["designation_name"].stringValue
                
                let badgeNo = json["data"][0]["countnoti"].stringValue
                if badgeNo == "0" {
                    self.tabBarController!.tabBar.items!.last!.badgeValue = nil
                }
                else{
                    self.tabBarController!.tabBar.items!.last!.badgeValue = badgeNo
                }
                
                self.showMood = false
                if json["data"][0]["todaymood"] == "" {
                    showMood = true
                }
                
                if json["data"][0]["ispopup"].stringValue != popupShown {
                    self.popupPic.sd_setImage(with: URL(string:json["data"][0]["popup"][0]["image_url"].stringValue), placeholderImage: UIImage(named: "xxx"))
                    self.popupTitle.text = json["data"][0]["popup"][0]["title"].stringValue
                    self.popupDescription.text = json["data"][0]["popup"][0]["detail"].stringValue
                    self.popIn(popupView: self.blurView)
                    self.popIn(popupView: self.popupView)
                    popupShown = json["data"][0]["ispopup"].stringValue
                }
                else if showMood {
                    self.popIn(popupView: self.blurView)
                    self.popIn(popupView: self.feelingView)
                }
                
                self.quickMenuJSON = json["data"][0]["quickmenu"]
                quickBtn1.sd_setImage(with: URL(string: self.quickMenuJSON![0]["menu_image_url"].stringValue), for: .normal, placeholderImage: UIImage(named: "logo_circle"))
                quickBtn2.sd_setImage(with: URL(string: self.quickMenuJSON![1]["menu_image_url"].stringValue), for: .normal, placeholderImage: UIImage(named: "logo_circle"))
                quickBtn3.sd_setImage(with: URL(string: self.quickMenuJSON![2]["menu_image_url"].stringValue), for: .normal, placeholderImage: UIImage(named: "logo_circle"))
                quickBtn4.sd_setImage(with: URL(string: self.quickMenuJSON![3]["menu_image_url"].stringValue), for: .normal, placeholderImage: UIImage(named: "logo_circle"))
                
                quickBtn1.imageView!.contentMode = .scaleAspectFit
                quickBtn2.imageView!.contentMode = .scaleAspectFit
                quickBtn3.imageView!.contentMode = .scaleAspectFit
                quickBtn4.imageView!.contentMode = .scaleAspectFit
                
                quickLabel1.text = self.quickMenuJSON![0][menuNameKey()].stringValue
                quickLabel2.text = self.quickMenuJSON![1][menuNameKey()].stringValue
                quickLabel3.text = self.quickMenuJSON![2][menuNameKey()].stringValue
                quickLabel4.text = self.quickMenuJSON![3][menuNameKey()].stringValue
                
                self.categoryJSON = json["data"][0]["mainmenu"]
                self.annoucementJSON = json["data"][0]["announcement"]
                self.recommendJSON = json["data"][0]["reward_banner"]
                
                self.categoryCollectionView.reloadData()
                self.announcementCollectionView.reloadData()
                self.recommendCollectionView.reloadData()
                
                if self.categoryJSON!.count > 0 {
                    categoryStack.isHidden = false
                }
                else{
                    categoryStack.isHidden = true
                }
                
                if self.annoucementJSON!.count > 0 {
                    startAutoScroll()
                    announcementPageControl.numberOfPages = annoucementJSON!.count
                    if firstTime {
                        self.announcementCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: true)
                        firstTime = false
                    }
                    annoucementStack.isHidden = false
                    announcementPageControl.isHidden = false
                }
                else{
                    annoucementStack.isHidden = true
                    announcementPageControl.isHidden = true
                }
                
                if self.recommendJSON!.count > 0 && json["data"][0]["isreward"] == "1" {
                    recommendStack.isHidden = false
                }
                else{
                    recommendStack.isHidden = true
                }
                
                self.view.bringSubviewToFront(announcementPageControl)
                
                if json["data"][0]["privacy_policy_accept"] == "0" {
                    let vc = UIStoryboard.loginStoryBoard.instantiateViewController(withIdentifier: "PrivacyPolicy") as! PrivacyPolicy
                    vc.agreementShow = true
                    self.navigationController!.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    @IBAction func feelingClick(_ sender: UIButton) {
        clearFeeling()
        
        switch sender.tag {
        case 1:
            setFeelingBorder(button: feelingBtn1 ,title: feelingTitle1)
            submitMood(moodID: "1")
        case 2:
            setFeelingBorder(button: feelingBtn2 ,title: feelingTitle2)
            submitMood(moodID: "2")
        case 3:
            setFeelingBorder(button: feelingBtn3 ,title: feelingTitle3)
            submitMood(moodID: "3")
        case 4:
            setFeelingBorder(button: feelingBtn4 ,title: feelingTitle4)
            submitMood(moodID: "4")
        default:
            break
        }
    }
    
    func clearFeeling() {
        clearFeelingBorder(button: feelingBtn1 ,title: feelingTitle1)
        clearFeelingBorder(button: feelingBtn2 ,title: feelingTitle2)
        clearFeelingBorder(button: feelingBtn3 ,title: feelingTitle3)
        clearFeelingBorder(button: feelingBtn4 ,title: feelingTitle4)
    }
    
    func setFeelingBorder(button: [UIButton], title: [UILabel]) {
        for item in button {
            item.layer.cornerRadius = item.frame.size.width/2
            item.layer.borderColor = UIColor.textPointGold.cgColor
            item.layer.borderWidth = 4
        }
        
        for item in title {
            item.textColor = .textPointGold
        }
    }
    
    func clearFeelingBorder(button: [UIButton], title: [UILabel]) {
        for item in button {
            item.layer.borderWidth = 0
        }
        
        for item in title {
            item.textColor = .textDarkGray
        }
    }
    
    func submitMood(moodID:String) {
        print(moodID)
        let parameters:Parameters = ["mood_id":moodID]
        loadRequest(method:.post, apiName:"auth/setmoodlog", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS SETMOOD\(json)")
                
                self.popOut(popupView: self.blurView)
                self.popOut(popupView: self.feelingView)
                self.clearFeeling()
            }
        }
    }
    
    @IBAction func popupClose(_ sender: UIButton) {
        self.popOut(popupView: self.popupView)
        if showMood {
            self.popIn(popupView: self.feelingView)
        }
        else{
            self.popOut(popupView: self.blurView)
        }
    }
    
    @IBAction func profileClick(_ sender: UIButton) {
        let vc = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "Profile") as! Profile
        vc.whoMode = .Me
        vc.userID = self.profileJSON!["user_id"].stringValue
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func quickMenuClick(_ sender: UIButton) {
        let quickMenuID = quickMenuJSON![sender.tag]["menu_key_id"].stringValue
        switch quickMenuID {
        case "QUICK_CHECK_IN"://Check In
            if CLLocationManager.locationServicesEnabled() {
                switch CLLocationManager.authorizationStatus() {
                case .notDetermined, .restricted, .denied:
                    print("No access")
                    let alert = UIAlertController(title: "HOME_Location_Denied".localized(), message: "HOME_Location_Allow".localized(), preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { action in
                        
                    }))
                    alert.actions.last?.titleTextColor = .buttonRed
                    
                    alert.addAction(UIAlertAction(title: "GO_Setting".localized(), style: .default, handler: { action in
                        
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                    }))
                    alert.actions.last?.titleTextColor = .themeColor
                    
                    self.present(alert, animated: true)
                    
                case .authorizedAlways, .authorizedWhenInUse:
                    print("Access")
                    let mainboard = UIStoryboard.attendanceStoryBoard
                    let mapsController = mainboard.instantiateViewController(withIdentifier: "CheckInMap") as! CheckInMap
                    let sheetController = mainboard.instantiateViewController(withIdentifier: "CheckIn") as! CheckIn
                    
                    let containerController = OverlayContainerViewController(style: .flexibleHeight)
                    containerController.delegate = self
                    containerController.viewControllers = [
                        mapsController,
                        sheetController
                    ]
                    
                    self.navigationController!.pushViewController(containerController, animated: true)
                    
                @unknown default:
                    break
                }
            } else {
                print("Location Not enabled")
                let alert = UIAlertController(title: "HOME_Location_Disable".localized(), message: "HOME_Location_Check".localized(), preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK".localized(), style: .default, handler: { action in
                    //UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                }))
                alert.actions.last?.titleTextColor = .themeColor
                
                self.present(alert, animated: true)
            }
            
        case "QUICK_ATTENDANCE"://Attendance
            let vc = UIStoryboard.attendanceStoryBoard.instantiateViewController(withIdentifier: "Attendance") as! Attendance
            self.navigationController!.pushViewController(vc, animated: true)
        case "QUICK_LEAVE_REQUEST"://Leaves
            let vc = UIStoryboard.attendanceStoryBoard.instantiateViewController(withIdentifier: "Leave") as! Leave
            self.navigationController!.pushViewController(vc, animated: true)
        case "QUICK_OT"://OT
            let vc = UIStoryboard.attendanceStoryBoard.instantiateViewController(withIdentifier: "OT") as! OT
            self.navigationController!.pushViewController(vc, animated: true)
            
        default:
            break
        }
    }
    
    enum OverlayNotch: Int, CaseIterable {
        case medium//minimum, medium, maximum
    }
    
    func numberOfNotches(in containerViewController: OverlayContainerViewController) -> Int {
        return OverlayNotch.allCases.count
    }
    
    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        heightForNotchAt index: Int,
                                        availableSpace: CGFloat) -> CGFloat {
        switch OverlayNotch.allCases[index] {
            //            case .maximum:
            //                return availableSpace * 3 / 4
        case .medium:
            if UIDevice.current.hasNotch
            {//iphone X or upper
                return availableSpace * 0.5
            }
            else{
                return availableSpace * 0.5
            }
            
            //            case .minimum:
            //                return availableSpace * 1 / 4
        }
    }
    
    @IBAction func seeAllReward(_ sender: UIButton) {
        let vc = UIStoryboard.rewardStoryBoard.instantiateViewController(withIdentifier: "RewardList") as! RewardList
        vc.mode = .promotion
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
}//end ViewController

// MARK: - UICollectionViewDataSource

extension Home: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoryCollectionView && categoryJSON != nil {//Category
            return categoryJSON!.count
        }
        else if collectionView == announcementCollectionView && annoucementJSON != nil {//Announcement
            return annoucementJSON!.count
        }
        else if collectionView == recommendCollectionView && recommendJSON != nil {//Recommend
            return recommendJSON!.count
        }
        else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoryCollectionView {//Category
            
            let cellArray = self.categoryJSON![indexPath.item]
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"CategoryCell", for: indexPath) as! CategoryCell
            
            cell.cellImage.sd_setImage(with: URL(string:cellArray["menu_image_url"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
            //cell.menuImage.setImageColor(color: .themeColor)
            
            cell.cellTitle.text = cellArray[menuNameKey()].stringValue
            
            return cell
        }
        else if collectionView == announcementCollectionView {//Announcement
            
            let cellArray = self.annoucementJSON![indexPath.item]
            
            //let cell = collectionView.dequeueReusableCell(withReuseIdentifier: announcementCell.identifier, for: indexPath) as! announcementCell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnnouncementCell", for: indexPath) as! AnnouncementCell
            
            cell.setRoundAndShadow()
            cell.cellImage.sd_setImage(with: URL(string:cellArray["banner_url"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
            
            return cell
        }
        else if collectionView == recommendCollectionView {//Recommend
            
            let cellArray = self.recommendJSON![indexPath.item]
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"PromotionCell", for: indexPath) as! CategoryCell
            
            cell.setRoundAndShadow()
            cell.cellImage.sd_setImage(with: URL(string:cellArray["banner_url"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
            cell.cellTitle.text = cellArray["name_title"].stringValue
            cell.cellDescription.text = cellArray["desc"].stringValue
            
            return cell
        }
        else {
            return UICollectionViewCell()
        }
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension Home: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let viewWidth = collectionView.frame.width-20
        let viewHeight = viewWidth/329*142
        //viewHeight*2.33
        
        if collectionView == categoryCollectionView {//Category
            return CGSize(width: 72 , height: collectionView.frame.height)
        }
        else if collectionView == announcementCollectionView {//Announcement
            return CGSize(width: viewWidth , height: viewHeight-8)
        }
        else if collectionView == recommendCollectionView {//Recommend
            return CGSize(width: 292 , height: collectionView.frame.height-8)
        }
        else {
            return CGSize()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == categoryCollectionView {//Category
            return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20) //.zero
        }
        else if collectionView == announcementCollectionView {//Announcement
            return UIEdgeInsets(top: 4, left: 20, bottom: 4, right: 20) //.zero
        }
        else if collectionView == recommendCollectionView {//Recommend
            return UIEdgeInsets(top: 4, left: 20, bottom: 4, right: 20) //.zero
        }
        else {
            return UIEdgeInsets()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == categoryCollectionView {//Category
            return 5
        }
        else if collectionView == announcementCollectionView {//Announcement
            return 10
        }
        else if collectionView == recommendCollectionView {//Recommend
            return 15
        }
        else {
            return CGFloat()
        }
    }
}

// MARK: - UICollectionViewDelegate

extension Home: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoryCollectionView {//Category
            let cellArray = self.categoryJSON![indexPath.item]
            switch cellArray["menu_key_id"].stringValue {
            case "MAIN_EDOCUMENT":
                let vc = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "EDocMenu") as! EDocMenu
                self.navigationController!.pushViewController(vc, animated: true)
                
            case "MAIN_REPORT":
                let vc = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "ReportMenu") as! ReportMenu
                self.navigationController!.pushViewController(vc, animated: true)
                
            case "MAIN_WARNING":
                let vc = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "Warning") as! Warning
                self.navigationController!.pushViewController(vc, animated: true)
                
            case "MAIN_WARNING_HEAD":
                let vc = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "WarningHead") as! WarningHead
                self.navigationController!.pushViewController(vc, animated: true)
                
            case "MAIN_SWAP":
                let vc = UIStoryboard.attendanceStoryBoard.instantiateViewController(withIdentifier: "SwapShift") as! SwapShift
                vc.myName = userName.text
                vc.myUserID = profileJSON!["user_id"].stringValue
                self.navigationController!.pushViewController(vc, animated: true)
                
//            case "MAIN_MORE":
//                let vc = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "MoreMenu") as! MoreMenu
//                self.navigationController!.pushViewController(vc, animated: true)
                
            default:
                let cellArray = self.categoryJSON![indexPath.item]
                
                let url = cellArray["link_url"].stringValue
                if url.isEmpty {
                    showComingSoon()
                }
                else {
                    let vc = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "Web") as! Web
                    vc.titleString = cellArray["menu_name_en"].stringValue
                    vc.webUrlString = url
                    self.navigationController!.pushViewController(vc, animated: true)
                }
            }
        }
        else if collectionView == announcementCollectionView {//Announcement
            let cellArray = self.annoucementJSON![indexPath.item]
            
            let vc = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "Web") as! Web
            vc.titleString = "HOME_Announcement".localized()
            vc.webUrlString = cellArray["content_url"].stringValue
            self.navigationController!.pushViewController(vc, animated: true)
        }
        else if collectionView == recommendCollectionView {//Recommend
            let cellArray = self.recommendJSON![indexPath.item]
            
            if cellArray["reward_id"] == "0" {
                //Do nothing
            }
            else{
                let vc = UIStoryboard.rewardStoryBoard.instantiateViewController(withIdentifier: "RewardDetail") as! RewardDetail
                vc.mode = .redeem
                vc.rewardID = cellArray["reward_id"].stringValue
                self.navigationController!.pushViewController(vc, animated: true)
            }
        }
    }
    
    @objc func startAutoScroll() {
        announcementTimer?.invalidate()
        announcementTimer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(self.autoScrollAnnouncement), userInfo: nil, repeats: true)
    }
    
    func stopAutoScroll() {
        announcementTimer?.invalidate()
    }
    
    @objc func autoScrollAnnouncement() {
        print("auto")
        if announcementIndex < announcementCollectionView.numberOfItems(inSection: 0)-1 {
            announcementIndex += 1
        }
        else{
            announcementIndex = 0
        }
        let indexPath = IndexPath(item: announcementIndex, section: 0)
        self.announcementCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.tag == 2{
            let pageIndex = round(scrollView.contentOffset.x/scrollView.frame.width)
            announcementPageControl.currentPage = Int(pageIndex)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView.tag == 2{
            stopAutoScroll()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        for cell in announcementCollectionView.visibleCells {
//            let indexPath = announcementCollectionView.indexPath(for: cell)
//            print(indexPath)
//        }
        if scrollView.tag == 2{
            let visibleCells = announcementCollectionView.indexPathsForVisibleItems.sorted()
            var indexPath:IndexPath?
            
            if scrollView.panGestureRecognizer.translation(in: scrollView.superview).x > 0 {
                print("left")
                indexPath = visibleCells.first
            } else {
                print("right")
                indexPath = visibleCells.last
            }
            
            announcementIndex = indexPath!.row
            self.announcementCollectionView.scrollToItem(at: indexPath!, at: .centeredHorizontally, animated: true)
            
            perform(#selector(startAutoScroll), with: nil, afterDelay: 4)
        }
    }
}
