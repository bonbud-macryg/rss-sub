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
+|  %validators
::
++  validate-rss-channel
  ::  XX handle edge-cases around required elements
  |=  [terms=(list @tas) =rss-channel]
  ^-  ?
  %.y
::
++  validate-rss-item
  ::  XX handle edge-cases around required elements
  |=  [terms=(list @tas) =rss-item]
  ^-  ?
  %.y
::
++  validate-atom-feed
  ::  XX handle edge-cases around required elements
  |=  [terms=(list @tas) =atom-feed]
  ^-  ?
  %.y
::
++  validate-atom-entry
  ::  XX handle edge-cases around required elements
  |=  [terms=(list @tas) =atom-entry]
  ^-  ?
  %.y
::
++  check-channel
  |=  [terms=(list @tas) =rss-channel]
  ^-  ?
  %.y
  ::  check elements in rss-channel
  ::|=  [terms=(list @tas) channel=rss-channel]
  ::^-  ?
  ::%+  levy
  ::  terms
  ::|=  =term
  ::^-  ?
  ::%+  lien
  ::  `(list rss-channel-element)`elems.channel
  ::|=  elem=[@tas *]
  ::^-  ?
  ::=(term -.elem)
::
++  check-item
  |=  [terms=(list @tas) =rss-item]
  ^-  ?
  %.y
  ::  check elements in rss-item
  ::|=  [terms=(list @tas) item=rss-item]
  ::^-  ?
  ::%+  levy
  ::  terms
  ::|=  =term
  ::^-  ?
  ::%+  lien
  ::  +.item
  ::|=  elem=[@tas *]
  ::^-  ?
  ::=(term -.elem)
::
++  check-feed
  ::  check elements in atom-feed
  |=  [terms=(list @tas) =atom-feed]
  ^-  ?
  %.y
  ::  check elements in atom-feed
  ::|=  [terms=(list @tas) feed=atom-feed]
  ::^-  ?
  ::%+  levy
  ::  terms
  ::|=  =term
  ::^-  ?
  ::%+  lien
  ::  elems.feed
  ::|=  elem=[@tas *]
  ::^-  ?
  ::=(term -.elem)
::
++  check-entry
  ::  check elements in atom-entry
  |=  [terms=(list @tas) =atom-entry]
  ^-  ?
  %.y
  ::
  ::  these work in dojo
  ::  inclined to say this arm works
  ::  (levy `(list @tas)`~[%one %two %three] |=(term=@tas (lien `(list [@tas @ud])`~[[%one 1] [%two 2] [%three 3]] |=(a=[@tas @ud] =(-.a term)))))
  ::  (levy `(list @tas)`~[%title %link %id] |=(term=@tas (lien `(list [@tas *])`(tail test-atom-entry) |=(elem=[@tas *] =(-.elem term)))))
  ::  (levy `(list @tas)`~[%title %link %id] |=(=term (lien `(list [@tas *])`(tail test-atom-entry) |=(elem=[@tas *] =(-.elem term)))))
  ::
  ::  check elements in atom-entry
  ::|=  [terms=(list @tas) entry=atom-entry]
  ::^-  ?
  ::%+  levy
  ::  `(list @tas)`terms
  ::|=  =term
  ::%+  lien
  ::  `(list [@tas *])`(tail entry)
  ::|=  elem=[@tas *]
  ::^-  ?
  ::=(-.elem term)
::
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