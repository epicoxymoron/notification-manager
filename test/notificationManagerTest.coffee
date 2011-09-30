$ ->
	
	module "Constructor"

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
	
	module "setDisplayMethod()"

	test "test with valid values", ->
		nm = new NotificationManager
		nm.setDisplayMethod "all"
		equals "all", nm._displayMethod, "changed the value successfully"
		nm.setDisplayMethod "priority"
		equals "priority", nm._displayMethod, "changed the value successfully"
	
	test "test with invalid values", ->
		nm = new NotificationManager
		oldValue = nm._displayMethod
		nm.setDisplayMethod "some bad value"
		equals oldValue, nm._displayMethod, "kept the old value"
	
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

