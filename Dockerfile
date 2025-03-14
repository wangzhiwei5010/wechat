FROM wangzhiwei/wechat:arm-base
WORKDIR /root
COPY . .
RUN cpanm Mojolicious@8.01 && cd /root/Mojo-Weixin-1.4.2 && cpanm .
RUN apt-get autoremove && apt-get autoclean
CMD ["mv","/tmp/mojo_weixin_cookie_default.dat","/tmp/delete_cookie.dat"]
CMD ["mv","mojo_weixin_state_default.json","/tmp/delete_state.dat"]
CMD ["perl", "wechat.pl"]