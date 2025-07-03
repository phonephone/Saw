//
//  SceneDelegate.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 7/10/2564 BE.
//

import UIKit
import Localize_Swift
import LineSDK
import AppTrackingTransparency

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        let defaults = UserDefaults.standard
        //defaults.dictionaryRepresentation().keys.forEach(defaults.removeObject(forKey:))
        
        let storyboard = UIStoryboard.loginStoryBoard
        var navigationController : UINavigationController
        
        let accessToken = defaults.string(forKey:"access_token")
        let passCode = defaults.string(forKey:"passCode")
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            
            if accessToken != nil {
                print("ALREADY LOGIN \(accessToken!)")
                print(Localize.availableLanguages())
                
                if passCode != nil {
                    print("HAVE PASSCODE \(passCode!)")
                    let vc = storyboard.instantiateViewController(withIdentifier: "EnterPasscode") as! EnterPasscode
                    vc.passcodeStr = passCode
                    navigationController = UINavigationController.init(rootViewController: vc)
                }
                else{
                    print("NO PASSCODE")
                    let vc = storyboard.instantiateViewController(withIdentifier: "NewPasscode") as! NewPasscode
                    navigationController = UINavigationController.init(rootViewController: vc)
                }
            }
            else{
                print("1ST time")
                let vc = storyboard.instantiateViewController(withIdentifier: "Login") as! Login
                navigationController = UINavigationController.init(rootViewController: vc)
            }

            // MARK: - Bypass Login
            var bypassVC = UIViewController()
            
            //bypassVC = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "Profile") as! Profile
            
            //bypassVC = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "Reward") as! Reward
            
            //bypassVC = UIStoryboard.rewardStoryBoard.instantiateViewController(withIdentifier: "Coupon") as! Coupon
            
            //bypassVC = UIStoryboard.attendanceStoryBoard.instantiateViewController(withIdentifier: "Leave") as! Leave
            
            //bypassVC = UIStoryboard.attendanceStoryBoard.instantiateViewController(withIdentifier: "LeaveDetail") as! LeaveDetail

            
            //bypassVC = UIStoryboard.attendanceStoryBoard.instantiateViewController(withIdentifier: "Attendance") as! Attendance
            
            //bypassVC = UIStoryboard.attendanceStoryBoard.instantiateViewController(withIdentifier: "OT") as! OT
            
            //bypassVC = UIStoryboard.attendanceStoryBoard.instantiateViewController(withIdentifier: "OTManual") as! OTManual
            
            //bypassVC = UIStoryboard.attendanceStoryBoard.instantiateViewController(withIdentifier: "ApproveMenu") as! ApproveMenu
            
            //bypassVC = UIStoryboard.loginStoryBoard.instantiateViewController(withIdentifier: "NewPasscode") as! NewPasscode
            
            //bypassVC = UIStoryboard.loginStoryBoard.instantiateViewController(withIdentifier: "Tutorial") as! Tutorial
            //bypassVC.mode = .later
            
            //bypassVC = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "ReportMenu") as! ReportMenu
            
            //bypassVC = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "EDocMenu") as! EDocMenu
            
//            bypassVC = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "EDoc") as! EDoc
//            vc.edocType = .probation
            
//            bypassVC = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "EDocDetail") as! EDocDetail
//            vc.edocType = .salary_cert
//            vc.detailID = "695"
            
            //bypassVC = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "EDocWeb") as! EDocWeb
            
            //bypassVC = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "EDocSalaryQR") as! EDocSalaryQR
            
            //bypassVC = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "Warning") as! Warning
            
            //bypassVC = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "WarningHead") as! WarningHead
            
            //bypassVC = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "ProbationScore") as! ProbationScore
            
            //bypassVC = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "ProbationResult") as! ProbationResult
            
            //bypassVC = UIStoryboard.settingStoryBoard.instantiateViewController(withIdentifier: "Setting") as! Setting
            
            //bypassVC = UIStoryboard.settingStoryBoard.instantiateViewController(withIdentifier: "Language") as! Language
            
            //bypassVC = UIStoryboard.attendanceStoryBoard.instantiateViewController(withIdentifier: "SwapShift") as! SwapShift
            
            //bypassVC = UIStoryboard.loginStoryBoard.instantiateViewController(withIdentifier: "TermOfService") as! TermOfService
            
//            bypassVC = UIStoryboard.loginStoryBoard.instantiateViewController(withIdentifier: "PrivacyPolicy") as! PrivacyPolicy
//            bypassVC.agreementShow = true
            
            //bypassVC = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "EditProfile") as! EditProfile
                     
//            bypassVC = UIStoryboard.moodStoryBoard.instantiateViewController(withIdentifier: "MoodJournal") as! MoodJournal
//            
//            bypassVC = UIStoryboard.moodStoryBoard.instantiateViewController(withIdentifier: "MoodJournalHead") as! MoodJournalHead
            
//            bypassVC = UIStoryboard.moodStoryBoard.instantiateViewController(withIdentifier: "MyMood") as! MyMood
            
//            bypassVC = UIStoryboard.moodStoryBoard.instantiateViewController(withIdentifier: "MoodReport") as! MoodReport
            
//            bypassVC = UIStoryboard.moodStoryBoard.instantiateViewController(withIdentifier: "MoodDashBoard") as! MoodDashBoard
            
//            bypassVC = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "DemoExpired") as! DemoExpired
            
//            bypassVC = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "ReportList") as! ReportList
            
//            bypassVC = UIStoryboard.loginStoryBoard.instantiateViewController(withIdentifier: "Login") as! Login
            
//            bypassVC = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "TabBar") as! TabBar
            
//            bypassVC = UIStoryboard.aiStoryBoard.instantiateViewController(withIdentifier: "FaceEmotionAI") as! FaceEmotionAI
//            
            
            //navigationController = UINavigationController.init(rootViewController: bypassVC)
            //Localize.setCurrentLanguage("en")
            //Localize.setCurrentLanguage("th")
            //Localize.setCurrentLanguage("zh")
            //Localize.resetCurrentLanguageToDefault()
            //print(Localize.defaultLanguage())
            //print(Localize.availableLanguages())
            
            
            // MARK: - End Bypass
            
            navigationController.setNavigationBarHidden(true, animated:false)
            window.rootViewController = navigationController// Your RootViewController in here
            window.makeKeyAndVisible()
            self.window = window
        }
        
        //guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        _ = LoginManager.shared.application(.shared, open: URLContexts.first?.url)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        
        //requestTrackingPermission()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

//    func requestTrackingPermission() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            if #available(iOS 14, *) {
//                ATTrackingManager.requestTrackingAuthorization { (status) in
//                    switch status {
//                    case .authorized:
//                        // Tracking authorization dialog was shown
//                        // and we are authorized
//                        print("Authorized")
//                    case .denied:
//                        // Tracking authorization dialog was
//                        // shown and permission is denied
//                        print("Denied")
//                    case .notDetermined:
//                        // Tracking authorization dialog has not been shown
//                        print("Not Determined")
//                    case .restricted:
//                        print("Restricted")
//                    @unknown default:
//                        print("Unknown")
//                    }
//                }
//            }
//        }
//    }
}

