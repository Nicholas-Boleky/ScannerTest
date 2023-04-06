//
//  ToggleButton.swift
//  VSBarcodeReader
//
//  Copyright © 2023 Vision Smarts. All rights reserved.
//

import Foundation
import UIKit

class ToggleGroupButton: UIButton {

    // All ToggleGroupButtons belong to one group, displayed together,
    // and there is always one with tag==-1 : the 'all' button
    public static var buttonGroup : [ToggleGroupButton] = []
    public static var allButton : ToggleGroupButton! = nil

    public static func symbologiesMask() -> Int32 {
        return buttonGroup.filter( { $0.isSelected } ).reduce(0, { acc, b in acc | Int32(b.tag) } )
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupDefaults()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupDefaults()
    }
    
    deinit {
        if let index = ToggleGroupButton.buttonGroup.firstIndex(of:self) {
            ToggleGroupButton.buttonGroup.remove(at:index)
        }
        if self == ToggleGroupButton.allButton {
            ToggleGroupButton.allButton = nil
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setupVisuals()
    }
    
    func setupDefaults() {
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 0
        self.addTarget(self, action: #selector(tap(sender:)), for: UIControl.Event.touchUpInside)
        if tag == -1 { ToggleGroupButton.allButton = self }
        else { ToggleGroupButton.buttonGroup.append(self) }
    }

    func setupVisuals() {
        self.layer.borderColor = self.tintColor.cgColor
        self.showState()
    }

    @IBAction func tap(sender: UIButton) {
        self.isSelected = self.isSelected != true
        let allB = ToggleGroupButton.allButton
        let group = ToggleGroupButton.buttonGroup
        if self == allB {
            for b in group {
                b.isSelected = self.isSelected
                b.showState()
            }
        }
        else {
            allB?.isSelected = group.reduce(true, { acc, b in acc && b.isSelected } )
        }
        self.showState()
    }
 
    func showState() {
            self.backgroundColor = isSelected ? self.tintColor : UIColor.clear
    }
    
}
