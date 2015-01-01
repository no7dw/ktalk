util = require 'util'
events = require 'events'
request = require 'request'
logger = require("../../../common/helpers/logger").getLogger __filename

TRY_TIMES = 3
TRY_INTERVAL = 5000

class Communication
    constructor : () ->
        @on 'bind', bind

    bind = (data, self, tryTimes) ->
        request.post {
            url:'http://weixin.awang.com/weixincm/communication/bind'
            json: data
        }, (error, response, body) ->
            if error or response?.statusCode isnt 200 or body.code
                logger.error "request bind failed err: #{error}, statusCode: #{response?.statusCode}, body: #{JSON.stringify(body)}"
                if --tryTimes
                    setTimeout ()->
                        logger.debug 'request bind failed. try again'
                        self.bind data, tryTimes
                    , TRY_INTERVAL
            else
                logger.info 'request bind success.'


util.inherits Communication, events.EventEmitter

Communication::bind = (data, tryTimes) ->
    tryTimes = tryTimes || ( typeof tryTimes is 'undefined' && TRY_TIMES )
    @emit 'bind', data, @, tryTimes



com = new Communication
module.exports = com