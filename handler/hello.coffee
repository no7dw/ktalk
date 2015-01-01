_ = require 'underscore'
config = require '../config'

module.exports =
    handlers : [
        {
            name:"sys_focus"
            handle:(argus, options, callback) ->
                tmp = "本"
                tmp = "#{options.username}的" if options.username
                callback null, type : 'text', value : "感谢关注#{tmp}店！有什么问题可以随意咨询哦！比如：发送“新款”可获得本店最新的宝贝哦~或者发送价格“50~120元”，我们能帮你挑选宝贝哦！\n <a href=\"http://guide.awang.com/weixincm/shopdetail?seller=#{options.username}&type=high\">去微信店铺败点货</a>"

        }
        {
            name:"sys_hello",
            handle:(argus, options, callback) ->
                keywords = argus[1];
                value = '您好，'
                if -1 isnt keywords.indexOf "早"
                    value = "早上好，祝你新的一天有个好心情！/:sun"
                if -1 isnt keywords.indexOf "晚"
                    value = "/:moon晚上好～"
                value += '有什么可以帮到您？需要什么宝贝可以直接询问我哦！'
                if (_.find ["晚安", "睡觉", "休息"], (k)->
                    -1 isnt keywords.indexOf k
                )
                    value = "亲好梦/:moon"
                callback null, type : 'text', value : value
        }
        {
            name:"sys_help",
            handle:(argus, options, callback) ->
                callback null, type : 'text', value : "亲，有什么问题可以随意咨询哦！比如：发送“新款”可获得本店最新的宝贝哦~或者发送价格“50~120元”，我们能帮你挑选宝贝哦！"
        }
        {
            name:"sys_default",
            handle:(argus, options, callback) ->
                callback null, type : 'text', value : "亲，我小学还没毕业，听不懂您的意思！"
        }
        {
            name:"sys_pic_test",
            handle:(argus, options, callback) ->
                pics = [{title:'测试', desc:'这是图片描述亲！', picUrl:'https://www.google.com.hk/logos/2013/mary_leakeys_100th_birthday-1026006-hp.jpg', url:'http://www.chaobaida.com'}]
                callback null, type : 'image', value : pics
        }
        {
            name:"sys_weixin_face",
            handle:(argus, options, callback) ->
                faces = config.weixinFaces
                callback null, type : 'text', value : faces[Math.floor(Math.random() * faces.length)]
        }
    ]