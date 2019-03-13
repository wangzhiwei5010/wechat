#!/usr/bin/env perl
# use lib '/root/Mojo-Weixin-1.4.2/lib';
# use lib '/home/wangzhiwei/Documents/git/Mojo-Weixin/lib';
use Mojo::Weixin;
use Data::Dumper;
my $client = Mojo::Weixin->new(log_encoding=>"utf8","log_path"=>"/root/wechat.log","log_level"=>"info");
$client->load("IRCShell",data=>{
    listen=>[ {host=>"0.0.0.0",port=>6667},], #可选，IRC服务器监听的地址+端口，默认0.0.0.0:6667
    load_friend => 1, #默认是0 是否初始为每个好友生成irc虚拟帐号并加入频道 #我的好友
});
#$poll_api = 'http://xxxx';
#data是一个HASH引用
# $client->load("Openwx",data=>{
#     listen => [ {host=>"0.0.0.0",port=>3000}, ] , #监听的地址和端口，支持多个，默认监听0.0.0.0:3000
#     auth   => sub {my($param,$controller) = @_},    #可选，认证回调函数，用于进行请求鉴权
#     # post_api => 'http://xxxx',                      #可选，你自定义的接收消息上报接口
#     post_event => 1,                                #可选，是否上报事件，为了向后兼容性，默认值为0
#     post_stdout => 0,                               #可选，上报数据是否打印到stdout，适合管道交互信息方式，默认0
#     post_media_data => 1,                           #可选，是否上报经过base64编码的图片原始数据，默认值为1
#     post_event_list => ['login','stop','state/_change','input_qrcode'], #可选，上报事件列表
#     #poll_api  => 'http://xxxx',                     #可选，从外网调用内网程序的api时需要使用到，默认不启用
#     #poll_interval   => 5,                           #可选，长轮询请求间隔，默认5s
# });
$client->load("ShowMsg");
#$client->load("ShowQRCodeInTerm");
$client->load("Translation");
# 
# 
$client->load("PostQRcode",data=>{
    smtp    =>  'smtp.126.com', #邮箱的smtp地址
    port    =>  '25', #smtp服务器端口，默认25
    from    =>  'mydevmail@126.com', #发件人
    to      =>  'wangzhiwei5010@126.com', #收件人
    user    =>  'mydevmail@126.com', #smtp登录帐号
    pass    =>  'wzw520Gxd' #smtp登录密码
    #tls     =>  0      #可选，是否使用SMTPS协议，默认为0                            
                        #在没有设置的情况下，如果使用的端口为465，则该选项会自动被设置为1
});

#ready事件触发时 表示客户端一切准备就绪：已经成功登录、已经加载完个人/好友/群信息等
#你的代码建议尽量写在 ready 事件中
$client->on(ready=>sub{});

$client->run();
