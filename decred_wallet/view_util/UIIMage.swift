//
//  UIIMage.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit

extension UIImage {
    
    func trim(trimRect :CGRect) -> UIImage {
        if CGRect(origin: CGPoint.zero, size: self.size).contains(trimRect) {
            if let imageRef = self.cgImage?.cropping(to: trimRect) {
                return UIImage(cgImage: imageRef)
            }
        }
        
        UIGraphicsBeginImageContextWithOptions(trimRect.size, true, self.scale)
        self.draw(in: CGRect(x: -trimRect.minX, y: -trimRect.minY, width: self.size.width, height: self.size.height))
        let trimmedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let image = trimmedImage else { return self }
        
        return image
    }
}
