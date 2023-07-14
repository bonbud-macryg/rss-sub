/-  *rss-atom
|%
::
+|  %state
::
+$  rss-refresh  @dr
::  XX need to accomodate atom-feeds too
+$  rss-state    (map url rss-channel)
::+$  rss-feed     ?(rss-channel atom-feed)
::
+$  rss-sub-action
  $%  [%add-rss-feed =url]
      [%del-rss-feed =url]
      [%rss-refresh-now url=(unit @t)]
      [%set-rss-refresh refresh=@dr]
  ==
::
+|  %actions
::
++  add-rss-feed
  |=  [=url =rss-state]
  ^+  rss-state
  ::  XX bunt of rss-channel a hack
  ::       need to accomodate atom-feeds too
  (~(put by rss-state) url *rss-channel)
::
++  del-rss-feed
  |=  [=url =rss-state]
  ^+  rss-state
  (~(del by rss-state) url)
::
++  rss-refresh-now
  |=  url=(unit url)
  ::  XX narrow down type
  ^-  *
  ?.  =(~ url)
    ::  XX run thread on one url
    !!
  ::  XX run thread on all urls
  !!
::
::+|  %parsers
--