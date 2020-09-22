//
//  ViewController.swift
//  Kamera
//
//  Created by zsq on 2020/9/16.
//  Copyright © 2020 zsq. All rights reserved.
//

import UIKit
import AVFoundation
class ViewController: UIViewController {

    @IBOutlet weak var previewView: ZPreviewView!
    @IBOutlet weak var overlayView: ZOverlayView!
    

    @IBOutlet weak var thumbnailButton: UIButton!
    var cameraController = ZCameraController()
    var timer: Timer!
    var cameraMode: ZCameraMode = .video
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        if cameraController.setupSession() {
            previewView.session = self.cameraController.captureSession
            previewView.delegate = self
            cameraController.startSession()
        }
        
        previewView.tapToFocusEnabled = cameraController.cameraSupportsTapToFocus
        previewView.tapToExposeEnabled = cameraController.cameraSupportsTapToExpose
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateThumbnail(notification:)), name: Notification.Name.init("ZThumbnailCreatedNotification"), object: nil)
    }
    
    @objc func updateThumbnail(notification: Notification){
        let image = notification.object as? UIImage
        thumbnailButton.setImage(image, for: .normal)
        thumbnailButton.layer.borderColor = UIColor.white.cgColor
        thumbnailButton.layer.borderWidth = 1.0
    }

    
    @IBAction func flashControlChanged(_ sender: ZFlashControl) {
        if cameraMode == .photo {
            cameraController.flashMode = AVCaptureDevice.FlashMode(rawValue: cameraMode.rawValue)!
        } else {
            cameraController.torchMode = AVCaptureDevice.TorchMode(rawValue: cameraMode.rawValue)!
        }
    }
    

    @IBAction func captureOrRecord(_ sender: Any) {
        if cameraMode == .photo {
            cameraController.captureStillImage()
        } else {
            if !cameraController.isRecording() {
                DispatchQueue(label: "com.tapharmonic.kamera").async {
                    self.cameraController.startRecording()
                }
            }
        }
    }
    
    @IBAction func swapCameras(_ sender: Any) {
        if cameraController.switchCameras() {
            var isHidden = false
            if cameraMode == .photo {
                isHidden = !cameraController.cameraHasFlash
            } else {
                isHidden = !cameraController.cameraHasTorch
            }
            overlayView.flashControlHidden = isHidden
            previewView.tapToExposeEnabled = cameraController.cameraSupportsTapToExpose
            previewView.tapToFocusEnabled = cameraController.cameraSupportsTapToFocus
            cameraController.resetFocusAndExposureModes()
            
        }
      }
    
    @IBAction func cameraModeChanged(_ sender: ZCameraModeView) {
        cameraMode = sender.cameraMode
    }
    @IBAction func showCameraRoll(_ sender: Any) {
        let controller = UIImagePickerController()
        controller.sourceType = .photoLibrary
        controller.mediaTypes = UIImagePickerController.availableMediaTypes(for: UIImagePickerController.SourceType.photoLibrary)!
        present(controller, animated: true, completion: nil)
    }
    
    func startTimer() {
        timer.invalidate()
        timer = Timer(timeInterval: 0.5, target: self, selector: #selector(updateTimeDisplay), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimeDisplay(){
        let duration = cameraController.recordedDuration()
        let time = Int(CMTimeGetSeconds(duration))
        let hours = time / 3600
        let minutes = (time / 60)%60
        let seconds = time%60
        
        let timeString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        overlayView.statusView.elapsedTimeLabel.text = timeString
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
}

extension ViewController: ZPreviewViewDelegate {
    func tappedToFocusAtPoint(point: CGPoint) {
        cameraController.focus(point: point)
    }
    
    func tappedToExposeAtPoint(point: CGPoint) {
        cameraController.expose(point: point)
    }
    
    func tappedToResetFocusAndExposure() {
        cameraController.resetFocusAndExposureModes()
    }
    
    
}

