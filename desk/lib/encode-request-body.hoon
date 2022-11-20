|%
++  encode-request-body
  |*  body=*
  ^-  (unit octs)
  (some (as-octt:mimes:html (en-json:html o+(malt (limo body)))))
--