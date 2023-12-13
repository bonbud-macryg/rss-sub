::
::  parse an atom feed and create threads to parse new entries
::
/-  spider, *rss-atom
/+  *strandio
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
::
::  NOTE not using text parser anymore, some logic still applies
::
::
::  need last update time for a feed passed in as input
::  send-request to url
::  take-maybe-response from url
::    produces (unit client-response:iris)
::    if null, end thread with error msg
::  extract-body from the response
::  check if first entry in feed was updated after get-time
::    should be passed in as input to the thread
::  if no, skip it
::  if yes,
::    split XML into <entry>s
::      update the last-fetched @da on the feed
::      for each entry,
::        start-thread-with-args a child entry.hoon thread to parse the entry
!!
::|=  strand-input:spider
::
::  above is all boilerplate
::
::  ;<  t1=@da  bind:m  get-time
::  ;<  t2=@da  bind:m  get-time
::  ;<  output  bind:m  any-gate
::  (pure:m !>([t1 t2]))
::  (pure:m !>(final-output))
::
::?+    q.arg  [~ %fail %not-foo ~]
::    %foo
::  [~ %done arg]
::==
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
