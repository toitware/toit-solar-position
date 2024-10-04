// Copyright (C) 2021 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the EXAMPLES_LICENSE file.

import solar-position show *

// Northern Hemisphere.
TRANBJERG-LONGITUDE ::= 10.1337
TRANBJERG-LATITUDE ::= 56.09

// Antarctic.
TROLL-STN-LATITUDE ::= -72.011667  // 72 00' 42'' S
TROLL-STN-LONGITUDE ::= 2.53472    //  2 32' 05'' E

// Northern Tropics.
THE-DUNE-LATITUDE  ::= 18.176191456792704
THE-DUNE-LONGITUDE ::= -63.11793075444335

// Easter Island
RAPA-NUI-LATITUDE  ::=  -27.11667  // 27 7'S
RAPA-NUI-LONGITUDE ::= -109.36667  // 109 22'W

main:
  curve "Tranbjerg" TRANBJERG-LONGITUDE TRANBJERG-LATITUDE 2021 10 11
  curve "Tranbjerg" TRANBJERG-LONGITUDE TRANBJERG-LATITUDE 2021 6 21
  curve "Tranbjerg" TRANBJERG-LONGITUDE TRANBJERG-LATITUDE 2021 12 21
  curve "Troll    " TROLL-STN-LONGITUDE TROLL-STN-LATITUDE 2021 10 11
  curve "Troll    " TROLL-STN-LONGITUDE TROLL-STN-LATITUDE 2021 6 21
  curve "Troll    " TROLL-STN-LONGITUDE TROLL-STN-LATITUDE 2021 12 21
  curve "The Dune " THE-DUNE-LONGITUDE THE-DUNE-LATITUDE 2021 10 11
  curve "The Dune " THE-DUNE-LONGITUDE THE-DUNE-LATITUDE 2021 6 21
  curve "The Dune " THE-DUNE-LONGITUDE THE-DUNE-LATITUDE 2021 12 21
  curve "The Dune " THE-DUNE-LONGITUDE THE-DUNE-LATITUDE 2024 6 1
  curve "Rapa Nui " RAPA-NUI-LONGITUDE RAPA-NUI-LATITUDE 2021 10 11
  curve "Rapa Nui " RAPA-NUI-LONGITUDE RAPA-NUI-LATITUDE 2021 6 21
  curve "Rapa Nui " RAPA-NUI-LONGITUDE RAPA-NUI-LATITUDE 2021 12 21
  curve "Rapa Nui " RAPA-NUI-LONGITUDE RAPA-NUI-LATITUDE 2024 6 1

curve place long lat y m d:
  ss := sunrise-sunset y m d long lat
  print "Sunrise $ss.sunrise"
  print "Sunset  $ss.sunset"
  for i := 1; i <= 23; i++:
    time := Time.utc --year=y --month=m --day=d --h=i
    position := solar-position time long lat
    print "$place $time.utc $position.elevation-degrees $position.azimuth-degrees"
  print ""
