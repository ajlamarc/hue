/-  spider
/+  strandio
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
=/  [url=@t headers=(list [@t @t]) body=(unit octs)]
  !<  [@t (list [@t @t]) (unit octs)]  arg
=/  =request:http  [%'PUT' url headers body]
=/  =task:iris  [%request request *outbound-config:iris]
=/  =card:agent:gall  [%pass /http-req %arvo %i task]
;<  ~  bind:m  (send-raw-card:strandio card)
;<  res=(pair wire sign-arvo)  bind:m  take-sign-arvo:strandio
?.  ?=([%iris %http-response %finished *] q.res)
  (strand-fail:strand %bad-sign ~)
?~  full-file.client-response.q.res
  (strand-fail:strand %no-body ~)
(pure:m !>(`@t`q.data.u.full-file.client-response.q.res))