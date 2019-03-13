FROM ubuntu:16.04
MAINTAINER peter <wangzhiwei5010@126.com>
LABEL Description="add Mojo::Weixin from ubuntu:16.04" Version="1.0"
RUN su
WORKDIR /root
EXPOSE 6667 3000
RUN apt-get update
RUN apt-get install -y perl \
    curl \
    libssl-dev \
    cpanminus \
    build-essential \
    libpng16-16 \
    libpng16-dev \
    wget \
    pkg-config \
    zlib1g \
    zlib1g-dev \
    libtext-qrcode-perl \
    language-pack-zh-hans
RUN export LANG="zh_CN.UTF-8"
RUN cpanm Mojo::Weixin Net::SSLeay Crypt::OpenSSL::RSA IO::Socket::SSL Crypt::OpenSSL::Bignum Mojo::IRC::Server::Chinese Term::QRCode
ADD wechat.pl /root
ADD Mojo-Weixin-1.4.2 /root/Mojo-Weixin-1.4.2
RUN apt-get install -y vim && apt-get autoremove && apt-get autoclean
CMD ["perl", "wechat.pl"]