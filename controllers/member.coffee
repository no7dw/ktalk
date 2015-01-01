###*
 * @author cat.
 * @create 2013-04-08
###
config = require '../../../config'
appPath = config.getAppPath()
mongodbClient = require('klgmongodb').initClient(config.getMongodbServerInfo(),'baas')
WechatManage = require "#{appPath}/common/helpers/wechatmanage"
lynxUtil = require "#{appPath}/apps/common/util"
logger = require("#{appPath}/common/helpers/logger").getLogger __filename

class Member
	constructor : (@db) ->
		self = @
		self.memberdb = 'wx_member'
		self.userdb = 'User'

	###*
	 * 获得微信信息
	 * @param {String} seller 商家名称
	 * @param {Function} callback 回调函数
	###
	getSellerWeChat : (seller, callback) ->
		self = @
		self.db.find self.userdb, {username : seller}, 'wx', {limit : 1}, (err, doc) ->
			if not err
				if doc.length && doc[0]['wx']
					callback null, doc[0]['wx']
				else
					callback null
			else
				callback null
	###*
	 * 获得公众平台信息
	 * @param {String} username 微信帐号
	 * @param {String} password 微信密码
	 * @param {Function} callback 回调函数
	###
	getWechatMessage : (username, password, callback) ->
		self = @
		WechatManage.login username, password, (err, cookie) ->
			if not err
				WechatManage.getMessage cookie, 10, (err, messages) ->
						callback err, cookie, messages
			else
				callback null, null
	###*
	 * 匹配用户
	 * 在微信公众平台匹配用户，匹配后获得用户的所有信息
	 * @param {String} seller 商家名称
	 * @param {Object} options 对话信息
	 * @param {Function} callback 回调函数
	###
	matchMember : (seller, options, callback) ->
		self = @
		if options.msgType != 'text'
			callback null, null
			return
		self.getSellerWeChat seller, (err, wechat) -> #获得微信帐号
			if not err
				if wechat == undefined
					callback null, null
					return
				self.getWechatMessage wechat.name, wechat.pwd, (err, cookie, messages) -> #获得公众平台数据
					if not err
						fakeId = null
						for message in messages
							if message.dateTime == options.time and message.content == options.msg #匹配信息
								fakeId = message.fakeId
								break
						if fakeId isnt null	#是否匹配
							WechatManage.getUserInfo cookie, fakeId, (err, userinfo) ->
								userinfo.seller = seller
								callback null, userinfo #返回到ktalk中流程继续
								if not err	#如果没有错误就保存用户信息
									self.updateMember options.username, userinfo, (err, doc) ->
										logger.info "save userinfo success! #{JSON.stringify(userinfo)}"
								else
									logger.info "get userinfo failed! #{fakeId}"
						else
							callback null, null	#没匹配到直接返回
					else
						callback null, null	#获得数据失败直接返回
			else
				callback null, null	#没有登录信息或者登录失败也直接返回

	###*
	 * 保存用户信息
	 * @param {String} userid 用户在微信内的ID
	 * @param {Object} userinfo 用户相信
	 * @param {Function} callback 回调函数
	###
	createMember : (userid, userinfo, callback) ->
		self = @
		userinfo.openid = userid
		self.db.save self.memberdb, userinfo, callback 

	###*
	 * 更改用户信息
	 * @param {String} userid 用户在微信内的ID
	 * @param {Object} userinfo 用户相信
	 * @param {Function} callback 回调函数
	###
	updateMember : (userid, userinfo, callback) ->
		self = @
		self.db.update self.memberdb, {openid : userid}, {$set : userinfo}, callback 

	###*
	 * 增加用户积分
	 * @param {String} userid 用户在微信内的ID
	 * @param {Number} score 分数
	 * @param {Function} callback 回调函数
	###
	changeScore : (userid, score, callback) ->
		self = @
		self.db.update self.memberdb, {openid : userid},{$inc : {score : score}, $set : {signtime : Date.now()}}, (err, doc) ->
			if not err
				self.db.find self.memberdb, {openid : userid}, (err, doc) ->
					if not err && doc.length && doc[0]['score']
						callback null, doc[0]['score']
					else
						callback {ret : -65535, msg : 'database failed!'}
			else
				callback {ret : -65535, msg : 'database failed!'}
	###*
	 * 获得用户信息
	 * @param {String} seller 商家名称
	 * @param {Object} options 信息选项
	 * @param {Function} callback 回调函数(err: 错误信息, userinfo: 用户信息)
	###
	getUserinfo : (seller, options, callback) ->
		self = @
		if options.username
			self.db.find self.memberdb, {openid : options.username}, {limit : 1}, (err, doc) -> #去数据库里找用户信息
				if not err 
					if doc.length && doc[0]['FakeId']
						callback null, doc[0]
					else
						callback null, null
						matchMember = () ->
							self.matchMember seller, options, (err, doc) -> #如果没有找到就去匹配用户
									if doc == null
										logger.info "匹配失败"
									else
										logger.info "匹配成功"
						if doc.length
							matchMember()
						else
							self.createMember options.username, {}, (err, doc) ->
								if not err 
									matchMember()
								else
									logger.info "创建用户失败"
				else
					callback null, null
		else
			callback null, null

	###*
	 * 是否签到
	 * @param {String} userid 微信公众接口的openid
	 * @param {Function} callback 回调函数
	###
	isSign : (userid, callback) ->
		self = @
		self.db.find self.memberdb, {openid : userid}, 'signtime', {limit : 1}, (err, doc) ->
			if not err
				flag = false
				flag = true if doc[0]['signtime'] > lynxUtil.date('Y-m-d 00:00:00', true)
				flag = false if doc[0]['signtime'] is undefined
				callback null, flag
			else
				callback null, true

	###*
	 * 用户所在的商家是否开启签到加积分功能
	 * @param {String} username 商家名称
	 * @param {Function} callback 回调函数
	###
	isOpenSing : (username, callback) ->
		self = @
		self.db.find self.userdb, {username : username}, '_id', (err, doc) ->
			if not err && doc.length
				db = require('klgmongodb').initClient(config.getMongodbServerInfo(),'onepiece_item')
				db.find 'wx_plugin', {type : 'sign', seller : doc[0]['_id'].toString()}, (err, doc) ->
					callback err, doc
			else
				callback null, []

	###*
	 * 获得用户积分
	 * @param {String} userid 微信内的用户ID
	 * @param {Function} callback 回调函数
	###
	getUserScore : (userid, callback) ->
		self = @
		self.db.find self.memberdb, {openid : userid}, 'score', {limit : 1}, (err, doc) ->
			if not err && doc.length
				score = 0
				score = doc[0]['score'] if doc[0]['score']
				callback null, score
			else
				callback null, 0

	###*
	 * 获得用户
	 * @param {String} userid 用户微信内ID
	 * @param {Function} callback 回调函数
	###
	getUser : (userid, callback) ->
		self = @
		self.db.find self.memberdb, {openid : userid}, {limit : 1}, callback
			
module.exports = new Member mongodbClient