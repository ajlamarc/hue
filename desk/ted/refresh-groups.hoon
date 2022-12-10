/-  spider
/+  strandio, *hue-json-decoder
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
=/  [url=@t headers=(list [@t @t]) group=@t]
  !<  [@t (list [@t @t]) @t]  arg
::  ************* Request 1: GET names of all groups *************
=/  =request:http  [%'GET' url headers ~]
=/  =task:iris  [%request request *outbound-config:iris]
=/  =card:agent:gall  [%pass /http-req %arvo %i task]
;<  ~  bind:m  (send-raw-card:strandio card)
;<  res=(pair wire sign-arvo)  bind:m  take-sign-arvo:strandio
?.  ?=([%iris %http-response %finished *] q.res)
  (strand-fail:strand %bad-sign ~)
?~  full-file.client-response.q.res
  (strand-fail:strand %no-body ~)
=/  resp  `@t`q.data.u.full-file.client-response.q.res
=/  jon  (de-json:html resp)
=/  name-map  (groups-from-json (need jon))
::  *************** END REQUEST 1 ***************
::
::  ************* Request 2: GET currently selected group's state *************
=.  url  `@t`(rap 3 url '/' group ~)
=/  =request:http  [%'GET' url headers ~]
=/  =task:iris  [%request request *outbound-config:iris]
=/  =card:agent:gall  [%pass /http-req %arvo %i task]
;<  ~  bind:m  (send-raw-card:strandio card)
;<  res=(pair wire sign-arvo)  bind:m  take-sign-arvo:strandio
?.  ?=([%iris %http-response %finished *] q.res)
  (strand-fail:strand %bad-sign ~)
?~  full-file.client-response.q.res
  (strand-fail:strand %no-body ~)
=/  resp   `@t`q.data.u.full-file.client-response.q.res
=/  jon    (de-json:html resp)
=/  state  (group-from-json (need jon))
(pure:m !>([state=state name-map=name-map]))