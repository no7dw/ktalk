clipmanage = require '../controllers/clipmanage'
module.exports =
    handlers : [
        {
            name:"sys_bind_email"
            handle:(argus, options, callback) ->
                email = argus[0]
                userid = options.from
                clipmanage.bindEmail userid, email, callback
        },
        {
            name : 'sys_clip_message',
            handle : (argus, options, callback) ->
                message = argus[1]
                type = argus[2]
                userid = options.from
                clipmanage.sendMessage userid, message, type, callback
        },
        {
            name : 'sys_clip_default',
            handle : (argus, options, callback) ->
                userid = options.from
                clipmanage.getBindPanel userid, callback
        },
        {
            name : 'sys_clip_setdefault',
            handle : (argus, options, callback) ->
                userid = options.from
                platform = argus[1]
                clipmanage.setDefaultPlatform userid, platform, callback
        }
    ]