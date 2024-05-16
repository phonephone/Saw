//
//  RoundRect.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 3/11/2564 BE.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import SideMenuSwift
import Localize_Swift

// MARK: - Color & Font & Value
extension UIColor {
    static let themeColor = UIColor(named: "Main_Theme_1")!
    static let textDarkGray = UIColor(named: "Text_Dark_Gray")!
    static let textGray = UIColor(named: "Text_Gray")!
    static let textGray1 = UIColor(named: "Text_Gray_1")!
    static let textPointGold = UIColor(named: "Text_Point_Gold")!
    static let buttonRed = UIColor(named: "Btn_Red")!
    static let buttonGreen = UIColor(named: "Btn_Green")!
    static let buttonDisable = UIColor(named: "Btn_Disable")!
    static let bgLightGray = UIColor(named: "Bg_Light_Gray")!
    static let headerGradient1 = UIColor(named: "Header_1")!
    static let headerGradient2 = UIColor(named: "Header_2")!
    
    static func customThemeColor() -> UIColor {
        let iconColor = UserDefaults.standard.loadcolor(forKey: "iconColor")
        return iconColor ?? .themeColor
    }
}

extension UIFont {
    class func Roboto_Medium(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Roboto-Medium", size: size)!
    }
    class func Roboto_Regular(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Roboto-Regular", size: size)!
    }
    
    class func Kanit_Medium(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Kanit-Medium", size: size)!
    }
    class func Kanit_Regular(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Kanit-Regular", size: size)!
    }
}

extension UIStoryboard  {
    static let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
    static let loginStoryBoard = UIStoryboard(name: "Login", bundle: nil)
    static let attendanceStoryBoard = UIStoryboard(name: "Attendance", bundle: nil)
    static let rewardStoryBoard = UIStoryboard(name: "Reward", bundle: nil)
    static let eDocumentStoryBoard = UIStoryboard(name: "EDocument", bundle: nil)
    static let settingStoryBoard = UIStoryboard(name: "Setting", bundle: nil)
    static let alertStoryBoard = UIStoryboard(name: "Alert", bundle: nil)
    static let moodStoryBoard = UIStoryboard(name: "Mood", bundle: nil)
}

extension Bundle {
    public var appName: String { getInfo("CFBundleName")  }
    public var displayName: String {getInfo("CFBundleDisplayName")}
    public var language: String {getInfo("CFBundleDevelopmentRegion")}
    public var identifier: String {getInfo("CFBundleIdentifier")}
    public var copyright: String {getInfo("NSHumanReadableCopyright")}
    public var appBuild: String { getInfo("CFBundleVersion") }
    public var appVersionLong: String { getInfo("CFBundleShortVersionString") }
    public var appVersionShort: String { getInfo("CFBundleShortVersion") }
    
    fileprivate func getInfo(_ str: String) -> String { infoDictionary?[str] as? String ?? "⚠️" }
}


// MARK: - UIDevice
extension UIDevice {
    /// Returns `true` if the device has a notch
    var hasNotch: Bool {
        guard #available(iOS 11.0, *), let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else { return false }
        if UIDevice.current.orientation.isPortrait {
            return window.safeAreaInsets.top >= 44
        } else {
            return window.safeAreaInsets.left > 0 || window.safeAreaInsets.right > 0
        }
    }
}

// MARK: - UINavigationController
extension UINavigationController {
    
    func setStatusBarColor(backgroundColor: UIColor? = nil) {

        var statusBarFrame: CGRect
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.first
            let topPadding = window?.safeAreaInsets.top
            statusBarFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: topPadding ?? 0.0)
        } else {
            statusBarFrame = UIApplication.shared.statusBarFrame
        }
        
        let statusBarView = UIView(frame: statusBarFrame)
        
        if (backgroundColor != nil) {
            statusBarView.backgroundColor = backgroundColor
        }
        else{
            let gradient1 = UserDefaults.standard.loadcolor(forKey: "gradientColor_1")
            statusBarView.backgroundColor = gradient1 ?? UIColor.themeColor//backgroundColor
        }
        
        view.addSubview(statusBarView)
    }
    
    func popToViewController(ofClass: AnyClass, animated: Bool = true) {
        if let vc = viewControllers.last(where: { $0.isKind(of: ofClass) }) {
            popToViewController(vc, animated: animated)
        }
    }
    
    func removeAnyViewControllers(ofKind kind: AnyClass)
    {
        self.viewControllers = self.viewControllers.filter { !$0.isKind(of: kind)}
    }
    
    func containsViewController(ofKind kind: AnyClass) -> Bool
    {
        return self.viewControllers.contains(where: { $0.isKind(of: kind) })
    }
}

// MARK: - UITabBarController
extension UITabBarController {
    
    func setStatusBarColor(backgroundColor: UIColor? = nil) {

        var statusBarFrame: CGRect
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.first
            let topPadding = window?.safeAreaInsets.top
            statusBarFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: topPadding ?? 0.0)
        } else {
            statusBarFrame = UIApplication.shared.statusBarFrame
        }
        
        let statusBarView = UIView(frame: statusBarFrame)
        
        if (backgroundColor != nil) {
            statusBarView.backgroundColor = backgroundColor
        }
        else{
            let gradient1 = UserDefaults.standard.loadcolor(forKey: "gradientColor_1")
            statusBarView.backgroundColor = gradient1 ?? UIColor.themeColor//backgroundColor
        }
        
        view.addSubview(statusBarView)
    }
}

// MARK: - UIViewController
extension UIViewController {
    
    func embed(_ viewController:UIViewController, inView view:UIView){
        viewController.willMove(toParent: self)
        viewController.view.frame = view.bounds
        view.addSubview(viewController.view)
        self.addChild(viewController)
        viewController.didMove(toParent: self)
    }
    
    func unEmbed(_ viewController:UIViewController){
        viewController.willMove(toParent: nil)
        viewController.removeFromParent()
        viewController.didMove(toParent: nil)
    }
    
    func switchToLogin() {
        if self is Home {
            //not logout from Home request
        }else{
            let vc = UIStoryboard.loginStoryBoard.instantiateViewController(withIdentifier: "Login")
            self.navigationController!.setViewControllers([vc], animated: true)
        }
    }
    
    func switchToHome(pushTo: String? = nil) {
        //let vc = UIStoryboard.init(name:"Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TabBar")
        //self.navigationController!.setViewControllers([vc], animated: true)
        
        var tabBarArray:[UIViewController] = []
        let parameters:Parameters = [:]
        loadRequest(method:.get, apiName:"auth/getappsetting", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                //ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                //print("SUCCESS SETTIING\(json)")
                
                let tabBarJSON = json["data"][0]["quickmenu"]
                
                for menu in tabBarJSON {
                    let menuKey = menu.1["menu_key_id"].stringValue
                    
                    if menuKey == "BOTTOM_HOME" {
                        let vc = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "Home") as! Home
                        tabBarArray.append(vc)
                    }
                    else if menuKey == "BOTTOM_GIFT" {
                        let vc = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "Reward") as! Reward
                        tabBarArray.append(vc)
                    }
                    else if menuKey == "BOTTOM_SEARCH" {
                        let vc = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "DirectoryList") as! DirectoryList
                        
//                        if json["data"][0]["is_birthday"].stringValue == "1" {
//                            vc.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "tabbar_birthday"), selectedImage: UIImage(named: "tabbar_birthday"))
//                        }
                        
                        tabBarArray.append(vc)
                    }
                    else if menuKey == "BOTTOM_DATE" {
                        let vc = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "CalendarList") as! CalendarList
                        tabBarArray.append(vc)
                    }
                    else if menuKey == "BOTTOM_NOTI" {
                        let vc = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "NotificationAll") as! NotificationAll
                        tabBarArray.append(vc)
                    }
                }
                
                let menuViewController = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "SideMenu")
                
                let tabBar = UITabBarController()
                tabBar.viewControllers = tabBarArray
                //tabBar.selectedIndex = 0
                
                //let contentViewController = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "TabBar")
                
                let screenSize: CGRect = UIScreen.main.bounds
                
                SideMenuController.preferences.basic.menuWidth = screenSize.width*0.8
                SideMenuController.preferences.basic.position = .above
                SideMenuController.preferences.basic.direction = .left
                SideMenuController.preferences.basic.enablePanGesture = true
                SideMenuController.preferences.basic.supportedOrientations = .portrait
                SideMenuController.preferences.basic.shouldRespectLanguageDirection = true
                
                //self.navigationController!.setViewControllers([SideMenuController(contentViewController: tabBar, menuViewController: menuViewController)], animated: true)
                
                //PUSH from notifocation
                if pushTo == nil {
                    self.navigationController!.setViewControllers([SideMenuController(contentViewController: tabBar, menuViewController: menuViewController)], animated: true)
                }
                else{
                    switch pushTo {
                    case "xxx":
                        let vc = UIStoryboard.attendanceStoryBoard.instantiateViewController(withIdentifier: "Approve") as! Approve
                        vc.approveType = .leave
                        self.navigationController!.setViewControllers([SideMenuController(contentViewController: tabBar, menuViewController: menuViewController),vc], animated: true)
                        
                    default:
                        break
                    }
                    
                }
            }
        }
    }
    
    func logOut() {
        UserDefaults.standard.removeObject(forKey:"access_token")
        UserDefaults.standard.removeObject(forKey:"passCode")
        UserDefaults.standard.removeObject(forKey:"fcm_token")
        
        UserDefaults.standard.removeObject(forKey:"gradientColor_1")
        UserDefaults.standard.removeObject(forKey:"gradientColor_2")
        UserDefaults.standard.removeObject(forKey:"iconColor")
        
        //Remove all keyss
        //        if let appDomain = Bundle.main.bundleIdentifier {
        //            UserDefaults.standard.removePersistentDomain(forName: appDomain)
        //        }
        
        self.switchToLogin()
    }
    
    func loadingHUD() {
        ProgressHUD.show("Loading".localized(), interaction: false)
    }
    
    func submitSuccess() {
        ProgressHUD.showSuccess("Successful".localized(), interaction: false)
    }
    
    func showErrorNoData() {
        ProgressHUD.imageError = .remove
        ProgressHUD.showError("Empty".localized())
    }
    
    func showComingSoon() {
        ProgressHUD.imageError = UIImage(named:"coming_soon")!
        ProgressHUD.showError("Coming_Soon".localized())
    }
    
    func loadRequest(method:HTTPMethod, apiName:String, authorization:Bool, showLoadingHUD:Bool, dismissHUD:Bool, parameters:Parameters, completion: @escaping (AFResult<AnyObject>) -> Void) {
        
        if showLoadingHUD == true
        {
            loadingHUD()
        }
        
        let baseURL = "https://sawgrow.com/api/v2/"
        let fullURL = baseURL+apiName
        
        var headers: HTTPHeaders
        if authorization == true {
            let accessToken = UserDefaults.standard.string(forKey:"access_token")
            headers = ["Authorization": "Bearer \(accessToken!)",
                       "Accept": "application/json",
                       "Lang": "Formatter_Locale".localized()
            ]
            
            //V2 TEST (P'Dui ID)
            //headers = ["Authorization": "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6IlV6MVBNV3IzZVFYaXVHRl9XVnd1TWJvM0t5Y2h5bGlQOGdCZE5aZUJQdXMiLCJjb20iOiJxdWRIZmZLUXhwWG9sdUFZdC1OZ3NRX0Q3SEVuQzZyQVpXWmJQYW55RlBNIiwiaWF0IjoxNjYwMjEyMDY0LCJleHAiOjI2NjAyMTIwNjN9.-1_ZRDlu6mCQL6e1eWXoCgNJW0fsdqR99m61rw0ZlNg", "Accept": "application/json","Lang": "Formatter_Locale".localized()]
            
            //MANAGER TEST (P'Ae ID)
            //headers = ["Authorization": "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6InNVOGloc2xKQ3VBT3Vzc2t4OGxaVVJNWFl2XzZ2V1BGNThpSjdWOEJwVk0iLCJjb20iOiJyeXVxeUJFTkFwZ2lwbUV2ZFE2TWRoYnZ5RWkzWVJEd1ZXY2JFODNCa2FZIiwiaWF0IjoxNjc1MDU2Mzg4LCJleHAiOjI2NzUwNTYzODd9.ZZSIjKpJKhD2_fTEJiWYpgpjFfQT-d0DrR0l1DMLV9s", "Accept": "application/json","Lang": "Formatter_Locale".localized()]
            
            //BEURAZ TEST
            //headers = ["Authorization": "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Ii1XemFFOHZlY1ZPdzlFX0ZZQ1lGMXp3SFVoTVFsUXJiR21wYkg1MEpZZ3MiLCJjb20iOiJHZG9WMDdEbFFSXzFvSEJSWmx6Z1RtTjBYYkJucHNDYWFFektrRS1NU0FNIiwiaWF0IjoxNjQ1NzA2MTk4LCJleHAiOjI2NDU3MDYxOTd9.Plmqc9JEVN3zF0Sdf8KXX4kwpVQUzR6BDNTTShh7gdc", "Accept": "application/json","Lang": "Formatter_Locale".localized()]
            
            //SWAP TEST (P'Ball ID)
            //headers = ["Authorization": "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6ImhDanNsaVliSFhxdkpoczJGQmpkS1c5VW1qUzBFeEFGcmdXWlk0WXVEWFkiLCJjb20iOiI3a1FweDFaMnVoMFh1Qk5PMk50aExnUjAtQUc5UVJhZG11V2lYR0tMUi00IiwiaWF0IjoxNjc0OTk4ODE5LCJleHAiOjI2NzQ5OTg4MTh9.oCovFbSbeFvuyB9h8qxDLBgSN97IkEJHcbUZs5k3Q00", "Accept": "application/json","Lang": "Formatter_Locale".localized()]
            
            //HR TEST (N'Mo ID)
            //headers = ["Authorization": "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6IjlUQU9zOHQybzc3ckZRNWJCUlhrQUt6bks1dW9DT21mWGx6Vlc2N0RpUzQiLCJjb20iOiJhNkUwWlNSRmNZUFpyZTM4MC1JcmlFcm9sdU9SbGdoV0k4SFVwMGpfU3BjIiwiaWF0IjoxNjkzNDkxMTU4LCJleHAiOjI2OTM0OTExNTd9.4UyOavbIWT-ONCKXrVPvw86D_Z0ZpGZyjADddo7NPyw", "Accept": "application/json","Lang": "Formatter_Locale".localized()]
            
            //P'Sorn
            //headers = ["Authorization": "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6IlJkWEt5NzlaV1NPb2xDMHlrMUYyOS1oSGN1ZmgySXNacm10Zm92b1ViOFkiLCJjb20iOiJBU2VfelFDNGNoSndiS3dQenF0aEVXZmdLVDc4Qkdva0k3YVpZTjFYWHdBIiwiaWF0IjoxNjkwNDI1NzA0LCJleHAiOjI2OTA0MjU3MDN9.QLrjMcTjg0uwmC270JLLdyO_2ywX066n_mCUF8rN0lw", "Accept": "application/json","Lang": "Formatter_Locale".localized()]
        }
        else{
            headers = ["Accept": "application/json",
                       "Lang": "Formatter_Locale".localized()
            ]
        }
        //print("HEADER = \(headers)")
        //print("PARAM = \(parameters)")
        
        AF.request(fullURL,
                   method: method,
                   parameters: parameters,
                   headers: headers).responseJSON { response in
            //debugPrint(response)
            
            //self.dismissHUD()
            
            switch response.result {
            case .success(let data as AnyObject):
                
                if data["status"] as! String == "success" {
                    if showLoadingHUD == true && dismissHUD == true
                    {
                        ProgressHUD.dismiss()
                    }
                    completion(.success(data))
                }
                else if data["status"] as! String == "error" {
                    if data["message"] as! String == "Signature verification failed" {
                        self.logOut()
                        ProgressHUD.dismiss()
                    }
                    else{
                        ProgressHUD.showFailed(data["message"] as? String)
                    }
                }
                else{
                    print("FAIL = \(data["message"]!!)")
                    ProgressHUD.showFailed(data["message"] as? String)
                }
                
            case .failure(let error):
                completion(.failure(error))
                ProgressHUD.showError("Connection_Error".localized())
                
            default:
                fatalError("received non-dictionary JSON response")
            }
        }
    }
    
    @objc func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:    #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func blurViewSetup() -> UIVisualEffectView{
        let blurEffect = UIBlurEffect(style: .prominent)
        let blurView = UIVisualEffectView (effect: blurEffect)
        blurView.bounds = self.view.bounds
        blurView.center = self.view.center
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(blurViewTapped))
        blurView.isUserInteractionEnabled = true
        blurView.addGestureRecognizer(tap)
        
        return blurView
    }
    
    func popIn(popupView : UIView) {
        var backgroundView:UIView
        if let tabBarView = self.tabBarController?.view {
            backgroundView = tabBarView
        }
        else {
            backgroundView = self.view
        }
        
        //        let blurView = blurViewSetup()
        //        blurView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        //        blurView.alpha = 0
        //        backgroundView!.addSubview(blurView)
        
        //popupView.center = backgroundView!.center
        popupView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        popupView.alpha = 0
        
        backgroundView.addSubview(popupView)
        
        UIView.animate(withDuration: 0.3, animations:{
            //blurView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            //blurView.alpha = 1
            
            popupView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            popupView.alpha = 1
        })
    }
    
    func popOut(popupView : UIView) {
        UIView.animate(withDuration: 0.3, animations:{
            popupView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            popupView.alpha = 1
        }, completion: {_ in
            popupView.removeFromSuperview()
        })
    }
    
    @objc func blurViewTapped(_ sender: UITapGestureRecognizer) {
        //sender.view?.removeFromSuperview()
        print("Tap Blur")
    }
    
    func colorFromRGB(rgbString : String) -> UIColor{
        let rgbArray = rgbString.components(separatedBy: ", ")
        
        let red = Float(rgbArray[0])!
        let green = Float(rgbArray[1])!
        let blue = Float(rgbArray[2])!
        
        let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1.0)
        return color
    }
    
    func dateToServerString(date:Date) -> String{
        let strdt = DateFormatter.serverFormatter.string(from: date)
        if let dtDate = DateFormatter.serverFormatter.date(from: strdt){
            return DateFormatter.serverFormatter.string(from: dtDate)
        }
        return "-"
    }
    
    func dateAndTimeToServerString(date:Date) -> String{
        let strdt = DateFormatter.serverFormatterWithTime.string(from: date)
        if let dtDate = DateFormatter.serverFormatterWithTime.date(from: strdt){
            return DateFormatter.serverFormatterWithTime.string(from: dtDate)
        }
        return "-"
    }
    
    func monthAndYearToServerString(date:Date) -> String{
        let strdt = DateFormatter.serverFormatterMonthYear.string(from: date)
        if let dtDate = DateFormatter.serverFormatterMonthYear.date(from: strdt){
            return DateFormatter.serverFormatterMonthYear.string(from: dtDate)
        }
        return "-"
    }
    
    func appDateFromServerString(dateStr:String) -> Date? {
        if let dtDate = DateFormatter.serverFormatter.date(from: dateStr){
            return dtDate as Date?
        }
        return nil
    }
    
    func appDateFromString(dateStr:String, format:String) -> Date?{//Case for HH:mm
        let dateFormatter:DateFormatter = DateFormatter.customFormatter
        dateFormatter.locale = Locale(identifier: "Formatter_Locale".localized())//Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = format
        if let dtDate = dateFormatter.date(from: dateStr){
            return dtDate as Date?
        }
        return nil
    }
    
    func appStringFromDate(date:Date, format:String) -> String{
        let dateFormatter:DateFormatter = DateFormatter.customFormatter
        dateFormatter.locale = Locale(identifier: "Formatter_Locale".localized())//Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = format
        let strdt = dateFormatter.string(from: date)
        if let dtDate = dateFormatter.date(from: strdt){
            return dateFormatter.string(from: dtDate)
        }
        return "-"
    }
    
    func nameKey() -> String{
        //return "Name".localized()
        return "name"
    }
    
    func firstNameKey() -> String{
        //return "First_Name".localized()
        return "first_name"
    }
    
    func lastNameKey() -> String{
        //return "Last_Name".localized()
        return "last_name"
    }
    
    func menuNameKey() -> String{
        //return "Menu_Name".localized()
        return "menu_name"
    }
    
    func categoryNameKey() -> String{
        //return "Category_Name".localized()
        return "category_name"
    }
    
    func requestNameKey() -> String{
        //return "Request_Name".localized()
        return "request_name"
    }
    
}//end UIViewController

// MARK: - UIView
extension UIView {
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        
        self.layer.mask = mask
    }
    
    func setGradientBackground(colorTop: UIColor? = nil, colorBottom: UIColor? = nil, mainPage: Bool? = false){
        
        for sublayer in self.layer.sublayers! {
            if sublayer.name == "GRADIENT" {
                sublayer.removeFromSuperlayer()
            }
        }
        
        let gradientLayer = CAGradientLayer()
        
        if colorTop != nil && colorBottom != nil {
            gradientLayer.colors = [colorBottom!.cgColor, colorTop!.cgColor]
        }
        else if mainPage == true {
            let gradient1 = UserDefaults.standard.loadcolor(forKey: "gradientColor_1")
            let gradient2 = UserDefaults.standard.loadcolor(forKey: "gradientColor_2")
            
            gradientLayer.colors = [gradient2?.cgColor ?? UIColor.bgLightGray.cgColor, gradient1?.cgColor ?? UIColor.themeColor.cgColor]
        }
        else {
            let gradient1 = UserDefaults.standard.loadcolor(forKey: "gradientColor_1")
            gradientLayer.colors = [gradient1?.cgColor ?? UIColor.headerGradient2.cgColor, gradient1?.cgColor ?? UIColor.headerGradient1.cgColor]
        }
        
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.locations = [NSNumber(floatLiteral: 0.0), NSNumber(floatLiteral: 1.0)]
        gradientLayer.frame = self.bounds
        gradientLayer.name = "GRADIENT"
        
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func asImage() -> UIImage {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContext(self.frame.size)
            self.layer.render(in:UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return UIImage(cgImage: image!.cgImage!)
        }
    }
}

// MARK: - UIImageView
extension UIImageView {
    func setImageColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
    
    func loadFrom(URLAddress: String) {
        guard let url = URL(string: URLAddress) else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            if let imageData = try? Data(contentsOf: url) {
                if let loadedImage = UIImage(data: imageData) {
                    self?.image = loadedImage
                }
            }
        }
    }
}

// MARK: - UIImage
extension UIImage {
    func imageWithColor(color: UIColor) -> UIImage {
        let rect: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func imageResized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    func convertImageToBase64String () -> String {
        return self.jpegData(compressionQuality: 0.5)?.base64EncodedString() ?? ""
    }
    
    //    func convertBase64StringToImage (imageBase64String:String) -> UIImage {
    //        let imageData = Data.init(base64Encoded: imageBase64String, options: .init(rawValue: 0))
    //        let image = UIImage(data: imageData!)
    //        return image!
    //    }
}


// MARK: - UIButton
extension UIButton {
    func disableBtn() {
        isEnabled = false
        backgroundColor = UIColor.buttonDisable
        setTitleColor(.gray, for: .normal)
    }
    
    func enableBtn() {
        isEnabled = true
        backgroundColor = UIColor.themeColor
        setTitleColor(.white, for: .normal)
    }
    
    func segmentOn(color:UIColor? = .themeColor ) {
        backgroundColor = color
        setTitleColor(UIColor.white, for: .normal)
    }
    
    func segmentOff() {
        backgroundColor = UIColor.clear
        setTitleColor(.textDarkGray, for: .normal)
    }
}


// MARK: - UITextField
extension UITextField {
    func setUI () {
        self.borderStyle = .none
        self.layer.cornerRadius = 10.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGray.cgColor
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}


// MARK: - String
extension String {
    func contains(_ find: String) -> Bool{
        return self.range(of: find) != nil
    }
    
    func containsIgnoringCase(_ find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
    /// Decode a String from Base64. Returns nil if unsuccessful.
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}


// MARK: - Date
extension Date {
    //    init(_ dateString:String) {
    //        let dateStringFormatter = DateFormatter()
    //        dateStringFormatter.locale = Locale(identifier: "en_US")
    //        dateStringFormatter.dateFormat = "yyyy-MM-dd"
    //        let date = dateStringFormatter.date(from: dateString)!
    //        self.init(timeInterval:0, since:date)
    //    }
}


// MARK: - DateFormatter
extension DateFormatter {
    //    static let iso8601Full: DateFormatter = {
    //        let formatter = DateFormatter()
    //        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    //        formatter.calendar = Calendar(identifier: .iso8601)
    //        formatter.timeZone = TimeZone(secondsFromGMT: 0)
    //        formatter.locale = Locale(identifier: "en_US_POSIX")
    //        return formatter
    //    }()
    
    static let appDateFormatStr: String = "d MMM yyyy"
    static let appDateWithTimeFormatStr: String = "dd MMM yyyy HH:mm"
    static let appMonthYearFormatStr: String = "MMMM yyyy"
    
    static let serverFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")//Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        return formatter
    }()
    
    static let serverFormatterWithTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")//Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        return formatter
    }()
    
    static let serverFormatterMonthYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        formatter.locale = Locale(identifier: "en_US_POSIX")//Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        return formatter
    }()
    
    static let customFormatter: DateFormatter = {
        let formatter = DateFormatter()
        //formatter.locale = Locale(identifier: "Formatter_Locale".localized())//Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        //formatter.calendar = Calendar(identifier: .buddhist)
        return formatter
    }()
}


// MARK: - UIAlertController & UIAlertAction
extension UIAlertController {
    func setColorAndFont(){
        
        let attributesTitle = [NSAttributedString.Key.foregroundColor: UIColor.textDarkGray, NSAttributedString.Key.font: UIFont.Kanit_Medium(ofSize: 18)]
        let attributesMessage = [NSAttributedString.Key.foregroundColor: UIColor.gray, NSAttributedString.Key.font: UIFont.Kanit_Regular(ofSize: 15)]
        let attributedTitleText = NSAttributedString(string: self.title ?? "", attributes: attributesTitle as [NSAttributedString.Key : Any])
        let attributedMessageText = NSAttributedString(string: self.message ?? "", attributes: attributesMessage as [NSAttributedString.Key : Any])
        
        self.setValue(attributedTitleText, forKey: "attributedTitle")
        self.setValue(attributedMessageText, forKey: "attributedMessage")
    }
}

extension UIAlertAction {
    var titleTextColor: UIColor? {
        get { return self.value(forKey: "titleTextColor") as? UIColor }
        set { self.setValue(newValue, forKey: "titleTextColor") }
    }
}

// MARK: - UICollectionViewCell
extension UICollectionViewCell {
    func setRoundAndShadow () {
        contentView.layer.cornerRadius = 15.0
        contentView.layer.borderWidth = 0.0
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.layer.masksToBounds = true
        
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0.0)
        layer.shadowRadius = 4.0
        layer.shadowOpacity = 0.2
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
    }
}

// MARK: - UserDefaults
extension UserDefaults {

    func saveColor(_ value: UIColor?, forKey key: String) {

        guard let color = value else { return }
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false)
            set(data, forKey: key)
        } catch let error {
            print("error color key data not saved \(error.localizedDescription)")
        }
    }
    
    func loadcolor(forKey key: String) -> UIColor? {
        guard let colorData = data(forKey: key) else {
            return nil
        }

        do {
            return try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData)
        } catch let error {
            print("color error \(error.localizedDescription)")
            return nil
        }
    }
}
