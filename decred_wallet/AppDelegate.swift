//  AppDelegate.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import CoreData
import Dcrlibwallet
import SlideMenuControllerSwift
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    var navigation: UINavigationController?
    fileprivate let loadThread = DispatchQueue.self
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping
        (UNNotificationPresentationOptions) -> Void){
        completionHandler([.alert])
    }
    
    fileprivate func walletSetupView() {
        DispatchQueue.main.async{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let walletSetupController = storyboard.instantiateViewController(withIdentifier: "WalletSetupViewController") as! WalletSetupViewController
            let nv = UINavigationController(rootViewController: walletSetupController)
            nv.isNavigationBarHidden = true
            self.window?.rootViewController = nv
            
            self.window?.makeKeyAndVisible()
        }
    }
    
    fileprivate func createMenuView() {
        // create viewController code...
        DispatchQueue.main.async{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainViewController = storyboard.instantiateViewController(withIdentifier: "OverviewViewController") as! OverviewViewController
            let leftViewController = storyboard.instantiateViewController(withIdentifier: "LeftViewController") as! LeftViewController
            
            let nvc: UINavigationController = UINavigationController(rootViewController: mainViewController)
            
            UINavigationBar.appearance().tintColor = GlobalConstants.Colors.navigationBarColor
            
            leftViewController.mainViewController = nvc
            
            let slideMenuController = ExSlideMenuController(mainViewController: nvc, leftMenuViewController: leftViewController)
            slideMenuController.changeLeftViewWidth((self.window?.frame.size.width)! - (self.window?.frame.size.width)! / 6)
            
            slideMenuController.delegate = mainViewController
            self.window?.backgroundColor = GlobalConstants.Colors.lightGrey
            self.window?.rootViewController = slideMenuController
            
            self.window?.makeKeyAndVisible()
        }
    }
    
    fileprivate func populateFirstScreen() {
        var initWalletError: NSError?
        SingleInstance.shared.wallet = DcrlibwalletNewLibWallet(NSHomeDirectory() + "/Documents/dcrwallet/", "bdb", "testnet3", &initWalletError)
        if initWalletError != nil {
            print("init wallet error -> \(initWalletError!.localizedDescription)")
            return
        }
        
        SingleInstance.shared.wallet?.initLoader()
        
        if isWalletCreated() {
            if(UserDefaults.standard.bool(forKey: "secure_wallet")){
                if(UserDefaults.standard.string(forKey: "securitytype") == "PASSWORD"){
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let sendVC = storyboard.instantiateViewController(withIdentifier: "StartUpPasswordViewController") as! StartUpPasswordViewController
                    sendVC.senders = "launcher"
                    self.window?.rootViewController = sendVC
                    self.window?.makeKeyAndVisible()
                }
                else{
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let sendVC = storyboard.instantiateViewController(withIdentifier: "PinSetupViewController") as! PinSetupViewController
                    sendVC.senders = "launcher"
                    self.window?.rootViewController = sendVC
                    self.window?.makeKeyAndVisible()
                }
                
            }
            else{
                openUnSecuredWallet()
            }
            
        } else {
            DispatchQueue.global(qos: .default).async {
                self.walletSetupView()
            }
            
        }
    }
    
    fileprivate func showAnimatedStartScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let startScreenController = storyboard.instantiateViewController(withIdentifier: "WaiterScreenViewController") as! WaiterScreenViewController
        
        startScreenController.onFinish = { [weak self] in
            guard let this = self else { return }
            this.populateFirstScreen()
        }
        
        startScreenController.onTapAnimation = { [weak self] in
            guard let this = self else { return }
            this.gotoSetting()
        }
        
        self.navigation = UINavigationController(rootViewController: startScreenController)
        UINavigationBar.appearance().tintColor = GlobalConstants.Colors.navigationBarColor
        self.navigation?.navigationBar.isHidden = true
        self.window?.rootViewController = self.navigation
        self.window?.makeKeyAndVisible()
    }
    
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        DispatchQueue.main.async {
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge , .sound]){ (granted, error) in
                print("granted: \(granted)")
                
            }
            UserDefaults.standard.setValuesForKeys(["pref_user_name": "dcrwallet",
                                                    "pref_user_passwd": "dcrwallet",
                                                    "pref_server_ip": "",
                                                    "pref_peer_ip": ""])
            UserDefaults.standard.set(true, forKey: "pref_use_testnet")
            self.showAnimatedStartScreen()
        }
        
        
        return true
    }
    
    fileprivate func gotoSetting() {
        let vcSetting = GlobalConstants.ConstantStoryboardMain.getControllerInstance(identifier: "SettingsController2", storyBoard: GlobalConstants.ConstantStoryboardMain.IDENTIFIER_STORYBOARD_MAIN) as! SettingsController
        vcSetting.isFromLoader = true
        
        self.navigation?.pushViewController(vcSetting, animated: true)
    }
    
    fileprivate func openUnSecuredWallet() {
        let key = "public"
        let finalkey = key as NSString
        let finalkeyData = finalkey.data(using: String.Encoding.utf8.rawValue)!
        do {
            ((try SingleInstance.shared.wallet?.open(finalkeyData)))
        } catch let error {
            print(error)
        }
        DispatchQueue.global(qos: .default).async {
            self.createMenuView()
        }
    }
    
    func applicationWillResignActive(_: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        if (SingleInstance.shared.wallet != nil){
            UserDefaults.standard.set(false, forKey: "walletScanning")
            UserDefaults.standard.set(false, forKey: "synced")
            UserDefaults.standard.synchronize()
            SingleInstance.shared.wallet?.shutdown()
        }
    }
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
    }
}

extension AppDelegate {
    class var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
}
