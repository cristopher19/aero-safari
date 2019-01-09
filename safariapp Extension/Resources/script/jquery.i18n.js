/**
 * Copyright (C) 2014 Aeropost. All Rights Reserved.
 */

(function($) {
  $.i18n = function(aOptions) {
    var options = aOptions || {};
    var wrappedSet = this;
    /**
     * Applies the locale to the relevant elements by the given data.
     * @param aOptions the options.
     */
    function applyLocale(aOptions) {
      var attrNames = aOptions.attributeNames || [];
      const RE_LOCALE_KEY_NAME = /^i18n\[(.*?)\]/;

      wrappedSet.each(function() {
        var elem = $(this);
        if (elem.attr("rel")) {
          var results = elem.attr("rel").match(RE_LOCALE_KEY_NAME);
          if (results && results[1]) {
            elem.text($.i18n.getString(results[1], null));
          }
        }

        $.each(attrNames, function(aIndex, aValue) {
          if (elem.attr(aValue)) {
            var results = elem.attr(aValue).match(RE_LOCALE_KEY_NAME);

            if (results && results[1]) {
              elem.attr(aValue, $.i18n.getString(results[1], null));
            }
          }
        });
      });
    }

    applyLocale(options);
  };

  // attach the i18n object and its methods to the jQuery object.
  $.fn.i18n = $.i18n;
  // flag indicates whether this has been loaded before or not.
  $.i18n._loaded = false;

  var language = navigator.language.toLowerCase();

  //XXX: Required to localize strings from de, es, fr, it, nl, pl
  if (language != "en-us" && language != "en-gb") {
    language = language.substring(0,2);
  }

  // locale data.
  if (!LOCALES[language]) {
    $.i18n.data = LOCALES["en-us"];
  } else {
    $.i18n.data = LOCALES[language];
  }
  // the default language set for the browser.
  $.i18n.defaultLanguage = navigator.language;

  // get the string for a key.
  $.i18n.getString = function(aKey, aStrArray) {
    var data = $.i18n.data;

    var str = null;

    // Replace dots with underscores, to match Google Chrome's i18n policy
    aKey = aKey.replace(/\./g,"_");
    if (!data[aKey]) {
      Logger.error("Couldn't retrieve localization message for key: "+aKey);
    } else {
      str = data[aKey]["message"];
      // replace placeholders.
      if ($.isArray(aStrArray)) {
        $.each(aStrArray, function(aIndex, aValue) {
          str = str.replace("%S" + (aIndex + 1), aValue);
        });
        str = str.replace("%S", aStrArray[0]);
      }
    }

    if (str == null | str == "") {
      Logger.warn("i18n key not found: "+aKey);
    }

    return str;
  };

})(jQuery);
