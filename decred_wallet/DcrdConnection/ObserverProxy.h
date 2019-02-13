//
//  ObserverProxy.h
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.
//

#import <Foundation/Foundation.h>
#import <Dcrlibwallet/Dcrlibwallet.h>

/*@class TransactionResponse;
 @class Transaction;
 
 @protocol TransactionNotificationsObserverProtocol
 @property (nonatomic, strong) NSMutableArray<DcrlibwalletTransactionListener>* transactionNotificationsSubscribers;
 - (void) subscribeForUpdateNotifications:(id<DcrlibwalletTransactionListener>)observer;
 - (void) unsubscribeForUpdateNotifications:(id<DcrlibwalletTransactionListener>)observer;
 @end
 
 @protocol TransactionBlockNotificationObserverProtocol
 @property (nonatomic, strong) NSMutableArray<DcrlibwalletBlockNotificationError>* transactionBlockNotificationsSubscribers;
 - (void) subscribeForBlockNotifications:(id<DcrlibwalletBlockNotificationError>)observer;
 - (void) unsubscribeForBlockNotifications:(id<DcrlibwalletBlockNotificationError>)observer;
 @end
 
 @protocol GetTransactionObserverProtocol
 @property (nonatomic, strong) NSMutableArray<DcrlibwalletGetTransactionsResponse>* transactionNotificationsSubscribers;
 - (void) subscribeForNotifications:(id<DcrlibwalletGetTransactionsResponse>)observer;
 - (void) unsubscribeForNotifications:(id<DcrlibwalletGetTransactionsResponse>)observer;
 @end
 
 @interface GetTransactionObserveHub: NSObject <DcrlibwalletGetTransactionsResponse, GetTransactionObserverProtocol>
 @property (nonatomic, strong) NSMutableArray<DcrlibwalletGetTransactionsResponse>* transactionNotificationsSubscribers;
 - (void) subscribeForNotifications:(id<DcrlibwalletGetTransactionsResponse>)observer;
 - (void) unsubscribeForNotifications:(id<DcrlibwalletGetTransactionsResponse>)observer;
 @end
 
 @interface TransactionBlockNotificationObserveHub : NSObject <DcrlibwalletBlockNotificationError>
 @property (nonatomic, strong) NSMutableArray<DcrlibwalletBlockNotificationError>* transactionBlockNotificationsSubscribers;
 - (void) subscribeForBlockNotifications:(id<DcrlibwalletBlockNotificationError>)observer;
 - (void) unsubscribeForBlockNotifications:(id<DcrlibwalletBlockNotificationError>)observer;
 @end
 
 @interface TransactionNotificationsObserveHub : NSObject <DcrlibwalletTransactionListener, TransactionNotificationsObserverProtocol>
 @property (nonatomic, strong) NSMutableArray<DcrlibwalletTransactionListener>* transactionNotificationsSubscribers;
 - (void) subscribeForUpdateNotifications:(id<DcrlibwalletTransactionListener>)observer;
 - (void) unsubscribeForUpdateNotifications:(id<DcrlibwalletTransactionListener>)observer;
 @end
 
 @interface BlockScanObserverHub : NSObject <DcrlibwalletBlockScanResponse>
 @property (nonatomic, strong) NSMutableArray<DcrlibwalletBlockScanResponse>* blockScanNotificationsSubscribers;
 - (void) subscribeForBlockScanNotifications:(id<DcrlibwalletBlockScanResponse>)observer;
 - (void) unsubscribeForBlockScanNotifications:(id<DcrlibwalletBlockScanResponse>)observer;
 @end*/
