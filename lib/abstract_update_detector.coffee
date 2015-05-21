{EventEmitter} = require 'events'
UpdateEvent = require './update_event'
class AbstractDetector extends EventEmitter
  constructor: (@defultInterval = 30 * 60 * 1000)->
    @urlMap = {}
    @datas = {}
    @destroyed = false
    
  addURL: (name, url, interval = @defultInterval)->
    @urlMap[name] = {
      url : url,
      interval : interval,
      _intervalId : null
    }
    @fetchStart()
    
  fetchStart: ()->
    for key, value of @urlMap
      if value._intervalId is null
        @fetch key, value.url
        value._intervalId = setInterval ()=>
          @fetch key, value.url
        , value.interval
    
  fetch: (name, url)->
    # abstract
  
  handle: (name, item)->
    @emit 'data', name, item
    parsedItem = @parse item
    
    @emit 'item_parsed', name, parsedItem
    
    itemDiff = @itemDiff parsedItem, @urlMap[name]
    
    @emit 'diff', name, itemDiff
    
    if Array.isArray itemDiff
      for diff in itemDiff
        @notifyUpdate name, diff
    else if itemDiff?
      @notifyUpdate name, itemDiff
    
  parse: (data...)->
    # abstract
    
  itemDiff: (newItem, datas)->
    # abstract
    
    #return (null|undefined) or (array of)? item
  
  _destroy: (name, datas)->
    # abstract
    # shutdown all connection here
    #return (null|undefined) or (array of)? item
  
  notifyUpdate: (name, itemDiff)->
    @emit 'update', new UpdateEvent name, itemDiff
    @emit "update_#{name}", new UpdateEvent name, itemDiff
  
  destroy: ()->
    for key, value of @urlMap
      clearInterval value._intervalId if value._intervalId?
      @_destroy key, value
    @urlMap = null
    @destroyed = true
  
module.exports = AbstractDetector