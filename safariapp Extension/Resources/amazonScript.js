/**
 * Copyright (C) 2016 AeroPost. All Rights Reserved.
 */

/**
 * Amazon Script Class.
 */
var AmazonScript = {

  currentASIN : null,
  currentColor : null,
  currentSize : null,

  /**
   * Initializes the object.
   */
  init : function() {

    this._addHTTPRequestLoadListener();

  },

  /**
   * Unitializes the object.
   */
  uninit : function() {

  },

  _addHTTPRequestLoadListener : function() {
    var origOpen = XMLHttpRequest.prototype.open;
    var that = this;
    XMLHttpRequest.prototype.open = function() {
        //console.log('request started!');
        this.addEventListener('load', function() {
            //console.log('request completed!');
            //console.log(this.responseURL);
            //console.log(this.readyState); //will always be 4 (ajax is completed successfully)
            //console.log(this.responseText); //whatever the response was
            
            var newASIN = null;
            var newSize = null;
            var newColor = null;

            if (typeof DetailPage != 'undefined' && DetailPage != null && DetailPage.StateController != null && DetailPage.StateController.state != null) {
              newASIN = DetailPage.StateController.state.current_asin;
              newSize = DetailPage.StateController.state.selected_variations.size_name;
              newColor = DetailPage.StateController.state.selected_variations.color_name;
            } else {
              var url = window.location.href;
              var regex = RegExp("(?:/)([a-zA-Z0-9]{10})");
              m = url.match(regex);
              if(m != null && m.length == 2) {
                newASIN = m[1];
              }
            }

          if (newASIN != null) {
              if ((newASIN != null && newASIN != that.currentASIN) ||
                  (newSize != null && newSize != that.currentSize) ||
                  (newColor != null && newColor != that.currentColor)) {
                that.currentASIN = newASIN;
                that.currentSize = newSize;
                that.currentColor = newColor;
                var data = {type: "AMAZON_PDP_CURRENT_ASIN",
                            currentASIN: that.currentASIN,
                            size : that.currentSize,
                            color: that.currentColor};
                window.postMessage(data, "*");
              }
            } else {
              var data = {type: "AMAZON_PDP_CURRENT_ASIN",
                            currentASIN: null,
                            size : null,
                            color: null};
              window.postMessage(data, "*");
            }
        });
        origOpen.apply(this, arguments);
    };
  }


};

AmazonScript.init();
