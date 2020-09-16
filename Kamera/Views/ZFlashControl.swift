//
//  ZFlashControl.swift
//  Kamera
//
//  Created by zsq on 2020/9/16.
//  Copyright © 2020 zsq. All rights reserved.
//

import UIKit


protocol ZFlashControlDelegate: NSObjectProtocol {
    func flashControlWillExpand()
    func flashControlDidExpand()
    func flashControlWillCollapse()
    func flashControlDidCollapse()
}

extension ZFlashControlDelegate{
    func flashControlWillExpand() {}
    func flashControlDidExpand() {}
    func flashControlWillCollapse() {}
    func flashControlDidCollapse() {}
}

private let BUTTON_WIDTH: CGFloat = 48.0
private let BUTTON_HEIGHT: CGFloat = 30.0
private let ICON_WIDTH: CGFloat = 18.0
private let FONT_SIZE: CGFloat = 17.0

class ZFlashControl: UIControl {

    var selectedMode = 0
    weak var delegate: ZFlashControlDelegate?

    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: ICON_WIDTH + BUTTON_WIDTH, height: BUTTON_HEIGHT))
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    func setupView() {
        
        
        
    }
}
