$(function() {
  module("constructor");
  test("no arguments", function() {
    var nm;
    nm = new NotificationManager;
    same(nm._bucketList, [], "bucketList should be empty initially");
    equal(nm._displayMethod, "priority", "priority should be the displayMethod initially");
    return equal(nm._displayThreshold, void 0, "because the method isn't threshold");
  });
  test("default display method", function() {
    var list, nm;
    list = ["A", "B", "C"];
    nm = new NotificationManager(list);
    same(nm._bucketList, list, "bucketList should be match the parameters");
    equal(nm._displayMethod, "priority", "priority should be the displayMethod by default");
    return equal(nm._displayThreshold, void 0, "because the method isn't threshold");
  });
  test("setting display method", function() {
    var list, nm;
    list = ["A", "B", "C"];
    nm = new NotificationManager(list, "all");
    same(nm._bucketList, list, "bucketList should be match the parameters");
    equal(nm._displayMethod, "all", "should have accepted 'all'");
    nm = new NotificationManager(list, "some bad value");
    same(nm._bucketList, list, "bucketList should be match the parameters");
    equal(nm._displayMethod, "priority", "should have stayed with priority in the case of an invalid value");
    return equal(nm._displayThreshold, void 0, "because the method isn't threshold");
  });
  test("using display args", function() {
    var nm;
    nm = new NotificationManager(["a", "b", "c"], "threshold", "b");
    same(nm._bucketList, ["a", "b", "c"], "bucketList should be match the parameters");
    equal(nm._displayMethod, "threshold", "should have accepted 'threshold'");
    equal(nm._displayThreshold, "b", "should have accepted the display argument");
    nm = new NotificationManager(["a", "b", "c"], "threshold", "z");
    same(nm._bucketList, ["a", "b", "c"], "bucketList should be match the parameters");
    equal(nm._displayMethod, "priority", "should have rejected 'threshold' because of the invalid argument");
    return equal(nm._displayThreshold, void 0, "because 'threshold' was rejected, should be empty");
  });
  module("totalSize()");
  test("counting", function() {
    var nm;
    nm = new NotificationManager;
    equal(0, nm.totalSize());
    nm.add(new Notification("a", "b"));
    equal(1, nm.totalSize());
    nm.add(new Notification("a", "b"));
    equal(2, nm.totalSize());
    nm.add(new Notification("a", "b"));
    equal(3, nm.totalSize());
    nm.add(new Notification("b", "a"));
    return equal(4, nm.totalSize());
  });
  module("clear()");
  test("clear all buckets", function() {
    var nm;
    nm = new NotificationManager;
    nm.add(new Notification("a", "b"));
    nm.add(new Notification("a", "b"));
    nm.add(new Notification("a", "b"));
    nm.add(new Notification("b", "a"));
    notEqual(0, nm.totalSize());
    ok(nm.clear());
    return equal(0, nm.totalSize());
  });
  test("clear single bucket", function() {
    var nm;
    nm = new NotificationManager;
    nm.add(new Notification("a", "b"));
    nm.add(new Notification("a", "b"));
    nm.add(new Notification("a", "b"));
    nm.add(new Notification("b", "a"));
    notEqual(0, nm.totalSize());
    ok(nm.clear("a"));
    equal(1, nm.totalSize());
    same(nm.notifications(), ["a"]);
    return same(nm.bucket("a"), []);
  });
  test("clear nonexistant bucket", function() {
    var nm;
    nm = new NotificationManager;
    nm.add(new Notification("a", "b"));
    nm.add(new Notification("a", "b"));
    nm.add(new Notification("a", "b"));
    nm.add(new Notification("b", "a"));
    equal(nm.totalSize(), 4);
    ok(nm.clear("c"));
    return equal(nm.totalSize(), 4);
  });
  test("clear is idempotent", function() {
    var nm;
    nm = new NotificationManager;
    nm.add(new Notification("a", "b"));
    nm.add(new Notification("a", "b"));
    nm.add(new Notification("a", "b"));
    nm.add(new Notification("b", "a"));
    equal(nm.totalSize(), 4);
    ok(nm.clear("a"));
    equal(nm.totalSize(), 1);
    ok(nm.clear("a"));
    equal(nm.totalSize(), 1);
    ok(nm.clear("a"));
    equal(nm.totalSize(), 1);
    ok(nm.clear("b"));
    equal(nm.totalSize(), 0);
    ok(nm.clear("b"));
    equal(nm.totalSize(), 0);
    ok(nm.clear("b"));
    return equal(nm.totalSize(), 0);
  });
  module("setDisplayMethod()");
  test("test with valid values", function() {
    var nm;
    nm = new NotificationManager(["a", "b", "c"]);
    ok(nm.setDisplayMethod("all"));
    equal("all", nm._displayMethod, "changed the value successfully");
    ok(nm.setDisplayMethod("priority"));
    equal("priority", nm._displayMethod, "changed the value successfully");
    ok(nm.setDisplayMethod("threshold", "b"));
    return equal("threshold", nm._displayMethod, "changed the value successfully");
  });
  test("test with invalid values", function() {
    var nm, oldValue;
    nm = new NotificationManager(["a", "b", "c"]);
    oldValue = nm._displayMethod;
    ok(!nm.setDisplayMethod("some bad value"));
    equal(oldValue, nm._displayMethod, "kept the old value");
    ok(!nm.setDisplayMethod("threshold", "z"));
    return equal(oldValue, nm._displayMethod, "kept the old value");
  });
  module("buckets()");
  test("statically added buckets", function() {
    var bkts, nm;
    nm = new NotificationManager(["a", "b", "c"]);
    bkts = nm.buckets();
    equal(bkts.length, 3);
    equal(bkts[0], "a");
    equal(bkts[1], "b");
    return equal(bkts[2], "c");
  });
  test("dynamically added buckets", function() {
    var bkts, nm;
    nm = new NotificationManager;
    nm.add(new Notification("a", "message"));
    nm.add(new Notification("b", "message"));
    nm.add(new Notification("c", "message"));
    nm.add(new Notification("d", "message"));
    bkts = nm.buckets();
    equal(bkts.length, 4);
    equal(bkts[0], "a");
    equal(bkts[1], "b");
    equal(bkts[2], "c");
    return equal(bkts[3], "d");
  });
  test("statically and dynamically added buckets", function() {
    var bkts, nm;
    nm = new NotificationManager(["a", "c", "e"]);
    nm.add(new Notification("b", "message"));
    nm.add(new Notification("d", "message"));
    bkts = nm.buckets();
    equal(bkts.length, 5);
    equal(bkts[0], "a");
    equal(bkts[1], "c");
    equal(bkts[2], "e");
    equal(bkts[3], "b");
    return equal(bkts[4], "d");
  });
  module("bucket()");
  test("buckets that statically exist", function() {
    var nm;
    nm = new NotificationManager(["a", "b", "c"]);
    nm.add(new Notification("a", "message1"));
    nm.add(new Notification("a", "message2"));
    nm.add(new Notification("b", "message3"));
    equal(nm.bucket("a").length, 2);
    equal(nm.bucket("b").length, 1);
    equal(nm.bucket("c").length, 0);
    same(nm.bucket("a"), ["message1", "message2"]);
    same(nm.bucket("b"), ["message3"]);
    return same(nm.bucket("c"), []);
  });
  test("buckets that dynamically exist", function() {
    var nm;
    nm = new NotificationManager;
    nm.add(new Notification("a", "message1"));
    nm.add(new Notification("a", "message2"));
    nm.add(new Notification("b", "message3"));
    equal(nm.bucket("a").length, 2);
    equal(nm.bucket("b").length, 1);
    same(nm.bucket("a"), ["message1", "message2"]);
    return same(nm.bucket("b"), ["message3"]);
  });
  test("buckets that don't exist at all", function() {
    var nm;
    nm = new NotificationManager;
    same(nm.bucket("fake-bucket"), []);
    nm.add(new Notification("a", "message1"));
    same(nm.bucket("fake-bucket"), []);
    nm = new NotificationManager(["a", "b", "c"]);
    same(nm.bucket("fake-bucket"), []);
    nm.add(new Notification("a", "message1"));
    return same(nm.bucket("fake-bucket"), []);
  });
  module("notifications()");
  test("displayMethod: 'all' --> all messages come back", function() {
    var expected, nm;
    nm = new NotificationManager(["a", "b"], "all");
    equal(nm._displayMethod, "all", "check that value actually stuck");
    nm.add(new Notification("a", "message1"));
    nm.add(new Notification("a", "message2"));
    nm.add(new Notification("b", "message3"));
    expected = {
      a: ["message1", "message2"],
      b: ["message3"]
    };
    return same(nm.notifications(), expected, "should have brought all messages out");
  });
  test("displayMethod: 'all' --> only non-empty buckets come back", function() {
    var expected, nm;
    nm = new NotificationManager(["a", "b", "c"], "all");
    equal(nm._displayMethod, "all", "check that value actually stuck");
    nm.add(new Notification("b", "message3"));
    expected = {
      b: ["message3"]
    };
    return same(nm.notifications(), expected, "should have excluded any empty buckets");
  });
  test("displayMethod: 'all' --> handles 0 messages correctly", function() {
    var nm, size, x;
    nm = new NotificationManager(["a", "b", "c"], "all");
    equal(nm._displayMethod, "all", "check that value actually stuck");
    size = ((function() {
      var _results;
      _results = [];
      for (x in nm.notifications()) {
        _results.push(x);
      }
      return _results;
    })()).length;
    equal(size, 0, "shouldn't bring back any buckets");
    return same(nm.notifications(), {}, "should have returned an empty map");
  });
  test("displayMethod = priority --> a single list comes back", function() {
    var nm;
    nm = new NotificationManager(["a", "b", "c"], "priority");
    equal(nm._displayMethod, "priority", "check that value actually stuck");
    nm.add(new Notification("a", "message1"));
    nm.add(new Notification("a", "message2"));
    nm.add(new Notification("b", "message3"));
    equal(Object.prototype.toString.call(nm.notifications()), "[object Array]", "return value is a list");
    return same(nm.notifications(), ["message1", "message2"], "check the content");
  });
  test("displayMethod = priority --> only highest priority bucket gets returned, even if dynamically introduced", function() {
    var nm;
    nm = new NotificationManager(["a", "b", "c"], "priority");
    equal(nm._displayMethod, "priority", "check that value actually stuck");
    nm.add(new Notification("e", "message4"));
    nm.add(new Notification("f", "message5"));
    nm.add(new Notification("g", "message6"));
    equal(Object.prototype.toString.call(nm.notifications()), "[object Array]", "return value is a list");
    same(nm.notifications(), ["message4"], "check the content");
    nm.add(new Notification("c", "message3"));
    equal(Object.prototype.toString.call(nm.notifications()), "[object Array]", "return value is a list");
    same(nm.notifications(), ["message3"], "check the content");
    nm.add(new Notification("b", "message2"));
    equal(Object.prototype.toString.call(nm.notifications()), "[object Array]", "return value is a list");
    same(nm.notifications(), ["message2"], "check the content");
    nm.add(new Notification("a", "message1"));
    equal(Object.prototype.toString.call(nm.notifications()), "[object Array]", "return value is a list");
    return same(nm.notifications(), ["message1"], "check the content");
  });
  test("displayMethod: priority --> handles 0 messages correctly", function() {
    var nm, size, x;
    nm = new NotificationManager(["a", "b", "c"], "priority");
    equal(nm._displayMethod, "priority", "check that value actually stuck");
    size = ((function() {
      var _results;
      _results = [];
      for (x in nm.notifications()) {
        _results.push(x);
      }
      return _results;
    })()).length;
    equal(size, 0, "shouldn't bring back any buckets");
    return same(nm.notifications(), [], "should have returned an empty list");
  });
  test("displayMethod = threshold --> returns all messages with a priority greater than a threshold", function() {
    var expected, nm, size, x;
    nm = new NotificationManager(["a", "b", "c"], "threshold", "b");
    equal(nm._displayMethod, "threshold", "check that value actually stuck");
    nm.add(new Notification("a", "message1"));
    nm.add(new Notification("a", "message2"));
    nm.add(new Notification("b", "message3"));
    nm.add(new Notification("b", "message4"));
    nm.add(new Notification("c", "message5"));
    nm.add(new Notification("c", "message6"));
    size = ((function() {
      var _results;
      _results = [];
      for (x in nm.notifications()) {
        _results.push(x);
      }
      return _results;
    })()).length;
    equal(size, 2, "should get 2 buckets back");
    expected = {
      a: ["message1", "message2"],
      b: ["message3", "message4"]
    };
    return same(nm.notifications(), expected, "should have returned correct messages");
  });
  test("displayMethod = threshold --> handles 0 messages correctly", function() {
    var nm, size, x;
    nm = new NotificationManager(["a", "b", "c"], "threshold", "b");
    equal(nm._displayMethod, "threshold", "check that value actually stuck");
    size = ((function() {
      var _results;
      _results = [];
      for (x in nm.notifications()) {
        _results.push(x);
      }
      return _results;
    })()).length;
    equal(size, 0, "shouldn't bring back any buckets");
    return same(nm.notifications(), {}, "should have returned an empty map");
  });
  module("Real World Usage");
  test("logging", function() {
    var CRITICAL, DEBUG, ERROR, FATAL, INFO, TRACE, WARN, expected, nm;
    FATAL = "FATAL";
    CRITICAL = "CRITICAL";
    ERROR = "ERROR";
    WARN = "WARN";
    INFO = "INFO";
    DEBUG = "DEBUG";
    TRACE = "TRACE";
    nm = new NotificationManager([FATAL, CRITICAL, ERROR, WARN, INFO, DEBUG, TRACE], "threshold", INFO);
    nm.add(new Notification(DEBUG, "server is at 127.0.0.1/server/api/"));
    nm.add(new Notification(INFO, "establishing connection with server"));
    nm.add(new Notification(ERROR, "error contacting external server"));
    nm.add(new Notification(FATAL, "holy crap, the server caught on fire"));
    expected = {};
    expected[FATAL] = ["holy crap, the server caught on fire"];
    expected[INFO] = ["establishing connection with server"];
    expected[ERROR] = ["error contacting external server"];
    return same(nm.notifications(), expected, "should match expected output exactly");
  });
  return true;
});