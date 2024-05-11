::
::  parse an rss channel / atom feed and
::  create threads to parse new items / entries
::
/-  spider, rss-atom
/+  *strandio, *rss-sub
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
=/  time-and-link  !<([=time link=@t] arg)
;<    now=time
    bind:m
  get-time
::
::  check if updated time is valid
?.  (lte time.time-and-link now)
  ::  XX all error messaging should be better
  ::       should include source desk, other dynamic info
  (strand-fail %bad-updated-time ~)
::
::  make iris card for http request
::  XX ugly lark notation on feed
=/  =request:http     [%'GET' link.time-and-link ~ ~]
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
=,  response-header.client-response.q.response
?~  full-file.client-response.q.response
  ?.  ?|  =(301 status-code)
          =(307 status-code)
      ==
    (strand-fail %empty-response ~)
  %=  $
    arg  !>  ^-  (pair time @t)
         :-  time.time-and-link
         %-  %~  got  by
           (malt headers)
         'location'
  ==
?:  (gte status-code 500)
  (strand-fail %internal-server-error ~)
?:  (gte status-code 400)
  (strand-fail %bad-request ~)
::
=/  xml
  (de-xml:html `@t`q.data.u.full-file.client-response.q.response)
?~  xml
  ::
  ::  XX failures to parse here could be fixed by ~migrev-dolseg's patch
  ::       test those problem feeds in %feeds and check for %parse-failed error
  (strand-fail %failed-to-parse-xml ~)
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
=/  document
  c:(need xml)
?:  =(%channel n.g:(head c:(need xml)))
  ::  rss channel
  =/  channel-tags
    %+  turn
      %+  skip
        c.i.-.document
      |=  =manx
      ^-  ?
      ?|  =(n.g.manx %item)
          =(n.g.manx %items)
      ==
    |=  =manx
    ::  ^-  rss-channel-element
    ^-  [@tas *]
    =*  tag  n.g.manx
    =*  val  (crip v:(head a.g:(head c.manx)))
    ~&  >>  tag
    ~&  >>  val
    [%foo 'bar']
    ::  [tag val]
    ::  =*  tag  n.g.manx
    ::  =*  val  v.a.g.c.manx
    ::  ?-  tag
    ::  ::
    ::      %title
    ::    [tag (text:rss-atom val)]
    ::  ::
    ::      %link
    ::    [tag (link:rss-atom val)]
    ::  ::
    ::      %description
    ::    [tag (text:rss-atom val)]
    ::  ::
    ::      %language
    ::    [tag (lang:rss-atom val)]
    ::  ::
    ::      %pub-date
    ::    ::  XX convert from RSS time standard to @da
    ::    [tag val]
    ::  ::
    ::      %last-build-date
    ::    ::  XX convert
    ::    [tag val]
    ::  ::
    ::      %docs
    ::    [tag (link:rss-atom val)]
    ::  ::
    ::      %generator
    ::    [tag (text:rss-atom val)]
    ::  ::
    ::      %managing-editor
    ::    ::  XX might need to be text
    ::    [tag (mail:rss-atom val)]
    ::  ::
    ::      %web-master
    ::    ::  XX might need to be text
    ::    [tag (mail:rss-atom val)]
    ::  ::
    ::      %copyright
    ::    [tag (text:rss-atom val)]
    ::  ::
    ::      %category
    ::    !!
    ::  ::
    ::      %ttl
    ::    [tag (numb:rss-atom val)]
    ::  ::
    ::      %rating
    ::    [tag (text:rss-atom val)]
    ::  ::
    ::      %text-input
    ::    !!
    ::  ::
    ::      %cloud
    ::    !!
    ::  ::
    ::      %image
    ::    !!
    ::  ::
    ::      %skip-days
    ::    ::  XX parse into (list @t) then typecheck
    ::    !!
    ::  ::
    ::      %skip-hours
    ::    ::  XX parse into (list @t) then typecheck
    ::    !!
    ::
    ::  ==
  ::
  ::  items will be typechecked in /ted/item.hoon
  =/  item-tags
    %+  skim
      c.i.-.document
    |=  =manx
    ^-  ?
    ::  =(n.g.manx %item)
    =(n.g.manx %foo)
  ::
  %-  pure:m
  !>  ^-  [%rss * marl]
  ~&  >>  "channel tags: {<channel-tags>}"
  :*  %rss
      channel-tags
      item-tags
  ==
::  atom feed
=/  feed-tags
  %+  skim
    c.i.-.document
  |=  =manx
  ^-  ?
  ::  XX is head tag one of atom-feed-element...
  ::  XX ...and is value a valid atom-feed-element value?
  %.y
::
::  entries will be typechecked in /ted/entry.hoon
=/  entry-tags
  %+  skim
    c.i.-.document
  |=  =manx
  ^-  ?
  =(n.g.manx %entry)
::
%-  pure:m
::  XX narrow down type
!>  ^-  [%atom marl marl]
:*  %atom
    feed-tags
    entry-tags
==
