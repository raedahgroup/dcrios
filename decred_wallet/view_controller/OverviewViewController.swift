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

class OverviewViewController: UIViewController, DcrlibwalletGetTransactionsResponseProtocol, DcrlibwalletTransactionListenerProtocol, DcrlibwalletBlockScanResponseProtocol, DcrlibwalletSpvSyncResponseProtocol {
    
    weak var delegate : LeftMenuProtocol?
    var pinInput: String?
    var reScan_percentage = 0.1;
    var discovery_percentage = 0.8
    var peerCount = 0
    var bestBlock :Int32?
    var bestBlockTimestamp : Int64?
    @IBOutlet weak var syncProgressbar: UIProgressView!
    @IBOutlet weak var syncContainer: UIView!
    @IBOutlet weak var topAmountContainer: UIStackView!
    @IBOutlet weak var bottomBtnContainer: UIStackView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lbCurrentBalance: UILabel!
    @IBOutlet var viewTableHeader: UIView!
    @IBOutlet var viewTableFooter: UIView!
    @IBOutlet weak var activityIndicator: UIImageView!
    @IBOutlet weak var SendBtn: UIButton!
    @IBOutlet weak var showAllTransactionBtn: UIButton!
    @IBOutlet weak var connetStatus: UIButton!
    @IBOutlet weak var chainStatusText: UIButton!
    @IBOutlet weak var daysbeindText: UIButton!
    @IBOutlet weak var peersSyncText: UILabel!
    
    @IBOutlet weak var tapViewMoreBtn: UIButton!
    @IBOutlet weak var percentageComplete: UILabel!
    @IBOutlet weak var ReceiveBtn: UIButton!
    var visible = false
    var scanning = false
    var synced = false
    var showAllSyncInfo = false
    var recognizer:UIGestureRecognizer?
    var recognizer2 : UIGestureRecognizer?
    var recognizer3 : UIGestureRecognizer?
    var recognizer4 : UIGestureRecognizer?
    @IBOutlet weak var connectStatusCont: UIStackView!
    @IBOutlet weak var chainStatusCont: UIStackView!
    @IBOutlet weak var verboseContainer: UIView!
    @IBOutlet weak var verboseText: UIButton!
    @IBOutlet weak var dummyVerboseCont: UIView!
    @IBOutlet weak var syncLoadingText: UILabel!
    var wallet = SingleInstance.shared.wallet
    var walletInfo = SingleInstance.shared
    var NetType = "mainnet"
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
                                     for: UIControl.Event.valueChanged)
            refreshControl.tintColor = UIColor.lightGray
            
            return refreshControl
        }()
        
        let isTestnet = Bool(infoForKey(GlobalConstants.Strings.IS_TESTNET)!)!
        NetType = isTestnet ? "testnet" : "mainnet"
        self.tableView.addSubview(self.refreshControl)
        self.setupSendRecvBtn()
        self.verboseText.contentHorizontalAlignment = .center
        self.verboseText.contentVerticalAlignment = .top
        self.verboseText.titleLabel?.textAlignment = .center
        self.wifiSyncOption()
    }
    
    func wifiSyncOption() {
        let wifiselect = UserDefaults.standard.integer(forKey: "wifsync")
        switch wifiselect {
        case 0:
            wifCheck()
            break
        case 1:
            wifCheck()
            break
        case 2:
            self.setupConnection()
            break
        default:
            wifCheck()
        }
    }
    
    func setupConnection() {
        self.connectToDecredNetwork()
        
        self.wallet?.transactionNotification(self)
        self.wallet?.add(self)
        self.walletInfo.syncing = true
        self.SyncGestureSetup()
        self.showActivity()
    }
    
    func wifCheck() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let WifiConfirmationController = storyboard.instantiateViewController(withIdentifier: "WifiSyncView") as! WifiConfirmationController
        WifiConfirmationController.modalTransitionStyle = .crossDissolve
        WifiConfirmationController.modalPresentationStyle = .overCurrentContext
        
        let tap = UITapGestureRecognizer(target: WifiConfirmationController.view, action: #selector(WifiConfirmationController.msgContent.endEditing(_:)))
        tap.cancelsTouchesInView = false
        
        WifiConfirmationController.view.addGestureRecognizer(tap)
        
        WifiConfirmationController.Always = {
            UserDefaults.standard.set(2, forKey: "wifsync")
            UserDefaults.standard.synchronize()
            self.setupConnection()
        }
        WifiConfirmationController.Yes = {
            UserDefaults.standard.set(1, forKey: "wifsync")
            UserDefaults.standard.synchronize()
            self.setupConnection()
        }
        WifiConfirmationController.No = {
            UserDefaults.standard.set(0, forKey: "wifsync")
            UserDefaults.standard.synchronize()
        }
        
        DispatchQueue.main.async {
            self.present(WifiConfirmationController, animated: true, completion: nil)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("low memory")
        
        // Dispose of any resources that can be recreated.
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
        if (appInstance.integer(forKey: "network_mode") == 0) {
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let _ = self else { return }
                do {
                    self!.wallet?.add(self)
                    try
                        self!.wallet?.spvSync(getPeerAddress(appInstance: appInstance))
                    print("done syncing")
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func updateCurrentBalance() {
        var amount = "0"
        var account = GetAccountResponse()
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard self != nil else { return }
            do {
                var getAccountError: NSError?
                let strAccount = self!.wallet?.getAccounts(0, error: &getAccountError)
                if getAccountError != nil {
                    throw getAccountError!
                }
                
                account = try JSONDecoder().decode(GetAccountResponse.self, from: (strAccount?.data(using: .utf8))!)
                amount = "\((account.Acc.filter({UserDefaults.standard.bool(forKey: "hidden\($0.Number)") != true}).map{$0.dcrTotalBalance}.reduce(0,+)))"
                let amountTmp = Decimal(Double(amount)!) as NSDecimalNumber
            
                DispatchQueue.main.async {
                    self?.hideActivityIndicator()
                    self?.lbCurrentBalance.attributedText = getAttributedString(str: "\(amountTmp.round(8))", siz: 17.0, TexthexColor: GlobalConstants.Colors.TextAmount)
                    self!.walletInfo.walletBalance = "\(amountTmp.round(8))"
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
                    self!.wallet?.getTransactions(this)
            } catch let Error {
                print(Error)
            }
        }
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.prepareRecent()
        refreshControl.endRefreshing()
    }
    
    
    //Sync Indicator functions
    @IBAction func viewMoreInfo(_ sender: Any) {
        self.tapViewMoreFunc()
    }
    func tapViewMoreFunc(){
        DispatchQueue.main.async {
            if (self.showAllSyncInfo){
                self.ShowAllSync()
            }
            else{
                self.ShowhalfSync()
            }
            
        }
    }
    func ShowhalfSync() {
         DispatchQueue.main.async {
            self.tapViewMoreBtn.isHidden = true
            self.chainStatusText.isHidden = false
            self.connetStatus.isHidden = false
            self.daysbeindText.isHidden = false
            self.peersSyncText.isHidden = false
            self.verboseContainer.isHidden = true
            self.dummyVerboseCont.isHidden = false
        }
    }
    func ShowAllSync(){
         DispatchQueue.main.async {
            self.tapViewMoreBtn.isHidden = true
            self.chainStatusText.isHidden = false
            self.connetStatus.isHidden = false
            self.daysbeindText.isHidden = false
            self.peersSyncText.isHidden = false
            self.verboseContainer.isHidden = false
            self.dummyVerboseCont.isHidden = true
        }
    }
    func hideHalfSynce(){
         DispatchQueue.main.async {
            self.tapViewMoreBtn.isHidden = false
            self.chainStatusText.isHidden = true
            self.connetStatus.isHidden = true
            self.daysbeindText.isHidden = true
            self.peersSyncText.isHidden = true
            self.verboseContainer.isHidden = true
            self.dummyVerboseCont.isHidden = false
        }
        
        
    }
    func hideAllSync(){
         DispatchQueue.main.async {
            self.tapViewMoreBtn.isHidden = false
            self.chainStatusText.isHidden = true
            self.connetStatus.isHidden = true
            self.daysbeindText.isHidden = true
            self.peersSyncText.isHidden = true
            self.verboseContainer.isHidden = true
            self.dummyVerboseCont.isHidden = false
        }
    }
    var count = 0
    @objc func longPressHappened(gesture: UILongPressGestureRecognizer){
        if gesture.state == UIGestureRecognizer.State.began {
                if !(self.showAllSyncInfo){
                self.ShowAllSync()
                    self.showAllSyncInfo = true
            }else{
                self.ShowhalfSync()
                    self.showAllSyncInfo = false
            }
                return
        }
    }
    @IBAction func toggleViewInfo(_ sender: UIButton) {
            self.hideAllSync()
    }
    
    func SyncGestureSetup(){
        self.recognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressHappened))
        self.recognizer2 = UILongPressGestureRecognizer(target: self, action: #selector(longPressHappened))
        self.recognizer3 = UILongPressGestureRecognizer(target: self, action: #selector(longPressHappened))
        self.recognizer4 = UILongPressGestureRecognizer(target: self, action: #selector(longPressHappened))
        self.connetStatus.addGestureRecognizer(recognizer!)
        self.chainStatusText.addGestureRecognizer(recognizer2!)
        self.verboseText.addGestureRecognizer(recognizer3!)
        self.daysbeindText.addGestureRecognizer(recognizer4!)
    }
   
    func hideSyncContainers(){
        DispatchQueue.main.async {
            self.topAmountContainer.isHidden = false
            self.bottomBtnContainer.isHidden = false
            self.syncContainer.isHidden = true
            self.tableView.isHidden = false
        }
    }
    
    
    func onResult(_ json: String?) {
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
    
    func onSyncError(_ code: Int, err: Error?) {
        print("sync error")
        print(err!)
    }
    
    func onSynced(_ synced: Bool) {
        self.synced = synced
        UserDefaults.standard.set(false, forKey: "walletScanning")
        UserDefaults.standard.set(synced, forKey: "synced")
        UserDefaults.standard.synchronize()
        self.walletInfo.synced = synced
        self.walletInfo.syncing = false
        if (synced) {
            self.walletInfo.syncStartPoint = -1
            self.walletInfo.syncEndPoint = -1
            self.walletInfo.syncCurrentPoint = -1
            self.walletInfo.syncRemainingTime = -1
            self.walletInfo.fetchHeaderTime = -1
            self.walletInfo.syncStatus = ""
            self.hideSyncContainers()
            if !(self.visible){
                return
            }
            else{
                self.prepareRecent()
                self.updateCurrentBalance()
            }
        }
        
    }
    //overview UI functions
    
    func setupSendRecvBtn(){
        ReceiveBtn.layer.cornerRadius = 4
        
        ReceiveBtn.layer.borderWidth = 1.5
        ReceiveBtn.layer.borderColor = UIColor(hex: "#596D81", alpha:0.8).cgColor
        SendBtn.layer.cornerRadius = 4
        SendBtn.layer.borderWidth = 1.5
        SendBtn.layer.borderColor = UIColor(hex: "#596D81", alpha:0.8).cgColor
        showAllTransactionBtn.layer.borderWidth = 1.5
        showAllTransactionBtn.layer.borderColor = UIColor(hex: "#596D81", alpha:0.8).cgColor
        showAllTransactionBtn.layer.cornerRadius = 4
    }
    
    @IBAction func sendView(_ sender: Any) {
        UIApplication.shared.beginIgnoringInteractionEvents()
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            self.delegate!.changeViewController(LeftMenu.send)
            UIApplication.shared.endIgnoringInteractionEvents()
        }
        
    }
    @IBAction func receiveView(_ sender: Any) {
        UIApplication.shared.beginIgnoringInteractionEvents()
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            self.delegate!.changeViewController(LeftMenu.receive)
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
    
    @IBAction func historyView(_ sender: Any) {
        UIApplication.shared.beginIgnoringInteractionEvents()
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            self.delegate!.changeViewController(LeftMenu.history)
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
    private func showActivity(){
        lbCurrentBalance.isHidden = true
        activityIndicator.loadGif(name: "progress bar-1s-200px")
    }
    
    private func hideActivityIndicator(){
        activityIndicator.isHidden = true
        lbCurrentBalance.isHidden = false
    }
    
    func onBlockNotificationError(_ err: Error!) {
        print(err!)
    }
    
    func onTransactionConfirmed(_ hash: String?, height: Int32) {
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
    
    func onTransaction(_ transaction: String?) {
        
        print("New transaction for onTransaction")
        var transactions = try! JSONDecoder().decode(Transaction.self, from:(transaction?.data(using: .utf8)!)!)
        
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
    
    func updatePeerCount() {
        if (!self.walletInfo.synced && !self.walletInfo.syncing) {
            self.walletInfo.syncStatus = "Not Synced";
            return
    }
        if (!self.walletInfo.syncing) {
            if (self.walletInfo.peers == 1) {
                self.walletInfo.syncStatus = "Synced with 1 peer";
                
            } else {
                self.walletInfo.syncStatus = "Synced with \(self.walletInfo.peers) peers "
                }
            
        }else {
            if (self.walletInfo.peers == 1) {
                self.walletInfo.syncStatus = "Synced with 1 peer"
                
            } else {
                 self.walletInfo.syncStatus = "Synced with \(self.walletInfo.peers) peers "
            }
        }
    }
    
    func onFetchMissingCFilters(_ missingCFitlersStart: Int32, missingCFitlersEnd: Int32, state: String?) {}
    
    var headerTime: Int64 = 0
    func onFetchedHeaders(_ fetchedHeadersCount: Int32, lastHeaderTime: Int64, state: String?) {
        DispatchQueue.global(qos: .background).async {
        if (!self.walletInfo.syncing) {
            // Ignore this call because this function gets called for each peer and
            // we'd want to ignore those calls as far as the wallet is synced.
            return
        } else if (self.walletInfo.totalFetchTime != -1) {
            return
        }
        
        
        print("last header time \(lastHeaderTime)")
        let bestblck = self.wallet?.getBestBlock()
        let bestblocktemp = Int64(bestblck!)
        let lastblocktime = self.wallet?.getBestBlockTimeStamp()
        let currentTime = Date().millisecondsSince1970 / 1000;
        let targetTimePerBlock = Int64(infoForKey("TargetTimePerBlock")!)!
        let estimatedBlocks = ((currentTime - lastblocktime!) / targetTimePerBlock ) + bestblocktemp
        
        switch (state) {
        case DcrlibwalletSTART:
            if (self.walletInfo.fetchHeaderTime != -1) {
                return
            }
            
            self.walletInfo.syncStatus = "Fetching headers...";
            
            self.walletInfo.syncStartPoint = Int64((self.wallet?.getBestBlock())!);
            self.walletInfo.syncEndPoint = estimatedBlocks - self.walletInfo.syncStartPoint;
            if !(self.walletInfo.syncStartPoint < estimatedBlocks){
                return
            }
            self.walletInfo.syncCurrentPoint =  self.walletInfo.syncStartPoint;
            self.walletInfo.fetchHeaderTime = Date().millisecondsSince1970
           self.hideAllSync()
            DispatchQueue.main.async {
            self.tapViewMoreBtn.isEnabled = false
            self.tapViewMoreBtn.setTitle("", for: .normal)
            }
          //  syncProgressBar.setProgress(0)
          //  syncProgressBar.setVisibility(View.VISIBLE);
            break
        case DcrlibwalletPROGRESS:
           if (self.headerTime == lastHeaderTime ){
                print("returning it")
                return
            }
            self.headerTime = lastHeaderTime
            self.walletInfo.syncEndPoint = estimatedBlocks - self.walletInfo.syncStartPoint
            self.walletInfo.syncCurrentPoint += Int64(fetchedHeadersCount)
            var count = self.walletInfo.syncCurrentPoint
            if (self.walletInfo.syncStartPoint > 0) {
                count -= self.walletInfo.syncStartPoint;
            }
            
            let percent =  Float(count) / Float(self.walletInfo.syncEndPoint)
            let totalFetchTime = Double((Date().millisecondsSince1970 - self.walletInfo.fetchHeaderTime)) / Double(percent)
            let remainingFetchTime = round(totalFetchTime) - Double((Date().millisecondsSince1970 - self.walletInfo.fetchHeaderTime));
            let elapsedFetchTime = Double(Date().millisecondsSince1970 - self.walletInfo.fetchHeaderTime)
            //10% of fetch time is used for estimating both rescan while 80% is used for address discovery time
           let estimatedRescanTime = totalFetchTime * self.reScan_percentage;
           let estimatedDiscoveryTime = totalFetchTime * self.discovery_percentage;
            let totalSyncTime = totalFetchTime + estimatedRescanTime + estimatedDiscoveryTime;
             let syncTimeLeft = remainingFetchTime + estimatedRescanTime + estimatedDiscoveryTime
            if !(syncTimeLeft.isNaN || syncTimeLeft.isInfinite){
                self.walletInfo.syncRemainingTime = Int64(round(syncTimeLeft));
                self.walletInfo.syncProgress = Int(( Double(elapsedFetchTime) / Double(totalSyncTime) * 100.0))
                self.walletInfo.syncStatus = "Fetching block headers."
                self.walletInfo.bestBlockTime = "\(lastHeaderTime)"
                self.walletInfo.ChainStatus = "\(self.walletInfo.syncEndPoint - count) blocks behind."
                let daysBehind = calculateDays(seconds: ((Date().millisecondsSince1970 / 1000) - lastHeaderTime))
                self.walletInfo.bestblockTimeInfo = "\(daysBehind) ago"
                let status = "Fetched \(count) of \(self.walletInfo.syncEndPoint) block headers."
                let status2 = "\(round(percent * 100))% through step 1 of 3."
                let status3 = " Your wallet is \(daysBehind) behind."
                let percentage = getSyncTimeRemaining(millis: self.walletInfo.syncRemainingTime, percentageCompleted: Int(self.walletInfo.syncProgress), syncView: true)
                let status4 = "All Times\nelapsed: \(getTime(millis: Int64(elapsedFetchTime))) remain: \(getTime(millis: self.walletInfo.syncRemainingTime)) total: \(getTime(millis: Int64(round(totalSyncTime)))) \n\nStage Times\nelapsed: \(getTime(millis: Int64(elapsedFetchTime))) remain: \(getTime(millis: Int64(remainingFetchTime)))  total: \(getTime(millis: Int64(round(totalFetchTime))))"

                DispatchQueue.main.async {
                    self.syncLoadingText.text = "Synchronizing"
                    self.connetStatus.setTitle(status, for: .normal)
                    self.percentageComplete.text = percentage
                    self.chainStatusText.setTitle(status2, for: .normal)
                    self.tapViewMoreBtn.isEnabled = false
                    self.tapViewMoreBtn.setTitle("Tap to view information", for: .normal)
                    self.daysbeindText.setTitle(status3, for: .normal)
                    self.syncProgressbar.isHidden = false
                    self.tapViewMoreBtn.isEnabled = true
                    self.syncProgressbar.progressTintColor = UIColor(hex: "#7fcc9e")
                    self.syncProgressbar.progress = (Float(self.walletInfo.syncProgress) / 100.0)
                    print("progress = \(self.walletInfo.syncProgress)")
                    self.verboseText.setTitle(status4, for: .normal)
                    self.peersSyncText.text = "Syncing with \(self.peerCount) peers on \(self.NetType)."
                
                }
                if (self.walletInfo.initialSyncEstimate == -1) {
                    self.walletInfo.initialSyncEstimate = self.walletInfo.syncRemainingTime;
                }
    }
            break
        case DcrlibwalletFINISH:
            self.updatePeerCount();
            self.walletInfo.totalFetchTime = Date().millisecondsSince1970 - self.walletInfo.fetchHeaderTime;
            self.walletInfo.syncStartPoint = -1;
           self.walletInfo.syncEndPoint = -1;
           self.walletInfo.syncCurrentPoint = -1;
            self.walletInfo.syncStatus = ""
            self.walletInfo.ChainStatus = ""
            self.walletInfo.bestblockTimeInfo = ""
            DispatchQueue.main.async {
                self.daysbeindText.setTitle("", for: .normal)
            }
            break;
        default:
            break
        }
        }
    }
    
    
    func onRescan(_ rescannedThrough: Int32, state: String?) {
        DispatchQueue.global(qos: .background).async {
        if (self.walletInfo.syncEndPoint == -1) {
            self.walletInfo.syncEndPoint = Int64(self.wallet!.getBestBlock());
        }
        
        switch (state) {
        case DcrlibwalletSTART:
            self.walletInfo.syncStatus = "Scanning blocks."
            self.walletInfo.syncStartPoint = 0;
            self.walletInfo.syncCurrentPoint = 0;
            self.walletInfo.syncEndPoint = Int64(self.wallet!.getBestBlock());
            self.walletInfo.rescanTime = Date().millisecondsSince1970;
            break;
        case DcrlibwalletPROGRESS:
            
            let scannedPercentage = ((Double(rescannedThrough) / Double(self.walletInfo.syncEndPoint)) * 100)
            let elapsedRescanTime = Date().millisecondsSince1970 - self.walletInfo.rescanTime;
            let totalScanTime = Double(elapsedRescanTime) / ((Double(rescannedThrough) / Double(self.walletInfo.syncEndPoint)))
            let totalSyncTime = Double(self.walletInfo.totalFetchTime) + Double(self.walletInfo.totalDiscoveryTime) + totalScanTime
            let elapsedTime = (Double(self.walletInfo.totalFetchTime) + Double(self.walletInfo.totalDiscoveryTime) + Double(elapsedRescanTime))
            
            self.walletInfo.syncRemainingTime = Int64(round(totalScanTime)) - elapsedRescanTime
            self.walletInfo.syncProgress = Int((Double(elapsedTime) /  Double(totalSyncTime)) * 100.0)
            let status = "Scanning \(rescannedThrough) of \(self.walletInfo.syncEndPoint) block headers."
            let status2 = "\(round(scannedPercentage))% through step 3 of 3."
            self.walletInfo.syncStatus = status
            let status4 = "All Times\nelapsed: \(getTime(millis: Int64(round(Double(elapsedTime))))) remain: \(getTime(millis: self.walletInfo.syncRemainingTime)) total: \(getTime(millis: Int64(round(totalSyncTime)))) \n\nStage Times\nelapsed: \(getTime(millis: Int64(round(Double(elapsedRescanTime))))) remain: \(getTime(millis: self.walletInfo.syncRemainingTime))  total: \(getTime(millis: Int64(round(totalScanTime))))"
            
            let percentage = getSyncTimeRemaining(millis: self.walletInfo.syncRemainingTime, percentageCompleted: Int(self.walletInfo.syncProgress), syncView: true)
            DispatchQueue.main.async {
                self.syncProgressbar.progressTintColor = UIColor(hex: "#7fcc9e")
                self.syncProgressbar.progress = (Float(self.walletInfo.syncProgress) / 100.0)
                self.syncLoadingText.text = "Synchronizing"
                self.syncProgressbar.isHidden = false
                print("progress = \(self.walletInfo.syncProgress)")
                self.percentageComplete.text = percentage
                self.chainStatusText.setTitle(status2, for: .normal)
               self.connetStatus.setTitle(status, for: .normal)
                self.daysbeindText.isHidden = true
                self.verboseText.setTitle(status4,for: .normal)
                self.peersSyncText.text = "Syncing with \(self.peerCount) peers on \(self.NetType)."
                if !(self.tapViewMoreBtn.isEnabled){
                    self.hideAllSync()
                    self.tapViewMoreBtn.isEnabled = true
                    self.tapViewMoreBtn.setTitle("Tap to view information", for: .normal)
                }
                
            }
             let percentage3 = getSyncTimeRemaining(millis: self.walletInfo.syncRemainingTime, percentageCompleted: Int(self.walletInfo.syncProgress), syncView: false)
            self.walletInfo.syncStatus = "Scanning blocks."
            self.walletInfo.bestblockTimeInfo = ""
            self.walletInfo.ChainStatus = percentage3
            break;
        default:
            self.updatePeerCount();
            break;
        }
        }
    }
    
    func onError(_ err: String?) {}
    
    func onDiscoveredAddresses(_ state: String?) {
       // setChainStatus(null);
        DispatchQueue.global(qos: .background).async {
            if ((state?.elementsEqual(DcrlibwalletSTART))!) {
                    self.walletInfo.accountDiscoveryStartTime = Date().millisecondsSince1970;
            let estimatedRescanTime = round(Double(self.walletInfo.totalFetchTime) * Double(self.reScan_percentage))
            let estimatedDiscoveryTime = round(Double(self.walletInfo.totalFetchTime) * Double(self.discovery_percentage));

            let elapsedDiscoveryTime = Date().millisecondsSince1970 - self.walletInfo.accountDiscoveryStartTime;
                    
            var totalSyncTime = 0.0
                    if (Double(elapsedDiscoveryTime) > Double(estimatedDiscoveryTime)) {
                    totalSyncTime = Double(self.walletInfo.totalFetchTime) + Double(elapsedDiscoveryTime) + estimatedRescanTime
                    } else {
                    totalSyncTime = Double(self.walletInfo.totalFetchTime) + estimatedDiscoveryTime + estimatedRescanTime;
                    }
                    
            let elapsedTime = Double(self.walletInfo.totalFetchTime) + Double(elapsedDiscoveryTime);
                    
                    var remainingAccountDiscoveryTime = round(Double(estimatedDiscoveryTime) - Double(elapsedDiscoveryTime))
                    if (remainingAccountDiscoveryTime < 0) {
                    remainingAccountDiscoveryTime = 0;
                    }
                    
            self.walletInfo.syncProgress = Int((Double(elapsedTime) / Double( totalSyncTime)) * 100.0)
            self.walletInfo.syncRemainingTime = Int64((remainingAccountDiscoveryTime + estimatedRescanTime))
                    
                    self.walletInfo.syncStatus = "Discovering used addresses."
            
            let percentage = getSyncTimeRemaining(millis: self.walletInfo.syncRemainingTime, percentageCompleted: self.walletInfo.syncProgress, syncView: true)
            let status = "Discovering used addresses."
            let discoveryProgress = round((Double(elapsedDiscoveryTime) / Double(estimatedDiscoveryTime)) * 100.0);
            var status2 = ""
            let status4 = "All Times\nelapsed: \(getTime(millis: Int64(round(Double(elapsedTime))))) remain: \(getTime(millis: self.walletInfo.syncRemainingTime)) total: \(getTime(millis: Int64(round(totalSyncTime)))) \n\nStage Times\nelapsed: \(getTime(millis: Int64(round(Double(elapsedDiscoveryTime))))) remain: \(getTime(millis: self.walletInfo.syncRemainingTime))  total: \(getTime(millis: Int64(round(totalSyncTime))))"
            if (discoveryProgress > 100) {
                status2 = "\(discoveryProgress)% (over) through step 2 of 3."
                        } else {
                            status2 = "\(discoveryProgress)% through step 2 of 3."
                        }
            DispatchQueue.main.async {
                self.syncLoadingText.text = "Synchronizing"
                self.syncProgressbar.isHidden = false
                self.syncProgressbar.progressTintColor = UIColor(hex: "#7fcc9e")
                self.syncProgressbar.progress = (Float(self.walletInfo.syncProgress) / 100.0)
                print("progress = \(self.walletInfo.syncProgress)")
                self.percentageComplete.text = percentage
                self.chainStatusText.setTitle(status2, for: .normal)
                self.connetStatus.setTitle(status, for: .normal)
                self.daysbeindText.isHidden = true
                self.verboseText.setTitle(status4, for: .normal)
               
                self.peersSyncText.text = "Syncing with \(self.peerCount) peers on \(self.NetType)."
                if !(self.tapViewMoreBtn.isEnabled){
                    self.hideAllSync()
                    self.tapViewMoreBtn.isEnabled = true
                    self.tapViewMoreBtn.setTitle("Tap to view information", for: .normal)
                }
                
            }
            let percentage3 = getSyncTimeRemaining(millis: self.walletInfo.syncRemainingTime, percentageCompleted: Int(self.walletInfo.syncProgress), syncView: false)
            self.walletInfo.bestblockTimeInfo = ""
            self.walletInfo.ChainStatus = percentage3
            
     
        } else {
            
            self.walletInfo.totalDiscoveryTime = (Date().millisecondsSince1970 - self.walletInfo.accountDiscoveryStartTime);
            self.updatePeerCount();
        }
        }
    }
    
    func onFetchMissingCFilters(_ missingCFitlersStart: Int32, missingCFitlersEnd: Int32, finished: Bool) {}
    
    func onFetchedHeaders(_ fetchedHeadersCount: Int32, lastHeaderTime: Int64, finished: Bool) {}
    
    func onRescanProgress(_ rescannedThrough: Int32, finished: Bool) {}
    
    func onFetchMissingCFilters(_ missingCFitlersStart: Int32, missingCFitlersEnd: Int32) {}
    
    func onBlockAttached(_ height: Int32, timestamp: Int64) {
        self.bestBlock = height;
        self.bestBlockTimestamp = timestamp / 1000000000;
        if (!self.walletInfo.syncing) {
            let status =  "latest Block \(String(describing: bestBlock))"
            self.walletInfo.ChainStatus = status
           self.updateCurrentBalance()
            self.walletInfo.bestBlockTime = "\(String(describing: bestBlockTimestamp))"
            }
        
    }
    
    func onBlockAttached(_ height: Int32) {}
    
    func onDiscoveredAddresses(_ finished: Bool) {}
    
    func onFetchMissingCFilters(_ fetchedCFiltersCount: Int32) {}
    
    func onFetchedHeaders(_ fetchedHeadersCount: Int32, lastHeaderTime: Int64) {
       
    }
    
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
        let maxDisplayItems = round(tableView.frame.size.height / DataTableViewCell.height())
        return min(self.mainContens.count, Int(maxDisplayItems))
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
extension Date {
    var millisecondsSince1970:Int64 {
         return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

