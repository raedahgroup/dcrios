//  AccountDataCell.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class AccountDataCell: UITableViewCell, AccountDetailsCellProtocol {
    
    @IBOutlet private weak var containerStackView: UIStackView!
    
    // MARK:- Details
    @IBOutlet private weak var labelImmatureRewardValue: UILabel!
    @IBOutlet private weak var labelLockedByTicketsValue: UILabel!
    @IBOutlet private weak var labelVotingAuthorityValue: UILabel!
    @IBOutlet private weak var labelImmatureStakeGenerationValue: UILabel!
    
    // MARK:- Properties
    @IBOutlet private weak var labelAccountNoValue: UILabel!
    @IBOutlet private weak var labelHDPathValue: UILabel!
    @IBOutlet private weak var labelKeysValue: UILabel!
    @IBOutlet weak var defaultAccount: UISwitch!
    private var accountTmp: AccountsEntity!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func setDefault(_ sender: Any) {
        self.accountTmp.makeDefault()
    }
    
    func setup(account: AccountsEntity) {
        self.accountTmp = account
        
        labelImmatureRewardValue.text = "\(account.Balance?.dcrImmatureReward ?? 0)"
        labelLockedByTicketsValue.text = "\(account.Balance?.dcrLockedByTickets ?? 0)"
        labelVotingAuthorityValue.text = "\(account.Balance?.dcrVotingAuthority ?? 0)"
        labelImmatureStakeGenerationValue.text = "\(account.Balance?.dcrImmatureStakeGeneration ?? 0)"
        labelAccountNoValue.text = "\(account.Number)"
        labelKeysValue.text = "\(account.ExternalKeyCount) External, \(account.InternalKeyCount) Internal, \(account.ImportedKeyCount) Imported"
        
        if (account.Name.elementsEqual("imported")) {
            defaultAccount.setOn(false, animated: false)
            defaultAccount.isEnabled = false
        }else{
            if (account.isDefaultWallet){
                defaultAccount.setOn(true, animated: false)
                defaultAccount.isEnabled = false
            }else {
                defaultAccount.setOn(false, animated: false)
                defaultAccount.isEnabled = true
            }
        }
        
        
        
        
    }
}
