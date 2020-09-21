//
//  ZPreviewView.swift
//  Kamera
//
//  Created by zsq on 2020/9/17.
//  Copyright © 2020 zsq. All rights reserved.
//

import UIKit

protocol ZPreviewViewDelegate: NSObjectProtocol {
    func tappedToFocusAtPoint(point: CGPoint)
    func tappedToExposeAtPoint(point: CGPoint)
    func tappedToResetFocusAndExposure()
}

class ZPreviewView: UIView {

   
}
