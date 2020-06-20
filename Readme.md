#Install Weechat
```
apt-get update
export LANG="zh_CN.UTF-8"
apt-get install weechat
apt-get install language-pack-zh-hans


/server add wechat 172.17.0.2/6667 --ssl -autoconnect
/set irc.server.wechat.autoconnect on
/script install buffers.pl
/script install autojoin.py

/mouse enable

/set irc.server.wechat.autojoin "#我的好友"
/set irc.server.wechat.nicks "王志伟"
/set irc.server.wechat.username "王志伟"

/set weechat.bar.buffers.position "right"
/set weechat.bar.buffers.size 30
```
