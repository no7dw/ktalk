request = require 'request'
Redis = require('klgredis').getClient('klgRedisServer')
exec = require('child_process').exec
logger = require('../../../common/helpers/logger').getLogger __filename
SIMSIMI_API_URL = 'http://www.simsimi.com/func/req?lc=ch&msg='
SIMSIMI_REFERER = 'http://www.simsimi.com/talk.htm?lc=ch'
USER_AGENT = 'Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.64 Safari/537.11'
COOKIE = 'JSESSIONID=E6E8C23E3E9D005DC6CD393685126403' #TODO

callSimsimi = (text, callback) ->
    console.time 'simsimi'
    exec "curl -b '#{COOKIE}' -e '#{SIMSIMI_REFERER}' '#{SIMSIMI_API_URL + text}'", (err, stdout, stderr) ->
        console.timeEnd 'simsimi'
        if err
            logger.error err
            callback err
        else 
            try
                obj = JSON.parse stdout
            catch err
                logger.error err
                callback err
            if obj?.id > 1 and obj?.response
                if filter obj.response
                    callback null, obj.response
                else
                    callback 'bad reply'
            else
                err = "something wrong, err: #{JSON.stringify(obj)}"
                logger.error err
                callback err

filter = (text) ->
    msg = text.replace /\s/g, ''
    keywords = ['微信']
    for k in keywords
        if -1 isnt msg.indexOf(k)
            return false
    return true

module.exports =
    handlers : [
        {
            name:"simsimi",
            handle:(argus, options, callback) ->
                msg = argus[0]
                callSimsimi msg, (err, text) ->
                    if err
                        callback null, null
                    else
                        messages = ['你喜欢什么宝贝？发个关键词给我看看吧~',
                                    '喜欢我吧，快分享给朋友吧~',
                                    '试试输入 包邮 新款 折扣 看看有什么惊喜？',
                                    '你觉得我们这个账号怎么样，说实话哈？']
                        id = 'wechat_' + options.from
                        Redis.get id, (err, val) ->
                            if val is null
                                Redis.set id, '1,0,1,2,3'
                            else
                                arr = val.split ','
                                if arr.length > 1
                                    arr[0] = parseInt(arr[0]) + 1
                                    console.log arr
                                    if arr[0] % 5 is 0
                                        index = Math.floor(Math.random() * (arr.length - 2)) + 1
                                        msg = messages[parseInt(arr[index])]
                                        console.log index, arr[index]
                                        arr.splice index, 1
                                        text += "\n" + msg
                                    Redis.set id, arr.join ','
                            callback null, type : 'text', value : text
        }
    ]