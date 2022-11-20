|%
+$  tokens
  $:  access-token=@t
      refresh-token=@t
  ==
+$  state
  $:  on=?
      bri=@ud
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
      ==
  ==
:: ++  state-from-json
::   =,  dejs:format
::   ^-  $-(json state)
::   %-  ar
::   %-  ot
::   :~  :-  %success
::       %-  ot
::       :~  ['/groups/0/action/on' bo]
::       ==
::   :-  %success
::       %-  ot
::       :~  ['/groups/0/action/bri' ni]
::       ==
::   ==
--