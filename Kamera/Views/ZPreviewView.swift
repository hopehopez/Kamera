//
//  ZPreviewView.swift
//  Kamera
//
//  Created by zsq on 2020/9/17.
//  Copyright © 2020 zsq. All rights reserved.
//

import UIKit
import AVFoundation
protocol ZPreviewViewDelegate: NSObjectProtocol {
    func tappedToFocusAtPoint(point: CGPoint)
    func tappedToExposeAtPoint(point: CGPoint)
    func tappedToResetFocusAndExposure()
}

class ZPreviewView: UIView {

    ///session用来关联AVCaptureVideoPreviewLayer 和 激活AVCaptureSession
    var session: AVCaptureSession? {
        set {
            (self.layer as? AVCaptureVideoPreviewLayer)?.session = newValue
        }
        get {
            return (self.layer as? AVCaptureVideoPreviewLayer)?.session
        }
        
    }
    weak var delegate: ZPreviewViewDelegate?
    ///是否聚焦
    var tapToFocusEnabled = false {
        didSet{
            singleTapRecognizer.isEnabled = tapToFocusEnabled
        }
    }
    ///是否曝光
    var tapToExposeEnabled = false {
        didSet {
            doubleTapRecognizer.isEnabled = tapToExposeEnabled
        }
    }
    
    
    private var focusBox: UIView!
    private var exposureBox: UIView!
    private var timer: Timer!
    private var singleTapRecognizer: UITapGestureRecognizer!
    private var doubleTapRecognizer: UITapGestureRecognizer!
    private var doubleDoubleTapRecognizer: UITapGestureRecognizer!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override class var layerClass : AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    
    
    //关于UI的实现，例如手势，单击、双击 单击聚焦、双击曝光
    func setupView() {
        (self.layer as? AVCaptureVideoPreviewLayer)?.videoGravity = .resizeAspectFill
        
        singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(recognizer:)))
        doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(recognizer:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleDoubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleDoubleTap(recognizer:)))
        doubleDoubleTapRecognizer.numberOfTapsRequired = 2
        doubleDoubleTapRecognizer.numberOfTouchesRequired = 2
        
        addGestureRecognizer(singleTapRecognizer)
        addGestureRecognizer(doubleTapRecognizer)
        addGestureRecognizer(doubleDoubleTapRecognizer)
        
        focusBox = view(with: UIColor(red: 0.102, green: 0.636, blue: 1.000, alpha: 1.0))
        exposureBox = view(with: UIColor(red: 1.0, green: 0.421, blue: 0.054, alpha: 1.0))
        addSubview(focusBox)
        addSubview(exposureBox)
    }

    func view(with color: UIColor) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        view.backgroundColor = UIColor.clear
        view.layer.borderColor = color.cgColor
        view.layer.borderWidth = 5.0
        view.isHidden = true
        return view
    }
   
    @objc func handleSingleTap(recognizer:UITapGestureRecognizer) {
        let point = recognizer.location(in: self)
        runBoxAnimation(view: focusBox, point: point)
        delegate?.tappedToFocusAtPoint(point: point)
    }
    @objc func handleDoubleTap(recognizer:UITapGestureRecognizer) {
        let point = recognizer.location(in: self)
        runBoxAnimation(view: exposureBox, point: point)
        delegate?.tappedToExposeAtPoint(point: point)
    }
    @objc func handleDoubleDoubleTap(recognizer:UITapGestureRecognizer) {
        runResetAnimation()
        delegate?.tappedToResetFocusAndExposure()
    }
    
    func captureDevicePoint(for point: CGPoint) -> CGPoint {
        return (self.layer as? AVCaptureVideoPreviewLayer)?.captureDevicePointConverted(fromLayerPoint: point) ?? .zero
    }
    
    func runBoxAnimation(view: UIView, point: CGPoint) {
        view.center = point
        view.isHidden = false
        UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseInOut, animations: {
            view.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0)
        }) { (_) in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
                view.isHidden = true
                view.transform = .identity
            }
        }
    }
    
    func runResetAnimation() {
        guard tapToFocusEnabled && tapToExposeEnabled else {
            return
        }
        
        guard let previewLayer = layer as? AVCaptureVideoPreviewLayer else { return }
        
        let centerPoint = previewLayer.captureDevicePointConverted(fromLayerPoint: CGPoint(x: 0.5, y: 0.5))
        focusBox.center = centerPoint
        exposureBox.center = centerPoint
        exposureBox.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        focusBox.isHidden = false
        exposureBox.isHidden = false
        UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseInOut, animations: {
            self.focusBox.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0)
            self.exposureBox.layer.transform = CATransform3DMakeScale(0.7, 0.7, 1.0)
        }) { (_) in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
                self.focusBox.isHidden = true
                self.exposureBox.isHidden = true
                self.focusBox.transform = .identity
                self.exposureBox.transform = .identity
            }
        }
        
    }
}
