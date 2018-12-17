//
//  CartView.swift
//  safariapp Extension
//
//  Created by Centauro-mac on 11/28/18.
//  Copyright © 2018 Centauro-mac. All rights reserved.
//

import Foundation
import SafariServices
import Alamofire
import SDWebImage
extension MainViewController{
    /*
     * Create Profile view
     * # tag for view = 1001
     */
    @objc func showCartView() {
        self.profileContentBox?.isHidden = true
        self.prealertContentBox?.isHidden = true
        self.trackContentBox?.isHidden = true
        if (self.contentBox.viewWithTag(903) == nil ){
            // - 12 del scroll / - 30 de la section bottom
            self.cartContentBox = NSView(frame: NSMakeRect(contentBox.frame.origin.x,contentBox.frame.origin.y  ,
                                                           contentBox.frame.size.width, contentBox.frame.size.height))
            self.cartContentBox!.wantsLayer = true
            //self.cartContentBox!.borderType = .lineBorder
            //self.cartContentBox!.boxType = .custom
            
            self.contentBox.addSubview(self.cartContentBox!)
            cartContentBox!.leftAnchor.constraint(equalTo: self.cartContentBox!.leftAnchor, constant: 0.0).isActive = true
            cartContentBox!.topAnchor.constraint(equalTo: self.cartContentBox!.topAnchor, constant: 0.0).isActive = true
            cartContentBox!.rightAnchor.constraint(equalTo: self.cartContentBox!.rightAnchor, constant: 0.0).isActive = true
            cartContentBox!.bottomAnchor.constraint(equalTo: self.cartContentBox!.bottomAnchor, constant: 0.0).isActive = true
            
            viewModel.getCart()
            viewModel.didFinishFetch = {
                UserDefaults.standard.set(self.viewModel.cartObject?.cartId, forKey: "cartID")
                self.createCartView()
            }
            
        }else{
            self.cartContentBox?.isHidden = false
        }
        
    }
    
    func createCartView(){
        let cartObjects = self.viewModel.cartObject?.cartItemList?.count ?? 0
        let profileBox = NSView()
        profileBox.viewWithTag(1001)
        profileBox.wantsLayer = true
        profileBox.layer?.backgroundColor = NSColor.white.cgColor
        
        self.cartContentBox?.addSubview(profileBox)
        profileBox.addConstraintTop(topOffset: 0, toItem: self.cartContentBox!, firstAttribute: .top, secondAttribute: .top)
        profileBox.addConstraintRight(rightOffset: 0, toItem: self.cartContentBox!)
        profileBox.addConstraintLeft(leftOffset: 0, firstAttribute: .leading, secondAttribute: .leading, toItem: self.cartContentBox!)
        profileBox.addConstraintHeight(height: self.cartContentBox!.frame.size.height)
        

        if(cartObjects == 0){
            //create text count items
            let accountTitleTextField = TextFieldStyle()
            accountTitleTextField.stringValue = "Shopping cart (\(String(cartObjects)))"
            accountTitleTextField.sizeToFit()
            accountTitleTextField.tag = 903
            // add items to trackbox
            profileBox.addSubview(accountTitleTextField)
            
            /** constraint **/
            accountTitleTextField.addConstraintLeft(leftOffset: 15.0, firstAttribute: .leading, secondAttribute: .leading, toItem: profileBox)
            accountTitleTextField.addConstraintTop(topOffset: 10, toItem: profileBox, firstAttribute: .top, secondAttribute: .top)
            accountTitleTextField.addConstraintWidth(width: accountTitleTextField.frame.width)
            accountTitleTextField.addConstraintHeight(height: 20.0)
            
            lastCartBox = accountTitleTextField
            self.createCartEmpty(parent: profileBox)
        }else{
            // Initial scrollview
            let scrollView = NSScrollView()
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.borderType = .noBorder
            scrollView.backgroundColor = NSColor.white
            scrollView.hasVerticalScroller = true
            
            profileBox.addSubview(scrollView)
            profileBox.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollView]|", options: [], metrics: nil, views: ["scrollView": scrollView]))
            profileBox.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollView]|", options: [], metrics: nil, views: ["scrollView": scrollView]))
            
            // Initial clip view
            let clipView = NSClipView()
            clipView.layer?.backgroundColor = NSColor.white.cgColor
            clipView.backgroundColor = NSColor.white
            clipView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.contentView = clipView
            scrollView.addConstraint(NSLayoutConstraint(item: clipView, attribute: .left, relatedBy: .equal, toItem: scrollView, attribute: .left, multiplier: 1.0, constant: 0))
            scrollView.addConstraint(NSLayoutConstraint(item: clipView, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1.0, constant: 0))
            scrollView.addConstraint(NSLayoutConstraint(item: clipView, attribute: .right, relatedBy: .equal, toItem: scrollView, attribute: .right, multiplier: 1.0, constant: 0))
            scrollView.addConstraint(NSLayoutConstraint(item: clipView, attribute: .bottom, relatedBy: .equal, toItem: scrollView, attribute: .bottom, multiplier: 1.0, constant: 0))
            
            // Initial document view
            let documentView = FlippedView()
            documentView.translatesAutoresizingMaskIntoConstraints = false
            documentView.wantsLayer = true
            documentView.layer?.backgroundColor = NSColor.white.cgColor
            
            scrollView.documentView = documentView
            clipView.addConstraint(NSLayoutConstraint(item: clipView, attribute: .left, relatedBy: .equal, toItem: documentView, attribute: .left, multiplier: 1.0, constant: 0))
            clipView.addConstraint(NSLayoutConstraint(item: clipView, attribute: .top, relatedBy: .equal, toItem: documentView, attribute: .top, multiplier: 1.0, constant: 0))
            clipView.addConstraint(NSLayoutConstraint(item: clipView, attribute: .right, relatedBy: .equal, toItem: documentView, attribute: .right, multiplier: 1.0, constant: 0))
            
            
            //create text count items
            let accountTitleTextField = TextFieldStyle()
            accountTitleTextField.stringValue = "Shopping cart (\(String(cartObjects)))"
            accountTitleTextField.sizeToFit()
            accountTitleTextField.tag = 903
            // add items to trackbox
            documentView.addSubview(accountTitleTextField)
            
            /** constraint **/
            accountTitleTextField.addConstraintLeft(leftOffset: 15.0, firstAttribute: .leading, secondAttribute: .leading, toItem: clipView)
            accountTitleTextField.addConstraintTop(topOffset: 10, toItem: clipView, firstAttribute: .top, secondAttribute: .top)
            accountTitleTextField.addConstraintWidth(width: accountTitleTextField.frame.width)
            accountTitleTextField.addConstraintHeight(height: 20.0)
            
            lastCartBox = accountTitleTextField
            
            self.createCartListItems(parent: documentView)
             scrollView.documentView = documentView
        }
       
        
    }
    func createCartEmpty(parent: NSView){
        let imageRefresh = NSImageView.init(frame:NSMakeRect(15, 8, 10, 10))
        imageRefresh.image = NSImage(named: "icon_cart")
        
        //create text desc items
        let cartEmptyTextField = TextFieldStyle()
        cartEmptyTextField.stringValue = "Your cart is empty"
        cartEmptyTextField.sizeToFit()
        
        //create text desc items
        let descriptionTextField = TextFieldStyle()
        descriptionTextField.stringValue = "You don't have any products aaded to your cart yet."
        descriptionTextField.sizeToFit()
        
        /** btn checkout **/
        let buttonLogOut = NSButton()
        buttonLogOut.wantsLayer = true
        buttonLogOut.layer?.backgroundColor = NSColor(hex: ColorPalette.BackgroundColor.bgDarkBlue).cgColor
        buttonLogOut.title = "Visit Aeropost.com"
        buttonLogOut.tag = UrlPages.checkOut.idPage
        buttonLogOut.action = #selector(MainViewController.openUrlInWeb(_:))
        
        parent.addSubview(imageRefresh)
        parent.addSubview(cartEmptyTextField)
        parent.addSubview(descriptionTextField)
        parent.addSubview(buttonLogOut)
        
        imageRefresh.addConstraintWidth(width: 30.0)
        imageRefresh.addConstraintHeight(height: 30.0)
        imageRefresh.addConstraintLeft(leftOffset: (contentBox.frame.size.width / 2) - 15, firstAttribute: .leading, secondAttribute: .leading, toItem: parent)
        imageRefresh.addConstraintTop(topOffset: 25.0, toItem: lastCartBox, firstAttribute: .top, secondAttribute: .bottom)
        
        cartEmptyTextField.addConstraintWidth(width: cartEmptyTextField.frame.size.width)
        cartEmptyTextField.addConstraintLeft(leftOffset: (contentBox.frame.size.width / 2) - (cartEmptyTextField.frame.size.width / 2), firstAttribute: .leading, secondAttribute: .leading, toItem: parent)
        cartEmptyTextField.addConstraintTop(topOffset: 25.0, toItem: imageRefresh, firstAttribute: .top, secondAttribute: .bottom)
        
        descriptionTextField.addConstraintWidth(width: descriptionTextField.frame.size.width)
        descriptionTextField.addConstraintLeft(leftOffset: (contentBox.frame.size.width / 2) - (descriptionTextField.frame.size.width / 2), firstAttribute: .leading, secondAttribute: .leading, toItem: parent)
        descriptionTextField.addConstraintTop(topOffset: 25.0, toItem: cartEmptyTextField, firstAttribute: .top, secondAttribute: .bottom)
        
        
        buttonLogOut.addConstraintHeight(height: 40.0)
        buttonLogOut.addConstraintLeft(leftOffset: 20, firstAttribute: .leading, secondAttribute: .leading, toItem: parent)
        buttonLogOut.addConstraintRight(rightOffset: -30, toItem: parent)
        buttonLogOut.addConstraintTop(topOffset: 30.0, toItem: descriptionTextField, firstAttribute: .top, secondAttribute: .bottom)
    }
    
    func createCartListItems(parent: NSView){
        let itemCartHeight: CGFloat = 80.0
        var itemCartSpace: CGFloat = 15.0
        
        if let cartList = viewModel.cartObject?.cartItemList{
            for (index, itemCart) in cartList.enumerated(){
                let productItemBox = NSView()
                productItemBox.viewWithTag(index + 100)
                productItemBox.wantsLayer = true
                productItemBox.layer?.backgroundColor = NSColor.white.cgColor
                productItemBox.layer?.borderWidth = 1
                productItemBox.layer!.borderColor = NSColor(hex: ColorPalette.BorderColor.bgMidGray).cgColor
                /** items del box **/
                let imageRefresh = NSImageView.init(frame:NSMakeRect(15, 8, 10, 10))
                let url = URL(string: itemCart.image ?? "")
                if(url != nil){
                    imageRefresh.sd_setImage(with: URL(string: (url?.absoluteString)!), placeholderImage: NSImage(named: "defaultImage"))
                }else{
                    imageRefresh.sd_setImage(with: URL(string: ("")), placeholderImage: NSImage(named: "defaultImage"))
                }
                
                
                //create text desc items
                let descriptionTextField = TextFieldStyle()
                descriptionTextField.stringValue = itemCart.title ?? ""
                
                //create text courier items
                let itemAmountTextField = TextFieldStyle()
                itemAmountTextField.stringValue = String(format: "%.2f", Double(itemCart.price ?? 0))
                itemAmountTextField.sizeToFit()
                
                //create text courier name items
                let quantityTextField = TextFieldStyle()
                quantityTextField.stringValue = "Quantity \(itemCart.quantity ?? 0)"
                quantityTextField.sizeToFit()
                
                //create text courier name items
                let removeTextField = TextFieldStyle()
                removeTextField.stringValue = "Remove"
                removeTextField.sizeToFit()
                removeTextField.tag = index
                let removeClick: NSClickGestureRecognizer = NSClickGestureRecognizer()
                removeClick.action = #selector(MainViewController.deleteItemCart(_:))
                removeTextField.addGestureRecognizer(removeClick)
                
                productItemBox.addSubview(imageRefresh)
                productItemBox.addSubview(descriptionTextField)
                productItemBox.addSubview(itemAmountTextField)
                productItemBox.addSubview(quantityTextField)
                productItemBox.addSubview(removeTextField)
                
                //add to parent
                parent.addSubview(productItemBox)
                
                /** constraint here**/
                productItemBox.addConstraintLeft(leftOffset: 0, firstAttribute: .leading, secondAttribute: .leading, toItem: parent)
                productItemBox.addConstraintTop(topOffset: itemCartSpace, toItem: lastCartBox, firstAttribute: .top, secondAttribute: .bottom)
                productItemBox.addConstraintWidth(width: contentBox.frame.size.width)
                productItemBox.addConstraintHeight(height: itemCartHeight)
                
                imageRefresh.addConstraintWidth(width: 40.0)
                imageRefresh.addConstraintHeight(height: 40.0)
                imageRefresh.addConstraintLeft(leftOffset: 15.0, firstAttribute: .leading, secondAttribute: .leading, toItem: productItemBox)
                imageRefresh.addConstraintTop(topOffset: (itemCartHeight / 2) - 20, toItem: productItemBox, firstAttribute: .top, secondAttribute: .top)
                
                
                descriptionTextField.addConstraintHeight(height: 15.0)
                descriptionTextField.addConstraintLeft(leftOffset: 10.0, firstAttribute: .leading, secondAttribute: .trailing, toItem: imageRefresh)
                descriptionTextField.addConstraintRight(rightOffset: -25, toItem: productItemBox)
                //17 = 15 del tamaño de textfield 2 del espacio
                descriptionTextField.addConstraintTop(topOffset: (itemCartHeight / 2) - 20, toItem: productItemBox, firstAttribute: .top, secondAttribute: .top)
                
                itemAmountTextField.addConstraintWidth(width: itemAmountTextField.frame.size.width)
                itemAmountTextField.addConstraintHeight(height: 15.0)
                itemAmountTextField.addConstraintLeft(leftOffset: 10.0, firstAttribute: .leading, secondAttribute: .trailing, toItem: imageRefresh)
                itemAmountTextField.addConstraintTop(topOffset: 2, toItem: descriptionTextField, firstAttribute: .top, secondAttribute: .bottom)
                
                quantityTextField.addConstraintWidth(width: quantityTextField.frame.size.width)
                quantityTextField.addConstraintHeight(height: 15.0)
                quantityTextField.addConstraintLeft(leftOffset: 10.0, firstAttribute: .leading, secondAttribute: .trailing, toItem: imageRefresh)
                quantityTextField.addConstraintTop(topOffset: 2, toItem: itemAmountTextField, firstAttribute: .top, secondAttribute: .bottom)
                
                removeTextField.addConstraintWidth(width: removeTextField.frame.size.width)
                removeTextField.addConstraintHeight(height: 12.0)
                removeTextField.addConstraintRight(rightOffset: -25, toItem: productItemBox)
                removeTextField.addConstraintTop(topOffset: 2, toItem: itemAmountTextField, firstAttribute: .top, secondAttribute: .bottom)
                
                itemCartSpace = 0.0
                lastCartBox = productItemBox
            }
            
            createOrderSummary(parent: parent)
        }
        
    }
    @objc func deleteItemCart(_ sender : NSClickGestureRecognizer) {
        if let v = sender.view as? NSTextField {
            let product: ShoppingCartProducts = (viewModel.cartObject?.cartItemList![v.tag])!
            
            viewModel.deleteCartItem(productId: product.productId!)
            viewModel.didFinishFetch = {
                
                self.cartContentBox!.subviews.forEach({ $0.removeFromSuperview() })
                self.showCartView()
               
            }
        }
    }
    func createOrderSummary(parent: NSView){
        let orderSummaryItemBox = NSView()
        orderSummaryItemBox.viewWithTag(1001)
        orderSummaryItemBox.wantsLayer = true
        orderSummaryItemBox.layer?.backgroundColor = NSColor(hex: ColorPalette.BackgroundColor.bgLightGray).cgColor
        
        let divideLine = NSView()
        divideLine.wantsLayer = true
        divideLine.layer?.backgroundColor = NSColor(hex: ColorPalette.BackgroundColor.bgLightBlue).cgColor
        
        //create text desc items
        let titleTextField = TextFieldStyle()
        titleTextField.stringValue = "Order summary".uppercased()
        titleTextField.sizeToFit()
        titleTextField.alignment = .center
        
        //create text desc items
        let subTotalTextField = TextFieldStyle()
        subTotalTextField.stringValue = "Subtotal: "
        subTotalTextField.sizeToFit()
        subTotalTextField.alignment = .right
        
        //create text desc items
        let admFeeTextField = TextFieldStyle()
        admFeeTextField.stringValue = "Administrative Fee: "
        admFeeTextField.sizeToFit()
        admFeeTextField.alignment = .right
        
        //create text desc items
        let taxesTextField = TextFieldStyle()
        taxesTextField.stringValue = "Taxes"
        taxesTextField.sizeToFit()
        taxesTextField.alignment = .right
        
        //create text desc items
        let shippingCostTextField = TextFieldStyle()
        shippingCostTextField.stringValue = "Shipping cost to destination country"
        shippingCostTextField.sizeToFit()
        shippingCostTextField.alignment = .right
        
        //create text desc items
        let multipleProductTextField = TextFieldStyle()
        multipleProductTextField.stringValue = "Multiple Product discount"
        multipleProductTextField.sizeToFit()
        multipleProductTextField.alignment = .right
        
        //create text desc items
        let orderTotalTextField = TextFieldStyle()
        orderTotalTextField.stringValue = "Order total".uppercased()
        orderTotalTextField.sizeToFit()
        orderTotalTextField.alignment = .right
        
        //create text desc items
        let priceDescriptionTextField = TextFieldStyle()
        priceDescriptionTextField.stringValue = "Price includes shipping and taxes"
        priceDescriptionTextField.sizeToFit()
        priceDescriptionTextField.alignment = .right
        
        /** textfield Values **/
        //create text desc items
        let subtotalValueTextField = TextFieldStyle()
        subtotalValueTextField.stringValue = String(format: "%.2f", Double(viewModel.cartObject?.subtotal ?? 0))
        subtotalValueTextField.sizeToFit()
        
        //create text desc items
        let admFeeValueTextField = TextFieldStyle()
        admFeeValueTextField.stringValue = String(format: "%.2f", Double(viewModel.cartObject?.administrativeFee ?? 0))
        admFeeValueTextField.sizeToFit()
        
        //create text desc items
        let taxesValueTextField = TextFieldStyle()
        taxesValueTextField.stringValue = String(format: "%.2f", Double(viewModel.cartObject?.taxes ?? 0))
        taxesValueTextField.sizeToFit()
        
        //create text desc items
        let shippingCostValueTextField = TextFieldStyle()
        shippingCostValueTextField.stringValue = String(format: "%.2f", Double(viewModel.cartObject?.shippingCost ?? 0))
        shippingCostValueTextField.sizeToFit()
        
        //create text desc items
        let multipleProductValueTextField = TextFieldStyle()
        multipleProductValueTextField.stringValue = String(format: "%.2f", Double(viewModel.cartObject?.discountMultipleItems ?? 0))
        multipleProductValueTextField.sizeToFit()
        
        //create text desc items
        let orderTotalValueTextField = TextFieldStyle()
        orderTotalValueTextField.stringValue = String(format: "%.2f", Double(viewModel.cartObject?.totalPrice ?? 0))
        orderTotalValueTextField.sizeToFit()
        
   
        /** btn checkout **/
        let buttonLogOut = NSButton()
        buttonLogOut.wantsLayer = true
        buttonLogOut.layer?.backgroundColor = NSColor(hex: ColorPalette.BackgroundColor.bgDarkBlue).cgColor
        buttonLogOut.title = "Continue to checkout"
        buttonLogOut.tag = UrlPages.checkOut.idPage
        buttonLogOut.action = #selector(MainViewController.openUrlInWeb(_:))
        
        /** add to view **/
        orderSummaryItemBox.addSubview(titleTextField)
        orderSummaryItemBox.addSubview(subTotalTextField)
        orderSummaryItemBox.addSubview(admFeeTextField)
        orderSummaryItemBox.addSubview(taxesTextField)
        orderSummaryItemBox.addSubview(shippingCostTextField)
        orderSummaryItemBox.addSubview(multipleProductTextField)
        orderSummaryItemBox.addSubview(orderTotalTextField)
        orderSummaryItemBox.addSubview(priceDescriptionTextField)
        orderSummaryItemBox.addSubview(subtotalValueTextField)
        orderSummaryItemBox.addSubview(admFeeValueTextField)
        orderSummaryItemBox.addSubview(taxesValueTextField)
        orderSummaryItemBox.addSubview(shippingCostValueTextField)
        orderSummaryItemBox.addSubview(multipleProductValueTextField)
        orderSummaryItemBox.addSubview(orderTotalValueTextField)
        orderSummaryItemBox.addSubview(buttonLogOut)
        orderSummaryItemBox.addSubview(divideLine)
        
        parent.addSubview(orderSummaryItemBox)
        
        /** Constraints here **/
        orderSummaryItemBox.addConstraintLeft(leftOffset: 0, firstAttribute: .leading, secondAttribute: .leading, toItem: parent)
        orderSummaryItemBox.addConstraintTop(topOffset: 25, toItem: lastCartBox, firstAttribute: .top, secondAttribute: .bottom)
        orderSummaryItemBox.addConstraintWidth(width: contentBox.frame.size.width)
        orderSummaryItemBox.addConstraintHeight(height: 250)
        
        /** titulo **/
        titleTextField.addConstraintLeft(leftOffset: 0, firstAttribute: .leading, secondAttribute: .leading, toItem: orderSummaryItemBox)
        titleTextField.addConstraintTop(topOffset: 5, toItem: orderSummaryItemBox, firstAttribute: .top, secondAttribute: .top)
        titleTextField.addConstraintWidth(width: contentBox.frame.size.width)
        titleTextField.addConstraintHeight(height: titleTextField.frame.size.height)
        
        subTotalTextField.addConstraintLeft(leftOffset: 2, firstAttribute: .leading, secondAttribute: .leading, toItem: orderSummaryItemBox)
        subTotalTextField.addConstraintTop(topOffset: 5, toItem: titleTextField, firstAttribute: .top, secondAttribute: .bottom)
        subTotalTextField.addConstraintWidth(width: contentBox.frame.size.width * 0.55)
        subTotalTextField.addConstraintHeight(height: subTotalTextField.frame.size.height)
        
        admFeeTextField.addConstraintLeft(leftOffset: 2, firstAttribute: .leading, secondAttribute: .leading, toItem: orderSummaryItemBox)
        admFeeTextField.addConstraintTop(topOffset: 5, toItem: subTotalTextField, firstAttribute: .top, secondAttribute: .bottom)
        admFeeTextField.addConstraintWidth(width: contentBox.frame.size.width * 0.55)
        admFeeTextField.addConstraintHeight(height: admFeeTextField.frame.size.height)
        
        taxesTextField.addConstraintLeft(leftOffset: 2, firstAttribute: .leading, secondAttribute: .leading, toItem: orderSummaryItemBox)
        taxesTextField.addConstraintTop(topOffset: 5, toItem: admFeeTextField, firstAttribute: .top, secondAttribute: .bottom)
        taxesTextField.addConstraintWidth(width: contentBox.frame.size.width * 0.55)
        taxesTextField.addConstraintHeight(height: taxesTextField.frame.size.height)
        
        shippingCostTextField.addConstraintLeft(leftOffset: 2, firstAttribute: .leading, secondAttribute: .leading, toItem: orderSummaryItemBox)
        shippingCostTextField.addConstraintTop(topOffset: 5, toItem: taxesTextField, firstAttribute: .top, secondAttribute: .bottom)
        shippingCostTextField.addConstraintWidth(width: contentBox.frame.size.width * 0.55)
        shippingCostTextField.addConstraintHeight(height: shippingCostTextField.frame.size.height)
        
        multipleProductTextField.addConstraintLeft(leftOffset: 2, firstAttribute: .leading, secondAttribute: .leading, toItem: orderSummaryItemBox)
        multipleProductTextField.addConstraintTop(topOffset: 5, toItem: shippingCostTextField, firstAttribute: .top, secondAttribute: .bottom)
        multipleProductTextField.addConstraintWidth(width: contentBox.frame.size.width * 0.55)
        multipleProductTextField.addConstraintHeight(height: multipleProductTextField.frame.size.height)
        
        divideLine.addConstraintLeft(leftOffset: 10, firstAttribute: .leading, secondAttribute: .leading, toItem: orderSummaryItemBox)
        divideLine.addConstraintTop(topOffset: 5, toItem: multipleProductTextField, firstAttribute: .top, secondAttribute: .bottom)
        divideLine.addConstraintHeight(height: 1)
        divideLine.addConstraintRight(rightOffset: -10, toItem: orderSummaryItemBox)
        
        //order total
        orderTotalTextField.addConstraintLeft(leftOffset: 2, firstAttribute: .leading, secondAttribute: .leading, toItem: orderSummaryItemBox)
        orderTotalTextField.addConstraintTop(topOffset: 5, toItem: divideLine, firstAttribute: .top, secondAttribute: .bottom)
        orderTotalTextField.addConstraintWidth(width: contentBox.frame.size.width * 0.55)
        orderTotalTextField.addConstraintHeight(height: orderTotalTextField.frame.size.height)
        
        priceDescriptionTextField.addConstraintLeft(leftOffset: 2, firstAttribute: .leading, secondAttribute: .leading, toItem: orderSummaryItemBox)
        priceDescriptionTextField.addConstraintTop(topOffset: 5, toItem: orderTotalTextField, firstAttribute: .top, secondAttribute: .bottom)
        priceDescriptionTextField.addConstraintWidth(width: contentBox.frame.size.width * 0.55)
        priceDescriptionTextField.addConstraintHeight(height: priceDescriptionTextField.frame.size.height)
        
        buttonLogOut.addConstraintLeft(leftOffset: 30, firstAttribute: .leading, secondAttribute: .leading, toItem: orderSummaryItemBox)
        buttonLogOut.addConstraintTop(topOffset: 15, toItem: priceDescriptionTextField, firstAttribute: .top, secondAttribute: .bottom)
        buttonLogOut.addConstraintRight(rightOffset: -30, toItem: orderSummaryItemBox)
        buttonLogOut.addConstraintHeight(height: 40)
        buttonLogOut.addConstraintBottom(topOffset: -30, toItem: parent, firstAttribute: .bottom, secondAttribute: .bottom)
        /** constraint  values **/
        /** titulo **/
        
        
        subtotalValueTextField.addConstraintTop(topOffset: 5, toItem: titleTextField, firstAttribute: .top, secondAttribute: .bottom)
        subtotalValueTextField.addConstraintWidth(width: contentBox.frame.size.width * 0.40)
        subtotalValueTextField.addConstraintHeight(height: subTotalTextField.frame.size.height)
        subtotalValueTextField.addConstraintRight(rightOffset: -2, toItem: orderSummaryItemBox)
        
        admFeeValueTextField.addConstraintRight(rightOffset: -2, toItem: orderSummaryItemBox)
        admFeeValueTextField.addConstraintTop(topOffset: 5, toItem: subTotalTextField, firstAttribute: .top, secondAttribute: .bottom)
        admFeeValueTextField.addConstraintWidth(width: contentBox.frame.size.width * 0.40)
        admFeeValueTextField.addConstraintHeight(height: admFeeTextField.frame.size.height)
        
        taxesValueTextField.addConstraintRight(rightOffset: -2, toItem: orderSummaryItemBox)
        taxesValueTextField.addConstraintTop(topOffset: 5, toItem: admFeeTextField, firstAttribute: .top, secondAttribute: .bottom)
        taxesValueTextField.addConstraintWidth(width: contentBox.frame.size.width * 0.40)
        taxesValueTextField.addConstraintHeight(height: taxesTextField.frame.size.height)
        
        shippingCostValueTextField.addConstraintRight(rightOffset: -2, toItem: orderSummaryItemBox)
        shippingCostValueTextField.addConstraintTop(topOffset: 5, toItem: taxesTextField, firstAttribute: .top, secondAttribute: .bottom)
        shippingCostValueTextField.addConstraintWidth(width: contentBox.frame.size.width * 0.40)
        shippingCostValueTextField.addConstraintHeight(height: shippingCostTextField.frame.size.height)
        
        multipleProductValueTextField.addConstraintRight(rightOffset: -2, toItem: orderSummaryItemBox)
        multipleProductValueTextField.addConstraintTop(topOffset: 5, toItem: shippingCostTextField, firstAttribute: .top, secondAttribute: .bottom)
        multipleProductValueTextField.addConstraintWidth(width: contentBox.frame.size.width * 0.40)
        multipleProductValueTextField.addConstraintHeight(height: multipleProductTextField.frame.size.height)
        
        //order total
        orderTotalValueTextField.addConstraintRight(rightOffset: -2, toItem: orderSummaryItemBox)
        orderTotalValueTextField.addConstraintTop(topOffset: 5, toItem: divideLine, firstAttribute: .top, secondAttribute: .bottom)
        orderTotalValueTextField.addConstraintWidth(width: contentBox.frame.size.width * 0.40)
        orderTotalValueTextField.addConstraintHeight(height: orderTotalValueTextField.frame.size.height)
    }
    
    
}
