# user defined in /etc/apache2/envvars
# default user www-data
chown -R ${APACHE_RUN_USER}:${APACHE_RUN_GROUP}  /var/log/php

/var/www/html/install/install.tar.gz

#Tasks
Install&Test opencart

#批量导出数据库
https://www.baidu.com/s?ie=UTF-8&wd=shell%20%E6%89%B9%E9%87%8F%E5%AF%BC%E5%87%BAMySQL%E6%95%B0%E6%8D%AE%E5%BA%93


#抄袭文章底部分享代码
http://zmingcx.com/wordpress-backup-and-recovery.html

# backup database
http://www.forece.net/post/3285.htm

mysqldump -h localhost -pZp1214@web.sQL ${databasename} -u root >${databasename}.sql

http://zhidao.baidu.com/question/282265574.html


#!/bin/bash
path="/var/www"
mkdir -p /var/www/a
cd $path
for filename in `ls`
do
  cat >/var/www/a/${filename}.txt<<eof
${filename}
eof
echo $filename 
done


#去掉Mac产生的文件
find / -name .DS_Store -exec rm {} \;




https://www.linode.com/docs/websites/cms/how-to-install-and-configure-wordpress
https://www.linode.com/docs/websites/apache-tips-and-tricks/tuning-your-apache-server

The first things to check (or ask your host provider to check) are the values of upload_max_filesize, memory_limit and post_max_size in the php.ini configuration file. All of these three settings limit the maximum size of data that can be submitted and handled by PHP. One user also said that post_max_size and memory_limit need to be larger than upload_max_filesize. 

UPDATE wp_options SET option_value = replace( option_value, 'www.zhangpeng.info', 'localhost/wordpress' ) WHERE option_name = 'home' OR option_name = 'siteurl'; 
UPDATE wp_posts SET guid = replace( guid, 'www.zhangpeng.info', 'localhost/wordpress' ) ;
UPDATE wp_posts SET post_content = replace( post_content, 'www.zhangpeng.info', 'localhost/wordpress' ) ;
UPDATE wp_comments SET comment_content = replace( comment_content, 'www.zhangpeng.info', 'localhost/wordpress' ) ;
UPDATE wp_comments SET comment_author_url = replace( comment_author_url, 'www.zhangpeng.info', 'localhost/wordpress' ) ;


前一篇文章中讲了如何在服务器上通过SSH的Tar压缩命令备份文件，那么这篇文章就是说的数据库了。为什么用SSH来备份数据库呢，一个是稳定，另外一个是方便。之前 Forece 用过 Cpanel 自带的 Phpmyadmin 来备份数据库，由于博客数据量很大，每次导出的数据库大小都不一样，那么肯定就是出现错误了呗。用SSH备份的好处就是速度快，备份完之后也很方便下载到本地。另外导入的时候也可以用 SSH 来导入，一般来说 Phpmyadmin 最大的数据库文件只支持到50MB，所以如果你的数据库和 Forece 的一样，比较大的话，那么乖乖的用SSH导入数据库或者用其他数据库工具导入吧。

首先确保你的空间已经开通 SSH 功能，如果没有请联系空间商将此功能打开，然后通过 Putty 连接我们的空间。输入用户名密码，Putty 就会打开一个类似于 CMD 命令行的窗口。然后我们用 TAR 或者 ZIP 命令来打包我们的网站文件夹。


备份数据的过程：

1
mysqldump -h mysql.forece.net -p mysql_dbname -u mysql_dbuser >bak.sql
这里的mysql.forece.net是您的数据库服务器地址，如果你数据库没有域名的话，那么就直接填写 localhost 也可以，mysql_dbname是您的数据库名称，mysql_dbuser 是您的数据库用户名，bak.sql是你备份的数据库的脚本文件名称(将来可用来恢复数据)。然后回车，提示你输入数据库登陆密码，输入完密码后回车即可，Liunx下输入密码是不回显的，所以你只管输入，注意别错了就行啦!


OK了，这时候，你的数据库已经备份完毕，直接用FTP工具拖到本机备份吧。


导入(恢复)数据的过程：
依然还是在之前SSH的命令行模式下，输入以下命令进入数据库：

1
mysql -h mysql.forece.net -p mysql_dbname -u mysql_dbuser
然后回车，提示你输入数据库登陆密码，输入密码后，回车会出现MySQL操作提示符号，之后输入下面的命令：

1
source bak.sql


注意要先确认bak.sql这个文件在当前目录下哦，没问题后点击 回车，这是就开始恢复数据啦，耐心等待一会儿吧。。。


PS一句：刚才看到万戈用 Shell 命令导入数据库，用的是 Mysql 命令，大家也可以借鉴一下。