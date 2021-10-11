// Copyright (C) 2021 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the EXAMPLES_LICENSE file.

import expect show *

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

PRECISION := 0.15

main:
  known_values
  random_values

known_values:
  check
    Time.from_string "2021-10-11T08:00:00Z"
    TRANBJERG_LONGITUDE
    TRANBJERG_LATITUDE
    131.43
    16.17

  check
    Time.from_string "2000-01-01T12:00:00Z"
    TRANBJERG_LONGITUDE
    TRANBJERG_LATITUDE
    188.71
    10.57

  check
    Time.from_string "2000-01-01T12:00:00Z"
    TROLL_STN_LONGITUDE
    TROLL_STN_LATITUDE
    357.92
    41.03

  check
    Time.from_string "2024-06-01T16:10:15Z"
    THE_DUNE_LONGITUDE
    THE_DUNE_LATITUDE
    0.62
    85.99

  // 30 seconds later the angle is almost two degrees less.
  check
    Time.from_string "2024-06-01T16:10:45Z"
    THE_DUNE_LONGITUDE
    THE_DUNE_LATITUDE
    358.97
    85.99

  check
    Time.from_string "2024-06-01T08:30:45Z"
    THE_DUNE_LONGITUDE
    THE_DUNE_LATITUDE
    60.27
    -14.64

  check
    Time.from_string "2024-06-01T09:00:00Z"
    THE_DUNE_LONGITUDE
    THE_DUNE_LATITUDE
    63.23
    -8.5

  check
    Time.from_string "2024-06-01T09:00:00Z"
    THE_DUNE_LONGITUDE
    THE_DUNE_LATITUDE
    63.23
    -8.5

  check
    Time.from_string "2024-06-01T00:05:00Z"
    RAPA_NUI_LONGITUDE
    RAPA_NUI_LATITUDE
    297.63
    4.63


check time/Time long/float lat/float expect_azimuth expect_elevation -> none:
  position := solar_position time long lat
  expected := SolarPosition (degrees_to_radians_ expect_azimuth) (degrees_to_radians_ expect_elevation) --noaa_elevation_correction=false
  a_precision := PRECISION
  // When the Sun is almost vertical the angle changes very fast (gimbal lock).
  if expect_elevation > 85: a_precision *= 10
  expect expected.azimuth_degrees - a_precision <= position.azimuth_degrees <= expected.azimuth_degrees + a_precision
  expect expected.elevation_degrees - PRECISION <= position.elevation_degrees <= expected.elevation_degrees + PRECISION

  expect_equals
    position.elevation_degrees < -0.833
    position.night

random_values:
  set_random_seed "azimuth elevation solar calculation"

  1000.repeat:
    year := 2000 + (random 30)
    month := 1 + (random 12)
    day := 1 + (random 28)
    hour := random 24
    minute := random 60
    second := random 60
    time := Time.from_string "$(year)-$(%02d month)-$(%02d day)T$(%02d hour):$(%02d minute):$(%02d second)Z"
    lat := (random 181) - 90.0
    long := random 360
    position := solar_position time long lat
    expect (not position.azimuth_degrees.is_nan)
    expect (not position.elevation_degrees.is_nan)
    // Above the Tropic of Cancer the sun never rises above
    // an angle that depends on the Latitude.
    if lat > 23.5:
      expect position.elevation_degrees < 90.0 - (lat - 23.5)
    // Below the Tropic of Capricorn the sun never rises above
    // an angle that depends on the Latitude.
    else if lat < -23.5:
      expect position.elevation_degrees < 90.0 - (-lat - 23.5)
    else:
      expect position.elevation_degrees <= 90.0

    expect 0.0 <= position.azimuth_degrees < 360.0

    expect_equals
      position.elevation_degrees < -0.833
      position.night

    expect_equals
      position.elevation_degrees < -6
      position.civil_night

    expect_equals
      position.elevation_degrees < -12
      position.nautical_night

    expect_equals
      position.elevation_degrees < -18
      position.astronomical_night

    adjusted_position := solar_position time long lat --noaa_elevation_correction

    expect_equals
      adjusted_position.elevation_degrees < 0
      adjusted_position.night

    // The NOAA adjustment gives an earlier sunset and later sunrise
    // than the standard 0.833 degree adjustment.
    if position.night:
      expect adjusted_position.night
