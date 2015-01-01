fs = require 'fs'
path = require 'path'
logger = require("../../../common/helpers/logger").getLogger __filename


class Util
    constructor : () ->

    ###
    #   读取文件列表
    ###
    getDirFilesName : (path, callback) ->
        fs.readdir path, (err, files) ->
            if err
                logger.error err
                files = []
            else
                filesName = (name for name in files when name.indexOf('.js') >= 0 or name.indexOf('.coffee') >= 0)
            callback err, filesName


    ###
    #   读取文件夹列表
    ###
    getDirDirsName : (path, callback) ->
        fs.readdir path, (err, files) ->
            if err
                logger.error err
                files = []
            else
                filesName = (name for name in files when name.indexOf('.') is -1) #剔除svn目录
            callback err, filesName

    getModuleFromFile : (filePath, callback) ->
        callback null, require filePath

module.exports = new Util