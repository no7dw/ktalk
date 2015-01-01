# author : wade
# info: Format

class Format

	#return callback null, type: 'text', value: '不能理解你指定的时间，具体点好吗？如：20130321, 0321'
	formatDigit2Time : (digit) ->
	    len  = digit.length
	    #console.log len
	    if len < 4
	        return ""
	    else if len == 4        
	        return '2013-'+digit[0..1]+'-'+digit[2..3]
	    else if len ==6
	        return  digit[0..3]+'-0'+digit[4]+'-0'+ digit[5]
	    else if len ==7 and  digit[5..6] <= '31' and digit[4..5] > '12' 
	        return  digit[0..3]+'-0'+digit[4]+'-'+digit[5..6]
	    else if len ==7 and  digit[4..5] <= '12' and digit[5..6] > '31'
	        return  digit[0..3]+'-'+digit[4..5]+'-0'+digit[6]    
	    else if len ==7 and  digit[5..6] <= '31' and digit[4..5] <= '12'
	       console.log 'arbigus'
	       return ""
	    else if len ==8 and ('2012'==digit[0..3] or '2013'==digit[0..3])
	        if -1 == digit.indexOf('-')            
	            return digit[0..3]+'-'+digit[4..5]+'-'+digit[6..7]    
	        else            
	            return digit[0..3]+'-0'+digit[5]+'-0'+digit[7]    
	    else if len ==9
	        if '-' == digit[6]
	            return digit[0..3]+'-0'+digit[5]+'-'+digit[7..8]
	        else
	            return digit[0..3]+'-'+digit[5..6]+'-0'+digit[8] 
	    else if len == 10 
	        return digit
	    else 
	        return ""

	genRandomIndex : (start, end) ->
	    parseInt(Math.random()*(end-start+1)+start)       

	add_static_link : (index) ->
		add = ["\n<a href=\"http://www.chaobaida.com/qz/shb/items/?category=#{encodeURIComponent("特价")}&style=#{encodeURIComponent("全部")}\">【今日特价宝贝】</a>" ]
		add.push "\n<a href=\"http://www.chaobaida.com/qz/shb/items?from=weixin\">【今日省荷包单品推荐】</a>"
		return add[index]

module.exports = new Format
