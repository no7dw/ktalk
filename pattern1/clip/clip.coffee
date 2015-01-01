module.exports =
    patterns : [
        {
            name : 'sys_clip_bind'
            msgType : 'text'
            pattern : (msg, options, callback) ->
                if ~msg.indexOf "@"
                    callback null, 80, "sys_bind_email", [msg]
                else
                    callback null, 0
            priority : 100
        },
        {
            name : 'sys_clip_message'
            msgType : 'text'
            pattern : (msg, options, callback) ->
                if msg.length > 30 || msg.indexOf('e:') is 0
                    msg = msg.replace 'e:',''
                    callback null, 90, 'sys_clip_message', [msg, 'e']
                else if msg.indexOf('w:') is 0
                    msg = msg.replace 'w:', ''
                    callback null, 90, 'sys_clip_message', [msg, 'w']
                else
                    callback null, 0
        },
        {
            name : 'sys_clip_setdefault'
            msgType : 'text'
            pattern : (msg, options, callback) ->
                if msg.indexOf('m:') is 0
                    msg = msg.replace 'm:', ''
                    callback null, 90, 'sys_clip_setdefault', [msg]
                else
                    callback null, 0
        },
        {
            name : 'sys_clip_default'
            msgType : 'text'
            pattern : (msg, options, callback) ->
                callback null, 20, 'sys_clip_default', [msg]
        }
    ]