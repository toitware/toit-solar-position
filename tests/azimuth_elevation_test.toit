// Copyright (C) 2021 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the TESTS_LICENSE file.

import expect show *

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

PRECISION := 0.15

main:
  known-values
  random-values

known-values:
  check
    Time.parse "2021-10-11T08:00:00Z"
    TRANBJERG-LONGITUDE
    TRANBJERG-LATITUDE
    131.43
    16.17

  check
    Time.parse "2000-01-01T12:00:00Z"
    TRANBJERG-LONGITUDE
    TRANBJERG-LATITUDE
    188.71
    10.57

  check
    Time.parse "2000-01-01T12:00:00Z"
    TROLL-STN-LONGITUDE
    TROLL-STN-LATITUDE
    357.92
    41.03

  check
    Time.parse "2024-06-01T16:10:15Z"
    THE-DUNE-LONGITUDE
    THE-DUNE-LATITUDE
    0.62
    85.99

  // 30 seconds later the angle is almost two degrees less.
  check
    Time.parse "2024-06-01T16:10:45Z"
    THE-DUNE-LONGITUDE
    THE-DUNE-LATITUDE
    358.97
    85.99

  check
    Time.parse "2024-06-01T08:30:45Z"
    THE-DUNE-LONGITUDE
    THE-DUNE-LATITUDE
    60.27
    -14.64

  check
    Time.parse "2024-06-01T09:00:00Z"
    THE-DUNE-LONGITUDE
    THE-DUNE-LATITUDE
    63.23
    -8.5

  check
    Time.parse "2024-06-01T09:00:00Z"
    THE-DUNE-LONGITUDE
    THE-DUNE-LATITUDE
    63.23
    -8.5

  check
    Time.parse "2024-06-01T00:05:00Z"
    RAPA-NUI-LONGITUDE
    RAPA-NUI-LATITUDE
    297.63
    4.63


check time/Time long/float lat/float expect-azimuth expect-elevation -> none:
  position := solar-position time long lat
  expected := SolarPosition (degrees-to-radians_ expect-azimuth) (degrees-to-radians_ expect-elevation) --noaa-elevation-correction=false
  a-precision := PRECISION
  // When the Sun is almost vertical the angle changes very fast (gimbal lock).
  if expect-elevation > 85: a-precision *= 10
  expect expected.azimuth-degrees - a-precision <= position.azimuth-degrees <= expected.azimuth-degrees + a-precision
  expect expected.elevation-degrees - PRECISION <= position.elevation-degrees <= expected.elevation-degrees + PRECISION

  expect-equals
    position.elevation-degrees < -0.833
    position.night

random-values:
  set-random-seed "azimuth elevation solar calculation"

  1000.repeat:
    year := 2000 + (random 30)
    month := 1 + (random 12)
    day := 1 + (random 28)
    hour := random 24
    minute := random 60
    second := random 60
    time := Time.parse "$(year)-$(%02d month)-$(%02d day)T$(%02d hour):$(%02d minute):$(%02d second)Z"
    lat := (random 181) - 90.0
    long := random 360
    position := solar-position time long lat
    expect-not position.azimuth-degrees.is-nan
    expect-not position.elevation-degrees.is-nan
    // Above the Tropic of Cancer the sun never rises above
    // an angle that depends on the Latitude.
    if lat > 23.5:
      expect position.elevation-degrees < 90.0 - (lat - 23.5)
    // Below the Tropic of Capricorn the sun never rises above
    // an angle that depends on the Latitude.
    else if lat < -23.5:
      expect position.elevation-degrees < 90.0 - (-lat - 23.5)
    else:
      expect position.elevation-degrees <= 90.0

    expect 0.0 <= position.azimuth-degrees < 360.0

    expect-equals
      position.elevation-degrees < -0.833
      position.night

    expect-equals
      position.elevation-degrees < -6
      position.civil-night

    expect-equals
      position.elevation-degrees < -12
      position.nautical-night

    expect-equals
      position.elevation-degrees < -18
      position.astronomical-night

    adjusted-position := solar-position time long lat --noaa-elevation-correction

    expect-equals
      adjusted-position.elevation-degrees < 0
      adjusted-position.night

    // The NOAA adjustment gives an earlier sunset and later sunrise
    // than the standard 0.833 degree adjustment.
    if position.night:
      expect adjusted-position.night
