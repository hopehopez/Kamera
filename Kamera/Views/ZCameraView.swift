//
//  ZCameraView.swift
//  Kamera
//
//  Created by zsq on 2020/9/17.
//  Copyright © 2020 zsq. All rights reserved.
//

import UIKit

class ZCameraView: UIView {

   @IBOutlet private(set) var previewView: ZPreviewView!
   @IBOutlet private(set) var controlsView: ZOverlayView!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.black
    }
}
