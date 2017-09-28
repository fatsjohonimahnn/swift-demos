//
//  AppDelegate.swift
//  VideoRecorderPlayerBackendless
//
//  Created by Jonathon Fishman on 10/8/16.
//  Copyright © 2016 fatsjohonimahnn. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let APP_ID = "17D84BEF-BBE0-1A00-FFDE-9C5B767CFA00" //"<replace-with-your-app-id>"
    let SECRET_KEY = "93E34934-9640-7086-FFAC-3F3BAB77FE00" //"<replace-with-your-secret-key>"
    
    let VERSION_NUM = "v1"
    
    let EMAIL = "test@test.com" // Doubles as User Name
    let PASSWORD = "password"
    
    let backendless = Backendless.sharedInstance()

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if APP_ID != "<replace-with-your-app-id>" && SECRET_KEY != "<replace-with-your-secret-key>" {
            
            backendless?.initApp(APP_ID, secret: SECRET_KEY, version: VERSION_NUM)
            backendless?.userService.setStayLoggedIn(true)
            backendless?.setThrowException(false)

            backendless?.hostURL = "https://api.backendless.com"
            
            backendless?.mediaService = MediaService()
            
            // Next, check if the user is already logged in. If they are - do nothing else!
            let isValidUser = backendless?.userService.isValidUserToken()
            
            if isValidUser != nil && isValidUser != 0 {
                
                // The user has a valid user token
                print("User is already logged in: \(isValidUser?.boolValue)")
            } else {
                
                // If the user is not logged in, register the test user, and log them in
                let user: BackendlessUser = BackendlessUser()
                user.email = EMAIL as NSString!
                user.password = PASSWORD as NSString!
                
                backendless?.userService.registering( user,
                
                    response:{ ( user: BackendlessUser?) -> Void in
                        
                        print("User was registered: \(user?.objectId)")
                        
                        self.backendless?.userService.login(self.EMAIL, password: self.PASSWORD,
                        
                             response:{ (user: BackendlessUser?) -> Void in
                                print("User logged in")
                            
                            },
                             error:{ (fault: Fault?) -> Void in
                                print("User failed to log in: \(fault)")
                        })
                    },
                                                      
                    error:{ (fault: Fault?) -> Void in
                        
                        print("User failed to register: \(fault)")
                })
            }
        }
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


}

