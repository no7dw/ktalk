ktalk = new (require '../apis/ktalk1')
appConfig = require '../../weixincm/config'
wxUserApi = require '../../weixincm/apis/user'
wxTradeApi = require '../../weixincm/apis/trade'

queryHandle = (query, options, callback) ->
    ktalk.getQueryResults query, options, (err, items) ->
        if not items.length
            callback null, null
            # callback null, type: 'text', value: options.notFoundMsg
        else
            callback null, type: 'item', value: items

module.exports =
    handlers : [
        {
            name:"sys_taobao_default",
            handle:(argus, options, callback) ->
                msgValue = "亲，我小学还没毕业，听不懂您的意思！"
                if options.username
                    shopUrl = "\n <a href=\"http://guide.awang.com/weixincm/shopdetail?seller=#{options.username}&type=high\">去微信店铺败点货</a>"
                    callback null, type : 'text', value : msgValue + shopUrl
                else
                    callback null, type : 'text', value : msgValue
        }
        {
            #查询新品
            name:"sys_lastest_items"
            handle:(argus, options, callback) ->
                matchWord = argus[1]
                query = nick: options.username
                callback null, {type : 'query', query : query, sort : {listTime : -1}, num : 3}
        }
        {
            #查询销量高
            name:"sys_highest_sales_items"
            handle:(argus, options, callback) ->
                matchWord = argus[1]
                query = nick: options.username, buyNumber: {$gt: 0}
                limit = 3
                #查询销量高的宝贝
                ktalk.getQueryResults query, {sort: {buyNumber : -1, listTime : -1}, limit : limit}, (err, items) ->
                    if not items.length
                        #如果没有，则查询橱窗推荐的宝贝
                        query = nick: options.username, hasShowcase: true
                        ktalk.getQueryResults query, {sort: {listTime : -1}, limit : limit}, (err, items) ->
                            if not items.length
                                callback null, type: 'text', value: '[可怜]亲，小编听不懂你说什么，换换别的关键词试试吧？ 例如：“颜色”“尺寸”“折扣”等等宝贝相关词都可以哦 [坏笑]'
                            else
                                callback null, type: 'item', value: items
                    else
                        callback null, type: 'item', value: items
        }
        {
            #查询最便宜的
            name:"sys_cheapest_items"
            handle:(argus, options, callback) ->
                query = nick: options.username
                ktalk.getQueryResults query, {sort: {price : 1}, limit : 4}, (err, items) ->
                    callback null, type: 'item', value: items
        }
        {
            #查询价格范围
            name:"sys_price_items"
            handle:(argus, options, callback) ->
                query = nick: options.username
                low = argus[1]
                high = argus[2]
                query.price = {$lte: high, $gte: low}
                options = 
                    sort : 
                        price : 1
                    limit : 4
                    notFoundMsg : '[可怜]亲，没找到相应价格的宝贝，换换别的关键词试试吧？ 例如：“颜色”“尺寸”“折扣”等等宝贝相关词都可以哦 [坏笑]'
                queryHandle query, options, callback
        }
        {
            #查询包邮宝贝
            name:"sys_baoyou_items"
            handle:(argus, options, callback) ->
                query = nick: options.username
                query.freightPayer = "seller"
                options = 
                    sort : 
                        price : -1
                    limit : 4
                    notFoundMsg : '[可怜]亲，没找到包邮宝贝，换换别的关键词试试吧？ 例如：“颜色”“尺寸”“折扣”等等宝贝相关词都可以哦 [坏笑]'
                # query = appCids : 1001, isBY: true
                # options = 
                #     db : 'onepiece_item'
                #     sort : 
                #         score : -1
                #     limit : 4
                queryHandle query, options, callback
        }
        {
            #查询宝贝标签
            name:"sys_tags_items"
            handle:(argus, options, callback) ->
                limit = 4
                query = nick: options.username
                query.qTags = new RegExp argus[1]
                ktalk.getQueryResults query, {sort: {listTime : -1}, limit : limit}, (err, items) ->
                    if not items.length
                        delete query.qTags
                        query.title = new RegExp argus[1]
                        queryHandle query, {sort : {price : 1}, limit : 4, notFoundMsg : '[可怜]亲，没找到相应宝贝，换换别的关键词试试吧？ 例如：“颜色”“尺寸”“折扣”等等宝贝相关词都可以哦 [坏笑]'}, callback
                    else
                        callback null, type: 'item', value: items
                
        }
        {
            #查询宝贝优惠
            name:"sys_discount_items"
            handle:(argus, options, callback) ->
                discount = Number(Number('0.' + argus[1]).toFixed(1))
                query = nick: options.username
                query['promo.disc'] = {$gt: 0, $lte: discount}
                queryHandle query, {sort : {'promo.disc' : -1}, limit : 4, notFoundMsg : '[可怜]亲，没找到相应宝贝，换换别的关键词试试吧？ 例如：“颜色”“尺寸”“折扣”等等宝贝相关词都可以哦 [坏笑]'}, callback
        }
        {
            #查询用户订单
            name:"sys_taobao_orders"
            handle:(argus, options, callback) ->
                buyerNick = argus[1]
                if not buyerNick
                    callback null, type: 'text', value: '亲，您要查谁的订单呢？'
                else
                    query = nick: options.username
                    wxUserApi.getTopSession options.username, (err, topSession) ->
                        if err 
                            callback null, type: 'text', value: '出错啦，再来试试！'
                        else
                            trade = new wxTradeApi appConfig.appKey, appConfig.appSecret
                            trade.getSellerOrders topSession, {buyer_nick:buyerNick ,page_size:5}, (err, orders) ->
                                if err or not orders.length
                                    callback null, type: 'text', value: "亲，\"#{buyerNick}\"还没在我这里下单呢。"
                                else
                                    callback null, type: 'text', value: formatTrades(orders)

                    formatTrades = (trades) ->
                        str = "#{trades[0].buyerNick}，您的订单：\n"
                        for t in trades
                            str += "订单号：#{t.tId}，创建时间：#{t.created}，购买了"
                            for o in t.orders
                                str += "<a href=\"http://item.taobao.com/item.htm?id=#{o.itemId}\">#{o.title}</a>，"
                            str += "共￥#{t.payment}元，"
                            switch t.status
                                when 'TRADE_NO_CREATE_PAY' then str += '还没有创建支付宝交易。'
                                when 'WAIT_BUYER_PAY' then str += '正等待买家付款。'
                                when 'WAIT_SELLER_SEND_GOODS' then str += '请等待卖家发货。'
                                when 'WAIT_BUYER_CONFIRM_GOODS' then str += '卖家已发货，等待买家确认收货。'
                                when 'TRADE_BUYER_SIGNED' then str += '买家已签收。'
                                when 'TRADE_FINISHED' then str += '交易成功。'
                                when 'TRADE_CLOSED' then str += '退款成功，交易已被关闭。'
                                when 'TRADE_CLOSED_BY_TAOBAO' then str += '交易已被关闭。'
                        str += '\n'
        }
        {
            name:"sys_guide",
            handle:(argus, options, callback) ->
                msgValue = '感谢关注，请输入关键词\n【热销】 查看热销宝贝\n【折扣】 查看折扣宝贝\n【新款】 查看新款宝贝\n【推荐】 查看推荐宝贝\n任意输入颜色、尺寸等宝贝相关词，智能解答\n回复"help" 或"帮助"再出现此菜单\n'
                if options.username                   
                        shopUrl = "\n <a href=\"http://guide.awang.com/weixincm/shopdetail?seller=#{options.username}&type=high\">去微信店铺败点货</a>"                        
                        callback null, type : 'text', value : msgValue + shopUrl
                else
                    callback null, type : 'text', value : msgValue
        }
    ]