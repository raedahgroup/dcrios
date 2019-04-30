//
//  SecurityViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class SecurityViewController: UIViewController {
    // "Password" or "Pin" will be appended to the title depending on what tab is activated
    var pageTitlePrefix = "Create Spending"
    
    // This will be triggered after a pin or password is provided by the user.
    var onUserEnteredPinOrPassword: ((_ pinOrPassword: String, _ securityType: String) -> Void)?
    
    var pager: UITabBarController?
    @IBOutlet weak var btnPin: UIButton!
    @IBOutlet weak var btnPassword: UIButton!
    
    @IBAction func onPasswordTab(_ sender: Any) {
        pager?.selectedIndex = 0
        btnPassword.backgroundColor = #colorLiteral(red: 0.9529411765, green: 0.9607843137, blue: 0.9647058824, alpha: 1)
        btnPin.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    @IBAction func onPinTab(_ sender: Any) {
        pager?.selectedIndex = 1
        btnPin.backgroundColor = #colorLiteral(red: 0.9529411765, green: 0.9607843137, blue: 0.9647058824, alpha: 1)
        btnPassword.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedPager" {
            pager = segue.destination as? UITabBarController
            pager?.tabBar.isHidden = true
            
            let passwordTabVC = pager?.viewControllers?.first as? PasswordSetupViewController
            passwordTabVC?.pageTitle = "\(self.pageTitlePrefix) Password"
            passwordTabVC?.onUserEnteredPassword = { password in
                self.onUserEnteredPinOrPassword?(password, "PASSWORD")
            }
            
            let pinTabVC = pager?.viewControllers?.last as? RequestPinViewController
            pinTabVC?.prompt = "\(self.pageTitlePrefix) PIN"
            pinTabVC?.requestPinConfirmation = true
            pinTabVC?.onUserEnteredPin = { pin in
                self.onUserEnteredPinOrPassword?(pin, "PIN")
            }
        }
    }
}
