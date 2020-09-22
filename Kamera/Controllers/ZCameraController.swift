//
//  ZCameraController.swift
//  Kamera
//
//  Created by zsq on 2020/9/21.
//  Copyright © 2020 zsq. All rights reserved.
//

import AVFoundation
import UIKit
import AssetsLibrary
protocol ZCameraControllerDelegate: NSObjectProtocol {
    func deviceConfigurationFailedWithError(error: Error)
    func mediaCaptureFailedWithError(error: Error)
    func assetLibraryWriteFailedWithError(error: Error)
}


class ZCameraController: NSObject {
    
    weak var delegate: ZCameraControllerDelegate?
    private(set) var captureSession: AVCaptureSession!
    var cameraCount:Int {
        get {
           return AVCaptureDevice.devices(for: .video).count
        }
    }
    ///手电筒
    private(set) var cameraHasTorch = false
    ///闪光灯
    private(set) var cameraHasFlash = false
    ///聚焦
    var cameraSupportsTapToFocus: Bool {
        //询问激活中的摄像头是否支持兴趣点对焦
        return activeCamera().isFocusPointOfInterestSupported
    }
    ///曝光
    var cameraSupportsTapToExpose: Bool {
        //询问激活中的摄像头是否支持兴趣点对焦
        return activeCamera().isExposurePointOfInterestSupported
    }
    ///手电筒模式
    var torchMode: AVCaptureDevice.TorchMode = .off
    ///闪光灯模式
    var flashMode: AVCaptureDevice.FlashMode = .off
    
    //视频队列
    private var videoQueue: DispatchQueue!
    weak var activeVideoInput: AVCaptureDeviceInput!
    var imageOutput: AVCaptureStillImageOutput!
    var movieOutput: AVCaptureMovieFileOutput!
    var outputURL: NSURL!
    
    var ZCameraAdjustingExposureContext: String!
    
    
    // 2 用于设置、配置视频捕捉会话
    func setupSession() -> Bool {
        //创建捕捉会话。AVCaptureSession 是捕捉场景的中心枢纽
        captureSession = AVCaptureSession()
        
        //设置图像的分辨率
        captureSession.sessionPreset = .high
        
        //拿到默认视频捕捉设备 iOS系统返回后置摄像头
        
        
        //将捕捉设备封装成AVCaptureDeviceInput
        //注意：为会话添加捕捉设备，必须将设备封装成AVCaptureDeviceInput对象
        //判断videoInput是否有效
        guard let videoDevice = AVCaptureDevice.default(for: .video), let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            return false
        }
        //canAddInput：测试是否能被添加到会话中
        if captureSession.canAddInput(videoInput) {
            //将videoInput 添加到 captureSession中
            captureSession.addInput(videoInput)
            activeVideoInput = videoInput
        }
        
        //选择默认音频捕捉设备 即返回一个内置麦克风
        guard let audioDevice = AVCaptureDevice.default(for: .audio), let audioInput = try? AVCaptureDeviceInput(device: audioDevice) else { return false }
        if captureSession.canAddInput(audioInput) {
            captureSession.addInput(audioInput)
        }
        
        //AVCaptureStillImageOutput 实例 从摄像头捕捉静态图片
        imageOutput = AVCaptureStillImageOutput()
        //配置字典：希望捕捉到JPEG格式的图片
        imageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        //输出连接 判断是否可用，可用则添加到输出连接中去
        if captureSession.canAddOutput(imageOutput) {
            captureSession.addOutput(imageOutput)
        }
        
        //创建一个AVCaptureMovieFileOutput 实例，用于将Quick Time 电影录制到文件系统
        movieOutput = AVCaptureMovieFileOutput()
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }
        
        videoQueue = DispatchQueue.init(label: "VideoQueue")
        
        return true
    }
    
    func startSession() {
        //检查是否处于运行状态
        if !captureSession.isRunning {
            //使用同步调用会损耗一定的时间，则用异步的方式处理
            videoQueue.async {
                self.captureSession.startRunning()
            }
            
        }
    }
    
    func stopSession() {
        if captureSession.isRunning {
            videoQueue.async {
                self.captureSession.stopRunning()
            }
        }
    }
    
    //MARK: - Device Configuration   配置摄像头支持的方法
        
    
    // 3 切换不同的摄像头
    func switchCameras() ->Bool {
        guard canSwitchCameras() else { return false}
        
        //获取当前设备的反向设备
        guard let videoDevice = inactiveCamera() else { return false }
        
        var videoInput: AVCaptureDeviceInput!
        do {
            //将输入设备封装成AVCaptureDeviceInput
            videoInput = try AVCaptureDeviceInput(device: videoDevice)
        } catch {
            //创建AVCaptureDeviceInput 出现错误，则通知委托来处理该错误
            delegate?.deviceConfigurationFailedWithError(error: error)
            return false
        }
        
        //标注原配置变化开始
        captureSession.beginConfiguration()
        
        //将捕捉会话中，原本的捕捉输入设备移除
        captureSession.removeInput(activeVideoInput)
        
        //判断新的设备是否能加入
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
            //将获得设备 改为 videoInput
            activeVideoInput = videoInput
        } else {
            //如果新设备，无法加入。则将原本的视频捕捉设备重新加入到捕捉会话中
            captureSession.addInput(activeVideoInput)
        }
        
        //配置完成后， AVCaptureSession commitConfiguration 会分批的将所有变更整合在一起。
        captureSession.commitConfiguration()
        
        return true
    }
    
    //判断是否有超过1个摄像头可用
    func canSwitchCameras() -> Bool {
        return cameraCount > 1
    }
    
    //返回当前未激活的摄像头
    func inactiveCamera() -> AVCaptureDevice? {
        //通过查找当前激活摄像头的反向摄像头获得，如果设备只有1个摄像头，则返回nil
        if cameraCount>0 {
            if activeCamera().position == .back {
                return camera(position: .front)
            } else {
                return camera(position: .back)
            }
        } else {
            return nil
        }
    }
    
    func activeCamera() -> AVCaptureDevice {
        return activeVideoInput.device
    }
    
    func camera(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        //获取可用视频设备
        let devices = AVCaptureDevice.devices(for: .video)
        //遍历可用的视频设备 并返回position 参数值
        for device in devices {
            if device.position == position {
                return device
            }
        }
        return nil
    }
    
    /*
        AVCapture Device 定义了很多方法，让开发者控制ios设备上的摄像头。可以独立调整和锁定摄像头的焦距、曝光、白平衡。对焦和曝光可以基于特定的兴趣点进行设置，使其在应用中实现点击对焦、点击曝光的功能。
        还可以让你控制设备的LED作为拍照的闪光灯或手电筒的使用
        
        每当修改摄像头设备时，一定要先测试修改动作是否能被设备支持。并不是所有的摄像头都支持所有功能，例如牵制摄像头就不支持对焦操作，因为它和目标距离一般在一臂之长的距离。但大部分后置摄像头是可以支持全尺寸对焦。尝试应用一个不被支持的动作，会导致异常崩溃。所以修改摄像头设备前，需要判断是否支持
     
     
     */
    
    // 4 聚焦、曝光、重设聚焦、曝光的方法
    //MARK: - Focus Methods 点击聚焦方法的实现
    func focus(point: CGPoint) {
        let device = activeCamera()
        
        //是否支持兴趣点对焦 & 是否自动对焦模式
        if device.isFocusPointOfInterestSupported &&
            device.isFocusModeSupported(.autoFocus){
            
            do {
                //锁定设备准备配置，如果获得了锁
                try device.lockForConfiguration()
                //将focusPointOfInterest属性设置CGPoint
                device.focusPointOfInterest = point
                //focusMode 设置为AVCaptureFocusModeAutoFocus
                device.focusMode = .autoFocus
                //释放该锁定
                device.unlockForConfiguration()
            } catch  {
                //错误时，则返回给错误处理代理
                delegate?.deviceConfigurationFailedWithError(error: error)
            }
        }
    }
    
    //MARK:  - Exposure Methods   点击曝光的方法实现
    func expose(point: CGPoint) {
        let device = activeCamera()
        
        //判断是否支持 AVCaptureExposureModeContinuousAutoExposure 模式
        if device.isExposurePointOfInterestSupported &&
            device.isExposureModeSupported(.autoExpose){
            do {
                //锁定设备准备配置，如果获得了锁
                try device.lockForConfiguration()
                //将focusPointOfInterest属性设置CGPoint
                device.exposurePointOfInterest = point
                //focusMode 设置为AVCaptureFocusModeAutoFocus
                device.exposureMode = .autoExpose
                
                //判断设备是否支持锁定曝光的模式。
                if device.isExposureModeSupported(.locked) {
                    //支持，则使用kvo确定设备的adjustingExposure属性的状态。
                    device.addObserver(self, forKeyPath: "adjustingExposure", options: .new, context: &ZCameraAdjustingExposureContext)
                }
                
                //释放该锁定
                device.unlockForConfiguration()
            } catch  {
                //错误时，则返回给错误处理代理
                delegate?.deviceConfigurationFailedWithError(error: error)
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        //判断context（上下文）是否为ZCameraAdjustingExposureContext
        if context == &ZCameraAdjustingExposureContext {
            //获取device
            let device = object as! AVCaptureDevice
            
            //判断设备是否不再调整曝光等级，确认设备的exposureMode是否可以设置为AVCaptureExposureModeLocked
            if !device.isAdjustingExposure &&
                device.isExposureModeSupported(.locked){
                //移除作为adjustingExposure 的self，就不会得到后续变更的通知
                device.removeObserver(self, forKeyPath: "adjustingExposure", context: &ZCameraAdjustingExposureContext)
                
                //异步方式调回主队列，
                DispatchQueue.main.async {
                    do{
                        try device.lockForConfiguration()
                        //修改exposureMode
                        device.exposureMode = .locked
                        //释放该锁定
                        device.unlockForConfiguration()
                    }catch{
                        self.delegate?.deviceConfigurationFailedWithError(error: error)
                    }
                }
                
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    //重新设置对焦&曝光
    func resetFocusAndExposureModes() {
        let device = activeCamera()
        
        //获取对焦兴趣点 和 连续自动对焦模式 是否被支持
        let canResetFocus = device.isFocusPointOfInterestSupported && device.isFocusModeSupported(.autoFocus)
        
        //确认曝光度可以被重设
        let canResetExposure = device.isExposurePointOfInterestSupported &&
            device.isExposureModeSupported(.autoExpose)
        
        //回顾一下，捕捉设备空间左上角（0，0），右下角（1，1） 中心点则（0.5，0.5）
        let centPoint = CGPoint(x: 0.5, y: 0.5)
        
        do {
            try device.lockForConfiguration()
            
            if canResetFocus {
                device.focusMode = .autoFocus
                device.focusPointOfInterest = centPoint
            }
            
            if canResetExposure {
                device.exposureMode = .autoExpose
                device.exposurePointOfInterest = centPoint
            }
            
            device.unlockForConfiguration()
        } catch {
            delegate?.deviceConfigurationFailedWithError(error: error)
        }
    }
    
    
    //MARK: - Image Capture Methods 拍摄静态图片
    /*
        AVCaptureStillImageOutput 是AVCaptureOutput的子类。用于捕捉图片
     */
    // 5 实现捕捉静态图片 & 视频的功能
    //捕捉静态图片
    func captureStillImage() {
        //获取连接
        guard let connection = imageOutput.connection(with: .video) else { return }
        
        //程序只支持纵向，但是如果用户横向拍照时，需要调整结果照片的方向
        //判断是否支持设置视频方向
        if connection.isVideoOrientationSupported {
            //获取方向值
            connection.videoOrientation = currentVideoOrientation()
        }
        
        //捕捉静态图片
        imageOutput.captureStillImageAsynchronously(from: connection) { (sampleBuffer, error) in
            if sampleBuffer != nil {
                if let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer!) {
                    if let image = UIImage(data: imageData) {
                        //重点：捕捉图片成功后，将图片传递出去
                        self.writeImageToAssetsLibrary(image: image)
                    }
                }
            }
        }
    }
    
    
    //MARK: - Video Capture Methods 捕捉视频
    //视频录制
    //开始录制
    func startRecording() {
        
    }
    
    //停止录制
    func stopRecording() {
        
    }
    
    //获取录制状态
    func isRecording() -> Bool {
        return movieOutput.isRecording
    }
    
    //录制时间
    func recordedDuration() -> CMTime {
        return CMTime(seconds: 1, preferredTimescale: .zero)
    }
    
    //获取方向值
    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        //获取UIDevice 的 orientation
        switch UIDevice.current.orientation {
        case .portrait:
            return .portrait
        case .landscapeRight:
            return .landscapeLeft
        case .portraitUpsideDown:
            return .portraitUpsideDown
        default:
            return .landscapeRight
        }
    }
    
    /*
        Assets Library 框架
        用来让开发者通过代码方式访问iOS photo
        注意：会访问到相册，需要修改plist 权限。否则会导致项目崩溃
     */
    func writeImageToAssetsLibrary(image: UIImage) {
        //创建ALAssetsLibrary  实例
        let library = ALAssetsLibrary()
        
        //参数1:图片（参数为CGImageRef 所以image.CGImage）
        //参数2:方向参数 转为NSUInteger
        //参数3:写入成功、失败处理
        library.writeImage(toSavedPhotosAlbum: image.cgImage, orientation: ALAssetOrientation(rawValue: image.imageOrientation.rawValue)!) { (url, error) in
            if error != nil {
                print("保存成功")
            } else {
                //失败打印错误信息
                print("保存失败: \(error!.localizedDescription)")
            }
        }
    }
}
