//
//  keyPadButton.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class KeyPadButton: UIButton {
    
    @IBInspectable
    open var keyPadButton: String = "1"
    
    @IBInspectable
    open var borderColor: UIColor = UIColor.white {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable
    open var borderRadius: CGFloat = 30 {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable
    open var highlightBackgroundColor: UIColor = UIColor.clear {
        didSet {
            setupView()
        }
    }
    
    public override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        setupView()
        setupActions()
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        setupActions()
    }
    
    open override var intrinsicContentSize : CGSize {
        
        return CGSize(width: 60, height: 60)
    }
    
    fileprivate var defaultBackgroundColor = UIColor.clear
    
    fileprivate func setupView() {
        
        layer.borderWidth = 0.5
        layer.cornerRadius = borderRadius
        layer.borderColor = borderColor.cgColor
        
        if let backgroundColor = backgroundColor {
            
            defaultBackgroundColor = backgroundColor
        }
    }
    
    fileprivate func setupActions() {
        
        addTarget(self, action: #selector(KeyPadButton.handleTouchDown), for: .touchDown)
        addTarget(self, action: #selector(KeyPadButton.handleTouchUp), for: [.touchUpInside, .touchDragOutside, .touchCancel])
    }
    
    @objc func handleTouchDown() {
        
        animateBackgroundColor(highlightBackgroundColor)
    }
    
    @objc func handleTouchUp() {
        
        animateBackgroundColor(defaultBackgroundColor)
    }
    
    fileprivate func animateBackgroundColor(_ color: UIColor) {
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0.0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0.0,
            options: [.allowUserInteraction, .beginFromCurrentState],
            animations: {
                
                self.backgroundColor = color
        },
            completion: nil
        )
    }
}
