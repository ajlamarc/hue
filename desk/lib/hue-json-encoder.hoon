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
    [%group s+group.upd]
    [%group-names o+(malt (limo ~(tap by (~(run by group-names.upd) |=(val=@t s+val)))))]
  ==
--