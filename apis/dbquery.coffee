#dbquery
#author:wade

config = require '../config'
ktalk = new (require '../apis/ktalk1')
logger = require('log4js').getLogger __filename
rootPath = require('../../../config').getAppPath()
config2 = require "#{rootPath}/config"
Onepiece_item = config2.getDb 'onepiece_item'

fs = require('fs')
async = require 'async'
exec = require('child_process').exec

server_path = "~/node/node"
if config2.isProductionMode()
	server_path = "/var/baas/node"

class dbquery

	# info: construct jumping url
	# img_level:  which level image Message lies	
	# restype: Respon Type: 0 common query , 1 keyword query, 2 date diary query
	constructUrlWeixin: (id, img_level , restype ) ->
		if restype == 2
			# id now become a target url
			url = id+"&from=weixin&img_level=#{img_level}&restype=#{restype}"
		else
			url = "http://item.taobao.com/item.htm?id=#{id}&from=weixin&img_level=#{img_level}&restype=#{restype}"

		url = "http://www.chaobaida.com/qz/statics/jump?url=" + encodeURIComponent(url)				

	queryHandle : (query, options, callback) ->		
		self = @
		ktalk.getQueryResults query, options, (err, items) ->
			if not items.length			
				# callback null, null
				callback null, type: 'text', value: 'sorry'
			else 				
				i = 0
				while i < items.length					
					items[i].clickUrl = self.constructUrlWeixin(items[i].id,i,0)		
					i++				

				callback null, type: 'item', value: items

	queryHandle_format : (query, ori_msg, options, callback) ->
		self = @
		ktalk.getQueryResults query, options, (err, items) ->
			if not items.length						
				callback null, type: 'text', value: 'sorry'
			else						  
				insert_recommendation = {
					id:"" , 
					title: "【今日最热#{ori_msg}】赶紧点击查看>>", 
					price:"", 
					picUrl:"", 
					clickUrl:"http://www.chaobaida.com/qz/shb/items/?category=#{ori_msg}&from=weixin" 
					}						 
				if query.tags
					insert_recommendation.clickUrl="http://www.chaobaida.com/qz/shb/items/?keyword=#{ori_msg}&from=weixin" 
					insert_recommendation.title = "【今日最热#{ori_msg}单品】赶紧点击查看>>"

				title_q =  new RegExp(ori_msg)
				#desc_q = new RegExp(ori_msg)
				#mod_query = { $or: [{'title':title_q},{'desc':desc_q}] }
				mod_query = {'title':title_q}
				q_options = 
					fail_return:true
					db : 'onepiece_item'                   
					limit : 1
					sort:
						time:-1

				#modify 
				self.queryHandle_wxjournal mod_query, q_options ,(err, items_diary) ->											
					if items_diary.value.length == 1						
						insert_recommendation.clickUrl = items_diary.value[0].url

					Path = []
					id = []
					tempPath = []								
					for i in [0..2]
						Path[i] = items[i].picUrl
						id[i] = items[i].id
						tempPath[i] = "/tmp/#{i}.jpg"
						items[i].clickUrl=self.constructUrlWeixin(items[i].id,i,1 ) 
						# "http://www.chaobaida.com/qz/statics/jump?url=" + encodeURIComponent("http://item.taobao.com/item.htm?id="+items[i+3].id+"&from=weixin")

					OutputPath = "/var/files/common/merge_#{id[0]}_#{id[1]}_#{id[2]}.jpg"
					console.log OutputPath
					#reset picUrl
					insert_recommendation.picUrl = "http://www.chaobaida.com/files/common/merge_#{id[0]}_#{id[1]}_#{id[2]}.jpg" 
					
					#second class result length = 8
					if (query.appCids && query.appCids.toString().length == 8) || query.tags
						for i in [0..2]		
							items[5-i].clickUrl=self.constructUrlWeixin(items[5-i].id, 2-i, 1 )		 
							items[2-i]=items[5-i]
							items.pop()
						   
						fs.exists OutputPath ,(exists) ->
							if not exists
								console.log 'not exists now download each of them'						
								#download to /temp
								async.forEachLimit [0..2],  3, (i, callback) ->
									command = "wget \"#{Path[i]}\" -O #{tempPath[i]} -o /dev/null" 
									console.log command
									exec command, (err, stdout, stderr) ->													 
										logger.error err || stderr if err || stderr
										callback err || stderr, stdout 
								,(err) ->
									
									if not err
										#command = "convert -size !300x100 xc:white -background None \"#{tempPath[0]}\" -geometry !100x100+0+0 -composite \"#{tempPath[1]}\" -geometry !100x100+100+0  -composite  \"#{tempPath[2]}\"  -geometry !100x100+200+0 -composite  \"#{OutputPath}\""
										command ="#{server_path}/apps/ktalk/bin/merge.sh \"#{tempPath[0]}\" \"#{tempPath[1]}\" \"#{tempPath[2]}\"  \"#{OutputPath}\" "
										console.log command
										exec command, (err, stdout, stderr) ->											
											logger.error err || stderr if err || stderr
											callback err || stderr, stdout 
									else								
										console.log err	

							else
								console.log "exists already: " + OutputPath   

					else if query.appCids
						#first class			
						encode_ori_msg = encodeURIComponent(ori_msg)
						#console.log encode_ori_msg
						insert_recommendation.picUrl = "http://www.chaobaida.com/files/common/#{encode_ori_msg}.jpg"
						console.log insert_recommendation.picUrl

					items.unshift insert_recommendation
					options = 
	                    db : 'onepiece_item'                    
	                    sort :
	                        time: 1
	                    limit : 1  

					callback null, type: 'item', value: items

	construct_loop : (items) ->
		self = @
		i = 0
		while i < items.length
			console.log items[i].url
			items[i].url = self.constructUrlWeixin(items[i].url, i, 2)
			i++
		items

	# query from wxjournal
	queryHandle_wxjournal : (query, options, callback) ->
		self = @		
		ktalk.getQueryResults_wxjournal query, options, (err, items) ->			
			if not items.length  
				if not options.fail_return
					query = {}
					options = 
						db : 'onepiece_item'					
						limit : 4
						sort: 
							time : -1
					ktalk.getQueryResults_wxjournal query, options, (err, items) ->
						console.log "return newest diary!"						
						#items = self.construct_loop(items)
						callback null, type: 'image', value: items	
				else
					console.log 'not match in wxjournal'
					callback null, type: 'image', value: ''	
			else				
				#items = self.construct_loop(items)
				callback null, type: 'image', value: items

	queryHandle_activity : (query, options, callback) ->
		ktalk.getQueryResults_wxjournal query, options, (err, items) ->
			if not items.length  	
				callback null, type:'text', value:'sorry, no match code found'
			else
				if items.length==1
					link = "sorry, u need a friend to decode this link"
				else if items.length == 2
					link = "<a href=\"www.taobao.com\">congratulation , u got 50% off now</a>"
				else
					link = "sorry, u already got the decode link"
				
				callback null, type:'text', value:link



module.exports = new dbquery

