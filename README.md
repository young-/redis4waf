# redis4waf
web application firewall use redis cache

# 说明
waf使用redis缓存数据

使用redis缓存数据可以保持数据的持久性；

即使nginx、redis重启，数据依然存在且有效

# 安装说明
openresty安装完毕

nginx.conf http中添加模块

    lua_package_path "/opt/openresty/lualib/resty/?.lua;;/opt/openresty/nginx/conf/_waf/?.lua;;";

    init_by_lua_file "/opt/openresty/nginx/conf/_waf/function_lib.lua";

    access_by_lua_file "/opt/openresty/nginx/conf/_waf/redis_connect.lua";

（根据实际路径修改）
    
把三个文件放入到conf/_waf/

config.lua  function_lib.lua  redis_connect.lua

增加一个nginx服务
```
    server {
        listen       80;
        server_name  localhost;

        charset utf-8;

        access_log  /var/log/nginx/host.access.log  main;

        location / {
            root   html;
            index  index.html index.htm;
        }
        location /hello {
            default_type text/html;
            content_by_lua_block {
                ngx.say("<h1>HelloWorld</h1>")
            }
        }

    }
  ```
  
  访问测试
  ---
# 配置文件说明
  ```
  cat config.lua 
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
  ```
