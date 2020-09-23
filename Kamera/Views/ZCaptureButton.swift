//
//  ZCaptureButton.swift
//  Kamera
//
//  Created by zsq on 2020/9/17.
//  Copyright © 2020 zsq. All rights reserved.
//

import UIKit

enum ZCaptureButtonMode : Int{
    case photo = 0
    case video = 1
}

class ZCaptureButton: UIButton {

    var captureButtonMode: ZCaptureButtonMode = .photo {
        didSet{
            let circleColor = captureButtonMode == .video ? UIColor.red : UIColor.white
            circleLayer.backgroundColor = circleColor.cgColor
        }
    }
    
    override var isHighlighted: Bool {
        didSet{
            let fadeAnimation = CABasicAnimation(keyPath: "opacity")
            fadeAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            fadeAnimation.duration = 0.2
            if isHighlighted {
                fadeAnimation.toValue = 0
            } else {
                fadeAnimation.toValue = 1.0
            }
            circleLayer.opacity = fadeAnimation.toValue as? Float ?? 0.0
            circleLayer.add(fadeAnimation, forKey: "fadeAnimation")
        }
    }
    
    override var isSelected: Bool {
        didSet{
            if captureButtonMode == .video {
                CATransaction.disableActions()
                
                let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
                let radiusAnimation = CABasicAnimation(keyPath: "cornerRadius")
                
                if isSelected {
                    scaleAnimation.toValue = 0.6
                    radiusAnimation.toValue = circleLayer.bounds.width/4
                } else {
                    scaleAnimation.toValue  = 1.0
                    radiusAnimation.toValue = circleLayer.bounds.width/2
                }
                
                let animationGroup = CAAnimationGroup()
                animationGroup.animations = [scaleAnimation, radiusAnimation]
                animationGroup.beginTime = CACurrentMediaTime() + 0.2
                animationGroup.duration = 0.35
                
                circleLayer.setValue(scaleAnimation.toValue, forKeyPath: "transform.scale")
                circleLayer.setValue(radiusAnimation.toValue, forKeyPath: "cornerRadius")
                
                circleLayer.add(animationGroup, forKey: "scaleAndRadiusAnimation")
                
            }
        }
    }
    
    private var circleLayer: CALayer!
    
    let LINE_WIDTH: CGFloat = 6.0
    let DEFAULT_FRAME = CGRect(x: 0, y: 0, width: 68, height: 68)
    
//    convenience init(with mode: ZCaptureButtonMode) {
//        self.init()
//
//        setupView()
//    }
    
     
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func setupView(){
    
        backgroundColor = UIColor.clear
        tintColor = UIColor.clear
        
        let circleColor = captureButtonMode == .video ? UIColor.red : UIColor.white
        circleLayer = CALayer()
        circleLayer.backgroundColor = circleColor.cgColor
        //insetBy origin偏移(dx,dy) 大小缩小2*dx 2*dy
        circleLayer.frame = bounds.insetBy(dx: 8.0, dy: 8.0)
        circleLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        circleLayer.cornerRadius = circleLayer.frame.width/2
        
        layer.addSublayer(circleLayer)
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(UIColor.white.cgColor)
        context?.setFillColor(UIColor.white.cgColor)
        context?.setLineWidth(LINE_WIDTH)
        let insetRect = rect.insetBy(dx: LINE_WIDTH/2, dy: LINE_WIDTH/2)
        context?.strokeEllipse(in: insetRect)
    }
    
}
