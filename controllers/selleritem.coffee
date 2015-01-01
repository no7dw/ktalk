###*
 * @author cat.
 * @create 2013-04-22
###
config = require '../../../config'
klgMongoDb = require 'klgmongodb'
server = {host : 'yun.awang.com', port : 27017}
mongodbClient = klgMongoDb.initClient server, 'taobao', (err) ->

###*
 * 商家宝贝
###

class Selleritem
	constructor : (@db) -> 
		self = @
		self.dbname = 't_Item'
		self.fields = 'id title price picUrl clickUrl promo buyNumber'

	###*
	 * 获得新品
	 * @param  {String}   seller   商户名称
	 * @param  {Function} callback 回调函数(err: 错误信息, doc: 数据)
	 * @return {[type]}            [description]
	###
	getLastestItems : (seller, callback) ->
		self = @
		criteria = {
			clickUrl : {$exists : true},
			nick : seller
		}
		self.db.find self.dbname, criteria, self.fields, {limit : 20, sort : {listTime : -1}}, callback

	###*
	 * 获得销量高的商品
	 * @param {String} seller 商家名称
	 * @param {Function} callback 回调函数(err: 错误信息, doc: 数据)
	###
	getHighestSalesItems : (seller, callback) ->
		self = @
		criteria = {
			clickUrl : {$exists : true},
			nick : seller,
			hasShowcase : true
		}
		self.db.find self.dbname, criteria, self.fields, {sort : {buyNumber : -1}, limit : 20}, callback

	###*
	 * 获得包邮的商品
	 * @param {String} seller 商家名称
	 * @param {Function} callback 回调函数(err: 错误信息, doc: 数据)
	###
	getBaoyouItems : (seller, callback) ->
		self = @
		criteria = {
			clickUrl : {$exists : true},
			nick : seller,
			freightPayer : "seller"
		}
		self.db.find self.dbname, criteria, self.fields, {limit : 20}, callback

	###*
	 * 获得橱窗的宝贝
	 * @param {String} seller 商家名称
	 * @param {Function} callback 回调函数(err: 错误信息, doc: 数据)
	###
	getShowItems : (seller, callback) ->
		self = @
		criteria = {
			clickUrl : {$exists : true},
			hasShowcase : true,
			nick : seller
		}
		self.db.find self.dbname, criteria, self.fields, {limit : 20}, callback
	###*
	 * 获得首页数据
	 * @param {String} seller 商家名称
	 * @param {Function} callback 回调函数(err: 错误信息, doc: 数据)
	###
	getHome : (seller, callback) ->
		callback null, []

module.exports = new Selleritem mongodbClient