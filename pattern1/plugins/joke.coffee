module.exports = {
    patterns : [
        {
            name : 'plugins_joke'
            msgType : 'text'
            pattern : (msg, options, callback) ->
                if ((~msg.indexOf "笑话") or (~msg.indexOf "糗事"))
                    probability = 100 - (msg.length - 2) * 5
                    probability = 10 if probability < 10
                    callback null, probability, "sys_plugins_joke", [msg]
                else
                    callback null, 0
            priority : 100
        },
        {
            name : 'plugins_arithmetic'
            msgType : 'text'
            pattern : (msg, options, callback) ->
                regexp = /([\d\.\(\)\+\-\*\/]+)(\s*(=|等于|是多少|是几|等于几|等于多少|$))/
                if value = regexp.exec(msg)
                    if value[2]
                        probability = 80
                    else
                        probability = 0
                        probability = 80 if /[\+\-\*\/]+/.test value[1]
                    console.log probability
                    callback null, probability, "sys_arithmetic", [value[1]]
                else
                    callback null, 0
        },
        {
            name : 'plugins_wikiedia'
            msgType : 'text'
            pattern : (msg, options, callback)->
                regexp = /(?:(?:(?:什么|啥|谁)是)(.+?)(?:啊|那|呢|哈|！|。|？|\?|\s|\Z|$))|(?:(.+?)(?:是(?:什么|啥|谁))(?:啊|那|呢|哈|！|。|？|\?|\s|\Z|$))/
                if value = regexp.exec msg
                    if value[1]
                        value = value[1]
                        probability = 80
                    else if value[2]
                        value = value[2]
                        probability = 80
                    else
                        value = null
                        probability = 0
                    callback null, probability, "sys_wikiedia", [value]
                else
                    callback null, 0
        },
        {
            name : 'plugins_activity'
            msgType : 'text'
            pattern : (msg, options, callback) ->
                if msg == '签到'
                    callback null, 100, "sys_member_sign", [msg]
                else
                    callback null, 0

        },
        {
            name : 'plugins_weather'
            msgType : 'text'
            pattern : (msg, options, callback) ->
                weather = /(\W*?)(的?)天气/g.exec msg
                if weather
                    city = weather[1]
                    console.log city
                    probability = 90
                    if city.length > 5 
                        probability = 50
                    callback null, probability, "sys_weather", [city]
                else
                    callback null, 0
        },
        {
            name : 'plugins_activity_list'
            msgType : 'text'
            pattern : (msg, options, callback) ->
                if msg == "活动"
                    callback null, 100, "sys_activity_list"
                else
                    callback null, 0
        }
    ]
}