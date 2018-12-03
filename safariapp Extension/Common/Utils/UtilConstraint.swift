//
//  UtilConstraint.swift
//  safariapp Extension
//
//  Created by Centauro-mac on 11/14/18.
//  Copyright © 2018 Centauro-mac. All rights reserved.
//

import Foundation
import SafariServices
protocol UtilConstraint{
    func addConstraintsToItem<T>(leftOffset: CGFloat, rightOffset: CGFloat, topOffset: CGFloat,height: CGFloat, toItem: T)
    func addConstraintLeft<T>(leftOffset: CGFloat,firstAttribute: NSLayoutConstraint.Attribute,secondAttribute:NSLayoutConstraint.Attribute, toItem: T)
    func addConstraintRight<T>( rightOffset: CGFloat, toItem: T)
    func addConstraintHeight(height: CGFloat)
    func addConstraintTop<T>(topOffset: CGFloat, toItem: T,firstAttribute: NSLayoutConstraint.Attribute,secondAttribute:NSLayoutConstraint.Attribute)
    func addConstraintWidth(width: CGFloat)
    func addConstraintBottom<T>(topOffset: CGFloat, toItem: T,firstAttribute: NSLayoutConstraint.Attribute,secondAttribute:NSLayoutConstraint.Attribute)
}
extension NSBox: UtilConstraint {}
extension NSTextField: UtilConstraint {}
extension NSImageView: UtilConstraint {}
extension NSView : UtilConstraint {}
extension NSButton: UtilConstraint {}
//basic constraint for NSbox
extension UtilConstraint  where Self: NSView{
    func addConstraintsToItem<T>(leftOffset: CGFloat, rightOffset: CGFloat, topOffset: CGFloat,height: CGFloat, toItem: T) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        //left
        NSLayoutConstraint(item: self,
                           attribute: .leading,
                           relatedBy: .equal,
                           toItem: toItem,
                           attribute: .leading,
                           multiplier: 1,
                           constant: leftOffset).isActive = true
        //right
        NSLayoutConstraint(item: self,
                           attribute: .trailing,
                           relatedBy: .equal,
                           toItem: toItem,
                           attribute: .trailing,
                           multiplier: 1,
                           constant: rightOffset).isActive = true
        //top
        NSLayoutConstraint(item: self,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: toItem,
                           attribute: .top,
                           multiplier: 1,
                           constant: rightOffset).isActive = true
        
        
        NSLayoutConstraint(item: self,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1,
                           constant: height).isActive = true
    }
    
    
    func addConstraintLeft<T>(leftOffset: CGFloat,firstAttribute: NSLayoutConstraint.Attribute,secondAttribute:NSLayoutConstraint.Attribute, toItem: T) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: self,
                           attribute: firstAttribute,
                           relatedBy: .equal,
                           toItem: toItem,
                           attribute: secondAttribute,
                           multiplier: 1,
                           constant: leftOffset).isActive = true
    }
    
  
    
    
    func addConstraintRight<T>( rightOffset: CGFloat, toItem: T) {
        
         self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: self,
                           attribute: .trailing,
                           relatedBy: .equal,
                           toItem: toItem,
                           attribute: .trailing,
                           multiplier: 1,
                           constant: rightOffset).isActive = true
    }
    
    
    func addConstraintHeight(height: CGFloat) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: self,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1,
                           constant: height).isActive = true
        
    }
    
    func addConstraintWidth(width: CGFloat) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: self,
                           attribute: .width,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1,
                           constant: width).isActive = true
        
    }
    
    func addConstraintTop<T>(topOffset: CGFloat, toItem: T,firstAttribute: NSLayoutConstraint.Attribute,secondAttribute:NSLayoutConstraint.Attribute) {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: self,
                           attribute: firstAttribute,
                           relatedBy: .equal,
                           toItem: toItem,
                           attribute: secondAttribute,
                           multiplier: 1,
                           constant: topOffset).isActive = true
    }
    
    func addConstraintBottom<T>(topOffset: CGFloat, toItem: T,firstAttribute: NSLayoutConstraint.Attribute,secondAttribute:NSLayoutConstraint.Attribute) {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: self,
                           attribute: firstAttribute,
                           relatedBy: .equal,
                           toItem: toItem,
                           attribute: secondAttribute,
                           multiplier: 1,
                           constant: topOffset).isActive = true
    }
}


