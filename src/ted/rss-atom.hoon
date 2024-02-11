::
::  parse an rss channel / atom feed and
::  create threads to parse new items / entries
::
/-  spider
/+  *strandio, *rss-sub
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
::  XX ugly types, should be $time and $link
=/  date-and-link  !<([@da @t] arg)
;<    =time
    bind:m
  get-time
::
::  check if updated time is valid
?.  (lte -.date-and-link time)
  ::  XX all error messaging should be better
  ::       should include source desk, other dynamic info
  (strand-fail %bad-updated-time ~)
::
::  make iris card for http request
::  XX ugly lark notation on feed
=/  =request:http     [%'GET' +.date-and-link ~ ~]
=/  =task:iris        [%request request *outbound-config:iris]
=/  =card:agent:gall  [%pass /http-req %arvo %i task]
::
::  send card and validate response
;<    ~
    bind:m
  (send-raw-card card)
;<    response=(pair wire sign-arvo)
    bind:m
  take-sign-arvo
?.  ?=([%iris %http-response %finished *] q.response)
  (strand-fail %failed-http-request ~)
?~  full-file.client-response.q.response
  (strand-fail %empty-response ~)
=/  xml
  (de-xml:html `@t`q.data.u.full-file.client-response.q.response)
?~  xml
  ::
  ::  XX failures to parse here could be fixed by ~migrev-dolseg's patch
  ::       test those problem feeds in %feeds and check for %parse-failed error
  (strand-fail %invalid-xml ~)
::
::  XX is this test robust enough?
::     skimming for any %channel tags might be better
::
::  branch on whether feed is rss or atom
::
::  right now this is just declaring whether feed is
::  rss or atom, but eventually should 1) parse feed info
::  and send back to the agent and 2) send each item or
::  entry in the rss/atom feed to the relevant thread:
::  either -item or -entry
?:  =(%channel n.g:(head c:(need xml)))
  ::  rss
  (pure:m !>(%rss))
::  atom
(pure:m !>(%atom))
