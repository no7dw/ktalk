#activity
#author:wade

module.exports =
    patterns : [
        {
            #activity
            name:"sys_cbd_activity"
            msgType:"text"
            pattern: (msg, options, callback) ->                
                console.log 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
                msg=msg||'' 
                keywords = ["nm123", "nmm123"]                
                for k in keywords                    
                    if msg.indexOf(k) isnt -1
                        return callback null, 99, "sys_cbd_activity", [msg]
                return callback null, 0
            priority:99
        }         
    ]