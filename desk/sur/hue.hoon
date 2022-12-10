|%
+$  on  ?
+$  bri  @ud
+$  code            @t
+$  url             @t
+$  username        @t
+$  access-token    @t
+$  refresh-token   @t
+$  group           @t
::
+$  logs  (list json)
+$  groups  (list json)
::
+$  action
  $%  [%toggle =on]
      [%bri =bri]
      [%code =code]
      [%group =group]
  ==
+$  update
  $:  =on
      =bri
      =code
      =group
  ==
--