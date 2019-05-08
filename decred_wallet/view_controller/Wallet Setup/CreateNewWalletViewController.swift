//
//  CreateNewWalletViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class CreateNewWalletViewController: UIViewController {
    
    @IBOutlet var vWarningLabel: UILabel!
    @IBOutlet private var seedWordLabels: [UILabel]!
    @IBOutlet private var outerStackView: UIStackView!
    @IBOutlet var seedContainer: UIView!
    
    var seed: String! = ""
    var arrWords = Array<String>()
    var yPosition: CGFloat?
    var xPostiion: CGFloat?
    var totalWidth: CGFloat?
    var widthOffset: CGFloat?
    var heightOffset: CGFloat?
    var calcultaedHeight: CGFloat?
    let font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var generateSeedError: NSError?
        self.seed =  (SingleInstance.shared.wallet?.generateSeed(&generateSeedError))
        if generateSeedError != nil {
            print("seed generate error: \(String(describing: generateSeedError?.localizedDescription))")
        }
        
        arrWords = (seed.components(separatedBy: " "))
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) { [weak self] in
            guard let this = self else { return }
            this.drawSeed()
        }
        
        backButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func unwind(_: UIStoryboardSegue){}
    // MARK: - Utility
    
    func setUpUItraits() {
        totalWidth = seedContainer.frame.size.width
        yPosition = 20.0
        xPostiion = 20.0
        widthOffset = 0.0
        heightOffset = 0.0
        calcultaedHeight = 21.0
    }
    
    // Draw seed
    func drawSeed() {
        for view in seedContainer.subviews {
            view.removeFromSuperview()
        }       
        setUpUItraits()        
        seedContainer.addSubview(outerStackView)
        
        for count in 0 ..< arrWords.count {
            seedWordLabels[count].text = "\(count + 1). \(arrWords[count])"
        }
        
        outerStackView.frame = seedContainer.frame
        let windowSize = AppDelegate.shared.window?.frame.size ?? CGSize.zero
        outerStackView.frame.size.width = 0.9 * min(windowSize.width, windowSize.height)
        outerStackView.center = seedContainer.center
        outerStackView.center.x = self.view.center.x
        seedContainer.setNeedsLayout()
    }
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let confirmSeedVC = segue.destination as! ConfirmNewWalletSeedViewController
        confirmSeedVC.seedToVerify = self.seed
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
