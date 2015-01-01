#author: wade

keyword = new (require '../apis/keyword')
formatter = require '../apis/format'
addctional = require '../apis/addctional'
dbquery = require '../apis/dbquery'

recomemdation_test = true
test_log = null

user_ask_test_histoty = {}

module.exports =
    handlers : [
        {
            name:"sys_cbd_focus"
            handle:(argus, options, callback) ->               
                re_focus = [
                    "谢谢妞关注潮百搭~\n爱时尚玩潮流，试输入 \n宝贝类别如\"衣服\",\"包包\"…\n风格元素如\n\"欧美\"\"波点\"…\n让小编帮你找找看~\n<a href=\"http://www.chaobaida.com/qz/shb/items?from=weixin\">【今日省荷包单品推荐】>></a>"]                
                index = 0           
                callback null, type : 'text', value : re_focus[index]+"\n如果觉得不错，推荐给您的其他朋友吧～"
        }
        {
            name:"user_cbd_help",
            handle:(argus, options, callback) ->
                callback null, type : 'text', value : "亲，有什么问题可以随意咨询哦！比如：发送“裙子”可获得本店“裙子”类别的宝贝哦~或者发送“20130315”查询那天的日志，我们能帮你挑选宝贝哦！"
        }
        {
            #查询catagory
            name:"sys_cbd_cat"            
            handle:(argus, options, callback) ->
                #get the appCids then query the db                 
                query = appCids : argus[1],state:1
                #console.log "sys_cbd_cat"+" log "+query               
                options = 
                    db : 'onepiece_item'                     
                    sort : 
                        score : -1
                    limit : 3
                #second class
                if argus[1].toString().length == 8                    
                    options.limit = 6

                dbquery.queryHandle_format query, argus[2] , options, callback                
        }
        {
            #查询 tags
            name:"sys_cbd_tags"            
            handle:(argus, options, callback) ->
                #get the appCids then query the db    
                #query = { $all:[argus[1]] }
                query = tags : argus[1] ,state:1    
                console.log "sys_cbd_tags"+" log "+query
                options = 
                    db : 'onepiece_item'                     
                    sort : 
                        score : -1
                    limit : 6
                
                dbquery.queryHandle_format query, argus[2] , options, callback                
        }   
        {                    
            name:"sys_cbd_hello"
            handle:(argus, options, callback) ->   
                #console.log "sys_cbd_hello"                        
                value = '您好'                
                callback null, type : 'text', value : value

        }        
        {
            #query date weixin journal            
            name:"sys_cbd_date"
            handle:(argus, options, callback) ->                          
                ti = formatter.formatDigit2Time argus[1]
                console.log "time format from "+argus[1]+" to "+ ti   
                if 0 == ti.length
                    return callback null, type:'text',value:'不能理解你指定的时间，具体点好吗？如：20130321, 0321'                                      
                # query = {time : ti , isT:false} # items before not set isT                                             
                query = {time : ti }                                              
                options = 
                    db : 'onepiece_item'                    
                    sort :
                        _id: 1
                    limit : 4                    
                    #notFoundMsg : '找不到对应时间的日志。可能时间不对，或者该时间没有日志。'
                dbquery.queryHandle_wxjournal query, options, callback

        }         
        {
            #query test json    
            name:"sys_cbd_test",
            handle:(argus, options, callback) ->                                 
                test_index = argus[1]-1
                test_answer = argus[2]                 
                if test_index ==-1
                    console.log "newest"
                    query = "isT":true                
                    q_options = 
                        db : 'onepiece_item'                    
                        limit : 0
                        sort:
                            time:1                    
                else     
                    query = "isT":true                
                    q_options = 
                        db : 'onepiece_item'                    
                        limit : 0
                        sort:
                            time:1
                
                dbquery.queryHandle_wxjournal query, q_options, (err,items) ->
                    #console.log items
                    test_log = items.value                    
                                
                    if test_index ==-1
                        test_index = test_log.length-1                                                               
                    
                    if test_index >= test_log.length ||  test_index == -1
                        values = "还没有第#{argus[1]}题，试一下第#{test_log.length}题吧"                           
                        return callback null, type:'text', value:values

                    if not test_answer                      
                        console.log "just for the topic ,test_index : "+ test_index 
                        
                        # user_ask_test_histoty[options.from]=test_index
                        # console.log user_ask_test_histoty

                        pic = [title:test_log[test_index].title,desc:test_log[test_index].desc, picUrl:test_log[test_index].picUrl, url:test_log[test_index].url]                            
                        return callback null, type: 'image', value: pic
                    else                        
                        console.log "just for test answer ,index:  "+test_index                                              
                        test_answer_index = test_answer.toLowerCase().charCodeAt()-'a'.charCodeAt()                                                      
                        values = test_log[test_index].options[test_answer_index]
                        if recomemdation_test
                            values += '\n输入 \"题+数字\",如“题5”, 玩更多的测试题'    
                            values += formatter.add_static_link(formatter.genRandomIndex(0,1))                
                            # if options.userinfo
                            #     addctional.send  values, options.userinfo, (err, data) ->
                            #         return callback null, type: 'text', value: values 

                        return callback null, type: 'text', value: values    
                                                      
        }
        {
            name:"default_cbd_fail",
            handle:(argus, options, callback) ->
                query = appCids : 10010101
                #console.log "sys_cbd_default"+" log "+query   
                options = 
                    db : 'onepiece_item'   
                    sort : 
                        score:-1
                    limit : 1
                dbquery.queryHandle query, options, (err, value) -> 
                    encode_ori_msg = encodeURIComponent("衣服")                    
                    recom = { "url":"http://www.chaobaida.com/qz/shb/items/?category=#{encode_ori_msg}","picUrl": "http://www.chaobaida.com/files/common/#{encode_ori_msg}.jpg"}
                    pic = [title:"找不到您想要的内容，推荐些给您吧", desc:'',picUrl:recom.picUrl,url:recom.url]
                    pic.push {title:value.value[0].title, desc:'',picUrl:value.value[0].picUrl,url:value.value[0].clickUrl}                    
                    callback null, type : 'image', value : pic                
        }
        {
            #查询最便宜的
            name:"sys_cbd_cheapest_items"
            handle:(argus, options, callback) ->
                query = appCids : 100101,state:1, listT:{$gt:new Date((new Date)-86400*1000*30).getTime()  }     
                #console.log "sys_cbd_cheapest_items"+" log "+query   
                options = 
                    db : 'onepiece_item'   
                    sort : 
                        price: 1
                    limit : 3 
                dbquery.queryHandle query, options, callback                
        }
        {
            #查询新品
            name:"sys_cbd_lastest_items"
            handle:(argus, options, callback) ->    
                query = appCids:100101,state:1,listT:{$gt:new Date((new Date)-86400*1000*30).getTime()  }         
                options = 
                    db : 'onepiece_item'   
                    sort : 
                        listT : -1
                    limit : 3                
                dbquery.queryHandle query, options, callback
        }  
        {
            #查询包邮宝贝
            name:"sys_cbd_baoyou_items"
            handle:(argus, options, callback) ->
                query = {appCids:100101,state:1,isBY:true}
                options = 
                    db : 'onepiece_item'       
                    sort : 
                        score:-1
                    limit : 3
                    notFoundMsg : '[可怜]亲，没找到包邮宝贝，换换别的关键词试试吧？ 例如：“颜色”“尺寸”“折扣”等等宝贝相关词都可以哦 [坏笑]'                
                dbquery.queryHandle query, options, callback
        }     
        {
            #查询销量高
            name:"sys_cbd_highest_sales_items"
            handle:(argus, options, callback) -> 
                #console.log "sys_cbd_highest_sales_items"               
                query = appCids:100101,state:1,listT:{$gt:new Date((new Date)-86400*1000*30).getTime() } 
                console.log query
                options = 
                    db : 'onepiece_item'       
                    sort : 
                        buyN:-1
                    limit : 3
                dbquery.queryHandle query, options, callback                
        }
        {
            #团购 groupon
            name:"sys_cbd_tuan"
            handle: (argus, option, callback) ->                
                date=null
                parseDate_start=null
                parseDate_end=null
                if argus[1].length>1
                    date=argus[1][1..argus[1].length-1]
                    date = formatter.formatDigit2Time(date)
                    console.log "date tuan "+date
                    

                #with date speciafec groupon 
                if date                    
                    query = position:{$lt:1}
                    options =
                        db: 'onepiece_item'                        
                        sort:
                            position:1
                        limit:4                                                
                        createdAt:{$lt:new Date(parseDate_end), $gte: new Date(parseDate_start)}
                    #console.log "options 111:"+options
                else
                    #return today's groupon
                    query = position:{$gte:1}
                    options =
                        db: 'onepiece_item'
                        sort:
                            position:1
                        limit:4                                                            
                                        
                keyword.getQueryResults_popup query, options, callback

        }        
    ]
