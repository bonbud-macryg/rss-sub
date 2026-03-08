/-  ra=rss-atom
/+  manx-utils
|%
::
+|  %types
::
+$  updated  @da         ::  last update
::  XX refresh should be a unit; maybe we're only doing manual refreshes
+$  refresh  @dr         ::  refresh timer
::
::  XX +each + %channel and %feed head-tags will be ugly
::       strong preference to remove +each rather than the tags
::       but not sure what causes the problem +each solves and
::       how to navigate without +each
::
+$  feed        (each channel:rss:ra feed:atom:ra)    ::  RSS/Atom
::  XX could be feed-items; devs might add other 'feed state' on top of this
+$  feed-state  (map link:ra (pair updated (unit feed)))  ::  URLs and feeds
::
+$  rss-sub-action
  $%  [%add-feed =link:ra]
      [%del-feed =link:ra]
      [%set-refresh =refresh]
      [%refresh-now link=(unit link:ra)]
  ==
::
+|  %actions
::
++  set-refresh  !!
::
++  make-refresh-cards
  |=  [link=(unit link:ra) =desk =feed-state]
  ^-  (list card:agent:gall)
  ?~  link
    ::  refresh all links
    %+  turn
      ~(tap in ~(key by feed-state))
    |=  =link:ra
    %:  make-refresh-card
        link
        -:(~(got by feed-state) link)
        desk
    ==
  ::  refresh given link
  ?.  (~(has by feed-state) u.link)
    ~
  :~  %:  make-refresh-card
          u.link
          -:(~(got by feed-state) u.link)
          desk
      ==
  ==
::
++  make-refresh-card
  ::  XX foobarbat should all be link
  |=  [bat=@t =updated =desk]
  ^-  card:agent:gall
  :*  %pass
      ::  XX should devs be able to optionally specify
      ::     a return path?
      /rss-sub/update/feed/(scot %t bat)
      %arvo
      %k
      %fard
      desk
      %rss-atom
      %noun
      !>([updated bat])
  ==
::
::  XX convert rss time to @da
::
::  XX convert atom time to @da
::
--
