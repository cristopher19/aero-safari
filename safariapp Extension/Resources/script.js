safari.self.addEventListener("message", handleMessage);

function handleMessage(event) {
    window.alert(event.name + " / " + event.message.data.field1);
    
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
                  var trackingButtonEnabled = $(orderDetails).find("span[class~='track-package-button'][class~='a-button-primary']");
                  
                  if (trackingButtonEnabled.length > 0 &&
                    
                      }
                  } else {
                      // the package hasn't been shipped yet (the tracking button is not enabled),
                      // so we display the not prealertable button
                      var existingAnchor = $(order).find("button[class~='preAlertButton']");
                      if (existingAnchor.length == 0) {
                      var button = $("<button type='button' class='btn aero-injected-button'>" +
                                     "<img />" +
                                     "<span id='aero-injected-button-text'>" + "preAlert" + "</span>" +
                                     "</button>");
                      if (aType == "preAlert") {
                      $(button).attr("href", "#aero-inline-content");
                      }
                          $(button).addClass("disabled");
                          $("#aero-injected-button-text", button).text("Not prealerted");
                          $(button).addClass("preAlertButton");
                          $(button).addClass("aero-amazon-button");
                          $(button).appendTo(order);
                      }
                  }
              }
});
