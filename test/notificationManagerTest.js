$(function() {
  module("Constructor");
  test("no arguments", function() {
    var nm;
    nm = new NotificationManager;
    same(nm._bucketList, [], "bucketList should be empty initially");
    return same(nm._displayMethod, "priority", "priority should be the displayMethod initially");
  });
  test("1 argument", function() {
    var list, nm;
    list = ["A", "B", "C"];
    nm = new NotificationManager(list);
    same(nm._bucketList, list, "bucketList should be match the parameters");
    return same(nm._displayMethod, "priority", "priority should be the displayMethod by default");
  });
  test("2 arguments", function() {
    var list, nm;
    list = ["A", "B", "C"];
    nm = new NotificationManager(list, "all");
    same(nm._bucketList, list, "bucketList should be match the parameters");
    same(nm._displayMethod, "all", "should have accepted 'all'");
    nm = new NotificationManager(list, "some bad value");
    same(nm._bucketList, list, "bucketList should be match the parameters");
    return same(nm._displayMethod, "priority", "should have stayed with priority in the case of an invalid value");
  });
  module("totalSize()");
  test("counting", function() {
    var nm;
    nm = new NotificationManager;
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
  test("clear and check size", function() {
    var nm;
    nm = new NotificationManager;
    nm.add(new Notification("a", "b"));
    nm.add(new Notification("a", "b"));
    nm.add(new Notification("a", "b"));
    nm.add(new Notification("b", "a"));
    notEqual(0, nm.totalSize());
    nm.clear();
    return equal(0, nm.totalSize());
  });
  module("setDisplayMethod()");
  test("test with valid values", function() {
    var nm;
    nm = new NotificationManager;
    nm.setDisplayMethod("all");
    equal("all", nm._displayMethod, "changed the value successfully");
    nm.setDisplayMethod("priority");
    return equal("priority", nm._displayMethod, "changed the value successfully");
  });
  test("test with invalid values", function() {
    var nm, oldValue;
    nm = new NotificationManager;
    oldValue = nm._displayMethod;
    nm.setDisplayMethod("some bad value");
    return equal(oldValue, nm._displayMethod, "kept the old value");
  });
  return true;
});