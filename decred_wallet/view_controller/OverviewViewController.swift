//
//  OverviewViewController.swift
//  Decred Wallet

// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import SlideMenuControllerSwift
import Dcrlibwallet
import JGProgressHUD
import UserNotifications

class OverviewViewController: UIViewController, DcrlibwalletGetTransactionsResponseProtocol, DcrlibwalletTransactionListenerProtocol,
DcrlibwalletBlockScanResponseProtocol, DcrlibwalletSpvSyncResponseProtocol {
    
    var peerCount = 0
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lbCurrentBalance: UILabel!
    @IBOutlet var viewTableHeader: UIView!
    @IBOutlet var viewTableFooter: UIView!
    @IBOutlet weak var activityIndicator: UIImageView!
    
    var visible = false
    var scanning = false
    var synced = false
    
    
    var mainContens = [Transaction]()
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerCellNib(DataTableViewCell.self)
        self.tableView.tableHeaderView = viewTableHeader
        self.tableView.tableFooterView = viewTableFooter
        refreshControl = {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action:
                #selector(OverviewViewController.handleRefresh(_:)),
                                     for: UIControlEvents.valueChanged)
            refreshControl.tintColor = UIColor.lightGray
            
            return refreshControl
        }()
        self.tableView.addSubview(self.refreshControl)
        
        
        connectToDecredNetwork()
        
        SingleInstance.shared.wallet?.transactionNotification(self)
        
        showActivity()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("low memory")
        
        // Dispose of any resources that can be recreated.
    }
    
    private func showActivity(){
        lbCurrentBalance.isHidden = true
        let image = UIImage.gifImageWithURL(Bundle.main.url(forResource: "progress bar-1s-200px", withExtension: "gif")?.absoluteString ?? "");
        activityIndicator.image = image
    }
    
    private func hideActivityIndicator(){
        activityIndicator.isHidden = true
        lbCurrentBalance.isHidden = false
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
        self.navigationItem.title = "Overview"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.visible = true
        if(UserDefaults.standard.bool(forKey: "synced") == true){
            if(self.mainContens.count != 0){
                self.tableView.reloadData()
                updateCurrentBalance()
                return
            }
            self.prepareRecent()
            updateCurrentBalance()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.visible = false
    }
    
    @IBAction func onRescan(_ sender: Any) {
        print("rescaning")
    }
    
    func connectToDecredNetwork(){
        let appInstance = UserDefaults.standard
        var passphrase = ""
        passphrase = appInstance.string(forKey: "password")!
        let finalPassphraseData = (passphrase as NSString).data(using: String.Encoding.utf8.rawValue)!
        
        if (appInstance.integer(forKey: "network_mode") == 0) {
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let _ = self else { return }
                do {
                    SingleInstance.shared.wallet?.add(self)
                    try
                        SingleInstance.shared.wallet?.spvSync("127.0.0.1")
                    print("done syncing")
                } catch {
                    print(error)
                }
            }
        } else {
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let this = self else { return }
                do {
                    try
                        SingleInstance.shared.wallet?.unlock(finalPassphraseData)
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func updateCurrentBalance(){
        var amount = "0"
        var account = GetAccountResponse()
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard self != nil else { return }
            do {
                let strAccount = try SingleInstance.shared.wallet?.getAccounts(0)
                account = try JSONDecoder().decode(GetAccountResponse.self, from: (strAccount?.data(using: .utf8))!)
                amount = "\((account.Acc.first?.dcrTotalBalance)!)"
                DispatchQueue.main.async {
                    self?.hideActivityIndicator()
                    if(amount != nil){
                        self?.lbCurrentBalance.attributedText = getAttributedString(str: amount, siz: 15.0)
                    }
                }
            } catch let error {
                print(error)
            }
        }
    }
    
    func prepareRecent(){
        self.mainContens.removeAll()
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let this = self else { return }
            do {
                try
                    SingleInstance.shared.wallet?.getTransactions(this)
            } catch let Error {
                print(Error)
            }
        }
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.prepareRecent()
        refreshControl.endRefreshing()
    }
    
    func onResult(_ json: String!) {
        if (self.visible == false) {
            return
        } else {
            let tjson = json
            DispatchQueue.main.async {
                do {
                    let trans = GetTransactionResponse.self
                    let transactions = try JSONDecoder().decode(trans, from: (tjson?.data(using: .utf8)!)!)
                    if (transactions.Transactions.count) > 0 {
                        if transactions.Transactions.count > self.mainContens.count {
                            print(transactions.Transactions.count)
                            self.mainContens.removeAll()
                            for transactionPack in transactions.Transactions {
                                self.mainContens.append(transactionPack)
                            }
                            self.mainContens.reverse()
                            self.tableView.reloadData()
                            self.updateCurrentBalance()
                        }
                    }
                    return
                    
                } catch let error {
                    print(error)
                    return
                }
            }
        }
    }
    
    func onSyncError(_ code: Int, err: Error!) {
        print("sync error")
        print(err)
    }
    
    func onSynced(_ synced: Bool) {
        
        self.synced = synced
        UserDefaults.standard.set(false, forKey: "walletScanning")
        UserDefaults.standard.set(synced, forKey: "synced")
        UserDefaults.standard.synchronize()
        
        if(self.visible == false){
            return
        }
        
        if(synced == true){
            if(visible == true){
                self.prepareRecent()
                self.updateCurrentBalance()
            }
        }
    }
    
    func onBlockNotificationError(_ err: Error!) {
        print(err)
    }
    
    func onTransactionConfirmed(_ hash: String!, height: Int32) {
        if(visible == true){
            self.prepareRecent()
            updateCurrentBalance()
        }
    }
    
    func onEnd(_ height: Int32, cancelled: Bool) {
        
    }
    
    func onError(_ code: Int32, message: String!) {
        
    }
    
    func onScan(_ rescannedThrough: Int32) -> Bool {
        UserDefaults.standard.set(true, forKey: "walletScanning")
        UserDefaults.standard.synchronize()
        return true
    }
    
    func onTransactionRefresh() {
        print("refresh")
    }
    
    func onTransaction(_ transaction: String!) {
        
        print("New transaction for onTransaction")
        var transactions = try! JSONDecoder().decode(Transaction.self, from:transaction.data(using: .utf8)!)
        
        if(self.mainContens.contains(where: { $0.Hash == transactions.Hash })){
            return
        }
        
        self.mainContens.append(transactions)
        
        if(transactions.Fee == 0 && UserDefaults.standard.bool(forKey: "pref_notification_switch") == true){
            let content = UNMutableNotificationContent()
            content.title = "New Transaction"
            let tnt = Decimal(transactions.Amount / 100000000.00) as NSDecimalNumber
            content.body = "You received ".appending(tnt.round(8).description).appending(" DCR")
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: "TxnIdentifier", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
        
        transactions.Animate = true
        DispatchQueue.main.async {
            self.mainContens.reverse()
            
            self.mainContens.append(transactions)
            self.mainContens.reverse()
            if(self.visible == false){
                return
            }
            self.tableView.reloadData()
        }
        
        self.updateCurrentBalance()
        return
    }
    
    func onFetchMissingCFilters(_ missingCFitlersStart: Int32, missingCFitlersEnd: Int32, state: String!) {}
    
    func onFetchedHeaders(_ fetchedHeadersCount: Int32, lastHeaderTime: Int64, state: String!) {}
    
    func onRescan(_ rescannedThrough: Int32, state: String!) {}
    
    func onError(_ err: String!) {}
    
    func onDiscoveredAddresses(_ state: String!) {}
    
    func onFetchMissingCFilters(_ missingCFitlersStart: Int32, missingCFitlersEnd: Int32, finished: Bool) {}
    
    func onFetchedHeaders(_ fetchedHeadersCount: Int32, lastHeaderTime: Int64, finished: Bool) {}
    
    func onRescanProgress(_ rescannedThrough: Int32, finished: Bool) {}
    
    func onFetchMissingCFilters(_ missingCFitlersStart: Int32, missingCFitlersEnd: Int32) {}
    
    func onBlockAttached(_ height: Int32, timestamp: Int64) {}
    
    func onBlockAttached(_ height: Int32) {}
    
    func onDiscoveredAddresses(_ finished: Bool) {}
    
    func onFetchMissingCFilters(_ fetchedCFiltersCount: Int32) {}
    
    func onFetchedHeaders(_ fetchedHeadersCount: Int32, lastHeaderTime: Int64) {}
    
    func onPeerConnected(_ peerCount: Int32) {
        
        self.peerCount = Int(peerCount)
        UserDefaults.standard.set(self.peerCount, forKey: "peercount")
        UserDefaults.standard.synchronize()
        
    }
    
    func onPeerDisconnected(_ peerCount: Int32) {
        
        self.peerCount = Int(peerCount)
        UserDefaults.standard.set(self.peerCount, forKey: "peercount")
        UserDefaults.standard.synchronize()
        
    }
    
    func onRescanProgress(_ rescannedThrough: Int32) {}
}

extension OverviewViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return DataTableViewCell.height()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "TransactionFullDetailsViewController", bundle: nil)
        let subContentsVC = storyboard.instantiateViewController(withIdentifier: "TransactionFullDetailsViewController") as! TransactionFullDetailsViewController
        print(indexPath.row)
        if self.mainContens.count == 0{
            return
        }
        subContentsVC.transaction = self.mainContens[indexPath.row]
        self.navigationController?.pushViewController(subContentsVC, animated: true)
    }
    
}

extension OverviewViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(self.mainContens.count, 6)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: DataTableViewCell.identifier) as! DataTableViewCell
        if self.mainContens.count != 0{
            let data = DataTableViewCellData(trans: self.mainContens[indexPath.row])
            cell.setData(data)
            return cell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if(self.mainContens.count != 0){
            if(self.mainContens[indexPath.row].Animate){
                cell.blink()
            }
            self.mainContens[indexPath.row].Animate = false
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {}
}

extension OverviewViewController : SlideMenuControllerDelegate {
    
    func leftWillOpen() {}
    
    func leftDidOpen() {}
    
    func leftWillClose() {}
    
    func leftDidClose() {}
    
    func rightWillOpen() {}
    
    func rightDidOpen() {}
    
    func rightWillClose() {}
    
    func rightDidClose() {}
}
