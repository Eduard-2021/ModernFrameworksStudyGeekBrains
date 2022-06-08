//
//  AppDelegate.swift
//  MovementMonitoring
//
//  Created by Eduard on 19.03.2022.
//

import UIKit
import GoogleMaps

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var appCoordinator: AppCooridanor?
    var mainNavigationController: UINavigationController?
    let navigationController = UINavigationController()
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        GMSServices.provideAPIKey("AIzaSyApb176QReRAhxT9Qob-pGFI0KTYtDjdjU")
        
        window = UIWindow(frame: UIScreen.main.bounds)
        appCoordinator = AppCooridanor(navigationController: navigationController)
        appCoordinator?.start()
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        guard let backgroundViewController = storyboard.instantiateViewController(withIdentifier: "BackgroundViewController") as? BackgroundViewController else {
            return
        }
        window?.rootViewController = backgroundViewController
    }

    
    func applicationDidBecomeActive(_ application: UIApplication) {
        window?.rootViewController = navigationController
    }

}

