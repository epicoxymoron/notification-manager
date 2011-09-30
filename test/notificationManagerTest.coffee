$ ->
	
	module "constructor"

	test "no arguments", ->
		nm = new NotificationManager
		same nm._bucketList, [], "bucketList should be empty initially"
		same nm._displayMethod, "priority", "priority should be the displayMethod initially"
	
	test "1 argument", ->
		list = ["A", "B", "C"]
		nm = new NotificationManager list
		same nm._bucketList, list, "bucketList should be match the parameters"
		same nm._displayMethod, "priority", "priority should be the displayMethod by default"
	
	test "2 arguments", ->
		list = ["A", "B", "C"]
		nm = new NotificationManager list, "all"
		same nm._bucketList, list, "bucketList should be match the parameters"
		same nm._displayMethod, "all", "should have accepted 'all'"
		nm = new NotificationManager list, "some bad value"
		same nm._bucketList, list, "bucketList should be match the parameters"
		same nm._displayMethod, "priority", "should have stayed with priority in the case of an invalid value"
	
	module "totalSize()"

	test "counting", ->
		nm = new NotificationManager
		equal 0, nm.totalSize()
		nm.add new Notification "a", "b"
		equal 1, nm.totalSize()
		nm.add new Notification "a", "b"
		equal 2, nm.totalSize()
		nm.add new Notification "a", "b"
		equal 3, nm.totalSize()
		nm.add new Notification "b", "a"
		equal 4, nm.totalSize()
	
	module "clear()"

	test "clear and check size", ->
		nm = new NotificationManager
		nm.add new Notification "a", "b"
		nm.add new Notification "a", "b"
		nm.add new Notification "a", "b"
		nm.add new Notification "b", "a"
		notEqual 0, nm.totalSize()
		nm.clear()
		equal 0, nm.totalSize()

	module "setDisplayMethod()"

	test "test with valid values", ->
		nm = new NotificationManager
		equal true, nm.setDisplayMethod "all"
		equal "all", nm._displayMethod, "changed the value successfully"
		equal true, nm.setDisplayMethod "priority"
		equal "priority", nm._displayMethod, "changed the value successfully"
	
	test "test with invalid values", ->
		nm = new NotificationManager
		oldValue = nm._displayMethod
		equal false, nm.setDisplayMethod "some bad value"
		equal oldValue, nm._displayMethod, "kept the old value"
	
	module "buckets()"

	test "statically added buckets", ->
		nm = new NotificationManager ["a", "b", "c"]
		bkts = nm.buckets()
		equal bkts.length, 3
		equal bkts[0], "a"
		equal bkts[1], "b"
		equal bkts[2], "c"

	test "dynamically added buckets", ->
		nm = new NotificationManager
		nm.add new Notification "a", "message"
		nm.add new Notification "b", "message"
		nm.add new Notification "c", "message"
		nm.add new Notification "d", "message"
		bkts = nm.buckets()
		equal bkts.length, 4
		equal bkts[0], "a"
		equal bkts[1], "b"
		equal bkts[2], "c"
		equal bkts[3], "d"

	test "statically and dynamically added buckets", ->
		nm = new NotificationManager ["a", "c", "e"]
		nm.add new Notification "b", "message"
		nm.add new Notification "d", "message"
		bkts = nm.buckets()
		equal bkts.length, 5
		equal bkts[0], "a"
		equal bkts[1], "c"
		equal bkts[2], "e"
		equal bkts[3], "b"
		equal bkts[4], "d"

	module "bucket()"

	test "buckets that statically exist", ->
		nm = new NotificationManager ["a", "b", "c"]
		nm.add new Notification "a", "message1"
		nm.add new Notification "a", "message2"
		nm.add new Notification "b", "message3"

		equal nm.bucket("a").length, 2
		equal nm.bucket("b").length, 1
		equal nm.bucket("c").length, 0

		same nm.bucket("a"), ["message1", "message2"]
		same nm.bucket("b"), ["message3"]
		same nm.bucket("c"), []
		
	test "buckets that dynamically exist", ->
		nm = new NotificationManager
		nm.add new Notification "a", "message1"
		nm.add new Notification "a", "message2"
		nm.add new Notification "b", "message3"

		equal nm.bucket("a").length, 2
		equal nm.bucket("b").length, 1

		same nm.bucket("a"), ["message1", "message2"]
		same nm.bucket("b"), ["message3"]
		
	test "buckets that don't exist at all", ->
		nm = new NotificationManager
		same nm.bucket("fake-bucket"), []
		nm.add new Notification "a", "message1"
		same nm.bucket("fake-bucket"), []

		nm = new NotificationManager ["a", "b", "c"]
		same nm.bucket("fake-bucket"), []
		nm.add new Notification "a", "message1"
		same nm.bucket("fake-bucket"), []
	
	module "notifications()"

	test "displayMethod: 'all' --> all messages come back", ->
		nm = new NotificationManager ["a", "b"], "all"
		equal nm._displayMethod, "all", "check that value actually stuck"

		nm.add new Notification "a", "message1"
		nm.add new Notification "a", "message2"
		nm.add new Notification "b", "message3"

		expected =
			a: ["message1", "message2"],
			b: ["message3"]
		
		same nm.notifications(), expected, "should have brought all messages out"

	test "displayMethod: 'all' --> only non-empty buckets come back", ->
		nm = new NotificationManager ["a", "b", "c"], "all"
		equal nm._displayMethod, "all", "check that value actually stuck"

		nm.add new Notification "b", "message3"

		expected =
			b: ["message3"]
		
		same nm.notifications(), expected, "should have excluded any empty buckets"

	test "displayMethod: 'all' --> handles 0 messages correctly", ->
		nm = new NotificationManager ["a", "b", "c"], "all"
		equal nm._displayMethod, "all", "check that value actually stuck"

		size = (x for x of nm.notifications()).length
		equal size, 0, "shouldn't bring back any buckets"
		same nm.notifications(), {}, "should have returned an empty map"

	test "displayMethod = priority --> only one bucket comes back", ->
		nm = new NotificationManager ["a", "b", "c"], "priority"
		equal nm._displayMethod, "priority", "check that value actually stuck"

		nm.add new Notification "a", "message1"
		nm.add new Notification "a", "message2"
		nm.add new Notification "b", "message3"
		
		size = (x for x of nm.notifications()).length
		equal size, 1, "should bring back only 1 bucket"
		
	test "displayMethod = priority --> only highest priority bucket gets returned", ->
		nm = new NotificationManager ["a", "b", "c"], "priority"
		equal nm._displayMethod, "priority", "check that value actually stuck"

		nm.add new Notification "b", "message1"
		nm.add new Notification "c", "message2"
		nm.add new Notification "c", "message3"
		
		size = (x for x of nm.notifications()).length
		equal size, 1, "should bring back only 1 bucket"

		bucket = (x for x of nm.notifications())[0]
		equal bucket, "b", "should bring back the correct bucket"

	test "displayMethod = priority --> only highest priority bucket gets returned, even if dynamically introduced", ->
		nm = new NotificationManager ["a", "b", "c"], "priority"
		equal nm._displayMethod, "priority", "check that value actually stuck"

		nm.add new Notification "e", "message1"
		nm.add new Notification "f", "message2"
		nm.add new Notification "g", "message3"
		
		size = (x for x of nm.notifications()).length
		equal size, 1, "should bring back only 1 bucket"

		bucket = (x for x of nm.notifications())[0]
		equal bucket, "e", "should bring back the correct bucket"

		nm.add new Notification "c", "message1"
		size = (x for x of nm.notifications()).length
		equal size, 1, "should bring back only 1 bucket"
		bucket = (x for x of nm.notifications())[0]
		equal bucket, "c", "should bring back the correct bucket"

		nm.add new Notification "b", "message1"
		size = (x for x of nm.notifications()).length
		equal size, 1, "should bring back only 1 bucket"
		bucket = (x for x of nm.notifications())[0]
		equal bucket, "b", "should bring back the correct bucket"

		nm.add new Notification "a", "message1"
		size = (x for x of nm.notifications()).length
		equal size, 1, "should bring back only 1 bucket"
		bucket = (x for x of nm.notifications())[0]
		equal bucket, "a", "should bring back the correct bucket"

	test "displayMethod: 'priority' --> handles 0 messages correctly", ->
		nm = new NotificationManager ["a", "b", "c"], "priority"
		equal nm._displayMethod, "priority", "check that value actually stuck"

		size = (x for x of nm.notifications()).length
		equal size, 0, "shouldn't bring back any buckets"
		same nm.notifications(), {}, "should have returned an empty map"

	true

#ERROR = "error"
#WARN = "warning"
#SUCCESS = "success"

#manager = new NotificationManager [ERROR, WARN, SUCCESS]

#err1 = new Notification ERROR, "error: must do something"
#err2 = new Notification ERROR, "error: must do something else"
#warn1 = new Notification WARN, "warning: maybe something"

#manager.add err1
#manager.add err2
#manager.add warn1
#manager.add new Notification "test", "test: test message"

#alert(manager.totalSize())

#alert(manager._displayMethod)
#manager.setDisplayMethod "priority"
#alert(manager._displayMethod)

#alert(manager.get("errors").toSource())
#alert(manager.get("nonexistent-bucket").toSource())

#alert(manager.get().toSource())
#manager.setDisplayMethod("all")
#alert(manager.get().toSource())

#alert(manager.listify("ul").toSource())
#alert(manager.listify("ul", WARN).toSource())
#alert(manager.listify("ul", 'bucket-that-doesnt-exist').toSource())

#buckets = manager.buckets()
#lists = manager.listify("ul")
#for div in buckets
#	alert("$('##{div}').hide()")
#for div of lists
#	alert("$('##{div}').append('#{lists[div]}')")
#	alert("$('##{div}').show()")

