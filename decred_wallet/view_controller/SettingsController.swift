//
//  SettingsController.swift
//  Decred Wallet

// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.
import Foundation
import UIKit

protocol StartUpPasswordProtocol {
    var senders: String?{get set}
    var pass_pinToVerify:String?{get set}
}

class SettingsController: UITableViewController  {
    
    weak var delegate: LeftMenuProtocol?
    
    @IBOutlet weak var peer_cell: UIView!
    @IBOutlet weak var connectPeer_cell: UITableViewCell!
    @IBOutlet weak var server_cell: UITableViewCell!
    @IBOutlet weak var certificate_cell: UITableViewCell!
    @IBOutlet weak var serverAdd_label: UILabel!
    @IBOutlet weak var connect_ip_label: UILabel!
    @IBOutlet weak var certificat_label: UILabel!
    @IBOutlet weak var network_mode_subtitle: UILabel!
    @IBOutlet weak var network_mode: UITableViewCell!
    @IBOutlet weak var Start_Pin_cell: UITableViewCell!
    
    @IBOutlet weak var connect_peer_ip: UILabel!
    @IBOutlet weak var build: UILabel!
    @IBOutlet weak var version: UILabel!
    @IBOutlet weak var server_ip: UILabel!
    
    @IBOutlet weak var debu_msg: UISwitch!
    @IBOutlet weak var testnet_switch: UISwitch!
    @IBOutlet weak var spend_uncon_fund: UISwitch!
    @IBOutlet weak var incoming_notification_switch: UISwitch!
    @IBOutlet weak var start_Pin: UISwitch!
    
    var isFromLoader = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = UIColor.blue
        self.navigationItem.title = "Settings"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        connect_peer_ip?.text = UserDefaults.standard.string(forKey: "pref_peer_ip") ?? ""
        server_ip?.text = UserDefaults.standard.string(forKey: "pref_server_ip") ?? ""
        
        let network_value = UserDefaults.standard.integer(forKey: "network_mode")
        loadDate()
        if (network_value == 0) {
            network_mode_subtitle?.text = "Simplified Payment Verification"
            self.certificate_cell.isUserInteractionEnabled = false
            self.server_cell.isUserInteractionEnabled = false
            self.connectPeer_cell.isUserInteractionEnabled = true
            self.server_ip.textColor = UIColor.lightGray
            self.certificat_label.textColor = UIColor.lightGray
            self.connect_peer_ip.textColor = UIColor.darkText
            self.serverAdd_label.textColor = UIColor.lightGray
            self.connect_ip_label.textColor = UIColor.darkText
        } else if (network_value == 1) {
            network_mode_subtitle?.text = "Local Full Node"
            self.certificate_cell.isUserInteractionEnabled = false
            self.server_cell.isUserInteractionEnabled = false
            self.connectPeer_cell.isUserInteractionEnabled = true
            self.server_ip.textColor = UIColor.lightGray
            self.certificat_label.textColor = UIColor.lightGray
            self.connect_peer_ip.textColor = UIColor.darkText
            self.serverAdd_label.textColor = UIColor.lightGray
            self.connect_ip_label.textColor = UIColor.darkText
        } else {
            network_mode_subtitle?.text = "Remote Full Node"
            self.certificate_cell.isUserInteractionEnabled = true
            self.server_cell.isUserInteractionEnabled = true
            self.connectPeer_cell.isUserInteractionEnabled = false
            self.connect_peer_ip.textColor = UIColor.lightGray
            self.certificat_label.textColor = UIColor.darkText
            self.server_ip.textColor = UIColor.darkText
            self.serverAdd_label.textColor = UIColor.darkText
            self.connect_ip_label.textColor = UIColor.lightGray
        }
    }
    
    @objc func cancel() -> Void {
        if self.isFromLoader == true {
            self.navigationController?.navigationBar.isHidden = true
            self.navigationController?.popViewController(animated: true)
        } else {
            delegate?.changeViewController(LeftMenu.overview)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil, completion: { (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
            guard let vc = (self.slideMenuController()?.mainViewController as? UINavigationController)?.topViewController else {
                return
            }
            if vc.isKind(of: SettingsController.self) {
                self.slideMenuController()?.removeLeftGestures()
                self.slideMenuController()?.removeRightGestures()
            }
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadDate()-> Void {
        
        let network_value = UserDefaults.standard.integer(forKey: "network_mode")
        version?.text = UserDefaults.standard.string(forKey: "app_version") ?? "Pre-release"
        
        var compileDate:Date
        {
            let bundleName = Bundle.main.infoDictionary!["CFBundleName"] as? String ?? "Info.plist"
            if let infoPath = Bundle.main.path(forResource: bundleName, ofType: nil),
                let infoAttr = try? FileManager.default.attributesOfItem(atPath: infoPath),
                let infoDate = infoAttr[FileAttributeKey.creationDate] as? Date
            { return infoDate }
            return Date()
        }
        
        let dateformater = DateFormatter()
        dateformater.dateFormat = "yyyy-MM-dd"
        build?.text = dateformater.string(from: compileDate as Date)
        debu_msg?.setOn((UserDefaults.standard.bool(forKey: "pref_debug_switch") ), animated: false)
        spend_uncon_fund?.setOn(UserDefaults.standard.bool(forKey: "pref_spend_fund_switch"), animated: false)
        connect_peer_ip?.text = UserDefaults.standard.string(forKey: "pref_peer_ip") ?? ""
        server_ip?.text = UserDefaults.standard.string(forKey: "pref_server_ip") ?? ""
        incoming_notification_switch?.setOn(UserDefaults.standard.bool(forKey: "pref_notification_switch"), animated: true)
        start_Pin?.setOn(UserDefaults.standard.bool(forKey: "secure_wallet") , animated: false)
        
        if (network_value == 0) {
            network_mode_subtitle?.text = "Simplified Payment Verification (SPV)"
        } else if(network_value == 1) {
            network_mode_subtitle?.text = "Local Full Node"
        } else {
            network_mode_subtitle?.text = "Remote Full Node"
        }
    }
    
    @objc func save() -> Void {
        UserDefaults.standard.set(incoming_notification_switch.isOn, forKey: "pref_notification_switch")
        UserDefaults.standard.set(spend_uncon_fund.isOn, forKey: "pref_spend_fund_switch")
        UserDefaults.standard.set(debu_msg.isOn, forKey: "pref_debug_switch")
        UserDefaults.standard.set(testnet_switch.isOn, forKey: "pref_use_testnet")
        UserDefaults.standard.synchronize()
        if (self.isFromLoader == true) {
            self.navigationController?.navigationBar.isHidden = true
            self.navigationController?.popViewController(animated: true)
        } else {
            delegate?.changeViewController(LeftMenu.overview)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SetstartupPin_pas"{
            var startUp = segue.destination as?
            StartUpPasswordProtocol
            startUp?.senders = "settings"
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 1) {
            if (indexPath.row == 1) {
                if (start_Pin.isOn) {
                    if (UserDefaults.standard.string(forKey: "securitytype") == "PASSWORD") {
                        let sendVC = storyboard!.instantiateViewController(withIdentifier: "StartUpPasswordViewController") as! StartUpPasswordViewController
                        sendVC.senders = "settings"
                        self.navigationController?.pushViewController(sendVC, animated: true)
                    } else {
                        let sendVC = storyboard!.instantiateViewController(withIdentifier: "PinSetupViewController") as! PinSetupViewController
                        sendVC.senders = "settings"
                        self.navigationController?.pushViewController(sendVC, animated: true)
                    }
                } else {
                    self.performSegue(withIdentifier: "SetstartupPin_pas", sender: self)
                }
            } else if (indexPath.row == 0) {
                if (UserDefaults.standard.string(forKey: "spendingSecureType") == "PASSWORD") {
                    let sendVC = storyboard!.instantiateViewController(withIdentifier: "StartUpPasswordViewController") as! StartUpPasswordViewController
                    sendVC.senders = "settingsChangeSpending"
                    self.navigationController?.pushViewController(sendVC, animated: true)
                } else {
                    let sendVC = storyboard!.instantiateViewController(withIdentifier: "PinSetupViewController") as! PinSetupViewController
                    sendVC.senders = "settingsChangeSpendingPin"
                    self.navigationController?.pushViewController(sendVC, animated: true)
                }
            }
        }
    }
}
