|%
::
::  XX check none are unused here
::  XX fill out the other raw auras
+|  %type-faces
::
+$  uri        @t
+$  url        @t
+$  name       @t
+$  email      @t
+$  timestamp  @da
::
::  Atom 1.0
+|  %atom-types
::
+$  atom-feed
  $:  elems=(set atom-feed-element)
      entries=(set atom-entry)
  ==
::
+$  atom-entry
  [%entry (set atom-entry-element)]
::
+$  atom-feed-element
  $%  [%id @t]
      [%title @t]
      [%updated timestamp]
      [%link rel=url href=url]
      [%author =name =email =uri]
      [%category @t]
      [%contributor =name]
      [%generator =uri version=@t]
      [%icon =url] 
      [%logo =url]
      [%rights @t]
      [%subtitle @t]
  ==
::
+$  atom-entry-element
  $%  [%id @t]
      [%title @t]
      [%updated timestamp]
      [%author name]
      [%summary @t]
      [%contributor name]
      [%published timestamp]
      [%rights @t]
      [%source id=url title=@t updated=timestamp]
      [%category term=@t scheme=(unit uri) label=(unit @t)]
      $:  %content
          type=@t
          src=(unit uri)
      ==
      $:  %link
          href=uri
          rel=(unit ?(uri %'alternate' %'enclosure' %'related' %'self' %'via'))
          type=@t
          hreflang=@t
          title=@t
          length=@t
      ==
  ==
--