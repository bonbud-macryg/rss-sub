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
::+|  %parsers
--