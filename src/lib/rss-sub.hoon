/-  *rss-atom
|%
::
+|  %state
::
+$  last-update  @da
+$  rss-refresh  @dr
+$  rss-feed     (each rss-channel atom-feed)
+$  rss-state    (map url (pair last-update rss-feed))
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
::  should specify the terms we're looking for?
::    would make these more general
::    if so, just need one arm cause only the terms change;
::    they're all sets of head-tagged cells
::
::  XX validate set of elements
::  |=  [elems=(list @tas) set=(set ?(rss-channel rss-item atom-feed atom-entry))]
::  ^-  ?
::  iterate over every elem in elems
::  check if it's in set
::
::+|  %helpers
::
::++  validate-rss-channel
::  |=  [terms=(list @tas) channel=rss-channel]
::  ^-  ?
::  %+  levy
::    terms
::  |=  =term
::  ^-  ?
::  ::  XX i think elems hates being a set
::  ::       could be a list or map
::  ~!  elems.channel
::  (~(has in elems.channel) [term *])
::
::++  validate-feed
::  ::  check elements in rss-channel or atom-feed
::  |=  [terms=(list @tas) feed=rss-feed]
::  ^-  ?
::  %+  levy
::    terms
::  |=  =term
::  ^-  ?
::  (~(has in `(set rss)(head feed)) [term *])
::
::++  validate-item
::  ::  check elements in rss-item
::  |=  [terms=(list @tas) item=rss-item]
::  ^-  ?
::  %+  levy
::    terms
::  |=  =term
::  ^-  ?
::  (~(has in (tail item)) [term *])
::
::++  validate-entry
::  ::  check elements in atom-entry
::  |=  [terms=(list @tas) entry=atom-entry]
::  ^-  ?
::  %+  levy
::    terms
::  |=  =term
::  ^-  ?
::  (~(has in (tail entry)) [term *])
::
::
::+|  %parsing-helpers
::
::  XX can write/test parsers for indiv. elements independent of thread
::
::  as a rule: parsers should be independent components that
::  devs can use to do whatever they want
::
::  XX rss-channel barket
::    XX rss-item barket
::      XX rss-item element parsers
::
::  XX atom-feed barket
::    XX atom-entry barket
::      XX atom-entry element parsers
::
--