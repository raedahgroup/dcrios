//
//  PinSetupViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import JGProgressHUD
import Dcrlibwallet

class PinSetupViewController: UIViewController, SeedCheckupProtocol, StartUpPasswordProtocol, PinEnteredProtocol {
    
    var very = false
    var pinInput: String?
    var senders: String?
    var pass_pinToVerify: String?
    var seedToVerify: String?
    var VerifyPin = ""
    var pin: String = "" {
        didSet {
            print("triggered")
            pinMarks.entered = pin.count
            pinMarks.update()
            prgsPinStrength.progressTintColor = pinStrength.strengthColor(forPin: pin)
            prgsPinStrength.progress = pinStrength.strength(forPin: pin)
            pinMarks.alignment = .center
            if pin.count > 0{
                self.btnCommit.isEnabled = true
            }
            else{
                self.btnCommit.isEnabled = false
            }
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
    
    var seconds = 1
    var timer = Timer()
    
    @IBOutlet weak var headerText: UILabel!
    @IBOutlet weak var pinMarks: PinMarksView!
    @IBOutlet weak var prgsPinStrength: UIProgressView!
    @IBOutlet weak var btnCommit: UIButton!
    
    var progressHud: JGProgressHUD?
    var pinStrength = PinWeakness()
    let pinInputController = PinInputController(max: Int(LONG_LONG_MAX))
    
    override func viewDidLoad() {
        setHeader()
        prgsPinStrength.layer.cornerRadius = 25
    }
    
    @IBAction func on1(_ sender: Any) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        pin = pinInputController.input(digit: 1)
    }
    
    @IBAction func on2(_ sender: Any) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        pin = pinInputController.input(digit: 2)
    }
    
    @IBAction func on3(_ sender: Any) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        pin = pinInputController.input(digit: 3)
    }
    
    @IBAction func on4(_ sender: Any) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        pin = pinInputController.input(digit: 4)
    }
    
    @IBAction func on5(_ sender: Any) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        pin = pinInputController.input(digit: 5)
    }
    
    @IBAction func on6(_ sender: Any) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        pin = pinInputController.input(digit: 6)
    }
    
    @IBAction func on7(_ sender: Any) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        pin = pinInputController.input(digit: 7)
    }
    
    @IBAction func on8(_ sender: Any) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        pin = pinInputController.input(digit: 8)
    }
    
    @IBAction func on9(_ sender: Any) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        pin = pinInputController.input(digit: 9)
    }
    
    @IBAction func on0(_ sender: Any) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        pin = pinInputController.input(digit: 0)
    }
    
    @IBAction func onBackspace(_ sender: Any) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        pin = pinInputController.backspace()
    }
    
    @IBAction func onCommit(_ sender: Any) {
        if (senders == "launcher") {
            pass_PIn_Unlock()
        } else if (senders == "settings") {
            if (UserDefaults.standard.bool(forKey: "secure_wallet")) {
                RemovestartupPin_pas()
            } else{
                if very {
                    if pin.elementsEqual(VerifyPin) {
                        SetstartupPin_pas()
                    } else {
                        self.headerText.text = "PINs do not match. Try again"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.pin = self.pinInputController.clear()
                            self.VerifyPin = ""
                            self.headerText.text = "Create Startup PIN"
                            self.very = false
                        }
                    }
                }
                else{
                    VerifyPin = pin
                    pin = pinInputController.clear()
                    headerText.text = "Confirm Startup PIN"
                    very = true
                }
            }
        } else if (senders == "settingsChangeSpending") {
            if very {
                if pin.elementsEqual(VerifyPin){
                    ChangeSpendingPIN()
                } else {
                    self.headerText.text = "PINs do not match. Try again"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.pin = self.pinInputController.clear()
                        self.VerifyPin = ""
                        self.headerText.text = "Change Spending PIN"
                        self.very = false
                    }
                }
            } else {
                VerifyPin = pin
                pin = pinInputController.clear()
                headerText.text = "Confirm Spending PIN"
                very = true
            }
        } else if (senders == "settingsChangeSpendingPin") {
            let sendVC = storyboard!.instantiateViewController(withIdentifier: "SecurityViewController") as! SecurityViewController
            sendVC.senders = "settingsChangeSpending"
            sendVC.pass_pinToVerify = self.pin
            self.navigationController?.pushViewController(sendVC, animated: true)
        } else if (senders == "spendFund") {
            pinInput = pin
            UserDefaults.standard.set(pin, forKey: "TMPPIN") //deeply concern about
            UserDefaults.standard.synchronize()
            print(pinInput as Any)
            self.navigationController?.popViewController(animated: true)
        } else {
            if very {
                if pin.elementsEqual(VerifyPin){
                    createWallet()
                } else{
                    self.headerText.text = "PINs do not match. Try again"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.pin = self.pinInputController.clear()
                        self.VerifyPin = ""
                        self.headerText.text = "Create Spending PIN"
                        self.very = false
                    }
                }
            } else {
                VerifyPin = pin
                pin = pinInputController.clear()
                headerText.text = "Confirm Spending PIN"
                very = true
            }
        }
    }
    
    
    func setHeader(){
        if (senders == "launcher") {
            headerText.text = "Enter Startup PIN"
        } else if (senders == "settings") {
            if (UserDefaults.standard.bool(forKey: "secure_wallet")){
                headerText.text = "Enter Current PIN"
            } else {
                headerText.text = "Create Startup PIN"
            }
        } else if (senders == "settingsChangeSpending") {
            headerText.text = "Change Spending PIN"
        } else if (senders == "settingsChangeSpendingPin") {
            headerText.text = "Enter Spending PIN"
        } else if (senders == "spendFund") {
            headerText.text = "Input Spending PIN"
        } else {
            headerText.text = "Create Spending PIN"
        }
    }
    
    func createWallet(){
        
        progressHud = showProgressHud(with: "creating wallet...")
        
        let seed = self.seedToVerify!
        let pass = self.pin
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let this = self else { return }
            
            do {
                if SingleInstance.shared.wallet == nil {
                    return
                }
                
                try SingleInstance.shared.wallet?.createWallet(pass, seedMnemonic: seed)
                DispatchQueue.main.async {
                    self!.progressHud!.dismiss()
                    // TODO: do not save password in defaults
                    UserDefaults.standard.set(pass, forKey: "password") //deeply concern about
                    UserDefaults.standard.set("PIN", forKey: "spendingSecureType") // this stuff
                    UserDefaults.standard.synchronize()
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
    
    func SetstartupPin_pas(){
        progressHud = showProgressHud(with: "securing wallet...")
        
        let insecurePublicPass = ("public" as NSString).data(using: String.Encoding.utf8.rawValue)!
        let pass = (self.pin as NSString).data(using: String.Encoding.utf8.rawValue)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let this = self else { return }
            
            do {
                try SingleInstance.shared.wallet?.changePublicPassphrase(insecurePublicPass, newPass: pass)
                DispatchQueue.main.async {
                    this.progressHud?.dismiss()
                    UserDefaults.standard.set(true, forKey: "secure_wallet")
                    UserDefaults.standard.setValue("PIN", forKey: "securitytype")
                    UserDefaults.standard.synchronize()
                    self?.dismissView()
                }
                return
            } catch let error {
                DispatchQueue.main.async {
                    this.progressHud?.dismiss()
                    this.showError(error: error)
                }
            }
        }
    }
    
    func dismissView() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func pass_PIn_Unlock(){
        
        progressHud = showProgressHud(with: "Opening wallet")
        
        let finalkeypassData = (self.pin as NSString).data(using: String.Encoding.utf8.rawValue)!
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let this = self else { return }
            
            do {
                try SingleInstance.shared.wallet?.open(finalkeypassData)
                DispatchQueue.main.async {
                    this.progressHud?.dismiss()
                    self!.createMenu()
                }
                return
            } catch let error {
                DispatchQueue.main.async {
                    this.progressHud?.dismiss()
                    this.showError(error: error)
                }
            }
        }
    }
    
    func ChangeSpendingPIN(){
        
        progressHud = showProgressHud(with: "Changing spending PIN...")
        
        let finalkeyData = (pass_pinToVerify! as NSString).data(using: String.Encoding.utf8.rawValue)!
        let finalkeypassData = (self.pin as NSString).data(using: String.Encoding.utf8.rawValue)!
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let this = self else { return }
            
            do {
                try SingleInstance.shared.wallet?.changePrivatePassphrase(finalkeyData, newPass: finalkeypassData)
                DispatchQueue.main.async {
                    this.progressHud?.dismiss()
                    UserDefaults.standard.setValue("PIN", forKey: "spendingSecureType")
                    UserDefaults.standard.synchronize()
                    self?.dismissView()
                }
                return
            } catch let error {
                DispatchQueue.main.async {
                    this.progressHud?.dismiss()
                    this.showError(error: error)
                }
            }
        }
    }
    
    func RemovestartupPin_pas(){
        progressHud = showProgressHud(with: "Removing Security")
        let key = "public"
        let finalkey = key as NSString
        let finalkeyData = finalkey.data(using: String.Encoding.utf8.rawValue)!
        let pass = self.pin
        let finalpass = pass as NSString
        let finalkeypassData = finalpass.data(using: String.Encoding.utf8.rawValue)!
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let this = self else { return }
            
            do {
                try SingleInstance.shared.wallet?.changePublicPassphrase(finalkeypassData, newPass: finalkeyData)
                DispatchQueue.main.async {
                    this.progressHud?.dismiss()
                    UserDefaults.standard.set(false, forKey: "secure_wallet")
                    UserDefaults.standard.synchronize()
                    self?.dismissView()
                }
                return
            } catch let error {
                DispatchQueue.main.async {
                    this.progressHud?.dismiss()
                    this.showError(error: error)
                }
            }
        }
    }
    
    func createMenu(){
        createMainWindow()
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
