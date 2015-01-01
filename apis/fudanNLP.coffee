exec = require('child_process').exec
rootPath = require('../../../config').getAppPath()

work_dir = "#{rootPath}/../FudanNLP"

class fudanNLP

	KeyWordExtraction : (msg, callback) ->	
		callback null, '' #this for temp use , because the following take too much time
		return 

		command = "#{work_dir}/good.cmd \"#{msg}\""
		console.log command
		env = {	cwd : work_dir}
		exec command, env ,(err, stdout, stderr) ->
			if err
				console.log err				
				callback err, ""
			else
				pattern2match = /\=/g						
				result = stdout
				result = result.replace(pattern2match, ':')				
				data = eval("(" + result + ")")
				console.log data											
				callback null, data
										

module.exports = fudanNLP