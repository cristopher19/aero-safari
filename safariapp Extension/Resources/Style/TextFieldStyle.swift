//
//  TextFieldStyle.swift
//  safariapp Extension
//
//  Created by Centauro-mac on 11/21/18.
//  Copyright © 2018 Centauro-mac. All rights reserved.
//

import Foundation
import SafariServices
class TextFieldStyle: NSTextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        self.isEditable = false
        self.drawsBackground = false
        self.isBezeled = false
        self.textColor = NSColor(hex: ColorPalette.TextColor.textBlue)
        self.font = NSFont(name: "Helvetica Neue", size: 11)
        self.lineBreakMode = .byTruncatingTail
    }
}

class HyperlinkTextField: NSTextField {
    @IBInspectable var href: String = ""
    
    override func resetCursorRects() {
        discardCursorRects()
        addCursorRect(self.bounds, cursor: NSCursor.pointingHand)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isEditable = false
        self.drawsBackground = false
        self.isBezeled = false
        self.textColor = NSColor(hex: ColorPalette.TextColor.textBlue)
        self.font = NSFont(name: "Helvetica Neue", size: 11)
        self.lineBreakMode = .byTruncatingTail
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        if let localHref = URL(string: href) {
            NSWorkspace.shared.open(localHref)
        }
    }
    
    override func mouseEntered(with event: NSEvent) {
        // TODO:  Fix this and get the hover click to work.
        
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: NSColor.linkColor,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue as AnyObject
        ]
        attributedStringValue = NSAttributedString(string: self.stringValue, attributes: attributes)
    }
    override func mouseMoved(with event: NSEvent) {
        NSCursor.pointingHand.set()
    }
}



