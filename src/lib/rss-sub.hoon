/-  *rss-atom
/+  manx-utils
|%
::
+|  %state
::
+$  last-update  @da
+$  rss-refresh  @dr
::
::  XX +each + %channel and %feed head-tags will be ugly
::       strong preference to remove +each rather than the tags
::       but not sure what causes the problem +each solves and
::       how to navigate without +each
::
+$  rss-feed   (each rss-channel atom-feed)
+$  rss-state  (map link (pair last-update rss-feed))
::
::  XX add constants for:
::       how many items in an rss-feed before we start trimming it
::         should be a unit: no value = no limit
::
+$  rss-sub-action
  ::  XX remove 'rss'
  $%  [%add-rss-feed =link]
      [%del-rss-feed =link]
      [%set-rss-refresh =rss-refresh]
      [%rss-refresh-now links=(list link)]
      ::  XX add poke(s) to add items
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
::  XX convert rss time to @da
::
::  XX convert atom time to @da
::
::  +|  %parse-channel
::  +|  %parse-item
::  +|  %parse-feed
::  +|  %parse-entry
--
