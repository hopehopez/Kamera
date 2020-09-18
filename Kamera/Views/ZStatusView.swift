//
//  ZStatusView.swift
//  Kamera
//
//  Created by zsq on 2020/9/17.
//  Copyright © 2020 zsq. All rights reserved.
//

import UIKit

class ZStatusView: UIView, ZFlashControlDelegate {

   @IBOutlet var flashControl: ZFlashControl!
   @IBOutlet var elapsedTimeLabel: UILabel!
    

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
//        setupView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    func setupView() {
        flashControl.delegate = self
    }
    
    func flashControlWillExpand() {
        UIView.animate(withDuration: 0.2) {
            self.elapsedTimeLabel.alpha = 0
        }
    }
    
    func flashControlWillCollapse() {
        UIView.animate(withDuration: 0.2) {
            self.elapsedTimeLabel.alpha = 1.0
        }
    }
}
