/**
 * Copyright (C) 2016 Aeropost. All Rights Reserved.
 */

/**
 * Content script class.
 */
var QuoteScript = {
  /**
   * Initializes the object.
   */
  init : function() {
  },

  /**
   * Creates the quote div to be injected in Amazon pdps
   * @param product the product info to be used to populate the div
   * @return the created div with the product info
   */
  _createQuoteDiv : function(product) {
    // remove the node if it already exists
    $("#aero-quote-main-container").remove();

    var mainContainer = $("<div id='aero-quote-main-container' class='iconNotification'></div>");

    var quoteContainer = $("<div class='quoteContainer aIconBlueCont apRightBubble'>" +
      "<div class='aIconBlue'><img/></div>" +
      "<div class='allInclusiveCont'>" +
      "<span class='labelSm blueTextLabel'>" + $.i18n.getString("content_script_quote_all_inclusive_label") + "</span>" +
      "<span class='pluginAllInclusivePrice'>$ " + product.priceBreakdown.total + "</span>" +
      "</div>" +
      "</div>");

    var quoteUnavailableContainer = $("<div class='aIconBlueCont quoteUnavailableContainer'>" +
      "<div class='aIconBlue'><img/></div>" +
      "<div class='aeropostNotification'>" +
      "<div style='position: absolute; right: -10px;' class='ArrowRightCont'>" +
      "<div class='ArrowUpInside'><br></div>" +
      "</div>" +
      "<div class='container-fluid'>" +
      "<div class='row'>" +
      "<div class='col-md-12'><p class='leadBlue'>" + $.i18n.getString("content_script_quote_select_variables_label") + "</p></div>" +
      "</div>" +
      "</div>" +
      "</div>" +
      "</div>");

    $(mainContainer).append(quoteContainer);
    $(mainContainer).append(quoteUnavailableContainer);

    QuoteScript._updateQuoteDivState(product, quoteContainer, quoteUnavailableContainer);

    // create the add to cart modal
    QuoteScript._createQuoteModalDialog(product);

    $(mainContainer).click(function() {
      $(".addtoCartModal").modal("show");
    });

    $("body").append(mainContainer);
  },

  /**
   * Creates the modal dialog for eventual use when the user clicks the quote button
   * @param product the product information that will be eventually added to the cart
   */
  _createQuoteModalDialog : function(product) {
    // remove the node if it already exists
    $(".barNotification").remove();

    totalCharges = product.priceBreakdown.total - product.priceUSD;
    totalCharges = totalCharges.toFixed(2);

    $("<div class='barNotification' >" +
        "<div style='display:inline'> " +
        "<div class='aIconBluBar' >" +
        "<div class='iconAeropost'></div>"+   
        "</div>" +
        "<div id='barLeftViewID' class='barLeftViewP' ><span>"+ $.i18n.getString("quote_script_quote_view_price_label") +"</span></div>" +
        "<!-- the class apRightBubble makes visible the all inclusive cont -->" +
        "<div id='allInclusiveBarId' class='allInclusiveContBar' ><span class='labelSm_new blueTextLabel_new'>"+$.i18n.getString("quote_script_quote_price_label")+"</span><span class='pluginAllInclusivePrice_new'>" +
        "<strong> $ " + product.priceUSD + "</strong> + $ " + totalCharges + " " + $.i18n.getString("quote_script_quote_customs_shipping_handling_label") +
        "</span>" +
        "<button id='addToCartBtn'>" + $.i18n.getString("quote_script_quote_add_to_aeropost_com_button") + " </button></div>" +
      "</div>" +
        "<div id='chevronBar' class='chevronBarRight' style='display:none'></div>" +
        "</div>").insertBefore("body");

      if($(window).scrollTop() > 200){
        $(".barNotification").attr("class", "barNotification barLeftViewPrice barOn");
        $("#allInclusiveBarId").hide();
        $("#barLeftViewID").attr("class", "barLeftViewPOn");
        $("#chevronBar").attr("class", "chevronBarRight");
        $("#chevronBar").show();
      }

      $("#chevronBar").click(function(event){
        $("#barLeftViewID").remove();
        $(".barNotification").attr("class", "barNotification barLeft barOff");
        $("#chevronBar").attr("class", "chevronBarLeft");
        $("#allInclusiveBarId").show();

      });

      $("body").attr("style","margin-top:30px!important;");

      $("#addToCartBtn").click(function() {
        safari.extension.dispatchMessage("addToCart", {productInfo : product});
      });

  },

  /**
   * Updates the quote div information with the provided product
   * @param product the product to update the quote div info
   */
  _updateQuoteDiv : function(product) {
    $('.pluginAllInclusivePrice').text("$" + product.priceBreakdown.total);

    QuoteScript._updateQuoteDivState(product,
                                      $(".quoteContainer"),
                                      $(".quoteUnavailableContainer"));

    // remove and recreate the modal dialog with the updated info
    QuoteScript._createQuoteModalDialog(product);
  },

  /**
   * Updates the quote div based on the product provided (avaiable/unavailable)
   * @param product the product to update the quote div state
   * @param quoteContainer the quote container node
   * @param quoteUnavailableContainer the quote unavailable container node
   */
  _updateQuoteDivState : function(product, quoteContainer, quoteUnavailableContainer) {
    if (product.itemVariations != null &&
        (!$.isEmptyObject(product.itemVariations) && product.selectedVariation != null) ||
        ($.isEmptyObject(product.itemVariations) && product.selectedVariation == null)) {
      $(quoteUnavailableContainer).hide();
      $(quoteContainer).show();
    } else {
      $(quoteContainer).hide();
      $(quoteUnavailableContainer).show();
    }
  }
};

QuoteScript.init();

window.addEventListener("message", function(event) {
  // We only accept messages from ourselves
  if (event.source != window)
    return;

  if (event.data.type && (event.data.type == "AMAZON_PDP_CURRENT_ASIN")) {
    var currentASIN = event.data.currentASIN;
    if (currentASIN) {
      AmazonContentScript.quoteAmazonProduct(currentASIN, event.data.size, event.data.color);
    } else {
      // change top bar:

      //remove loading gif
      $(".sk-fading-circle").remove();
      //Show new mesagge
      $(".blueTextLabel_new").text($.i18n.getString("quote_script_quote_view_all_inclusive_price_message"));

      $("#quoteBtn").show();
       
    }
  }
}, false);
