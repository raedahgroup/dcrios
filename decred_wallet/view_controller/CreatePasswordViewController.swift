//
//  CreatePasswordViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import JGProgressHUD
import Dcrlibwallet

class CreatePasswordViewController: UIViewController, SeedCheckupProtocol, UITextFieldDelegate {
    
    var seedToVerify: String?
    
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfVerifyPassword: UITextField!
    @IBOutlet weak var btnEncrypt: UIButton!
    
    var progressHud : JGProgressHUD?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tfPassword.delegate = self
        tfVerifyPassword.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        validatePassword()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        validatePassword()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func validatePassword(){
        btnEncrypt.isEnabled = (tfPassword.text == tfVerifyPassword.text) && !(tfPassword.text?.isEmpty)!
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onEncrypt(_ sender: Any) {
        
        progressHud = showProgressHud(with: "creating wallet...")
        
        let seed = self.seedToVerify!
        let pass = self.tfPassword!.text
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let this = self else { return }
            
            do {
                if SingleInstance.shared.wallet == nil {
                    return
                }
                try SingleInstance.shared.wallet?.createWallet(pass, seedMnemonic: seed)
                DispatchQueue.main.async {
                    self!.progressHud?.dismiss()
                    UserDefaults.standard.set(pass, forKey: "password")
                    createMainWindow()
                    this.dismiss(animated: true, completion: nil)
                }
                return
            } catch let error {
                DispatchQueue.main.async {
                    self!.progressHud!.dismiss()
                    this.showError(error: error)
                    print("wallet error")
                    print(error)
                }
            }
        }
    }
    
    func showError(error:Error){
        let alert = UIAlertController(title: "Warning", message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            alert.dismiss(animated: true, completion: {self.navigationController?.popToRootViewController(animated: true)})
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: {self.progressHud!.dismiss()})
    }
}
