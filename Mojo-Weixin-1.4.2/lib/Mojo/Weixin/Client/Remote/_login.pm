sub Mojo::Weixin::_login {
    my $self = shift;
    $self->info("客户端准备登录...");
    my $api = 'https://login.'. $self->domain .'/cgi-bin/mmwebwx-bin/login';
    if(not $self->_is_need_login()){
        $self->info("检测到近期登录活动，尝试直接恢复登录");
        $self->wxuin($self->search_cookie("wxuin"));
        $self->wxsid($self->search_cookie("wxsid"));
        if(defined $self->wxuin and defined $self->wxsid){
            $self->login_state("success");
            return 1;
        }
    }
    else{
        $self->info("登录状态已失效，需要重新登录");
        $self->clear_cookie();
    }
    my $qrcode_uuid = $self->_get_qrcode_uuid(); 
    if(not defined $qrcode_uuid){
        $self->info("无法获取到登录二维码，登录失败");
        $self->stop();
    }
    $self->qrcode_uuid($qrcode_uuid);
    if(not $self->_get_qrcode_image($qrcode_uuid)){
        $self->info("下载二维码失败，客户端退出");
        $self->stop();
    }
    my $i=1;
    $self->info("等待手机微信扫描二维码...");
    $self->state('scaning');
    while(1){
        $self->check_controller();
        my @query_string = (
            loginicon => 'true',
            uuid    =>  $qrcode_uuid,
            tip     =>  $show_tip ,
            r       =>  sub{use integer;unpack 'i',~ pack 'l',$self->now() & 0xFFFFFFFF}->(),
            _       =>  $self->now(),
        );
        my $r = $self->http_get($self->gen_url($api,@query_string));
        next unless defined $r;
        my %data = $r=~/window\.(.+?)=(.+?);/g;
        $data{redirect_uri}=~s/^["']|["']$//g if defined $data{redirect_uri};
        if($data{code} == 408){
            select undef,undef,undef,0.5;
            if($i==5){
                $self->emit("qrcode_expire");
                $self->info("登录二维码已失效，重新获取二维码");
                $qrcode_uuid = $self->_get_qrcode_uuid();
                $self->_get_qrcode_image($qrcode_uuid);
                $self->state('scaning');
                $i = 1;
                next;
            }
            $i++;
        }
        elsif($data{code} == 201){
            $self->info("手机微信扫码成功，请在手机微信上点击 [登录] 按钮...");
            $self->state('confirming');
            $show_tip = 0;
            next;

        }
        elsif($data{code} == 200){
            $self->info("正在进行登录...");
            if($data{redirect_uri}=~m#https?://([^/]+)#m){
                $self->domain($1) if ($1 and $1 ne $self->domain);
            }
            my $data = $self->http_get($data{redirect_uri} . '&fun=new&version=v2&mod=desktop&lang=zh_CN',{Referer=>'https://' . $self->domain . '/','Client-Version' => '2.0.0','Extspam' => 'Go8FCIkFEokFCggwMDAwMDAwMRAGGvAESySibk50w5Wb3uTl2c2h64jVVrV7gNs06GFlWplHQbY/5FfiO++1yH4ykCyNPWKXmco+wfQzK5R98D3so7rJ5LmGFvBLjGceleySrc3SOf2Pc1gVehzJgODeS0lDL3/I/0S2SSE98YgKleq6Uqx6ndTy9yaL9qFxJL7eiA/R3SEfTaW1SBoSITIu+EEkXff+Pv8NHOk7N57rcGk1w0ZzRrQDkXTOXFN2iHYIzAAZPIOY45Lsh+A4slpgnDiaOvRtlQYCt97nmPLuTipOJ8Qc5pM7ZsOsAPPrCQL7nK0I7aPrFDF0q4ziUUKettzW8MrAaiVfmbD1/VkmLNVqqZVvBCtRblXb5FHmtS8FxnqCzYP4WFvz3T0TcrOqwLX1M/DQvcHaGGw0B0y4bZMs7lVScGBFxMj3vbFi2SRKbKhaitxHfYHAOAa0X7/MSS0RNAjdwoyGHeOepXOKY+h3iHeqCvgOH6LOifdHf/1aaZNwSkGotYnYScW8Yx63LnSwba7+hESrtPa/huRmB9KWvMCKbDThL/nne14hnL277EDCSocPu3rOSYjuB9gKSOdVmWsj9Dxb/iZIe+S6AiG29Esm+/eUacSba0k8wn5HhHg9d4tIcixrxveflc8vi2/wNQGVFNsGO6tB5WF0xf/plngOvQ1/ivGV/C1Qpdhzznh0ExAVJ6dwzNg7qIEBaw+BzTJTUuRcPk92Sn6QDn2Pu3mpONaEumacjW4w6ipPnPw+g2TfywJjeEcpSZaP4Q3YV5HG8D6UjWA4GSkBKculWpdCMadx0usMomsSS/74QgpYqcPkmamB4nVv1JxczYITIqItIKjD35IGKAUwAA=='});
            #<error><ret>0</ret><message>OK</message><skey>@crypt_859d8a8a_3f3db5290570080d1db29da9507e35de</skey><wxsid>rsuMHe7xmA0aHW1D</wxsid><wxuin>138122335</wxuin><pass_ticket>hWdpMVCMqXIVfhXLcsJxYrC6bv785tVDLZAres096ZE%3D</pass_ticket></error
            if($data !~ m#^<error>.*</error>#){
                $self->error("登录返回数据格式无效");
                return 0;
            }
            my %d = $data=~/<([^<>]+?)>([^<>]+?)<\/\1>/g;
            if($d{ret}!=0){
                $self->error("登录返回状态码异常: $d{ret}, $d{message}");
                $self->emit(login => -1,$d{message});
                return 0;
            }
            $self->skey($d{skey} || '');
            $self->wxsid($d{wxsid} || $self->search_cookie("wxsid"));
            $self->wxuin($d{wxuin} || $self->search_cookie("wxuin"));
            $self->pass_ticket($d{pass_ticket} || '');
            $self->info("微信登录成功");
            $self->login_state("success");
            return 2;
        }
        elsif($data{code} == 400){
            $self->info("登录错误，客户端退出");
            $self->stop();
            last;
        }
        elsif($data{code} == 500){
            $self->info("登录错误，客户端尝试重新登录...");
            $i = 1;
            $show_tip = 1;
            $qrcode_uuid = $self->_get_qrcode_uuid();
            $self->_get_qrcode_image($qrcode_uuid);
            $self->state('scaning');
            next;
        }
    }
}
1;
