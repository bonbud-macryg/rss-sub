::
::  Specification for storing RSS/Atom data in Hoon.
::
::  XX explanatory notes
::  XX  tag <-> value rules / example
::        if one item, it's the tag value
::        otherwise, tag value is specified
::        <example>
::        attributes in comments are strictly faces corresponding to attribute
::
|%
+$  day   @t   ::  XX ?(%monday %tuesday %wednesday %thursday %friday)
::  XX should maybe have a uuid type for ids, but double-check across RSS + Atom
+$  uri   @t
::  XX note different standards in RSS vs. Atom if necessary
+$  lang  @t   ::  BCP47 language tag
+$  link  @t   ::  url
+$  mail  @t   ::  email
+$  mime  @t
+$  name  @t   ::  author
+$  text  @t
+$  vers  @t   ::  semantic version number
+$  hour  @ud  ::  hours 0 to 23
+$  numb  @ud
::
::  Atom 1.0
++  atom
  |%
  +$  feed
    $+  atom-feed
    $:  %feed
        ::  XX narrow down type
        headers=(list *)
        elems=(list feed-element)
        entries=(list entry)
    ==
  ::
  +$  entry
    $+  atom-entry
    [%entry (list entry-element)]
  ::
  ::  XX label attributes in comments (like %category and %source)
  +$  feed-element
    $+  feed-element
    $%  [%id uri]
        [%title text]
        [%updated time]
        [%author name (unit mail) (unit uri)]
        [%category text (unit uri) (unit text)]  ::  term, scheme, label
        [%contributor name]
        [%generator (unit uri) (unit vers)]  ::  uri, version
        [%icon link]
        [%logo link]
        [%rights text]
        [%subtitle text]
        ::  href, ref, type, hreflang, title, length
        [%link uri (unit ref) (unit mime) (unit lang) (unit text) (unit numb)]
    ==
  ::
  +$  ref
    $+  atom-ref
    ?(uri %alternate %enclosure %related %self %via)
  ::
  +$  entry-element
    $+  atom-entry-element
    $%  [%id uri]
        [%title text]
        [%updated time]
        [%author name]
        [%summary text]
        [%contributor name]
        [%published time]
        [%rights text]
        ::  XX what's optional?
        ::  XX is id a link or uri?
        [%source link text time]  ::  id, title, updated
        [%category text (unit uri) (unit text)]  ::  term, scheme, label
        ::  XX check what is required in what circumstances
        [%content (unit type) (unit uri) (unit text)]
        ::  href, ref, type, hreflang, title, length
        [%link uri (unit ref) (unit mime) (unit lang) (unit text) (unit numb)]
    ==
  ::
  ::  XX fine for a rough draft, but check against the actual RFC
  ::       it's a bit more complicated than this
  +$  type
    ?(mime %html %text %xhtml)
  --
::
::  RSS 2.0.1
::  XX on versions: https://www.rssboard.org/rss-specification#extendingRss
++  rss
  |%
  +$  channel
    $+  rss-channel
    $:  %channel
        ::  XX narrow down type
        headers=(list *)
        elems=(list channel-element)
        items=(list item)
    ==
  ::
  +$   item
    $+  rss-item
    [%item (list item-element)]
  ::
  +$  item-element
    $+  rss-item-element
    $%  [%title text]
        [%link link]
        [%description text]
        [%author text]
        [%category (unit link) text]  ::  domain, tag
        [%comments link]
        [%enclosure link numb mime]  ::  url, length, type
        ::  XX i forgot what this is, investigate
        [%guid (unit text) link]  ::  isPermaLink, tag, value
        [%pub-date time]
        [%source link text]  ::  url, tag
    ==
  ::
  +$  channel-element
    $%  [%title text]
        [%link link]
        [%description text]
        [%language lang]  ::  ISO639 or RFC1766 lang code
        [%pub-date time]
        [%last-build-date time]
        [%docs link]
        [%generator text]
        [%managing-editor text]
        [%web-master text]
        [%copyright text]
        [%category (unit link) text]  ::  domain, tag
        [%ttl numb]
        [%rating text]  ::  PICS rating; deprecated
        ::  title, desc, name, link
        [%text-input text text text link]
        ::  domain, port, path, register-procedure, protocol
        [%cloud link numb link text text]
        ::  url, title, link, width, height, desc
        [%image link text link (unit numb) (unit numb) (unit text)]
        [%skip-days (list day)]
        [%skip-hours (list hour)]
    ==
  --
--
