/**
 * Copyright (C) 2014 Aeropost. All Rights Reserved.
 */

/**
 * Notification Data Transfer Object.
 */
function NotificationObject(aId) {
  this._init(aId);
}

/* DTO Prototype. */
NotificationObject.prototype = {

  id : null,
  type : null,
  point : null,
  title : null,
  msg : null,

  /**
   * Initializes the object.
   * @param aId the notification id
   */
  _init : function(aId) {
    this.id = aId;
  }
};
