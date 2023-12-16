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
++  make-refresh-cards
  ::  XX annoying, come back to this
  !!
  ::  |=  [links=(list link) =desk =feed-state]
  ::  ^-  (list card)
  ::  %+  turn
  ::    links
  ::  |=  =link
  ::  (make-refresh-card [link (~(got by feed-state) link)] desk)
  ::  |=  [links=(list link) deskcase=(pair desk case) =feed-state]
  ::  ^-  (list card)
  ::  [*card]~
  ::  ?.  =(~ links)
  ::    ::  XX should use urn:by
  ::    ::  given feeds
  ::    %+  turn
  ::      (skim links ~(has by feed-state))
  ::    |=  =link
  ::    %:  make-refresh-card
  ::        [link (~(got by feed-state) link)]
  ::        case
  ::        desk
  ::    ==
  ::  ::  XX should use urn:by
  ::  ::  all feeds
  ::  %+  turn
  ::    ~(tap in ~(key by feed-state))
  ::  |=  =link
  ::  %:  make-refresh-card
  ::      [link (~(got by feed-state) link)]
  ::      case
  ::      desk
  ::  ==
::
++  make-refresh-card
  |=  [[=link [=updated =feed]] =desk]
  ^-  card:agent:gall
  [%pass /result %arvo %k %fard desk %my-thread %noun !>(%.y)]
  ::  |=  [[=link [=updated =feed]] =case =desk]
  ::  *card
  ::  ^-  card
  ::  :*  %pass
  ::      ~
  ::      %arvo
  ::      %k
  ::      %fard
  ::      [desk case]
  ::      ?:  =(%.y -.feed)
  ::        %channel
  ::      %feed
  ::      %noun
  ::      !>([updated link])
  ::  ==
::
::  XX convert rss time to @da
::
::  XX convert atom time to @da
::
--
