//
//  PinWeakness.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import PasswordStrength

class PinWeakness {
    
    let passstrength = PinAnalyzer()
    
    func strength(forPin:String) -> Float{
        if forPin.length == 0 {return 0.0}
        let res = passstrength.analyze(pin: forPin)
        return res / 10.0
    }
    
    func strengthColor(forPin:String) -> UIColor{
        let pinStrength = strength(forPin: forPin)
        let colors = [#colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1), #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1), #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1), #colorLiteral(red: 0.6179546118, green: 0.9191936255, blue: 0.6673415303, alpha: 1), #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)]
        let colorIndex = Int(pinStrength * 10.0 / 2.0)
        
        return colors[min(colorIndex,4)]
    }
}

class PinAnalyzer {
    
    var checkRules : [((String) -> Float)]? = []
    init() {
        setupRules()
    }
    
    func analyze(pin:String) -> Float{
        let strength = checkRules?.reduce(1.0, { (sum, current) -> Float in
            return sum * current(pin)
        })
        return strength ?? 1.0
    }
    
    private func setupRules(){
        checkRules?.append({ (pin) -> Float in
            let digit1 = Float(String(pin.first!))
            return digit1 ?? 9.0 / 9.0
        })
        
        checkRules?.append({(pin)-> Float in
            return Float(pin.length) / 5.0
        })
    }
}
