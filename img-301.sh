//LNMPA图片防盗链方法

LNMPA环境下Nginx作为前端服务器可以更快更直接的处理静态资源，由此图片防盗链规则可直接在nginx的配置下进行设置，设置方法很简单，如下：

找到图片服务器nginx的config文件，找到类似如下的代码：

location ~ .*\.(gif|jpg|jpeg|png|bmp|swf|ico)$
{
expires 30d;
}
修改为如下即可（根据自己网站的情况修改其中地址即可）：

location ~ .*\.(gif|jpg|jpeg|png|bmp|swf|ico)$
{
valid_referers none blocked server_names
*.amznz.com *.duliboke.net *.baidu.com *.so.com
~\.google\. ~\.yahoo\.;
if ($invalid_referer) {
rewrite ^/ http://www.amznz.com/nopic.gif;
#return 403;
}
expires 30d;
}
参数说明：
none
缺少“Referer”请求头；
blocked
“Referer” 请求头存在，但是它的值被防火墙或者代理服务器删除； 这些值都不以“http://” 或者 “https://”字符串作为开头；
server_names
“Referer” 请求头包含某个虚拟主机名；
任意字符串
定义一个服务器名和可选的URI前缀。服务器名允许在开头或结尾使用“*”符号。 当nginx检查时，“Referer”请求头里的服务器端口将被忽略。
正则表达式
必须以“~”符号作为开头。 需要注意的是表达式会从“http://”或者“https://”之后的文本开始匹配。

参考文档：

http://nginx.org/cn/docs/http/ngx_http_referer_module.html