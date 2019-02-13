//
//  WalletLogViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import os

class WalletLogViewController: UIViewController {
    
    @IBOutlet weak var logTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Wallet Log"
        let testnetOn = UserDefaults.standard.bool(forKey: "pref_use_testnet")
        let logsType = testnetOn ? "testnet3" : "mainnet"
        load(log: logsType)
    }
    
    fileprivate func load(log:String){
        let logPath = NSHomeDirectory()+"/Documents/dcrwallet/logs/\(log)/dcrwallet.log"
        let logContent = try? String(contentsOf: URL(fileURLWithPath: logPath))
        let aLogs = logContent?.split(separator: "\n")
        var cutOffLogFlow = aLogs?.suffix(from: 0)
        if (aLogs?.count)! > 500 {
            cutOffLogFlow = aLogs?.suffix(from: (aLogs?.count)! - 500)
        }
        
        logTextView.text = cutOffLogFlow?.joined(separator: ";\n")
    }
}
