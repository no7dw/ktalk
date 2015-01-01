###*
 * @author cat.
 * @create 2013/02/04/
###
config = require '../../../config'
appPath = config.getAppPath()
mongodbClient = require('klgmongodb').initClient(config.getMongodbServerInfo(),'baas')
UserApi = require "#{appPath}/common/apis/users/user.coffee"
nodemailer = require 'nodemailer'
weibo = require 'weibo'
#weibo.init 'weibo', '2225792066', '92e37381b8109dbb5adb173aee32e653'

smtpTransport = nodemailer.createTransport 'SMTP',{
    service: 'Gmail',
    auth: {
        user: 'smtp5@kalengo.com',
        pass: 'Kalengo2go'
    }
}

class ClipManage
	###*
	 * 构造函数
	###
	constructor : (@user, @db, @mailserver) ->

	###*
	 * 用户是否存在！
	 * @param  {String}   userid   
	 * @param  {Function} callback      
	###
	isExists : (userid, callback) ->
		self = @
		self.getUser userid, (err, row) ->
			if not err
				callback err, !!row.length
			else
				callback err, {msg: '查询出错！ ktalk/controllers/clipmanage.coffee line 36!'}

	###*
	 * 检查用户，如果不存在就创建
	 * @param {String} userid
	 * @param {Function} callback
	###
	checkUser : (userid, callback) ->
		self = @
		self.isExists userid, (err, doc) ->
			if not err
				if doc
					callback null, true
				else
					self.createUser userid, (err, doc) ->
						if not err
							callback null, true
						else
							callback err, doc
			else
				callback err, doc
	###*
	 * 创建用户
	 * @param {String} userid 
	 * @param {Function} callback
	###
	createUser : (userid, callback) ->
		self = @
		data = {
			userId : userid,
			username : '微剪报用户',
			password : '123456'
			appName : 'weijianbao'
		}
		self.user.create data, callback

	###*
	 * 是否绑定新浪，如果绑定了就判断是否过期
	 * @param {String} userid 
	 * @param {Function} callback
	###
	isBindSinaAndTimeout : (userid, callback) ->
		self = @


	###*
	 * 是否绑定email
	###
	isBindEmail : (userid, callback) ->
		self = @
		self.user.attribute userid, 'email', (err, doc)->
			if not err
				callback err, !!doc.length
			else
				callback err, {msg : 'clipmanage line 89!'}


	###*
	 * 获得用户
	 * @param {String} userid 
	 * @param {Function} callback
	###
	getUser : (userid, callback) ->
		self = @
		self.user.query {userId : userid}, callback

	###*
	 * 绑定新浪微博
	 * @param {String} userid 
	 * @param {[type]} [varname] 
	 * @param {Function} callback 
	###
	bindSinaWeibo : (userid, oauthUser, callback) ->
		self = @
		self.attribute userid, {oauthUser : oauthUser}, callback
	###*
	 * 绑定到邮箱
	 * @param {String} userid
	 * @param {String} email
	 * @param {Function} callbck 
	###
	bindEmail : (userid, email, callback) ->
		self = @
		self.checkUser userid, (err, doc) ->
			if not err and doc
				self.attribute userid, {email: email}, (err, doc) ->
					if not err
						callback null, type: 'text', value: '成功绑定到邮箱! 回复超过三十个字或则使用【e:】开头 系统将自动同步到你的邮箱!'
					else
						callback null, type: 'text', value: '系统出现异常!请稍后再试!'
			else
				callback null, type: 'text', value: '系统出现异常!请稍后再试!'

	###*
	 * 发送信息
	 * @param {String} userid 
	 * @param {String} msg 
	 * @param {String} type [weibo,email]
	 * @param {Function} callback 
	###
	sendMessage : (userid, msg, type, callback) ->
		self = @
		self.checkUser userid, (err, doc) ->
			if not err and doc
				switch type
					when 'w'
						self.sendMessageToSina userid, msg, callback
					when 'e'
						self.sendMessageToEmail userid, msg, callback
			else
				callback null, type: 'text', value: '系统出现异常!请稍后再试!'

	###*
	 * 发送到微博
	 * @param {String} userid
	 * @param {String} msg
	 * @param {Function} callback
	###
	sendMessageToSina : (userid, msg, callback) ->
		self = @
		self.getUser userid, (err, doc) ->
			if not err
				user = doc[0]['oauthUser']
				weibo.update user, msg, (err, doc)->
					if not err
							callback null, type: 'text', value: "成功发送到你的微博"
						else
							callback null, type: 'text', value: '发送到微博失败,可能是你绑定的微博已过期。请从新绑定后再试!'


	###*
	 * 发送到email
	 * @param {String} userid
	 * @param {String} msg
	 * @param {Function} callback
	###
	sendMessageToEmail : (userid, msg, callback) ->
		self = @
		self.getMail userid, (err, doc) ->
			if not err
				if doc.length > 0
					email = doc[0]['email']
					self.sendMail email, '微剪报邮件提醒!', msg, (err, doc)->
						if not err
							callback null, type: 'text', value: "成功发送到你的邮箱！请前#{email}往查看"
						else
							callback null, type: 'text', value: '发送到邮箱失败,请检查你设定的邮箱。或稍后再试!'
				else
					self.getBindPanel userid, callback
			else
				callback null, type: 'text', value: '系统出现异常!请稍后再试!'

	###*
	 * 获得email
	 * @param {String} userid 
	 * @param {Function} callback 
	###
	getMail : (userid, callback) ->
		self = @
		self.attribute userid, 'email', callback

	###*
	 * 用户属性
	###
	attribute : (userid, attribute, callback) ->
		self = @
		if typeof attribute is 'string'
			self.user.query {userId : userid}, attribute, callback
		else
			self.user.change {userId : userid}, {$set : attribute}, callback

	###*
	 * send mail
	 * @param {Object} user 收信人的地址
	 * @param {String} subject 邮件的主题
	 * @param {String} content 邮件内容
	 * @param {Function} callback 回调函数
	###
	sendMail : (user, subject, content, callback) ->
		self = @
		options = {
			from : 'smtp5@kalengo.com',
			to : user,
			subject : subject,
			html : content
		}
		self.mailserver.sendMail options, callback

	###*
	 * 获得绑定面板
	 * @param {String} userid 
	 * @param {String} type
	 * @param {Function} callback 
	###
	getBindPanel : (userid, callback) ->
		self = @
		self.checkUser userid, (err, doc) ->
			if not err and doc
				values = []
				self.getUser userid, (err, doc) ->
					if not err 
						if not doc[0]['email']
							values.push {
								title : '发送常用邮箱帐号，直接绑定!',
								desc : '绑定到你的常用邮箱',
								picUrl : 'https://www.google.com/a/kalengo.com/images/logo.gif'
							}
						if not doc[0]['oauthUser']
							values.push {
								title : '点击绑定到新浪微博'
								desc : '点击绑定到新浪微博',
								picUrl : 'http://blog.jobbole.com/wp-content/uploads/2011/11/sina-weibo-logo.gif',
								url : 'http://guide.awang.com/wjb/sina/login?type=weibo&userid=' + userid
							}
						if values.length is 0
							callback null, type : 'text', value : '1.以【e:】开头直接发送到邮箱\n2.以【w:】开头直接发送到微博.\n3.回复大于三十字直接发送到默认平台\n4.修改默认平台请回复【m:e】邮箱【m:w】微博'
						else
							callback null, type : 'image', value : values
					else
						callback null, type : 'text', value : '系统出现异常!请稍后再试!'
			else
				callback null, type: 'text', value: '系统出现异常!请稍后再试!'

	###*
	 * 设置默认发送平台
	 * @param {String} userid
	 * @param {String} type w | e
	 * @param {Function} callback 
	###
	setDefaultPlatform : (userid, type, callback) ->
		self = @
		self.checkUser userid, (err, doc)->
			if not err and doc
				self.attribute userid, {defaultplatform : type}, (err, doc) ->
					if not err
						callback null, type : 'text', value : "默认发送平台已经设置为#{type.replace('e','邮箱').replace('w','微博')}"
			else
				callback null, type: 'text', value: '系统出现异常!请稍后再试!'

module.exports = new ClipManage new UserApi, mongodbClient, smtpTransport
