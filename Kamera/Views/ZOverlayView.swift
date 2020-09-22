//
//  ZOverlayView.swift
//  Kamera
//
//  Created by zsq on 2020/9/17.
//  Copyright © 2020 zsq. All rights reserved.
//

import UIKit

class ZOverlayView: UIView {

    @IBOutlet var modeView: ZCameraModeView!
    @IBOutlet var statusView: ZStatusView!
    
    var flashControlHidden = false{
        didSet{
            statusView.flashControl.isHidden = flashControlHidden
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.clear
        modeView.addTarget(self, action: #selector(modeChanged(modelView:)), for: .valueChanged)
        
    }
    
    @objc func modeChanged(modelView: ZCameraModeView) {
        let photoModeEnabled  = modeView.cameraMode == .photo
        let toColor = photoModeEnabled ? UIColor.black : UIColor(white: 0.0, alpha: 0.5)
        let toOpacity: CGFloat = photoModeEnabled ? 0.0 : 1.0
        statusView.layer.backgroundColor = toColor.cgColor
        statusView.elapsedTimeLabel.alpha = toOpacity
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if statusView.point(inside: convert(point, to: statusView), with: event) ||
            modeView.point(inside: convert(point, to: modeView), with: event){
            return true
        }
        return false
    }
    
    
}
