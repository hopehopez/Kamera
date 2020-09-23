//
//  ZCameraModeView.swift
//  Kamera
//
//  Created by zsq on 2020/9/17.
//  Copyright © 2020 zsq. All rights reserved.
//

import UIKit

enum ZCameraMode: Int{
    case photo = 0
    case video
}

class ZCameraModeView: UIControl {

    var cameraMode = ZCameraMode.video {
        didSet{
            if cameraMode == .photo {
                captureButton.isSelected = false
                captureButton.captureButtonMode = .photo
                layer.backgroundColor = UIColor.black.cgColor
            } else {
                captureButton.captureButtonMode = .video
                layer.backgroundColor = UIColor(white: 0.0, alpha: 0.5).cgColor
            }
            sendActions(for: .valueChanged)
        }
    }
    
    @IBOutlet var captureButton: ZCaptureButton!
    
    private var foregroundColor: UIColor!
    private var videoTextLayer: CATextLayer!
    private var photoTextLayer: CATextLayer!
    private var labelContainerView: UIView!
    private var maxLeft = false
    private var maxRight = true
    private var videoStringWidth: CGFloat!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    func setupView() {
        maxRight = true
        cameraMode = .video
        
        backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        foregroundColor = UIColor(red: 1.0, green: 0.734, blue: 0.006, alpha: 1.0)
        
        videoTextLayer = textLayerWithTitle(title: "VIDEO")
        videoTextLayer.foregroundColor = foregroundColor.cgColor
        photoTextLayer = textLayerWithTitle(title: "PHOTO")
        
        let size = ("VIDEO" as NSString).size(withAttributes: [NSAttributedString.Key.font: UIFont(name: "AvenirNextCondensed-DemiBold", size: 17.0)!, NSAttributedString.Key.foregroundColor: UIColor.white])
        videoStringWidth = size.width
        
        videoTextLayer.frame = CGRect(x: 0, y: 0, width: 40, height: 20)
        photoTextLayer.frame = CGRect(x: 60, y: 0, width: 50, height: 20)
        let containerRect = CGRect(x: 0, y: 8, width: 120, height: 30)
        labelContainerView = UIView(frame: containerRect)
        labelContainerView.backgroundColor = UIColor.clear
        labelContainerView.layer.addSublayer(videoTextLayer)
        labelContainerView.layer.addSublayer(photoTextLayer)
        addSubview(labelContainerView)
        
        let rightRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(switchMode(recognizer:)))
        let leftRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(switchMode(recognizer:)))
        leftRecognizer.direction = .left
        addGestureRecognizer(leftRecognizer)
        addGestureRecognizer(rightRecognizer)
        
    }
    
    func toggleSelected() {
        captureButton.isSelected = !captureButton.isSelected
    }
    
    @objc func switchMode(recognizer: UISwipeGestureRecognizer) {
        if recognizer.direction == .left && !maxLeft{
            UIView.animate(withDuration: 0.28, delay: 0.0, options: .curveEaseInOut, animations: {
                var newFrame = self.labelContainerView.frame
                newFrame.origin.x -= 62
                self.labelContainerView.frame = newFrame
                
                UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveLinear, animations: {
                    CATransaction.disableActions()
                    self.photoTextLayer.foregroundColor = self.foregroundColor.cgColor
                    self.videoTextLayer.foregroundColor = UIColor.white.cgColor
                }) { (_) in
                    
                }

            }) { (_) in
                self.cameraMode = .photo
                self.maxLeft = true
                self.maxRight = false
            }


        } else if recognizer.direction == .right && !maxRight{
            
            UIView.animate(withDuration: 0.28, delay: 0.0, options: .curveEaseInOut, animations: {
                var newFrame = self.labelContainerView.frame
                newFrame.origin.x += 62
                self.labelContainerView.frame = newFrame
                
                UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveLinear, animations: {
                    CATransaction.disableActions()
                    self.videoTextLayer.foregroundColor = self.foregroundColor.cgColor
                    self.photoTextLayer.foregroundColor = UIColor.white.cgColor
                }) { (_) in
                    
                }

            }) { (_) in
                self.cameraMode = .video
                self.maxLeft = false
                self.maxRight = true
            }
        }
    }
    
    func textLayerWithTitle(title: String) -> CATextLayer {
        let layer = CATextLayer()
        layer.string = NSAttributedString(string: title, attributes: [NSAttributedString.Key.font: UIFont(name: "AvenirNextCondensed-DemiBold", size: 17.0)!, NSAttributedString.Key.foregroundColor: UIColor.white])
        layer.contentsScale = UIScreen.main.scale
        return layer
    }
    
   
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(foregroundColor.cgColor)
        
        let circleRect = CGRect(x: rect.midX-4, y: 2, width: 6, height: 6)
        context?.fillEllipse(in: circleRect)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var newFrame = labelContainerView.frame
        newFrame.origin.x = bounds.midX - videoStringWidth/2.0
        labelContainerView.frame = newFrame
    }
}
