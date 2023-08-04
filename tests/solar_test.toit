// Copyright (C) 2021 Toitware ApS.  All rights reserved.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the TESTS_LICENSE file.

import expect show *
import math

import solar_position show *

main:
  aarhus_2021
  berlin_2021
  honolulu_2021
  auckland_2021
  arctic_summer_2021
  arctic_spring_2021
  arctic_winter_2021
  antarctic_conditions_2021
  poles_2021
  main2
  check_declination

AARHUS_LONGITUDE ::= 10.2039
AARHUS_LATITUDE  ::= 56.1629

TRANBJERG_LONGITUDE ::= 10.1337
TRANBJERG_LATITUDE ::= 56.09

aarhus_2021:
  oct_8 ::= Time.parse "2021-10-08T12:00:00Z"
  geome := sunrise_sunset oct_8 AARHUS_LONGITUDE AARHUS_LATITUDE GEOMETRIC
  civil := sunrise_sunset oct_8 AARHUS_LONGITUDE AARHUS_LATITUDE CIVIL
  nauti := sunrise_sunset oct_8 AARHUS_LONGITUDE AARHUS_LATITUDE NAUTICAL
  astro := sunrise_sunset oct_8 AARHUS_LONGITUDE AARHUS_LATITUDE ASTRONOMICAL

  print "morning astronomical twilight $astro.sunrise.local"
  print "morning nautical twilight     $nauti.sunrise.local"
  print "morning civil twilight        $civil.sunrise.local"
  print "sunrise                       $geome.sunrise.local"
  print "sunset                        $geome.sunset.local"
  print "evening civil twilight        $civil.sunset.local"
  print "evening nautical twilight     $nauti.sunset.local"
  print "evening astronomical twilight $astro.sunset.local"

  ERROR := Duration --s=85
  // Expected times from Wolfram Alpha.
  astro_rise := Time.parse "2021-10-08T03:31:00Z"
  nauti_rise := Time.parse "2021-10-08T04:15:00Z"
  civil_rise := Time.parse "2021-10-08T04:59:00Z"
  geome_rise := Time.parse "2021-10-08T05:36:00Z"
  geome_set  := Time.parse "2021-10-08T16:35:00Z"
  civil_set  := Time.parse "2021-10-08T17:12:00Z"
  nauti_set  := Time.parse "2021-10-08T17:56:00Z"
  astro_set  := Time.parse "2021-10-08T18:40:00Z"
  expect astro_rise - ERROR < astro.sunrise < astro_rise + ERROR
  expect nauti_rise - ERROR < nauti.sunrise < nauti_rise + ERROR
  expect civil_rise - ERROR < civil.sunrise < civil_rise + ERROR
  expect geome_rise - ERROR < geome.sunrise < geome_rise + ERROR
  expect geome_set  - ERROR < geome.sunset < geome_set  + ERROR
  expect civil_set  - ERROR < civil.sunset < civil_set  + ERROR
  expect nauti_set  - ERROR < nauti.sunset < nauti_set  + ERROR
  expect astro_set  - ERROR < astro.sunset < astro_set  + ERROR

BERLIN_LONGITUDE ::= 13.4123026
BERLIN_LATITUDE  ::= 52.5189418

berlin_2021:
  oct_8 ::= Time.parse "2021-10-08T12:00:00Z"
  geome := sunrise_sunset oct_8 BERLIN_LONGITUDE BERLIN_LATITUDE GEOMETRIC

  print "sunset (Berlin)               $geome.sunset.local"

  ERROR := Duration --s=85
  // Expected times from the net.
  geome_set  := Time.parse "2021-10-08T16:27:00Z"
  expect geome_set  - ERROR < geome.sunset < geome_set  + ERROR

HONOLULU_LONGITUDE ::= -157.8583
HONOLULU_LATITUDE  ::= 21.3069

honolulu_2021:
  oct_8 ::= Time.parse "2021-10-08T12:00:00Z"
  geome := sunrise_sunset oct_8 HONOLULU_LONGITUDE HONOLULU_LATITUDE GEOMETRIC

  print "sunrise (Honolulu)             $geome.sunrise"
  print "sunset  (Honolulu)             $geome.sunset"

  ERROR := Duration --s=85
  // Expected times from the TimeAndData.com.
  geome_rise := Time.parse "2021-10-08T16:24:00Z"  // 6:24 local time.
  geome_set  := Time.parse "2021-10-09T04:12:00Z"  // 18:12 local time.
  expect geome_rise - ERROR < geome.sunrise < geome_rise + ERROR
  expect geome_set  - ERROR < geome.sunset < geome_set  + ERROR

AUCKLAND_LONGITUDE ::= 174.7645
AUCKLAND_LATITUDE  ::= -36.8509

auckland_2021:
  oct_8 ::= Time.parse "2021-10-08T12:00:00Z"
  geome := sunrise_sunset oct_8 AUCKLAND_LONGITUDE AUCKLAND_LATITUDE GEOMETRIC

  print "sunrise (Auckland)            $geome.sunrise"
  print "sunset (Auckland)             $geome.sunset"

  ERROR := Duration --s=85
  // Expected times from TimeAndDate.com
  geome_rise := Time.parse "2021-10-07T17:45:00Z"  // 6:45 local time, Auckland is GMT+13.
  geome_set  := Time.parse "2021-10-08T06:31:00Z"  // 19:31 local time, Auckland is GMT+13.
  expect geome_rise - ERROR < geome.sunrise < geome_rise + ERROR
  expect geome_set  - ERROR < geome.sunset < geome_set  + ERROR

JAN_MAYEN_LONGITUDE ::= -8.2920
JAN_MAYEN_LATITUDE  ::= 71.0318

arctic_summer_2021:
  // We disagree with TimeAndDate.com on whether the sun rose on May 12 and July 31.
  // Given that the sun is skimming along parallel to the horizon all night
  // this is not too worrying.
  may_11 ::= Time.parse "2021-05-11T12:00:00Z"  // 2nd-last day with a sunset according to TimeAndDate.com.
  may_13 ::= Time.parse "2021-05-13T12:00:00Z"  // First day with no night.
  jul_30 ::= Time.parse "2021-07-30T12:00:00Z"  // 2nd-last day with no night according to TimeAndDate.com.
  aug_1 ::= Time.parse "2021-08-01T12:00:00Z"   // First day with a sunrise according to TimeAndDate.com.

  spring          := sunrise_sunset may_11 JAN_MAYEN_LONGITUDE JAN_MAYEN_LATITUDE GEOMETRIC
  no_night_spring := sunrise_sunset may_13 JAN_MAYEN_LONGITUDE JAN_MAYEN_LATITUDE GEOMETRIC
  no_night_autumn := sunrise_sunset jul_30 JAN_MAYEN_LONGITUDE JAN_MAYEN_LATITUDE GEOMETRIC
  autumn          := sunrise_sunset aug_1  JAN_MAYEN_LONGITUDE JAN_MAYEN_LATITUDE GEOMETRIC

  print "sunrise (Jan Mayen)            $spring.sunrise"
  print "sunset (Jan Mayen)             $spring.sunset"
  print "sunrise (Jan Mayen)            $autumn.sunrise"
  print "sunset (Jan Mayen)             $autumn.sunset"

  expect_not_equals null spring.sunrise
  expect_not_equals null spring.sunset
  expect no_night_spring.always_light
  expect no_night_autumn.always_light
  expect_not_equals null autumn.sunrise
  expect_not_equals null autumn.sunset

  ERROR := Duration --s=1080  // 18 minute errors when the sun is almost horizontal!
  // Expected times from TimeAndDate.com
  spring_rise := Time.parse "2021-05-11T01:10:00Z"  // 3:30 local time
  spring_set  := Time.parse "2021-05-11T23:45:00Z"  // 1:48 local time, next day.
  expect spring_rise - ERROR < spring.sunrise < spring_rise + ERROR
  expect spring_set  - ERROR < spring.sunset < spring_set  + ERROR
  autumn_rise := Time.parse "2021-08-01T01:30:00Z"  // 3:30 local time
  autumn_set  := Time.parse "2021-08-01T23:48:00Z"  // 1:48 local time, next day.
  expect autumn_rise - ERROR < autumn.sunrise < autumn_rise + ERROR
  expect autumn_set  - ERROR < autumn.sunset < autumn_set  + ERROR

arctic_spring_2021:
  fool ::= Time.parse      "2021-04-01T12:00:00Z"  // April fool's day
  halloween ::= Time.parse "2021-10-31T12:00:00Z"
  print_times fool JAN_MAYEN_LONGITUDE JAN_MAYEN_LATITUDE GEOMETRIC "Geometric"
  print_times halloween JAN_MAYEN_LONGITUDE JAN_MAYEN_LATITUDE GEOMETRIC "Geometric"

  fool_sun := sunrise_sunset fool JAN_MAYEN_LONGITUDE JAN_MAYEN_LATITUDE GEOMETRIC
  spooky_sun := sunrise_sunset halloween JAN_MAYEN_LONGITUDE JAN_MAYEN_LATITUDE GEOMETRIC

  print "sunrise (Jan Mayen Fool)            $fool_sun.sunrise"
  print "sunset (Jan Mayen Fool)             $fool_sun.sunset"
  print "sunrise (Jan Mayen Halloween)       $spooky_sun.sunrise"
  print "sunset (Jan Mayen Halloween)        $spooky_sun.sunset"

  expect_not_equals null fool_sun.sunrise
  expect_not_equals null fool_sun.sunset
  expect_not_equals null spooky_sun.sunrise
  expect_not_equals null spooky_sun.sunset

  ERROR := Duration --s=85
  // Expected times from TimeAndDate.com
  fool_rise := Time.parse "2021-04-01T05:31:00Z"  // 7:31 local time
  fool_set  := Time.parse "2021-04-01T19:43:00Z"  // 21:43 local time
  expect fool_rise - ERROR < fool_sun.sunrise < fool_rise + ERROR
  expect fool_set  - ERROR < fool_sun.sunset < fool_set  + ERROR
  // Expected times from TimeAndDate.com
  ERROR = Duration --s=180  // 3 minute errors at Halloween..
  spooky_rise := Time.parse "2021-10-31T09:10:00Z"  // 10:10 local time
  spooky_set  := Time.parse "2021-10-31T15:20:00Z"  // 16:20 local time
  expect spooky_rise - ERROR < spooky_sun.sunrise < spooky_rise + ERROR
  expect spooky_set  - ERROR < spooky_sun.sunset < spooky_set  + ERROR

arctic_winter_2021:
  jan_1 ::= Time.parse "2021-01-01T12:00:00Z"

  silvester_sun := sunrise_sunset jan_1 JAN_MAYEN_LONGITUDE JAN_MAYEN_LATITUDE GEOMETRIC
  expect silvester_sun.always_dark

  silvester_civil := sunrise_sunset jan_1 JAN_MAYEN_LONGITUDE JAN_MAYEN_LATITUDE CIVIL
  // No sun, but there is a bit of twilight to cheer you up in January on Jan Mayen.
  expect false == (silvester_civil.always_dark)

  // Near the North Pole in Winter the sun is almost 23 degrees under the
  // horizon so you can watch the stars 24/7.
  silvester_north_pole := sunrise_sunset jan_1 0.0 90.0 ASTRONOMICAL
  expect silvester_north_pole.always_dark

TROLL_STATION_LATITUDE ::= -72.011667  // 72 00' 42'' S
TROLL_STATION_LONGITUDE ::= 2.53472    //  2 32' 05'' E

antarctic_conditions_2021:
  jan_1 ::= Time.parse "2021-01-01T12:00:00Z"
  feb_1 ::= Time.parse "2021-02-01T12:00:00Z"

  silvester_sun := sunrise_sunset jan_1 TROLL_STATION_LONGITUDE TROLL_STATION_LATITUDE GEOMETRIC
  expect silvester_sun.always_light

  feb_sun := sunrise_sunset feb_1 TROLL_STATION_LONGITUDE TROLL_STATION_LATITUDE GEOMETRIC
  // It's light almost all day.
  expect (feb_sun.sunrise.to feb_sun.sunset) > (Duration --h=22)

  feb_twilight := sunrise_sunset feb_1 TROLL_STATION_LONGITUDE TROLL_STATION_LATITUDE CIVIL
  // Never less than twilight in February.
  expect feb_twilight.always_light

  feb_astro := sunrise_sunset feb_1 TROLL_STATION_LONGITUDE TROLL_STATION_LATITUDE ASTRONOMICAL
  // No stargazing at Troll Station in February.
  expect feb_astro.always_light

  jul_1 ::= Time.parse "2021-07-01T12:00:00Z"

  july_sun := sunrise_sunset jul_1 TROLL_STATION_LONGITUDE TROLL_STATION_LATITUDE GEOMETRIC
  expect july_sun.always_dark

poles_2021:
  fool ::= Time.parse      "2021-04-01T12:00:00Z"  // April fool's day
  halloween ::= Time.parse "2021-10-31T12:00:00Z"
  march_equinox := Time.parse "2021-03-21T12:00:00Z"  // March equinox.
  september_equinox := Time.parse "2021-09-21T12:00:00Z"  // September equinox.

  NORTH_POLE := 90.0
  SOUTH_POLE := -90.0

  fool_sun := sunrise_sunset fool                0.0 90.0 GEOMETRIC
  spooky_sun := sunrise_sunset halloween         0.0 90.0 GEOMETRIC
  spring_sun := sunrise_sunset march_equinox     0.0 90.0 GEOMETRIC
  autumn_sun := sunrise_sunset september_equinox 0.0 90.0 GEOMETRIC

  // No sunsets or sunrises on the North Pole on a random day.
  expect_equals null fool_sun.sunrise
  expect_equals null fool_sun.sunset
  expect_equals null spooky_sun.sunrise
  expect_equals null spooky_sun.sunset
  expect_equals null spring_sun.sunrise
  expect_equals null spring_sun.sunset
  expect_equals null autumn_sun.sunrise
  expect_equals null autumn_sun.sunset

  fool_sun = sunrise_sunset fool                0.0 -90.0 GEOMETRIC
  spooky_sun = sunrise_sunset halloween         0.0 -90.0 GEOMETRIC
  spring_sun = sunrise_sunset september_equinox 0.0 -90.0 GEOMETRIC
  autumn_sun = sunrise_sunset march_equinox     0.0 -90.0 GEOMETRIC

  // No sunsets or sunrises on the South Pole on a random day.
  expect_equals null fool_sun.sunrise
  expect_equals null fool_sun.sunset
  expect_equals null spooky_sun.sunrise
  expect_equals null spooky_sun.sunset
  expect_equals null spring_sun.sunrise
  expect_equals null spring_sun.sunset
  expect_equals null autumn_sun.sunrise
  expect_equals null autumn_sun.sunset

check_declination:
  // NOAA has a very accurate calculator that takes your century into
  // account.  For Tranbjerg they give the following declinations at 12 noon.
  //            NOAA
  // 2001-04-30 14.88
  // 2011-04-30 14.75
  // 2021-04-30 14.93
  // 2031-04-30 14.80
  // 2041-04-30 14.98
  // 2051-04-30 14.85
  // 2061-04-30 15.02
  // 2071-04-30 14.89
  CORRECT ::= {
    2001: 14.88,
    2011: 14.75,
    2021: 14.93,
    2031: 14.80,
    2041: 14.98,
    2051: 14.85,
    2061: 15.02,
  }

  for y := 2001; y < 2070; y += 10:
    t := Time.parse "$(y)-04-30T12:00:00Z"
    decl := declination t
    decl = radians_to_degrees decl
    decl %= 360.0
    expect CORRECT[y] - 0.01 < decl < CORRECT[y] + 0.01

radians_to_degrees radians/num -> float:
  return radians / math.PI * 180.0

degrees_to_radians degrees/num -> float:
  return degrees * math.PI / 180.0

main2:
  expect_equals
    0.0
    days_since_2000 (Time.parse "2000-01-01T12:00:00Z")
  expect_equals
    1.0
    days_since_2000 (Time.parse "2000-01-02T12:00:00Z")
  expect_equals
    -1.0
    days_since_2000 (Time.parse "1999-12-31T12:00:00Z")
  expect_equals
    0.5
    days_since_2000 (Time.parse "2000-01-02T00:00:00Z")
  expect_equals
    365.5  // Leap year.
    days_since_2000 (Time.parse "2001-01-01T00:00:00Z")

  end_of_april := Time.parse "2021-04-30T03:48:00Z"
  expect_equals
    7790.0 - 9.0 / 24 + 48.0 / (24 * 60)
    days_since_2000 end_of_april

  expect_equals
    2451545 + (days_since_2000 end_of_april)
    julian_day end_of_april

  accurate := radians_to_degrees
      declination end_of_april
  print "Accurate: $(%0.8f accurate)"
  // https://gml.noaa.gov/grad/solcalc/ says 14.8 degrees.
  expect 14.75 <= accurate < 14.85

  start_of_october := Time.parse "2049-10-01T14:41:49Z"
  october_declination := radians_to_degrees
      declination start_of_october

  print "October: $(%0.8f october_declination)"
  // https://gml.noaa.gov/grad/solcalc/ says -3.51 degrees.
  expect -3.515 <= october_declination < -3.505

  birthday := Time.parse "1969-05-27T12:55:00Z"
  birthday_declination := radians_to_degrees
      declination birthday

  print "May: $(%0.8f birthday_declination)"
  // https://gml.noaa.gov/grad/solcalc/ says 21.32 degrees.
  expect 21.315 <= birthday_declination < 21.325

  print "89: $(%0.3f elevation_correction (degrees_to_radians 89.0))"
  print "86: $(%0.3f radians_to_degrees (elevation_correction (degrees_to_radians 86.0)))"
  print "85: $(%0.3f radians_to_degrees (elevation_correction (degrees_to_radians 85.0)))"
  print "84: $(%0.3f radians_to_degrees (elevation_correction (degrees_to_radians 84.0)))"
  print "5.01: $(%0.3f radians_to_degrees (elevation_correction (degrees_to_radians 5.01)))"
  print "5.00: $(%0.3f radians_to_degrees (elevation_correction (degrees_to_radians 5.00)))"
  print "4.99: $(%0.3f radians_to_degrees (elevation_correction (degrees_to_radians 4.99)))"
  print "4.0: $(%0.3f radians_to_degrees (elevation_correction (degrees_to_radians 4.0)))"
  print "3.0: $(%0.3f radians_to_degrees (elevation_correction (degrees_to_radians 3.0)))"
  print "2.0: $(%0.3f radians_to_degrees (elevation_correction (degrees_to_radians 2.0)))"
  print "1.0: $(%0.3f radians_to_degrees (elevation_correction (degrees_to_radians 1.0)))"
  print "0.0: $(%0.3f radians_to_degrees (elevation_correction (degrees_to_radians 0.0)))"
  print "-0.5: $(%0.3f radians_to_degrees (elevation_correction (degrees_to_radians -0.5)))"
  print "-0.574: $(%0.3f radians_to_degrees (elevation_correction (degrees_to_radians -0.574)))"
  print "-0.575: $(%0.3f radians_to_degrees (elevation_correction (degrees_to_radians -0.575)))"
  print "-0.576: $(%0.3f radians_to_degrees (elevation_correction (degrees_to_radians -0.576)))"
  print "-0.6: $(%0.3f radians_to_degrees (elevation_correction (degrees_to_radians -0.6)))"
  print "-1.0: $(%0.3f radians_to_degrees (elevation_correction (degrees_to_radians -1.0)))"
  print "-2.0: $(%0.3f radians_to_degrees (elevation_correction (degrees_to_radians -2.0)))"
  print "-3.0: $(%0.3f radians_to_degrees (elevation_correction (degrees_to_radians -3.0)))"
  print "-4.0: $(%0.3f radians_to_degrees (elevation_correction (degrees_to_radians -4.0)))"
  print "-5.0: $(%0.3f radians_to_degrees (elevation_correction (degrees_to_radians -5.0)))"
  print "-6.0: $(%0.3f radians_to_degrees (elevation_correction (degrees_to_radians -6.0)))"
  print "-12.0: $(%0.3f radians_to_degrees (elevation_correction (degrees_to_radians -12.0)))"
  print "-18.0: $(%0.3f radians_to_degrees (elevation_correction (degrees_to_radians -18.0)))"
  print "-89.9: $(%0.3f radians_to_degrees (elevation_correction (degrees_to_radians -89.9)))"
  print "-90.0: $(%0.3f radians_to_degrees (elevation_correction (degrees_to_radians -90.0)))"

  noon := Time.parse "2021-04-30T12:00:00Z"
  print_times noon TRANBJERG_LONGITUDE TRANBJERG_LATITUDE GEOMETRIC     "   Geometric"
  print_times noon TRANBJERG_LONGITUDE TRANBJERG_LATITUDE CIVIL         "       Civil"
  print_times noon TRANBJERG_LONGITUDE TRANBJERG_LATITUDE NAUTICAL      "    Nautical"
  print_times noon TRANBJERG_LONGITUDE TRANBJERG_LATITUDE ASTRONOMICAL  "Astronomical"

print_times noon_time/Time longitude/float latitude/float type/num name/string -> none:
  // First we get the sunset/sunrise times with the time of year based on
  // the day.
  times := sunrise_sunset noon_time longitude latitude type
  unrefined_sunrise := times.sunrise
  unrefined_sunset := times.sunset
  if unrefined_sunrise:
    // Get a more refined sunrise time where we determine the time of year based
    // on the first, unrefined sunrise time.
    times_2 := sunrise_sunset noon_time --time=unrefined_sunrise longitude latitude type
    sunrise := times_2.sunrise
    if sunrise:
      print "Sunrise ($name): $sunrise.utc"
    else:
      print "Sunrise ($name): none"
  if unrefined_sunset:
    // Get a more refined sunset time where we determine the time of year based
    // on the first, unrefined sunset time.
    times_2 := sunrise_sunset noon_time --time=unrefined_sunset longitude latitude type
    sunset := times_2.sunset
    if sunset:
      print "Sunset  ($name): $sunset.utc"
    else:
      print "Sunset  ($name): none"
