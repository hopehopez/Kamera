//
//  CameraDelegate.swift
//  FaceKamera
//
//  Created by zsq on 2020/9/24.
//  Copyright © 2020 zsq. All rights reserved.
//

import AVFoundation

protocol ZCameraControllerDelegate: NSObjectProtocol {
    func deviceConfigurationFailedWithError(error: Error)
    func mediaCaptureFailedWithError(error: Error)
    func assetLibraryWriteFailedWithError(error: Error)
}

protocol ZFaceDetectionDelegate: NSObjectProtocol {
    func didDetectFaces(faces: [AVMetadataFaceObject])
}

protocol ZCodeDetectionDelegate: NSObjectProtocol {
    func didDetectFaces(faces: [AVMetadataObject])
}

