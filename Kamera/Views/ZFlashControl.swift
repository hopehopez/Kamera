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

    var selectedMode = 0 {
        didSet{
            sendActions(for: .valueChanged)
        }
    }
    weak var delegate: ZFlashControlDelegate?

    private var expanded: Bool! = false
    private var defaultWidth: CGFloat!
    private var expandedWidth: CGFloat!
    private var selectedIndex: Int! = 0 {
        didSet{
            if selectedIndex == 0 {
                selectedMode = 2
            } else if selectedIndex == 2 {
                selectedMode = 0
            } else {
                selectedMode = selectedIndex
            }
        }
    }
    private var midY: CGFloat!
    private var labels: [UILabel]!
   
        
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: ICON_WIDTH + BUTTON_WIDTH, height: BUTTON_HEIGHT))
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    private func setupView() {
        
        backgroundColor = UIColor.clear
        let iconImage = UIImage(named: "flash_icon")
        let imageView = UIImageView(image: iconImage)
        addSubview(imageView)
        imageView.frame = CGRect(x: imageView.frame.origin.x, y: (frame.height-imageView.frame.height)/2, width: imageView.frame.width, height: imageView.frame.height)
        midY = floor(frame.height - BUTTON_HEIGHT) / 2.0
        labels = buildLabels(labelStrings: ["Auto", "On", "Off"])
        
        defaultWidth = frame.width
        expandedWidth = ICON_WIDTH + BUTTON_WIDTH*CGFloat(labels.count)
        clipsToBounds = true
        
        addTarget(self, action: #selector(selectMode(sender:event:)), for: .touchUpInside)
    }
    
    private func buildLabels(labelStrings: [String]) -> [UILabel] {
        var x = ICON_WIDTH
        var first = true
        var lables = [UILabel]()
        for str in labelStrings {
            let frame = CGRect(x: x, y: midY, width: BUTTON_WIDTH, height: BUTTON_HEIGHT)
            let label = UILabel(frame: frame)
            label.text = str
            let NORMAL_FONT = UIFont(name: "AvenirNextCondensed-Medium", size: FONT_SIZE)
            label.font = NORMAL_FONT
            label.textColor = UIColor.white
            label.backgroundColor = UIColor.clear
            label.textAlignment = first ? .left : .center
            first = false
            addSubview(label)
            lables.append(label)
            x += BUTTON_WIDTH
        }
        return lables
    }
    
    @objc private func selectMode(sender: UIButton, event: UIEvent){
        if !expanded {
            delegate?.flashControlWillExpand()
            let BOLD_FONT = UIFont(name: "AvenirNextCondensed-DemiBold", size: FONT_SIZE)
            let NORMAL_FONT = UIFont(name: "AvenirNextCondensed-Medium", size: FONT_SIZE)
            UIView.animate(withDuration: 0.3) {
                var newFrame = self.frame
                newFrame.size.width = self.expandedWidth
                self.frame = newFrame
                for i in 0..<self.labels.count {
                    let label = self.labels[i]
                    label.font = self.selectedIndex == i ? BOLD_FONT : NORMAL_FONT
                    label.frame = CGRect(x: ICON_WIDTH + CGFloat(i) * BUTTON_WIDTH, y: self.midY, width: BUTTON_WIDTH, height: BUTTON_HEIGHT)
                    if i>0 {
                        label.textAlignment = .center
                    }
                 }
                
            } completion: { (_) in
                self.delegate?.flashControlDidExpand()
            }

        } else {
            delegate?.flashControlWillCollapse()
            
            guard let touch = event.allTouches?.first else { return }
            
            for i in 0..<labels.count {
                let label = labels[i]
                let touchPoint = touch.location(in: label)
                if label.point(inside: touchPoint, with: event) {
                    selectedIndex = i
                    label.textAlignment = .left
                    
                    UIView.animate(withDuration: 0.2) {
                        for i in 0..<self.labels.count {
                            let label = self.labels[i]
                            if i == self.selectedIndex {
                                label.frame = CGRect(x: ICON_WIDTH, y: self.midY, width: BUTTON_WIDTH, height: BUTTON_HEIGHT)
                            } else if i < self.selectedIndex {
                                label.frame = CGRect(x: ICON_WIDTH, y: self.midY, width: 0, height: BUTTON_HEIGHT)
                            } else {
                                label.frame = CGRect(x: ICON_WIDTH + BUTTON_WIDTH, y: self.midY, width: 0, height: BUTTON_HEIGHT)
                            }
                        }
                        var newFrame = self.frame
                        newFrame.size.width = self.defaultWidth
                        self.frame = newFrame
                    } completion: { (_) in
                        self.delegate?.flashControlDidCollapse()
                    }

                }
            }
        }
        expanded = !expanded
    }
}
