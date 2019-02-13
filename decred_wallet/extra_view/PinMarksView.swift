//
//  PinMarksView.swift
//  
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class PinMarksView: UIStackView {
    var total = 5
    var entered: Int
    let space:CGFloat = 10.0
    var numberw = UILabel()
    override init(frame: CGRect) {
        total = 5
        entered = 0
        
        super.init(frame: frame)
    }
    
    required init(coder: NSCoder) {
        total = 5
        entered = 0
        
        super.init(coder: coder)
    }
    
    override func draw(_ rect: CGRect) {
        super.alignment = .center
        update()
    }
    
    func removeBtn(){
        self.removeArrangedSubview(numberw)
    }
    
    func update() {
        self.alignment = .center
        drawCells(in: frame)
    }
    
    func drawCells(in rect:CGRect){
        let h = rect.size.height
        var w = rect.size.width / CGFloat(total) - space
        
        if self.arrangedSubviews.count > 0{
            self.removeArrangedSubview(numberw)
        }
        
        self.layer.sublayers?.removeAll()
        numberw.text = ""
        
        if entered == 0 {
            return
        } else if (entered > 0 && entered < 6) {
            for i in 0...(min((entered - 1),4)) {
                let cellRect = CGRect(x: CGFloat(i) * w + space * CGFloat(i), y:0, width: w, height: h)
                drawActiveCell(rect: cellRect)
                w = rect.size.width / CGFloat(total) - space
            }
        } else {
            numberw = UILabel()
            numberw.text = String(entered)
            self.alignment = .center
            numberw.textAlignment = .center
            numberw.textColor = #colorLiteral(red: 0.2537069321, green: 0.8615272641, blue: 0.7028611302, alpha: 1)
            numberw.font = numberw.font.withSize(25)
            self.addArrangedSubview(numberw)
        }
    }
    
    func drawActiveCell(rect: CGRect){
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: rect.origin.x + rect.size.width / 2, y: rect.size.height / 2), radius: rect.size.width / 2 * 0.7, startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        shapeLayer.fillColor = #colorLiteral(red: 0.2537069321, green: 0.8615272641, blue: 0.7028611302, alpha: 1).cgColor
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 2
        self.alignment = .center
        self.layer.addSublayer(shapeLayer)
    }
}
