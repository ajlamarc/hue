/-  *hue
|_  act=action
++  grow
  |%
  ++  noun  act
  --
++  grab
  |%
  ++  noun  action
  ++  json
    =,  dejs:format
    |=  jon=json
    ^-  action
    %.  jon
    %-  of
    :~  [%toggle bo]
        [%bri ni]
        [%code so]
        [%group so]
    ==
  --
++  grad  %noun
--