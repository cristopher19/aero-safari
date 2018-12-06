/**
 * Copyright (C) 2016 Aeropost. All Rights Reserved.
 */

/**
 * Amazon Content Script class
 */
var AmazonContentScript = {
    
    /**
     * Injects the amazon script to get product info
     
    injectAmazonScript : function() {
        var amazonScript = safari.extension.baseURI + "ui/view/siteScripts/amazonScript.js";
        var script = document.createElement('script');
        script.type = "text/javascript";
        script.src = amazonScript;
        
        (document.body || document.head || document.documentElement).appendChild(script);
    },*/
    
    modifyAmazonOrdersPage : function() {
        var orders = $("div[class~='order-info']");
        var ordersLength = orders.length;
        
        if (ordersLength > 0) {
            for (var i = 0; i < ordersLength; i++) {
                var order = orders[i];
                var orderDetails = $(order).parent().find("div[class~='shipment']");
                // massive hack to solve a problem where amazon duplicates the previous package
                // shipping info in packages that don't have any
                var trackingButtonEnabled = $(orderDetails).find("span[class~='track-package-button'][class~='a-button-primary']");
                
                if (trackingButtonEnabled.length > 0 &&
                    ContentScript._isPackageForUser("Amazon", order, false)) {
                    // get the tracking page url
                    var trackingPageUrl = $($(trackingButtonEnabled)[0]).find("a");
                    if (trackingPageUrl.length > 0) {
                        trackingPageUrl = "https://www.amazon.com" + $($(trackingPageUrl)[0]).attr("href");
                        // load package tracking page
                        //var asins = $(order).parent().find("div[class~='a-fixed-left-grid-col'][class~='a-col-right']");
                        AmazonContentScript.processAmazonOrder(trackingPageUrl, i);
                    }
                } else {
                    // the package hasn't been shipped yet (the tracking button is not enabled),
                    // so we display the not prealertable button
                    var existingAnchor = $(order).find("button[class~='preAlertButton']");
                    if (existingAnchor.length == 0) {
                        var button = ContentScript._createButton("preAlert");
                        $(button).addClass("disabled");
                        $("#aero-injected-button-text", button).text($.i18n.getString("content_script_button_not_prealertable_label"));
                        $(button).addClass("preAlertButton");
                        $(button).addClass("aero-amazon-button");
                        $(button).appendTo(order);
                    }
                }
            }
        }
    },
    
    modifyAmazonNewOrdersPage : function() {
        var orders = $("div[class~='order']");
        var ordersLength = orders.length;
        
        if (ordersLength > 0) {
            for (var i = 0; i < ordersLength; i++) {
                var order = orders[i];
                var orderDetails = $(order).find("div[class~='shipment']");
                // massive hack to solve a problem where amazon duplicates the previous package
                // shipping info in packages that don't have any
                var trackingButtonEnabled = $(orderDetails).find("span[class~='track-package-button'][class~='a-button-primary']");
                
                if (trackingButtonEnabled.length > 0 &&
                    ContentScript._isPackageForUser("Amazon", order, false)) {
                    // get the tracking page url
                    var trackingPageUrl = $($(trackingButtonEnabled)[0]).find("a");
                    if (trackingPageUrl.length > 0) {
                        trackingPageUrl = "https://www.amazon.com" + $($(trackingPageUrl)[0]).attr("href");
                        // load package tracking page
                        
                        var asins = $(order).parent().find("div[class~='a-fixed-left-grid-col'][class~='a-col-right']");
                        AmazonContentScript.processAmazonOrder(trackingPageUrl, i, asins);
                    }
                } else {
                    // the package hasn't been shipped yet (the tracking button is not enabled),
                    // so we display the not prealertable button
                    var button = ContentScript._createButton("preAlert");
                    $(button).addClass("disabled");
                    $("#aero-injected-button-text", button).text(chrome.i18n.getMessage("content_script_button_not_prealertable_label"));
                    $(button).addClass("aero-amazon-button");
                    $(button).appendTo(aOrderDetails);
                }
            }
        }
    },
    
    
    processAmazonOrder : function(aTrackingPageUrl, aOrderIndex) {
        var request =
        $.ajax({
               type: "GET",
               url: aTrackingPageUrl,
               jsonp: false,
               timeout: 60 * 1000,
               }).done(function(aData) {
                       
                       //var asins = AmazonContentScript._getAsins(aProducts);
                       
                       var orders = $("div[class~='order-info']");
                       var order = orders[aOrderIndex];
                       
                       var trackingInfoContainer = $($("[class='a-fixed-right-grid-col a-col-right'] [class='a-box']", aData)[1]);
                       var trackingInfoNodes = $(trackingInfoContainer).find("span");
                       var trackingInfo = new Array();
                       for (var i = 0; i < trackingInfoNodes.length; i++) {
                       trackingInfo.push($(trackingInfoNodes[i]).text());
                       }
                       
                       if (trackingInfo.length == 0) {
                       trackingInfoContainer = $("div[id='carrierRelatedInfo-container']", aData);
                       if (trackingInfoContainer.length > 0) {
                       trackingInfo[0] = $("h1:contains('Shipped with')", aData).text();
                       if(trackingInfo[0].length == 0){
                       trackingInfo[0] = $("h1:contains('Enviado con')", aData).text();
                       }
                       
                       trackingInfo[1] = $("a.carrierRelatedInfo-trackingId-text", aData).text();
                       
                       }
                       
                       }
                       
                       // this means we are in the right place and got the tracking info
                       // successfully
                       if (trackingInfo.length == 2 && trackingInfo[1].length > 0) {
                       var courierName = ContentScript._trimHTML(trackingInfo[0]);
                       var courierNumber = ContentScript._trimHTML(trackingInfo[1]);
                       if(courierName.length == 0){
                       courierName = "Other";
                       }
                       
                       if (courierName.length > 0 && courierNumber.length > 0 &&
                           courierNumber.toLowerCase().indexOf("n/a") == -1 &&
                           courierNumber.toLowerCase().indexOf("no tracking number") == -1) {
                       
                       courierName = courierName.replace("Shipped with ","");
                       courierName = courierName.replace("Enviado con ","");
                       courierNumber = courierNumber.replace("Tracking ID ","");
                       courierNumber = courierNumber.replace("Código de rastreo ","");
                       // make sure we get the carrier and tracking #, else don't inyect the button
                       var orderDetails = $(order).parent().find("div[class~='shipment']");
                       
                       var existingAnchor = $(order).find("button[class~='preAlertButton']");
                       if (orderDetails.length > 0 && existingAnchor.length == 0) {
                       var delivered = $($(orderDetails)[0]).hasClass("shipment-is-delivered");
                       
                       var button;
                       // handle multiple shipments order
                       // attribute to recognize orders with multiple shipments
                       //GET NUMBER OF SHIPMENTS IN ORDER
                       //$(button).attr("multipleShipments", trackingDetails.length > 1);
                       // multiple packages, take the user to the order details page
                       if (orderDetails.length > 1) {
                       button = ContentScript._createButton("viewDetails");
                       $(button).addClass("aero-amazon-button");
                       $(button).addClass("preAlertButton");
                       $(button).click(function() {
                                       var orderDetailsNode =
                                       $($($(order).find("div[class~='actions']")[0]).find("ul")[0]).children()[0];
                                       var orderDetailsUrl = "https://www.amazon.com" + $(orderDetailsNode).attr("href");
                                       window.location = orderDetailsUrl;
                                       });
                       } else {
                       button = ContentScript._createButton("preAlert");
                       $(button).addClass("aero-amazon-button");
                       $(button).attr("orderIndex", aOrderIndex);
                       $(button).attr("delivered", delivered);
                       $(button).addClass("preAlertButton");
                       // append tracking number as Id of the button, and send message to
                       // check the tracking number and disable the button if the prealert
                       // already exists
                       var infoObj = {};
                       infoObj.value = AmazonContentScript.getAmazonOrderTotal(order);
                       var descObj = AmazonContentScript.getAmazonPackageDescription(order);
                       infoObj.packageDescription = descObj.packageDescription;
                       infoObj.firstItemDescription = descObj.firstItemDescription;
                       
                       infoObj.invoiceUrl = AmazonContentScript.getAmazonInvoiceUrl(order);
                       
                       infoObj.ordersUrl = AmazonContentScript.getAmazonOrdersUrl(aData);
                       
                       infoObj.courierName = courierName;
                       infoObj.courierNumber = courierNumber;
                       var orderActions = $(order).find("div[class~='actions']");
                       var orderInfoNode = $(orderActions[0]).children()[1];
                       infoObj.shipperName = "Amazon";
                       infoObj.isNewPrealert = true;
                       infoObj.packageDescription = infoObj.firstItemDescription;
                       infoObj.invoice = aData;
                       
                       $(button).attr("buttonId", "aero-prealert-" + courierNumber + "-" + aOrderIndex);
                       $(button).attr("packageInfo", JSON.stringify(infoObj));
                       var address = AmazonContentScript._getShippingAddres(aData);
                       
                       safari.extension.dispatchMessage("checkPreAlert", {courierNumber: courierNumber,
                                                       delivered : $(button).attr("delivered"),
                                                       firstItemDescription : infoObj.firstItemDescription,
                                                       invoiceUrl : infoObj.invoiceUrl,
                                                       orderIndex : aOrderIndex,
                                                       shipper : infoObj.shipperName,
                                                       generateInvoice : true,
                                                       shippingAddress : address,
                                                       isNewPrealert : true,
                                                       generateInvoice : true});
                       
                       // show confirmation lightbox
                       $(button).colorbox({
                                          inline:true,
                                          closeButton:false,
                                          width: ContentScript.COLORBOX_WIDTH,
                                          opacity:0.5,
                                          onOpen:function() {
                                          safari.extension.dispatchMessage("preAlertStarted",{});
                                          var packageInfo = JSON.parse($(this).attr("packageInfo"));
                                          ContentScript._populateConfirmation(packageInfo);
                                          
                                          },
                                          onLoad:function() {
                                          $('html, body').css('overflow', 'hidden'); // page scrollbars off
                                          },
                                          onClosed:function() {
                                          $('html, body').css('overflow', ''); // page scrollbars on
                                          },
                                          onComplete : function() {
                                          $(this).colorbox.resize();
                                          }
                                          });
                       }
                       $(button).appendTo(order);
                       }
                       
                       }
                       } else {
                       // we don't have the tracking info, so the package is not prealertable
                       // at this point
                       var button = ContentScript._createButton("preAlert");
                       $(button).addClass("disabled");
                       $("#aero-injected-button-text", button).text($.i18n.getString("content_script_button_not_prealertable_label"));
                       $(button).addClass("aero-amazon-button");
                       $(button).addClass("preAlertButton");
                       $(button).appendTo(order);
                       }
                       }).fail(function(aXHR, aTextStatus, aError) {
                               console.log("tracking request error: " + aError);
                               });
        
    },
    
    modifyAmazonOrderDetailsPage : function() {
        var orderPackages = $("a[name^='shipped-items']");
        for (var i = 0; i < orderPackages.length; i++) {
            var orderPackage = orderPackages[i];
            
            // inject button if the package has tracking
            var trackingNode = $(orderPackage).find("img[alt^='Track']");
            var status = $($(orderPackage).find("b[class='sans']")[0]).text();
            var buttonContainer = $(trackingNode).parent().parent();
            var existingAnchor = $(buttonContainer).find("button[class~='preAlertButton']");
            if (trackingNode.length > 0 /*&&
                                         status.indexOf("Delivered") == -1*/ && existingAnchor.length == 0 &&
                ContentScript._isPackageForUser("Amazon", orderPackage, true)) {
                
                var button = ContentScript._createButton("preAlert");
                $(button).addClass("aero-amazon-order-details-button");
                $(button).addClass("preAlertButton");
                $(button).attr("orderIndex", i);
                $(button).attr("delivered", status.indexOf("Delivered") != -1);
                
                var infoObj =
                AmazonContentScript.getAmazonPackageInfo(orderPackages[i]);
                infoObj.invoiceUrl =
                AmazonContentScript.getAmazonInvoiceUrl(null, true);
                
                infoObj.shipperName = "Amazon";
                infoObj.isNewPrealert = true;
                var courierNumber = infoObj.courierNumber;
                infoObj.packageDescription = aInfoObj.firstItemDescription;
                $(button).attr("buttonId", "aero-prealert-" + courierNumber);
                $(button).attr("packageInfo", JSON.stringify(infoObj));
                
                safari.extension.dispatchMessage("checkPreAlert", {courierNumber: courierNumber,
                                                delivered : $(button).attr("delivered"),
                                                firstItemDescription : infoObj.firstItemDescription,
                                                invoiceUrl : infoObj.invoiceUrl,
                                                shippingAddress : address,
                                                isNewPrealert : true,
                                                shipper : infoObj.shipperName,
                                                generateInvoice : true});
                // show confirmation lightbox
                $(button).colorbox({
                                   inline:true,
                                   closeButton:false,
                                   width: ContentScript.COLORBOX_WIDTH,
                                   opacity:0.5,
                                   onOpen:function() {
                                   safari.extension.dispatchMessage("preAlertStarted",{});
                                   var packageInfo = JSON.parse($(this).attr("packageInfo"));
                                   ContentScript._populateConfirmation(packageInfo);
                                   },
                                   onLoad:function() {
                                   $('html, body').css('overflow', 'hidden'); // page scrollbars off
                                   },
                                   onClosed:function() {
                                   $('html, body').css('overflow', ''); // page scrollbars on
                                   },
                                   onComplete : function() {
                                   $(this).colorbox.resize();
                                   }
                                   });
                
                $(button).appendTo(buttonContainer);
            } else {
                if (existingAnchor.length == 0) {
                    var containerNode =
                    $($("[class='displayAddressDiv']")[0]).closest("table").parent().
                    parent().prev().find("table");
                    containerNode = $(containerNode).find("td")[0];
                    
                    var button = ContentScript._createButton("preAlert");
                    $(button).addClass("aero-amazon-order-details-button");
                    $(button).addClass("disabled");
                    $("#aero-injected-button-text", button).text($.i18n.getString("content_script_button_not_prealertable_label"));
                    $(button).addClass("preAlertButton");
                    $(button).appendTo(containerNode);
                }
            }
        }
    },
    
    modifyAmazonNewOrderDetailsPage : function() {
        var orderPackages = $("div[class~='shipment']");
        for (var i = 0; i < orderPackages.length; i++) {
            var orderPackage = orderPackages[i];
            
            var trackingButtonEnabled = $(orderPackage).find("span[class~='track-package-button'][class~='a-button-primary']");
            if (trackingButtonEnabled.length > 0 &&
                ContentScript._isPackageForUser("Amazon", orderPackage, true)) {
                // get the tracking page url
                var trackingPageUrl = $($(trackingButtonEnabled)[0]).find("a");
                if (trackingPageUrl.length > 0) {
                    trackingPageUrl = "https://www.amazon.com" + $($(trackingPageUrl)[0]).attr("href");
                    // load package tracking page
                    //var asins = $(orderPackage).find("div[class~='a-fixed-left-grid-col'][class~='a-col-right']");
                    AmazonContentScript.processAmazonOrderDetails(trackingPageUrl, i);
                }
            } else {
                var existingAnchor = $(orderPackage).find("button[class~='preAlertButton']");
                
                if (existingAnchor.length == 0) {
                    var button = ContentScript._createButton("preAlert");
                    $(button).addClass("aero-amazon-order-details-button");
                    $(button).addClass("disabled");
                    $("#aero-injected-button-text", button).text($.i18n.getString("content_script_button_not_prealertable_label"));
                    $(button).addClass("preAlertButton");
                    $(button).prependTo(orderPackage);
                }
            }
        }
    },
    
    processAmazonOrderDetails : function(aTrackingPageUrl, aShipmentIndex) {
        var request =
        $.ajax({
               type: "GET",
               url: aTrackingPageUrl,
               jsonp: false,
               timeout: 60 * 1000,
               }).done(function(aData) {
                       
                       //var asins = AmazonContentScript._getAsins(aProducts);
                       
                       var trackingInfoContainer = $($("[class='a-fixed-right-grid-col a-col-right'] [class='a-box']", aData)[1]);
                       var trackingInfoNodes = $(trackingInfoContainer).find("span");
                       var trackingInfo = new Array();
                       for (var i = 0; i < trackingInfoNodes.length; i++) {
                       trackingInfo.push($(trackingInfoNodes[i]).text());
                       }
                       
                       if (trackingInfo.length == 0) {
                       trackingInfoContainer = $("div[id='carrierRelatedInfo-container']", aData);
                       if (trackingInfoContainer.length > 0) {
                       trackingInfo[0] = $("h1:contains('Shipped with')", aData).text();
                       if(trackingInfo[0].length == 0){
                       trackingInfo[0] = $("h1:contains('Enviado con')", aData).text();
                       }
                       
                       trackingInfo[1] = $("a.carrierRelatedInfo-trackingId-text", aData).text();
                       }
                       
                       }
                       
                       // this means we are in the right place and got the tracking info
                       // successfully
                       if (trackingInfo.length == 2 &&
                           trackingInfo[1].length > 0) {
                       var courierName = ContentScript._trimHTML(trackingInfo[0]);
                       var courierNumber = ContentScript._trimHTML(trackingInfo[1]);
                       if(courierName.length == 0){
                       courierName = "Other";
                       }
                       
                       if (courierName.length > 0 && courierNumber.length > 0 &&
                           courierNumber.toLowerCase().indexOf("n/a") == -1 &&
                           courierNumber.toLowerCase().indexOf("no tracking number") == -1) {
                       
                       courierName = courierName.replace("Shipped with ","");
                       courierName = courierName.replace("Enviado con ","");
                       courierNumber = courierNumber.replace("Tracking ID ","");
                       courierNumber = courierNumber.replace("Código de rastreo ","");
                       
                       // make sure we get the carrier and tracking #, else don't inyect the button
                       var orderPackages =  $("div[class~='shipment']");
                       
                       if (orderPackages.length > 0) {
                       var orderPackage = $(orderPackages)[aShipmentIndex];
                       var infoObj =
                       AmazonContentScript.getAmazonNewPackageInfo(orderPackage);
                       infoObj.courierName = courierName;
                       infoObj.courierNumber = courierNumber;
                       infoObj.invoiceUrl =
                       AmazonContentScript.getAmazonInvoiceUrl(null, true);
                       infoObj.ordersUrl = AmazonContentScript.getAmazonOrdersUrl(aData);
                       //console.log("invoice" + courierNumber + ": " + infoObj.invoiceUrl);
                       
                       infoObj.shipperName = "Amazon";
                       infoObj.isNewPrealert = true;
                       AmazonContentScript.getNewAmazonInvoice(infoObj, aShipmentIndex);
                       
                       }
                       
                       }
                       } else {
                       // we don't have the tracking info, so the package is not prealertable
                       // at this point
                       var orderPackages =  $("div[class~='shipment']");
                       
                       if (orderPackages.length > 0) {
                       var orderPackage = $(orderPackages)[aShipmentIndex];
                       var button = ContentScript._createButton("preAlert");
                       $(button).addClass("disabled");
                       $("#aero-injected-button-text", button).text($.i18n.getString("content_script_button_not_prealertable_label"));
                       $(button).addClass("aero-amazon-order-details-button");
                       $(button).prependTo($(orderPackage));
                       }
                       }
                       }).fail(function(aXHR, aTextStatus, aError) {
                               console.log("tracking request error: " + aError);
                               });
    },
    
    /**
     * Retrieves the order invoice for new amazon order details page, so we can
     * extract the right value for each package
     */
    getNewAmazonInvoice : function(aInfoObj, aShipmentIndex) {
        
        if (aInfoObj.invoiceUrl) {
            var request =
            $.ajax({
                   type: "GET",
                   url: aInfoObj.invoiceUrl,
                   jsonp: false,
                   timeout: 60 * 1000,
                   }).done(function(aData) {
                           
                           var orderValue = ContentScript._getValueFromInvoice(aData, aInfoObj.firstItemDescription);
                           if (orderValue) {
                           aInfoObj.value = orderValue.totalValue;
                           aInfoObj.subTotalCost = orderValue.subTotalCost;
                           }
                           
                           var orderPackages =  $("div[class~='shipment']");
                           
                           if (orderPackages.length > 0) {
                           var orderPackage = $(orderPackages)[aShipmentIndex];
                           var delivered = $(orderPackage).hasClass("shipment-is-delivered");
                           
                           aInfoObj.packageDescription = aInfoObj.firstItemDescription;
                           var existingAnchor = $(orderPackage).find("button[class~='preAlertButton']");
                           
                           if (existingAnchor.length == 0) {
                           var button = ContentScript._createButton("preAlert");
                           $(button).addClass("aero-amazon-order-details-button");
                           $(button).addClass("preAlertButton");
                           $(button).attr("orderIndex", aShipmentIndex);
                           $(button).attr("delivered", delivered);
                           
                           $(button).attr("buttonId", "aero-prealert-" + aInfoObj.courierNumber);
                           $(button).attr("packageInfo", JSON.stringify(aInfoObj));
                           var address = AmazonContentScript._getShippingAddres(aData);
                           
                           var finalHtml =
                           AmazonContentScript.generateAmazonInvoice(aData, aInfoObj.firstItemDescription, aInfoObj.courierNumber, aInfoObj.invoiceUrl);
                           
                           safari.extension.dispatchMessage("checkPreAlert", {
                                                           courierNumber: aInfoObj.courierNumber,
                                                           delivered: $(button).attr("delivered"),
                                                           firstItemDescription: aInfoObj.firstItemDescription,
                                                           invoiceUrl : aInfoObj.invoiceUrl,
                                                           invoiceHtml: finalHtml,
                                                           shippingAddress : address,
                                                           isNewPrealert : true,
                                                           shipper: aInfoObj.shipperName
                                                           });
                           // show confirmation lightbox
                           $(button).colorbox({
                                              inline: true,
                                              closeButton: false,
                                              width: ContentScript.COLORBOX_WIDTH,
                                              opacity: 0.5,
                                              onOpen: function () {
                                              safari.extension.dispatchMessage("preAlertStarted", {});
                                              
                                              var packageInfo = JSON.parse($(this).attr("packageInfo"));
                                              ContentScript._populateConfirmation(packageInfo);
                                              
                                              },
                                              onLoad: function () {
                                              $('html, body').css('overflow', 'hidden'); // page scrollbars off
                                              },
                                              onClosed: function () {
                                              ContentScript._populateConfirmation(null);
                                              $('html, body').css('overflow', ''); // page scrollbars on
                                              },
                                              onComplete: function () {
                                              $(this).colorbox.resize();
                                              }
                                              });
                           
                           $(button).prependTo($(orderPackage));
                           }
                           }
                           }).fail(function(aXHR, aTextStatus, aError) {
                                   console.log("error retrieving the package invoice: " + aError);
                                   });
        }
    },
    
    /**
     * Extracts the Amazon package information for the preAlert
     * @param aOrderNode the order info node to extract the package
     * tracking info from
     * @return an object with the tracking info (if available)
     */
    getAmazonPackageInfo : function(aOrderNode) {
        var infoObj = {};
        var trackingNode = $(aOrderNode).find("img[alt^='Track']")[0];
        // in this case, the carrier and the tracking # come in a sentence, so we
        // should extract the info from it
        var trackingString = $($(trackingNode).parent().parent()).text();
        var multipleUnitsRegex = /^(\d+) of (.*)/;
        
        // e.g "1 package via UPS with tracking number 1Z1Y2E300334122088"
        var carrier =
        trackingString.substring(
                                 trackingString.indexOf("via") + 3,
                                 trackingString.indexOf("with tracking")).trim();
        infoObj.courierName = carrier;
        
        var courierNumber =
        trackingString.substring(
                                 trackingString.indexOf("number") + 6, trackingString.length).trim();
        if (courierNumber.indexOf("\n") != -1) {
            courierNumber = courierNumber.substring(0, courierNumber.indexOf("\n"));
        }
        infoObj.courierNumber = ContentScript._trimHTML(courierNumber);
        
        var orderDetailsNode =
        $(aOrderNode).find("td[valign='top'][bgcolor='#ffffff'][width='100%'][align='right']")[0];
        
        var descriptionNode =
        $(orderDetailsNode).find("div[style='float:left; max-width:500px; margin:0 10px 0 10px;']");
        
        if (descriptionNode.length == 1) {
            infoObj.packageDescription =
            ContentScript._trimHTML($($($(descriptionNode[0]).children()[0]).children()[0]).text());
            var res = multipleUnitsRegex.exec(infoObj.packageDescription);
            if (res) {
                infoObj.packageDescription = res[2];
            }
            infoObj.firstItemDescription = infoObj.packageDescription;
        } else if (descriptionNode.length > 1) {
            infoObj.packageDescription = $.i18n.getString("extension_prealert_multiple_items");
            infoObj.firstItemDescription =
            ContentScript._trimHTML($($($(descriptionNode[0]).children()[0]).children()[0]).text());
            var res = multipleUnitsRegex.exec(infoObj.firstItemDescription);
            if (res) {
                infoObj.firstItemDescription = res[2];
            }
        }
        
        // get the final price
        var orderCostNode =
        $($($(orderDetailsNode).children()[2]).find("td > b"))[1];
        
        var value = ContentScript._trimHTML($(orderCostNode).text());
        infoObj.value = value.substring(value.indexOf("$") + 1, value.length).trim();
        infoObj.value = infoObj.value.replace(",", "");
        
        // extract the sub total without taxes and shipping for BOG users
        infoObj.subTotalCost = infoObj.value;
        
        return infoObj;
    },
    
    /**
     * Extracts the Amazon package information for the preAlert, using the new
     * order details page
     * @param aPackageNode the package info node to extract the info from
     * @return an object with the tracking info (if available)
     */
    getAmazonNewPackageInfo : function(aPackageNode) {
        var infoObj = {};
        var packageDescription = null;
        var firstItemDescription = null;
        var orderDescription = $(aPackageNode).find("div[class='a-fixed-left-grid-col a-col-right']>div[class='a-row']>a[class='a-link-normal']");
        var multipleUnitsRegex = /^(\d+) of (.*)/;
        
        if (orderDescription.length == 1) {
            packageDescription = ContentScript._trimHTML($(orderDescription[0]).text());
            var res = multipleUnitsRegex.exec(packageDescription);
            if (res) {
                packageDescription = res[2];
            }
            firstItemDescription = packageDescription;
        } else if (orderDescription.length > 1) {
            packageDescription = $.i18n.getString("extension_prealert_multiple_items");
            firstItemDescription = ContentScript._trimHTML($(orderDescription[0]).text());
            var res = multipleUnitsRegex.exec(firstItemDescription);
            if (res) {
                firstItemDescription = res[2];
            }
        }
        
        infoObj.packageDescription = packageDescription;
        infoObj.firstItemDescription = firstItemDescription;
        var value = null;
        var valueNode = $(aPackageNode).find("[class~='a-color-price']");
        if (valueNode.length > 0) {
            for (var i = 0; i < valueNode.length; i++) {
                var itemValue = $($(valueNode)[i]).text();
                itemValue = ContentScript._trimHTML(itemValue);
                itemValue = itemValue.substring(itemValue.indexOf("$") + 1, itemValue.length).trim();
                itemValue = itemValue.replace(",", "");
                if (value == null) {
                    value = 0;
                }
                value += Number(itemValue);
            }
        }
        infoObj.value = value;
        
        // extract the sub total without taxes and shipping for BOG users
        infoObj.subTotalCost = infoObj.value;
        
        return infoObj;
    },
    
    /**
     * returns the amazon package description
     * @param aOrderNode the order node to get the package description from
     * @returns the amazon package description
     */
    getAmazonPackageDescription : function(aOrderNode) {
        var descObj = {};
        var orderDescription = $(aOrderNode).parent().find("div[class='a-fixed-left-grid-col a-col-right']>div[class='a-row']>a[class='a-link-normal']");
        var multipleUnitsRegex = /^(\d+) of (.*)/;
        
        if (orderDescription.length == 1) {
            descObj.packageDescription = ContentScript._trimHTML($(orderDescription[0]).text());
            var res = multipleUnitsRegex.exec(descObj.packageDescription);
            if (res) {
                descObj.packageDescription = res[2];
            }
            descObj.firstItemDescription = descObj.packageDescription;
        } else if (orderDescription.length > 1) {
            descObj.packageDescription = $.i18n.getString("extension_prealert_multiple_items");
            descObj.firstItemDescription = ContentScript._trimHTML($(orderDescription[0]).text());
            var res = multipleUnitsRegex.exec(descObj.firstItemDescription);
            if (res) {
                descObj.firstItemDescription = res[2];
            }
        }
        
        return descObj;
    },
    
    /**
     * Extracts the order total from an amazon order
     */
    getAmazonOrderTotal : function(aOrderNode) {
        var totalNode = $(aOrderNode).find("div[class*='a-column a-span2']")[0];
        var totalValue = $($(totalNode).children()[1]).text();
        var value = ContentScript._trimHTML(totalValue);
        value = value.substring(value.indexOf("$") + 1, value.length).trim();
        value = value.replace(",", "");
        return value;
    },
    
    /**
     * Returns the amazon order number
     * @param aOrderNode the order node to get the order number from
     * @param aOrderDetailsPage whether this is an order details page or not
     * @returns the amazon order number
     */
    getAmazonInvoiceUrl : function(aOrderNode, aOrderDetailsPage) {
        var invoiceUrl = null;
        if (!aOrderDetailsPage) {
            var orderActions = $(aOrderNode).find("div[class~='actions']");
            var orderInfoNode = $(orderActions[0]).find("a[class='a-link-normal']");
            var orderId = $(orderInfoNode[0]).attr("href");
            if (orderId) {
                orderId = orderId.substring(orderId.indexOf("&orderID=") + 9, orderId.length);
                invoiceUrl =
                "https://www.amazon.com/gp/css/summary/print.html/ref=od_print_invoice?ie=UTF8&orderID=" + orderId;
            }
        } else {
            var oldFormat = $("a[name^='shipped-items']").length > 0;
            var newFormat = $("#orderDetails").length > 0;
            if (oldFormat) {
                invoiceUrl =
                "https://www.amazon.com" +
                $($("a[name='payment-info']").find("a")[0]).attr("href");
            } else if (newFormat) {
                invoiceUrl =
                "https://www.amazon.com" +
                $($("#a-autoid-0").find("a")[0]).attr("href");
            }
        }
        return invoiceUrl;
    },
    
    /**
     * Returns the amazon orders list
     * @param aOrderNode the order node to get the orders list
     * @returns the amazon orders list
     */
    getAmazonOrdersUrl : function(aOrderNode) {
        var invoiceUrl = [];
        //Obtiene la lista de ordenes
        var ordersContainer = $("div[id='ordersInPackage-container']", aOrderNode).find("a[class='a-link-normal']");
        for(var i = 0; i < ordersContainer.length; i++){
            var url = $(ordersContainer[i]).prop('href');
            if(url.indexOf('orderID=') == -1){
                var start_pos = url.indexOf('oid=') + 4;
                var end_pos = url.indexOf('&',start_pos);
                invoiceUrl[i] = "https://www.amazon.com/gp/css/summary/print.html/ref=od_print_invoice?ie=UTF8&orderID=" + url.substring(start_pos,end_pos);
            }else{
                var start_pos = url.indexOf('orderID=') + 8;
                var end_pos = url.indexOf('&',start_pos);
                invoiceUrl[i] = "https://www.amazon.com/gp/css/summary/print.html/ref=od_print_invoice?ie=UTF8&orderID=" + url.substring(start_pos,end_pos);
            }
            
        }
        
        return invoiceUrl;
    },
    
    /**
     * cleans the printable version of the amazon invoice to remove
     * the unnecesary info
     * @param aInvoiceHTML the invoice html to be processed
     * @param aPackageDescription the package description to be used to clean
     * the invoice
     * @param aCourierNumber the courier number for the shipment we are generating
     * the invoice for
     * @param aInvoiceUrl the url from which the html was retrieved
     * @returns the cleaned invoice
     */
    generateAmazonInvoice : function(aInvoiceHTML, aPackageDescription, aCourierNumber, aInvoiceUrl) {
        var finalHtml = null;
        var errorMsg = null;
        try {
            var cleanHTML = ContentScript._cleanHTML(aInvoiceHTML);
            cleanHTML = $(ContentScript._trimHTML(cleanHTML));
            
            // find the table that contains the item description and
            // remove the rest
            
            // first, get shipment nodes
            var shipmentNodes = $(cleanHTML).find("center:contains('Shipped on')");
            if (shipmentNodes.length > 0) {
                var shipmentTableContainer = $(shipmentNodes[0]).closest("table").parent().closest("table").parent().closest("table").parent();
                var shipmentTables = $(shipmentTableContainer).children("table");
                // the first one is the order summary table node, so we keep it
                // but we remove the order total value from it, because for
                // orders with multiple packages, this will be the value for the
                // entire order, not only the shipment we are interested in
                var summaryNode = shipmentTables[0];
                $($(summaryNode).find("b:contains('Order Total:')")[0]).parent().html("<b>Tracking Number:</b> " + aCourierNumber);
                
                for (var i = 1; i < shipmentTables.length; i++) {
                    // keep the one that contains the first item description
                    // remove the rest
                    var table = shipmentTables[i];
                    
                    // get the whole text and see if the description is contained in it
                    // this helps with special characters
                    var tableText = $(table).text();
                    if (tableText.indexOf(aPackageDescription) == -1) {
                        $(table).remove();
                    } else {
                        $(table).attr("invoiceContent", true);
                    }
                }
                
                finalHtml = "<html>";
                for (var j = 0; j < cleanHTML.length; j++) {
                    var node = cleanHTML[j];
                    if (node.nodeName.toLowerCase() != "script" &&
                        node.nodeName.toLowerCase() != "#comment") {
                        if (node.nodeName.toLowerCase() == "#text") {
                            finalHtml += $(node).text();
                        } else {
                            finalHtml += node.outerHTML;
                        }
                    }
                }
                finalHtml += "</html>";
                
                var resultingHtml = $(finalHtml);
                if ($(resultingHtml).find("[invoiceContent]").length == 0) {
                    // we didn't find any node with the package description
                    // so we set the finalHtml to null
                    finalHtml = null;
                }
            }
            
        } catch(e) {
            errorMsg = e.message;
        }
        
        if (finalHtml == null || errorMsg != null) {
            // notify sentry that we couldn't generate an html invoice
            safari.extension.dispatchMessage("reportError",
                                            {error : {
                                            message: "Unable to generate amazon invoice from HTML: " + errorMsg,
                                            extra : {
                                            invoiceUrl: aInvoiceUrl,
                                            firstItemDescription: aPackageDescription,
                                            courierNumber: aCourierNumber,
                                            shipper: "Amazon"
                                            }
                                            }});
        }
        return finalHtml;
    },
    
    /**
     * Performs a quote on the amazon product page and shows the offer to the user
     * @param productASIN the product ASIN to
     * @param size the currently selected size
     * @param color the currently selected color
     */
    quoteAmazonProduct : function(productASIN, size, color) {
        if ($("#aero-quote-main-container").length) {
            $("#aero-quote-main-container").addClass("disabled");
        }
        
        safari.extension.dispatchMessage("quoteProduct", {message: "quoteProduct",
                                        productASIN : productASIN,
                                        size: size,
                                        color: color});
    },
    
    _getAsins : function(aProducts){
        var asins = null;
        //Se obtiene la lista de asins de todos los productos
        if (null != aProducts && aProducts.length > 0) {
            asins = "";
            var regex = RegExp("(?:/)([a-zA-Z0-9]{10})");
            for (var i = 0; i < aProducts.length; i++) {
                var url = $($(aProducts)[i]).find("a[class~='a-link-normal']").attr("href");
                m = url.match(regex);
                if(m != null && m.length == 2) {
                    asins += m[1];
                }
                if(i+1 < aProducts.length){
                    asins += ",";
                }
            }
        }
        
        return asins;
    },
    
_getShippingAddres: function(aContext){
    var shippingAddress = "";
    
    $(".displayAddressUL", aContext).find("li").each(function( index ) {
                                                     shippingAddress = shippingAddress + $( this ).text() + " ";
                                                     });
    
    if(shippingAddress == ""){
        $("#shippingAddress-container", aContext).find("p").each(function( index ) {
                                                                 shippingAddress = shippingAddress + $( this ).text() + " ";
                                                                 });
    }
    
    return shippingAddress;
}
};

