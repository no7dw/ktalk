keyword = require '../../../apps/collector/config'
klgMongoDb = require 'klgmongodb'

_ = require 'underscore'
config = require '../../../config'
#database connection
server = {host : 'koala', port : 27017}
if config.isProductionMode()
    server = {host : 'butterfly.local', port : 27017}
mongodbClient = klgMongoDb.initClient server, 'taobao', (err) ->

onepieceMongoDb_popup = klgMongoDb.getClient('onepiece_item', 'itempopup');

class keyword_check
	#pass a msg and then check if it is in the categories
	#return it's cid
	do_keyword_check_cat : (msg) ->
		for val of keyword.item.appCats
			categories = keyword.item.appCats[val].categories
			for key of categories
				result = categories[key]				
				if -1 isnt msg.indexOf(result.name)
					#what if multiple match
					return result

	do_keyword_check_tags : (msg) ->	
		for val of keyword.item.tags			
			name  = keyword.item.tags[val].name			
			if -1 isnt msg.indexOf(name.toLowerCase())				
				return keyword.item.tags[val]				
			#else if -1 isnt name.toLowerCase().indexOf(msg)
				#return keyword.item.tags[val]	
		return ""
			# else 
			# 	return -1		
	
	do_keyword_check_date : (msg) ->
		#console.log	msg+" "+__filename
		reDate = /201[2-3]0[1-9]|1[0-2]0[1-9]|[12][0-9]/
		val = reDate.test msg
		reDate_short = /0[1-9]|1[0-2]0[1-9]|[12][0-9]/
		val_short = reDate_short.test msg
		if  val or val_short		
			return msg
		else
			return ""

	getQueryResults_popup : (query, options, callback) ->
        options = options || {}
        options.limit = options.limit || 20
        options.skip = options.skip || 0
        fields = options.fields || null
        client = mongodbClient
        
        if 'onepiece_item' is options.db        	
            #shb database            
            fields = options.fields || "title picUrl link"
            onepieceMongoDb_popup.find query, fields, {limit : options.limit, sort : options.sort}, (err, docs) ->            	                
                if err
                    console.log err
                    docs = []
                docs = _.map docs, (doc) ->
                    title: doc.title
                    picUrl: doc.picUrl
                    url: doc.link                
                #callback null, docs
                callback null, type: 'image', value: docs
        else        	
        	callback null, null

	TransArrayWithSpace: ( msg ) ->
		msg = msg || ''
		merge=''
		for index in msg 		    
			if merge ==''
				merge =index
			else
				merge=merge+' '+index 
		return merge
		

module.exports = keyword_check
