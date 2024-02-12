//
//  AppDelegate.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 7/10/2564 BE.
//

import UIKit
import IQKeyboardManagerSwift
import ProgressHUD
import GoogleMaps
import Firebase
import FirebaseMessaging
import UserNotifications
import LineSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let gcmMessageIDKey = "gcm.message_id"
    
    override init() {
        super.init()
        UIFont.overrideInitialize()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        IQKeyboardManager.shared.enable = true
        
        FirebaseApp.configure()
        // [START set_messaging_delegate]
        Messaging.messaging().delegate = self
        // [END set_messaging_delegate]
        
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        application.registerForRemoteNotifications()
        // [END register_for_notifications]
        
        GMSServices.provideAPIKey(PlistParser.getKeysValue()!["GMS_provideAPIKey"]!)
        //GMSPlacesClient.provideAPIKey("YOUR_API_KEY")
        
        LoginManager.shared.setup(channelID: PlistParser.getKeysValue()!["lineChannelID"]!, universalLinkURL: nil)
        
        ProgressHUD.animationType = .circleStrokeSpin
        ProgressHUD.colorAnimation = UIColor.customThemeColor()
        ProgressHUD.colorHUD = .white
        ProgressHUD.colorBackground = .clear//.lightGray
        ProgressHUD.colorStatus = UIColor.customThemeColor()
        ProgressHUD.fontStatus = UIFont.Kanit_Medium(ofSize: 20)
        
        Thread.sleep(forTimeInterval: 1.0)
        //RunLoop.current.run(until:NSDate(timeIntervalSinceNow:1)as Date)
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    //แอพเปิดอยู่
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
                                -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // [START_EXCLUDE]
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID AAA: \(messageID)")
        }
        // [END_EXCLUDE]
        // Print full message.
        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([[.alert, .sound]])
    }
    
    //กดที่แถบ Noti
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        // [START_EXCLUDE]
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID BBB: \(messageID)")
        }
        // [END_EXCLUDE]
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print full message.
        print(userInfo)
        
        let aps : [String : Any] = userInfo["aps"] as! [String : Any]
        let alert : [String : Any] = aps["alert"] as! [String : Any]
        let title : String = alert["title"] as! String
        let body : String = alert["body"] as! String
        print("Title = \(title)\nMessage = \(body)")
        
        //      let apsData = (userInfo["order_id"] as? NSString)?.integerValue
        //      // if you need to go some views
        //      if apsData != nil {
        //          let sb = UIStoryboard(name: "Order", bundle: nil)
        //          let vc = sb.instantiateViewController(withIdentifier: "RequestDeliveriesVC") as! RequestDeliveriesVC
        //          vc.order_ofer = apsData ?? 0
        //
        //          let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //
        //          guard  let window = appDelegate.window else {return}
        //          window.rootViewController = vc
        //
        //          UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil, completion: nil)
        //      } else {
        //
        //      }
        
        completionHandler()
    }
    
    func pushToSpecificVC()
    {
        guard let window = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window else { return }

        let storyboard = UIStoryboard(name: "YourStoryboard", bundle: nil)
        let yourVC = storyboard.instantiateViewController(identifier: "yourVCIdentifier")
        
        let navController = UINavigationController(rootViewController: yourVC)
        navController.modalPresentationStyle = .fullScreen

        // you can assign your vc directly or push it in navigation stack as follows:
        window.rootViewController = navController
        window.makeKeyAndVisible()
    }
}
// [END ios_10_message_handling]


// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
        UserDefaults.standard.set(fcmToken, forKey: "fcm_token")
    }
    // [END refresh_token]
}
