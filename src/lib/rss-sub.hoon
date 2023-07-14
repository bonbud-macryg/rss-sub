/-  *atom, *rss
|%
+|  %state
+$  rss-refresh  @dr
+$  rss-state    (map url rss-channel)
::
+$  rss-sub-action
  $%  [%add-rss-feed =url]
      [%del-rss-feed =url]
      [%rss-refresh url=(unit @t)]
      [%set-rss-refresh refresh=@dr]
  ==
::
+|  %actions
++  add-feed
  |=  [=url =rss-state]
  ^+  rss-state
  (~(put by rss-state) url *rss-channel)
::
++  del-feed  !!
++  set-refresh  !!
++  refresh  !!
::+|  %parsers
--