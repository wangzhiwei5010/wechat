FROM ubuntu:16.04
MAINTAINER peter <wangzhiwei5010@126.com>
LABEL Description="add Mojo::Weixin from ubuntu:16.04" Version="1.0"
RUN su
WORKDIR /root
EXPOSE 6667 3000
COPY . .
RUN mv -f sources.list /etc/apt/
RUN apt-get update
RUN apt-get install -y perl \
    libssl-dev \
    wget \
    curl \
    cpanminus \
    pkg-config \
    language-pack-zh-hans
RUN export LANG="zh_CN.UTF-8"
RUN cpanm Mojo::Weixin Net::SSLeay Crypt::OpenSSL::RSA IO::Socket::SSL Crypt::OpenSSL::Bignum Mojo::IRC::Server::Chinese
RUN apt-get autoremove && apt-get autoclean
CMD ["perl", "wechat.pl"]