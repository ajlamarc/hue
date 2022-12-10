/-  *hue
|%
+$  tokens
  $:  =access-token
      =refresh-token
  ==
::
++  tokens-from-json
  =,  dejs:format
  ^-  $-(json tokens)
  %-  ot
  :~
    [`@tas`'access_token' so]
    [`@tas`'refresh_token' so]
  ==
++  username-from-json
  =,  dejs:format
  %-  ar
  %-  ot
  :~  :-  %success
      %-  ot
      :~  username+so
  ==  ==
++  state-from-json
  |=  [group=@t state=json]
  =,  dejs:format
  =/  s-on   `@t`(rap 3 '/groups/' group '/action/on' ~)
  =/  s-bri  `@t`(rap 3 '/groups/' group '/action/bri' ~)
  %-
  %-  ar
  %-  ot
  :~  :-  %success
      %-  of
      :~  s-on^bo
          s-bri^ni
  ==  ==
  state
--