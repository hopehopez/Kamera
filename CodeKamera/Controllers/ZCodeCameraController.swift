//
//  ZCodeCameraController.swift
//  CodeKamera
//
//  Created by zsq on 2020/9/24.
//  Copyright © 2020 zsq. All rights reserved.
//

import AVFoundation

class ZCodeCameraContrller: ZBaseCameraController, AVCaptureMetadataOutputObjectsDelegate {
    weak var codeDetectionDelegate: ZCodeDetectionDelegate?
    private var metadataOutput: AVCaptureMetadataOutput = AVCaptureMetadataOutput()
    
    override var sessionPreset: AVCaptureSession.Preset {
        //重写sessionPreset方法，可以选择最适合应用程序捕捉预设类型。
        //苹果公司建议开发者使用最低合理解决方案以提高性能
        return .vga640x480
    }
    
    override func setupSessionInputs() -> Bool {
        guard super.setupSessionInputs() else { return false}
        
        //设置相机自动对焦，这样可以在任何距离都可以进行扫描。
        //判断是否能自动聚焦
        guard activeCamera().isAutoFocusRangeRestrictionSupported else {
            return false
        }
        
        do{
            try activeCamera().lockForConfiguration()
            //自动聚焦
            activeCamera().autoFocusRangeRestriction = .near
            //释放该锁定
            activeCamera().unlockForConfiguration()
        }catch{
            self.delegate?.deviceConfigurationFailedWithError(error: error)
        }
        
        return true
    }
    
    override func setupSessionOutputs() -> Bool {
        guard super.setupSessionOutputs() else {
            return false
        }
        
        guard captureSession.canAddOutput(metadataOutput) else {
            return false
        }
        
        captureSession.addOutput(metadataOutput)
        
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        //指定扫描对是OR码 & Aztec 码 (移动营销)
        let metadatObjectTypes: [AVMetadataObject.ObjectType] = [.qr, .aztec, .dataMatrix, .pdf417]
        metadataOutput.metadataObjectTypes = metadatObjectTypes
        
        return true
        
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count>0 {
            print(metadataObjects.first!)
        }
        codeDetectionDelegate?.didDetectFaces(faces: metadataObjects)
    }
}
