//
//  AppDelegate.swift
//  PowerScout
//
//  Created by Srinivas Dhanwada on 1/20/18.
//  Copyright © 2018 FRC Team 525. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    var orientationLock: UIInterfaceOrientationMask = .all
    var matchStore:MatchStore!
    var serviceStore:ServiceStore!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Mock data testing (use this line)
//        matchStore = MatchStore(withMock: true)
        // No Mock Data Testing (use this line)
        matchStore = MatchStore(withMock: false)
        serviceStore = ServiceStore(withMatchStore: matchStore)
        
        if let splitViewController = self.window!.rootViewController as? UISplitViewController {
            let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
            if splitViewController.displayMode == .primaryHidden {
                navigationController.topViewController!.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Matches", style: splitViewController.displayModeButtonItem.style, target: splitViewController.displayModeButtonItem.target, action: splitViewController.displayModeButtonItem.action)
            } else {
                navigationController.topViewController!.navigationItem.leftBarButtonItem = nil
            }
            
            let masterNC = splitViewController.viewControllers[0] as! UINavigationController
            if let masterVC = masterNC.topViewController as? MasterViewController {
                masterVC.matchStore = matchStore
            }
            
            splitViewController.delegate = self
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

    // MARK: - Split view

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        return false
    }

    func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewControllerDisplayMode) {
        let masterNavController = svc.viewControllers[0] as! UINavigationController
        let detailNavController = svc.viewControllers[svc.viewControllers.count - 1] as! UINavigationController
        let title = masterNavController.topViewController!.navigationItem.title!
        svc.displayModeButtonItem.title = title
        if displayMode == .primaryHidden {
            detailNavController.topViewController!.navigationItem.leftBarButtonItem = UIBarButtonItem(title: title, style: svc.displayModeButtonItem.style, target: svc.displayModeButtonItem.target, action: svc.displayModeButtonItem.action)
        } else {
            detailNavController.topViewController!.navigationItem.leftBarButtonItem = nil
        }
    }
}

