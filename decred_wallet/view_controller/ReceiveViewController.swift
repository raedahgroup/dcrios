//  ReceiveViewController.swift
//  Decred Wallet

// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit

class ReceiveViewController: UIViewController,UIDocumentInteractionControllerDelegate {
    
    @IBOutlet private var accountDropdown: DropMenuButton!
    @IBOutlet private var imgWalletAddrQRCode: UIImageView!
    @IBOutlet weak var generateButton: UIButton!
    @IBOutlet var walletAddress: UIButton!
    
    var firstTrial = true
    var starttime: Int64 = 0
    var myacc: AccountsEntity!
    var account: GetAccountResponse?
    var tapGesture = UITapGestureRecognizer()
    
    private var selectedAccount = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TAP Gesture
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.CopyImgAddress(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        imgWalletAddrQRCode.addGestureRecognizer(tapGesture)
        imgWalletAddrQRCode.isUserInteractionEnabled = true
        self.generateButton.layer.cornerRadius = 6
        self.accountDropdown.backgroundColor = UIColor.white
        self.showFirstWalletAddressAndQRCode()
        self.populateWalletDropdownMenu()
        self.starttime = Int64(NSDate().timeIntervalSince1970)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBarItem()
        navigationItem.title = "Receive"
        let shareBtn = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
        self.navigationItem.rightBarButtonItems = [shareBtn]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction private func generateNewAddress() {
        self.getNextAddress(accountNumber: (self.myacc.Number))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    private func showFirstWalletAddressAndQRCode() {
        
        self.account?.Acc.removeAll()
        do{
            let strAccount = try SingleInstance.shared.wallet?.getAccounts(0)
            self.account = try JSONDecoder().decode(GetAccountResponse.self, from: (strAccount?.data(using: .utf8))!)
        } catch let error{
            print(error)
        }
        
        let acc = self.account?.Acc
        if (acc != nil) {
            let accNames: [String] = (self.account?.Acc.map({ $0.Name }))!
            self.myacc = self.account?.Acc.first
            
            if let firstWalletAddress = accNames.first {
                self.selectedAccount = firstWalletAddress
                self.accountDropdown.setTitle(self.selectedAccount, for: .normal)
                self.getAddress(accountNumber: (self.myacc.Number))
            }
        } else {
            print("no account")
        }
    }
    
    @IBAction func tapCopy(_ sender: Any) {
        self.copyAddress()
    }
    @IBAction func CopyImgAddress(_ sender: UITapGestureRecognizer) {
        self.copyAddress()
    }
    
    private func copyAddress() {
        DispatchQueue.main.async {
            //Copy a string to the pasteboard.
            UIPasteboard.general.string = self.walletAddress.currentTitle
            
            //Alert
            let alertController = UIAlertController(title: "", message: "Wallet address copied", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func populateWalletDropdownMenu() {
        
        self.account?.Acc.removeAll()
        do{
            let strAccount = try SingleInstance.shared.wallet?.getAccounts(0)
            self.account = try JSONDecoder().decode(GetAccountResponse.self, from: (strAccount?.data(using: .utf8))!)
        } catch let error{
            print(error)
        }
        
        if let defaultAccount = account?.Acc.filter({ $0.isDefaultWallet}).first {
            
            accountDropdown.setTitle(
                defaultAccount.Name,
                for: UIControlState.normal
            )
            self.accountDropdown.backgroundColor = UIColor.white
        }
        
        let accNames: [String] = (self.account?.Acc.map({ $0.Name }))!
        
        accountDropdown.initMenu(
            accNames
        ) { [weak self] _, val in
            guard let this = self else { return }
            this.selectedAccount = val
            if self?.account?.Acc.filter({ $0.Name == val }).first != nil {
                self?.myacc = self?.account?.Acc.map({ $0 }).first
                self?.getAddress(accountNumber: (self?.myacc.Number)!)
            }
        }
    }
    
    @objc func share(){
        self.shareImgOnTap()
    }
    
    @objc func getNext(){
        self.getNextAddress(accountNumber: self.myacc.Number)
    }
    
    func shareImgOnTap(){
        let imgcopy = self.walletAddress.currentTitle!
        let activityController = UIActivityViewController(activityItems: [imgcopy], applicationActivities: nil)
        
        activityController.completionWithItemsHandler = { (nil, completed, _, error) in
            
        }
        present(activityController, animated: true){
            
        }
    }
    
    private func getAddress(accountNumber : Int32){
        
        let receiveAddress = try?SingleInstance.shared.wallet?.currentAddress(Int32(accountNumber))
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            
            this.walletAddress.setTitle(receiveAddress!, for: .normal)
            this.imgWalletAddrQRCode.image = generateQRCodeFor(
                with: receiveAddress!!,
                forImageViewFrame: this.imgWalletAddrQRCode.frame
            )
        }
    }
    
    @objc private func getNextAddress(accountNumber : Int32){
        
        let receiveAddress = try?SingleInstance.shared.wallet?.nextAddress(Int32(accountNumber))
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            
            this.walletAddress.setTitle(receiveAddress!, for: .normal)
            this.imgWalletAddrQRCode.image = generateQRCodeFor(
                with: receiveAddress!!,
                forImageViewFrame: this.imgWalletAddrQRCode.frame
            )
        }
    }
}
