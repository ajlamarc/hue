/-  *hue
|%
::
++  update-to-json
  |=  upd=update
  ^-  json
  =,  enjs:format
  %-  pairs
  :~
    [%on b+on.upd]
    [%bri n+(scot %ud bri.upd)]
    [%code s+code.upd]
  ==
--