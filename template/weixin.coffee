module.exports =
    templates :[
        {
            name: "sys_text"
            type: "text"
            template: (text, callback) ->
                callback null, {type : 'text', value : text};
        }
        {
            name: "sys_news"
            type: "news"
            template: (items, callback) ->
                results = for item in items
                    id : item.id, title : item.title, description : "价格 ￥#{item.price}", picUrl : item.picUrl, url : "http://item.taobao.com/item.htm?id=#{item.id}"

                #pics size
                results[0]?.picUrl = results[0].picUrl + '_310x310.jpg'
                for result, i in results
                    continue if i is 0
                    results[i].picUrl += '_80x80.jpg'
                callback null, results
        }
    ]