xml2js = require 'xml2js'
WeixinApi = require '../apis/weixin'
userApi = require '../../weixincm/apis/user'
communicate = require '../apis/communication'

class WeiXinHandler
    constructor: () ->

    ###
    #   公众平台验证接口
    ###
    valid: (req, res, cbf) ->
        params = req.query
        params.username = req.params.username
        userApi.getToken params.username, (err, token) ->
            params.token = token
            valid getAppName(req.url), params
            ret = 'not ok'
            if valid req.query
                ret = req.query.echostr
                communicate.bind {username: params.username, token: params.token}
            cbf null, ret, {'Content-Type' : 'text/html'}

    ###
    #   公众平台回复接口
    ###
    reply: (req, res, cbf) ->
        console.log req.rawBody
        query = req.query
        query.username = req.params.username
        userApi.getToken query.username, (err, token) ->
            query.token = token
            if not valid query
               return cbf null, 'something wrong', {'Content-Type' : 'text/html'}
            parser = new xml2js.Parser
            parser.parseString req.rawBody, (err, result) ->
                result = result.xml
                msg = {}
                for field, value of result
                    msg[field] = value[0];
                weixinApi = new WeixinApi getAppName(req.url), token
                xmlResponse = weixinApi.chat query.username, msg, (err, xmlResponse)->
                    console.log xmlResponse
                    cbf null, xmlResponse, {"Content-Type" : 'application/xml' }



    ###
    #   签名验证
    ###
    valid = (query) ->
        weixinApi = new WeixinApi '', query.token        
        signParams = {
            timestamp : query.timestamp,
            nonce : query.nonce
        }
        weixinApi.bind signParams, query.signature

    getAppName = (url) ->
        result = url.match(/\/(\w+)\//)
        result?[1] || ''

module.exports = new WeiXinHandler