###
#   KTalk Robot
###
async = require 'async'
_ = require 'underscore'
config = require '../../../config'
appPath = config.getAppPath()
ktalkConfig = require '../config'
pattern = require './pattern1'
handler = require './handler'
userPatternApi = require '../../weixincm/apis/pattern'
klgMongoDb = require 'klgmongodb'
#MemberManage = require "#{appPath}/apps/ktalk/controllers/member" #公众平台模拟失败
#database connection
server = {host : 'koala', port : 27017}
if config.isProductionMode()
    server = {host : 'butterfly.local', port : 27017}

mongodbClient = klgMongoDb.initClient server, 'taobao', {'slave_ok' : true, readPreference : 'secondary'}, (err) ->

onepieceMongoDb = klgMongoDb.getClient('onepiece_item', 'items');
onepieceMongoDb_wx = klgMongoDb.getClient('onepiece_item', 'weixinjournal');

special_url = 'www.chaobaida.com'

class KTalk
    constructor : (@appName) ->

    chat : (who, msg, msgType, options, callback) ->        
        msg = msg || ''
        msgType = msgType || 'text'
        self = @
        #TODO 优化 先检查是否需要用户的pattern
        userPatternApi.getUserPatternAndHandler {username : options.username}, (err, patternsAndHandlers) ->            
            userPatterns = []
            userHandlers = []
            for p in patternsAndHandlers
                userPatterns.push p.pattern
                userHandlers.push p.handler
            patternList = self.getAppPatternList()            
            #MemberManage.getUserinfo options.username, {username : who, time : options.time, msg : msg, msgType : msgType}, (err, userinfo) -> #无法匹配用户信息
            opts =
                env:
                    username : options.username
                    #userinfo : userinfo
                    from : who
                    splitmsg : options.splitmsg
                    keymsg: options.keymsg
                handlers : userHandlers      
            pattern.getMatchPatterns msg, msgType, {patterns : userPatterns, patternList : patternList, splitmsg: options.splitmsg, keymsg: options.keymsg}, (err, matchPatterns)->                    
                handler.doHandlers matchPatterns, opts, (err, results)->
                    self.doHandlerValue results, callback

    ###
    #   提供给插件的数据库查询
    ###
    getQueryResults : (query, options, callback) ->
        options = options || {}
        options.limit = options.limit || 20
        options.skip = options.skip || 0
        fields = options.fields || null
        client = mongodbClient

        if 'onepiece_item' is options.db
            #shb database
            pattern_return = {
                title:"#{options.username}的"
            }
            tmp = "#{options.username}的"
            fields = options.fields || "iid title uTitle iPrice pUrl uPic cUrl"
            onepieceMongoDb.find query, fields, {limit : options.limit, sort : options.sort}, (err, docs) ->
                if err
                    console.log err
                    docs = []
                docs = _.map docs, (doc) -> 
                    id : doc.iid                   
                    title: doc.uTitle || doc.title
                    price: doc.picUrl
                    picUrl: doc.uPic || doc.pUrl
                    clickUrl:  doc.cUrl
                    #console.log doc.cUrl
                callback null, docs
        else
            #taobao database
            fields = options.fields || "id title price picUrl clickUrl"
            mongodbClient.find 't_Item', query, fields, {limit : options.limit, sort : options.sort, read:'secondaryPreferred'}, (err, docs) ->
                if err
                    console.log err
                    docs = []
                callback null, docs

    ###
    #   提供给插件的数据库查询weixinjournal
    ###
    getQueryResults_wxjournal : (query, options, callback) ->
        options = options || {}
        options.limit = options.limit || 20
        options.skip = options.skip || 0
        fields = options.fields || null
        client = mongodbClient

        if 'onepiece_item' is options.db
            #shb database
            fields = options.fields || "title desc imgURL url options Answer html"
            onepieceMongoDb_wx.find query, fields, {limit : options.limit, sort : options.sort}, (err, docs) ->
                if err
                    console.log err
                    docs = []                
                docs = _.map docs, (doc) ->
                    title: doc.title
                    desc: doc.desc
                    picUrl: doc.imgURL
                    url: doc.url 
                    options:doc.options 
                    Answer:doc.Answer  
                    html:doc.html            
                callback null, docs
        else
            #taobao database
            fields = options.fields || "id title price picUrl clickUrl"
            mongodbClient.find 't_Item', query, fields, {limit : options.limit, sort : options.sort}, (err, docs) ->
                if err
                    console.log err
                    docs = []
                callback null, docs



    ###
    #   根据条件返回Item
    #   TODO 移动到template
    ###
    getItemQueryHandle = (options, query, sort, callback) ->
        num = options.num || 5
        sort = sort || null
        mongodbClient.find 't_Item', query, "id title price picUrl clickUrl", {limit : num, sort : sort}, (err, items) ->
            if err
                console.log err
                items = []
            results = for item in items
                id : item.id, title : item.title, description : "价格 ￥#{item.price}", picUrl : item.picUrl, url : item.clickUrl || "http://item.taobao.com/item.htm?id=#{item.id}"

            #pics size            
            if results[0].picUrl.indexOf(special_url) == -1                
                results[0]?.picUrl = results[0].picUrl + '_310x310.jpg'

            for result, i in results
                continue if i is 0
                if results[i].picUrl.indexOf(special_url) == -1                    
                    results[i].picUrl  +=  '_80x80.jpg'
                
            callback null, value:results, type:'image'

    picHandle = (images, callback) ->
        results = for img in images
            title : img.title, description : img.desc, picUrl : img.picUrl, url : img.url
        callback null, value:results, type:'image'

    itemHandle = (items, callback) ->
        results = for item in items
            id : item.id, title : item.title, description : "价格 ￥#{item.price}", picUrl : item.picUrl, url : item.clickUrl || "http://item.taobao.com/item.htm?id=#{item.id}"
        #pics size
        if results[0].picUrl.indexOf(special_url) == -1            
            results[0]?.picUrl = results[0].picUrl + '_310x310.jpg'

        for result, i in results
            continue if i is 0
            if results[i].picUrl.indexOf(special_url) == -1
                results[i].picUrl += '_80x80.jpg'
        callback null, value:results, type:'image'

    ###
    #   执行完handler的汇总工作
    ###
    doHandlerValue : (values, callback) ->
        self = @
        result = null
        i = 0
        async.whilst ()->
            i < values.length and (not result or (_.isArray(result.value) and not result.value.length))
        , (callback) ->
            temp = values[i++]
            value = temp.value
            
            #value.AnsType 
            switch self.getHandlerValueType(value)
                when 'text'
                    result = value     
                    result.AnsType = temp.AnsType                
                    callback null
                when 'query' then getItemQueryHandle {num:value.num}, value.query, value.sort, (err, item) ->
                    result = item
                    result.AnsType = temp.AnsType 
                    callback null
                when 'image' then picHandle value.value, (err, pic) ->
                    result = pic
                    result.AnsType = temp.AnsType 
                    callback null
                when 'item' then itemHandle value.value, (err, val) ->
                    result = val
                    result.AnsType = temp.AnsType 
                    callback null
        , (err) ->
            if err
                callback err
            else                
                callback null, result

#        async.mapLimit values, 10, (v, callback)->
#            value = v.value
#            switch self.getHandlerValueType(value)
#                when 'text' then callback null, value
#                when 'query' then getItemQueryHandle {num:value.num}, value.query, value.sort, callback
#                when 'image' then picHandle value.value, callback
#            return
#        , (err, results) ->
#            if err
#                callback err
#            else
#                for r in results
#                    if r.type isnt 'image' or r.value.length
#                        callback null, r
#                        break;

    getAppPatternList : () ->
        ktalkConfig.patternList[@appName] || []

    getHandlerValueType : (value) ->
        value.type

    isTextChat : (chatRes) ->
        chatRes.type is 'text'

    isImageChat : (chatRes) ->
        chatRes.type is 'image'

    next = () ->


module.exports = KTalk