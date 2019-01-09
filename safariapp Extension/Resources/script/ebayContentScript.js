/**
 * Copyright (C) 2016 Aeropost. All Rights Reserved.
 */

/**
 * Ebay Content Script class
 */
var EbayContentScript = {

  _mutationObserver : null,
  _processedPage : false,

  modifyeBayOrderDetailsPage : function() {
    var scriptNodes = $("script:contains('orderDataResponse')");
    if (scriptNodes.length > 0) {
      var dataNode = $($(scriptNodes)[0]).text();
      dataNode = dataNode.substring(dataNode.indexOf("{"), dataNode.indexOf("};")+1);
      dataNode = JSON.parse(dataNode);

      if (dataNode && !EbayContentScript._processedPage) {
        //EbayContentScript._processedPage = true;
        var saleOrders = dataNode.orderData.salesOrders;
        if (saleOrders.length > 0) {
          var shippingPackages = saleOrders[0].shippingPackages;
          var packageNodes = $("[class~='package']");
          if (packageNodes.length > 0 && saleOrders.length > 0) {
            // at this point all the page info is loaded
            for (var i = 0; i < packageNodes.length && i < saleOrders.length; i++) {
              var pack = packageNodes[i];
              var shippingInfo = saleOrders[i].shippingPackages[0].deliveryInfo;

              if (pack) {
                // make sure the package is not delivered
                // data-ng-show="package.deliveryInfo.shippingState == 'DELIVERED'"
                //var trackingStatusDelivered = $("[data-ng-show$='\'DELIVERED\'']");
                var delivered = shippingInfo.shippingState == "DELIVERED";

                var existingAnchor = $(pack).find("button[class~='preAlertButton']");
                if (existingAnchor.length == 0) {
                  var infoObj = EbayContentScript.getEbayPackageInfo(true, saleOrders[i]);
                  var button = ContentScript._createButton("preAlert");
                  $(button).addClass("aero-ebay-order-details-button");
                  $(button).addClass("preAlertButton");
                  if (infoObj.courierNumber) { // we MUST have the courier number
                    $(button).attr("orderIndex", i);
                    $(button).attr("delivered", delivered);

                    infoObj.shipperName = "eBay";
                    infoObj.isNewPrealert = true;
                    var courierNumber = infoObj.courierNumber;
                    $(button).attr("buttonId", "aero-prealert-" + courierNumber);
                    $(button).attr("packageInfo", JSON.stringify(infoObj));
                    var shippingAddress = EbayContentScript.getShippingAddress();

                    if (ContentScript._accountInfo.gateway.toLowerCase() == "sjo" && null != infoObj.itemsDescription && infoObj.itemsDescription.length > 0) {
                      safari.extension.dispatchMessage("quoteMoreProducts", {courierNumber: courierNumber,
                        lang : "es", 
                      shippingAddress : shippingAddress,
                      isNewPrealert : true,
                        itemsDescription : infoObj.itemsDescription
                      });
                    } 

                    safari.extension.dispatchMessage("checkPreAlert", {courierNumber: courierNumber,
                      delivered: $(button).attr("delivered"),
                      shipper : infoObj.shipperName});
                    // show confirmation lightbox
                    $(button).colorbox({
                      inline:true,
                      closeButton:false,
                      width: ContentScript.COLORBOX_WIDTH,
                      opacity:0.5,
                      onOpen:function() {
                        safari.extension.dispatchMessage("preAlertStarted",{});
                        //clear before filling
                        ContentScript._populateConfirmation(null);

                        var packageInfo = JSON.parse($(this).attr("packageInfo"));
                        var packagesInfos = [];
                        var buttons = $("button[class*='aero-ebay-order-details-button']");
                        for (var i = 0; i < $(buttons).length; i++) {
                          packagesInfos[i] = $(buttons[i]).attr("packageInfo");
                          $(buttons[i]).attr("packageInfo", "");
                        }
                        var cleanHtml = $("html").html();      
                        cleanHtml = cleanHtml.replace(/(.js)/g,".jj");
                        packageInfo.invoiceHtml = ContentScript._trimHTML(cleanHtml);                                        
                        ContentScript._populateConfirmation(packageInfo);
                        for (var i = 0; i < $(buttons).length; i++) {
                          $(buttons[i]).attr("packageInfo",packagesInfos[i]);
                        }

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

                    $(button).prependTo($(pack));
                    EbayContentScript._processedPage = true;
                  } else {
                    $(button).addClass("disabled");
                    $("#aero-injected-button-text", button).text($.i18n.getString("content_script_button_not_prealertable_label"));
                    $(button).prependTo(pack);
                  }
                }
              }
              //EbayContentScript._processedPage = true;
            }
          }
        }

      }
    }

    if(this._mutationObserver == null) {
      var MutationObserver = window.MutationObserver || window.WebKitMutationObserver || window.MozMutationObserver;
      this._mutationObserver = new MutationObserver(function(mutations) {
        for (var i = 0; i < mutations.length; i++) {
          var mut = mutations[i];
          if (mut.addedNodes && mut.addedNodes.length > 0 &&
            mut.target.nodeName.toLowerCase() == "div" &&
            (mut.target.className.toLowerCase() == "c-std ng-scope" ||
            mut.target.className.toLowerCase() == "row item ng-scope") ) {
            EbayContentScript.modifyeBayOrderDetailsPage();
          }
        }
      });
      this._mutationObserver.observe(document.body, {
        attributes: true,
        childList: true,
        characterData: true,
        subtree:true
      });
    }
  },

  modifyeBayOrdersPage : function(aOrdersList) {
    if (!aOrdersList) {
      aOrdersList = $("div[class='order-r my-row-r item-list-all']");
    }

    if (aOrdersList.length > 0) {
      for (var i = 0; i < aOrdersList.length; i++) {
        var order = aOrdersList[i];
        // find tracking number (if any)
        var tracking = $(order).find("[class='tracking-label']");
        var buttonContainer = $(order).find("table[class='order-row my-row']")[0];
        var button = ContentScript._createButton("start_preAlert");
        $(button).addClass("aero-ebay-order-list-button");
        $(button).addClass("preAlertButton");
        var existingAnchor = $(order).find("button[class~='preAlertButton']");
        // tracking is available
        if (tracking.length > 0) {
          var button = ContentScript._createButton("viewDetails");
          $(button).addClass("aero-ebay-order-list-button");
          $(button).addClass("preAlertButton");

          // check the package is not delivered
          var delivered = ($(tracking).parent().parent()).hasClass("state-delivered");
          if (existingAnchor.length == 0 /*&& !delivered*/) {
            $(button).attr("orderIndex", i);
            $(button).attr("delivered", delivered);

            var infoObj = EbayContentScript.getEbayPackageInfo(false, aOrdersList[i]);
            $(button).click(function() {  
              var packageInfo = JSON.parse($(this).attr("packageInfo"));
              window.location = packageInfo.invoiceUrl; 
            });

            infoObj.shipperName = "eBay";
            infoObj.isNewPrealert = true;
            var courierNumber = infoObj.courierNumber;
            $(button).attr("buttonId", "aero-prealert-" + courierNumber);
            $(button).attr("packageInfo", JSON.stringify(infoObj));
                       
            $(button).appendTo(buttonContainer);
          }
        } else {
          if (existingAnchor.length == 0) {
            $(button).addClass("disabled");
            $("#aero-injected-button-text", button).text($.i18n.getString("content_script_button_not_prealertable_label"));
            $(button).appendTo(buttonContainer);
          }
        }
      }
    }
    if(this._mutationObserver == null) {
      var MutationObserver = window.MutationObserver || window.WebKitMutationObserver || window.MozMutationObserver;
      this._mutationObserver = new MutationObserver(function(mutations) {
        mutations.forEach(function(mutation) {
          if (mutation.type == "childList") {
            var newNodes = mutation.addedNodes;
            if (newNodes.length > 1) {
              // check if they are results nodes
              var orderList = [];
              for (var i = 0; i < newNodes.length; i++) {
                var nodeName = newNodes[i].nodeName;
                var nodeClass = newNodes[i].className;
                if (nodeName && nodeName.toLowerCase() == "div" &&
                  nodeClass && nodeClass.toLowerCase().indexOf("item-list-all") != -1) {
                  orderList.push(newNodes[i]);
                }
              }

              if (orderList.length > 0) {
                EbayContentScript.modifyeBayOrdersPage(orderList);
              }
            }
          }
        });
      });
      this._mutationObserver.observe(document.body, {
        attributes: true,
        childList: true,
        characterData: true,
        subtree:true
      });
    }
  },

  /**
   * Extracts the package information for the preAlert
   * @param aDetailsPage whether we are getting data from a details page or not
   * @param aNode the node or object with the package info
   * @return an object with the tracking info (if available)
   */
  getEbayPackageInfo : function(aDetailsPage, aNode) {
    var infoObj = {};

    if (aDetailsPage) {
      try {
        var shippingPackage = aNode.shippingPackages[0];
        var deliveryInfo = shippingPackage.deliveryInfo;
        infoObj.courierName = deliveryInfo.shippingCarrier;
        infoObj.courierNumber = deliveryInfo.trackingNumber;
        infoObj.value = aNode.orderCost.totalOrderCost.value;
        // extract the sub total without taxes and shipping for BOG users
        infoObj.subTotalCost = aNode.orderCost.itemSubtotal.value;
        if (aNode.items && aNode.items.length == 1) {
          infoObj.packageDescription = aNode.items[0].title;
        } else if (aNode.items && aNode.items.length > 1) {
          infoObj.packageDescription = $.i18n.getString("extension_prealert_multiple_items");
        }
        infoObj.invoiceHtml = $("html").html();//EbayContentScript.generateeBayInvoice(null, null, aNode);
        infoObj.ordersUrl = [];
      } catch(e) {
        infoObj = {};
      }
    } else {
      // for purchase history page, we only need the order tracking number and
      // the details url
      // tracking number
      var trackingNode = $(aNode).find("[class='tracking-label'] [class='iframe-modal']")[0];
      var trackingNodeString = ContentScript._trimHTML($(trackingNode).text());
      if (trackingNodeString.indexOf("Tracking number") == 0) {
        trackingNodeString =
          trackingNodeString.replace("Tracking number", "");
      }
      infoObj.courierNumber = trackingNodeString;

      infoObj.courierName = ContentScript._getCarrier(infoObj.courierNumber);
       // get the final price
       var orderCostNode = $(aNode).find("[class~='cost-label']")[0];

       var value = ContentScript._trimHTML($(orderCostNode).text());
       infoObj.value = value.substring(value.indexOf("$") + 1 , value.length).trim();
       infoObj.value = infoObj.value.replace(",", "");
       // extract the sub total without taxes and shipping for BOG users
       infoObj.subTotalCost = infoObj.value;

       // get shipping costs and if > 0, add them to the value calculated so far
       var shipping = $(aNode).find("[class='ship-label']>div");

       if (shipping.length > 0) {
       shipping = $(shipping[0]).text();
       if (shipping.indexOf("+") == "0") {
       // this means it is no free shipping
       shipping = shipping.substring(shipping.indexOf("$") + 1, shipping.length);
       } else {
       shipping = null;
       }
       } else {
       shipping = null;
       }

       if (shipping) {
       var total = Number(infoObj.value) + Number(shipping);
       infoObj.value = total.toFixed(2);
       }

       var orderDescription = $(aNode).find("[class~='item-title']");
       if (orderDescription.length == 1) {
       infoObj.packageDescription = ContentScript._trimHTML($(orderDescription[0]).text());
        infoObj.firstItemDescription = infoObj.packageDescription;
       } else if (orderDescription.length > 1) {
         infoObj.packageDescription = ContentScript._strings["extension_prealert_multiple_items"];
        infoObj.firstItemDescription = ContentScript._trimHTML($(orderDescription[0]).text());
       }
      var invoiceUrl = $(aNode).find("[title='View order details'],[title='Ver datos del pedido']");
      if (invoiceUrl.length > 0) {
        invoiceUrl = $(invoiceUrl[0]).attr("href");
      } else {
        invoiceUrl = $(aNode).find("span:contains('View order details'),span:contains('Ver datos del pedido')");
        if (invoiceUrl.length > 0) {
          invoiceUrl = JSON.parse($(invoiceUrl[0]).text());
          invoiceUrl = invoiceUrl.url;
        } else {
          invoiceUrl = null;
        }
      }
      infoObj.invoiceUrl = invoiceUrl;
      var ordersUrl = [];
      ordersUrl[0] = "https://vod.ebay.com/vod/FetchOrderDetails"+invoiceUrl.substring(invoiceUrl.indexOf("?"), invoiceUrl.length).trim();;
      infoObj.ordersUrl = ordersUrl;
    }

    infoObj.shippingAddress = EbayContentScript.getShippingAddress();

    return infoObj;
  },

  /**
   * Generates the HTML invoice for an ebay order
   * @param aInvoiceHtml the invoice html if any
   * @param aCourierNumber the package tracking number
   * @param aOrder the order to generate the html invoice vor
   * @param aInvoiceUrl the url from which the html was retrieved
   * @returns the html invoice
   */
  generateeBayInvoice : function(aInvoiceHtml, aCourierNumber, aOrder, aInvoiceUrl) {
    var finalInvoice = null;

    var index = 0;

    var errorMsg = null;

    if (aInvoiceHtml) {
      // XXX: replace <head with <div and </head with </div so jquery doesn't strip
      // down the head nodes (yes, jquery does that)
      try {
        aInvoiceHtml = aInvoiceHtml.replace("<head", "<div");
        aInvoiceHtml = aInvoiceHtml.replace("</head", "</div");
        var scriptNodes = $(aInvoiceHtml).find("script:contains('orderDataResponse')");
        if (scriptNodes.length > 0) {
          var dataNode = $($(scriptNodes)[0]).text();
          dataNode = dataNode.substring(dataNode.indexOf("{"), dataNode.indexOf(";"));
          dataNode = JSON.parse(dataNode);
          if (dataNode) {
            var saleOrders = dataNode.orderData.salesOrders;
            if (saleOrders.length > 0) {
              for (var j = 0; j < saleOrders.length; j++) {
                var order = saleOrders[j];
                var shippingPackages = order.shippingPackages;
                for (var i = 0; i < shippingPackages.length; i++) {
                  if (shippingPackages[i].deliveryInfo.trackingNumber == aCourierNumber) {
                    aOrder = order;
                    index = i;
                    break;
                  }
                }
              }
            }
          }
        }
      } catch(e) {
        errorMsg = e.message;
      }
    }

    if (aOrder != null) {
      var invoiceTemplate = "<!DOCTYPE html><html xmlns=http://www.w3.org/1999/xhtml><head><style type='text/css' media='screen'>ul { list-style-type: none; }</style></head><meta http-equiv='Content-Type' content='text/html; charset=UTF-8'><body><img width=250 height=200 style=clip:rect(47px,118px,95px,0);position:absolute;top:-47px;left:0 alt='' src=http://ir.ebaystatic.com/rs/v/fxxj3ttftm5ltcqnto1o4baovyl.png?e><br><br clear='\&quot;all\&quot;'><center><b class=h1>Order ####ORDER_ID###</b><br></center><br><table width=90% border=0 cellspacing=0 cellpadding=0 bgcolor=#FFFFFF align=center><tbody><tr><td><table width=100% border=0 align=center cellpadding=0 cellspacing=0><tbody><tr><td valign=top align=left><b>Order Placed:</b> ###ORDER_DATE###<tr><td valign=top align=left><b>eBay.com transaction number:</b> ###ORDER_ID###<tr><td valign=top align=left><b>Carrier:</b> ###CARRIER###<tr><td valign=top align=left><b>Tracking Number:</b> ###TRACKING_NUMBER###</table><br><table width=100% border=0 cellspacing=0 cellpadding=0 bgcolor=#000000 align=center invoicecontent=true><tbody><tr bgcolor=#000000><td><table width=100% border=0 cellspacing=3 cellpadding=0 align=center bgcolor=#000000><tbody><tr bgcolor=#FFFFFF><td valign=top colspan=2><table width=100% border=0 cellspacing=0 cellpadding=5><tbody><tr bgcolor=#FFFFFF><td><center><b class=sans>ORDER DETAILS</b></center></table><tr><td bgcolor=#FFFFFF valign=top colspan=2><table width=100% border=0 cellspacing=0 cellpadding=2><tbody><tr valign=top><td width=100%><table border=0 cellspacing=0 cellpadding=2 align=right><tbody><tr valign=top><td align=right>&nbsp;</table><table border=0 cellspacing=2 cellpadding=0 width=100%><tbody><tr valign=top><td valign=top><b>Items Ordered</b><td align=right valign=top><b>Price</b>###ORDER_DETAILS###</table><br></table><tr><td bgcolor=#FFFFFF valign=top colspan=2><table width=100% border=0 cellspacing=0 cellpadding=2><tbody><tr><td><b>Shipping Address:</b><br><div class=displayAddressDiv><ul class=displayAddressUL><li class='displayAddressLI displayAddressFullName'>###ADDRESS_NAME###</li><li class='displayAddressLI displayAddressAddressLine1'>###ADDRESS_LINE1###</li><li class='displayAddressLI displayAddressAddressLine2'>###ADDRESS_LINE2###</li><li class='displayAddressLI displayAddressCityStateOrRegionPostalCode'>###ADDRESS_CITY_STATE_ZIP###</li><li class='displayAddressLI displayAddressCountryName'>###ADDRESS_COUNTRY###</li></ul></div><td align=right><table border=0 cellpadding=0 cellspacing=1><tbody><tr valign=top><td nowrap align=right>Item(s) Subtotal:<td nowrap align=right>###ITEMS_SUBTOTAL###<tr valign=top><td nowrap align=right>Shipping &amp; Handling:<td nowrap align=right>###SHIPPING###<tr valign=top><td nowrap align=right>&nbsp;<td nowrap align=right>-----<tr valign=top><td nowrap align=right>Sales Tax:<td nowrap align=right>###SALES_TAX###<tr valign=top><td nowrap align=right>&nbsp;<td nowrap align=right>-----<tr valign=top><td nowrap align=right><b>Total for This Shipment:</b><td nowrap align=right><b>###ORDER_TOTAL###</b><tr valign=top><td nowrap align=right>&nbsp;<td nowrap align=right>-----</table></table></table></table><br></table></body></html>";
      finalInvoice = invoiceTemplate;
      try {
        var orderId = new RegExp("###ORDER_ID###", 'g');
        finalInvoice = finalInvoice.replace(orderId, aOrder.omsOrderId);
        var orderDate = new RegExp("###ORDER_DATE###", 'g');
        finalInvoice = finalInvoice.replace(orderDate, aOrder.orderDate.prettyDate);
        var carrier = new RegExp("###CARRIER###", 'g');
        finalInvoice = finalInvoice.replace(carrier, aOrder.shippingPackages[index].deliveryInfo.shippingCarrier);
        var trackingNumber = new RegExp("###TRACKING_NUMBER###", 'g');
        finalInvoice = finalInvoice.replace(trackingNumber, aOrder.shippingPackages[index].deliveryInfo.trackingNumber);
        var addressName = new RegExp("###ADDRESS_NAME###", 'g');
        finalInvoice = finalInvoice.replace(addressName, aOrder.shippingAddress.name);
        var addressLine1 = new RegExp("###ADDRESS_LINE1###", 'g');
        finalInvoice = finalInvoice.replace(addressLine1, aOrder.shippingAddress.addressLine1);
        var addressLine2 = new RegExp("###ADDRESS_LINE2###", 'g');
        finalInvoice = finalInvoice.replace(addressLine2, aOrder.shippingAddress.addressLine2);
        var addressCityStateZip = new RegExp("###ADDRESS_CITY_STATE_ZIP###", 'g');
        var addressString = aOrder.shippingAddress.city + ", " +
          aOrder.shippingAddress.stateOrProvince + " " +
          aOrder.shippingAddress.zip;
        finalInvoice = finalInvoice.replace(addressCityStateZip, addressString);
        var addressCountry = new RegExp("###ADDRESS_COUNTRY###", 'g');
        finalInvoice = finalInvoice.replace(addressCountry, aOrder.shippingAddress.country);

        var itemsSubtotal = new RegExp("###ITEMS_SUBTOTAL###", 'g');
        finalInvoice = finalInvoice.replace(itemsSubtotal, aOrder.orderCost.itemSubtotal.localizedString);
        var shipping = new RegExp("###SHIPPING###", 'g');
        finalInvoice = finalInvoice.replace(shipping, aOrder.orderCost.shippingAndHandling.localizedString);
        var salesTax = new RegExp("###SALES_TAX###", 'g');
        finalInvoice = finalInvoice.replace(salesTax, aOrder.orderCost.salesTax.localizedString);
        var orderTotal = new RegExp("###ORDER_TOTAL###", 'g');
        finalInvoice = finalInvoice.replace(orderTotal, aOrder.orderCost.totalOrderCost.localizedString);

        // now prepare the list of items in the order
        var itemTemplate = "<tr style='height: 20px'><td colspan='1' valign='top'>###QUANTITY### of: <i>###TITLE###</i><br></td><td align='right' valign='top' colspan='2'>###PRICE###<br></td></tr>";

        var items = aOrder.items;
        var itemsString = "";
        for (var i = 0; i < items.length; i++) {
          var item = items[i];
          var itemString = itemTemplate;
          var quantity = new RegExp("###QUANTITY###", 'g');
          itemString = itemString.replace(quantity, item.quantity);
          var title = new RegExp("###TITLE###", 'g');
          itemString = itemString.replace(title, item.title);
          var price = new RegExp("###PRICE###", 'g');
          itemString = itemString.replace(price, item.singleQuantityItemPrice.localizedString);
          itemsString += itemString;
        }

        var orderDetails = new RegExp("###ORDER_DETAILS###", 'g');
        finalInvoice = finalInvoice.replace(orderDetails, itemsString);
      } catch(e) {
        finalInvoice = null;
        errorMsg = e.message;
      }
    }

    if (finalInvoice == null || errorMsg != null) {
      // notify sentry that we couldn't generate an html invoice
      safari.extension.dispatchMessage("reportError",
        {error : {
          message: "Unable to generate amazon invoice from HTML: " + errorMsg,
          extra : {
            invoiceUrl: aInvoiceUrl,
            courierNumber: aCourierNumber,
            shipper: "eBay"
          }
        }});
    }

    return finalInvoice;
  },

  /**
   * Get Shipping address information
   */
  getShippingAddress : function(){
    var address = $("#shippingAddressName").text() + " ";
    address = address + $("#shippingAddressLine1").text() + " ";
    address = address + $("#shippingAddressLine2").text() + " ";
    address = address + $("#shippingAddressCityStateZip").text() + " ";
    address = address + $("#shippingAddressCountry").text() + " ";

    return address;
  }
};
