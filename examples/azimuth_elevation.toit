// Copyright (C) 2021 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the EXAMPLES_LICENSE file.

import solar_position show *

// Northern Hemisphere.
TRANBJERG_LONGITUDE ::= 10.1337
TRANBJERG_LATITUDE ::= 56.09

// Antarctic.
TROLL_STN_LATITUDE ::= -72.011667  // 72 00' 42'' S
TROLL_STN_LONGITUDE ::= 2.53472    //  2 32' 05'' E

// Northern Tropics.
THE_DUNE_LATITUDE  ::= 18.176191456792704
THE_DUNE_LONGITUDE ::= -63.11793075444335

// Easter Island
RAPA_NUI_LATITUDE  ::=  -27.11667  // 27 7'S
RAPA_NUI_LONGITUDE ::= -109.36667  // 109 22'W

main:
  curve "Tranbjerg" TRANBJERG_LONGITUDE TRANBJERG_LATITUDE 2021 10 11
  curve "Tranbjerg" TRANBJERG_LONGITUDE TRANBJERG_LATITUDE 2021 6 21
  curve "Tranbjerg" TRANBJERG_LONGITUDE TRANBJERG_LATITUDE 2021 12 21
  curve "Troll    " TROLL_STN_LONGITUDE TROLL_STN_LATITUDE 2021 10 11
  curve "Troll    " TROLL_STN_LONGITUDE TROLL_STN_LATITUDE 2021 6 21
  curve "Troll    " TROLL_STN_LONGITUDE TROLL_STN_LATITUDE 2021 12 21
  curve "The Dune " THE_DUNE_LONGITUDE THE_DUNE_LATITUDE 2021 10 11
  curve "The Dune " THE_DUNE_LONGITUDE THE_DUNE_LATITUDE 2021 6 21
  curve "The Dune " THE_DUNE_LONGITUDE THE_DUNE_LATITUDE 2021 12 21
  curve "The Dune " THE_DUNE_LONGITUDE THE_DUNE_LATITUDE 2024 6 1
  curve "Rapa Nui " RAPA_NUI_LONGITUDE RAPA_NUI_LATITUDE 2021 10 11
  curve "Rapa Nui " RAPA_NUI_LONGITUDE RAPA_NUI_LATITUDE 2021 6 21
  curve "Rapa Nui " RAPA_NUI_LONGITUDE RAPA_NUI_LATITUDE 2021 12 21
  curve "Rapa Nui " RAPA_NUI_LONGITUDE RAPA_NUI_LATITUDE 2024 6 1

curve place long lat y m d:
  ss := sunrise_sunset y m d long lat
  print "Sunrise $ss.sunrise"
  print "Sunset  $ss.sunset"
  for i := 1; i <= 23; i++:
    time := Time.utc --year=y --month=m --day=d --h=i
    position := solar_position time long lat
    print "$place $time.utc $position.elevation_degrees $position.azimuth_degrees"
  print ""
