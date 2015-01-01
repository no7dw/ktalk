module.exports =
    patterns:[
        {
            name:"sys_lastest_items"
            msgType:"text"
            pattern: (msg, options, callback) ->
                keywords =  ["新", "最近"]
                for k in keywords
                    if msg.indexOf(k) isnt -1
                        return callback null, 70, "sys_lastest_items", [k]
                return callback null, 0
            priority:4
        }
        {
            name:"sys_highest_sales_items"
            msgType:"text"
            pattern: (msg, options, callback) ->
                keywords = ["推荐", "爆款", "热款", "热卖", "好卖", "卖得最多", "最能卖", "销量", "热销"]
                for k in keywords
                    if msg.indexOf(k) isnt -1
                        return callback null, 70, "sys_highest_sales_items", [k]
                return callback null, 0
            priority:4
        }
        {
            name:"sys_cheapest_items"
            msgType:"text"
            pattern: (msg, options, callback) ->
                keywords =  ["便宜", "低价", "省钱"]
                for k in keywords
                    if msg.indexOf(k) isnt -1
                        return callback null, 60, "sys_cheapest_items", [k]
                return callback null, 0
            priority:4
        }
        {
            name:"sys_price_range"
            msgType:"text"
            pattern:(msg, options, callback) ->
               results = msg.match /(\d+)[^\d]+?(\d+)/
               if !results
                   return callback null, 0
               else
                   low = Math.min results[1], results[2]
                   high = Math.max results[1], results[2]
                   callback null, 80, "sys_price_items", [low, high]
            priority:3
        }
        {
            name:"sys_price_range2"
            msgType:"text"
            pattern:(msg, options, callback) ->
                results = msg.match /(\d+)/
                isPrice = msg.indexOf("元") isnt -1 or msg.indexOf("块") isnt -1
                if !results
                   callback null, 0
                else
                    score = 50
                    score += 20 if isPrice
                    price = 0 + results[1]
                    score += 10 if price >= 10
                    range = 0.3
                    low = price * (1 - range)
                    high = price * (1 + range)
                    callback null, score, "sys_price_items", [low, high]
            priority:3
        }
        {
            name:"sys_baoyou"
            msgType:"text"
            pattern:(msg, options, callback) ->
                results = -1 isnt msg.indexOf "包邮"
                if !results
                    callback null, 0
                else
                    callback null, 80, "sys_baoyou_items"
        }
        {
            name:"sys_discount"
            msgType:"text"
            pattern:(msg, options, callback) ->
                map =
                    '一' : 1
                    '二' : 2
                    '三' : 3
                    '四' : 4
                    '五' : 5
                    '六' : 6
                    '七' : 7
                    '八' : 8
                    '九' : 9
                    '半价' : '5折'

                for k,v of map
                    msg = msg.replace new RegExp(k, 'g'), v
                result = msg.match /(\d+)折/
                if (result)
                    callback null, 85, "sys_discount_items", [result[1]]
                else
                    callback null, 0
        }
        {
            name:"sys_discount_2"
            msgType:"text"
            pattern:(msg, options, callback) ->
                keywords = ["优惠","促销","大促","折扣","性价比","超值"]
                for k in keywords
                    if msg.indexOf(k) isnt -1
                        return callback null, 85, "sys_discount_items", [99]
                return callback null, 0
        }
        {
            name:"sys_tags"
            msgType:"text"
            pattern:(msg, options, callback) ->
                filterWord = ['了', '子', '呢', '啊', '吧', '哦', '呵', '噢', '哈', '嗯', '嘿', '嘻', '阿', '吓', '呀', '哎', '哟', '唉', '哼', '啧', '喂', '喔', '[^\\u4e00-\\u9fa5]']
                text = msg
                for word in filterWord
                    text = text.replace new RegExp(word, 'g'), ''
                if 0 < text.length < 5
                    score = 50
                else
                    score = 0
                callback null, score, "sys_tags_items", [text]
        }
        {
            name:"sys_size"
            msgType:"text"
            pattern:(msg, options, callback) ->
                keywords = ["xs", "s","m","l","xl"]
                for k in keywords
                    if msg.indexOf(k) isnt -1
                        return callback null, 85, "sys_tags_items", [k]
                return callback null, 0
        }
        {
            name:"sys_taobao_orders"
            msgType:"text"
            pattern:(msg, options, callback) ->
                result = msg.match /([\u4E00-\u9FA3\w]+).*(的){0,1}订单/
                buyNick = null
                if result?[1]
                    buyNick = result[1]
                    console.log typeof buyNick
                    if '的' is buyNick.charAt(buyNick.length - 1)
                        buyNick = buyNick.substr 0, buyNick.length - 1
                else
                    result = msg.match /订单.*?([\u4E00-\u9FA3\w]+)/
                    if result?[1]
                        buyNick = result[1]
                score = 0
                if -1 isnt msg.indexOf "订单"
                    score += 52
                if buyNick
                    score += 40
                callback null, score, "sys_taobao_orders", [buyNick]
        }
        {
            name : 'sys_taobao_default'
            msgType:"text"
            pattern : (msg, options, callback) ->
                callback null, 1.1, "sys_taobao_default"
            priority:99999
        }
    ]
