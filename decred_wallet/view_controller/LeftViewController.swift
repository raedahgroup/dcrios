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
    case account
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
    var timer = Timer()
    
    @IBOutlet weak var blockInfo: UILabel!
    @IBOutlet weak var connectionStatus: UILabel!
    @IBOutlet weak var rescanHeight: UILabel!
    @IBOutlet weak var bestblock: UILabel!
    @IBOutlet weak var chainStatus: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var LoadingImg: UIImageView!
    @IBOutlet weak var statusBackgroud: UIView!
    
    var menus = ["Overview","History", "Send", "Receive", "Account","Security", "Settings","Help"]
    
    var mainViewController: UIViewController!
    var accountViewController: UIViewController!
    var sendViewController: UIViewController!
    var receiveViewController: UIViewController!
    var settingsViewController: UIViewController!
    var historyViewController: UIViewController!
    var helpViewController:  UIViewController!
    var imageHeaderView: UIImageView?
    var securityMenuViewController:UIViewController!
    var selectedIndex: Int!
    var storyboard2: UIStoryboard!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedIndex = 0
        self.tableView.separatorColor = GlobalConstants.Colors.separaterGrey
        storyboard2 =  UIStoryboard(name: "Main", bundle: nil)
        self.tableView.registerCellClass(MenuCell.self)     
        imageHeaderView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width - 63, height: 80))
        imageHeaderView?.backgroundColor = UIColor(hex: "F9FBFA")
        imageHeaderView?.contentMode = .scaleAspectFit
        self.view.addSubview(self.imageHeaderView!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        imageHeaderView?.image = UserDefaults.standard.bool(forKey: "pref_use_testnet") ? UIImage(named: "logo-testnet") : UIImage(named: "logo-mainnet")
        
        self.scanning = UserDefaults.standard.bool(forKey: "walletScanning")
        self.sync = UserDefaults.standard.bool(forKey: "synced")
        self.runTimer()
    }
    
    func runTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(self.updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        self.loop()
    }
    
    func loop() {
        DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
            guard let this = self else { return }
            
            let bestblck = SingleInstance.shared.wallet?.getBestBlock()
            let bestblocktemp: Int64 = Int64(Int(bestblck!))
            let lastblocktime = SingleInstance.shared.wallet?.getBestBlockTimeStamp()
            let currentTime = NSDate().timeIntervalSince1970
            let estimatedBlocks = ((Int64(currentTime) - lastblocktime!) / 120) + bestblocktemp
            
            if estimatedBlocks > bestblocktemp {
                
                let peer = UserDefaults.standard.integer(forKey: "peercount")
                if (peer >= 1) {
                    this.bestblock.text = String(bestblocktemp).appending(" of ").appending(String(estimatedBlocks))
                    this.chainStatus.text = ""
                    this.blockInfo.text = "Fetched"
                    this.statusBackgroud.backgroundColor = UIColor(hex: "#2DD8A3")
                    this.connectionStatus.text = "Fetching Headers..."
                } else {
                    this.bestblock.text = String(bestblocktemp).appending(" of ").appending(String(estimatedBlocks))
                    this.chainStatus.text = ""
                    this.blockInfo.text = "Fetched"
                    this.statusBackgroud.backgroundColor = UIColor(hex: "#FFC84E")
                    this.connectionStatus.text = "Connecting to peers"
                }
            } else {
                if ((self?.sync)!) {
                    let peer = UserDefaults.standard.integer(forKey: "peercount")
                    if (peer >= 1) {
                        this.statusBackgroud.backgroundColor = UIColor(hex: "#2DD8A3")
                        this.connectionStatus.text = "Synced with \(peer) peer(s)"
                        this.bestblock.text = String(bestblocktemp)
                        this.blockInfo.text = "Latest Block"
                        this.chainStatus.text = this.calculateTime(millis: Int64(NSDate().timeIntervalSince1970) - lastblocktime!)
                    } else {
                        this.statusBackgroud.backgroundColor = UIColor(hex: "#FFC84E")
                        this.connectionStatus.text = "Connecting to peers"
                        this.bestblock.text = String(bestblocktemp)
                        this.blockInfo.text = "Latest Block"
                        this.chainStatus.text = this.calculateTime(millis: Int64(NSDate().timeIntervalSince1970) - lastblocktime!)
                    }
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
                
            case .account:
                
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
            case .overview, .history, .send, .receive, .account, .security, .settings, .help:
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
            case .overview, .history, .send, .receive, .account, .security, .settings, .help:
                
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
