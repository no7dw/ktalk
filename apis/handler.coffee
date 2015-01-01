_ = require 'underscore'
async = require 'async'
path = require 'path'
logger = require("../../../common/helpers/logger").getLogger __filename
util = require './util'

HANDLER_FILES_PATH = path.resolve __dirname, '../handler'
HANDLER_CONCURRENT_MAX = 1 #handler 并发处理数

class Handler
    constructor : () ->
        @handlers = []

        self = @
        getHandlerFilesName (err, filesName) ->
            async.forEach filesName, (fileName, callback)->
                getHandlerFromFile "#{HANDLER_FILES_PATH}/#{fileName}", (err, handlers)->
                    self.handlers = self.handlers.concat handlers.handlers
                    callback()
            , (err)->
                logger.error err if err

    ###
    #   回答来源类型
    ###
    ResponseType : (handlerName) ->        
        console.log handlerName
        if (-1 != (handlerName.indexOf 'user_')) and  (handlerName.indexOf('_defaults') == -1)
            AnsType = 1
        else if -1 != handlerName.indexOf 'editor_'  
            AnsType = 2
        else if (-1 != handlerName.indexOf('sys_')) and (handlerName.indexOf('sys_default') == -1)
            AnsType = 3  
        else if (-1 != handlerName.indexOf('user_'))  and  (handlerName.indexOf('_defaults') != -1)
            AnsType = 5               
        else if (-1 != handlerName.indexOf('default_cbd_')) or (handlerName.indexOf('sys_default') != -1)
            AnsType = 6
        else
            AnsType = 4
        console.log AnsType
        return AnsType

    ###
    #   执行handler
    ###
    doHandler : (handlerName, argus, options, callback) ->
        self = @
        @getHandler handlerName, {handlers:options.handlers}, (err, handler) ->
            if err
                callback err
            else
                AnsType = self.ResponseType  handlerName 

                options = options.env
                handler.handle argus, options, (err, value, matchScore) ->
                    if value
                        matchScore = matchScore || options.matchScore
                        matchScore = Math.min matchScore, 100
                        callback null, matchScore : matchScore, value : value, AnsType: AnsType
                    else
                        callback null, null

    ###
    #   批量执行handle
    #   按匹配度降序返回结果
    ###
    doHandlers : (handlers, options, callback) ->
        self = @
        handlerResults = []
        async.forEachLimit handlers, HANDLER_CONCURRENT_MAX, (handler, cbf) ->
            # 如果有结果便不再执行下面的handle
            if handlerResults.length
                cbf null
            else
                opts = _.extend {}, options
                opts.env.matchScore = handler.matchScore
                self.doHandler handler.handler, handler.argus, opts, (err, result) ->
                    if result
                        handlerResults.push result
                    cbf null
        , (err) ->
            handlerResults = _.sortBy handlerResults, (obj) ->
                return obj.matchScore || 0
            callback null, handlerResults.reverse()


    ###
    #  获取handler
    ###
    getHandler : (handlerName, options, callback) ->
        options = options || {}
        options.handlers = options.handlers || []
        for handler in @handlers.concat(options.handlers) when handlerName is handler.name
            return callback null, handler
        err = "handler #{handlerName} not found"
        logger.error err
        return callback err

    importHandlers : (handler, callback) ->
            @handlers = @handlers.concat(handler)
            callback null, @handlers


    removeHandlers : (namePattern, callback) ->
        tmp = []
        for h,i in @handlers
            if h.name.indexOf(namePattern) < 0
                tmp.push h
        @handlers = tmp
        callback null, @handlers

    ###
    #   读取handler文件列表
    ###
    getHandlerFilesName = (callback) ->
        util.getDirFilesName HANDLER_FILES_PATH, callback


    getHandlerFromFile = (filePath, callback) ->
        util.getModuleFromFile filePath, callback

module.exports = new Handler