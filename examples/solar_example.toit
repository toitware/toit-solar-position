// Copyright (C) 2021 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the EXAMPLES_LICENSE file.

import solar-position show *

TRANBJERG-LONGITUDE ::= 10.1337
TRANBJERG-LATITUDE ::= 56.09

main:
  // Sunrise and sunset for April 30, 2021 in Tranbjerg J, Denmark.
  transitions := sunrise-sunset 2021 04 30 TRANBJERG-LONGITUDE TRANBJERG-LATITUDE

  print "Sunrise 2021-04-30 at $transitions.sunrise.local"
  print "Sunset 2021-04-30 at $transitions.sunset.local"

  // Really you should give a time at noon, UTC, but you can get an approximate
  // answer just be using a nearby time.  If you are near the date line or it is
  // in the middle of the night you could get the sunset and sunrise times for
  // the day before or after, which is usually almost the same.
  today := sunrise-sunset (Time.now) TRANBJERG-LONGITUDE TRANBJERG-LATITUDE

  print "Sunrise today at $today.sunrise.local"
  print "Sunset today at $today.sunset.local"

  today = sunrise-sunset 2021 10 08 TRANBJERG-LONGITUDE TRANBJERG-LATITUDE

  print "Sunrise today at $today.sunrise.local"
  print "Sunset today at $today.sunset.local"
