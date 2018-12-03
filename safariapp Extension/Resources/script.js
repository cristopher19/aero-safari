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
      url.indexOf("order-history") != -1) {
                          
       safari.extension.dispatchMessage("passObj", { "data": "hola" });
  }
 
                          
});
