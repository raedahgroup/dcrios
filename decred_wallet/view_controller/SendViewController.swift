//
//  SendViewController.swift
//  Decred Wallet
//
//  Copyright (c) 2018-2019 The Decred developers
//  Use of this source code is governed by an ISC
//  license that can be found in the LICENSE file.
//

import QRCodeReader
import UIKit
import Dcrlibwallet
import SafariServices


class SendViewController: UIViewController, UITextFieldDelegate,UITextPasteDelegate, QRCodeReaderViewControllerDelegate {
    var pinInput: String?
    
    @IBOutlet weak var pasteBtn: UIButton!
    weak var delegate: LeftMenuProtocol?
    @IBOutlet var accountDropdown: DropMenuButton!
    @IBOutlet weak var toAccountDropDown: DropMenuButton!
    @IBOutlet var BalanceAfter: UILabel!
    @IBOutlet var estimateFee: UILabel!
    @IBOutlet var estimateSize: UILabel!
    @IBOutlet var walletAddress: UITextField!
    @IBOutlet var tfAmount: UITextField!
    @IBOutlet var sendAllBtn: UIButton!
    @IBOutlet weak var toAccountContainer: UIStackView!
    @IBOutlet weak var toAddressContainer: UIStackView!
    private var barButton: UIBarButtonItem?
    var removedBtn = true
    var wallet :DcrlibwalletLibWallet!
    
    @IBOutlet weak var sendNtwkErrtext: UILabel!
    @IBOutlet weak var amountErrorText: UILabel!
    @IBOutlet weak var addressErrorText: UILabel!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var qrcodeBtn: UIButton!
    var fromNotQRScreen = true
    var AccountFilter: [AccountsEntity]?
    
    @IBOutlet weak var conversionContHeight: NSLayoutConstraint!
    @IBOutlet weak var conversionRowCont: UIStackView!
    
    @IBOutlet weak var bottomCont: UIView!
    @IBOutlet weak var conversionFeeCont: UIStackView!
    
    
    @IBOutlet weak var sendInfoHeight: NSLayoutConstraint!
    
    @IBOutlet weak var exchangeRateCont: UIStackView!
    @IBOutlet weak var exchangeRateDisplay: UILabel!
    @IBOutlet weak var convertionFeeOther: UILabel!
    @IBOutlet weak var exchangeRateError: UIButton!
    @IBOutlet weak var currencyAmount2: AmountTextfield!
    
    private lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    var selectedAccount: AccountsEntity?
    var sendToAccount: AccountsEntity?
    var password: String?
    var sendAllTX = false
    var exchangeRateGloabal :NSDecimalNumber = 0.0
    var tempFee = "0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sendBtn.layer.cornerRadius = 5;
        self.accountDropdown.backgroundColor = UIColor.clear
        self.toAccountDropDown.backgroundColor = UIColor.clear
        self.tfAmount.delegate = self
        self.currencyAmount2.delegate = self
        self.pasteBtn.layer.cornerRadius = 4
        self.pasteBtn.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        wallet = SingleInstance.shared.wallet
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willEnterForegroundNotification, object: nil)
        self.walletAddress.delegate = self
        removedBtn = false
        let currency_value = UserDefaults.standard.integer(forKey: "currency")
        if(currency_value == 1){
            GetExchangeRate()
        }
        self.showDefaultAccount()
        self.removePasteBtn()
        self.checkpaste()
    }
    
    @objc func willResignActive() {
        if ((self.walletAddress.text?.count)! < 1) {
            self.checkpaste()
        }
    }
    
    private func clearFields() {
        if(self.walletAddress.hasText){
            self.walletAddress.text = ""
            self.tfAmount.text = ""
            self.addQrbtn()
            self.checkpaste()
            self.addressErrorText.text = ""
            self.amountErrorText.text = ""
            self.tfAmount.text = ""
            self.currencyAmount2.text = ""
            self.estimateFee.text = "0.00 DCR"
            self.estimateSize.text = "0 Bytes"
            self.BalanceAfter.text = "0.00 DCR"
        } else {
            self.amountErrorText.text = ""
            self.tfAmount.text = ""
            self.currencyAmount2.text = ""
            self.estimateFee.text = "0.00 DCR"
            self.estimateSize.text = "0 Bytes"
            self.BalanceAfter.text = "0.00 DCR"
        }
    }
    
    func checkpaste(){
        let pasteboardString: String? = UIPasteboard.general.string
        if let theString = pasteboardString {
            if (self.wallet.isAddressValid(theString )) {
                print("address valid on appear")
                if !(removedBtn){
                    print("not showing but adding now")
                    removedBtn = true
                    self.removePasteBtn()
                }
                else{
                    print("showing and leaving it")
                }
                //self.addressError.text = ""
            }
            else{
                print("address invalid on appear")
                if (removedBtn){
                    print("showing but removing now")
                    removedBtn = false
                    self.removePasteBtn()
                }
                //self.addressError.text = ""
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
        self.navigationItem.title = "Send"
        self.updateBalance()
        let menu = UIButton(type: .custom)
        menu.setImage(UIImage(named: "right-menu"), for: .normal)
        menu.addTarget(self, action: #selector(showMenu), for: .touchUpInside)
        menu.frame = CGRect(x: 0, y: 0, width: 10, height: 51)
        barButton = UIBarButtonItem(customView: menu)
        self.navigationItem.rightBarButtonItems = [barButton!]
        print("address valid on appear")
        if !(self.fromNotQRScreen){
            self.fromNotQRScreen = true
        }
        else{
            self.checkpaste()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSendAll(_ sender: Any?) {
        self.sendAllTX = true
        sendAll()
        
    }
    func sendAll() {
        let spendableAmount = spendable(account: self.selectedAccount!)
        self.tfAmount.text = "\(spendableAmount)"
        if !(self.conversionRowCont.isHidden){
            self.currencyAmount2.text = "\((((self.exchangeRateGloabal as Decimal) * spendableAmount)as NSDecimalNumber).round(2))"
        }
        self.prepareTransaction(sendAll: self.sendAllTX, amount: self.tfAmount.text!)
        self.toggleSendBtn(validate: self.validateSentBtn(amount: self.tfAmount.text!))
    }
    
    @objc func showMenu(){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let sendTitle = self.toAddressContainer.isHidden ? "Send to address" : "Send to account"
        let sendToAccount = UIAlertAction(title: sendTitle, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.sendToSwitch()
        })
        
        let clearFields = UIAlertAction(title: "Clear fields", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.clearFields()
        })
        
        if let popoverPresentationController = alertController.popoverPresentationController {
            popoverPresentationController.barButtonItem = barButton
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(sendToAccount)
        alertController.addAction(clearFields)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func sendToSwitch(){
        self.toAddressContainer.isHidden = !toAddressContainer.isHidden
        self.toAccountContainer.isHidden = !toAccountContainer.isHidden
        self.addressErrorText.isHidden = !self.addressErrorText.isHidden
        self.toggleSendBtn(validate: self.validateSentBtn(amount: self.tfAmount.text!))
    }
    
    func removePasteBtn(){
        DispatchQueue.main.async {
            if !(self.removedBtn){
                
                self.toAddressContainer.removeArrangedSubview(self.pasteBtn)
                self.pasteBtn.isHidden = true
                
            }
            else{
                self.toAddressContainer.insertArrangedSubview(self.pasteBtn, at: 1)
                self.pasteBtn.isHidden = false
            }
        }
        
    }
    
    func removeQrbtn(){
        DispatchQueue.main.async {
            self.toAddressContainer.removeArrangedSubview(self.qrcodeBtn)
            self.qrcodeBtn.isHidden = true
        }
    }
    func addQrbtn(){
        DispatchQueue.main.async {
            self.toAddressContainer.insertArrangedSubview(self.qrcodeBtn, at: 1)
            self.qrcodeBtn.isHidden = false
        }
    }
    
    @IBAction private func sendFund(_ sender: Any) {
        guard (UserDefaults.standard.bool(forKey: "synced")) else {
            sendNtwkErrtext.text = "Please wait for network synchronization."
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.sendNtwkErrtext.text = " "
            }
            return
        }
        let peer = UserDefaults.standard.integer(forKey: "peercount")
        guard peer > 0 else {
            sendNtwkErrtext.text = "Not connected to the network."
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.sendNtwkErrtext.text = " "
            }
            return
        }
        if self.validate(amount: self.tfAmount.text!) {
            self.fromNotQRScreen = false
            if SpendingPinOrPassword.currentSecurityType() == SecurityViewController.SECURITY_TYPE_PASSWORD {
                self.confirmSend(sendAll: false)
            } else {
                let requestPinVC = storyboard!.instantiateViewController(withIdentifier: "RequestPinViewController") as! RequestPinViewController
                requestPinVC.securityFor = "Spending"
                requestPinVC.showCancelButton = true
                requestPinVC.onUserEnteredPin = { pin in
                    self.confirmSendWithoutPin(sendAll: false, pin: pin)
                }
                self.present(requestPinVC, animated: true, completion: nil)
            }
        }
    }
    
    private func prepareTransaction(sendAll: Bool?, amount : String) {
        let amountToSend = Double((amount))!
        let amount = DcrlibwalletAmountAtom(amountToSend)
        var walletaddress = self.walletAddress.text!
        let acountN = (self.selectedAccount?.Number)!
        var fee = 0.0
        
        if !(validateDestinationAddress()) {
            walletaddress = (wallet?.currentAddress(acountN, error: nil))!
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                
                let isShouldBeConfirmed = UserDefaults.standard.bool(forKey: "pref_spend_fund_switch")
                let preparedTransaction: DcrlibwalletUnsignedTransaction?
                preparedTransaction = try self.wallet?.constructTransaction(walletaddress, amount: amount, srcAccount: acountN , requiredConfirmations: isShouldBeConfirmed ? 0 : 2, sendAll: sendAll ?? false)
                
                DispatchQueue.main.async { [weak self] in
                    guard let this = self else { return }
                    fee = Double((preparedTransaction?.estimatedSignedSize)!) / 0.001 / 1e8
                    let spendableAmount = spendable(account: (self?.selectedAccount!)!)
                    this.estimateSize.text = "\(preparedTransaction?.estimatedSignedSize ?? 0) Bytes"
                    this.estimateFee.text = "\(fee) DCR"
                    let Amount =  (spendableAmount - (Decimal(amountToSend) )) as NSDecimalNumber
                    this.BalanceAfter.text = "\(Amount.round(8)) DCR"
                    if !(self!.conversionRowCont.isHidden){
                        self?.conversionFeeCont.isHidden = false
                        self!.sendInfoHeight.constant = 155
                        self?.tempFee = "\((((Decimal(fee)) * ((self?.exchangeRateGloabal)! as Decimal)) as NSDecimalNumber).round(4))"
                        self?.convertionFeeOther.text = "(\(self!.tempFee) USD)"
                    }
                    if(sendAll)!{
                        this.tfAmount.text = "\(DcrlibwalletAmountCoin(amount - DcrlibwalletAmountAtom(fee)) )"
                    }
                }
            } catch {
               // self.showAlert(message: error.localizedDescription, titles: "Error")
            }
        }
    }
    
    private func signTransaction(sendAll: Bool?, password:String) {
        let peer = UserDefaults.standard.integer(forKey: "peercount")
        guard peer > 0 else {
            sendNtwkErrtext.text = "Not connected to the network."
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.sendNtwkErrtext.text = " "
            }
            return
        }
          var walletAddress = ""
        if (self.toAddressContainer.isHidden) {
            let receiveAddress = wallet?.currentAddress((self.sendToAccount?.Number)!, error: nil)
            walletAddress = receiveAddress!
        }
        else{
            DispatchQueue.main.async {
                walletAddress = self.walletAddress.text!
            }
        }
        DispatchQueue.main.async {
            let amount = Double((self.tfAmount.text)!)! * 100000000
            let account = (self.selectedAccount?.Number)!
            DispatchQueue.global(qos: .userInitiated).async {[unowned self] in
                do {
                    
                    let isShouldBeConfirmed = UserDefaults.standard.bool(forKey: "pref_spend_fund_switch")
                    let result = try self.wallet?.sendTransaction(password.data(using: .utf8), destAddr: walletAddress, amount: Int64(amount) , srcAccount: account , requiredConfs: isShouldBeConfirmed ? 0 : 2, sendAll: sendAll ?? false)
                    
                    DispatchQueue.main.async {
                        self.transactionSucceeded(hash: result?.hexEncodedString())
                        return
                    }
                    return
                    
                } catch let error {
                    self.showAlert(message: error.localizedDescription, titles: "Error")
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    private func confirmSend(sendAll: Bool) {
        
        let amountToSend = (tfAmount?.text)!
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let confirmSendFundViewController = storyboard.instantiateViewController(withIdentifier: "ConfirmToSendFundViewController") as! ConfirmToSendFundViewController
        confirmSendFundViewController.modalTransitionStyle = .crossDissolve
        confirmSendFundViewController.modalPresentationStyle = .overCurrentContext
        
        let tap = UITapGestureRecognizer(target: confirmSendFundViewController.view, action: #selector(confirmSendFundViewController.vContent.endEditing(_:)))
        tap.cancelsTouchesInView = false
        
        confirmSendFundViewController.view.addGestureRecognizer(tap)
        DispatchQueue.main.async {
            if (self.toAddressContainer.isHidden){
                let receiveAddress = self.wallet?.currentAddress((self.sendToAccount?.Number)!, error: nil)
                confirmSendFundViewController.address = receiveAddress!
                confirmSendFundViewController.account = (self.selectedAccount?.Name)!
            }
            else{
                confirmSendFundViewController.accountLabel.isHidden = true
                confirmSendFundViewController.address = self.walletAddress.text!
            }
            if !(self.conversionRowCont.isHidden){
                confirmSendFundViewController.amount = "\(amountToSend) DCR ($\((self.currencyAmount2.text)!))"
                confirmSendFundViewController.fee = "\((self.estimateFee.text)!) ($\((self.tempFee)))"
            }
            else{
                confirmSendFundViewController.amount = "\(amountToSend) DCR"
                confirmSendFundViewController.fee = "\((self.estimateFee.text)!) (\((self.estimateSize.text)!))"
                
            }
            
        }
        
        confirmSendFundViewController.confirm = { (password) in
            self.signTransaction(sendAll: sendAll, password: password)
        }
        
        DispatchQueue.main.async {
            self.present(confirmSendFundViewController, animated: true, completion: nil)
        }
        return
    }
    
    private func confirmSendWithoutPin(sendAll: Bool, pin: String) {
        let amountToSend = (tfAmount?.text)!
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let confirmSendFundViewController = storyboard.instantiateViewController(withIdentifier: "ConfirmToSendFundViewPINController") as! ConfirmToSendFundViewPINController
        confirmSendFundViewController.modalTransitionStyle = .crossDissolve
        confirmSendFundViewController.modalPresentationStyle = .overCurrentContext
        
        let tap = UITapGestureRecognizer(target: confirmSendFundViewController.view, action: #selector(confirmSendFundViewController.vContent.endEditing(_:)))
        tap.cancelsTouchesInView = false
        
        confirmSendFundViewController.view.addGestureRecognizer(tap)
        DispatchQueue.main.async {
            if (self.toAddressContainer.isHidden){
                let receiveAddress = self.wallet?.currentAddress((self.sendToAccount?.Number)!, error: nil)
                confirmSendFundViewController.address = receiveAddress!
                confirmSendFundViewController.account = (self.selectedAccount?.Name)!
            }
            else{
                confirmSendFundViewController.accountName.isHidden = true
                confirmSendFundViewController.address = self.walletAddress.text!
            }
            if !(self.conversionRowCont.isHidden){
                confirmSendFundViewController.amount = "\(amountToSend) DCR ($\((self.currencyAmount2.text)!))"
                confirmSendFundViewController.fee = "\((self.estimateFee.text)!) ($\((self.tempFee)))"
            }
            else{
                confirmSendFundViewController.amount = "\(amountToSend) DCR"
                confirmSendFundViewController.fee = "\((self.estimateFee.text)!) (\((self.estimateSize.text)!))"
            }
        }
        let tmp = pin
        confirmSendFundViewController.confirm = { () in
            self.signTransaction(sendAll: sendAll, password: tmp)
        }
        DispatchQueue.main.async {
            self.present(confirmSendFundViewController, animated: true, completion: nil)
        }
        return
    }
    
    override func onPassCompleted(pass: String) {
        self.confirmSendWithoutPin(sendAll: false, pin: pass)
    }
    
    @IBAction private func scanQRCodeAction(_ sender: UIButton) {
        // Retrieve the QRCode content
        // By using the delegate pattern
        self.readerVC.delegate = self
        
        // Or by using the closure pattern
        self.readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            
            DispatchQueue.main.async { [weak self] in
                guard let this = self else { return }
                var address = result?.value
                if address == nil {
                    return
                }
                
                let lenght = min((address?.length)!,40)
                let errorText = address?.prefix(lenght)
                let message = "This is not a decred wallet address.\n".appending((errorText)!)
                
                if (address?.length)! > 0 {
                    if (address?.starts(with: "decred:"))! {
                        address = address?.replacingOccurrences(of: "decred:", with: "")
                    }
                    if self!.wallet.isAddressValid(address!) {
                        self?.fromNotQRScreen = false
                        DispatchQueue.main.async {
                            this.walletAddress?.text = address
                        }
                        this.removeQrbtn()
                        if (this.removedBtn){
                            print("showing but removing now")
                            this.removedBtn = false
                            this.removePasteBtn()
                        }
                    } else{
                        self?.showAlert(message: message, titles: "Info")
                        print("invalid address length")
                    }
                } else{
                    self?.showAlert(message: message, titles: "Info")
                }
            }
        }
        
        // Presents the readerVC as modal form sheet
        self.readerVC.modalPresentationStyle = .formSheet
        DispatchQueue.main.async {
            self.present(self.readerVC, animated: true, completion: nil)
        }
    }
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.dismiss(animated: true, completion: nil)
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.dismiss(animated: true, completion: nil)
    }
    
    func openLink(urlString: String) {
        
        if let url = URL(string: urlString) {
            let viewController = SFSafariViewController(url: url, entersReaderIfAvailable: true)
            viewController.delegate = self as? SFSafariViewControllerDelegate
            
            self.present(viewController, animated: true)
        }
    }
    
    private func transactionSucceeded(hash: String?) {
        
        let hashe = hash
        let storyboard = UIStoryboard(
            name: "SendCompletedViewController",
            bundle: nil
        )
        
        let sendCompletedVC = storyboard.instantiateViewController(withIdentifier: "SendCompletedViewController") as! SendCompletedViewController
        sendCompletedVC.modalTransitionStyle = .crossDissolve
        sendCompletedVC.modalPresentationStyle = .overCurrentContext
        sendCompletedVC.transactionHash = hashe
        
        sendCompletedVC.openDetails = { [weak self] in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                self.walletAddress.text = nil
                self.estimateFee.text = "0.00 DCR"
                self.estimateSize.text = "0 Bytes"
                self.BalanceAfter.text = "0.00 DCR"
                self.tfAmount.text = nil
                if !(self.toAddressContainer.isHidden){
                    self.addQrbtn()
                    self.checkpaste()
                    
                }
                self.showDefaultAccount()
            }
            
            let isTestnet = Bool(infoForKey(GlobalConstants.Strings.IS_TESTNET)!)!
            if (isTestnet){
                self.openLink(urlString: "https://testnet.dcrdata.org/tx/" + hashe! )
            }else{
                self.openLink(urlString: "https://mainnet.dcrdata.org/tx/" + hashe! )
            }
        }
        sendCompletedVC.closeView = { [weak self] in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                self.walletAddress.text = nil
                self.estimateFee.text = "0.00 DCR"
                self.estimateSize.text = "0 Bytes"
                self.BalanceAfter.text = "0.00 DCR"
                self.tfAmount.text = nil
                self.currencyAmount2.text = nil
                if !(self.toAddressContainer.isHidden){
                    self.addQrbtn()
                    self.checkpaste()
                }
                self.showDefaultAccount()
                self.updateBalance()
            }
            
        }
        self.present(sendCompletedVC, animated: true, completion: nil)
        return
    }
    
    // MARK: - TextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !self.validateAmount(amount: self.tfAmount.text!) {
            self.showAlertInvalidAmount()
            return false
        }
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if (self.tfAmount.text != nil && self.tfAmount.text != "" && self.tfAmount.text != "0" && self.amountErrorText.text == "") {
            self.sendAllTX = false
            return true
        }
        
        if (textField == self.tfAmount) {
            self.estimateFee.text = "0.00 DCR"
            self.estimateSize.text = "0 Bytes"
            self.BalanceAfter.text = "0.00 DCR"
        }
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if (textField == self.walletAddress) {
            DispatchQueue.main.async {
                self.addressErrorText.text = ""
                
            }
            self.addQrbtn()
            if (self.wallet.isAddressValid(UIPasteboard.general.string)) {
                removedBtn = true
                self.removePasteBtn()
                return true
            }
        }
        
        return true
    }
    
    var ACCEPTABLE_CHARACTERS = ""
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        
        if (textField == self.walletAddress) {
            if (updatedString == nil || updatedString?.trimmingCharacters(in: .whitespaces) == "") {
                DispatchQueue.main.async {
                    self.addressErrorText.text = ""
                }
                self.addQrbtn()
                if (self.wallet.isAddressValid(UIPasteboard.general.string)) {
                        removedBtn = true
                        self.removePasteBtn()
                        return true
                }
                return true
            }
            
            if (removedBtn) {
                removedBtn = false
                self.removePasteBtn()
            }
            
            self.removeQrbtn()
            
            if (self.wallet.isAddressValid(updatedString)) {
                DispatchQueue.main.async {
                    self.addressErrorText.text = ""
                    self.toggleSendBtn(validate: self.validateSentBtn(amount: self.tfAmount.text!))
                }
                return true
            } else {
                DispatchQueue.main.async {
                    self.addressErrorText.text = "Destination address is not valid"
                    self.toggleSendBtn(validate: self.validateSentBtn(amount: self.tfAmount.text!))
                }
                return true
            }
        }
        
        if (textField == self.tfAmount) {
            self.sendAllTX = false
            let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
            if (updatedString != nil && updatedString != "" ) {
                if((updatedString?.contains("."))!){
                    let tmp2 = updatedString! as NSString
                    let TmpDot = tmp2.range(of: ".")
                    if((updatedString!.length - (TmpDot.location + 1)) > 8 || TmpDot.location > 8){
                        return false
                    }
                    if(updatedString?.first == "."){
                        DispatchQueue.main.async {
                            self.tfAmount.text = "0."
                        }
                        updatedString = "0."
                        ACCEPTABLE_CHARACTERS = "."
                    }
                    else{
                        ACCEPTABLE_CHARACTERS = "."
                    }
                }
                else{
                    if(updatedString!.length > 8){
                        return false
                    }
                    ACCEPTABLE_CHARACTERS = ""
                }
                if !(CharacterSet(charactersIn: string).isSubset(of: cs)){
                    return false
                }
                self.amountErrorText.text = ""
                
                let tspendable = spendable(account: self.selectedAccount!) as Decimal
                let amountToSend = Decimal(Double((updatedString)!)!)
                
                if (amountToSend > tspendable) {
                    DispatchQueue.main.async {
                        if !(self.conversionRowCont.isHidden){
                            let tmp = Double((updatedString)!)!
                            let tmp2 = Decimal(tmp)
                            self.currencyAmount2.text = "\((((self.exchangeRateGloabal as Decimal) * tmp2)as NSDecimalNumber).round(2))"
                        }
                        if(UserDefaults.standard.bool(forKey: "synced")){
                             self.amountErrorText.text = "Not enough funds"
                        }
                        else{
                             self.amountErrorText.text = "Not enough funds (or not connected)"
                        }
                        DispatchQueue.main.async {
                            self.estimateFee.text = "0.00 DCR"
                            self.estimateSize.text = "0 Bytes"
                            self.BalanceAfter.text = "0.00 DCR"
                            if !(self.conversionRowCont.isHidden){
                                self.conversionFeeCont.isHidden = true
                                self.sendInfoHeight.constant = 135
                                self.convertionFeeOther.text = ""
                            }
                        }
                    }
                }
                else {
                    DispatchQueue.main.async {
                        self.amountErrorText.text = ""
                        if !(self.conversionRowCont.isHidden){
                            let tmp = Double((updatedString)!)!
                            let tmp2 = Decimal(tmp)
                            self.currencyAmount2.text = "\((((self.exchangeRateGloabal as Decimal) * tmp2)as NSDecimalNumber).round(2))"
                        }
                    }
                }
                self.sendAllTX = false
                self.prepareTransaction(sendAll: self.sendAllTX, amount: updatedString!)
                self.toggleSendBtn(validate: self.validateSentBtn(amount: updatedString!))
            } else {
                DispatchQueue.main.async {
                    self.currencyAmount2.text = nil
                    self.estimateFee.text = "0.00 DCR"
                    self.estimateSize.text = "0 Bytes"
                    self.BalanceAfter.text = "0.00 DCR"
                    self.amountErrorText.text = ""
                    if !(self.conversionRowCont.isHidden){
                        self.conversionFeeCont.isHidden = true
                        self.sendInfoHeight.constant = 135
                        self.convertionFeeOther.text = ""
                    }
                    self.toggleSendBtn(validate: self.validateSentBtn(amount: updatedString!))
                }
            }
        }
       else if (textField == self.currencyAmount2) {
            self.sendAllTX = false
            let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
            if (updatedString != nil && updatedString != "" ){
                if((updatedString?.contains("."))!){
                    let tmp2 = updatedString! as NSString
                    let TmpDot = tmp2.range(of: ".")
                    if((updatedString!.length - (TmpDot.location + 1)) > 2 || TmpDot.location > 10){
                        return false
                    }
                    if(updatedString?.first == "."){
                        DispatchQueue.main.async {
                            self.currencyAmount2.text = "0."
                        }
                        updatedString = "0."
                        ACCEPTABLE_CHARACTERS = "."
                    }
                    else{
                        ACCEPTABLE_CHARACTERS = "."
                    }
                }
                else{
                    if(updatedString!.length > 10){
                        return false
                    }
                    ACCEPTABLE_CHARACTERS = ""
                }
                if !(CharacterSet(charactersIn: string).isSubset(of: cs)){
                    return false
                }
                self.amountErrorText.text = ""
                let tspendable = spendable(account: self.selectedAccount!) as Decimal
                let amountToSend = Decimal(Double((updatedString)!)!)
                if (amountToSend > tspendable) {
                    DispatchQueue.main.async {
                            let tmp = Double((updatedString)!)!
                            let tmp2 = Decimal(tmp)
                        print("\((tmp2 )) and \(self.exchangeRateGloabal as Decimal)")
                        print((tmp2 ) / (self.exchangeRateGloabal as Decimal))
                        print("currency")
                        self.tfAmount.text = "\(((tmp2 ) / (self.exchangeRateGloabal as Decimal) as NSDecimalNumber).round(8))"
                        if(UserDefaults.standard.bool(forKey: "synced")){
                            self.amountErrorText.text = "Not enough funds"
                        }
                        else{
                            self.amountErrorText.text = "Not enough funds (or not connected)"
                        }
                        DispatchQueue.main.async {
                            self.estimateFee.text = "0.00 DCR"
                            self.estimateSize.text = "0 Bytes"
                            self.BalanceAfter.text = "0.00 DCR"
                            if !(self.conversionRowCont.isHidden){
                                self.conversionFeeCont.isHidden = true
                                self.sendInfoHeight.constant = 135
                                self.convertionFeeOther.text = ""
                            }
                        }
                    }
                }
                else{
                    DispatchQueue.main.async {
                        self.amountErrorText.text = ""
                        if !(self.conversionRowCont.isHidden){
                            let tmp = Double((updatedString)!)!
                            let tmp2 = Decimal(tmp)
                            self.tfAmount.text = "\(((tmp2 ) / (self.exchangeRateGloabal as Decimal) as NSDecimalNumber).round(8))"
                        }
                    }
                }
                self.sendAllTX = false
                print("before validate")
                self.toggleSendBtn(validate: self.validateSentBtn(amount: updatedString!))
                self.prepareTransaction(sendAll: self.sendAllTX, amount: updatedString!)
                return true
            }else{
                DispatchQueue.main.async {
                    self.tfAmount.text = nil
                    self.estimateFee.text = "0.00 DCR"
                    self.estimateSize.text = "0 Bytes"
                    self.BalanceAfter.text = "0.00 DCR"
                    if !(self.conversionRowCont.isHidden){
                        self.conversionFeeCont.isHidden = true
                        self.sendInfoHeight.constant = 135
                        self.convertionFeeOther.text = ""
                    }
                    self.toggleSendBtn(validate: self.validateSentBtn(amount: updatedString!))
                }
            }
        }
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
    private func toggleSendBtn(validate: Bool){
        if validate {
            self.sendBtn.backgroundColor = UIColor(hex: "#007AFF")
            self.sendBtn.setTitleColor(UIColor.white, for: .normal)
            print("btn true")
        }
        else{
            self.sendBtn.backgroundColor = UIColor(hex: "#E6EAED")
            self.sendBtn.setTitleColor(UIColor(hex: "#000000", alpha: 0.61), for: .normal)
            print("btn false")
        }
    }
    
    private func showDefaultAccount() {
        var account: GetAccountResponse?
        do {
            var getAccountError: NSError?
            let strAccount = wallet?.getAccounts(0, error: &getAccountError)
            if getAccountError != nil {
                throw getAccountError!
            }
            account = try JSONDecoder().decode(GetAccountResponse.self, from: (strAccount?.data(using: .utf8))!)
            
        } catch let error {
            print(error)
        }
        
        let defaultNumber = UserDefaults.standard.integer(forKey: "wallet_default")
        
        if let defaultAccount = account?.Acc.filter({ $0.Number == defaultNumber }).first {
            let tspendable = spendable(account: defaultAccount) as NSDecimalNumber
            
            accountDropdown.setTitle(
                "\(defaultAccount.Name) [\(tspendable.round(8) )]",
                for: UIControl.State.normal
            )
            toAccountDropDown.setTitle(
                "\(defaultAccount.Name) [\(tspendable.round(8) )]",
                for: UIControl.State.normal
            )
            selectedAccount = defaultAccount
            sendToAccount = defaultAccount
            print("before function default")
        }
    }
    
    private func updateBalance() {
        var accounts = [String]()
        var account: GetAccountResponse?
        do {
            var getAccountError: NSError?
            let strAccount = wallet?.getAccounts(0, error: &getAccountError)
            if getAccountError != nil {
                throw getAccountError!
            }
            account = try JSONDecoder().decode(GetAccountResponse.self, from: (strAccount?.data(using: .utf8))!)
            
        } catch let error {
            print(error)
        }
        accounts = (account?.Acc.filter({UserDefaults.standard.bool(forKey: "hidden\($0.Number)")  != true && $0.Number != INT_MAX }).map { (acc) -> String in
            let tspendable = spendable(account: acc) as NSDecimalNumber
            print(acc.Number)
            
            return "\(acc.Name) [\( tspendable.round(8) )]"
            })!
        AccountFilter = (account?.Acc.filter({UserDefaults.standard.bool(forKey: "hidden\($0.Number)")  != true && $0.Number != INT_MAX }).map { (acc) -> AccountsEntity in
            return acc
            })!
        self.accountDropdown.initMenu(accounts) { [weak self] ind, val in
            guard let this = self else { return }
            this.accountDropdown.setTitle(
                val,
                for: UIControl.State.normal
            )
            this.selectedAccount = self?.AccountFilter?[ind]
            print("before function update")
            if(self!.sendAllTX){
                self!.sendAll()
            }
        }
        self.toAccountDropDown.initMenu(accounts) { [weak self] ind, val in
            guard let this = self else { return }
            this.toAccountDropDown.setTitle(
                 val,
                 for: UIControl.State.normal
            )
            this.sendToAccount = self?.AccountFilter?[ind]
        }
    }
    
    @IBAction func pasteFunc(_ sender: Any) {
        DispatchQueue.main.async {
            self.walletAddress.text = UIPasteboard.general.string
        }
        self.removedBtn = false
        self.addressErrorText.text = ""
        self.removeQrbtn()
        self.removePasteBtn()
        self.walletAddress.becomeFirstResponder()
    }
    
    //MARK: - Validation
    
    private func validate(amount: String) -> Bool {
        if !self.validateWallet() {
            self.showAlertForInvalidWallet()
            return false
        }
        if self.toAddressContainer.isHidden {
            if !self.validateDestinationAddress() {
                self.addressErrorText.text = "Destination address is not valid"
                return false
            }
        }
        if !self.validateAmount(amount: amount) {
            self.amountErrorText.text = "Amount can not be zero"
            return false
        }
        if(self.amountErrorText.text != ""){
            return false
        }
        return true
    }
    
    private func validateSentBtn(amount : String)-> Bool {
        if !self.validateWallet() {
            self.showAlertForInvalidWallet()
            print("wallet error")
            return false
        }
        if !self.toAddressContainer.isHidden {
            if !self.validateDestinationAddress() {
                print("address error")
                return false
            }
        }
        if !self.validateAmount(amount: amount) {
            print("amount error")
            return false
        }
        if(self.amountErrorText.text != ""){
            print("addressErrorText error")
            return false
        }
        
        return true
    }
    
    private func validateDestinationAddress() -> Bool {
        return self.wallet.isAddressValid(self.walletAddress.text!)
    }
    
    private func validateAmount(amount : String) -> Bool {
        if(amount == "" ){
            print("Amount nill or empty")
            return false
        }
        else{
            
            let amountToSend = Double((amount ))!
            let tspendable = spendable(account: self.selectedAccount!) as Decimal
            print(" result of amount is \(amountToSend > 0 || Decimal(amountToSend) < tspendable)")
            return amountToSend > 0 && Decimal(amountToSend) <= tspendable
        }
    }
    
    private func validateWallet() -> Bool {
        return self.selectedAccount != nil
    }
    
    private func showAlertForInvalidDestinationAddress() {
        self.showAlert(message: "Please paste a correct destination address.", titles: "Warning")
    }
    
    private func showAlertForInvalidWallet() {
        self.showAlert(message: "Please select your source wallet.", titles: "Warning")
    }
    
    private func showAlertInvalidAmount() {
        self.showAlert(message: "Please input amount of DCR to send.", titles: "Warning")
    }
    
    private func showAlert(message: String? , titles: String?) {
        let alert = UIAlertController(title: titles, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func validate(address: String) -> Bool {
        return (wallet?.isAddressValid(address)) ?? false
    }
    
    @IBAction func reloadExchange(_ sender: Any) {
        self.exchangeRateError.isEnabled = false
        self.GetExchangeRate()
    }
    
    func GetExchangeRate(){
        //create the url with NSURL
       let url = NSURL(string: "https://bittrex.com/api/v1.1/public/getticker?market=USDT-DCR")! //change the url
        print("start fetching")
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        let request = URLRequest(url: url as URL)
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            print("in task now")
            guard error == nil else {
                DispatchQueue.main.async {
                    self.exchangeRateError.setTitle("bittrex rate unavailable (tap to retry)", for: .normal)
                    self.exchangeRateError.isEnabled = true
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.exchangeRateError.setTitle("bittrex rate unavailable (tap to retry)", for: .normal)
                    self.exchangeRateError.isEnabled = true
                }
                return
            }
            
            do {
                //create json object from data
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    let resultValue = json["success"] as? Bool?
                    print(json["result"]! as Any)
                    print(json["success"]!)
                    if resultValue  == true{
                        // print(json["data"] as Any)
                        let reportLoad = json["result"] as? NSDictionary
                        if let exchangeRate = reportLoad!["Last"] as? Double?{
                            let exchange = Decimal(exchangeRate!) as NSDecimalNumber
                            DispatchQueue.main.async {
                                self.conversionContHeight.constant = 75
                                self.conversionRowCont.isHidden = false
                                self.sendInfoHeight.constant = 135
                                self.exchangeRateCont.isHidden = false
                                self.exchangeRateDisplay.text = exchange.round(2).stringValue + " USD/DCR (bittrex)"
                                self.exchangeRateGloabal = exchange.round(2)
                                self.exchangeRateError.isEnabled = false
                                self.exchangeRateError.setTitle("", for: .normal)
                            }
                            return
                        }
                        DispatchQueue.main.async {
                            self.exchangeRateError.setTitle("bittrex rate unavailable (tap to retry)", for: .normal)
                            self.exchangeRateError.isEnabled = true
                        }
                    }
                    else{
                        DispatchQueue.main.async {
                            self.exchangeRateError.setTitle("bittrex rate unavailable (tap to retry)", for: .normal)
                            self.exchangeRateError.isEnabled = true
                        }
                        return
                    }
                }
            } catch let error {
                DispatchQueue.main.async {
                    self.exchangeRateError.setTitle("bittrex rate unavailable (tap to retry)", for: .normal)
                    self.exchangeRateError.isEnabled = true
                }
                
                print(error.localizedDescription)
                return
            }
        })
        
        task.resume()
    }
    
}
class AmountTextfield: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}
