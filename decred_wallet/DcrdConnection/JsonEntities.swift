//
//  JsonEntities.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation

struct BalanceEntity: Decodable {
    var Total: Double = 0
    var Spendable: Double = 0
    var ImmatureReward: Double = 0
    var ImmatureStakeGeneration: Double = 0
    var LockedByTickets: Double = 0
    var VotingAuthority: Double = 0
    var UnConfirmed: Double = 0
}

extension BalanceEntity {
    var dcrTotal: Double {
        return self.Total / 100000000
    }
    
    var dcrSpendable: Double {
        return self.Spendable / 100000000
    }
    
    var dcrImmatureReward: Double {
        return self.ImmatureReward / 100000000
    }
    
    var dcrImmatureStakeGeneration: Double {
        return self.ImmatureStakeGeneration / 100000000
    }
    
    var dcrLockedByTickets: Double {
        return self.LockedByTickets / 100000000
    }
    
    var dcrVotingAuthority: Double {
        return self.VotingAuthority / 100000000
    }
    
    var dcrUnConfirmed: Double {
        return self.UnConfirmed / 100000000
    }
}

struct AccountsEntity: Decodable {
    var Number: Int32 = 0
    var Name = "default"
    var Balance: BalanceEntity?
    var TotalBalance: Double = 0.0
    var ExternalKeyCount = 20
    var InternalKeyCount = 20
    var ImportedKeyCount = 0
    
    func makeDefault() {
        UserDefaults.standard.set(self.Number, forKey: "wallet_default")
    }
    
    var isDefaultWallet: Bool {
        let `default` = UserDefaults.standard.integer(forKey: "wallet_default")
        
        return `default` == self.Number ? true : false
    }
}

extension AccountsEntity {
    var dcrTotalBalance: Double {
        return self.TotalBalance / 100000000
    }
}

struct GetAccountResponse: Decodable {
    var Count = 0
    var ErrorMessage = ""
    var ErrorCode = 0
    var ErrorOccurred = false
    var Acc: [AccountsEntity] = []
    var CurrentBlockHash = ""
    var CurrentBlockHeight = 0
}

struct GroceryProduct: Codable {
    var name: String
    var points: Int
    var description: String
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try values.decode(String.self, forKey: .name)
        self.points = try values.decodeIfPresent(Int.self, forKey: .points) ?? 0
        self.description = try values.decodeIfPresent(String.self, forKey: .description) ?? ""
    }
}

struct GetTransactionResponse: Codable {
    var Transactions: [Transaction]
    var ErrorOccurred: Bool
    var ErrorMessage: String
    init(from decoder: Decoder) throws {
        do {
            print("in decoding now ")
            let values = try decoder.container(keyedBy: CodingKeys.self)
            self.Transactions = try values.decodeIfPresent([Transaction].self, forKey: .Transactions) ?? [Transaction(from: decoder)]
            self.ErrorOccurred = try values.decodeIfPresent(Bool.self, forKey: .ErrorOccurred) ?? true
            self.ErrorMessage = (try values.decodeIfPresent(String.self, forKey: .ErrorMessage)) ?? ""
            print("done my work decoding")
        }
        catch {
            print(Error.self)
            print("error decoding")
            self.Transactions = [try Transaction(from: decoder)]
            self.ErrorOccurred = false
            self.ErrorMessage = ""
        }
    }
}

struct Transaction: Codable {
    var Hash: String
    var Transaction: String?
    var Fee: Double
    var Direction: Int
    var Timestamp: UInt64
    var `Type`: String
    var Amount: Double
    var Status: String
    var Height: Int
    var Debits: [Debit]
    var Credits: [Credit]
    @nonobjc var Animate: Bool
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.Hash = try values.decodeIfPresent(String.self, forKey: .Hash) ?? ""
        self.Transaction = try values.decodeIfPresent(String.self, forKey: .Transaction) ?? ""
        self.Fee = try values.decodeIfPresent(Double.self, forKey: .Fee) ?? 0.0
        self.Direction = try values.decodeIfPresent(Int.self, forKey: .Direction) ?? 0
        self.Timestamp = try values.decodeIfPresent(UInt64.self, forKey: .Timestamp) ?? 0
        self.Type = try values.decodeIfPresent(String.self, forKey: .Type) ?? "REGULAR"
        self.Amount = (try values.decodeIfPresent(Double.self, forKey: .Amount) ?? 0.0)
        self.Status = try values.decodeIfPresent(String.self, forKey: .Status) ?? ""
        self.Height = try values.decodeIfPresent(Int.self, forKey: .Height) ?? 0
        self.Debits = try values.decodeIfPresent([Debit].self, forKey: .Debits) ?? [Debit]()
        self.Credits = try values.decodeIfPresent([Credit].self, forKey: .Credits) ?? [Credit]()
        self.Animate = false
    }
}

struct Credit: Codable {
    var Index: Int64
    var Account: Int64
    var Internal: Bool
    var Amount: Double
    var Address: String
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.Index = (try values.decodeIfPresent(Int64.self, forKey: .Index) ?? 0)
        self.Account = try values.decodeIfPresent(Int64.self, forKey: .Account) ?? 0
        self.Internal = try values.decodeIfPresent(Bool.self, forKey: .Internal) ?? false
        self.Amount = try values.decodeIfPresent(Double.self, forKey: .Amount) ?? 0.0
        self.Address = try values.decodeIfPresent(String.self, forKey: .Address) ?? ""
    }
}

extension Credit {
    var dcrAmount: Double {
        return self.Amount / 100000000
    }
}

struct Debit: Codable {
    var Index: Int64 = 0
    var PreviousAccount: Double = 0.0
    var PreviousAmount: Double = 0.0
    var AccountName = ""
    
    // var Address = ""
}

extension Debit {
    var dcrAmount: Double {
        return self.PreviousAmount / 100000000
    }
}

extension GetTransactionResponse {
    var transactionsTimeline: [Transaction] {
        let timeline = Transactions.sorted { (transaction1, transaction2) -> Bool in
            transaction1.Timestamp > transaction2.Timestamp
        }
        return timeline
    }
    
    func transaction(by hash: String) -> Transaction? {
        return self.Transactions.filter({ $0.Hash == hash }).first
    }
}

//extension UserDefaults {
//    var defaultAccountNumber: Int32 {
//        get {
//            return Int32(self.integer(forKey: "wallet_default"))
//        }
//
//        set {
//            self.set(newValue, forKey: "wallet_default")
//            self.synchronize()
//        }
//    }
//
//    func deleteDefaultAccountNumber() {
//        self.defaultAccountNumber = -1
//    }
//}

