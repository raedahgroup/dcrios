//
//  PeerSetTableViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class PeerSetTableViewController: UITableViewController {
    
    @IBOutlet weak var peer_ip: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.removeNavigationBarItem()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        self.navigationItem.title = "Connect to peer"
        // Do any additional setup after loading the view.
        peer_ip?.text = UserDefaults.standard.string(forKey: "pref_peer_ip") ?? "0.0.0.0"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.peer_ip.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func save() -> Void {
        // save here
        if !(peer_ip.text?.isEmpty)! && isValidIP(s: peer_ip.text!){
            UserDefaults.standard.set(peer_ip.text, forKey: "pref_peer_ip")
            UserDefaults.standard.synchronize()
            self.navigationController?.popViewController(animated: true)
        } else {
            self.showMessage(title: "Invalid input", userMessage: "please input a valid IP address", buttonTitle: "ok")
        }
    }
    
    @objc func cancel() -> Void {
        self.navigationController?.popViewController(animated: true)
    }
    
    func showMessage(title: String,userMessage : String, buttonTitle button:String) {
        
        let uiAlert = UIAlertController(title: title, message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        let uiAction = UIAlertAction(title: button, style: UIAlertActionStyle.default, handler: nil)
        
        uiAlert.addAction(uiAction)
        
        self.present(uiAlert, animated: true, completion: nil)
    }
    
    func isValidIP(s: String) -> Bool {
        let parts = s.components(separatedBy: ".")
        let nums = parts.flatMap { Int($0) }
        return parts.count == 4 && nums.count == 4 && nums.filter { $0 >= 0 && $0 < 256}.count == 4
    }
}
