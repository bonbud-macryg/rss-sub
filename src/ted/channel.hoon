::
::  parse an rss channel and create threads to parse new items
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
::  need last update time for a channel passed in as input
::  send-request to url
::  take-maybe-response from url
::    produces (unit client-response:iris)
::    if null, end thread with error msg
::  extract-body from the response
::  check if first entry in channel was updated after get-time
::    should be passed in as input to the thread
::  if no, skip it
::  if yes,
::    split XML into <item>s
::      update the last-fetched @da on the channel
::      for each item,
::        start-thread-with-args a child entry.hoon thread to parse the item
!!
