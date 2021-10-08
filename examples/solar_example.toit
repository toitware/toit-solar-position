// Copyright (C) 2021 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the EXAMPLES_LICENSE file.

import solar_position show *

TRANBJERG_LONGITUDE ::= 10.1337
TRANBJERG_LATITUDE ::= 56.09

main:
  // Sunrise and sunset for April 30, 2021 in Tranbjerg J, Denmark.
  transitions := sunrise_sunset 2021 04 30 TRANBJERG_LONGITUDE TRANBJERG_LATITUDE

  print "Sunrise 2021-04-30 at $transitions.sunrise.local"
  print "Sunset 2021-04-30 at $transitions.sunset.local"

  // Really you should give a time at noon, UTC, but you can get an approximate
  // answer just be using a nearby time.  If you are near the date line or it is
  // in the middle of the night you could get the sunset and sunrise times for
  // the day before or after, which is usually almost the same.
  today := sunrise_sunset (Time.now) TRANBJERG_LONGITUDE TRANBJERG_LATITUDE

  print "Sunrise today at $today.sunrise.local"
  print "Sunset today at $today.sunset.local"

  today = sunrise_sunset 2021 10 08 TRANBJERG_LONGITUDE TRANBJERG_LATITUDE

  print "Sunrise today at $today.sunrise.local"
  print "Sunset today at $today.sunset.local"
