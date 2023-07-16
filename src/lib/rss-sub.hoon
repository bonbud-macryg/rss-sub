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
      [%rss-refresh-now url=(unit url)]
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