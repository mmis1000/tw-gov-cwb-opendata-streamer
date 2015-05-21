class UpdateEvent
  constructor: (@name, @item)->
    @type = 'update'

module.exports = UpdateEvent

