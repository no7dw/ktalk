crypto = require 'crypto'
KTalk = require './ktalk1'
messageApi = require './message'
keyword = new (require './keyword')
rootPath = require('../../../config').getAppPath()

class Weixin
    constructor : (@appName, @token) ->       
        @kTalk = new KTalk @appName        
        @NLP = new(require('./fudanNLP'))
        try  
            mmseg = require('mmseg')
            @q = mmseg.open("#{rootPath}/apps/collector/etc/")
        catch err
            console.log err
            mmseg =null
            @q = null


    bind : (params, sig) ->        
        createSignature(@token, params.nonce, params.timestamp) is sig

    #chat : (username, msg, ResponseType , callback) ->
    chat : (username, msg, callback) ->
        self = @
        kTalk = @kTalk
        q = @q      
        NLP = @NLP  
        data = {FromUserName : msg.ToUserName, ToUserName : msg.FromUserName, CreateTime : Math.ceil(Date.now() / 1000)}
        msgValue = msg.Content || msg.Event
        NLP.KeyWordExtraction msg.Content  , (err, return_key_msg) ->
            if err
                callback err, ""
            else
                if not q
                    splitmsg_result = ''
                else
                    splitmsg_result = keyword.TransArrayWithSpace(q.segmentSync(msg.Content))

                kTalk.chat data.ToUserName, msgValue, msg.MsgType, {username : username, time : msg.CreateTime, splitmsg:  splitmsg_result, keymsg: return_key_msg }, (err, talkResponse) ->
                    if(kTalk.isTextChat(talkResponse))
                        data.MsgType = 'text'
                        data.Content = talkResponse.value
                        callback null, replyText data
                    else if(kTalk.isImageChat(talkResponse))
                        data.MsgType = 'news'
                        data.Articles = talkResponse.value;
                        callback null, replyPics data
                    messageApi.saveEvent (formatUserMessage username,  self.appName, msg), (err, msg) ->
                        if msg._id
                            res_tmp = formatReqOrRes(data)
                            res_tmp.AnsType = talkResponse.AnsType                    
                            messageApi.updateEvent msg._id, res:res_tmp
                            #messageApi.updateEvent msg._id, res:formatReqOrRes(data), @appName ,AnsType


    createSignature = (token, nonce, timestamp) ->
        tmp = [token, nonce, timestamp].sort()
        crp = crypto.createHash('sha1').update(tmp.join(''), 'utf8').digest('hex')        

    replyText = (data) ->
        "<xml><ToUserName><![CDATA[#{data.ToUserName}]]></ToUserName><FromUserName><![CDATA[#{data.FromUserName}]]></FromUserName><CreateTime>#{data.CreateTime}</CreateTime><MsgType><![CDATA[text]]></MsgType><Content><![CDATA[#{data.Content}]]></Content><FuncFlag>0</FuncFlag></xml>"

    replyPics = (data) ->
        result = ["<xml><ToUserName><![CDATA[#{data.ToUserName}]]></ToUserName><FromUserName><![CDATA[#{data.FromUserName}]]></FromUserName><CreateTime>#{data.CreateTime}</CreateTime><MsgType><![CDATA[news]]></MsgType><Content><![CDATA[#{data.Content}]]></Content>"]
        result.push "<ArticleCount>#{data.Articles.length}</ArticleCount><Articles>"
        for article in data.Articles
            result.push "<item><Title><![CDATA[#{article.title || ''}]]></Title><Description><![CDATA[#{article.description || article.title || ''}]]></Description><PicUrl><![CDATA[#{article.picUrl}]]></PicUrl><Url><![CDATA[#{article.url}]]></Url></item>"
        result.push "</Articles><FuncFlag>0</FuncFlag></xml>"
        result.join("")
    
    ###
    #   格式化各种message的特殊部分
    ###
    formatMessageDataMethod =
        text : (msg) ->
            content : msg.Content
        location : (msg) ->
            location :
                x : msg.Location_X  #地理位置纬度
                y : msg.Location_Y
            scale : msg.Scale #地图缩放大小
            Label : msg.Label
        image : (msg) ->
            picUrl : msg.PicUrl
        news : (msg) ->
            content : msg.Content
            articleCount : msg.Articles.length
            articles : msg.Articles
        event : (msg) ->
            r = event : msg.Event
            if msg.EventKey?.length
                r.eKey = msg.EventKey
            r

    formatReqOrRes = (msg) ->
        type : msg.MsgType #消息类型 text image location
        data : formatMessageDataMethod[msg.MsgType]?(msg)
        createTime : Number(msg.CreateTime)

    ###
    #   电商类判断
    ###
    CommercialRalative = (msg) ->
        keywords = ["买","卖","钱","价格","宝贝","商品","店铺","邮费","商家","消费","购买"]
        result3 = false
        msg = msg || ''        
        for k in keywords
            if -1 isnt msg.indexOf(k)
                return result3 = true

        return false

    ###
    #   根据问题保护的关键字判断问题的类型
    #   1.电商类
    #   2.非电商类
    ###
    judgeAskType = (msg) ->
        msg =msg||''
        result = keyword.do_keyword_check_cat msg
        result2 = keyword.do_keyword_check_tags msg
        result3 = CommercialRalative(msg)
        #result3 = keyword.isEcommercial msg
        if result || result2 ||result3
            type = 1
        else
            type = 2


    ###
    #   格式化message
    ###
    formatUserMessage = (username, appNameP, msg) ->        
        req_tmp = formatReqOrRes msg
        req_tmp.askType = judgeAskType msg.Content        
        message =
            #appName : 'weixincm'
            appName : appNameP
            username : username
            to: msg.ToUserName
            from : msg.FromUserName
            req: req_tmp

module.exports = Weixin
