# The **NotificationManager** collects notifications and determines which ones are
# important enough to return.
#
# There are a couple of different types of ways of determining which buckets
# to return, and they have different rules associated with them.  So, without
# further ado...
#
# * Setting displayMethod = "all" means that any time @notifications() is called,
# all non-empty buckets will be returned.
# * Setting displayMethod = "priority" means that the buckets added in the constructor
# are assumed to be in a sorted order (highest-priority first), with any 
# dynamically added buckets being of a lower priority than those entered on the 
# constructor, and that when @notificaitons() is called, it will return the 
# single highest-priority bucket that isn't empty.
# * Setting displayMethod = "threshold" takes in an additional displayArgument, which 
# corresponds to a bucket which must exist at the time the displayMethod is set.  For 
# example, to construct the manager using the threshold setting, then the bucket marked 
# as the threshold must be in the bucket list at the time of construction.  A 
# **NotificationManager** instance can be turned into "threshold" mode at any time so 
# long as the bucket marked as the threshold exists at the time of the setter.  So,
# the following is legal:
#
#         nm = new NotificationManager ['a', 'b', 'c']
#         nm.add new Notification 'x', 'message'
#         nm.setDisplayMethod 'threshold', 'x'

#### Notifications
#
# A **Notification** is really just a collection of the message itself and
# the bucket it belongs to.
class Notification
	constructor: (@bucket, @message) ->

#### The Manager
#
# Handles the collection and logic of returning certain messages
class NotificationManager

	# Take in a list of bucket names ordered by their priority and a display
	# method (optional), defaulting to "priority"
	constructor: (buckets = [], displayMethod = "priority", displayArguments) ->
		@_buckets = {}
		@_bucketList = []
		for bucket in buckets
			@_buckets[bucket] = []
			@_bucketList.push(bucket)
		# Reject badly formed input
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
	# `manager.bucket(bucketName).length`
	totalSize: ->
		(@_buckets[x].length for x of @_buckets).reduce ((a, b) -> a + b), 0

	# Sets the display method if the value is valid
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
		switch @_displayMethod
			when "all" then @_notifications_all()
			when "priority" then @_notifications_priority()
			when "threshold" then @_notifications_threshold()

	_notifications_all: ->
		retVal = {}
		for bkt in @_bucketList
			if @_buckets[bkt].length > 0
				retVal[bkt] = @_buckets[bkt]
		return retVal
	
	_notifications_priority: ->
		for bkt in @_bucketList
			if @_buckets[bkt].length > 0
				return @_buckets[bkt]
		return []
	
	_notifications_threshold: ->
		retVal = {}
		for bkt in @_bucketList
			if @_buckets[bkt].length > 0
				retVal[bkt] = @_buckets[bkt]
			if @_displayThreshold == bkt
				return retVal
		return retVal
		
