###
#   Pattern
###
_ = require 'underscore'
async = require 'async'
util = require './util'
path = require 'path'
#logger = require("log4js").getLogger __filename

PATTERN_FILES_PATH = path.resolve __dirname, '../pattern1'
TEMPLATE_FILES_PATH = path.resolve __dirname, '../template'

MATCH_PATTERN_MAX_TIMES = 10

class Pattern
    constructor : () ->
        @patterns = []

        self = @
        getPatternFilesName (err, filesName) ->
            async.forEach filesName, (fileName, callback)->
                getPatternFromFile "#{PATTERN_FILES_PATH}/#{fileName[0]}/#{fileName[1]}", (err, patterns)->
                    for p in patterns.patterns
                        p.package = fileName[0]
                        self.patterns.push p
                    callback()
            , (err)->
                self.patterns = _.sortBy self.patterns, (obj) ->
                    return obj.priority || 9999

    ###
    #   获取匹配的规则
    ###
    getMatchPatterns : (msg, msgType, options, callback) ->              
        if not callback and _.isFunction options
            callback = options
            options = {}
        self = @
        totalPatterns = self.patterns
        if options.patterns and _.isArray options.patterns
            totalPatterns = totalPatterns.concat options.patterns
            totalPatterns = _.sortBy totalPatterns, (obj) ->
                return obj.priority || 0
        msg = msg.toLowerCase().replace /\s/g, ''
        matchPatterns = []
        async.forEachLimit totalPatterns, 10, (pattern, callback) ->
            if msgType is self.getMsgType(pattern) and _.indexOf(options.patternList, pattern.package) isnt -1                
                #self.doPattern pattern, msg, {}, (err, matchScore, handler, argus)->                                    
                self.doPattern pattern, msg, options, (err, matchScore, handler, argus)->
                    if matchScore > 0
                        matchPatterns.push {matchScore : matchScore, handler : handler, argus : argus}
                        #当匹配次数达到 MATCH_PATTERN_MAX_TIMES 则不再匹配
                        if matchPatterns.length >= MATCH_PATTERN_MAX_TIMES
                            callback {code : 1, msg : 'match limit'}
                        else
                            callback null
                    else
                        callback null
            else
                callback null
        , (err) ->
            if matchPatterns.length
                mps = _.sortBy matchPatterns, (obj) ->
                    return -1 * obj.matchScore || 0
                callback null, mps
            else #use default handler
                index = totalPatterns.length - 1
                while (index >= 0) and (-1 is _.indexOf(options.patternList, totalPatterns[index].package))
                    index--
                if index >= 0
                    self.doPattern totalPatterns[index], msg, {}, (err, matchScore, handler, argus)->
                    #self.doPattern totalPatterns[index], msg, options, (err, matchScore, handler, argus)->
                        matchPatterns.push matchScore : matchScore, handler : handler, argus : argus
                        callback null, matchPatterns



    getPatterns : (callback) ->
        callback null, @patterns

    ###
    #   执行匹配
    ###
    doPattern : (pattern, msg, options, callback) ->
        pattern.pattern msg, options, (err, matchScore, handler, argus) ->
            matchScore = Math.min(matchScore, 100)   #最大100%匹配
            argus = [] if !argus
            argus.unshift msg            
            callback err, matchScore, handler, argus


    importPatterns : (patterns, callback) ->
        @patterns = _.sortBy @patterns.concat(patterns), (obj) ->
            return obj.priority || 9999
        callback null, @patterns


    removePatterns : (namePattern, callback) ->
        tmp = []
        for p,i in @patterns
            if p.name.indexOf(namePattern) < 0
                tmp.push p
        @patterns = tmp
        callback null, @patterns


    ###
    #   返回pattern匹配的信息类型
    ###
    getMsgType: (pattern) ->
        pattern.msgType

    ###
    #   读取pattern文件列表
    ###
    getPatternFilesName = (callback) ->
        util.getDirDirsName PATTERN_FILES_PATH, (err, dirs) ->
            results = [];
            async.forEachLimit dirs, 10, (dir, callback) ->
                util.getDirFilesName "#{PATTERN_FILES_PATH}/#{dir}", (err, filesName) ->
                    for file in filesName
                        results.push [dir, file]
                    callback null
            , () ->
                callback null, results

    ###
    #   从json文件读取pattern
    ###
    getPatternFromFile = (filePath, callback) ->
        util.getModuleFromFile filePath, callback


pattern = new Pattern
module.exports = pattern