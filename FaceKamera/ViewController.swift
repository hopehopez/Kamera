//
//  ViewController.swift
//  FaceKamera
//
//  Created by zsq on 2020/9/24.
//  Copyright © 2020 zsq. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var previewView: ZPreviewView!
    
    let cameraController: ZFaceCameraContrller! = ZFaceCameraContrller()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        if cameraController.setupSession() {
           _ = cameraController.switchCameras()
            
            previewView.session = cameraController.captureSession
            
            cameraController.faceDetectionDelegate = previewView
            
            cameraController.startSession()
        }
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }


    @IBAction func swapCamera(_ sender: Any) {
        cameraController.switchCameras()
    }
}

