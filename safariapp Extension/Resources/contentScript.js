/**
 * Copyright (C) 2014 Aeropost. All Rights Reserved.
 */

/**
 * Content script class.
 */
var ContentScript = {
    _mutationObserver : null,
    _processedPage : false,
    _siteList : null,
    _accountInfo : null,
    _checkRecipient : false,
    _page : null,
    _showGuide : true,
    
COLORBOX_WIDTH: 600,
    
    EMPTY_IMAGE_DATA : "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAAiAMIDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD3+iiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKAP//Z",

    /**
     * Initializes the object.
     */
    init : function() {
        var that = this;
       document.addEventListener("DOMContentLoaded", function(event) {
          //TOP BAR effect
          $(window).bind('scroll', function() {
             if($(window).scrollTop() > 200){
                 if($(".barNotification").hasClass("barLeftViewPrice")){
                 $(".barNotification").attr("class", "barNotification barLeftViewPrice barOn");
                 } else {
                 $(".barNotification").attr("class", "barNotification barLeft barOn");
                 }
                 $("#allInclusiveBarId").hide();
                 $("#chevronBar").attr("class", "chevronBarRight");
                 $("#chevronBar").show();
                } else{
                 $("#barLeftViewID").remove();
                 $(".barNotification").attr("class", "barNotification");
                 $("#chevronBar").hide();
                 setTimeout("", 1000);
                 $("#allInclusiveBarId").show();
             }
            });
          //var topUrl = window.top.location.href;
          var url = location.href.toLowerCase();
          // XXX: safari hack to prevent multiple processing of the same page due
          // to iframes
          if (url.indexOf("about:blank") == -1 ) {
            safari.extension.dispatchMessage("processPage",{});
          }
                          
          safari.self.addEventListener("message", function(msgEvent) {
           var url = location.href.toLowerCase();
           if (url.indexOf("about:blank") == -1) {
               var signedIn = msgEvent.message.signedIn;
               var clientAllowed = msgEvent.message.clientAllowed;
               switch (msgEvent.name) {
                   case "processPage":
                        console.log(msgEvent.message)
                       ContentScript._checkRecipient = msgEvent.message.checkRecipient;
                       var firstRunColorboxArray = msgEvent.message.firstRunColorboxArray;
                       if (signedIn && clientAllowed) {
                           ContentScript._accountInfo = signedIn;
                           var injectColorbox = false;
                           if (url.indexOf("amazon") != -1 && url.indexOf("order-history") != -1 &&
                               url.indexOf("signin") == -1 && url.indexOf("ap-prefetch-iframe.html") == -1) {
                               injectColorbox = true;
                               AmazonContentScript.modifyAmazonOrdersPage();
                               if (firstRunColorboxArray[0]) {
                                       ContentScript._page = "amazon";
                               }
                           } else if (url.indexOf("amazon") != -1 &&
                                      url.indexOf("summary/edit.html") != -1 &&
                                      url.indexOf("signin") == -1) {
                               injectColorbox = true;
                               AmazonContentScript.modifyAmazonOrderDetailsPage();
                               if (firstRunColorboxArray[1]) {
                                           ContentScript._page = "amazonDetails";
                               }
                           } else if (url.indexOf("amazon") != -1 &&
                                      url.indexOf("order-details") != -1 &&
                                      url.indexOf("signin") == -1) {
                               injectColorbox = true;
                               var oldFormat = $("a[name^='shipped-items']").length > 0;
                               var newFormat = $("#orderDetails").length > 0;
                               if (oldFormat) {
                                       AmazonContentScript.modifyAmazonOrderDetailsPage();
                               } else if (newFormat) {
                                       AmazonContentScript.modifyAmazonNewOrderDetailsPage();
                               }
                               if (firstRunColorboxArray[1]) {
                                       ContentScript._page = "amazonDetails";
                               }
                           } else if(url.indexOf("ebay") != -1 &&
                                     url.indexOf("fetchorderdetails") != -1 &&
                                     url.indexOf("signin.ebay.com") == -1) {
                               injectColorbox = true;
                               EbayContentScript.modifyeBayOrderDetailsPage();
                                       if (firstRunColorboxArray[3]) {
                                       ContentScript._page = "ebayDetails";
                               }
                           } else if((url.indexOf("my.ebay") != -1 ||
                                      (url.indexOf("www.ebay") != -1 &&
                                       url.indexOf("purchasehistory") != -1) ||
                                      url.indexOf("summary") != -1) &&
                                     url.indexOf("signin.ebay.com") == -1) {
                           injectColorbox = true;
                           // work in all my eBay pages
                           EbayContentScript.modifyeBayOrdersPage();
                           if (firstRunColorboxArray[2]) {
                           ContentScript._page = "ebay";
                           }
                           }   else if (url.indexOf("amazon") != -1 &&
                                        (url.indexOf("/dp/") != -1 || url.indexOf("/gp/product") != -1)) { // amazon pdp to quote
                           ContentScript._loadingPrice();
                           AmazonContentScript.injectAmazonScript();
                           } else if(url.indexOf("login.aeropost.com") != -1) {
                           ContentScript._injectAutoCompleteLoginForm();
                           } else {
                           // check if a potential address page and fill it
                           that.checkPage();
                           }
                           if (injectColorbox) {
                               var existingColorbox = $("#aero-colorbox-container");
                               if (existingColorbox.length == 0) {
                                           that._injectPrealertColorbox();
                               }
                           }
                        }
                   break;
               }
           }
          },false)
        //fin document ready
        });
    },
    
    /**
     * Checks whether the package is being shipped to the currently signed in
     * account
     * @param aPage the page we are checking at (Amazon/eBay/etc)
     * @param aOrder the order to check the shipping address
     * @param aIsOrderDetailsPage whether this is an order details page or not
     * @returns true or false if the package is being shipped to the signed in
     * account or not
     */
    _isPackageForUser : function(aPage, aOrder, aIsOrderDetailsPage) {
        var isForUser = false;
        if (ContentScript._checkRecipient) {
            var recipientNode;
            var recipient = "";
            switch (aPage) {
                case "Amazon":
                    if (!aIsOrderDetailsPage) {
                        recipientNode = $(aOrder).find("div[class~='recipient']");
                        if (recipientNode.length > 0) {
                            recipientNode = $(recipientNode[0]).find("[data-a-popover]");
                            if (recipientNode.length > 0) {
                                recipient = $(recipientNode[0]).attr("data-a-popover").toLowerCase();
                            }
                        }
                    } else {
                        var oldFormat = $("a[name^='shipped-items']").length > 0;
                        var newFormat = $("#orderDetails").length > 0;
                        
                        if (oldFormat) {
                            recipientNode = $(aOrder).find("div[class~='displayAddressDiv']");
                            recipient = $(recipientNode).text().toLowerCase();
                        } else if (newFormat) {
                            recipientNode = $("div[class~='displayAddressDiv']");
                            recipient = $(recipientNode).text().toLowerCase();
                        }
                    }
                    break;
                case "Aeropostale":
                    if (aIsOrderDetailsPage) {
                        recipient = $(aOrder).text().toLowerCase();
                    } else {
                        recipientNode = $(aOrder).find("b:contains('Shipping To')").parent();
                        recipient = $(recipientNode).text().toLowerCase();
                    }
                    break;
                case "Forever21":
                    recipient = $(aOrder).text().toLowerCase();
                    break;
                case "Rakuten":
                    recipientNode = $(aOrder).find("tr[class*='ShippingAddress']");
                    recipient = $(recipientNode).text().toLowerCase();
                    break;
                default:
                    break;
            }
            
            if (recipient.indexOf(ContentScript._accountInfo.gateway.toLowerCase()) != -1 &&
                recipient.indexOf(ContentScript._accountInfo.accountNumber) != -1) {
                isForUser = true;
            }
            
        } else {
            isForUser = true;
        }
        return isForUser;
    },
    
    /**
     * Generates the button to be injected in the pages
     * @param aType the type of button to be injected
     * @return the button to be injected
     */
    _createButton : function(aType) {
        var button = $("<button type='button' class='btn aero-injected-button'>" +
                       "<img />" +
                       "<span id='aero-injected-button-text'>" + $.i18n.getString("content_script_button_" + aType + "_label") + "</span>" +
                       "</button>");
        if (aType == "preAlert") {
            $(button).attr("href", "#aero-inline-content");
        }
        return button;
    },
    
    /**
     * Populates the confirmation colorbox
     * @param aInfoObj an object with the information for the prealert to be confirmed
     */
    _populateConfirmation : function(aInfoObj) {
        if (aInfoObj) {
            $("#aero-colorbox-carrier").text(aInfoObj.courierName);
            $("#aero-colorbox-tracking").text(aInfoObj.courierNumber);
            var desc = aInfoObj.packageDescription;
            if (desc && desc.length > 50) {
                desc = desc.substring(0, 50);
                desc += "...";
            }
            
            $("#aero-colorbox-description").text(desc);
            if (ContentScript._accountInfo.gateway.toLowerCase() == "bog") {
                $("#aero-colorbox-value").text(aInfoObj.subTotalCost);
            } else {
                $("#aero-colorbox-value").text(aInfoObj.value);
            }
            $("#aero-colorbox-container").attr("preAlertInfo", JSON.stringify(aInfoObj));
            $("#aero-colorbox-account").text(ContentScript._accountInfo.gateway + "-" + ContentScript._accountInfo.accountNumber);
        } else {
            $("#aero-colorbox-carrier").text("");
            $("#aero-colorbox-tracking").text("");
            $("#aero-colorbox-description").text("");
            $("#aero-colorbox-value").text("");
            $("#aero-colorbox-container").attr("preAlertInfo", "");
            $("#aero-colorbox-value-title").css("color", "black");
            $("#aero-colorbox-carrier-title").css("color", "black");
            $("#aero-colorbox-tracking-title").css("color", "black");
            $("#aero-colorbox-description-title").css("color", "black");
            
        }
        
        $("[class='aero-colorbox-error-msg']").hide();
        $.colorbox.resize();
        
    },
    
    /**
     * Removes all the \n\r and white spaces from an HTML string
     * @param aHTMLString the html string to be trimmed
     * @returns the trimmed HTML
     */
    _trimHTML : function(aHTMLString) {
        var n = new RegExp("\\n", 'g');
        var r = new RegExp("\\r", 'g');
        var t = new RegExp("\\t", 'g');
        aHTMLString = aHTMLString.replace(n, "");
        aHTMLString = aHTMLString.replace(r, "");
        aHTMLString = aHTMLString.replace(t, "");
        aHTMLString = aHTMLString.replace("  ", "");
        aHTMLString = aHTMLString.trim();
        
        return aHTMLString;
    },
    /**
      * Extracs the shipment value from an invoice
      * @param aInvoiceHtml the invoice to be searched
      * @param aFirstItemDescription the first item description
      * @returns the value of the order
      */
    _getValueFromInvoice : function(aInvoiceHtml, aFirstItemDescription) {
        //console.log("invoice: " + aInvoiceHtml);
        // this prevents problems with descriptions that contain single quotes
        if (aFirstItemDescription.indexOf("'") != -1) {
            aFirstItemDescription = aFirstItemDescription.substring(0, aFirstItemDescription.indexOf("'"));
        }
        
        var valueObj = null;
        
        var itemNode = $("i:contains('" + aFirstItemDescription + "')", aInvoiceHtml);
        if (itemNode.length > 0) {
            // we can check if the shipment contains gift card info and use the
            // actual price of the order, ignoring the gift card value
            var containerTable = $(itemNode[0]).closest("table").parent().closest("table").parent().closest("table");
            var giftCardValue = $(containerTable).find("b:contains('Total paid by Gift Card')");
            if (giftCardValue.length > 0) {
                giftCardValue = $(giftCardValue[0]).parent().next("td").text();
                giftCardValue = giftCardValue.substring(giftCardValue.indexOf("$") + 1, giftCardValue.length).trim();
                giftCardValue = giftCardValue.replace(",", "");
            } else {
                giftCardValue = 0;
            }
            
            var rewardsPoints = $(containerTable).find("b:contains('Total paid by Rewards Points')");
            if (rewardsPoints.length > 0) {
                rewardsPoints = $(rewardsPoints[0]).parent().next("td").text();
                rewardsPoints = rewardsPoints.substring(rewardsPoints.indexOf("$") + 1, rewardsPoints.length).trim();
                rewardsPoints = rewardsPoints.replace(",", "");
            } else {
                rewardsPoints = 0;
            }
            
            var totalValue = $($(containerTable).find("b:contains('Total for This Shipment')")[0]).parent().next("td").text();
            totalValue = totalValue.substring(totalValue.indexOf("$") + 1, totalValue.length).trim();
            totalValue = totalValue.replace(",", "");
            totalValue = Number(totalValue) + Number(giftCardValue) + Number(rewardsPoints);
            valueObj = {};
            valueObj.totalValue = totalValue;
            var subTotalCost = $(containerTable).find("td:contains('Item(s) Subtotal')").last().next("td").text();
            subTotalCost = subTotalCost.substring(subTotalCost.indexOf("$") + 1, subTotalCost.length).trim();
            subTotalCost = subTotalCost.replace(",", "");
            subTotalCost = Number(subTotalCost);
            valueObj.subTotalCost = subTotalCost;
            return valueObj;
        } else {
            
        }
        return null;
    },
    
    /**
     * Removes unnecesary pieces of code from the html
     * @param aHtml the html to be cleaned
     * @returns the cleaned html
     */
    _cleanHTML : function(aHtml) {
        $("script", aHtml).remove();
        return aHtml;
    },
    /**
       * Injects the colorbox for eventual use when the user clicks the prealert
       * button
       */
    _injectPrealertColorbox : function() {
        
        colorBoxContent =
        "<div  id='aero-colorbox-container' style='display:none'>" +
        "<div id='aero-inline-content' style='display:block; width:100%; padding:0;'>" +
        "<div style='display:block; width:100%;'>" +
        "<h2 class='plugHeadingMd' style='padding: 0 15px;'>" + $.i18n.getString("content_script_prealert_confirmation_modal_title") + "</h2>" +
        "<p class='confirmation-lead' style='padding: 0 15px;'>" + $.i18n.getString("content_script_prealert_confirmation_modal_confirm_label") + "</p>";
        
        if (ContentScript._accountInfo.gateway.toLowerCase() == "sjo") {
            var locale = ContentScript._accountInfo.language == "1" ? "en" : "es";
            var urlMyAccount = $.i18n.getString("content_script_prealert_go_to_my_account_url").replace("%S1", locale);
            var url = location.href.toLowerCase();
            width = "100%;";
            if (url.indexOf("ebay") != -1){
                width = "530px;"
            }
            colorBoxContent +=
            "<div style='display:block; width:"+width+" padding: 0 35px; margin-bottom:15px;'>"+
            "<div style='padding: .75rem 1.25rem; margin-bottom: 1rem; border: 1px solid transparent; border-radius: .25rem; background-color: #fcf8e3; border-color: #faf2cc; color: #8a6d3b;'>"+
            "<div style='display:block; width:100%; padding: 0;'>"+
            "<div style='width:75px; float:left;''><div class='alertPrealertIcon'><span>!</span></div></div>"+
            "<div style='width:425px; margin-left:75px; text-align:left;'>"+
            "<div style='font-size:16px; text-align:left;'>" + $.i18n.getString("content_script_prealert_go_to_my_account_exemption") + "</div></div></div>"+
            "<div style='display:block; width:100%; padding: 0; text-align:center; margin-top:10px;'>"+
            "<a type='button' href='http://aeropost.com' class='btn btn-block btn-prealert-aeropost-external'>" + $.i18n.getString("content_script_prealert_go_to_my_account_exemption_cta") + "</a></div></div></div>";
        }
        colorBoxContent +=
        "<p class='confirmation-lead' style='padding: 0 15px;'><strong>" + $.i18n.getString("content_script_prealert_confirmation_modal_account_label") + "</strong> <span id='aero-colorbox-account'></span></p>" +
        "</div>" +
        "<div style='display:block; width:100%;min-height:200px;'>" +
        "<div style='display:inline-block; width:255px; padding-left:15px; float:left;'>" +
        "<div class='panel panel-default' '>" +
        "<div class='panel-heading'>" +
        "<span><strong>" + $.i18n.getString("content_script_prealert_confirmation_modal_carrier_information_title") + "</strong></span>" +
        "</div>" +
        "<div class='panel-body'>" +
        "<p><strong id='aero-colorbox-carrier-title'>" + $.i18n.getString("content_script_prealert_confirmation_modal_carrier_name_label") + "</strong> <span id='aero-colorbox-carrier'></span></p>" +
        "<p><strong id='aero-colorbox-tracking-title'>" + $.i18n.getString("content_script_prealert_confirmation_modal_tracking_number_label") + "</strong> <span id='aero-colorbox-tracking'></span></p>" +
        "</div>" +
        "</div>" +
        "</div>" +
        "<div style='display:inline-block; width:300px; padding-left:15px;'>" +
        "<div class='panel panel-default' >" +
        "<div class='panel-heading'>" +
        "<span><strong>" + $.i18n.getString("content_script_prealert_confirmation_modal_package_information_title") + "</strong></span>" +
        "</div>" +
        "<div class='panel-body'>" +
        "<p><strong id='aero-colorbox-description-title'>" + $.i18n.getString("content_script_prealert_confirmation_modal_description_label") + "</strong> <span id='aero-colorbox-description'></span></p>" +
        "<p><strong id='aero-colorbox-value-title'>" + $.i18n.getString("content_script_prealert_confirmation_modal_value_label") + "</strong> <span id='aero-colorbox-value'></span></p>" +
        "</div>" +
        "</div>" +
        "</div>" +
        "</div>" +
        "<div style='display:block; width:100%;'>" +
        "<br><hr>" +
        "<div class='aero-colorbox-error-msg'>" +
        "<span>" + $.i18n.getString("content_script_prealert_confirmation_missing_data_label") + "</span>" +
        "</div>" +
        "</div>" +
        "<div style='display:block; width:100%; text-align:center;'>" +
        "<div style='display:inline-block; width:200px; margin-right:10px;'>" +
        "<button id='aero-colorbox-cancel' type='button' class='btn btn-block aero-injected-button-clear'>" + $.i18n.getString("content_script_prealert_confirmation_modal_cancel_button") + "</button>"+
        "</div>" +
        "<div style='display:inline-block; width:200px; margin-left:10px;'>" +
        "<button id='aero-colorbox-prealert' type='button' class='btn btn-block aero-injected-button'>" + $.i18n.getString("content_script_prealert_confirmation_modal_prealert_button") + "</button>" +
        "</div>" +
        "</div>" +
        "</div>" +
        "</div>";
        var colorBoxNode = $(colorBoxContent);
        $("body").append(colorBoxNode);
        
        // add click listeners
        $("#aero-colorbox-prealert").click(function(event) {
                                           var preAlertInfo = $("#aero-colorbox-container").attr("preAlertInfo");
                                           if (preAlertInfo && preAlertInfo.length > 0) {
                                           preAlertInfo = JSON.parse(preAlertInfo);
                                           
                                           var showMissingData = false;
                                           if (!preAlertInfo.value || Number(preAlertInfo.value) <= 0) {
                                           showMissingData = true;
                                           $("#aero-colorbox-value-title").css("color", "red");
                                           } else {
                                           $("#aero-colorbox-value-title").css("color", "black");
                                           }
                                           
                                           if (!preAlertInfo.courierName) {
                                           showMissingData = true;
                                           $("#aero-colorbox-carrier-title").css("color", "red");
                                           } else {
                                           $("#aero-colorbox-carrier-title").css("color", "black");
                                           }
                                           
                                           if (!preAlertInfo.courierNumber) {
                                           showMissingData = true;
                                           $("#aero-colorbox-tracking-title").css("color", "red");
                                           } else {
                                           $("#aero-colorbox-tracking-title").css("color", "black");
                                           }
                                           
                                           if (!preAlertInfo.packageDescription) {
                                           showMissingData = true;
                                           $("#aero-colorbox-description-title").css("color", "red");
                                           } else {
                                           $("#aero-colorbox-description-title").css("color", "black");
                                           }
                                           
                                           if (showMissingData) {
                                           $("[class='aero-colorbox-error-msg']").show();
                                           $.colorbox.resize();
                                           } else {
                                           $.colorbox.close();
                                           safari.self.tab.dispatchMessage("preAlert", preAlertInfo);
                                           }
                                           
                                           }
                                           });
        $("#aero-colorbox-cancel").click(function(event) {
                                         $.colorbox.close();
                                         safari.self.tab.dispatchMessage("preAlertCanceled",{});
                                         });
    }
};
ContentScript.init();



