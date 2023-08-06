/-  *rss-atom
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
+$  rss-feed     (each rss-channel atom-feed)
+$  rss-state    (map link (pair last-update rss-feed))
::
+$  rss-sub-action
  $%  [%add-rss-feed =link]
      [%del-rss-feed =link]
      [%set-rss-refresh =rss-refresh]
      [%rss-refresh-now links=(list link)]
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
+|  %validators
::
++  validate-rss-channel
  ::  XX handle edge-cases around required elements
  |=  [terms=(list @tas) =rss-channel]
  ^-  ?
  %.y
::
++  validate-rss-item
  ::  XX handle edge-cases around required elements
  |=  [terms=(list @tas) =rss-item]
  ^-  ?
  %.y
::
++  validate-atom-feed
  ::  XX handle edge-cases around required elements
  |=  [terms=(list @tas) =atom-feed]
  ^-  ?
  %.y
::
++  validate-atom-entry
  ::  XX handle edge-cases around required elements
  |=  [terms=(list @tas) =atom-entry]
  ^-  ?
  %.y
::
++  check-channel
  ::  check elements in rss-channel
  |=  [terms=(list @tas) =rss-channel]
  ^-  ?
  %+  levy
    terms
  |=  =term
  ^-  ?
  %+  lien
    elems.rss-channel
  |=  elem=[@tas *]
  ^-  ?
  =(term -.elem)
::
++  check-item
  ::  check elements in rss-item
  |=  [terms=(list @tas) =rss-item]
  ^-  ?
  %+  levy
    terms
  |=  =term
  ^-  ?
  %+  lien
    +.rss-item
  |=  elem=[@tas *]
  ^-  ?
  =(term -.elem)
::
++  check-feed
  ::  check elements in atom-feed
  |=  [terms=(list @tas) =atom-feed]
  ^-  ?
  %+  levy
    terms
  |=  =term
  ^-  ?
  %+  lien
    elems.atom-feed
  |=  elem=[@tas *]
  ^-  ?
  =(term -.elem)
::
++  check-entry
  ::  check elements in atom-entry
  |=  [terms=(list @tas) =atom-entry]
  ^-  ?
  %+  levy
    terms
  |=  =term
  %+  lien
    +.atom-entry
  |=  elem=[@tas *]
  ^-  ?
  =(-.elem term)
::
::
::+|  %parser-helpers
::::
::::  XX change the name of this?
::++  cha
::  ::|=  =cord 
::  ::  XX  kethep, output of line below
::  ::%+  rash
::  ::  cord
::  ;~  pose
::      ::  XX why printable?
::      prn
::      %-  mask
::      :~  ' '
::          ::  XX why casting as atoms?
::          `@`0x9
::          `@`0xa
::          `@`0xd
::          `@`'\\'
::          `@`'"'
::      ==
::  ==
::::
::++  match-until
::  |=  =cord
::  ::  XX kethep, output of line below
::  %-  star
::  ;~(less (jest cord) cha)
::::
::++  in-tag
::  |=  tag=tape
::  ::  XX kethep, output of line below
::  :-  %-  jest
::      %-  crip
::      (weld ['<' tag] ">")
::  %-  jest
::  %-  crip
::  (weld ['<' '/' tag] ">")
::
::  XX convert rss time to @da
::
::  XX convert atom time to @da
::
::+|  %parsers
::::
::::  parse xml tapes to rss types
::++  rss
::  |%
::  ++  headers
::    ::  XX +parse-headers?
::    ::       might need to add $headers to $rss-channel
::    ::
::    ::  |=  xml-file=cord
::    ::  ^-  <rss header types>
::    ::  ;~(sfix (match-until '<channel>') channel)
::    ::  then parse into hoon spec of rss headers (todo)
::    ::
::    !!
::  ::
::  ++  channel
::    |=  xml-file=cord
::    ^-  rss-channel
::    ::  XX inefficient; parsing items twice
::    %+  rash
::      xml-file
::    ;~  plug
::      ::  elems
::      %+  ifix
::        (in-tag "channel")
::      ;~  sfix
::        ::<title>NASA Space Station News</title>
::        ::<link>http://www.nasa.gov/</link>
::        ::<description>A RSS news feed containing the latest NASA press releases on the International Space Station.</description>
::        ::<language>en-us</language>
::        ::<pubDate>Tue, 10 Jun 2003 04:00:00 GMT</pubDate>
::        ::<lastBuildDate>Fri, 21 Jul 2023 09:04 EDT</lastBuildDate>
::        ::<docs>https://www.rssboard.org/rss-specification</docs>
::        ::<generator>Blosxom 2.1.2</generator>
::        ::<managingEditor>neil.armstrong@example.com (Neil Armstrong)</managingEditor>
::        ::<webMaster>sally.ride@example.com (Sally Ride)</webMaster>
::        ::<atom:link href="https://www.rssboard.org/files/sample-rss-2.xml" rel="self" type="application/rss+xml"/>
::        ;~  sfix
::          ::
::          ::  XX definitely wrong
::          ::       need to handle cases where an element isn't there
::          ::
::          ::  XX could be its own arm +channel-elements
::          ::
::          ;~  plug
::            ;~(pfix (match-until '<title>') title)
::            ;~(pfix (match-until '<link>') link)
::            ;~(pfix (match-until '<description>') description)
::            ;~(pfix (match-until '<language>') language)
::            ;~(pfix (match-until '<pubDate>') pub-date)
::            ;~(pfix (match-until '<lastBuildDate>') last-build-date)
::            ;~(pfix (match-until '<docs>') docs)
::            ;~(pfix (match-until '<generator>') generator)
::            ;~(pfix (match-until '<managingEditor>') managing-editor)
::            ;~(pfix (match-until '<webMaster>') web-master)
::            ::<atom:link href="https://www.rssboard.org/files/sample-rss-2.xml" rel="self" type="application/rss+xml"/>
::            ~
::          ==
::          (match-until '<item>')
::        ==
::        items
::      ==
::      ::  entries
::      %+  ifix
::        (in-tag "channel")
::      ;~  pfix
::        !!
::        items
::      ==
::    ==
::    :::-  ::  elems
::    ::    %-  scan
::    ::      xml-file
::    ::    %+  ifix
::    ::      (in-tag "channel")
::    ::    ;~  sfix
::    ::      !!
::    ::    ==
::    ::::  entries
::    ::%-  scan
::    ::  xml-file
::    ::!!
::  ::
::  ++  items
::    ::  input: cord beginning with first <item>, ending with last </item>
::    ::  ^-  (list rss-item)
::    !!
::  ::
::  ++  item
::    !!
::  ::
::  ++  title
::  |=  xml=tape
::  ::^-  rss-item-element
::  :-  %title
::  %-  crip
::  %+  scan
::    xml
::  %+  ifix
::    (in-tag "title")
::  (match-until '</title>')
::  ::
::  ++  link
::  |=  xml=cord
::  ::  XX should output unparsed remainder of cord?
::  ^-  rss-item-element
::  :-  %link
::  %+  rash
::    xml
::  %+  ifix
::    (in-tag "link")
::  (match-until '</link>')
::  ::
::  ++  description
::  |=  xml=cord
::  ::  XX should output unparsed remainder of cord?
::  ^-  rss-item-element
::  :-  %description
::  %+  rash
::    xml
::  %+  ifix
::    (in-tag "description")
::  (match-until '</description>')
::  ::
::  ++  language
::  |=  xml=cord
::  ::  XX should output unparsed remainder of cord?
::  ^-  rss-item-element
::  :-  %language
::  %+  rash
::    xml
::  %+  ifix
::    (in-tag "language")
::  (match-until '</language>')
::  ::
::  ++  pub-date
::  ::  XX convert to @da
::  |=  xml=cord
::  ::  XX should output unparsed remainder of cord?
::  ^-  rss-item-element
::  :-  %pub-date
::  %+  rash
::    xml
::  %+  ifix
::    (in-tag "pubDate")
::  (match-until '</pubDate>')
::  ::
::  ++  last-build-date
::  ::  XX convert to @da
::  |=  xml=cord
::  ::  XX should output unparsed remainder of cord?
::  ^-  rss-item-element
::  :-  %last-build-date
::  %+  rash
::    xml
::  %+  ifix
::    (in-tag "lastPubDate")
::  (match-until '</lastPubDate>')
::  ::
::  ++  docs
::  |=  xml=cord
::  ::  XX should output unparsed remainder of cord?
::  ^-  rss-item-element
::  :-  %docs
::  %+  rash
::    xml
::  %+  ifix
::    (in-tag "docs")
::  (match-until '</docs>')
::  ::
::  ++  generator
::  |=  xml=cord
::  ::  XX should output unparsed remainder of cord?
::  ^-  rss-item-element
::  :-  %generator
::  %+  rash
::    xml
::  %+  ifix
::    (in-tag "generator")
::  (match-until '</generator>')
::  ::
::  ++  managing-editor
::  |=  xml=cord
::  ::  XX should output unparsed remainder of cord?
::  ^-  rss-item-element
::  :-  %managing-editor
::  %+  rash
::    xml
::  %+  ifix
::    (in-tag "managingEditor")
::  (match-until '</managingEditor>')
::  ::
::  ++  web-master
::  |=  xml=cord
::  ::  XX should output unparsed remainder of cord?
::  ^-  rss-item-element
::  :-  %web-master
::  %+  rash
::    xml
::  %+  ifix
::    (in-tag "webMaster")
::  (match-until '</webMaster>')
::  ::
::  --
::
::  XX +atom parser barcen
::
--