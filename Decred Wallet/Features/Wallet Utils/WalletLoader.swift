//
//  WalletLoader.swift
//  Decred Wallet
//
//  Created by Wisdom Arerosuoghene on 09/05/2019.
//  Copyright © 2019 The Decred developers. All rights reserved.
//

import Foundation
import Dcrlibwallet

class WalletLoader: NSObject {
    static let appDataDir = NSHomeDirectory() + "/Documents/dcrlibwallet"
    
    var wallet: DcrlibwalletLibWallet?
    var syncer: Syncer
    var notification: TransactionNotification
    
    override init() {
        syncer = Syncer()
        notification = TransactionNotification()
        super.init()
    }
    
    func initWallet() -> NSError? {
        var initWalletError: NSError?
        self.wallet = DcrlibwalletNewLibWallet(WalletLoader.appDataDir, "bdb", BuildConfig.NetType, &initWalletError)
        
        return initWalletError
    }
    
    var isSynced: Bool {
        return self.syncer.currentSyncOp == SyncOp.Done
    }
    
    var isWalletCreated: Bool {
        var walletExists: ObjCBool = ObjCBool(false)
        
        do {
            try self.wallet?.walletExists(&walletExists)
        } catch (let error) {
            print("Error checking if wallet exists: \(error.localizedDescription)")
        }
        
        return walletExists.boolValue
    }
}

extension DcrlibwalletLibWallet {
    func totalWalletBalance() throws -> Double {
        var getAccountsError: NSError?
        let accountsJson = AppDelegate.walletLoader.wallet?.getAccounts(0, error: &getAccountsError)
        if getAccountsError != nil {
            throw getAccountsError!
        }
        
        let accounts = try JSONDecoder().decode(WalletAccounts.self, from: accountsJson!.utf8Bits)
        return accounts.Acc.filter({ !$0.isHidden }).map({ $0.dcrTotalBalance }).reduce(0,+)
    }
}
