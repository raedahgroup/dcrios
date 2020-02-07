//
//  TransactionTableViewCell.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class TransactionTableViewCell: UITableViewCell {
    @IBOutlet weak var txTypeIconImageView: UIImageView!
    @IBOutlet weak var txAmountOrTicketStatusLabel: UILabel! // holds amount for regular txs and ticket status for staking txs
    @IBOutlet weak var stakingTxAmountLabel: UILabel! // staking txs only, holds amount for different ticket states
    @IBOutlet weak var voteRewardLabel: Label! // vote tx only
    @IBOutlet weak var txDateLabel: UILabel!
    @IBOutlet weak var daysCounterLabel: UILabel! // voted, revoked and expired tickets only
    @IBOutlet weak var txStatusIconImageView: UIImageView!

    override class func height() -> CGFloat {
        return 56
    }

    func displayInfo(for transaction: Transaction) {
        let txConfirmations = transaction.confirmations
        let isConfirmed = Settings.spendUnconfirmed || txConfirmations > 1

        let txDate = Date(timeIntervalSince1970: TimeInterval(transaction.timestamp))
        let ageInDays = txDate.daysFromNow
        var txDateString: String

        if ageInDays == 0 {
            txDateString = LocalizedStrings.today
        } else if ageInDays == -1 {
            txDateString = LocalizedStrings.yesterday
        } else {
            let txDateIsInCurrentYear = Calendar.current.isDate(txDate, equalTo: Date(), toGranularity: .year)
            txDateString = txDate.toString(format: txDateIsInCurrentYear ? "MMM dd" : "MMM dd, YYYY")
        }

        self.txDateLabel.text = isConfirmed ? txDateString : LocalizedStrings.pending
        self.txDateLabel.textColor = isConfirmed ? UIColor.appColors.bluishGray : UIColor.appColors.lightBluishGray
        self.txStatusIconImageView.image = isConfirmed ? UIImage(named: "ic_confirmed") : UIImage(named: "ic_pending")

        self.stakingTxAmountLabel.isHidden = transaction.type == DcrlibwalletTxTypeRegular
        self.daysCounterLabel.isHidden = transaction.type == DcrlibwalletTxTypeRegular
        self.voteRewardLabel.isHidden = true //TODO: set value

        if transaction.type == DcrlibwalletTxTypeRegular {
            self.displayRegularTxInfo(transaction)
        } else if transaction.type == DcrlibwalletTxTypeVote {
            self.displayVoteTxInfo(transaction, ageInDays: ageInDays)
        } else if transaction.type == DcrlibwalletTxTypeTicketPurchase {
            self.displayTicketPurchaseInfo(transaction, ageInDays: ageInDays)
        }
    }
    
    func displayRegularTxInfo(_ transaction: Transaction) {
        let amountString = Utils.getAttributedString(str: transaction.dcrAmount.round(8).description, siz: 13.0, TexthexColor: UIColor.appColors.darkBlue)

        if transaction.direction == DcrlibwalletTxDirectionSent {
            let attributedString = NSMutableAttributedString(string:"-")
            attributedString.append(amountString)
            self.txAmountOrTicketStatusLabel.attributedText = attributedString
            self.txTypeIconImageView?.image = UIImage(named: "ic_send")
        } else if transaction.direction == DcrlibwalletTxDirectionReceived {
            self.txAmountOrTicketStatusLabel.attributedText = amountString
            self.txTypeIconImageView?.image = UIImage(named: "ic_receive")
        } else if transaction.direction == DcrlibwalletTxDirectionTransferred {
            self.txAmountOrTicketStatusLabel.attributedText = amountString
            self.txTypeIconImageView?.image = UIImage(named: "ic_fee")
        }
    }
    
    func displayTicketPurchaseInfo(_ transaction: Transaction, ageInDays: Int) {
        self.txAmountOrTicketStatusLabel.text = "\(LocalizedStrings.voted)"
        self.txTypeIconImageView?.image = UIImage(named: "ic_ticketVoted")

        self.stakingTxAmountLabel.attributedText = Utils.getAttributedString(str: transaction.dcrAmount.round(8).description, siz: 11.0, TexthexColor: UIColor.appColors.lightBluishGray)
        self.daysCounterLabel.text = String(format: LocalizedStrings.days, -ageInDays)
    }
    
    func displayVoteTxInfo(_ transaction: Transaction, ageInDays: Int) {
        self.txAmountOrTicketStatusLabel.text = "\(LocalizedStrings.ticket)"
        self.txTypeIconImageView?.image = UIImage(named: "ic_ticketImmature")
        self.daysCounterLabel.text = String(format: LocalizedStrings.days, -ageInDays)
        self.stakingTxAmountLabel.attributedText = Utils.getAttributedString(str: transaction.dcrAmount.round(8).description, siz: 11.0, TexthexColor: UIColor.appColors.lightBluishGray)

        let requireConfirmation = Settings.spendUnconfirmed ? 0 : 2
        let txConfirmations = transaction.confirmations

        if txConfirmations < requireConfirmation {
            self.txDateLabel.textColor = UIColor.appColors.lightBluishGray
            self.txDateLabel.text = LocalizedStrings.pending
        } else if txConfirmations > BuildConfig.TicketMaturity {
            self.txAmountOrTicketStatusLabel.text = LocalizedStrings.live
            self.txTypeIconImageView?.image = UIImage(named: "ic_ticketLive")
        } else {
            self.txAmountOrTicketStatusLabel.text = LocalizedStrings.immature
            self.txTypeIconImageView?.image = UIImage(named: "ic_ticketImmature")
        }
    }
}
