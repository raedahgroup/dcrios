//
//  Utils.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import JGProgressHUD

extension Notification.Name {
    static let NeedAuth =   Notification.Name("NeedAuthorize")
    static let NeedLogout = Notification.Name("NeedDeauthorize")
}

func isWalletCreated() -> Bool{
    let fm = FileManager()
    let result = fm.fileExists(atPath: NSHomeDirectory()+"/Documents/dcrwallet/testnet3/wallet.db")
    return result
}

func showMsg(error:String,controller: UIViewController){
    let alert = UIAlertController(title: "PIN mismatch", message: error, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "Try again", style: UIAlertActionStyle.default, handler: nil)
    alert.addAction(okAction)
    DispatchQueue.main.async {
        controller.present(alert, animated: true, completion: nil)
    }
}

func createMainWindow(){
    // create viewController code...
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let mainViewController = storyboard.instantiateViewController(withIdentifier: "OverviewViewController") as! OverviewViewController
    let leftViewController = storyboard.instantiateViewController(withIdentifier: "LeftViewController") as! LeftViewController
    
    let nvc: UINavigationController = UINavigationController(rootViewController: mainViewController)
    
    UINavigationBar.appearance().tintColor = GlobalConstants.Colors.navigationBarColor
    
    leftViewController.mainViewController = nvc
    
    let slideMenuController = ExSlideMenuController(mainViewController:nvc, leftMenuViewController: leftViewController)
    slideMenuController.changeLeftViewWidth((UIApplication.shared.keyWindow?.frame.size.width)! - (UIApplication.shared.keyWindow?.frame.size.width)! / 6)
    
    slideMenuController.delegate = mainViewController
    UIApplication.shared.keyWindow?.backgroundColor = GlobalConstants.Colors.lightGrey
    UIApplication.shared.keyWindow?.rootViewController = slideMenuController
    UIApplication.shared.keyWindow?.makeKeyAndVisible()
}

func showProgressHud(with title:String?) -> JGProgressHUD{
    let hud = JGProgressHUD(style: .light)
    hud.shadow = JGProgressHUDShadow(color: .black, offset: .zero, radius: 5.0, opacity: 0.2)
    hud.textLabel.text = title ?? ""
    hud.show(in: (UIApplication.shared.keyWindow?.rootViewController?.view)!)
    return hud
}

func saveCertificate(secretKey: String) {
    do {
        let filePath = NSHomeDirectory() + "/Documents/rpc.cert"
        let filePathURL = URL.init(fileURLWithPath: filePath)
        try secretKey.write(to: filePathURL, atomically: true, encoding: String.Encoding.utf8)
    } catch {
        debugPrint("Could not create certificate file")
    }
}

func getPeerAddress(appInstance:UserDefaults) -> String{
    let ip = appInstance.string(forKey: "pref_peer_ip")
    if(ip?.elementsEqual(""))!{
        return ""
    }
    else{
        return (ip?.appending(":19108"))!
    }
}

func generateQRCodeFor(with addres: String, forImageViewFrame: CGRect) -> UIImage? {
    guard let addrData = addres.data(using: String.Encoding.utf8) else {
        return nil
    }
    
    // Color code and background
    guard let colorFilter = CIFilter(name: "CIFalseColor") else { return nil }
    
    let filter = CIFilter(name: "CIQRCodeGenerator")
    
    filter?.setValue(addrData, forKey: "inputMessage")
    
    /// Foreground color of the output
    let color = CIColor(red: 26/255, green: 29/255, blue: 47/255)
    
    /// Background color of the output
    let backgroundColor = CIColor.clear
    
    colorFilter.setDefaults()
    colorFilter.setValue(filter!.outputImage, forKey: "inputImage")
    colorFilter.setValue(color, forKey: "inputColor0")
    colorFilter.setValue(backgroundColor, forKey: "inputColor1")
    
    if let imgQR = colorFilter.outputImage {
        var tempFrame: CGRect? = forImageViewFrame
        
        if tempFrame == nil {
            tempFrame = CGRect(x: 0, y: 0, width: 100, height: 100)
        }
        
        guard let frame = tempFrame else { return nil }
        
        let smallerSide = frame.size.width < frame.size.height ? frame.size.width : frame.size.height
        
        let scale = smallerSide/imgQR.extent.size.width
        let transformedImage = imgQR.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        
        let imageQRCode = UIImage(ciImage: transformedImage)
        
        return imageQRCode
    }
    
    return nil
}

func spendable(account:AccountsEntity) -> Decimal{
    let bRequireConfirm = UserDefaults.standard.bool(forKey: "pref_spend_fund_switch")
    let iRequireConfirm = (bRequireConfirm ) ? Int32(0) : Int32(2)
    let int64Pointer = UnsafeMutablePointer<Int64>.allocate(capacity: 64)    
    do {
        
        try  SingleInstance.shared.wallet?.spendable(forAccount: account.Number, requiredConfirmations: iRequireConfirm, ret0_: int64Pointer)
    } catch let error{
        print(error)
        return 0.0
    }
    print("spendable =")
    print(Decimal(int64Pointer.move()))
    return Decimal(int64Pointer.move()) / 100000000.0
}

func loadCertificate() throws ->  String {
    let filePath = NSHomeDirectory() + "/Documents/rpc.cert"
    return try String.init(contentsOfFile: filePath)
}

func getAttributedString(str: String, siz: CGFloat) -> NSAttributedString {
    var tmpString = str
    var Strr:NSString = ""
    if !tmpString.contains("."){
        Strr =  (str.appending(".00") as NSString)
        tmpString = str.appending(".00")
    }
    let tmp2 = tmpString as NSString
    let TmpDot = tmp2.range(of: ".")
    if((tmpString.length - (TmpDot.location + 1)) == 1){
        tmpString = str.appending("0")
        
    }
    
    let stt = tmpString.appending(" DCR") as NSString?
    let atrStr = NSMutableAttributedString(string: stt! as String)
    let dotRange = stt?.range(of: ".")
    if(tmpString.length > ((dotRange?.location)!+2)) {
        atrStr.addAttribute(NSAttributedStringKey.font,
                            value: UIFont(
                                name: "Helvetica",
                                size: siz)!,
                            range: NSRange(
                                location:(dotRange?.location)!+3,
                                length:(stt?.length)!-1 - ((dotRange?.location)!+2)))
        
        atrStr.addAttribute(NSAttributedStringKey.foregroundColor,
                            value: UIColor(hex: "#091440"),
                            range: NSRange(
                                location:0,
                                length:(stt?.length)!))
        
    }
    return atrStr
}

extension NSDecimalNumber {
    public func round(_ decimals:Int) -> NSDecimalNumber {
        return self.rounding(accordingToBehavior:
            NSDecimalNumberHandler(roundingMode: .plain,
                                   scale: Int16(decimals),
                                   raiseOnExactness: false,
                                   raiseOnOverflow: false,
                                   raiseOnUnderflow: false,
                                   raiseOnDivideByZero: false))
    }
}

extension UITableViewCell{
    func blink(){
        UITableViewCell.animate(withDuration: 0.5, //Time duration you want,
            delay: 0.0,
            options: [.showHideTransitionViews, .autoreverse, .repeat],
            animations: { [weak self] in self?.alpha = 0.0 },
            completion: { [weak self] _ in self?.alpha = 1.0 })
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            [weak self] in
            self?.layer.removeAllAnimations()
        }
    }
}

extension UIButton {
    func set(fontSize: CGFloat) {
        if let titleLabel = titleLabel {
            titleLabel.font = UIFont(name: titleLabel.font.fontName, size: fontSize)
        }
    }
}
