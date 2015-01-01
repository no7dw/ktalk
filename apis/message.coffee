util = require 'util'
events = require 'events'
ObjectApi = require '../../../common/apis/objects/object'
logger = require('../../../common/helpers/logger').getLogger __filename

EVENT_SAVE = 'msg_event_save'
EVENT_UPDATE = 'msg_event_update'

messageApi = new ObjectApi 'ktalk_message'

class Message
    constructor : () ->

util.inherits Message, events.EventEmitter

Message::saveEvent = (data, cbf) ->
    @emit EVENT_SAVE, data, cbf

Message::updateEvent = (id, data, cbf) ->
    @emit EVENT_UPDATE, id, data, cbf

msg = new Message

###
#   保存信息
###
msg.on EVENT_SAVE, (data, cbf) ->
    messageApi.create data, (err, msg) ->
        logger.error err if err
        if cbf
            cbf err, msg

###
#   保存信息
###
msg.on EVENT_UPDATE, (id, data, cbf) ->
    messageApi.update id, {$set:data}, (err, msg) ->
        logger.error err if err
        if cbf
            cbf err, msg

module.exports = msg