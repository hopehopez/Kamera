//
//  ZPreviewView.swift
//  FaceKamera
//
//  Created by zsq on 2020/9/24.
//  Copyright © 2020 zsq. All rights reserved.
//

import UIKit
import AVFoundation
class ZPreviewView: UIView, ZFaceDetectionDelegate {
    
    var session: AVCaptureSession! {
        set{
            previewLayer.session = newValue
        }
        get {
            return previewLayer.session
        }
    }
    private var overlayLayer: CALayer!
    private var faceLayers: [Int: CALayer]  = [:]
    private var previewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    override class var layerClass: AnyClass{
        return AVCaptureVideoPreviewLayer.self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func setupView() {
        
        
        //设置videoGravity 使用AVLayerVideoGravityResizeAspectFill 铺满整个预览层的边界范围
        previewLayer.videoGravity = .resizeAspectFill
        
        //初始化overlayLayer
        overlayLayer = CALayer()
        //设置它的frame
        overlayLayer.frame = bounds
        
        //CATransform3D 图层的旋转，缩放，偏移，歪斜和应用的透
        //CATransform3DIdentity是单位矩阵，该矩阵没有缩放，旋转，歪斜，透视。该矩阵应用到图层上，就是设置默认值。
        var transform3D = CATransform3DIdentity
        //透视效果（就是近大远小），是通过设置m34 m34 = -1.0/D 默认是0.D越小透视效果越明显
        //D:eyePosition 观察者到投射面的距离
        transform3D.m34 = -1.0/1000.0
        
        //子图层形变 sublayerTransform属性   Core  Animation动画
        overlayLayer.sublayerTransform = transform3D
        
        previewLayer.addSublayer(overlayLayer)
    }
    
    
    //将检测到的人脸进行可视化
    func didDetectFaces(faces: [AVMetadataFaceObject]) {
        //创建一个本地数组 保存转换后的人脸数据
        let transformedFaces: [AVMetadataFaceObject] = faces.map { (item) -> AVMetadataFaceObject in
            let obj = self.previewLayer.transformedMetadataObject(for: item)
            return obj! as! AVMetadataFaceObject
        }
        
        /*
            支持同时识别10个人脸
         */
        var currentFaces = [Int]()
        
        for face in transformedFaces {
            currentFaces.append(face.faceID)
            
            //拿到当前faceID对应的layer
            var layer = faceLayers[face.faceID]
            
            //如果给定的faceID 没有找到对应的图层
            if layer == nil {
                //调用makeFaceLayer 创建一个新的人脸图层
                layer = makeFaceLayer()
                
                //将新的人脸图层添加到 overlayLayer上
                overlayLayer.addSublayer(layer!)
                
                //将layer加入到字典中
                faceLayers[face.faceID] = layer
            }
            
            //设置图层的transform属性 CATransform3DIdentity 图层默认变化 这样可以重新设置之前应用的变化
            layer?.transform = CATransform3DIdentity
            
            layer?.frame = face.bounds
            
            //判断人脸对象是否具有有效的斜倾角
            if face.hasRollAngle {
                //如果为YES,则获取相应的CATransform3D 值
                let t = transformForRollAngle(rollAngleInDegrees: face.rollAngle)
                
                //将它与标识变化关联在一起，并设置transform属性
                layer?.transform = CATransform3DConcat(layer!.transform, t)
            }
            
            //判断人脸对象是否具有有效的偏转角
            if face.hasYawAngle {
                //如果为YES,则获取相应的CATransform3D 值
                let t = transformForYawAngle(yawAngleInDegrees: face.yawAngle)
                layer?.transform = CATransform3DConcat(layer!.transform, t)
            }
            
        }
        
        for faceId in faceLayers.keys {
            if !currentFaces.contains(faceId) {
                faceLayers[faceId]?.removeFromSuperlayer()
            }
        }
        
        //遍历数组将剩下的人脸ID集合从上一个图层和faceLayers字典中移除
        faceLayers = faceLayers.filter{currentFaces.contains($0.key)}
        
        
    }
    
    //将 RollAngle 的 rollAngleInDegrees 值转换为 CATransform3D
    func transformForRollAngle(rollAngleInDegrees: CGFloat) -> CATransform3D {
        //将人脸对象得到的RollAngle 单位“度” 转为Core Animation需要的弧度值
        let rollAngleInRadians: CGFloat = rollAngleInDegrees * .pi / 180
        
        //将结果赋给CATransform3DMakeRotation x,y,z轴为0，0，1 得到绕Z轴倾斜角旋转转换
        return CATransform3DMakeRotation(rollAngleInRadians, 0.0, 0.0, 1.0)
    }
    
    //将 YawAngle 的 yawAngleInDegrees 值转换为 CATransform3D
    func transformForYawAngle(yawAngleInDegrees: CGFloat) -> CATransform3D {
        //将角度转换为弧度值
        let yawAngleInRaians: CGFloat = yawAngleInDegrees * .pi / 180
        
        //将结果CATransform3DMakeRotation x,y,z轴为0，-1，0 得到绕Y轴选择。
        //由于overlayer 需要应用sublayerTransform，所以图层会投射到z轴上，人脸从一侧转向另一侧会有3D 效果
        let yawTransform = CATransform3DMakeRotation(yawAngleInRaians, 0.0, 1.0, 0.0)
        
        //因为应用程序的界面固定为垂直方向，但需要为设备方向计算一个相应的旋转变换
        //如果不这样，会造成人脸图层的偏转效果不正确
        return CATransform3DConcat(yawTransform, orientationTransform())
    }
    
    func orientationTransform() -> CATransform3D {
        var angle: CGFloat = 0.0
        
        //拿到设备方向
        switch UIDevice.current.orientation {
        //方向：下
        case .portraitUpsideDown:
            angle = CGFloat(Double.pi)
        //方向：右
        case .landscapeRight:
            angle = CGFloat(-Double.pi/2.0)
        //方向：左
        case .landscapeLeft:
            angle = CGFloat(Double.pi/2.0)
        default:
            angle = 0.0
        }
        return CATransform3DMakeRotation(angle, 0.0, 0.0, 1.0)
    }
    
    func makeFaceLayer() -> CALayer {
        let layer = CALayer()
        layer.borderWidth = 5.0
        layer.borderColor = UIColor.red.cgColor
        layer.contents = UIImage(named: "551")?.cgImage
        return layer
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        

        previewLayer.frame = bounds
        overlayLayer.frame = bounds
    }
}
