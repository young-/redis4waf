-- "bantime" is the number of seconds that a host is banned.
bantime  = 60

-- A host is banned if it has generated "maxretry" during the last "findtime"
-- seconds.
findtime  = 60

-- "maxretry" is the number of failures before a host get banned.
maxretry = 5

-- 'on'/'off' 默认只统计单个IP的访问量，如果需要IP+URL统计访问量，开启
IP_URL='on'

-- 'on'/'off' 统计访问量时是否连带统计url参数,如果IP_URL = off,则忽略URL_ARGS
URL_ARGS = 'on'


-- 限制返回页面
config_output_html=[[
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="Content-Language" content="zh-cn" />
<title>网站防火墙</title>
</head>
<body>
<br><br><br><br><br><br><br><br><br><br>
<h1 align="center">当前访问疑似黑客攻击，已被拦截。</h1>
</body>
</html>
]]
