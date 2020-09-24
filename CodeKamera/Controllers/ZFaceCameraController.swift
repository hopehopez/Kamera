//
//  ZFaceCameraController.swift
//  FaceKamera
//
//  Created by zsq on 2020/9/24.
//  Copyright © 2020 zsq. All rights reserved.
//

import AVFoundation

class ZFaceCameraContrller: ZBaseCameraController, AVCaptureMetadataOutputObjectsDelegate {
    
    weak var faceDetectionDelegate: ZFaceDetectionDelegate?
    private var metadataOutput: AVCaptureMetadataOutput = AVCaptureMetadataOutput()
    
    override func setupSessionOutputs() -> Bool {
        //为捕捉会话添加设备
        guard captureSession.canAddOutput(metadataOutput) else {
            return false
        }
        captureSession.addOutput(metadataOutput)
        
        //获得人脸属性
        let metadatObjectTypes: [AVMetadataObject.ObjectType] = [AVMetadataObject.ObjectType.face]
        
        //设置metadataObjectTypes 指定对象输出的元数据类型。
        /*
         限制检查到元数据类型集合的做法是一种优化处理方法。可以减少我们实际感兴趣的对象数量
         支持多种元数据。这里只保留对人脸元数据感兴趣
         */
        metadataOutput.metadataObjectTypes = metadatObjectTypes
        
        //创建主队列： 因为人脸检测用到了硬件加速，而且许多重要的任务都在主线程中执行，所以需要为这次参数指定主队列。
        //通过设置AVCaptureVideoDataOutput的代理，就能获取捕获到一帧一帧数据
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        return true
    }
    
    
    //捕捉数据
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        
        //使用循环，打印人脸数据
        for meta in metadataObjects {
            guard let face = meta as? AVMetadataFaceObject else { return }
            
            print("Face detected with ID: \(face.faceID)")
            print("Face bounds: \(face.bounds)")
        }
        
        faceDetectionDelegate?.didDetectFaces(faces: metadataObjects as! [AVMetadataFaceObject])
    }
}
