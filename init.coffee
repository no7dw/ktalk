config = require "#{process._appPath}/config"
appPath = config.getAppPath

init = (app) ->
    require('./routes') app
    
module.exports = init