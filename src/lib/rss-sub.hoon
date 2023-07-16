/-  *rss-atom
|%
::
+|  %state
::
+$  rss-refresh  @dr
+$  rss-state    (map url rss-feed)
+$  rss-feed     (each rss-channel atom-feed)
::
+$  rss-sub-action
  $%  [%add-rss-feed =url]
      [%del-rss-feed =url]
      [%set-rss-refresh refresh=@dr]
      [%rss-refresh-now urls=(list url)]
  ==
::
+|  %actions
::
++  add-rss-feed
  |=  [=url =rss-state]
  ^+  rss-state
  ::  XX accomodate atom
  ::       request to feed at url
  ::       check if rss or atom
  ::       branch on result
  !!
::
++  rss-refresh-now
  |=  urls=(list url)
  ^-  rss-state
  ?.  =(~ urls)
    ::  XX run thread on these urls
    !!
  ::  XX run thread on all urls
  !!
::
::+|  %validate
::
::  XX validate rss-channel
::  XX validate rss-item
::  XX validate atom-feed
::  XX valdiate atom-entry
::
::+|  %parsing-helpers
::
::  XX can write/test parsers for indiv. elements independent of thread
::
::  as a rule: parsers should be independent components that
::  devs can use to do whatever they want
::
::  XX rss-channel barket
::    XX  rss-item barket
::      XX rss-item element parsers
::
::  XX atom-feed barket
::    XX atom-entry barket
::      XX atom-entry element parsers
::
--