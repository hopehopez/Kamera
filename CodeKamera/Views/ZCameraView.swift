//
//  ZCameraView.swift
//  FaceKamera
//
//  Created by zsq on 2020/9/24.
//  Copyright © 2020 zsq. All rights reserved.
//

import UIKit

class ZCameraView: UIView {

    @IBOutlet weak var previewView: ZPreviewView!
    
    override func awakeFromNib() {
        backgroundColor = UIColor.black
    }

}
