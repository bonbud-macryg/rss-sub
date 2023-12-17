::
::  parse an rss channel and create threads to parse new items
::
/-  spider, *rss-atom
/+  *strandio, *rss-sub
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
=+  !<([=link =updated] arg)
(pure:m !>([link updated]))
::  ;<    =bowl:rand
::      bind:m
::    get-bowl
::  ::  XX should just get now out of bowl,
::  ::     but idk how to pull data out of bowl rn
::  ;<    =time
::      bind:m
::    get-time
::  ?:  (lte updated time)
::    ::  %-  (slog [[%leaf "{q.byk.bowl>}: bad updated time {<updated>} for RSS channel {<link>}"] ~])
::    !!
::  =/  =request:http     [%'GET' link ~ ~]
::  =/  =task:iris        [%request request *outbound-config:iris]
::  =/  =card:agent:gall  [%pass /http-req %arvo %i task]
::  ;<    ~
::      bind:m
::    (send-raw-card card)
::  ;<    response=(pair wire sign-arvo)
::      bind:m
::    take-sign-arvo
::  ?.  ?=([%iris %http-response %finished *] q.response)
::    ::  %-  (slog [[%leaf "{<q.byk.bowl>}: failed HTTP request to {<link>}"] ~])
::    (strand-fail %bad-sign ~)
::  ?~  full-file.client-response.q.response
::    ::  %-  (slog [[%leaf "{<q.byk.bowl>}: empty response from {<link>}"] ~])
::    (strand-fail %bad-sign ~)
::  =/  xml
::    %-  need
::    (de-xml:html `@t`q.data.u.full-file.client-response.q.response)
::  ?~  xml
::    ::  %-  (slog [[%leaf "{<q.byk.bowl>}: invalid XML from {<link>}"] ~])
::    (strand-fail %bad-sign ~)
::  ::  %-  (slog [[%leaf "thread terminated"]])
::  ::  (pure:m !>('thread terminated'))
::  (strand-fail %bad-sign ~)
::
:: :: ::
::
::  NOTE not using text parser anymore, some logic still applies
::
::  check if first entry in channel was updated after get-time
::    should be passed in as input to the thread
::  if no, skip it
::  if yes,
::    split XML into <item>s
::      update the last-fetched @da on the channel
::      for each item,
::        start-thread-with-args a child entry.hoon thread to parse the item
::
::  ::  ::
::
::  =+  !<([~ arg=@t] arg)
::  =/  base-url  "https://pokeapi.co/api/v2/pokemon/"
::  =/  url  (weld base-url (cass (trip arg)))
::  ;<  info=json  bind:m  (fetch-json url)
::  (pure:m !>(info))
::
::  ++  fetch-json
::    |=  url=tape
::    =/  m  (strand ,json)
::    ^-  form:m
::    ;<  =cord  bind:m  (fetch-cord url)
::    =/  json=(unit json)  (de:json:html cord)
::    ?~  json
::      (strand-fail %json-parse-error ~)
::    (pure:m u.json)
::
::  ++  fetch-cord
::    |=  url=tape
::    =/  m  (strand ,cord)
::    ^-  form:m
::    =/  =request:http  [%'GET' (crip url) ~ ~]
::    ;<  ~                      bind:m  (send-request request)
::    ;<  =client-response:iris  bind:m  take-client-response
::    (extract-body client-response)
::
::  ++  send-request
::    |=  =request:http
::    =/  m  (strand ,~)
::    ^-  form:m
::    (send-raw-card %pass /request %arvo %i %request request *outbound-config:iris)
::
::  ++  take-client-response
::    =/  m  (strand ,client-response:iris)
::    ^-  form:m
::    |=  tin=strand-input:strand
::    ?+  in.tin  `[%skip ~]
::        ~  `[%wait ~]
::      ::
::        [~ %sign [%request ~] %iris %http-response %cancel *]
::      ::NOTE  iris does not (yet?) retry after cancel, so it means failure
::      :-  ~
::      :+  %fail
::        %http-request-cancelled
::      ['http request was cancelled by the runtime']~
::      ::
::        [~ %sign [%request ~] %iris %http-response %finished *]
::      `[%done client-response.sign-arvo.u.in.tin]
::    ==
::
::  ++  extract-body
::    |=  =client-response:iris
::    =/  m  (strand ,cord)
::    ^-  form:m
::    ?>  ?=(%finished -.client-response)
::    %-  pure:m
::    ?~  full-file.client-response  ''
::    q.data.u.full-file.client-response
