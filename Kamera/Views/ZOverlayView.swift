//
//  ZOverlayView.swift
//  Kamera
//
//  Created by zsq on 2020/9/17.
//  Copyright © 2020 zsq. All rights reserved.
//

import UIKit

@IBDesignable
class ZOverlayView: UIView {

    @IBInspectable var modeView: ZCameraModeView!
    @IBInspectable var statusView: ZStatusView!
    
    var flashControlHidden = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.clear
        
        
    }
}
