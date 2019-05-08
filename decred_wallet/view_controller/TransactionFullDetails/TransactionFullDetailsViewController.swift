//  TransactionFullDetailsViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.
import UIKit
import JGProgressHUD
import SafariServices

class TransactionFullDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,SFSafariViewControllerDelegate  {
    
    @IBOutlet private weak var tableTransactionDetails: UITableView!    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var detailsHeader: UIView!
    @IBOutlet weak var amount: UILabel!
    
    private var barButton: UIBarButtonItem?
    
    var transactionHash: String?
    var account : String?
    var txstatus: String?
    
    var progressHud : JGProgressHUD?
    var details: [TransactionDetails] = []
    var transaction: Transaction!
    var decodedTransaction: DecodedTransaction!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableTransactionDetails
            .hideEmptyAndExtraRows()
            .autoResizeCell(estimatedHeight: 60.0)
            .registerCellNib(TransactiontInputDetails.self)
        
        tableTransactionDetails.registerCellNib(TransactionDetailCell.self)
        tableTransactionDetails.registerCellNib(TransactiontOutputDetailsCell.self)
        tableTransactionDetails.registerCellNib(TransactiontInputDetails.self)
        
        self.removeNavigationBarItem()
        self.slideMenuController()?.removeLeftGestures()
        self.navigationItem.title = "Transaction Details"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "left-arrow"), style: .done, target: self, action: #selector(backk))
    }
    
    @objc func backk(){
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationItem.title = "Transaction Details"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "left-arrow"), style: .done, target: self, action: #selector(backk))
       
        let optionsMenuButton = UIButton(type: .custom)
        optionsMenuButton.setImage(UIImage(named: "right-menu"), for: .normal)
        optionsMenuButton.addTarget(self, action: #selector(showMenu), for: .touchUpInside)
        optionsMenuButton.frame = CGRect(x: 0, y: 0, width: 10, height: 51)
        barButton = UIBarButtonItem(customView: optionsMenuButton)
        self.navigationItem.rightBarButtonItems = [barButton!]
        
        do {
            if let data = Data(fromHexEncodedString: self.transaction.Hash) {
                var decodeTxError: NSError?
                let decodedTxJson = SingleInstance.shared.wallet?.decodeTransaction(data, error: &decodeTxError)
                if decodeTxError != nil {
                    throw decodeTxError!
                }
                
                self.decodedTransaction = try JSONDecoder().decode(DecodedTransaction.self, from: (decodedTxJson?.data(using: .utf8))!)
            } else {
                print("invalid hex string")
            }
        } catch let error {
            print(error)
        }
        
        wrap(transaction: self.transaction)
    }
    
    @objc func showMenu(sender: UIBarButtonItem){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let copyTxHash = UIAlertAction(title: "Copy transaction hash", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.copyText(text: self.transaction.Hash)
        })
        
        let copyRawTx = UIAlertAction(title: "Copy raw transaction", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.copyText(text: self.transaction.Raw)
        })
        
        let viewOnDcrdata = UIAlertAction(title: "View on dcrdata", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.openLink(urlString: "https://testnet.dcrdata.org/tx/\(self.transaction.Hash)")
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(copyTxHash)
        alertController.addAction(copyRawTx)
        alertController.addAction(viewOnDcrdata)
        
        if let popoverPresentationController = alertController.popoverPresentationController {
            popoverPresentationController.barButtonItem = barButton
        }
        
        self.present(alertController, animated: true, completion: nil)

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0 ? details.count : 1)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.5
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView.init(frame: CGRect.zero)
        headerView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        headerView.frame.size.height = 0
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionDetailCell") as! TransactionDetailCell
            let data = details[indexPath.row]
            cell.txnDetails = data
            
            return cell
        case 1:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactiontInputDetails") as! TransactiontInputDetails
            cell.setup(with: transaction.Debits, decodedInputs: decodedTransaction.Inputs, presentingController: self)
            cell.expandOrCollapse = { [weak self] in
                self?.tableTransactionDetails.reloadData()
            }
            
            return cell
        case 2:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactiontOutputDetailsCell") as! TransactiontOutputDetailsCell
            cell.setup(with: transaction.Credits, decodedOutputs: decodedTransaction.Outputs, presentingController: self)
            cell.expandOrCollapse = { [weak self] in
                self?.tableTransactionDetails.reloadData()
            }
            
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section{
        case 0:
            
            if indexPath.row == 6 {
                copyText(text: transaction.Hash)
            }
            
        default:
            return
        }
    }
    
    private func copyText(text: String){
        DispatchQueue.main.async {
            //Copy a string to the pasteboard.
            UIPasteboard.general.string = text
            
            //Alert
            let alertController = UIAlertController(title: "", message: "Copied", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        progressHud?.dismiss()
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func wrap(transaction:Transaction?){
        
        var confirmations: Int32 = 0
        var status = "Pending"
        let textColor: UIColor?
        
        if(transaction!.Height != -1){
            confirmations = (SingleInstance.shared.wallet?.getBestBlock())! - Int32(transaction!.Height)
            confirmations += 1
        }
        
        let height = transaction?.Height
        if (height == -1) {
            status = "Pending"
            textColor = #colorLiteral(red: 0.2392156863, green: 0.3960784314, blue: 0.6117647059, alpha: 1)
        } else {
            if(UserDefaults.standard.bool(forKey: "pref_spend_fund_switch") || confirmations > 1) {
                status = "Confirmed"
                textColor = #colorLiteral(red: 0.2549019608, green: 0.7490196078, blue: 0.3254901961, alpha: 1)
            } else {
                status = "Pending"
                textColor = #colorLiteral(red: 0.2392156863, green: 0.3960784314, blue: 0.6117647059, alpha: 1)
            }
        }
        
        let amount = Decimal(Double((transaction?.Amount)!) / 1e8) as NSDecimalNumber
        let fee = Decimal(Double((transaction?.Fee)!) / 1e8) as NSDecimalNumber
        
        var txType: String
        if transaction?.Type.lowercased() == "ticket_purchase" {
            txType = "Ticket Purchase"
        }else{
            let first = String((transaction?.Type.prefix(1))!).capitalized
            let other = String((transaction?.Type.dropFirst())!).lowercased()
            print("First: \(first) Other: \(other)")
            txType = first + other
        }
        
        details = [
            TransactionDetails(
                title: "Date",
                value: NSMutableAttributedString(string: "\(format(timestamp: transaction?.Timestamp))"),
                textColor: nil
            ),
            TransactionDetails(
                title: "Status",
                value: NSMutableAttributedString(string:status),
                textColor: textColor
            ),
            TransactionDetails(
                title: "Amount",
                value: getAttributedString(str: "\(amount.round(8))", siz: 13, TexthexColor: GlobalConstants.Colors.TextAmount),
                textColor: nil
            ),
            TransactionDetails(
                title: "Fee",
                value: getAttributedString(str: "\(fee.round(8))", siz: 13, TexthexColor: GlobalConstants.Colors.TextAmount),
                textColor: nil
            ),
            TransactionDetails(
                title: "Type",
                value: NSMutableAttributedString(string: "\(txType)"),
                textColor: nil
            ),
            TransactionDetails(
                title: "Confirmation",
                value: NSMutableAttributedString(string:"\(confirmations)"),
                textColor: nil
            ),
            TransactionDetails(
                title: "Hash",
                value: NSMutableAttributedString(string:(transaction?.Hash)!),
                textColor: #colorLiteral(red: 0.1607843137, green: 0.4392156863, blue: 1, alpha: 1)
            )
        ]
        
        if(transaction?.Type.lowercased() == "vote"){
            
            let lastBlockValid = TransactionDetails(
                title: "Last Block Valid",
                value: NSMutableAttributedString(string: String(describing: (decodedTransaction?.LastBlockValid.string)!)),
                textColor: nil
            )
            details.append(lastBlockValid)
            
            let voteVersion = TransactionDetails(
                title: "Version",
                value: NSAttributedString(string: String(describing: (decodedTransaction?.VoteVersion)!)),
                textColor: nil
            )
            details.append(voteVersion)
            
            let voteBits = TransactionDetails(
                title: "Vote Bits",
                value: NSAttributedString(string: String(describing: (decodedTransaction?.VoteBits)!)),
                textColor: nil
            )
            details.append(voteBits)
        }
    }
    
    func openLink(urlString: String) {
        if let url = URL(string: urlString) {
            let viewController = SFSafariViewController(url: url, entersReaderIfAvailable: true)
            viewController.delegate = self as SFSafariViewControllerDelegate
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    fileprivate func format(timestamp:UInt64?) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy / hh:mm:ss a"
        let date = Date(timeIntervalSince1970: Double(timestamp!))
        return formatter.string(from: date)
    }
}

extension String {
    
    func base64Encoded() -> String? {
        return data(using: .utf8)?.base64EncodedString()
    }
    
    func base64Decoded() -> String? {
        var st = self;
        if (self.count % 4 <= 2){
            st += String(repeating: "=", count: (self.count % 4))
        }
        guard let data = Data(base64Encoded: st) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
