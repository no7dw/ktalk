SuperAgent = require 'superagent'
http = require 'http'
config = require "#{process._appPath}/config"
appPath = config.getAppPath()
MemberMange = require "#{appPath}/apps/ktalk/controllers/member"
Weather = require "#{appPath}/apps/common/weather"
Activity = require "#{appPath}/apps/weixincm/controllers/activity"
module.exports = {
	handlers : [
		{
			name : 'sys_plugins_joke'
			handle : (args, options, callback) ->
				url = 'http://feed.feedsky.com/qiushi'
				http.get url, (res) ->
					data = null
					res.on 'data', (chunk)->
						data += chunk
					.on 'end', () ->
						values = []
						jokereg = /&lt;p&gt;\s+(([^\t]+))&lt;br\/&gt;/g
						while value = jokereg.exec(data.toString())
							values.push(value[1])
						values.pop()
						callback null, {type : 'text', value : values[Math.floor(Math.random() * (values.length - 1))]}
				.on 'error', (e) ->
					callback null, {type : 'text', value : '今早上班路上碰到一排迎亲车队，全是清一色的奔驰，然后我就在数到底有多少辆，结果看到车队里有辆帕萨特，我正纠结怎么有滥竽充数的呢。帕萨特的车窗落了下来，车主冲着前面的奔驰大喊:放我出去！！！'}
		},
		{
			name : 'sys_arithmetic'
			handle : (args, options, callback) ->
				try
					value = new Function('return ' + args[1] + ';')()
					value = '笨蛋,除数为零了啦～' if Math.abs value is Infinity || isNaN(value)
					callback null, {type : 'text', value : args[1]+'等于'+value+'啦,太简单了～'}
				catch e
					callback null, {type : 'text', value : '太难了，计算机都算不出来呢～'}
		},
		{
			name : 'sys_wikiedia',
			handle : (args, options, callback) ->
				url = "http://zh.wikipedia.org/zh-cn/#{args[1]}"
				SuperAgent.get(url).end (res)->
					$ = require 'jquery'
					text = $(res.text).find('#mw-content-text>p:first').text()
					if text.length > 5
						callback null, {type : 'text', value : text}
					else
						callback null, {type : 'text', value : '亲～你的这个问题太难了,我不知道哦～'}
		},
		{
			name : 'sys_member_sign',
			handle : (args, options, callback) ->
				seller = options.username
				userid = options.from
				MemberMange.isOpenSing seller, (err, doc) ->
					if not err && doc.length && doc[0]['status'] is 1
						MemberMange.isSign userid, (err, flag)->
							if not err && not flag
								MemberMange.changeScore userid, doc[0]['score'], (err, score) ->
									if not err
										callback null, {type : 'text', value : "签到成功！你目前的积分是#{score}"}
									else
										callback null, {type : 'text', value : "签到失败！#{err.ret} #{err.msg}"}
							else
								callback null, {type : 'text', value : "你今天已经签到过了哦～"}
					else
						callback null, {type : 'text', value : '签到功能还没有开启！'}
		},
		{
			name : "sys_weather",
			handle : (args, options, callback) ->
				city = args[1]
				if not city
					if options.userinfo && options.userinfo.City
						city = options.userinfo.city
					else
						callback null, {type : 'text', value : "不好意思，系统无法获取到您所在的城市。请发送【城市+天气】来查询。 例: 广州天气"}
						return
				Weather.getWeather city, (err, doc) ->
					if not err
						callback null, {type : 'text', value : "#{city}今天的天气:#{doc.weatherinfo.weather}, 最高温度:#{doc.weatherinfo.temp1}, 最低温度:#{doc.weatherinfo.temp2}。"}
					else
						callback null, {type : 'text', value : "对不起,我们暂时还无法查询到#{city}的天气"}
		},
		{
			name : 'sys_activity_list',
			handle : (args, options, callback) ->
				seller = options.username
				userid = options.from
				Activity.getStartActivity seller, (err, doc) ->
					if not err && doc.length
						value = ''
						for row in doc
							value += "<a href=\"http://guide.awang.com/weixincm/activitydetail?userid=#{userid}&activityid="+row['_id']+"\">#{row['name']}</a>\n"
						callback null, {type : 'text', value : value}
					else
						callback null, {type : 'text', value : '该商家还没有开启活动！'}

		}
	]
}

