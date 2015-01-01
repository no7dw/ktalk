config = require "#{process._appPath}/config"
appPath = config.getAppPath()
logger = require("#{appPath}/common/helpers/logger").getLogger __filename
routeHandler = require "#{appPath}/common/helpers/routehandler"
controllers = require "#{appPath}/apps/ktalk/controllers/weixin"
socialhandler = require "#{appPath}/common/helpers/socialhandler"
clipmanage = require "#{appPath}/apps/ktalk/controllers/clipmanage"
routeInfos = [
    {
        route : '/wxt/:username'
        handleFunc : controllers.valid
    },
    {
        type: 'post'
        route: '/wxt/:username'
        handleFunc : controllers.reply
    },
    {
        type: 'post'
        route: '/wjb/:username'
        handleFunc: controllers.reply
    },
    {
        type : 'get'
        route : '/wjb/:username'
        handleFunc : controllers.valid
    }
    {
        type: 'post'
        route: '/cbd/:username'
        handleFunc: controllers.reply
    },
    {
        type : 'get'
        route : '/cbd/:username'
        handleFunc : controllers.valid
    }

]

module.exports = (app) ->
    #socialhandler.init 'weibo', '2225792066', '92e37381b8109dbb5adb173aee32e653'
    app.use socialhandler.oauth {
        loginPath : '/wjb/sina/login'
        logoutPath : '/wjb/sina/logout'
        callbackPath : '/wjb/sina/callback'
        blogtypeField: 'type'
        afterLogin : (req, res, next) ->
            args = req.session.query
            req.session.query = null
            clipmanage.bindSinaWeibo args.userid, req.session.oauthUser, (err, doc)->
                if not err
                    res.header {'Content-Type': 'text/html; charset=utf8'}
                    res.end '绑定成功'
            
    }
    routeHandler.initRoutes app, routeInfos
