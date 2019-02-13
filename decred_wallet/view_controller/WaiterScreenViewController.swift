//
//  WaiterScreenViewController.swift
//  Decred Wallet

// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

protocol WaiterScreenProtocol {
    func set(label:String)
    func set(duration:Double)
    func stopAnimation()
    var onFinish:(()->Void)?{get set}
    var onTapAnimation:(()->Void)?{get set}
}


class WaiterScreenViewController: UIViewController, WaiterScreenProtocol {
    
    var onTapAnimation: (() -> Void)?
    var onFinish:(()->Void)?
    
    var timer: Timer?
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var girload: UIWebView!
    
    var  groupAnimation: CAAnimationGroup?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        girload.backgroundColor = UIColor(hex: "#F3F5F6")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let url = Bundle.main.url(forResource: "splashLoader", withExtension: "gif")!
        let data = try! Data(contentsOf: url)
        girload.load(data, mimeType: "image/gif", textEncodingName: "UTF-8", baseURL: NSURL() as URL)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        set(duration: 5)
    }
    
    func set(label: String) {
        self.label.text = label
    }
    
    func set(duration: Double) {
        timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false, block: {_ in
            self.stopAnimation()
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goToSeetings(_ sender: Any) {
        timer?.invalidate()
        onTapAnimation?()
    }
    
    func stopAnimation() {
        onFinish?()
    }
}
