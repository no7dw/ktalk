WecharManage = require './wecharmanage'
fs = require 'fs'
util = require 'util'
# #测试登录
# WecharManage.login '1420280082@qq.com','kalengo2010', (err, cookie) ->
# 	if !err
# 		console.log cookie
# 	else
# 		console.log '登录错误'+err.msg

#测试发送信息
# WecharManage.login '1420280082@qq.com','kalengo2010', (err, cookie) ->
# 	if !err
# 		WecharManage.sendMessage cookie, {msg : '/色 这是第六条～～～～～', fakeid : 1706094420}, (err, data) ->
# 			console.log data
# 	else
# 		console.log '登录错误'+err.msg

#获得粉丝列表
# WecharManage.login '1420280082@qq.com','kalengo2010', (err, cookie) ->
# 	if !err
# 		WecharManage.getFans cookie, (err, friends) ->
# 			console.log friends
# 	else
# 		console.log '登录错误'+err.msg
# 		

#获得二维码 		
# WecharManage.login '1420280082@qq.com','kalengo2010', (err, cookie) ->
# 	if !err
# 		WecharManage.getQrCode cookie, (err, qrcode) ->
# 			console.log qrcode
# 	else
# 		console.log '登录错误'+err.msg

#获得用户信息
# WecharManage.login '1420280082@qq.com','kalengo2010', (err, cookie) ->
# 	if !err
# 		WecharManage.getUserInfo cookie, "31423635", (err, data) ->
# 			console.log data
# 	else
# 		console.log '登录错误'+err.msg

#关闭开发者模式
# WecharManage.login '1420280082@qq.com','kalengo2010', (err, cookie) ->
# 	if !err
# 		WecharManage.operadvanced cookie, 0, (err, data) ->
# 			console.log data
# 	else
# 		console.log '登录错误'+err.msg

#开启开发者模式
# WecharManage.login '1420280082@qq.com','kalengo2010', (err, cookie) ->
# 	if !err
# 		WecharManage.operadvanced cookie, 1, (err, data) ->
# 			console.log data
# 	else
# 		console.log '登录错误'+err.msg


#绑定回调地址
# WecharManage.login '1420280082@qq.com','kalengo2010', (err, cookie) ->
# 	if !err
# 		WecharManage.profile cookie, {url : 'http://weixinguang.com/weixin_connect?token=3622584800acbc44764b6474bd8b0f4e', token : '3622584800acbc44764b6474bd8b0f4e'}, (err, data) ->
# 			console.log data #data.ret -204 基础信息不全  -201 无效的URL -202无效的Token -203 操作太快 -301 请求超时 -302服务器没有正确的响应token验证
# 	else
# 		console.log '登录错误'+err.msg

#群发
# WecharManage.login '1420280082@qq.com','kalengo2010', (err, cookie) ->
# 	if !err
# 		WecharManage.masssend cookie, '测试发送信息', (err, data) ->
# 			console.log data #data.ret -204 基础信息不全  -201 无效的URL -202无效的Token -203 操作太快 -301 请求超时 -302服务器没有正确的响应token验证
# 	else
# 		console.log '登录错误'+err.msg

#上传图片
# WecharManage.login '1420280082@qq.com','kalengo2010', (err, cookie) ->
# 	if !err
# 		image = fs.createReadStream('/Users/lynxcat/Pictures/a395560.jpg')
# 		WecharManage.uploadmaterial cookie, image, (err, data) ->
# 			console.log data #data.ret -204 基础信息不全  -201 无效的URL -202无效的Token -203 操作太快 -301 请求超时 -302服务器没有正确的响应token验证
# 	else
# 		console.log '登录错误'+err.msg
# 		
# 		


#创建文章
# WecharManage.login '1420280082@qq.com','kalengo2010', (err, cookie) ->
# 	if !err
# 		WecharManage.operateappmsg cookie, {
# 			count : 1,
# 			title0 : '阴阳家少司命～',
# 			degest0 : '可爱的少少～',
# 			content0 : '<p>少司命～</p>',
# 			fileid0 : 10000026
# 		}, (err, data) ->
# 			console.log data #data.ret -204 基础信息不全  -201 无效的URL -202无效的Token -203 操作太快 -301 请求超时 -302服务器没有正确的响应token验证
# 	else
# 		console.log '登录错误'+err.msg

#群发消息
# WecharManage.login '1420280082@qq.com','kalengo2010', (err, cookie) ->
# 	if !err
# 		WecharManage.sendImageMessageToAll cookie, 10000029, (err, data) ->
# 			console.log data #data.ret -204 基础信息不全  -201 无效的URL -202无效的Token -203 操作太快 -301 请求超时 -302服务器没有正确的响应token验证
# 	else
# 		console.log '登录错误'+err.msg

#创建一整篇文章
# WecharManage.login '1420280082@qq.com','kalengo2010', (err, cookie) ->
# 	if !err
# 		image = fs.createReadStream('/Users/lynxcat/Pictures/shaoshiming.jpg')
# 		WecharManage.uploadmaterial cookie, image, (err, data) ->
# 			if not err
# 				WecharManage.operateappmsg cookie, {
# 					count : 1,
# 					title0 : '-0-，亲.这个消息程序是全自动法的哦',
# 					degest0 : '可爱的少少～',
# 					content0 : '<p>依旧是可耐的小司～</p>',
# 					fileid0 : data.formId
# 				}, (err, data) ->
# 					console.log data #data.ret -204 基础信息不全  -201 无效的URL -202无效的Token -203 操作太快 -301 请求超时 -302服务器没有正确的响应token验证
# 			else
# 				console.log data
# 	else
# 		console.log '登录错误'+err.msg

#发送一篇文章给用户
# WecharManage.login '1420280082@qq.com','kalengo2010', (err, cookie) ->
# 	if !err
# 		WecharManage.sendImageMessage cookie, {appmsgid : 10000043, fakeid : 1706094420}, (err, data) ->
# 			console.log data #data.ret -204 基础信息不全  -201 无效的URL -202无效的Token -203 操作太快 -301 请求超时 -302服务器没有正确的响应token验证
# 	else
# 		console.log '登录错误'+err.msg

#获得第一篇文章的appmsgid
# WecharManage.login '1420280082@qq.com','kalengo2010', (err, cookie) ->
# 	if !err
# 		WecharManage.getAppmsgid cookie, (err, data) ->
# 			console.log data 
# 	else
# 		console.log '登录错误'+err.msg

#全自动发送一条消息
# WecharManage.login '1420280082@qq.com','kalengo2010', (err, cookie) ->
# 	if !err
# 		image = fs.createReadStream('/Users/lynxcat/Pictures/shaoshiming.jpg')
# 		WecharManage.uploadmaterial cookie, image, (err, data) ->
# 			if not err
# 				WecharManage.operateappmsg cookie, {
# 					count : 1,
# 					title0 : '-0-，亲.这个消息程序是全自动发的哦',
# 					degest0 : '可爱的少少～',
# 					content0 : '<p>依旧是可耐的小司～</p>',
# 					fileid0 : data.formId
# 				}, (err, data) ->
# 					if not err
# 						WecharManage.getAppmsgid cookie, (err, data) ->
# 							if not err
# 								WecharManage.sendImageMessage cookie, {fakeid : 31423635, appmsgid : data.appmsgid}, (err, data) ->
# 									console.log data
# 							else
# 								console.log err
# 					else
# 						console.log err
# 			else
# 				console.log err
# 	else
# 		console.log '登录错误'+err.msg

		
