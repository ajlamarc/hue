/-  *hue
/+  default-agent, dbug, *encode-request-body, *hue-json-decoder, *hue-json-encoder
|%
+$  versioned-state
  $%  state-0
  ==
+$  state-0  $:
  %0  url=@t  code=@t  username=@t  access-token=@t
  refresh-token=@t  on=?(%.y %.n)  bri=@ud
  logs=(list [@da ? @ud])
==
+$  card  card:agent:gall
++  change-light-state
  |=  [url=@t on=?(%.y %.n) bri=@ud username=@t access-token=@t]
  =/  body  ~[['on' b+on] ['bri' n+`@t`(scot %ud bri)]]
  =/  auth  `@t`(cat 3 'Bearer ' access-token)
  :*  %pass  /light  %arvo  %k  %fard
    %hue  %put-request  %noun
    !>  :+
        `@t`(rap 3 url username '/groups/0/action' ~)
        :~  ['Content-Type' 'application/json']
            ['Authorization' auth]
        ==
        (encode-request-body body)
  ==
++  setup-with-code
  |=  [code=@t]
  :*  %pass  /setup  %arvo  %k  %fard
    %hue  %setup-bridge  %noun
    !>  [code]
  ==
++  set-refresh-timer
  |=  [now=@da]
  [%pass /refresh %arvo %b %wait (add ~d6 now)]
++  refresh-tokens
  |=  [refresh-token=@t]
  =/  url  'https://api.meethue.com/oauth2/refresh?grant_type=refresh_token'
  =/  headers  ~[['Authorization' 'Basic ZWF6UGRNWkJHOUxIZkdCb2lkN3REbVpyekNlN0VGM1Y6aWxiTXkwZkxsajlPT29jZw=='] ['Content-Type' 'application/x-www-form-urlencoded']]
  =/  body  (some (as-octt:mimes:html (weld "refresh_token=" (trip refresh-token))))
  :*  %pass  /tokens  %arvo  %k  %fard
    %hue  %post-for-tokens  %noun
    !>  [url headers body]
  ==
--
%-  agent:dbug
=|  state-0
=*  state  -
^-  agent:gall
|_  =bowl:gall
+*  this  .
  def   ~(. (default-agent this %.n) bowl)
++  on-init
  ^-  (quip card _this)
  :-  ~
  %=  this
    url  'https://api.meethue.com/route/api/'
    code  ''
    username  ''
    access-token  ''
    refresh-token  ''
    on  %.n
    bri  254
    logs  *(list [@da ? @ud])
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
  =/  act  !<(action vase)
  ?-  -.act
      %toggle
    :_  this  :~  
      %-  change-light-state
          [url +.act bri username access-token]
    ==
  ::
      %bri
    :_  this  :~  
      %-  change-light-state
          [url %.y +.act username access-token]
    ==
  ::
      %code
    :_  this  ~[(setup-with-code +.act)]
  ==
++  on-watch  on-watch:def
++  on-leave  on-leave:def
++  on-peek
  |=  =path
  ::
  ::  scry from frontend, asking for current state.
  ::
  ^-  (unit (unit cage))
  ?>  ?=([%x %update ~] path)
  :^  ~  ~  %json
  !>  (update-to-json [on bri code])
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
      =/  resp  !<(@t q.p.p.sign)
      ::=/  jon  (de-json:html resp)
      ::=/  state  (state-from-json (need jon))
      ::=/ new-logs (limo (welp ~[[now.bowl on.state bri.state]] logs))
      ::`this(logs new-logs, on on.state, bri bri.state)
      `this
    `this :: error! TODO
    ::
      [%setup ~]
    ?>  ?=([%khan %arow *] sign)
    ?:  ?=(%.y -.p.sign)
      =/  resp  !<  
        $:  
          username=@t 
          code=@t 
          access-token=@t 
          refresh-token=@t
        ==
        q.p.p.sign
      :-  ~[(set-refresh-timer now.bowl)]  
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
    :_  this  ~[(refresh-tokens refresh-token)]
    ::
      [%tokens ~]
    ?>  ?=([%khan %arow *] sign)
    ?:  ?=(%.y -.p.sign)
      =/  resp  !<([access-token=@t refresh-token=@t] q.p.p.sign)
      :-  ~[(set-refresh-timer now.bowl)]
      %=  this
        access-token  access-token.resp
        refresh-token  refresh-token.resp
      ==
    `this :: error! TODO
  ==
++  on-fail   on-fail:def
--