//
//  ServerSetTableViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class ServerSetTableViewController: UITableViewController {
    
    @IBOutlet weak var server_ip: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.blue
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        self.navigationItem.title = LocalizedStrings.serverAddress
        server_ip?.text = "" // deprecated in v2
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.server_ip.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func save() -> Void {
        // no longer saving full node server ip, feature deprecated in v2
    }
    
    @objc func cancel() -> Void {
        self.navigationController?.popViewController(animated: true)
    }
    
    func showMessage(title: String,userMessage : String, buttonTitle button:String) {
        
        let uiAlert = UIAlertController(title: title, message: userMessage, preferredStyle: UIAlertController.Style.alert)
        let uiAction = UIAlertAction(title: button, style: UIAlertAction.Style.default, handler: nil)
        
        uiAlert.addAction(uiAction)
        
        self.present(uiAlert, animated: true, completion: nil)
    }
    
    func isValidIP(s: String) -> Bool {
        let parts = s.components(separatedBy: ".")
        let nums = parts.compactMap { Int($0) }
        return parts.count == 4 && nums.count == 4 && nums.filter { $0 >= 0 && $0 < 256}.count == 4
    }
}
