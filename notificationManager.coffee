class Notification
	constructor: (@bucket, @message) ->

class NotificationManager

	@displayMethod = "priority"

	constructor: (buckets, @displayMethod = "all") ->
		@buckets = {} 
		@bucketList = []
		for bucket in buckets
			@buckets[bucket] = []
			@bucketList.push(bucket)

	clear: (bucketName = null) ->
		if bucketName is null
			for bucket in @buckets
				@buckets[bucketName] = []
		else
			@buckets[bucketName] = []
		true

	add: (note) ->
		if note.bucket in @bucketList
			@buckets[note.bucket].push(note.message)
		else
			@buckets[note.bucket] = [note.message]
			@bucketList.push(note.bucket)
		true

	getBucket: (bucketName) ->
		return @buckets[bucketName] or []

	buckets: ->
		return @bucketList

	totalSize: ->
		(@buckets[x].length for x of @buckets).reduce (t, s) -> t + s

	setDisplayMethod: (method) ->
		if method in ["all", "priority"]
			@displayMethod = method
			true
		else
			false
	
	notifications: ->
		retVal = {}
		for bkt in @bucketList
			if @buckets[bkt].length > 0
				retVal[bkt] = @buckets[bkt]
				if @displayMethod == "priority"
					return retVal
		return retVal

ERROR = "error"
WARN = "warning"
SUCCESS = "success"

manager = new NotificationManager [ERROR, WARN, SUCCESS]

err1 = new Notification ERROR, "error: must do something"
err2 = new Notification ERROR, "error: must do something else"
warn1 = new Notification WARN, "warning: maybe something"

manager.add err1
manager.add err2
manager.add warn1

#alert(manager.totalSize())

#alert(manager.displayMethod)
#manager.setDisplayMethod "priority"
#alert(manager.displayMethod)

#alert(manager.get("errors").toSource())
#alert(manager.get("nonexistent-bucket").toSource())

alert(manager.get().toSource());
manager.setDisplayMethod("priority");
alert(manager.get().toSource());
