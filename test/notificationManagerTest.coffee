$ ->
	
	module "Constructor"

	test "1 argument", ->
		list = ["A", "B", "C"]
		nm = new NotificationManager list
		same nm._bucketList, list, "bucketList should be match the parameters"
		same nm._displayMethod, "priority", "priority should be the displayMethod initially"
	
	test "no arguments", ->
		nm = new NotificationManager
		same nm._bucketList, [], "bucketList should be empty initially"
		same nm._displayMethod, "priority", "priority should be the displayMethod initially"
	
	test ".setDisplayMethod()", ->
		ok true, "this test is fine"
		value = "hello"
		equal value, "hello", "We expect value to be hello"
	
	test "some other test", ->
		expect 2
		equal true, false, "failing test"
		equal true, true, "passing test"
	
	true
