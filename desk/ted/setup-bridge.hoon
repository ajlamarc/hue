/-  spider
/+  strandio, *hue-json-decoder, *encode-request-body
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
::=/  input  !<(@t arg)
::=/  code   +:input
=/  [code=@t]
  !<  [@t]  arg
::  After authorizing UrbHue to access a Philips Hue bridge, a setup code is returned.
::  We still need to make 3 HTTP requests to generate the required values for
::  interacting remotely with the lights: a username, an access token, and a refresh token.
::
::  ************* Request 1: Turn setup code into access and refresh tokens (POST) *************
=/  url  `@t`(rap 3 'https://api.meethue.com/oauth2/token?code=' code '&grant_type=authorization_code' ~)
:: Authorization = base64 encoded username:password (client ID and client secret), always the same
=/  headers  ~[[key='Authorization' value='Basic ZWF6UGRNWkJHOUxIZkdCb2lkN3REbVpyekNlN0VGM1Y6aWxiTXkwZkxsajlPT29jZw=='] [key='Content-Length' value='0']]
=/  =request:http  [%'POST' url headers ~]
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
=/  tokens  (tokens-from-json (need jon))
::~&  >>  tokens
:: ************* End Request 1 *************
:: if requests 2 and 3 fail, we can't use the same code to get access and refresh tokens again
:: consider running the following requests in a child thread, and always returning the tokens.
::
:: next two requests combine to create username, the remote API endpoint for our specific bridge.
::
:: ************* Request 2: Enable Link button for Request 3 (PUT) *************
=.  url  'https://api.meethue.com/route/api/0/config'
=.  headers  ~[[key='Authorization' value=(cat 3 'Bearer ' access-token.tokens)] [key='Content-Type' value='application/json']]
=/  body  (encode-request-body ~[['linkbutton' b+&]])
=.  request  [%'PUT' url headers body]
=.  task  [%request request *outbound-config:iris]
=.  card  [%pass /http-req %arvo %i task]
;<  ~  bind:m  (send-raw-card:strandio card)
;<  res=(pair wire sign-arvo)  bind:m  take-sign-arvo:strandio
?.  ?=([%iris %http-response %finished *] q.res)
  (strand-fail:strand %bad-sign ~)
?~  full-file.client-response.q.res
  (strand-fail:strand %no-body ~)
=.  resp  `@t`q.data.u.full-file.client-response.q.res
::~&  >>  resp
:: ************* End Request 2 *************
::
:: ************* Request 3: Create username (POST) *************
=.  url  'https://api.meethue.com/route/api'
=.  body  (encode-request-body ~[['devicetype' s+'urbhue']])
=.  request  [%'POST' url headers body]
=.  task  [%request request *outbound-config:iris]
=.  card  [%pass /http-req %arvo %i task]
;<  ~  bind:m  (send-raw-card:strandio card)
;<  res=(pair wire sign-arvo)  bind:m  take-sign-arvo:strandio
?.  ?=([%iris %http-response %finished *] q.res)
  (strand-fail:strand %bad-sign ~)
?~  full-file.client-response.q.res
  (strand-fail:strand %no-body ~)
=.  resp  `@t`q.data.u.full-file.client-response.q.res
:: ************* End Request 3 *************
=/  usr  (snag 0 `(list @t)`(username-from-json (need (de-json:html resp))))
::~&  >>  [username=usr tokens]
(pure:m !>([username=usr code=code tokens]))