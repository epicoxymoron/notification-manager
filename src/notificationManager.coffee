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
	constructor: (buckets = [], displayMethod = "priority", displayArguments) ->
		@_buckets = {}
		@_bucketList = []
		for bucket in buckets
			@_buckets[bucket] = []
			@_bucketList.push(bucket)
		# take care to handle badly formed input
		if not @setDisplayMethod displayMethod, displayArguments
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
		@_buckets[bucketName] or []

	# Gets a list of registered buckets
	buckets: ->
		@_bucketList

	# Magically returns the number of messages stored across all buckets.
	# To get the number of messages in a single bucket, it's just
	# `manager.get(bucketName).length`
	totalSize: ->
		(@_buckets[x].length for x of @_buckets).reduce ((a, b) -> a + b), 0

	# Sets the display method if the value is valid
	#
	# Valid values are:
	#
	# * "all" will return all non-empty buckets and the messages contained in them.
	# * "priority" will rank all buckets by priorty level and return all the messages 
	# from the highest priority non-empty bucket.
	# * "threshold" requires an extra argument which acts as the lower bound on the 
	# priority level of returned messages.  returns all non-empty buckets of that
	# priority level or higher.
	setDisplayMethod: (method, arg) ->
		switch method
			when "threshold"
				if arg in @_bucketList
					@_displayMethod = method
					@_displayThreshold = arg
					true
				else
					false
			when "all", "priority"
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
				if @_displayMethod == "priority"
					return @_buckets[bkt]
				else
					retVal[bkt] = @_buckets[bkt]
			if @_displayMethod == "threshold" and @_displayThreshold == bkt
				return retVal
		return retVal
	
