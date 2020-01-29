//  TransactionDetailsViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.
import UIKit
import Dcrlibwallet
import SafariServices

class TransactionDetailsViewController: UIViewController, SFSafariViewControllerDelegate {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var txIconImageView: UIImageView!
    @IBOutlet weak var txAmountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var confirmationsLabel: UILabel!
    @IBOutlet private weak var transactionDetailsTable: SelfSizedTableView!
    @IBOutlet weak var showOrHideDetailsBtn: UIButton!

    var transactionHash: String?
    var transaction: Transaction!

    var generalTxDetails: [TransactionDetails] = []
    var isTxInputsCollapsed: Bool = true
    var isTxOutputsCollapsed: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.transactionDetailsTable.isHidden = true
        self.showOrHideDetailsBtn.addBorder(atPosition: .top, color: UIColor.appColors.gray, thickness: 1)

        self.transactionDetailsTable
            .hideEmptyAndExtraRows()
            .autoResizeCell(estimatedHeight: 60.0)
    }

    override func viewWillAppear(_ animated: Bool) {
        transactionDetailsTable.maxHeight = self.view.frame.size.height - self.view.frame.origin.y
            - self.headerView.frame.size.height - self.showOrHideDetailsBtn.frame.size.height - (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)

        if self.transaction == nil && self.transactionHash != nil {
            let txHash = Data(fromHexEncodedString: self.transactionHash!)!
            var getTxError: NSError?
            let txJsonString = WalletLoader.shared.firstWallet?.getTransaction(txHash, error: &getTxError)
            if getTxError != nil {
                print("wallet.getTransaction error", getTxError!.localizedDescription)
            }

            do {
                self.transaction = try JSONDecoder().decode(Transaction.self, from: (txJsonString!.utf8Bits))
            } catch let error {
                print("decode transaction error:", error.localizedDescription)
            }
        }

        self.prepareTransactionDetails()
    }

    private func prepareTransactionDetails() {
        var confirmations: Int32 = 0
        let requireConfirmation = Settings.spendUnconfirmed ? 0 : 2
        if self.transaction.blockHeight != -1 {
            confirmations = WalletLoader.shared.firstWallet!.getBestBlock() - Int32(self.transaction.blockHeight) + 1
        }
        
        if Settings.spendUnconfirmed || confirmations > 1 {
            self.statusLabel.text = LocalizedStrings.confirmed
            self.statusLabel.textColor = UIColor.appColors.green
            self.statusImageView.image = UIImage(named: "ic_confirmed")
            self.confirmationsLabel.text = " · " + String(format: LocalizedStrings.confirmations, confirmations)
        } else {
            self.statusLabel.text = LocalizedStrings.pending
            self.statusLabel.textColor = UIColor.appColors.lightBluishGray
            self.statusImageView.image = UIImage(named: "ic_pending")
            self.confirmationsLabel.text = ""
        }

        self.dateLabel.attributedText = NSMutableAttributedString(string: Utils.formatDateTime(timestamp: self.transaction.timestamp))

        let txFee = Utils.getAttributedString(
            str: "\(self.transaction.dcrFee.round(8))",
            siz: 16,
            TexthexColor: UIColor.appColors.darkBlue
        )

        generalTxDetails = [
            TransactionDetails(
                title: LocalizedStrings.fee,
                value: txFee,
                isCopyEnabled: false
            ),
            TransactionDetails(
                title: LocalizedStrings.type,
                value: NSMutableAttributedString(string: self.transaction.type),
                isCopyEnabled: false
            ),
            TransactionDetails(
                title: LocalizedStrings.includedInBlock,
                value: NSMutableAttributedString(string: "\(self.transaction.blockHeight)"),
                isCopyEnabled: false
            ),
            TransactionDetails(
                title: LocalizedStrings.transactionID,
                value: NSMutableAttributedString(string: self.transaction.hash),
                isCopyEnabled: true
            )
        ]

        if self.transaction.type == DcrlibwalletTxTypeRegular {
            if self.transaction.direction == DcrlibwalletTxDirectionSent {
                self.titleLabel.text = LocalizedStrings.sent
                self.txIconImageView.image = UIImage(named: "ic_send")
                let attributedString = NSMutableAttributedString(string: "-")
                attributedString.append(Utils.getAttributedString(
                    str: "\(self.transaction.dcrAmount.round(8))",
                    siz: 20,
                    TexthexColor: UIColor.appColors.darkBlue
                ))
                self.txAmountLabel.attributedText = attributedString
            } else if self.transaction.direction == DcrlibwalletTxDirectionReceived {
                self.titleLabel.text = LocalizedStrings.received
                self.txIconImageView.image = UIImage(named: "ic_receive")
                self.txAmountLabel.attributedText = Utils.getAttributedString(
                    str: "\(self.transaction.dcrAmount.round(8))",
                    siz: 20,
                    TexthexColor: UIColor.appColors.darkBlue
                )
            } else if transaction.direction == DcrlibwalletTxDirectionTransferred {
                self.titleLabel.text = LocalizedStrings.transferred
                self.txIconImageView.image = UIImage(named: "ic_fee")
                self.txAmountLabel.attributedText = Utils.getAttributedString(
                    str: "\(self.transaction.dcrAmount.round(8))",
                    siz: 20,
                    TexthexColor: UIColor.appColors.darkBlue
                )
            }
        } else if self.transaction.type == DcrlibwalletTxTypeVote {
            self.titleLabel.text = " \(LocalizedStrings.vote)"
            self.txIconImageView.image =  UIImage(named: "ic_ticketVoted")

            let lastBlockValid = TransactionDetails(
                title: LocalizedStrings.lastBlockValid,
                value: NSMutableAttributedString(string: String(describing: self.transaction.lastBlockValid)),
                isCopyEnabled: false
            )
            generalTxDetails.append(lastBlockValid)

            let voteVersion = TransactionDetails(
                title: LocalizedStrings.version,
                value: NSAttributedString(string: "\(self.transaction.voteVersion)"),
                isCopyEnabled: false
            )
            generalTxDetails.append(voteVersion)

            let voteBits = TransactionDetails(
                title: LocalizedStrings.voteBits,
                value: NSAttributedString(string: self.transaction.voteBits),
                isCopyEnabled: false
            )
            generalTxDetails.append(voteBits)
            self.txAmountLabel.attributedText = Utils.getAttributedString(
                str: "\(self.transaction.dcrAmount.round(8))",
                siz: 20,
                TexthexColor: UIColor.appColors.darkBlue
            )
        } else if self.transaction.type == DcrlibwalletTxTypeTicketPurchase {
            self.titleLabel.text = " \(LocalizedStrings.ticket)"
            self.txIconImageView.image =  UIImage(named: "ic_ticketImmature")

            if confirmations < requireConfirmation {
                self.statusLabel.text = LocalizedStrings.pending
                self.statusLabel.textColor = UIColor.appColors.lightBluishGray
                self.statusImageView.image = UIImage(named: "ic_pending")
                self.confirmationsLabel.text = ""
            } else if confirmations > BuildConfig.TicketMaturity {
                self.txIconImageView.image = UIImage(named: "ic_ticketLive")
            } else {
                self.txIconImageView.image = UIImage(named: "ic_ticketImmature")
            }
            self.txAmountLabel.attributedText = Utils.getAttributedString(
                str: "\(self.transaction.dcrAmount.round(8))",
                siz: 20,
                TexthexColor: UIColor.appColors.darkBlue
            )
        }
    }

    @IBAction func onClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    func openLink(urlString: String) {
        //TODO
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
//            let viewController = SFSafariViewController(url: url)
//            viewController.delegate = self as SFSafariViewControllerDelegate
//            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }

    @IBAction func showInfo(_ sender: Any) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: LocalizedStrings.howToCopy,
                                                    message: "",
                                                    preferredStyle: UIAlertController.Style.alert)

            let attributedStringStyles = [ AttributedStringStyle(tag: "blue",
                                                                font: UIFont.systemFont(ofSize: 14),
                                                                color: UIColor.appColors.lightBlue)
                                            ]
            let defaultAttributedStringStyle = AttributedStringStyle(font: UIFont.systemFont(ofSize: 14),
                                                                     color: UIColor.appColors.deepGray)
            let attrMsgString =  Utils.styleAttributedString(LocalizedStrings.tapOnBlueText,
                                                                styles: attributedStringStyles,
                                                                defaultStyle: defaultAttributedStringStyle)
            alertController.setValue(attrMsgString, forKey: "attributedMessage")

            alertController.addAction(UIAlertAction(title: LocalizedStrings.gotIt,
                                                    style: UIAlertAction.Style.default,
                                                    handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }

    @IBAction func showOrHideDetails(_ sender: Any) {
        self.transactionDetailsTable.isHidden = !self.transactionDetailsTable.isHidden
        self.showOrHideDetailsBtn.setTitle(self.transactionDetailsTable.isHidden ? LocalizedStrings.showDetails : LocalizedStrings.hideDetails, for: .normal)
    }
}

extension TransactionDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? self.generalTxDetails.count : 1
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.5
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.zero)
        headerView.backgroundColor = UIColor.appColors.gray
        headerView.frame.size.height = 0
        return headerView
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionDetailCell") as! TransactionDetailCell
            cell.presentingController = self
            cell.txnDetails = self.generalTxDetails[indexPath.row]
            return cell

        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactiontInputDetailsCell") as! TransactiontInputDetailsCell
            cell.isCollapsed = self.isTxInputsCollapsed
            cell.setup(transaction.inputs, presentingController: self)
            cell.expandOrCollapse = { [weak self] in
                self?.isTxInputsCollapsed = !(self?.isTxInputsCollapsed ?? false)
                self?.transactionDetailsTable.reloadData()
            }
            return cell

        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactiontOutputDetailsCell") as! TransactiontOutputDetailsCell
            cell.isCollapsed = self.isTxOutputsCollapsed
            cell.setup(transaction.outputs, presentingController: self)
            cell.expandOrCollapse = { [weak self] in
                self?.isTxOutputsCollapsed = !(self?.isTxOutputsCollapsed ?? false)
                self?.transactionDetailsTable.reloadData()
            }
            return cell

        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactiontViewOnDcrdataCell") as! TransactiontViewOnDcrdataCell
            cell.onViewOnDcrData = { [weak self] in
                guard let `self` = self else { return }
                if BuildConfig.IsTestNet {
                    self.openLink(urlString: "https://testnet.dcrdata.org/tx/\(self.transaction.hash)")
                 } else {
                    self.openLink(urlString: "https://dcrdata.decred.org/tx/\(self.transaction.hash)")
                }
            }
            return cell

        default:
            return UITableViewCell()
        }
    }
}
