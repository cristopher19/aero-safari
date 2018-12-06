safari.self.addEventListener("message", handleMessage);

function handleMessage(event) {
    window.alert(event.name + " / " + event.message.data);
    
};

/*function injectImage() {
 var newElement = document.createElement("img");
 newElement.src = safari.extension.baseURI + "images/icon-256.png";
 document.body.insertBefore(newElement,
 document.body.firstChild);
 }*/

document.addEventListener("DOMContentLoaded", function(event) {
                          var url = location.href.toLowerCase();
                          
                          //response al app
                          if (url.indexOf("amazon") != -1 &&
                              url.indexOf("order-history") != -1 &&
                              url.indexOf("signin") == -1 &&
                              url.indexOf("ap-prefetch-iframe.html") == -1) {
                          
                          safari.extension.dispatchMessage("passObj", { "data": "hola" });
                          //AmazonContentScript.modifyAmazonOrdersPage();
                          var orders = $("div[class~='order-info']");
                          var ordersLength = orders.length;
                          
                          if (ordersLength > 0) {
                          for (var i = 0; i < ordersLength; i++) {
                          var order = orders[i];
                          var orderDetails = $(order).parent().find("div[class~='shipment']");
                          // massive hack to solve a problem where amazon duplicates the previous package
                          // shipping info in packages that don't have any
                          var trackingButtonEnabled = $(orderDetails).find("span[class~='track-package-button'][class~='a-button-primary']");
                          
                          if (trackingButtonEnabled.length > 0 && false ) {
                              //ContentScript._isPackageForUser("Amazon", order, false)) {
                              // get the tracking page url
                              var trackingPageUrl = $($(trackingButtonEnabled)[0]).find("a");
                              if (trackingPageUrl.length > 0) {
                                trackingPageUrl = "https://www.amazon.com" + $($(trackingPageUrl)[0]).attr("href");
                              // load package tracking page
                              //var asins = $(order).parent().find("div[class~='a-fixed-left-grid-col'][class~='a-col-right']");
                              // AmazonContentScript.processAmazonOrder(trackingPageUrl, i);
                              }
                          } else {
                          // the package hasn't been shipped yet (the tracking button is not enabled),
                          // so we display the not prealertable button
                          var existingAnchor = $(order).find("button[class~='preAlertButton']");
                          if (existingAnchor.length == 0) {
                          // var button = ContentScript._createButton("preAlert");
                          var button = $("<button type='button' class='btn aero-injected-button'>" +
                                         "<img />" +
                                         "<span id='aero-injected-button-text'>" + "prueba" + "</span>" +
                                         "</button>");
                          if ("preAlert" == "preAlert") {
                          $(button).attr("href", "#aero-inline-content");
                          }
                          
                          
                          $(button).addClass("disabled");
                          $("#aero-injected-button-text", button).text("content_script_button_not_prealertable_label");
                          $(button).addClass("preAlertButton");
                          $(button).addClass("aero-amazon-button");
                          $(button).appendTo(order);
                          }
                          }
                          }
                          }
                          }
                          });
