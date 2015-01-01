module.exports =
    patterns : [
        {
            name:"simsimi"
            msgType : 'text'
            pattern: (msg, options, callback) ->
                callback null, 30, 'simsimi'
            priority:99
        }
    ]