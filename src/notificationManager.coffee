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
	# method (optional), defaulting to "priority"
	constructor: (buckets = [], displayMethod = "priority") ->
		@_buckets = {}
		@_bucketList = []
		for bucket in buckets
			@_buckets[bucket] = []
			@_bucketList.push(bucket)
		# take care to handle badly formed input
		if not @setDisplayMethod displayMethod
			@_displayMethod = "priority"

	# Clears a single bucket if a bucket name is given, or all buckets if 
	# called with no arguments.
	clear: (bucketName = null) ->
		if bucketName is null
			for bucket of @_buckets
				@_buckets[bucket] = []
		else
			@_buckets[bucketName] = []
		true

	# Adds a notification to a bucket.  If the bucket doesn't exist, it will
	# be created at the lowest priority
	add: (note) ->
		if not note.bucket?
			false
		if note.bucket in @_bucketList
			@_buckets[note.bucket].push(note.message)
		else
			@_buckets[note.bucket] = [note.message]
			@_bucketList.push(note.bucket)
		true

	# Gets the list of messages for a bucket, or if the bucket doesn't exist,
	# returns an empty list
	bucket: (bucketName) ->
		return @_buckets[bucketName] or []

	# Gets a list of registered buckets
	buckets: ->
		return @_bucketList

	# Magically returns the number of messages stored across all buckets.
	# To get the number of messages in a single bucket, it's just
	# `manager.get(bucketName).length`
	totalSize: ->
		(@_buckets[x].length for x of @_buckets).reduce ((a, b) -> a + b), 0

	# Sets the display method if the value is valid
	#
	# Valid values are "all" and "priority".
	# "all" will return all messages no matter their bucket, whereas
	# "priority" will return all messages in the highest existent priority
	setDisplayMethod: (method) ->
		if method in ["all", "priority"]
			@_displayMethod = method
			true
		else
			false
	
	# Retrieves the relevant notifications based on the displayMethod
	# and what's been stored
	notifications: ->
		retVal = {}
		for bkt in @_bucketList
			if @_buckets[bkt].length > 0
				retVal[bkt] = @_buckets[bkt]
				if @_displayMethod == "priority"
					return retVal
		return retVal
	
	# Creates an HTML list out of the relevant notifications.  Pass in a
	# list container (either "ol" or "ul") and you'll get back a map of:
	#
	#     {
	#       bucket1: "<ol><li>Message 1</li><li>Message 2</li>"
	#       bucket2: "<ol><li>Message A</li><li>Message B</li>"
	#     }
	listify: (container, bucket = null) ->
		# only accept ul and ol for now
		if container not in ["ul", "ol"]
			return {}
		inner = "li"
		retVal = "<#{container}>"
		# only do the notifications we care about
		if bucket isnt null
			notes = {}
			notes[bucket] = @bucket(bucket)
		else
			notes = @notifications()
		for bucket of notes
			messages = notes[bucket]
			# don't put the container around an empty list.
			#
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
