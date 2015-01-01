#author: wade

keyword = new (require '../../apis/keyword')

module.exports =
    patterns : [
        {
            name : 'sys_cbd_focus'
            msgType : 'text'
            pattern : (msg, options, callback) ->
                if -1 isnt msg.indexOf "hello2bizuser"                    
                    callback null, 95, "sys_cbd_focus"
                else
                    callback null, 0
            priority:1
        },
        {
            name : 'sys_cbd_focus_2'
            msgType : 'event'
            pattern : (msg, options, callback) ->
                if -1 isnt msg.indexOf "subscribe"
                    callback null, 95, "sys_cbd_focus"
                else
                    callback null, 0
            priority:1
        },
        {
            name : 'user_cbd_help'
            msgType : 'text'
            pattern: (msg, options, callback) ->  
                msg= options.splitmsg #keyword.TransArrayWithSpace(q.segmentSync(msg))
                msg=msg||''                                               
                keywords = ["帮助", "help", "faq", "怎么用", "什么用", "用途", "说明", "解释", "什么玩意"]
                for k in keywords
                    if msg.indexOf(k) isnt -1
                        return callback null, k.length * 100 / msg.length, "user_cbd_help"
                return callback null, 0
            priority:99
        },
        {
            name : 'sys_cbd_cat'
            msgType : 'text'
            pattern : (msg, options, callback) ->
                #console.log options
                msg= options.splitmsg  #msg= keyword.TransArrayWithSpace(q.segmentSync(msg))                
                msg=msg||''
                result = keyword.do_keyword_check_cat msg
                if result   
                    cid = result.cid
                    #console.log "sys_cbd_cat " +cid                                                                                 
                    if cid                    
                        if  0 isnt cid.length                                                
                            return callback null, 88, "sys_cbd_cat", [cid, result.name]                    
                else                    
                        return callback null, 0
            priority : 99
        },
        {
            name : 'sys_cbd_tags'
            msgType : 'text'
            pattern : (msg, options, callback) ->
                #console.log options
                msg= options.splitmsg #msg= keyword.TransArrayWithSpace(q.segmentSync(msg))                
                msg=msg||''
                result = keyword.do_keyword_check_tags msg                                 
                if result 
                    cid = result.tid
                    if  cid &&  -1 != cid                         
                        return callback null, 88, "sys_cbd_tags", [cid, result.name]
                
                callback null, 0

            priority : 100
        }, 
        {
            name : 'sys_cbd_date'
            msgType : 'text'
            pattern : (msg, options, callback) ->     
                msg=msg||''           
                date = keyword.do_keyword_check_date msg                 
                #date = msg
                if typeof(date) == "string" and 0 != date.length                        
                    callback null, 99, "sys_cbd_date", [date]
                else
                    callback null, 0    
            priority : 100
        }, 
        {
            name : 'sys_cbd_test'
            msgType : 'text'
            pattern : (msg, options, callback) -> 
                msg=msg||''               
                reDate = /^题(\d+)([a-j]?)$/i                
                val = reDate.exec msg                
                if  val
                    test_index = val[1]
                    test_answer = null
                    if val[2] !=''          #query for test title          
                        test_answer = val[2]                                                                
                    return callback null, 199, "sys_cbd_test", [test_index,test_answer]
                else
                    #console.log "1212"
                    reDate = /题\d+[a-j]/i
                    if reDate.test msg                        
                        return callback null, type : 'text', value : "请输入正确的格式：如：题1a"            
                    else 
                        reDate2=/(\W{0,2})([a-j]{1})$/i
                        val2= reDate2.exec msg
                        if val2
                            test_answer = val2[val2.length-1]
                            test_index = 0 #newest / or last
                            return callback null, 199, "sys_cbd_test", [0, test_answer] 
                        reDate2=/^[k-z]/i
                        val2 = reDate2.exec msg
                        if val2 
                            values = "请输入正确的格式：如：A"                            
                            return callback null, type : 'text', value : values

                callback null, 0                    
            priority : 99
        },      
        {
            name : 'sys_cbd_hello'
            msgType : 'text'
            pattern : (msg, options, callback) ->
                keywords = ["hi", "hello", "你好", "您好", "亲", "在吗", "在?", "在？", "晚安", "睡觉", "休息", "晚上好", "早上好", "早啊", "早晨"]
                for k in keywords
                    if msg.indexOf(k) isnt -1
                        return callback null, 80, "sys_cbd_hello", [msg]
                return callback null, 0
            priority : 100
        },
        {
            name : 'default_cbd_fail'
            msgType:"text"
            pattern : (msg, options, callback) ->
                callback null, 1, "default_cbd_fail"
            priority:100000
        },
        {
            name:"sys_cbd_cheapest_items"
            msgType:"text"
            pattern: (msg, options, callback) ->
                #msg= mmseg.open('/usr/local/etc/').segmentSync(msg)
                keywords =  ["便宜", "低价", "省钱"]
                for k in keywords
                    if msg.indexOf(k) isnt -1
                        return callback null, 60, "sys_cbd_cheapest_items", [k]
                return callback null, 0
            priority:4
        },        
        {
            name:"sys_cbd_lastest_items"
            msgType:"text"
            pattern: (msg, options, callback) ->
                msg=msg||'' 
                #msg= mmseg.open('/usr/local/etc/').segmentSync(msg)
                keywords =  ["新", "最近"]
                for k in keywords
                    if msg.indexOf(k) isnt -1
                        return callback null, 70, "sys_cbd_lastest_items", [k]
                return callback null, 0
            priority:4
        },
        {
            name:"sys_cbd_baoyou"
            msgType:"text"
            pattern:(msg, options, callback) ->
                msg=msg||'' 
                #msg= mmseg.open('/usr/local/etc/').segmentSync(msg)
                results = -1 isnt msg.indexOf "包邮"
                if !results
                    callback null, 0
                else
                    callback null, 80, "sys_cbd_baoyou_items"
        },
        {
            name:"sys_cbd_highest_sales_items"
            msgType:"text"
            pattern: (msg, options, callback) ->
                msg=msg||'' 
                #msg= mmseg.open('/usr/local/etc/').segmentSync(msg)
                keywords = ["推荐", "爆款", "热款", "热卖", "好卖", "卖得最多", "最能卖", "销量"]
                for k in keywords
                    if msg.indexOf(k) isnt -1
                        return callback null, 70, "sys_cbd_highest_sales_items", [k]
                return callback null, 0
            priority:4
        },
        {
            #团购
            name:"sys_cbd_tuan"
            msgType:"text"
            pattern: (msg, options, callback) ->
                #msg= options.splitmsg
                msg=msg||'' 
                keywords = ["团", "团购"]                
                for k in keywords                    
                    if msg.indexOf(k) isnt -1
                        return callback null, 99, "sys_cbd_tuan", [msg]
                return callback null, 0
            priority:4
        }        
    ]

