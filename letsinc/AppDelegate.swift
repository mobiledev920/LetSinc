//
//  AppDelegate.swift
//  LetSinc
//
//  Created by Mateo Kozomara on 18/05/2017.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Contacts
import Firebase
import UserNotifications
import GooglePlaces
import GoogleMaps
import SVProgressHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var contactStore = CNContactStore()
    let locationManager = CLLocationManager()
    
    class func getAppDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        SVProgressHUD.setDefaultMaskType(.clear)
        UIApplication.shared.statusBarStyle = .default
        IQKeyboardManager.sharedManager().enable = true
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        let token = Messaging.messaging().fcmToken
        print("Token String: -- %@", token ?? "")
        GMSPlacesClient.provideAPIKey("AIzaSyAgGZVAQm_UUaYIqwF2iqa8zRL-4KaAaT8")
        locationManager.delegate = self
        registerPushNotifications()
        
//        GMSServices.provideAPIKey("AIzaSyAgGZVAQm_UUaYIqwF2iqa8zRL-4KaAaT8")
        
        return true
    }
    
    func requestContactsAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        
        switch authorizationStatus {
        case .authorized:
            completionHandler(true)
            
        case .denied, .notDetermined:
            self.contactStore.requestAccess(for: CNEntityType.contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    completionHandler(access)
                }
                else {
                    completionHandler(false)
                }
            })
            
        default:
            completionHandler(false)
        }
    }
    
    private var locationAuthorisationCallback:((_ accessGranted: Bool) -> Void)?
    
    func requestLocationAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        if CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .restricted {
            completionHandler(false)
            return
        }
        self.locationAuthorisationCallback = completionHandler
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("GOT LOCATION AUTHORISATION STATUS \(status.rawValue)")
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            self.locationAuthorisationCallback?(true)
            self.locationAuthorisationCallback = nil
        }
        else if status == .denied || status == .restricted {
        
            self.locationAuthorisationCallback?(false)
            self.locationAuthorisationCallback = nil
        } else if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func showMessage(title:String, message: String, completionHandler: (() -> Void)?) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action) -> Void in
            completionHandler?()
        }
        
        alertController.addAction(dismissAction)
        let presentedViewController = AppDelegate.topViewController()
        presentedViewController!.present(alertController, animated: true, completion: nil)
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification notification: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Auth.auth().canHandleNotification(notification) {
            completionHandler(UIBackgroundFetchResult.noData)
            return
        }
    }
    
    func registerPushNotifications() {
        let application = UIApplication.shared
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let center = UNUserNotificationCenter.current()
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            
            center.requestAuthorization(options: authOptions) {
                (granted, error) in
                print("Permission granted: \(granted)")
                guard granted else { return }
                self.getNotificationSettings()
            }
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func tokenRefreshNotification(_ notification: Notification) {
        print("IM IN tokenRefreshNotification")
        if let refreshedToken = InstanceID.instanceID().token() {
            print("FIRTOKEN refreshed \(refreshedToken)" )
//            setDeviceToken(token: refreshedToken)
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Pass device token to auth
//        Auth.auth().setAPNSToken(deviceToken, type: AuthAPNSTokenType.unknown)
//        Messaging.messaging().apnsToken = deviceToken
        
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}


@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // FOREGROUND
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let notificationData = notification.request.content.userInfo as! [String : AnyObject]
        print("userNotificationCenter willPresent \(notificationData)")
        handleNotification(notificationData: notificationData, appState: UIApplicationState.active, window: window!)
    }
    
    // BACKGROUND / CLOSED
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        let application = UIApplication.shared
        let notificationData = response.notification.request.content.userInfo as! [String : AnyObject]
        application.applicationIconBadgeNumber = application.applicationIconBadgeNumber + Int(response.notification.request.content.badge ?? 0)
        handleNotification(notificationData: notificationData, appState: UIApplicationState.background, window: window!)
        print("userNotificationCenter did receive response \(response.notification.request.content.userInfo)")
    }
    
    func handleNotification(notificationData: [String : AnyObject], appState: UIApplicationState, window: UIWindow) {
        if appState == .active {
            if let aps = notificationData["aps"] as? [String: Any], let alert = aps["alert"] as? [String: String] {
                let alertController = UIAlertController(title: alert["title"], message: alert["body"], preferredStyle: .alert)
                let confirmAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(confirmAction)
                window.rootViewController?.presentedViewController?.present(alertController, animated: true, completion: nil)
            }
        }
        
        if let rootViewController = window.rootViewController as? LoginViewController, let tabBarController = rootViewController.presentedViewController as? UITabBarController {
            if tabBarController.selectedIndex != 2 {
                let item = tabBarController.viewControllers![2]
                item.tabBarItem.badgeValue = String(UIApplication.shared.applicationIconBadgeNumber)
            } else {
                let item = tabBarController.viewControllers![2]
                item.tabBarItem.badgeValue = nil
            }
        }
    }
}

extension AppDelegate : MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("didRefreshRegistrationToken \(fcmToken)")
    }
   
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("didReceive remoteMessage")
    }
}
