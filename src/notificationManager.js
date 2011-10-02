var Notification, NotificationManager;
var __indexOf = Array.prototype.indexOf || function(item) {
  for (var i = 0, l = this.length; i < l; i++) {
    if (this[i] === item) return i;
  }
  return -1;
};
Notification = (function() {
  function Notification(bucket, message) {
    this.bucket = bucket;
    this.message = message;
  }
  return Notification;
})();
NotificationManager = (function() {
  function NotificationManager(buckets, displayMethod, displayArguments) {
    var bucket, _i, _len;
    if (buckets == null) {
      buckets = [];
    }
    if (displayMethod == null) {
      displayMethod = "priority";
    }
    this._buckets = {};
    this._bucketList = [];
    for (_i = 0, _len = buckets.length; _i < _len; _i++) {
      bucket = buckets[_i];
      this._buckets[bucket] = [];
      this._bucketList.push(bucket);
    }
    if (!this.setDisplayMethod(displayMethod, displayArguments)) {
      this._displayMethod = "priority";
    }
  }
  NotificationManager.prototype.clear = function(bucketName) {
    var bucket;
    if (bucketName == null) {
      bucketName = null;
    }
    if (bucketName === null) {
      for (bucket in this._buckets) {
        this._buckets[bucket] = [];
      }
    } else {
      this._buckets[bucketName] = [];
    }
    return true;
  };
  NotificationManager.prototype.add = function(note) {
    var _ref;
    if (!(note.bucket != null)) {
      false;
    }
    if (_ref = note.bucket, __indexOf.call(this._bucketList, _ref) >= 0) {
      this._buckets[note.bucket].push(note.message);
    } else {
      this._buckets[note.bucket] = [note.message];
      this._bucketList.push(note.bucket);
    }
    return true;
  };
  NotificationManager.prototype.bucket = function(bucketName) {
    return this._buckets[bucketName] || [];
  };
  NotificationManager.prototype.buckets = function() {
    return this._bucketList;
  };
  NotificationManager.prototype.totalSize = function() {
    var x;
    return ((function() {
      var _results;
      _results = [];
      for (x in this._buckets) {
        _results.push(this._buckets[x].length);
      }
      return _results;
    }).call(this)).reduce((function(a, b) {
      return a + b;
    }), 0);
  };
  NotificationManager.prototype.setDisplayMethod = function(method, arg) {
    switch (method) {
      case "threshold":
        if (__indexOf.call(this._bucketList, arg) >= 0) {
          this._displayMethod = method;
          this._displayThreshold = arg;
          return true;
        } else {
          return false;
        }
        break;
      case "all":
      case "priority":
        this._displayMethod = method;
        return true;
      default:
        return false;
    }
  };
  NotificationManager.prototype.notifications = function() {
    switch (this._displayMethod) {
      case "all":
        return this._notifications_all();
      case "priority":
        return this._notifications_priority();
      case "threshold":
        return this._notifications_threshold();
    }
  };
  NotificationManager.prototype._notifications_all = function() {
    var bkt, retVal, _i, _len, _ref;
    retVal = {};
    _ref = this._bucketList;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      bkt = _ref[_i];
      if (this._buckets[bkt].length > 0) {
        retVal[bkt] = this._buckets[bkt];
      }
    }
    return retVal;
  };
  NotificationManager.prototype._notifications_priority = function() {
    var bkt, _i, _len, _ref;
    _ref = this._bucketList;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      bkt = _ref[_i];
      if (this._buckets[bkt].length > 0) {
        return this._buckets[bkt];
      }
    }
    return [];
  };
  NotificationManager.prototype._notifications_threshold = function() {
    var bkt, retVal, _i, _len, _ref;
    retVal = {};
    _ref = this._bucketList;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      bkt = _ref[_i];
      if (this._buckets[bkt].length > 0) {
        retVal[bkt] = this._buckets[bkt];
      }
      if (this._displayThreshold === bkt) {
        return retVal;
      }
    }
    return retVal;
  };
  return NotificationManager;
})();