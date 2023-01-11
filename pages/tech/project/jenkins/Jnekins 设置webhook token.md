

添加个人用户的 token

http://192.168.5.149:49000/user/admin/configure



# 问题



> Hook executed successfully but returned HTTP 403 <html> <head> <meta http-equiv="Content-Type" content="text/html;charset=utf-8"/> <title>Error 403 No valid crumb was included in the request</title> </head> <body><h2>HTTP ERROR 403 No valid crumb was included in the request</h2> <table> <tr><th>URI:</th><td>/project/uac-pipe</td></tr> <tr><th>STATUS:</th><td>403</td></tr> <tr><th>MESSAGE:</th><td>No valid crumb was included in the request</td></tr> <tr><th>SERVLET:</th><td>Stapler</td></tr> </table> <hr><a href="https://eclipse.org/jetty">Powered by Jetty:// 9.4.38.v20210224</a><hr/> </body> </html>





解决：

安装插件 

Generic Webhook Trigger 

GitLab

Gitlab Authentication

![image-20210409102518632](C:\Users\Workstation\notes\jenkins\assets\image-20210409102518632.png)