#### Notifications

# A **Notification** is really just a collection of the message itself and
# the bucket it belongs to.
class Notification
	constructor: (@bucket, @message) ->

#### The Manager

# The **NotificationManager** collects the notifications and determines what's
# important enough to display
class NotificationManager

	# Take in a list of bucket names ordered by their priority and a display
	# method (optional)
	constructor: (buckets, @displayMethod = "priority") ->
		@buckets = {}
		@bucketList = []
		for bucket in buckets
			@buckets[bucket] = []
			@bucketList.push(bucket)

	# Clears a single bucket if a bucket name is given, or all buckets if 
	# called with no arguments.
	clear: (bucketName = null) ->
		if bucketName is null
			for bucket in @buckets
				@buckets[bucketName] = []
		else
			@buckets[bucketName] = []
		true

	# Adds a notification to a bucket.  If the bucket doesn't exist, it will
	# be created at the lowest priority
	add: (note) ->
		if note.bucket in @bucketList
			@buckets[note.bucket].push(note.message)
		else
			@buckets[note.bucket] = [note.message]
			@bucketList.push(note.bucket)
		true

	# Gets the list of messages for a bucket, or if the bucket doesn't exist,
	# returns an empty list
	getBucket: (bucketName) ->
		return @buckets[bucketName] or []

	# Gets a list of registered buckets
	buckets: ->
		return @bucketList

	# Magically returns the number of messages stored across all buckets.
	# To get the number of messages in a single bucket, it's just
	# `manager.get(bucketName).length`
	totalSize: ->
		(@buckets[x].length for x of @buckets).reduce (t, s) -> t + s

	# Sets the display method if the value is valid
	#
	# Valid values are "all" and "priority".
	# "all" will return all messages no matter their bucket, whereas
	# "priority" will return all messages in the highest existent priority
	setDisplayMethod: (method) ->
		if method in ["all", "priority"]
			@displayMethod = method
			true
		else
			false
	
	# Retrieves the relevant notifications based on the displayMethod
	# and what's been stored
	notifications: ->
		retVal = {}
		for bkt in @bucketList
			if @buckets[bkt].length > 0
				retVal[bkt] = @buckets[bkt]
				if @displayMethod == "priority"
					return retVal
		return retVal
	
	# Creates an HTML list out of the relevant notifications.  Pass in a
	# list container (either "ol" or "ul") and you'll get back a map of:
	#
	#	{
	#		bucket1: "<ol><li>Message 1</li><li>Message 2</li>"
	#		bucket2: "<ol><li>Message A</li><li>Message B</li>"
	#	}
	listify: (container, bucket = null) ->
		# only accept ul and ol for now
		if container not in ["ul", "ol"]
			return {}
		inner = "li"
		retVal = "<#{container}>"
		# only do the notifications we care about
		if bucket isnt null
			notes = {}
			notes[bucket] = @getBucket(bucket)
		else
			notes = @notifications()
		for bucket of notes
			messages = notes[bucket]
			# don't put the container around an empty list.
			# TODO: revisit this decision at some point
			if messages.length > 0
				messageList = "<#{container}>" 
				for message in messages
					message = "<#{inner}>#{message}</#{inner}>"
					messageList += message
				messageList += "</#{container}>"
			else
				messageList = ""
			notes[bucket] = messageList
		return notes

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
manager.add new Notification "test", "test: test message"

#alert(manager.totalSize())

#alert(manager.displayMethod)
#manager.setDisplayMethod "priority"
#alert(manager.displayMethod)

#alert(manager.get("errors").toSource())
#alert(manager.get("nonexistent-bucket").toSource())

#alert(manager.get().toSource())
#manager.setDisplayMethod("all")
#alert(manager.get().toSource())

alert(manager.listify("ul").toSource())
alert(manager.listify("ul", WARN).toSource())
alert(manager.listify("ul", 'bucket-that-doesnt-exist').toSource())
