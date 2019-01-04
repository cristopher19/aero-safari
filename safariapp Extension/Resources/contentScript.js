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
                                       
                           console.log("msg name" + msgEvent.name);
               switch (msgEvent.name) {
                                      
                   case "processPage":
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
                           //that.checkPage();
                           }
                           if (injectColorbox) {
                               var existingColorbox = $("#aero-colorbox-container");
                               if (existingColorbox.length == 0) {
                                           that._injectPrealertColorbox();
                               }
                           }
                        }
                   break;
                       case "checkedPreAlert":
                       var info = msgEvent.message;
                       var targetButton =
                       $("[buttonId='aero-prealert-" + info.courierNumber + (info.orderIndex != null ? "-" + info.orderIndex : "") + "']");
                       if (info.preAlerted && targetButton.length > 0) {
                           $(targetButton).addClass("disabled");
                           $(targetButton).removeClass("cboxElement");
                           $("#aero-injected-button-text", targetButton).text($.i18n.getString("content_script_button_prealerted_label"));
                       }
                       // the package has a MIA
                       // make sure the button is no there already
                       if (info.mia) {
                           if (targetButton.length == 1) {
                           $(targetButton).addClass("disabled");
                           $(targetButton).removeClass("cboxElement");
                           $(targetButton).replaceWith(ContentScript._createPackageButton(info));
                           }
                       }else if (!info.preAlerted) {
                           if (info.delivered == "true") {
                               // in this case, we remove the button because the package is
                               // already delivered but the user didn't prealert it and wasn't
                               // handled by Aeropost
                               //$(targetButton).remove();
                               // now we show the NOT PREALERTABLE button
                              // $(targetButton).addClass("disabled");
                              // $("#aero-injected-button-text", targetButton).text($.i18n.getString("content_script_button_not_prealertable_label"));
                              // $(targetButton).removeClass("cboxElement");
                           } else {
                               var invoiceUrl = info.invoiceUrl;
                               var firstItemDescription = info.firstItemDescription;
                               var storedInvoice = info.storedInvoice;
                               if (storedInvoice.length == 0) {
                               // if the package hasn't been prealerted and the invoiceUrl
                               // and item description are present, get the invoiceHtml
                               if (invoiceUrl && firstItemDescription) {
                                       ContentScript._loadOrderInvoice(info.courierNumber, invoiceUrl, firstItemDescription, info.shipper, info.orderIndex);
                               } else {
                                   if (info.generateInvoice) {
                                   // this means we should have had the info to load the order
                                   // invoice but we didn't
                                   // notify sentry that we couldn't load the invoice due to missing data
                                   safari.extension.dispatchMessage("reportError",
                                                                   {error : {
                                                                   message: "Unable to load order invoice due to missing data.",
                                                                   extra : {
                                                                   invoiceUrl: invoiceUrl,
                                                                   firstItemDescription: firstItemDescription,
                                                                   courierNumber: info.courierNumber,
                                                                   shipper: info.shipper
                                                                   }
                                                                   }});
                                   }
                               }
                               } else {
                                   // get value from stored invoice and update the button info
                                   // this is for orders using gift cards
                                   var storedInvoice = JSON.parse(storedInvoice);
                                   if (firstItemDescription) {
                                   ContentScript._checkInvoiceForGiftCards(
                                                                           storedInvoice.invoiceHtml, firstItemDescription, info.courierNumber, info.orderIndex);
                                   }
                               }
                               if (ContentScript._showGuide && ContentScript._page) {
                                   ContentScript._showGuide = false;
                                   ContentScript._showFirstRunGuide(targetButton, ContentScript._page);
                               }
                           }
                       }
                       break;
                       case "showNotification":
                           var info = msgEvent.message;
                            ContentScript.showNotification(info)
                       break;
                       case "reloadCurrentPage":
                      
                       ContentScript.reloadCurrentTab()
                       break;
                       case "changeTrackingDescription":
                           var info = msgEvent.message;
                           var targetButton = $("[buttonId='aero-prealert-" + info.courierNumber + (info.orderIndex != null ? "-" + info.orderIndex : "") + "']");
                           if (targetButton.length > 0) {
                               if(null != info && null != info.description && info.description.length > 0){
                                   var packageInfo = JSON.parse($(targetButton).attr("packageInfo"));
                                   packageInfo.packageDescription = info.description;
                                   $(targetButton).attr("packageInfo", JSON.stringify(packageInfo));
                               }
                           
                           }
                       break;
                       case "showQuoteData":
                           var info = msgEvent.message;
                           ContentScript.showQuoteData(info);
                       break;
                       case "showQuoteAgain":
                            $("#addToCartBtn").text( $.i18n.getString("quote_script_quote_add_again_label") );
                       break;
               }
           }
          },false)
        //fin document ready
        });
    },
    /**
     * Displays quote data returned by the API
     * @param aQuoteData the quote data to be displayed
     */
    showQuoteData : function(aQuoteData) {
        if (aQuoteData != null && aQuoteData.product != null && aQuoteData.product.hcInfo.hc != null) {
            // if it already exists, update it
            if ($("#aero-quote-main-container").length) {
                QuoteScript._updateQuoteDiv(aQuoteData.product);
                $("#aero-quote-main-container").removeClass("disabled");
            } else {
                // create quote node and inject it
                var quoteDiv = QuoteScript._createQuoteDiv(aQuoteData.product);
                $("body").append(quoteDiv);
            }
            
        }  else {
            // change top bar:
            //remove loading gif
            $(".sk-fading-circle").remove();
            //Show new mesagge
            $(".blueTextLabel_new").text($.i18n.getString("quote_script_quote_view_all_inclusive_price_message"));
            $("#quoteBtn").show();
            // no product, remove the quote div
            $("#aero-quote-main-container").remove();
            
        }
    },
    /**
     * Reloads the current tab
     */
    reloadCurrentTab : function() {
       location.reload();
    },
    _loadingPrice : function(){
        
        
        $("<div class='barNotification'>" +
          "<div> " +
          "<div class='aIconBluBar'>" +
          "<div class='iconAeropost'></div>"+
          "</div>" +
          "<!-- the class apRightBubble makes visible the all inclusive cont -->" +
          "<div id='allInclusiveBarId' class='allInclusiveContBar' ><span class='labelSm_new blueTextLabel_new'>" + $.i18n.getString("quote_script_quote_calculete_price") + "</span>" +
          "<button id='quoteBtn' style='display:none'>" + $.i18n.getString("quote_script_quote_aeropost_com_button") + "</button>" +
          "<div class='sk-fading-circle'>" +
          "<div class='sk-circle1 sk-circle'></div>" +
          "<div class='sk-circle2 sk-circle'></div>" +
          "<div class='sk-circle3 sk-circle'></div>" +
          "<div class='sk-circle4 sk-circle'></div>" +
          "<div class='sk-circle5 sk-circle'></div>" +
          "<div class='sk-circle6 sk-circle'></div>" +
          "<div class='sk-circle7 sk-circle'></div>" +
          "<div class='sk-circle8 sk-circle'></div>" +
          "<div class='sk-circle9 sk-circle'></div>" +
          "<div class='sk-circle10 sk-circle'></div>" +
          "<div class='sk-circle11 sk-circle'></div>" +
          "<div class='sk-circle12 sk-circle'></div>" +
          "</div></div>" +
          "<div id='chevronBar' class='chevronBarRight' style='display:none'></div>" +
          "</div>" +
          "</div>").insertBefore("body");
        
        $("#chevronBar").click(function(event){
                               $("#barLeftViewID").remove();
                               $(".barNotification").attr("class", "barNotification barLeft barOff");
                               $("#chevronBar").attr("class", "chevronBarLeft");
                               $("#allInclusiveBarId").show();
                               });
        
        $("#quoteBtn").click(function(event){
                             safari.extension.dispatchMessage("SearchURL", {url : window.location.href});
                             });
        
        $("body").attr("style","margin-top:30px!important;");
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
                                           
                                           setTimeout(function() {
                                                      var invoices = [];
                                                      preAlertInfo.invoiceData = invoices;
                                                      
                                                      preAlertInfo.descriptions = [];
                                                      preAlertInfo.descriptions[0] = preAlertInfo.packageDescription.substring(0, 100);
                                                      //Se obtienen todas las facturas para enviarlas
                                                      for(var i = 0; i < preAlertInfo.ordersUrl.length; i++){
                                                          var inv = ContentScript._getInvoiceByUrlHTML(preAlertInfo.ordersUrl[i]);
                                                          var decoded  = ContentScript._decodeHTMLEntities(inv);
                                                          preAlertInfo.invoiceData[i] = $.base64.btoa(decoded, true);
                                                          if(preAlertInfo.ordersUrl.length > 1){
                                                              var description = $("div[class='a-fixed-left-grid-inner']", inv).find("a[class='a-link-normal']");
                                                              preAlertInfo.descriptions[i] = $(description[0]).text();
                                                          }
                                                      }
                                                      $.colorbox.close();
                                                      safari.extension.dispatchMessage("preAlert", preAlertInfo);
                                                      }, 0 | Math.random() * 100);
                                           
                                           
                                          
                                           }
                                           
                                           }
                                           });
        $("#aero-colorbox-cancel").click(function(event) {
                                         $.colorbox.close();
                                         safari.extension.dispatchMessage("preAlertCanceled",{});
                                         });
    },
    
    /**
     * Gets the invoice html
     * @param aUrl the invoice url
     * @param aCallback the callback to be called on return
     */
    _getInvoiceByUrlHTML : function(aUrl) {
        var cleanHtml = null;
        
        var request =
        $.ajax({
               async:false,
               type: "GET",
               url: aUrl,
               jsonp: false,
               timeout: 60 * 1000,
               contentType: "application/x-javascript; charset:ISO-8859-1",
               }).done(function(aData) {
                       cleanHtml = ContentScript._cleanHTML(aData);
                       cleanHtml = ContentScript._trimHTML(cleanHtml)
                       }).fail(function(aXHR, aTextStatus, aError) {
                               console.log("Error retrieving the invoice HTML: Status: " +
                                           aTextStatus + " /Error: " + aError);
                               
                               });
        
        return cleanHtml;
    },
    
    /**
     * Removes all the \n\r and white spaces from an HTML string
     * @param aHTMLString the html string to be trimmed
     * @returns the trimmed HTML
     */
    _trimHTML : function (aHTMLString) {
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
     * Removes unnecesary pieces of code from the html
     * @param aHtml the html to be cleaned
     * @returns the cleaned html
     */
    _cleanHTML : function(aHtml) {
        $("script", aHtml).remove();
        return aHtml;
    },
    
    _decodeHTMLEntities : function(html) {
        var txt = document.createElement('textarea');
        txt.innerHTML = html;
        return txt.value;
    },
    
    /**
     * Loads the order invoice html and sends it over for storage
     * @param aCourierNumber the courier number
     * @param aInvoiceUrl the order invoice url
     * @param aFirstItemDescription the first item description in the order
     * @param aShipper the shipper of the package (Amazon, eBay, etc)
     * @param aOrderIndex the order index for pages with multiple orders
     */
    _loadOrderInvoice : function(aCourierNumber, aInvoiceUrl, aFirstItemDescription, aShipper, aOrderIndex) {
        var getInvoiceHtmlCallback = function(aHtml) {
            var finalHtml = AmazonContentScript.generateAmazonInvoice(aHtml, aFirstItemDescription, aCourierNumber, aInvoiceUrl);
            if (finalHtml) {
                safari.extension.dispatchMessage("processInvoiceHtml", {courierNumber : aCourierNumber,
                                                firstItemDescription: aFirstItemDescription,
                                                invoiceHtml : finalHtml});
            }
            // check if the order is using a gift card and update the order value
            // accordingly
            ContentScript._checkInvoiceForGiftCards(finalHtml, aFirstItemDescription, aCourierNumber, aOrderIndex);
        };
        ContentScript._getInvoiceHTML(aInvoiceUrl, getInvoiceHtmlCallback);
    },
    
    /**
     * Gets the invoice html
     * @param aUrl the invoice url
     * @param aCallback the callback to be called on return
     */
    _getInvoiceHTML : function(aUrl, aCallback) {
        var request =
        $.ajax({
               type: "GET",
               url: aUrl,
               jsonp: false,
               timeout: 60 * 1000,
               }).done(function(aData) {
                       aCallback(aData);
                       }).fail(function(aXHR, aTextStatus, aError) {
                               console.log("Error retrieving the invoice HTML: Status: " +
                                           aTextStatus + " /Error: " + aError);
                               // notify sentry that we couldn't load the invoice
                               safari.extension.dispatchMessage("reportError",
                                                               {error : {
                                                               message: "Error loading invoice HTML",
                                                               extra : {
                                                               invoiceUrl: aUrl,
                                                               }
                                                               }});
                               
                               aCallback();
                               });
    },
    
    /**
     * Checks an invoice to see if it contains gift cards and updates the respective
     * prealert info accordingly.
     * @param aInvoiceHtml the invoice html to be reviewed
     * @param aFirstItemDescription the description of the first item in the order
     * (for orders with multiple packages)
     * @param aCourierNumber the courier number to update the respective button
     * if necessary
     * @param aOrderIndex the order index for pages with multiple orders
     */
    _checkInvoiceForGiftCards : function(aInvoiceHtml, aFirstItemDescription, aCourierNumber, aOrderIndex) {
        var html = $(aInvoiceHtml);
        var orderValue = ContentScript._getValueFromInvoice(aInvoiceHtml, aFirstItemDescription);
        if (orderValue) {
            // search for the respective button and update the value accordingly
            var targetButton =
            $("[buttonId='aero-prealert-" + aCourierNumber + (aOrderIndex != null ? "-" + aOrderIndex : "") + "']");
            if (targetButton.length > 0) {
                var packageInfo = $(targetButton).attr("packageInfo");
                
                packageInfo = JSON.parse(packageInfo);
                packageInfo.value = orderValue.totalValue;
                packageInfo.subTotalCost = orderValue.subTotalCost;
                
                $(targetButton).attr("packageInfo", JSON.stringify(packageInfo));
            }
        }
    },
    /**
      * Generates the received package button
      * @return the button to be injected
      */
    _createPackageButton : function(aMIA) {
        //outer div
        var button = $("<button type='button' class='btn aero-injected-button preAlertButton'>" +
                       "<img />" +
                       "<span id='aero-injected-button-text'>" + $.i18n.getString("content_script_received_label") + aMIA.mia + "</span>" +
                       "</button>");
        
        var url = location.href.toLowerCase();
        if (url.indexOf("amazon") != -1 &&
            url.indexOf("order-history") != -1) {
            $(button).addClass("aero-amazon-button");
        } else if (url.indexOf("amazon") != -1 &&
                   url.indexOf("summary/edit.html") != -1) {
            $(button).addClass("aero-amazon-order-details-button");
        } else if (url.indexOf("amazon") != -1 &&
                   url.indexOf("order-details") != -1) {
            $(button).addClass("aero-amazon-order-details-button");
        } else if(url.indexOf("ebay") != -1 &&
                  url.indexOf("fetchorderdetails") != -1) {
            $(button).addClass("aero-ebay-order-details-button");
        } else if(url.indexOf("my.ebay") != -1 ||
                  (url.indexOf("www.ebay") != -1 &&
                   url.indexOf("purchasehistory") != -1) ||
                  url.indexOf("summary") != -1) {
            $(button).addClass("aero-ebay-order-list-button");
        } else if(url.indexOf("rakuten") != -1 &&
                  url.indexOf("orderhistory") != -1) {
            $(button).addClass("aero-rakuten-order-list-button");
        } else if(url.indexOf("aeropostale") != -1 &&
                  url.indexOf("ordertrackingdetail") != -1) {
            $(button).addClass("aero-aeropostale-order-details-button");
        } else if(url.indexOf("aeropostale") != -1 &&
                  url.indexOf("ordertracking") != -1) {
            $(button).addClass("aero-aeropostale-order-list-button");
        } else if(url.indexOf("forever21") != -1 &&
                  url.indexOf("pastorders") != -1) {
            $(button).addClass("aero-forever21-order-list-button");
        } else if(url.indexOf("forever21") != -1 &&
                  url.indexOf("vieworder") != -1) {
            $(button).addClass("aero-forever21-order-details-button");
        }
        
        $(button).attr("mia", aMIA.mia);
        
        $(button).attr("packageInfo", JSON.stringify(aMIA));
        $(button).click(function(event) {
                        var packageInfo = JSON.parse($(this).attr("packageInfo"));
                        safari.extension.dispatchMessage("viewPackage", packageInfo);
                        });
        
        return button;
    },
    
    /**
     * Shows the first run colorbox that will be displayed on the supported pages
     * the first time they are opened
     * @param aTargetButton the target button to link the guide to
     * @param aPage the page for which the colorbox will be displayed
     */
    _showFirstRunGuide : function(aTargetButton, aPage) {
        
        var floatingDiv = "<div class='col-xs-12 col-sm-12 col-md-12 aero-first-run-guide'>" +
        "<p class='text-center'>" +
        "<img />" +
        "</p>" +
        "<p class='leadBlue text-center'>" + $.i18n.getString("content_script_first_run_colorbox_msg") + "</p>" +
        "<p class='text-center'>" +
        "<a id='aero-colorbox-first-run-link'>" + $.i18n.getString("content_script_first_run_colorbox_hide") + "</a>" +
        "</p>" +
        "</div>";
        
        $(aTargetButton).popover({placement : "right",
                                 html : "true",
                                 content : floatingDiv});
        
        $(aTargetButton).appear();
        $(aTargetButton).on('appear', function(event, $all_appeared_elements) {
                            // this element is now inside browser viewport
                            if ($(aTargetButton).next('div.popover:visible').length == 0){
                            $(aTargetButton).popover("show");
                            $("#aero-colorbox-first-run-link").click(function(event) {
                                                                     $(aTargetButton).popover("destroy");
                                                                     safari.extension.dispatchMessage("stopShowingGuide", {page: aPage});
                                                                     });
                            }
                            });
        
        $("body").click(function(event) {
                        $(aTargetButton).popover("destroy");
                        });
    },
    
    /**
     * Returns the carrier, using regular expressions, from a tracking #
     * @param aTracking
     * @returns the carrier
     */
    _getCarrier : function(aTracking) {
        
        var UPS = /(\b1[zZ][A-Za-z0-9]{16}\b)|(\b\d{9}\b)/;
        if (UPS.test(aTracking)) {
            return "UPS";
        }
        
        var USPS = /(\b91\d{20}\b)|(\b94\d{20}\b)|(\b95\d{20}\b)|(\b\d{30}\b)/;
        if (USPS.test(aTracking)) {
            return "USPS";
        }
        
        var FEDEX = /(\b96\d{20}\b)|(\b\d{32}\b)|(\b\d{20}\b)|(\b\d{11}\b)|(\b\d{12}\b)|(\b\d{15}\b)/;
        if (FEDEX.test(aTracking)) {
            return "FEDEX";
        }
        
        var INTMAILCHINAPOST = /(\b[A-Za-z]{2}\d{9}[A-Za-z]{2}\b)/;
        if (INTMAILCHINAPOST.test(aTracking)) {
            return "INTMAILCHINAPOST";
        }
        
        var LASERSHIP = /(\b[Ll][A-Za-z]\d{8}\b)|(\b[A-Za-z]{2}\d{9})|(\b[0-9][Ll][A-Za-z]\d{12}\b)/;
        if (LASERSHIP.test(aTracking)) {
            return "LASERSHIP";
        }
        
        var DHL = /(\b\d{10}\b)|(\b\d{16}\b)|(\b\d{19}\b)|(\b\d{22}\b)|(\b\d{6}[A-Za-z]\d{4}\b)/;
        if (DHL.test(aTracking)) {
            return "DHL";
        }
        
        return null;
    },
    
    /**
     * Shows a notification
     * @param aNotification the notification to be shown
     * @param aClickable whether the notification should be clickable or not
     * @param aType the notification type so we know where to take the user on click
     */
    showNotification : function(aNotification, aClickable, aType) {
        var options = {};
        options.iconUrl = safari.extension.baseURI + "/Resources/logo_32_32.png";
        
        options.title = $.i18n.getString(aNotification.title);
        options.message = $.i18n.getString(aNotification.msg, [aNotification.id]);
        options.type = aNotification.type;
        options.isClickable = true;
        if (aNotification.point) {
            switch (aNotification.point) {
                case "start":
                    options.progress = 10;
                    break;
                case "invoice":
                    options.progress = 60;
                    break;
            }
        }
        options.priority = 2;
        var id = aNotification.id + "" + this._notificationCounter;
        this._notificationCounter++;
        
        var optionsNotification = {
        body: options.message,
        icon: options.iconUrl
        }
        
        // Comprobamos si el navegador soporta las notificaciones
        if (!("Notification" in window)) {
            alert("Este navegador no soporta las notificaciones del sistema");
        }
        
        // Comprobamos si ya nos habían dado permiso
        else if (Notification.permission === "granted") {
            // Si esta correcto lanzamos la notificación
            var notification = new Notification(options.title, optionsNotification);
        }
        
        // Si no, tendremos que pedir permiso al usuario
        else if (Notification.permission !== 'denied') {
            Notification.requestPermission(function (permission) {
                                           // Si el usuario acepta, lanzamos la notificación
                                           if (permission === "granted") {
                                           var notification = new Notification(options.title, optionsNotification);
                                           }
                                           });
        }
        
        
        if (aClickable) {
            notification.onclick = function() {
                var target = null;
                switch (aType) {
                    case 0:
                        target = "newPreAlert";
                        break;
                    case 1:
                        target = "viewCart";
                        break;
                }
                
                if (target != null) {
                    //Background.openPage(target);
                }
            };
        }
    }
};
ContentScript.init();




