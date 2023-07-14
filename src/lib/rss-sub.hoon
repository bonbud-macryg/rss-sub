/-  *atom, *rss, *rss-sub
|%
::+|  %state
::$:  feeds=(set url)
::      state=(map url rss-channel)
::      refresh=@dr
::  ==
::+|  %agent
::+|  %actions
  ::  add-feed
  ::  del-feed
  ::  set-refresh
  ::  refresh
::+|  %parsers
--