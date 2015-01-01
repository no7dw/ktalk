#Addctional
# author: wade

WechatManage = require '../../../common/helpers/wechatmanage'

class Addctional

	send : (message, userinfo, err, callback) ->		
		WechatManage.login 'chaobaida','klg2go', (err, cookie) ->
			if !err				
				WechatManage.sendMessage cookie, {msg : message, fakeid : userinfo.FakeId}, (err, data) ->
					if err
						console.log 'send error'+err.msg
						return callback err, ''
					else
						console.log 'seem succeed'
						console.log data
						return callback null, data
			else
				console.log '登录错误'+err.msg
				callback err, ''


module.exports = new Addctional

