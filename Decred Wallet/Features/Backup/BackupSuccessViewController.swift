//
//  BackupSuccessViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class BackupSuccessViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func onBackToOverview(_ sender: Any) {
        navigationController?.isNavigationBarHidden = false
        self.navigationController?.popToRootViewController(animated: true)
    }
}
