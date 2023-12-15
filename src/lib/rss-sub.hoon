/-  *rss-atom
/+  manx-utils
|%
::
+|  %types
::
+$  updated  @da         ::  last update
+$  refresh  @dr         ::  refresh timer
+$  maximum  (unit @ud)  ::  max. items per feed
::
::  XX +each + %channel and %feed head-tags will be ugly
::       strong preference to remove +each rather than the tags
::       but not sure what causes the problem +each solves and
::       how to navigate without +each
::
+$  feed        (each rss-channel atom-feed)    ::  RSS/Atom
+$  feed-state  (map link (pair updated feed))  ::  URLs and feeds
::
+$  rss-sub-action
  $%  [%add-feed =link]
      [%del-feed =link]
      [%add-item =rss-item]
      [%add-entry =atom-entry]
      ::
      [%set-refresh =refresh]
      [%refresh-now links=(list link)]
  ==
::
+|  %actions
::
++  add-feed
  |=  [=link =feed-state]
  ^+  feed-state
  ::  XX accomodate atom
  ::       request to feed at url
  ::       check if rss or atom
  ::       branch on result
  !!
++  add-item     !!
++  add-entry    !!
++  set-refresh  !!
::
::  ++  make-refresh-cards
::    |=  [=feed-state links=(list link)]
::    ^-  (list card)
::    ?.  =(~ links)
::      %+  turn
::        (skim links ~(has by feed-state))
::      |=  =link
::      (make-refresh-card link feed-state)
::    %-  %~  val  by
::    %-  %~  rut  by
::      feed-state
::    |=  =link
::    (make-refresh-card link feed-state)
::
++  make-refresh-card
  |=  [=link =feed-state =desk =case]
  ^-  card
  !!
  ::  XX  likely miscounted children here
  ::  %-  %~  val  by
  ::  %-  %~  run  by
  ::    feed-state
  ::  |=  [k=link v=[=updated =feed]]
  ::  ^-  card
  ::  :*  %pass
  ::      /feed-update
  ::      %arvo
  ::      %k
  ::      %fard
  ::      [desk case]
  ::      ?:  =(%.y -.feed.v)
  ::        %channel
  ::      %feed
  ::      %noun
  ::      !>([updated.v k])
  ::  ==
::
::  XX convert rss time to @da
::
::  XX convert atom time to @da
::
--
