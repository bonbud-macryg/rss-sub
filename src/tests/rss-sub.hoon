/+  *test, *rss-sub
=<
::
::  tests
|%
++  test-check-channel
  %+  expect-eq
    !>  %.y
  !>  (check-channel ~[%title %link %description] [~[[%title 'foo'] [%link 'bar']] ~[[%item ~[[%title 'foo'] [%author 'bar']]]]])
  ::;:  weld
  ::  %+  expect-eq
  ::    !>  %.y
  ::  !>  (check-channel ~[%title %link %description] test-rss-channel)
  ::  %+  expect-eq
  ::    !>  %.n
  ::  !>  (check-channel ~[%foo %bar %baz] test-rss-channel)
  ::==
++  test-check-item
  %+  expect-eq
    !>  %.y
  !>  (check-item ~[%title %link %description] [%item ~[[%title 'foo'] [%author 'bar']]])
  ::;:  weld
  ::  %+  expect-eq
  ::    !>  %.y
  ::  !>  (check-item ~[%title %link %description] (head test-rss-items))
  ::  %+  expect-eq
  ::    !>  %.n
  ::  !>  (check-item ~[%foo %bar %baz] (head test-rss-items))
  ::==
++  test-check-feed
  %+  expect-eq
    !>  %.y
  !>  (check-feed ~[%title %link %updated] [~[[%id 'foo'] [%title 'bar']] ~[[%entry ~[[%author 'foo'] [%title 'bar'] [%summary 'baz']]]]])
  ::;:  weld
  ::  %+  expect-eq
  ::    !>  %.y
  ::  !>  (check-feed ~[%title %link %updated] test-atom-feed)
  ::  %+  expect-eq
  ::    !>  %.n
  ::  !>  (check-feed ~[%foo %bar %baz] test-atom-feed)
  ::==
++  test-check-entry
  %+  expect-eq
    !>  %.y
  !>  (check-entry ~[%title %link %summary] [%entry ~[[%author 'foo'] [%title 'bar'] [%summary 'baz']]])
  ::;:  weld
  ::  %+  expect-eq
  ::    !>  %.y
  ::  !>  (check-entry ~[%title %link %summary] `(pair %entry (list atom-entry-element))`test-atom-entry)
  ::  %+  expect-eq
  ::    !>  %.n
  ::  !>  (check-entry ~[%foo %bar %baz] (head test-atom-entries))
  ::==
--
::
::  helper core
|%
++  test-atom-feed
  :_  ^=  entries
      test-atom-entries
      ^=  elems
      :~  [%title 'Example Feed']
          [%link 'http://example.org/']
          [%updated '2003-12-13T18:30:02Z']
          [%author name='John Doe' email='' uri='']
          [%id 'urn:uuid:60a76c80-d399-11d9-b93C-0003939e0af6']
      ==
::
++  test-atom-entries
  :~  :-  %entry
      :~  [%title 'Atom-Powered Robots Run Amok']
          [%link 'http://example.org/2003/12/13/atom03']
          [%id 'urn:uuid:1225c695-cfb8-4ebb-aaaa-80da344efa6a']
          [%updated '2003-12-13T18:30:02Z']
          [%summary 'Some text.']
      ==
  ==
::
++  test-rss-channel
  :_  ^=  items
      test-rss-items
      ^=  elems
      :~  [%title 'NASA Space Station News']
          [%link 'http://www.nasa.gov/']
          [%description 'A RSS news feed containing the latest NASA press releases on the International Space Station.']
          [%language 'en-us']
          [%pub-date 'Tue, 10 Jun 2003 04:00:00 GMT']
          [%last-build-date 'Fri, 21 Jul 2023 09:04 EDT']
          [%docs 'https://www.rssboard.org/rss-specification']
          [%generator 'Blosxom 2.1.2']
          [%managing-editor 'neil.armstrong@example.com (Neil Armstrong)']
          [%web-master 'sally.ride@example.com (Sally Ride)']
          ::  <atom:link href="https://www.rssboard.org/files/sample-rss-2.xml" rel="self" type="application/rss+xml"/>
      ==
::
++  test-rss-items
  :~  :-  %item
      :~  [%title 'Louisiana Students to Hear from NASA Astronauts Aboard Space Station']
          [%link 'http://www.nasa.gov/press-release/louisiana-students-to-hear-from-nasa-astronauts-aboard-space-station']
          [%description 'As part of the state’s first Earth-to-space call, students from Louisiana will have an opportunity soon to hear from NASA astronauts aboard the International Space Station.']
          [%pub-date 'Fri, 21 Jul 2023 09:04 EDT']
          [%guid 'http://www.nasa.gov/press-release/louisiana-students-to-hear-from-nasa-astronauts-aboard-space-station']
      ==
      :-  %item
      :~  [%description 'NASA has selected KBR Wyle Services, LLC, of Fulton, Maryland, to provide mission and flight crew operations support for the International Space Station and future human space exploration.']
          [%link 'http://www.nasa.gov/press-release/nasa-awards-integrated-mission-operations-contract-iii']
          [%pub-date 'Thu, 20 Jul 2023 15:05 EDT']
          [%guid 'http://www.nasa.gov/press-release/nasa-awards-integrated-mission-operations-contract-iii']
      ==
      :-  %item
      :~  [%title 'NASA Expands Options for Spacewalking, Moonwalking Suits']
          [%link 'http://www.nasa.gov/press-release/nasa-expands-options-for-spacewalking-moonwalking-suits-services']
          [%description 'NASA has awarded Axiom Space and Collins Aerospace task orders under existing contracts to advance spacewalking capabilities in low Earth orbit, as well as moonwalking services for Artemis missions.']
          [%enclosure url='http://www.nasa.gov/sites/default/files/styles/1x1_cardfeed/public/thumbnails/image/iss068e027836orig.jpg?itok=ucNUaaGx' length='1032272' type='image/jpeg']
          [%pub-date 'Mon, 10 Jul 2023 14:14 ED']
          [%guid 'http://www.nasa.gov/press-release/nasa-expands-options-for-spacewalking-moonwalking-suits-services']
      ==
      :-  %item
      :~  [%title 'NASA to Provide Coverage as Dragon Departs Station']
          [%link 'http://www.nasa.gov/press-release/nasa-to-provide-coverage-as-dragon-departs-station-with-science']
          [%description 'NASA is set to receive scientific research samples and hardware as a SpaceX Dragon cargo resupply spacecraft departs the International Space Station on Thursday, June 29.']
          [%pub-date 'Tue, 20 May 2003 08:56:02 GMT']
          [%guid 'http://www.nasa.gov/press-release/nasa-to-provide-coverage-as-dragon-departs-station-with-science']
      ==
      :-  %item
      :~  [%title 'NASA Plans Coverage of Roscosmos Spacewalk Outside Space Station']
          [%link 'http://liftoff.msfc.nasa.gov/news/2003/news-laundry.asp']
          [%description 'Compared to earlier spacecraft, the International Space Station has many luxuries, but laundry facilities are not one of them. Instead, astronauts have other options.']
          [%enclosure url='http://www.nasa.gov/sites/default/files/styles/1x1_cardfeed/public/thumbnails/image/spacex_dragon_june_29.jpg?itok=nIYlBLme' length='269866' type='image/jpeg']
          [%pub-date 'Mon, 26 Jun 2023 12:45 EDT']
          [%guid 'http://liftoff.msfc.nasa.gov/2003/05/20.html#item570']
      ==
  ==
--