/-  *rss-atom
|%
::
+|  %state
::
+$  last-update  @da
+$  rss-refresh  @dr
+$  rss-feed     (each rss-channel atom-feed)
+$  rss-state    (map link (pair last-update rss-feed))
::
+$  rss-sub-action
  $%  [%add-rss-feed =link]
      [%del-rss-feed =link]
      [%set-rss-refresh =rss-refresh]
      [%rss-refresh-now links=(list link)]
  ==
::
+|  %actions
::
++  add-rss-feed
  |=  [=link =rss-state]
  ^+  rss-state
  ::  XX accomodate atom
  ::       request to feed at url
  ::       check if rss or atom
  ::       branch on result
  !!
::
++  rss-refresh-now
  |=  links=(list link)
  ^-  rss-state
  ?.  =(~ links)
    ::  XX run thread on these urls
    !!
  ::  XX run thread on all urls
  !!
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
  ::  check elements in rss-channel
  |=  [terms=(list @tas) =rss-channel]
  ^-  ?
  %+  levy
    terms
  |=  =term
  ^-  ?
  %+  lien
    elems.rss-channel
  |=  elem=[@tas *]
  ^-  ?
  =(term -.elem)
::
++  check-item
  ::  check elements in rss-item
  |=  [terms=(list @tas) =rss-item]
  ^-  ?
  %+  levy
    terms
  |=  =term
  ^-  ?
  %+  lien
    +.rss-item
  |=  elem=[@tas *]
  ^-  ?
  =(term -.elem)
::
++  check-feed
  ::  check elements in atom-feed
  |=  [terms=(list @tas) =atom-feed]
  ^-  ?
  %+  levy
    terms
  |=  =term
  ^-  ?
  %+  lien
    elems.atom-feed
  |=  elem=[@tas *]
  ^-  ?
  =(term -.elem)
::
++  check-entry
  ::  check elements in atom-entry
  |=  [terms=(list @tas) =atom-entry]
  ^-  ?
  %+  levy
    terms
  |=  =term
  %+  lien
    +.atom-entry
  |=  elem=[@tas *]
  ^-  ?
  =(-.elem term)
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