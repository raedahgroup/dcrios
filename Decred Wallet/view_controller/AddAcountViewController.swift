//
//  AddAcountViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import JGProgressHUD

class AddAcountViewController: UIViewController {
    
    @IBOutlet weak var passphrase: UITextField!
    @IBOutlet weak var accountName: UITextField!
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var createBtnTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createBtn.layer.cornerRadius = 6
        self.accountName.placeholder = LocalizedStrings.accountName
        self.passphrase.placeholder = LocalizedStrings.privatePassphrase
        
        if SpendingPinOrPassword.currentSecurityType() != SecurityType.password.rawValue {
            passphrase.isHidden = true
            createBtnTopConstraint.constant = -40
        }
    }

    @IBAction func createFnc(_ sender: Any) {
        if (accountName.text?.length)! < 1 {
            Info(msg: LocalizedStrings.inputAccountName)
            return
        }
        
        let name = accountName.text
        if(!(name!.isEmpty)) {
            if SpendingPinOrPassword.currentSecurityType() == SecurityType.password.rawValue {
                addAccountWithoutPin()
            } else {
                Security.spending().with(prompt: LocalizedStrings.confirmToCreate).requestSecurityCode(sender: self) {
                    pin, _, completion in
                    self.addAccountWithPin(pin: pin as NSString, completion: completion)
                }
            }
        }
    }
    
    private func addAccountWithoutPin() {
        let pass = passphrase.text
        if !pass!.isEmpty {
            let passphrase = (self.passphrase.text! as NSString).data(using: String.Encoding.utf8.rawValue)!
            addAccount(passphrase: passphrase, completion: nil)
        }
    }

    private func addAccountWithPin(pin: NSString, completion: SecurityCodeRequestCompletionDelegate?) {
        let passphrase = pin.data(using: String.Encoding.utf8.rawValue)!
        addAccount(passphrase: passphrase, completion: completion)
    }

    private func addAccount(passphrase: Data, completion: SecurityCodeRequestCompletionDelegate?) {
        let progressHud = JGProgressHUD(style: .light)
        progressHud.shadow = JGProgressHUDShadow(color: .black, offset: .zero, radius: 5.0, opacity: 0.2)
        progressHud.textLabel.text = LocalizedStrings.creatingAccount
        progressHud.show(in: self.view)

        let accountName = self.accountName.text!

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // pass nil pointer as we don't need the account number
                try WalletLoader.shared.wallet?.nextAccount(accountName, privPass: passphrase, ret0_: nil)
                DispatchQueue.main.async {
                    progressHud.dismiss()
                    completion?.securityCodeProcessed()
                    self.dismiss(animated: true, completion: nil)
                }
            } catch {
                DispatchQueue.main.async {
                    progressHud.dismiss()
                    completion?.securityCodeError(errorMessage: error.localizedDescription)
                }
            }
        }
    }

    @IBAction func cancelBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showError(error: Error) {
        let alert = UIAlertController(title: LocalizedStrings.errorMsg, message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: LocalizedStrings.ok, style: .default)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func Info(msg: String) {
        let alert = UIAlertController(title: LocalizedStrings.info, message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: LocalizedStrings.ok, style: .default)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
