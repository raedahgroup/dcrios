//
//  PrivacyManualSetupViewController.swift
//  Decred Wallet
//
// Copyright (c) 2021 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class PrivacyManualSetupViewController: UIViewController {
    
    var wallet: DcrlibwalletWallet!
    @IBOutlet weak var mixedAccountView: WalletAccountView!
    @IBOutlet weak var unMixedAccountView: WalletAccountView!
    @IBOutlet weak var unmixedAccountViewCont: RoundedView!
    @IBOutlet weak var mixedAccountViewCont: RoundedView!
    
    @IBOutlet weak var unMixedHeight: NSLayoutConstraint!
    @IBOutlet weak var mixedHeight: NSLayoutConstraint!
    
    @IBOutlet weak var manualSetupWaningLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
    }
    
    @IBAction func setupManualMixer(_ sender: Any) {
        if self.mixedAccountView.selectedAccount?.number == self.unMixedAccountView.selectedAccount?.number {
            Utils.showBanner(in: self.view, type: .error, text: LocalizedStrings.sameAcountCannotBeUsedForMixedAndUnmixed)
            return
        }
        self.AuthMixerAccount()
    }
    
    @IBAction func dismissView(_ sender: Any) {
        self.dismissView()
    }
    
    func showReminder(callback: @escaping (Bool) -> Void) {
        let message = LocalizedStrings.setupMixerInfo
        SimpleOkCancelDialog.show(sender: self,
                                  title: LocalizedStrings.setupMixerWithTwoAccounts,
                                  message: message,
                                  warningText: LocalizedStrings.setupMixerWithTwoAccounts,
                                  okButtonText: LocalizedStrings.beginSetup,
                                  callback: callback)
    }
    
    func setupViews() {
        self.mixedAccountView.accountBalanceLabel.isHidden = true
        self.unMixedAccountView.accountBalanceLabel.isHidden = true
        
        self.mixedAccountView.showWatchOnlyWallet = false
        self.unMixedAccountView.showWatchOnlyWallet = false
        
        self.unMixedAccountView.walletNameLabel.isHidden = true
        self.mixedAccountView.walletNameLabel.isHidden = true
        
        self.mixedAccountView.accountNameLabel.textColor = UIColor.appColors.lightBluishGray
        self.unMixedAccountView.accountNameLabel.textColor = UIColor.appColors.lightBluishGray
        self.mixedAccountView.accountNameLabel.font = UIFont(name: "SourceSansPro", size: 18)
        
        NSLayoutConstraint.activate([
            self.mixedAccountView.heightAnchor.constraint(equalToConstant: 58),
            self.unMixedAccountView.heightAnchor.constraint(equalToConstant: 58)
        ])
        
        
        let attributedStringStyles = [AttributedStringStyle(tag: "bold",
                                                             fontFamily: "SourceSansPro-bold",
                                                             fontSize: 16,
                                                             color: UIColor.appColors.darkBluishGray)]
        self.manualSetupWaningLabel.attributedText = Utils.styleAttributedString(LocalizedStrings.manualSetupWarning, styles: attributedStringStyles)
        
        self.mixedAccountView.accountSelectorPrompt = LocalizedStrings.mixedAccount
        self.unMixedAccountView.accountSelectorPrompt = LocalizedStrings.unMixedAccount
        
        self.unMixedHeight.constant = 90
        self.mixedHeight.constant = 90
        self.mixedAccountView.layoutSubviews()
        
        self.mixedAccountView.selectFirstWalletAccount()
        self.unMixedAccountView.selectFirstWalletAccount()
        
        self.mixedAccountView.onAccountSelectionChanged = { _, newSourceAccount in}
        self.unMixedAccountView.onAccountSelectionChanged = { _, newSourceAccount in}
    }
    
    func AuthMixerAccount() {
        self.showReminder { ok in
            guard ok else { return }
            Security.spending(initialSecurityType: SpendingPinOrPassword.securityType(for: self.wallet.id_))
                .with(prompt: LocalizedStrings.confirmToCreateMixer)
                .with(submitBtnText: LocalizedStrings.remove)
                .requestCurrentCode(sender: self) { spendingCode, _, dialogDelegate in
                
                    DispatchQueue.global(qos: .userInitiated).async {
                        do {
                            try self.wallet.setAccountMixerConfig(self.mixedAccountView.selectedAccount!.number, unmixedAccount: self.unMixedAccountView.selectedAccount!.number, privPass: spendingCode)
                            WalletLoader.shared.multiWallet.setBoolConfigValueForKey("has_setup_privacy", value: true)
                            
                            DispatchQueue.main.async {
                                dialogDelegate?.dismissDialog()
                                Utils.showBanner(in: self.view, type: .success, text: LocalizedStrings.mixerSetupCompleted)
                                
                                let PrivacyViewVC = PrivacyViewController.instantiate(from: .Privacy)
                                PrivacyViewVC.wallet = self.wallet
                                self.navigationController?.pushViewController(PrivacyViewVC, animated: true)
                            }
                        } catch let error {
                            DispatchQueue.main.async {
                                var errorMessage = error.localizedDescription
                                if error.isInvalidPassphraseError {
                                    errorMessage = SpendingPinOrPassword.invalidSecurityCodeMessage(for: self.wallet.id_)
                                }
                                Utils.showBanner(in: self.view, type: .error, text: errorMessage)
                            }
                        }
                    }
            }
            
        }
    }
    
}
