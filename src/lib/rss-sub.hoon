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
::  XX could be feed-items; devs might add other 'feed state' on top of this
+$  feed-state  (map link (pair updated (unit feed)))  ::  URLs and feeds
::
+$  rss-sub-action
  $%  [%add-feed =link]
      [%del-feed =link]
      [%set-refresh =refresh]
      [%refresh-now links=(list link)]
  ==
::
+|  %actions
::
++  set-refresh  !!
::
++  make-refresh-cards
  |=  [links=(list link) =desk =feed-state]
  ^-  (list card:agent:gall)
  ?~  links
    ::  refresh all links
    %+  turn
      ~(tap in ~(key by feed-state))
    |=  =link
    %:  make-refresh-card
        link
        -:(~(got by feed-state) link)
        desk
    ==
  ::  refresh given links
  %+  turn
    %+  skim
      `(list link)`links
    |=  =link
    (~(has by feed-state) link)
  |=  =link
  %:  make-refresh-card
      link
      -:(~(got by feed-state) link)
      desk
  ==
::
++  make-refresh-card
  |=  [=link =updated =desk]
  ^-  card:agent:gall
  :*  %pass
      ~
      %arvo
      %k
      %fard
      desk
      %feed
      %noun
      !>([link updated])
  ==
::
::  XX convert rss time to @da
::
::  XX convert atom time to @da
::
--
