//
//  ContouredButton.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

@IBDesignable class ContouredButton: UIButton {
    
    @IBInspectable var borderColor: UIColor?
    @IBInspectable var borderThick: CGFloat = 2
    @IBInspectable var cornerRadius: CGFloat = 5.0
    @IBInspectable var selectedStateColor: UIColor = #colorLiteral(red: 0.3111695647, green: 0.728333056, blue: 0.215497613, alpha: 1)
    @IBInspectable var backgroundFillColor: UIColor = #colorLiteral(red: 0.9623823762, green: 0.9688158631, blue: 0.9719761014, alpha: 1)
    @IBInspectable var disabledStrokeColor: UIColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    
    override func draw(_ rect: CGRect) {
        
        let stateDependentStrokeColor = isEnabled ? borderColor : disabledStrokeColor
        let selectionDependentStrokeColor = isSelected ? selectedStateColor : stateDependentStrokeColor
        
        let context = UIGraphicsGetCurrentContext()
        context!.setStrokeColor((selectionDependentStrokeColor ?? UIColor.black).cgColor)
        let lineThick = isSelected ? borderThick + 1 : borderThick
        let corner = isSelected ? cornerRadius + 1 : cornerRadius
        context!.setLineWidth(lineThick)
        context!.setFillColor(isSelected ? selectionDependentStrokeColor!.cgColor : backgroundFillColor.cgColor)
        let path = UIBezierPath(roundedRect: rect.insetBy(dx: lineThick / 2, dy: lineThick / 2), cornerRadius: corner)
        context?.addPath(path.cgPath)
        context!.drawPath(using: CGPathDrawingMode.fillStroke)
    }
}
