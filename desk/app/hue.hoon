/-  hue
/+  default-agent,
    dbug,
    *encode-request-body,
    *hue-json-encoder
|%
+$  versioned-state
  $%  state-0
  ==
::
+$  state-0
  $:  %0
      =url:hue
      =code:hue
      =username:hue
      =access-token:hue
      =refresh-token:hue
      =on:hue
      =bri:hue
      =logs:hue
    ==
::
+$  card  card:agent:gall
--
%-  agent:dbug
=|  state-0
=*  state  -
^-  agent:gall
=<
|_  bol=bowl:gall
+*  this  .
  def   ~(. (default-agent this %.n) bol)
  hc    ~(. +> bol)
++  on-init
  ^-  (quip card _this)
  :-  ~
  %=  this
    url  'https://api.meethue.com/route/api/'
    on  %.n
    bri  254
  ==
++  on-save
  ^-  vase
  !>(state)
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  =/  old  !<(versioned-state old-state)
  ?-  -.old
    %0  `this(state old)
  ==
::
++  on-poke
  |=  [=mark =vase]
  ::
  ::  poke types:
  ::  %toggle: turn on/off the lights
  ::  %bri:  change brightness (0-254). Assumes lights are on.
  ::  %code: pass code to backend for generating tokens.
  ::
  ^-  (quip card _this)
  ?>  ?=(%hue-action mark)
  =/  act  !<(action:hue vase)
  ?-  -.act
      %toggle
    :_  this
    %-  change-light-state:hc
    [url +.act bri username access-token]
  ::
      %bri
    :_  this
    %-  change-light-state:hc
    [url %.y +.act username access-token]
  ::
      %code
    [(setup-with-code +.act) this]
  ==
++  on-watch  on-watch:def
++  on-leave  on-leave:def
++  on-peek
  |=  =path
  ::
  ::  scry from frontend, asking for current state.
  ::
  ^-  (unit (unit cage))
  ?+    path  ~|(bad-scry-path/path !!)
      [%x %update ~]
    ``json+!>((update-to-json [on bri code]))
      ::
      [%x %logs ~]
    ``json+!>(a+(limo logs))
  ==
++  on-agent  on-agent:def
++  on-arvo
  |=  [=wire sign=sign-arvo]
  ::
  ::  wire types:
  ::  /light:  resp from light state change
  ::  /setup:  resp. from setup-bridge. Contains auth/tokens.
  ::  /refresh: behn alert to refresh tokens
  ::  /tokens: resp. from token refresh
  ::
  ^-  (quip card _this)
  ?+  wire  (on-arvo:def wire sign)
      [%light ~]
    ?>  ?=([%khan %arow *] sign)
    ?:  ?=(%.y -.p.sign)
      =/  state  q.q.p.p.sign
      =/  new-on  ;;(? -.state)
      =/  new-bri  ;;(@ud +.state)
      =/  new-log  a+(limo ~[(sect:enjs:format now.bol) b+new-on (numb:enjs:format new-bri)])
      `this(on new-on, bri new-bri, logs (welp ~[new-log] logs))
    `this :: error! TODO
    ::
      [%setup ~]
    ?>  ?=([%khan %arow *] sign)
    ?:  ?=(%.y -.p.sign)
      =/  resp  !<  
        $:  
          =username:hue
          =code:hue
          =access-token:hue
          =refresh-token:hue
        ==
        q.p.p.sign
      :-  (set-refresh-timer:hc now.bol)
      %=  this
        username  username.resp
        code  code.resp
        access-token  access-token.resp
        refresh-token  refresh-token.resp
      ==
    `this :: error! TODO
    :: either retry (infinite loop potentially)
    :: or notify user that their code is wrong
    ::
      [%refresh ~]
    ?>  ?=([%behn %wake *] sign)
    [(refresh-tokens:hc refresh-token) this]
    ::
      [%tokens ~]
    ?>  ?=([%khan %arow *] sign)
    ?:  ?=(%.y -.p.sign)
      =/  resp
        !<([=access-token:hue =refresh-token:hue] q.p.p.sign)
      :-  (set-refresh-timer:hc now.bol)
      %=  this
        access-token  access-token.resp
        refresh-token  refresh-token.resp
      ==
    `this :: error! TODO
  ==
++  on-fail   on-fail:def
--
|_  bol=bowl:gall
::
++  change-light-state
|=  [=url:hue =on:hue =bri:hue =username:hue =access-token:hue]
|^
  =/  body  ~[['on' b+on] ['bri' n+`@t`(scot %ud bri)]]
  =/  auth  `@t`(cat 3 'Bearer ' access-token)
  =;  cag=cage
    [%pass /light %arvo %k %fard %hue %put-request cag]~
  :-  %noun
  !>  ^-  [@t (list [@t @t]) (unit octs)]
  :-  `@t`(rap 3 url username '/groups/0/action' ~)
  :_  (encode-request-body body)
  :~  ['Content-Type' 'application/json']
      ['Authorization' auth]
  ==
--
::
++  setup-with-code
|=  [=code:hue]
^-  (list card)
  [%pass /setup %arvo %k %fard %hue %setup-bridge noun+!>(code)]~
::
++  set-refresh-timer
|=  [now=@da]
^-  (list card)
  [%pass /refresh %arvo %b %wait (add ~d6 now)]~
++  refresh-tokens
|=  [=refresh-token:hue]
^-  (list card)
  =;  cag=cage
    [%pass /tokens %arvo %k %fard %hue %post-for-tokens cag]~
  :-  %noun
  !>  ^-  [url=@t headers=(list [@t @t]) body=(unit octs)]
  :-  'https://api.meethue.com/oauth2/refresh?grant_type=refresh_token'
  :_  (some (as-octt:mimes:html (weld "refresh_token=" (trip refresh-token))))
  :~  ['Authorization' 'Basic ZWF6UGRNWkJHOUxIZkdCb2lkN3REbVpyekNlN0VGM1Y6aWxiTXkwZkxsajlPT29jZw==']
      ['Content-Type' 'application/x-www-form-urlencoded']
  ==
--