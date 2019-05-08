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

    @IBOutlet weak var subheader: UILabel!
    @IBOutlet weak var lblWalletAddress: UILabel!
    
    private var barButton: UIBarButtonItem?
    
    var firstTrial = true
    var starttime: Int64 = 0
    var myacc: AccountsEntity!
    var account: GetAccountResponse?
    var tapGesture = UITapGestureRecognizer()
    var oldAddress = ""
    var wallet = SingleInstance.shared.wallet
    
    private var selectedAccount = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.subheader.text = "Each time you request a payment, a new address is created to protect your privacy."
        // TAP Gesture
        self.setupExtraUI()
               self.showFirstWalletAddressAndQRCode()
        self.populateWalletDropdownMenu()
        self.starttime = Int64(NSDate().timeIntervalSince1970)
    }
    
    func setupExtraUI(){
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.CopyImgAddress(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        imgWalletAddrQRCode.addGestureRecognizer(tapGesture)
        imgWalletAddrQRCode.isUserInteractionEnabled = true
        self.accountDropdown.backgroundColor = UIColor.white
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBarItem()
        navigationItem.title = "Receive"
        let shareBtn = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
        let generateAddressBtn = UIButton(type: .custom)
        generateAddressBtn.setImage(UIImage(named: "right-menu"), for: .normal)
        generateAddressBtn.addTarget(self, action: #selector(showMenu), for: .touchUpInside)
        generateAddressBtn.frame = CGRect(x: 0, y: 0, width: 10, height: 51)
        barButton = UIBarButtonItem(customView: generateAddressBtn)
        self.navigationItem.rightBarButtonItems = [barButton!, shareBtn ]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func showMenu(sender: Any){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let generateNewAddressAction = UIAlertAction(title: "Generate new address", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.generateNewAddress()
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(generateNewAddressAction)
        
        if let popoverPresentationController = alertController.popoverPresentationController {
            popoverPresentationController.barButtonItem = barButton
        }

        self.present(alertController, animated: true, completion: nil)
    }
    
    private func generateNewAddress() {
        self.oldAddress = self.lblWalletAddress.text!
        self.getNextAddress(accountNumber: (self.myacc.Number))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    private func showFirstWalletAddressAndQRCode() {
        
        self.account?.Acc.removeAll()
        do{
            var getAccountError: NSError?
            let strAccount = self.wallet?.getAccounts(0, error: &getAccountError)
            if getAccountError != nil {
                throw getAccountError!
            }
            
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
    
    @IBAction func CopyImgAddress(_ sender: UITapGestureRecognizer) {
        self.copyAddress()
    }
    
    private func copyAddress() {
        DispatchQueue.main.async {
            //Copy a string to the pasteboard.
            UIPasteboard.general.string = self.lblWalletAddress.text!
            
            //Alert
            let alertController = UIAlertController(title: "", message: "Wallet address copied", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func populateWalletDropdownMenu() {
        
        self.account?.Acc.removeAll()
        do{
            var getAccountError: NSError?
            let strAccount = self.wallet?.getAccounts(0, error: &getAccountError)
            if getAccountError != nil {
                throw getAccountError!
            }
            self.account = try JSONDecoder().decode(GetAccountResponse.self, from: (strAccount?.data(using: .utf8))!)
        } catch let error{
            print(error)
        }
        
        if let defaultAccount = account?.Acc.filter({ $0.isDefaultWallet}).first {
            
            accountDropdown.setTitle(
                defaultAccount.Name,
                for: UIControl.State.normal
            )
            self.accountDropdown.backgroundColor = UIColor.white
        }
        
        let accNames: [String] = (self.account?.Acc.filter({UserDefaults.standard.bool(forKey: "hidden\($0.Number)")  != true && $0.Number != INT_MAX }).map({ $0.Name }))!
        
        accountDropdown.initMenu(
            accNames
        ) { [weak self] _, val in
            guard let this = self else { return }
            this.selectedAccount = val
            if self?.account?.Acc.filter({ $0.Name == val }).first != nil {
                print("value is \(val)")
                self?.myacc = self?.account?.Acc.filter({ $0.Name == val }).map({ $0 }).first
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
        
        var img: UIImage = self.imgWalletAddrQRCode.image!
        
        if img.cgImage == nil {
            guard let ciImage = img.ciImage, let cgImage = CIContext(options: nil).createCGImage(ciImage, from: ciImage.extent) else {return}
            img = UIImage(cgImage: cgImage)
        }

        let activityController = UIActivityViewController(activityItems: [img], applicationActivities: nil)
        activityController.completionWithItemsHandler = { (nil, completed, _, error) in

        }
        present(activityController, animated: true){

        }
    }
    
    private func getAddress(accountNumber : Int32) {
        let receiveAddress = self.wallet?.currentAddress(Int32(accountNumber), error: nil)
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            
            this.lblWalletAddress.text = receiveAddress!
            this.imgWalletAddrQRCode.image = generateQRCodeFor(
                with: receiveAddress!,
                forImageViewFrame: this.imgWalletAddrQRCode.frame
            )
        }
    }
    
    @objc private func getNextAddress(accountNumber : Int32){
        let receiveAddress = self.wallet?.nextAddress(Int32(accountNumber), error: nil)
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            if (this.oldAddress != receiveAddress!) {
                this.lblWalletAddress.text = receiveAddress!
                this.imgWalletAddrQRCode.image = generateQRCodeFor(
                    with: receiveAddress!,
                    forImageViewFrame: this.imgWalletAddrQRCode.frame
                )
                return
            }
            else{
                self!.getNext()
            }
            
        }
       
    }
}
