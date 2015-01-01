#activity
#author:wade
dbquery = require '../apis/dbquery'
module.exports =
    handlers : [
        {
            name:"sys_cbd_activity"
            handle:(argus, options, callback) ->               
                re_focus = "thans ~\n<a href=\"http://www.chaobaida.com/qz/shb/items?from=weixin\">【今日省荷包单品推荐】>></a>" +"\n如果觉得不错，推荐给您的其他朋友吧～"
                index = 0   
                query = {"time":"2013-04-26"}
                options = 
                    db : 'onepiece_item'                    
                    sort :
                        _id: 1
                    limit : 1  
                dbquery.queryHandle_activity  query, options, callback                      
        }
    ]