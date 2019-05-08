//
//  LeftViewController.swift
//  Decred Wallet\//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit
import JGProgressHUD

enum LeftMenu: Int {
    case overview = 0
    case history
    case send
    case receive
    case accounts
    case security
    case settings
    case help
}

protocol LeftMenuProtocol : class {
    func changeViewController(_ menu: LeftMenu)
}

class LeftViewController : UIViewController, LeftMenuProtocol {
    
    var progressHud : JGProgressHUD?
    
    var scanning = false
    var sync = false
    var isTimerRunning = false
    
    var seconds = 60
    var timer: Timer?
    
    @IBOutlet weak var blockInfo: UILabel!
    @IBOutlet weak var connectionStatus: UILabel!
    @IBOutlet weak var rescanHeight: UILabel!
    @IBOutlet weak var bestblock: UILabel!
    @IBOutlet weak var chainStatus: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var statusBackgroud: UIView!
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var totalBalance: UILabel!
    @IBOutlet weak var progressbar: UIProgressView!
    
    @IBOutlet weak var synIndicate: UIImageView!
    var menus = ["Overview","History", "Send", "Receive", "Accounts","Security", "Settings","Help"]
    
    var mainViewController: UIViewController!
    var accountViewController: UIViewController!
    var sendViewController: UIViewController!
    var receiveViewController: UIViewController!
    var settingsViewController: UIViewController!
    var historyViewController: UIViewController!
    var helpViewController:  UIViewController!
    var securityMenuViewController:UIViewController!
    var selectedIndex: Int!
    var storyboard2: UIStoryboard!
    var walletInfo = SingleInstance.shared
    var wallet = SingleInstance.shared.wallet
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedIndex = 0
        self.tableView.separatorColor = GlobalConstants.Colors.separaterGrey
        storyboard2 =  UIStoryboard(name: "Main", bundle: nil)
        self.tableView.registerCellClass(MenuCell.self)
        self.totalBalance.text = ""
        self.synIndicate.loadGif(name: "progress bar-1s-200px")
        UserDefaults.standard.set(false, forKey: "synced")
        UserDefaults.standard.set(0, forKey: "peercount")
        UserDefaults.standard.synchronize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

         print("left did open")
        if UserDefaults.standard.bool(forKey: GlobalConstants.Strings.DELETE_WALLET) != false{
            UserDefaults.standard.set(false, forKey: GlobalConstants.Strings.DELETE_WALLET)
            let domain = Bundle.main.bundleIdentifier!
            UserDefaults.standard.removePersistentDomain(forName: domain)
            UserDefaults.standard.synchronize()
            SingleInstance.shared.setDefaults()
            DispatchQueue.main.async {
                self.timer?.invalidate()
                self.timer = nil
            }
            UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: false, completion: nil)
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.showAnimatedStartScreen()
            }
        }
        let initialSyncHelp = UserDefaults.standard.bool(forKey: GlobalConstants.Strings.INITIAL_SYNC_HELP)
        if(!initialSyncHelp){
            showAlert(message: "\nYour 33 word seed is your wallet, keep it safe. Without it your funds cannot be recovered should your device be lost or destroyed.\n\nInitial wallet sync will take longer than usual. The wallet will connect to p2p nodes to download the blockchain headers, and will fetch only the blocks that you need while preserving your privacy.", title: "Welcome to Decred Wallet.")
            UserDefaults.standard.set(true, forKey: GlobalConstants.Strings.INITIAL_SYNC_HELP)
            UserDefaults.standard.synchronize()
        }
        
        let clickGesture = UITapGestureRecognizer(target: self, action:  #selector(self.reconnect))
        statusBackgroud.addGestureRecognizer(clickGesture)
    }
    
    @objc func reconnect(){
        wallet?.dropSpvConnection()
        ((mainViewController as! UINavigationController).topViewController as! OverviewViewController).connectToDecredNetwork()
    }
    
    private func showAlert(message: String? , title: String?) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.left
        
        let messageText = NSMutableAttributedString(
            string: message!,
            attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body),
                NSAttributedString.Key.foregroundColor : UIColor.black
            ]
        )
        let titleText = NSMutableAttributedString(
            string: title!,
            attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: UIFont.TextStyle.title3),
                NSAttributedString.Key.foregroundColor : UIColor.black
            ]
        )
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.setValue(messageText, forKey: "attributedMessage")
        alert.setValue(titleText, forKey: "attributedTitle")
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let isTestnet = Bool(infoForKey(GlobalConstants.Strings.IS_TESTNET)!)!
        if isTestnet {
            headerImage?.image = UIImage(named: "logo-testnet")
        }
        
        self.scanning = UserDefaults.standard.bool(forKey: "walletScanning")
        self.runTimer()
        print("left will appear")
    }
    
    func runTimer() {
        if(timer == nil){
            self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self,   selector: (#selector(self.updateTimer)), userInfo: nil, repeats: true)
        }
    }
    
    @objc func updateTimer() {
        self.navStatusInfo()
    }
    func navStatusInfo(){
        DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
            guard let this = self else { return }
            let bestblck = self!.wallet?.getBestBlock()
            let bestblocktemp: Int64 = Int64(Int(bestblck!))
            let lastblocktime = self!.wallet?.getBestBlockTimeStamp()
            self!.sync = UserDefaults.standard.bool(forKey: "synced")
            
            if !((self?.sync)!){
                this.connectionStatus.text = self!.walletInfo.syncStatus
                this.blockInfo.text = self!.walletInfo.ChainStatus
                this.chainStatus.text = self!.walletInfo.bestblockTimeInfo
                if (this.connectionStatus.text == "Connecting to peers"){
                    this.progressbar.progressTintColor = UIColor(hex: "#F9FAFA")
                    this.progressbar.progress = 1
                }
                else{
                    this.progressbar.progressTintColor = UIColor(hex: "#2DD8A3")
                    this.progressbar.progress = (Float(self!.walletInfo.syncProgress) / 100.0)
                }
                
            }
            else{
                this.progressbar.progressTintColor = UIColor(hex: "#F9FAFA")
                this.progressbar.progress = 1
                self!.totalBalance.attributedText = getAttributedString(str: self!.walletInfo.walletBalance, siz: 12, TexthexColor: GlobalConstants.Colors.TextAmount)
                self!.synIndicate.isHidden = true
                let peer = UserDefaults.standard.integer(forKey: "peercount")
                if (peer >= 1) {
                    this.statusBackgroud.backgroundColor = UIColor(hex: "#2DD8A3")
                    this.connectionStatus.text = "Synced with \(peer) peer(s)"
                    this.blockInfo.text = "Latest Block \(bestblocktemp)"
                    this.chainStatus.text = this.calculateTime(millis: Int64(NSDate().timeIntervalSince1970) - lastblocktime!)
                } else {
                    this.statusBackgroud.backgroundColor = UIColor(hex: "#555555", alpha: 0.4)
                    this.connectionStatus.text = "Connecting to peers"
                    this.blockInfo.text = "Latest Block \(bestblocktemp)"
                    this.chainStatus.text = this.calculateTime(millis: Int64(NSDate().timeIntervalSince1970) - lastblocktime!)
                }
            }
        }
    }
    
    func calculateTime(millis: Int64) -> String {
        var millis2 = millis
        if(millis2 > 59){
            millis2 /= 60
            if (millis2 > 59){
                millis2 /= 60
                if(millis2 > 23){
                    millis2 /= 24
                    //days
                    return String(millis2).appending("d ago")
                }
                //hour
                return String(millis2).appending("h ago")
            }
            //minute
            return String(millis2).appending("m ago")
        }
        //seconds
        return String(millis2).appending("s ago")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.layoutIfNeeded()
    }
    
    func changeViewController(_ menu: LeftMenu) {
        DispatchQueue.main.async{
            switch menu {
            case .overview:
                self.slideMenuController()?.changeMainViewController(self.mainViewController, close: true)
                
                if (self.accountViewController != nil) {
                    self.accountViewController.dismiss(animated: true, completion: nil)
                    self.accountViewController = nil
                }
                
                if( self.sendViewController != nil) {
                    self.sendViewController.dismiss(animated: true, completion: nil)
                    self.sendViewController = nil
                }
                
            case .accounts:
                
                let accountViewController = self.storyboard2?.instantiateViewController(withIdentifier: "AccountViewController") as! AccountViewController
                self.accountViewController = UINavigationController(rootViewController: accountViewController)
                
                self.slideMenuController()?.changeMainViewController(self.accountViewController, close: true)
                if (self.sendViewController != nil) {
                    self.sendViewController.dismiss(animated: true, completion: nil)
                    self.sendViewController = nil
                }
                
            case .send:
                
                let sendViewController = self.storyboard2?.instantiateViewController(withIdentifier: "SendViewController") as! SendViewController
                self.sendViewController = UINavigationController(rootViewController: sendViewController)
                self.slideMenuController()?.changeMainViewController(self.sendViewController, close: true)
                
                if (self.accountViewController != nil) {
                    self.accountViewController.dismiss(animated: true, completion: nil)
                    self.accountViewController = nil
                }
                
            case .receive:
                
                let goViewController = self.storyboard2?.instantiateViewController(withIdentifier: "ReceiveViewController") as! ReceiveViewController
                self.receiveViewController = UINavigationController(rootViewController: goViewController)
                self.slideMenuController()?.changeMainViewController(self.receiveViewController, close: true)
                if (self.accountViewController != nil) {
                    self.accountViewController.dismiss(animated: true, completion: nil)
                    self.accountViewController = nil
                }
                
                if (self.sendViewController != nil) {
                    self.sendViewController.dismiss(animated: true, completion: nil)
                    self.sendViewController = nil
                }
                
            case .settings:
                
                let settingsController = self.storyboard2.instantiateViewController(withIdentifier: "SettingsController2") as! SettingsController
                settingsController.delegate = self
                self.settingsViewController = UINavigationController(rootViewController: settingsController)
                self.slideMenuController()?.changeMainViewController(self.settingsViewController, close: true)
                
                if (self.accountViewController != nil) {
                    self.accountViewController.dismiss(animated: true, completion: nil)
                    self.accountViewController = nil
                    
                }
                if (self.sendViewController != nil) {
                    self.sendViewController.dismiss(animated: true, completion: nil)
                    self.sendViewController = nil
                }
                
            case .history:
                
                let trController = TransactionHistoryViewController(nibName: "TransactionHistoryViewController", bundle: nil) as TransactionHistoryViewController?
                trController?.delegate = self
                self.historyViewController = UINavigationController(rootViewController: trController!)
                self.slideMenuController()?.changeMainViewController(self.historyViewController, close: true)
                
                if (self.accountViewController != nil) {
                    self.accountViewController.dismiss(animated: true, completion: nil)
                    self.accountViewController = nil
                }
                
                if (self.sendViewController != nil) {
                    self.sendViewController.dismiss(animated: true, completion: nil)
                    self.sendViewController = nil
                }
                
            case .help:
                
                let helpViewController  = self.storyboard2.instantiateViewController(withIdentifier: "HelpViewController") as! HelpViewController
                self.helpViewController = UINavigationController(rootViewController: helpViewController)
                self.slideMenuController()?.changeMainViewController(self.helpViewController, close: true)
                
                if (self.accountViewController != nil) {
                    self.accountViewController.dismiss(animated: true, completion: nil)
                    self.accountViewController = nil
                }
                
                if (self.sendViewController != nil) {
                    self.sendViewController.dismiss(animated: true, completion: nil)
                    self.sendViewController = nil
                }
                
            case .security:
                
                let SecurityViewController = self.storyboard2?.instantiateViewController(withIdentifier: "SecurityMenuViewController") as! SecurityMenuViewController
                self.securityMenuViewController = UINavigationController(rootViewController: SecurityViewController)
                self.slideMenuController()?.changeMainViewController(self.securityMenuViewController, close: true)
                if (self.accountViewController != nil) {
                    self.accountViewController.dismiss(animated: true, completion: nil)
                    self.accountViewController = nil
                }
                
                if (self.sendViewController != nil) {
                    self.sendViewController.dismiss(animated: true, completion: nil)
                    self.sendViewController = nil
                }
            }
        }
    }
}

extension LeftViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let menu = LeftMenu(rawValue: indexPath.row) {
            switch menu {
            case .overview, .history, .send, .receive, .accounts, .security, .settings, .help:
                return MenuCell.height()
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let menu = LeftMenu(rawValue: indexPath.row) {
            self.selectedIndex = indexPath.row
            if(self.selectedIndex == 6){
                self.selectedIndex = 0
            }
            self.tableView.reloadData()
            self.changeViewController(menu)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {}
}

extension LeftViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let menu = LeftMenu(rawValue: indexPath.row) {
            switch menu {
            case .overview, .history, .send, .receive, .accounts, .security, .settings, .help:
                
                tableView.register(UINib(nibName: MenuCell.identifier, bundle: nil), forCellReuseIdentifier: MenuCell.identifier)
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "MenuCell") as! MenuCell
                
                cell.setData(menus[indexPath.row])
                
                if (self.selectedIndex == indexPath.row) {
                    cell.backView.backgroundColor = UIColor.white
                    cell.lblMenu.textColor = UIColor.black
                } else {
                    cell.backView.backgroundColor = GlobalConstants.Colors.menuCell
                    cell.lblMenu.textColor = GlobalConstants.Colors.menuTitle
                }
                cell.selectedView.isHidden = (self.selectedIndex == indexPath.row) ? false : true
                return cell
            }
        }
        return UITableViewCell()
    }
}
