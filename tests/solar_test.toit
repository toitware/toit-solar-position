// Copyright (C) 2021 Toitware ApS.  All rights reserved.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the TESTS_LICENSE file.

import expect show *
import math

import solar-position show *

main:
  aarhus-2021
  berlin-2021
  honolulu-2021
  auckland-2021
  arctic-summer-2021
  arctic-spring-2021
  arctic-winter-2021
  antarctic-conditions-2021
  poles-2021
  main2
  check-declination

AARHUS-LONGITUDE ::= 10.2039
AARHUS-LATITUDE  ::= 56.1629

TRANBJERG-LONGITUDE ::= 10.1337
TRANBJERG-LATITUDE ::= 56.09

aarhus-2021:
  oct-8 ::= Time.parse "2021-10-08T12:00:00Z"
  geome := sunrise-sunset oct-8 AARHUS-LONGITUDE AARHUS-LATITUDE GEOMETRIC
  civil := sunrise-sunset oct-8 AARHUS-LONGITUDE AARHUS-LATITUDE CIVIL
  nauti := sunrise-sunset oct-8 AARHUS-LONGITUDE AARHUS-LATITUDE NAUTICAL
  astro := sunrise-sunset oct-8 AARHUS-LONGITUDE AARHUS-LATITUDE ASTRONOMICAL

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
  astro-rise := Time.parse "2021-10-08T03:31:00Z"
  nauti-rise := Time.parse "2021-10-08T04:15:00Z"
  civil-rise := Time.parse "2021-10-08T04:59:00Z"
  geome-rise := Time.parse "2021-10-08T05:36:00Z"
  geome-set  := Time.parse "2021-10-08T16:35:00Z"
  civil-set  := Time.parse "2021-10-08T17:12:00Z"
  nauti-set  := Time.parse "2021-10-08T17:56:00Z"
  astro-set  := Time.parse "2021-10-08T18:40:00Z"
  expect astro-rise - ERROR < astro.sunrise < astro-rise + ERROR
  expect nauti-rise - ERROR < nauti.sunrise < nauti-rise + ERROR
  expect civil-rise - ERROR < civil.sunrise < civil-rise + ERROR
  expect geome-rise - ERROR < geome.sunrise < geome-rise + ERROR
  expect geome-set  - ERROR < geome.sunset < geome-set  + ERROR
  expect civil-set  - ERROR < civil.sunset < civil-set  + ERROR
  expect nauti-set  - ERROR < nauti.sunset < nauti-set  + ERROR
  expect astro-set  - ERROR < astro.sunset < astro-set  + ERROR

BERLIN-LONGITUDE ::= 13.4123026
BERLIN-LATITUDE  ::= 52.5189418

berlin-2021:
  oct-8 ::= Time.parse "2021-10-08T12:00:00Z"
  geome := sunrise-sunset oct-8 BERLIN-LONGITUDE BERLIN-LATITUDE GEOMETRIC

  print "sunset (Berlin)               $geome.sunset.local"

  ERROR := Duration --s=85
  // Expected times from the net.
  geome-set  := Time.parse "2021-10-08T16:27:00Z"
  expect geome-set  - ERROR < geome.sunset < geome-set  + ERROR

HONOLULU-LONGITUDE ::= -157.8583
HONOLULU-LATITUDE  ::= 21.3069

honolulu-2021:
  oct-8 ::= Time.parse "2021-10-08T12:00:00Z"
  geome := sunrise-sunset oct-8 HONOLULU-LONGITUDE HONOLULU-LATITUDE GEOMETRIC

  print "sunrise (Honolulu)             $geome.sunrise"
  print "sunset  (Honolulu)             $geome.sunset"

  ERROR := Duration --s=85
  // Expected times from the TimeAndData.com.
  geome-rise := Time.parse "2021-10-08T16:24:00Z"  // 6:24 local time.
  geome-set  := Time.parse "2021-10-09T04:12:00Z"  // 18:12 local time.
  expect geome-rise - ERROR < geome.sunrise < geome-rise + ERROR
  expect geome-set  - ERROR < geome.sunset < geome-set  + ERROR

AUCKLAND-LONGITUDE ::= 174.7645
AUCKLAND-LATITUDE  ::= -36.8509

auckland-2021:
  oct-8 ::= Time.parse "2021-10-08T12:00:00Z"
  geome := sunrise-sunset oct-8 AUCKLAND-LONGITUDE AUCKLAND-LATITUDE GEOMETRIC

  print "sunrise (Auckland)            $geome.sunrise"
  print "sunset (Auckland)             $geome.sunset"

  ERROR := Duration --s=85
  // Expected times from TimeAndDate.com
  geome-rise := Time.parse "2021-10-07T17:45:00Z"  // 6:45 local time, Auckland is GMT+13.
  geome-set  := Time.parse "2021-10-08T06:31:00Z"  // 19:31 local time, Auckland is GMT+13.
  expect geome-rise - ERROR < geome.sunrise < geome-rise + ERROR
  expect geome-set  - ERROR < geome.sunset < geome-set  + ERROR

JAN-MAYEN-LONGITUDE ::= -8.2920
JAN-MAYEN-LATITUDE  ::= 71.0318

arctic-summer-2021:
  // We disagree with TimeAndDate.com on whether the sun rose on May 12 and July 31.
  // Given that the sun is skimming along parallel to the horizon all night
  // this is not too worrying.
  may-11 ::= Time.parse "2021-05-11T12:00:00Z"  // 2nd-last day with a sunset according to TimeAndDate.com.
  may-13 ::= Time.parse "2021-05-13T12:00:00Z"  // First day with no night.
  jul-30 ::= Time.parse "2021-07-30T12:00:00Z"  // 2nd-last day with no night according to TimeAndDate.com.
  aug-1 ::= Time.parse "2021-08-01T12:00:00Z"   // First day with a sunrise according to TimeAndDate.com.

  spring          := sunrise-sunset may-11 JAN-MAYEN-LONGITUDE JAN-MAYEN-LATITUDE GEOMETRIC
  no-night-spring := sunrise-sunset may-13 JAN-MAYEN-LONGITUDE JAN-MAYEN-LATITUDE GEOMETRIC
  no-night-autumn := sunrise-sunset jul-30 JAN-MAYEN-LONGITUDE JAN-MAYEN-LATITUDE GEOMETRIC
  autumn          := sunrise-sunset aug-1  JAN-MAYEN-LONGITUDE JAN-MAYEN-LATITUDE GEOMETRIC

  print "sunrise (Jan Mayen)            $spring.sunrise"
  print "sunset (Jan Mayen)             $spring.sunset"
  print "sunrise (Jan Mayen)            $autumn.sunrise"
  print "sunset (Jan Mayen)             $autumn.sunset"

  expect-not-equals null spring.sunrise
  expect-not-equals null spring.sunset
  expect no-night-spring.always-light
  expect no-night-autumn.always-light
  expect-not-equals null autumn.sunrise
  expect-not-equals null autumn.sunset

  ERROR := Duration --s=1080  // 18 minute errors when the sun is almost horizontal!
  // Expected times from TimeAndDate.com
  spring-rise := Time.parse "2021-05-11T01:10:00Z"  // 3:30 local time
  spring-set  := Time.parse "2021-05-11T23:45:00Z"  // 1:48 local time, next day.
  expect spring-rise - ERROR < spring.sunrise < spring-rise + ERROR
  expect spring-set  - ERROR < spring.sunset < spring-set  + ERROR
  autumn-rise := Time.parse "2021-08-01T01:30:00Z"  // 3:30 local time
  autumn-set  := Time.parse "2021-08-01T23:48:00Z"  // 1:48 local time, next day.
  expect autumn-rise - ERROR < autumn.sunrise < autumn-rise + ERROR
  expect autumn-set  - ERROR < autumn.sunset < autumn-set  + ERROR

arctic-spring-2021:
  fool ::= Time.parse      "2021-04-01T12:00:00Z"  // April fool's day
  halloween ::= Time.parse "2021-10-31T12:00:00Z"
  print-times fool JAN-MAYEN-LONGITUDE JAN-MAYEN-LATITUDE GEOMETRIC "Geometric"
  print-times halloween JAN-MAYEN-LONGITUDE JAN-MAYEN-LATITUDE GEOMETRIC "Geometric"

  fool-sun := sunrise-sunset fool JAN-MAYEN-LONGITUDE JAN-MAYEN-LATITUDE GEOMETRIC
  spooky-sun := sunrise-sunset halloween JAN-MAYEN-LONGITUDE JAN-MAYEN-LATITUDE GEOMETRIC

  print "sunrise (Jan Mayen Fool)            $fool-sun.sunrise"
  print "sunset (Jan Mayen Fool)             $fool-sun.sunset"
  print "sunrise (Jan Mayen Halloween)       $spooky-sun.sunrise"
  print "sunset (Jan Mayen Halloween)        $spooky-sun.sunset"

  expect-not-equals null fool-sun.sunrise
  expect-not-equals null fool-sun.sunset
  expect-not-equals null spooky-sun.sunrise
  expect-not-equals null spooky-sun.sunset

  ERROR := Duration --s=85
  // Expected times from TimeAndDate.com
  fool-rise := Time.parse "2021-04-01T05:31:00Z"  // 7:31 local time
  fool-set  := Time.parse "2021-04-01T19:43:00Z"  // 21:43 local time
  expect fool-rise - ERROR < fool-sun.sunrise < fool-rise + ERROR
  expect fool-set  - ERROR < fool-sun.sunset < fool-set  + ERROR
  // Expected times from TimeAndDate.com
  ERROR = Duration --s=180  // 3 minute errors at Halloween..
  spooky-rise := Time.parse "2021-10-31T09:10:00Z"  // 10:10 local time
  spooky-set  := Time.parse "2021-10-31T15:20:00Z"  // 16:20 local time
  expect spooky-rise - ERROR < spooky-sun.sunrise < spooky-rise + ERROR
  expect spooky-set  - ERROR < spooky-sun.sunset < spooky-set  + ERROR

arctic-winter-2021:
  jan-1 ::= Time.parse "2021-01-01T12:00:00Z"

  silvester-sun := sunrise-sunset jan-1 JAN-MAYEN-LONGITUDE JAN-MAYEN-LATITUDE GEOMETRIC
  expect silvester-sun.always-dark

  silvester-civil := sunrise-sunset jan-1 JAN-MAYEN-LONGITUDE JAN-MAYEN-LATITUDE CIVIL
  // No sun, but there is a bit of twilight to cheer you up in January on Jan Mayen.
  expect false == (silvester-civil.always-dark)

  // Near the North Pole in Winter the sun is almost 23 degrees under the
  // horizon so you can watch the stars 24/7.
  silvester-north-pole := sunrise-sunset jan-1 0.0 90.0 ASTRONOMICAL
  expect silvester-north-pole.always-dark

TROLL-STATION-LATITUDE ::= -72.011667  // 72 00' 42'' S
TROLL-STATION-LONGITUDE ::= 2.53472    //  2 32' 05'' E

antarctic-conditions-2021:
  jan-1 ::= Time.parse "2021-01-01T12:00:00Z"
  feb-1 ::= Time.parse "2021-02-01T12:00:00Z"

  silvester-sun := sunrise-sunset jan-1 TROLL-STATION-LONGITUDE TROLL-STATION-LATITUDE GEOMETRIC
  expect silvester-sun.always-light

  feb-sun := sunrise-sunset feb-1 TROLL-STATION-LONGITUDE TROLL-STATION-LATITUDE GEOMETRIC
  // It's light almost all day.
  expect (feb-sun.sunrise.to feb-sun.sunset) > (Duration --h=22)

  feb-twilight := sunrise-sunset feb-1 TROLL-STATION-LONGITUDE TROLL-STATION-LATITUDE CIVIL
  // Never less than twilight in February.
  expect feb-twilight.always-light

  feb-astro := sunrise-sunset feb-1 TROLL-STATION-LONGITUDE TROLL-STATION-LATITUDE ASTRONOMICAL
  // No stargazing at Troll Station in February.
  expect feb-astro.always-light

  jul-1 ::= Time.parse "2021-07-01T12:00:00Z"

  july-sun := sunrise-sunset jul-1 TROLL-STATION-LONGITUDE TROLL-STATION-LATITUDE GEOMETRIC
  expect july-sun.always-dark

poles-2021:
  fool ::= Time.parse      "2021-04-01T12:00:00Z"  // April fool's day
  halloween ::= Time.parse "2021-10-31T12:00:00Z"
  march-equinox := Time.parse "2021-03-21T12:00:00Z"  // March equinox.
  september-equinox := Time.parse "2021-09-21T12:00:00Z"  // September equinox.

  NORTH-POLE := 90.0
  SOUTH-POLE := -90.0

  fool-sun := sunrise-sunset fool                0.0 90.0 GEOMETRIC
  spooky-sun := sunrise-sunset halloween         0.0 90.0 GEOMETRIC
  spring-sun := sunrise-sunset march-equinox     0.0 90.0 GEOMETRIC
  autumn-sun := sunrise-sunset september-equinox 0.0 90.0 GEOMETRIC

  // No sunsets or sunrises on the North Pole on a random day.
  expect-equals null fool-sun.sunrise
  expect-equals null fool-sun.sunset
  expect-equals null spooky-sun.sunrise
  expect-equals null spooky-sun.sunset
  expect-equals null spring-sun.sunrise
  expect-equals null spring-sun.sunset
  expect-equals null autumn-sun.sunrise
  expect-equals null autumn-sun.sunset

  fool-sun = sunrise-sunset fool                0.0 -90.0 GEOMETRIC
  spooky-sun = sunrise-sunset halloween         0.0 -90.0 GEOMETRIC
  spring-sun = sunrise-sunset september-equinox 0.0 -90.0 GEOMETRIC
  autumn-sun = sunrise-sunset march-equinox     0.0 -90.0 GEOMETRIC

  // No sunsets or sunrises on the South Pole on a random day.
  expect-equals null fool-sun.sunrise
  expect-equals null fool-sun.sunset
  expect-equals null spooky-sun.sunrise
  expect-equals null spooky-sun.sunset
  expect-equals null spring-sun.sunrise
  expect-equals null spring-sun.sunset
  expect-equals null autumn-sun.sunrise
  expect-equals null autumn-sun.sunset

check-declination:
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
    decl = radians-to-degrees decl
    decl %= 360.0
    expect CORRECT[y] - 0.01 < decl < CORRECT[y] + 0.01

radians-to-degrees radians/num -> float:
  return radians / math.PI * 180.0

degrees-to-radians degrees/num -> float:
  return degrees * math.PI / 180.0

main2:
  expect-equals
    0.0
    days-since-2000 (Time.parse "2000-01-01T12:00:00Z")
  expect-equals
    1.0
    days-since-2000 (Time.parse "2000-01-02T12:00:00Z")
  expect-equals
    -1.0
    days-since-2000 (Time.parse "1999-12-31T12:00:00Z")
  expect-equals
    0.5
    days-since-2000 (Time.parse "2000-01-02T00:00:00Z")
  expect-equals
    365.5  // Leap year.
    days-since-2000 (Time.parse "2001-01-01T00:00:00Z")

  end-of-april := Time.parse "2021-04-30T03:48:00Z"
  expect-equals
    7790.0 - 9.0 / 24 + 48.0 / (24 * 60)
    days-since-2000 end-of-april

  expect-equals
    2451545 + (days-since-2000 end-of-april)
    julian-day end-of-april

  accurate := radians-to-degrees
      declination end-of-april
  print "Accurate: $(%0.8f accurate)"
  // https://gml.noaa.gov/grad/solcalc/ says 14.8 degrees.
  expect 14.75 <= accurate < 14.85

  start-of-october := Time.parse "2049-10-01T14:41:49Z"
  october-declination := radians-to-degrees
      declination start-of-october

  print "October: $(%0.8f october-declination)"
  // https://gml.noaa.gov/grad/solcalc/ says -3.51 degrees.
  expect -3.515 <= october-declination < -3.505

  birthday := Time.parse "1969-05-27T12:55:00Z"
  birthday-declination := radians-to-degrees
      declination birthday

  print "May: $(%0.8f birthday-declination)"
  // https://gml.noaa.gov/grad/solcalc/ says 21.32 degrees.
  expect 21.315 <= birthday-declination < 21.325

  print "89: $(%0.3f elevation-correction (degrees-to-radians 89.0))"
  print "86: $(%0.3f radians-to-degrees (elevation-correction (degrees-to-radians 86.0)))"
  print "85: $(%0.3f radians-to-degrees (elevation-correction (degrees-to-radians 85.0)))"
  print "84: $(%0.3f radians-to-degrees (elevation-correction (degrees-to-radians 84.0)))"
  print "5.01: $(%0.3f radians-to-degrees (elevation-correction (degrees-to-radians 5.01)))"
  print "5.00: $(%0.3f radians-to-degrees (elevation-correction (degrees-to-radians 5.00)))"
  print "4.99: $(%0.3f radians-to-degrees (elevation-correction (degrees-to-radians 4.99)))"
  print "4.0: $(%0.3f radians-to-degrees (elevation-correction (degrees-to-radians 4.0)))"
  print "3.0: $(%0.3f radians-to-degrees (elevation-correction (degrees-to-radians 3.0)))"
  print "2.0: $(%0.3f radians-to-degrees (elevation-correction (degrees-to-radians 2.0)))"
  print "1.0: $(%0.3f radians-to-degrees (elevation-correction (degrees-to-radians 1.0)))"
  print "0.0: $(%0.3f radians-to-degrees (elevation-correction (degrees-to-radians 0.0)))"
  print "-0.5: $(%0.3f radians-to-degrees (elevation-correction (degrees-to-radians -0.5)))"
  print "-0.574: $(%0.3f radians-to-degrees (elevation-correction (degrees-to-radians -0.574)))"
  print "-0.575: $(%0.3f radians-to-degrees (elevation-correction (degrees-to-radians -0.575)))"
  print "-0.576: $(%0.3f radians-to-degrees (elevation-correction (degrees-to-radians -0.576)))"
  print "-0.6: $(%0.3f radians-to-degrees (elevation-correction (degrees-to-radians -0.6)))"
  print "-1.0: $(%0.3f radians-to-degrees (elevation-correction (degrees-to-radians -1.0)))"
  print "-2.0: $(%0.3f radians-to-degrees (elevation-correction (degrees-to-radians -2.0)))"
  print "-3.0: $(%0.3f radians-to-degrees (elevation-correction (degrees-to-radians -3.0)))"
  print "-4.0: $(%0.3f radians-to-degrees (elevation-correction (degrees-to-radians -4.0)))"
  print "-5.0: $(%0.3f radians-to-degrees (elevation-correction (degrees-to-radians -5.0)))"
  print "-6.0: $(%0.3f radians-to-degrees (elevation-correction (degrees-to-radians -6.0)))"
  print "-12.0: $(%0.3f radians-to-degrees (elevation-correction (degrees-to-radians -12.0)))"
  print "-18.0: $(%0.3f radians-to-degrees (elevation-correction (degrees-to-radians -18.0)))"
  print "-89.9: $(%0.3f radians-to-degrees (elevation-correction (degrees-to-radians -89.9)))"
  print "-90.0: $(%0.3f radians-to-degrees (elevation-correction (degrees-to-radians -90.0)))"

  noon := Time.parse "2021-04-30T12:00:00Z"
  print-times noon TRANBJERG-LONGITUDE TRANBJERG-LATITUDE GEOMETRIC     "   Geometric"
  print-times noon TRANBJERG-LONGITUDE TRANBJERG-LATITUDE CIVIL         "       Civil"
  print-times noon TRANBJERG-LONGITUDE TRANBJERG-LATITUDE NAUTICAL      "    Nautical"
  print-times noon TRANBJERG-LONGITUDE TRANBJERG-LATITUDE ASTRONOMICAL  "Astronomical"

print-times noon-time/Time longitude/float latitude/float type/num name/string -> none:
  // First we get the sunset/sunrise times with the time of year based on
  // the day.
  times := sunrise-sunset noon-time longitude latitude type
  unrefined-sunrise := times.sunrise
  unrefined-sunset := times.sunset
  if unrefined-sunrise:
    // Get a more refined sunrise time where we determine the time of year based
    // on the first, unrefined sunrise time.
    times-2 := sunrise-sunset noon-time --time=unrefined-sunrise longitude latitude type
    sunrise := times-2.sunrise
    if sunrise:
      print "Sunrise ($name): $sunrise.utc"
    else:
      print "Sunrise ($name): none"
  if unrefined-sunset:
    // Get a more refined sunset time where we determine the time of year based
    // on the first, unrefined sunset time.
    times-2 := sunrise-sunset noon-time --time=unrefined-sunset longitude latitude type
    sunset := times-2.sunset
    if sunset:
      print "Sunset  ($name): $sunset.utc"
    else:
      print "Sunset  ($name): none"
