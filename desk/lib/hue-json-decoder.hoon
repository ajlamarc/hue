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
  =,  dejs:format
  %-  ar
  %-  ot
  :~  :-  %success
      %-  of
      :~  '/groups/0/action/on'^bo
          '/groups/0/action/bri'^ni
  ==  ==
--