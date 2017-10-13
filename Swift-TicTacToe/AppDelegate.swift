//
//  AppDelegate.swift
//  Swift-TicTacToe
//
//  Created by Lahiru Lakmal on 2016-12-20.
//  Copyright © 2016 SoundofCode. All rights reserved.
//

import UIKit
import UserNotifications
#if DEBUG
    import AdSupport
#endif
import Leanplum

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var gameTitleLabelValue = LPVar.define("gameTitleLabelValue", with: "Sonic The Hedgehog")
    var backgroundValue = LPVar.define("backgroundValue", with: "sonic.png")
    var backgroundFileValue = LPVar.define("backgroundFileValue", withFile: "sonic.png")
    var sessionDetails = LPVar.define("SessionDetails", with: [
        "PlayerOne": [
            "Name": "user1",
            "Wins": 256.0,
            "LastWin": "yesterday"
        ],
        "PlayerTwo": [
            "Name": "user2",
            "Wins": 512.0,
            "LastWin": "today"
        ]
    ])

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        #if DEBUG
//            Leanplum.setDeviceId(ASIdentifierManager.shared().advertisingIdentifier.uuidString)
            Leanplum.setDeviceId("testdevice123")
            Leanplum.setAppId(appId,
                              withDevelopmentKey: devKey)
        #else
            Leanplum.setAppId(appId,
                              withProductionKey: prodKey)
        #endif
        
        // None, Associate, Bachelor, Master, Doctor
        Leanplum.setVerboseLoggingInDevelopmentMode(true);
        Leanplum.start(withUserId: "leanplumtest", userAttributes: ["gender":"male", "university":"Bachelor"])
        registerForPushNotifications()
        return true
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
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func registerForPushNotifications() {
        //iOS-10
        if #available(iOS 10.0, *){
            let userNotifCenter = UNUserNotificationCenter.current()
            
            userNotifCenter.requestAuthorization(options: [.badge,.alert,.sound]){ (granted,error) in
                //Handle individual parts of the granting here.
            }
            
            userNotifCenter.getNotificationSettings { (settings : UNNotificationSettings) in
                if settings.authorizationStatus == .authorized {
                    print("AUTHORIZED")
                } else {
                    print("NOT AUTHORIZED")
                }
            }
            
            UIApplication.shared.registerForRemoteNotifications()
        }
            //iOS 8-9
        else if #available(iOS 8.0, *){
            let settings = UIUserNotificationSettings.init(types: [UIUserNotificationType.alert,UIUserNotificationType.badge,UIUserNotificationType.sound],
                                                           categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            UIApplication.shared.registerForRemoteNotifications()
        }
            //iOS 7
        else{
            UIApplication.shared.registerForRemoteNotifications(matching:
                [UIRemoteNotificationType.alert,
                 UIRemoteNotificationType.badge,
                 UIRemoteNotificationType.sound])
        }
        //Other code.
    }
    
}

