//
//  ViewController.swift
//  CodeKamera
//
//  Created by zsq on 2020/9/24.
//  Copyright © 2020 zsq. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var previewView: ZPreviewView!
    
    let cameraController: ZCodeCameraContrller! = ZCodeCameraContrller()
    override func viewDidLoad() {
        super.viewDidLoad()
        if cameraController.setupSession() {
            
            previewView.session = cameraController.captureSession
            
            cameraController.startSession()
        }
    }


}

