/-  ra=rss-atom
=,  format
|_  urls=(list link:ra)
++  grab
  |%
  ++  noun  (list link:ra)
  --
++  grow
  |%
  ++  noun  urls
  ++  json
    a+(turn urls |=(u=link:ra ^-(^json s+u)))
  --
++  grad  %noun
--
