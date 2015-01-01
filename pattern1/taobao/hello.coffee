config = require '../../config'

module.exports =
    patterns : [
        {
            name : 'sys_focus'
            msgType : 'text'
            pattern : (msg, options, callback) ->
                if -1 isnt msg.indexOf "hello2bizuser"
                    callback null, 9999, "sys_guide"
                else
                    callback null, 0
            priority:1
        }
        {
            name : 'sys_focus_2'
            msgType : 'event'
            pattern : (msg, options, callback) ->
                if -1 isnt msg.indexOf "subscribe"
                    callback null, 95, "sys_guide"
                else
                    callback null, 0
            priority:1
        }
        {
            name:"sys_hello"
            msgType : 'text'
            pattern: (msg, options, callback) ->
                keywords = ["hi", "hello", "你好", "您好", "亲", "在吗", "在?", "在？", "晚安", "睡觉", "休息", "晚上好", "早上好", "早啊", "早晨"]
                for k in keywords
                    if msg.indexOf(k) isnt -1
                        return callback null, k.length * 100 / msg.length, "sys_hello", [k]
                return callback null, 0
            priority:99
        }
        {
            name : 'sys_help'
            msgType : 'text'
            pattern: (msg, options, callback) ->
                keywords = ["帮助", "help", "faq", "怎么用", "什么用", "用途", "说明", "解释", "什么玩意"]
                for k in keywords
                    if msg.indexOf(k) isnt -1
                        return callback null, k.length * 100 / msg.length, "sys_guide"
                return callback null, 0
            priority:99
        }
        {
            name : 'sys_default'
            msgType:"text"
            pattern : (msg, options, callback) ->
                callback null, 1, "sys_default"
            priority:100000
        }
        {
            name : 'sys_test'
            msgType : 'text'
            pattern : (msg, options, callback) ->
                if -1 isnt msg.indexOf "图片测试"
                    callback null, 50, "sys_pic_test"
                else
                    callback null, 0
            priority:1000
        }
        {
            name : 'sys_weixin_face'
            msgType : 'text'
            pattern : (msg, options, callback) ->
                text = msg.replace /\s/g, ''
                face = config.weixinFaces
                for f in face
                    if -1 isnt text.indexOf f
                        callback null, f.length * 100 / text.length, "sys_weixin_face"
                        return
                callback null, 0
                return
            priority:500
        }
    ]

