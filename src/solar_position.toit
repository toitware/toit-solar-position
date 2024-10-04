// Copyright (C) 2021 Toitware ApS.  All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import math show *

/**
Describes sunrise and sunset for a given date.
*/
class Transitions:
  /// The time of sunrise, or null if the Sun does not rise.
  sunrise /Time?

  /// The time of sunset, or null if the Sun does not set.
  sunset /Time?

  constructor .sunrise/Time .sunset/Time:
    dark_ = null

  constructor.dark:
    sunset = null
    sunrise = null
    dark_ = true

  constructor.light:
    sunset = null
    sunrise = null
    dark_ = false

  dark_ /bool?

  /// Whether the Sun is below the horizon the entire day.
  always-dark -> bool:
    return not sunrise and dark_

  /// Is the Sun above the horizon the entire day.
  always-light -> bool:
    return not sunset and not dark_

  stringify -> string:
    if always-light: return "Always light"
    if always-dark: return "Always dark"
    return "Sunrise: $sunrise, Sunset: $sunset"

/**
The position of the Sun in the sky.
*/
class SolarPosition:
  /**
  The angle between the Sun's rays and the horizontal.  This is around
    zero at sunrise and sunset, and is at its highest around noon.
  The value will always be between 0 and PI/2 radians.
  */
  elevation-radians /float

  /**
  The angle between the Sun's rays and the horizontal.  This is around
    zero at sunrise and sunset, and is at its highest around noon.
  The value will always be between 0 and 90 degrees.
  */
  elevation-degrees -> float:
    return radians-to-degrees_ elevation-radians

  /**
  The compass source of the Sun's rays.  This is in the West (somewhere
    around 3/2 PI radians) in the morning, and in the East (somewhere around PI/2
    radians) in the evening.  North of the Tropic of Cancer it is in the
    South in the middle of the day (somewhere around PI radians), while South of
    the Tropic of Capricorn it is in the North in the middle of the day
    (somewhere around 0 radians).  In the Tropics it may be in the North or the
    South in the middle of the day, depending on the time of year.
  */
  azimuth-radians /float

  noaa-adjusted-elevation /bool

  /**
  The compass source of the Sun's rays.  This is in the West (somewhere
    around 270 degrees) in the morning, and in the East (somewhere around 90
    degrees) in the evening.  North of the Tropic of Cancer it is in the
    South in the middle of the day (somewhere around 180 degrees), while South of
    the Tropic of Capricorn it is in the North in the middle of the day
    (somewhere around 0 degrees).  In the Tropics it may be in the North or the
    South in the middle of the day, depending on the time of year.
  */
  azimuth-degrees -> float:
    return radians-to-degrees_ azimuth-radians

  /**
  Whether the Sun is below the minimum elevation for astronomical dusk/dawn.
  */
  astronomical-night -> bool:
    return elevation-degrees < ASTRONOMICAL

  /**
  Whether the Sun is below the minimum elevation for nautical dusk/dawn.
  */
  nautical-night -> bool:
    return elevation-degrees < NAUTICAL

  /**
  Whether Sun is below the minimum elevation for civil dusk/dawn.
  */
  civil-night -> bool:
    return elevation-degrees < CIVIL

  /**
  Whether the elevation of the Sun is under the horizon.
  If this object was generated using the NOAA model to adjust the
    apparent elevation of the Sun then this method returns whether
    the apparent elevation is less than 0 degrees.
  If this object was generated without taking the refraction of
    the atmosphere into account then a standard refraction correction
    of 0.833 degrees is used here to determine whether it is night.
  */
  night -> bool:
    if noaa-adjusted-elevation:
      return elevation-radians < 0.0
    else:
      return elevation-degrees < -0.833

  constructor .azimuth-radians/float .elevation-radians/float --noaa-elevation-correction/bool:
    noaa-adjusted-elevation = noaa-elevation-correction

SIN-AXIAL-TILT_ ::= sin
  23.44 / 180.0 * PI
NANOSECONDS-PER-DAY_ ::= Duration.NANOSECONDS-PER-HOUR * 24.0
LEAPSECOND-ADJUSTMENT_ ::= 0.0008  // In days.
TWO-PI-RECIPROCAL_ ::= 1.0 / (2.0 * PI)

/// The basis of the J2000 epoch as a $Time instance.
NOON-2000 ::= Time.parse "2000-01-01T12:00:00Z"

/**
Julian day number - the number of days including fractional part
  since noon UTC on January 1, 4713 BC.
*/
julian-day time/Time -> float:
  ns := time.ns-since-epoch
  days := time.ns-since-epoch.to-float / Duration.NANOSECONDS-PER-HOUR / 24
  return days + 2440587.5

/**
J2000 day number - the number of days including fractional part
  since noon UTC on January 1, 2000.
*/
days-since-2000 time/Time -> float:
  seconds := (NOON-2000.to time).in-s
  return seconds / (24.0 * 60 * 60 )

/**
The declination of the Sun for a given time of year.
*/
declination time/Time -> float:
  return declination time --time=time --longitude=0.0: | mean-anomaly |
    null

/**
The declination of the Sun for a given time of year.
$noon should be the UTC noon for the day of interest.
$time should be a time in the same day for which the
  mean anomaly is wanted.
The declination doesn't change very much depending on the time of day
  and doesn't change much depending on the longitude, but these can be given
  for a more precise result or if the transit time is wanted.
The provided block is called with the transit time for the given
  longitude on that day.  This is the time at which the Sun is due South,
  (or due North in the Southern Hemisphere).
*/
declination noon/Time --time/Time=noon --longitude/num [block]-> float:
  fractional-days := days-since-2000 time
  // M = mean anomaly.
  mean-anomaly := degrees-to-radians_
    (357.5291 + 0.9856474 * fractional-days) % 360.0
  // Omega = 282.89 degrees (-77.11)
  // L = mean longitude = M + omega.
  // Some pages like https://en.wikipedia.org/wiki/Sunrise_equation and
  // https://www.astrouw.edu.pl/~jskowron/pracownia/praca/sunspot_answerbook_expl/expl-5.html
  // recommend a slightly smaller multiplier here, 0.98560, combined with a slightly larger
  // argument of the perihelion, -77.11 (282.89 degrees).  This seems to work OK if you reset
  // the calculation every year on January 1, but errors accumulate if you just count days
  // from 2000 like we do.  Instead we use the numbers from
  // https://en.wikipedia.org/wiki/Position_of_the_Sun

  // The two ways to calculate lambda on the Net are as follows:
  // lambda1:  Argument of Perihelion 280.46, multiplier 0.9856474
  // lambda2:  Argument of Perihelion 282.89, multiplier 0.98560

  // NOAA has a very accurate calculator that takes your century into
  // account.  For Lat 56.09 Longitude 10.1337 they give the following
  // declinations at 12 noon.
  //            NOAA   declination-lambda1  declination-lambda2
  //                            error                error
  // 2001-04-30 14.88  14.87    -0.01       14.87     0.00
  // 2011-04-30 14.75  14.74    -0.01       14.68    -0.06
  // 2021-04-30 14.93  14.92    -0.01       14.81    -0.11
  // 2031-04-30 14.8   14.79    -0.01       14.63    -0.16
  // 2041-04-30 14.98  14.97    -0.01       14.75    -0.22
  // 2051-04-30 14.85  14.84    -0.01       14.56    -0.28
  // 2061-04-30 15.02  15.02     0.00       14.69    -0.33
  // 2071-04-30 14.89  14.89     0.00       14.51    -0.38
  //
  // Clearly they are equivalent near the year 2000, but diverge more and more
  // later.  We therefore use the lambda1 method.
  mean-longitude-deg := (280.460 + 0.9856474 * fractional-days) % 360.0

  sin-mean-anomaly := sin mean-anomaly

  // Equation of the center without accounting for Century.
  equation-of-the-center-deg := 0.0
    + 1.9148 * sin-mean-anomaly
    + 0.0200 * (sin 2.0 * mean-anomaly)

  // lambda = L + C
  ecliptic-longitude := degrees-to-radians_
    mean-longitude-deg + equation-of-the-center-deg

  utc := noon.utc
  transit-basis := Time.utc --year=utc.year --month=utc.month --day=utc.day --h=12

  // Equation of time.
  transit := (days-since-2000 transit-basis)
    - longitude / 360.0
    + 0.0053 * sin-mean-anomaly
    - 0.0069 * (sin (2.0 * ecliptic-longitude))

  block.call NOON-2000 + (Duration --ns=(transit * NANOSECONDS-PER-DAY_).to-int)

  declination := asin SIN-AXIAL-TILT_ * (sin ecliptic-longitude)

  return declination

/**
For a given elevation of the Sun in radians, how much higher does it
  appear to be due to atmospheric refraction.  Formula from
  https://www.esrl.noaa.gov/gmd/grad/solcalc/calcdetails.html
This function returns 0.575 degrees (in radians) for an elevation of
  zero degrees.  Some sources prefer 0.833 degrees at this elevation.
  In practice the actual value depends on the weather.
Only returns non-negative values.
*/
elevation-correction elevation/num -> float:
  RADIANS-PER-ARCSECOND ::= PI / 180.0 / 3600.0
  DEG-85 ::= degrees-to-radians_ 85.0
  DEG-5 ::= degrees-to-radians_ 5.0
  DEG-M0-575 ::= degrees-to-radians_ -0.575
  DEG-M89-99 ::= degrees-to-radians_ -89.99
  if elevation > DEG-85:
    // 85 to 90 degrees.
    return 0.0
  if elevation > DEG-5:
    // 5 to 85 degrees.
    t := tan elevation
    result := 58.1 / t
    result -= 0.07 / (t * t * t)
    result += 0.000086 / (t * t * t * t * t)
    return result * RADIANS-PER-ARCSECOND
  if elevation > DEG-M0-575:
    // -0.575 to 5 degrees
    h := radians-to-degrees_ elevation
    result := 1735.0
    result -= 518.2 * h
    result += 103.4 * h * h
    result -= 12.79 * h * h * h
    result += 0.711 * h * h * h * h
    return result * RADIANS-PER-ARCSECOND
  if elevation > DEG-M89-99:
    // -89.99 to -0.575 degrees
    t := tan elevation
    return -020.774 * RADIANS-PER-ARCSECOND / t
  return 0.0

PI-DIV-180_ ::=            PI / 180.0
PI-DIV-180-RECIPROCAL_ ::= 180.0 / PI

radians-to-degrees_ radians/num -> float:
  return radians * PI-DIV-180-RECIPROCAL_

degrees-to-radians_ degrees/num -> float:
  return degrees * PI-DIV-180_

/// The type for sunrise_sunset for the boundary between day and civil twilight.
GEOMETRIC := 0.0
/// The type for sunrise_sunset for the boundary between civil twilight and nautical twilight.
CIVIL := -6.0
/// The type for sunrise_sunset for the boundary between nautical twilight and astronomical twilight.
NAUTICAL := -12.0
/// The type for sunrise_sunset for the boundary between astronomical twilight and night.
ASTRONOMICAL := -18.0

/**
Variant of $sunrise-sunset that takes a date as three ints.
*/
sunrise-sunset year/int month/int day/int longitude/num latitude/num type/num=0.0 --noaa-elevation-correction/bool=false -> Transitions:
  time := Time.utc year month day 12
  return sunrise-sunset time --time=time longitude latitude type --noaa-elevation-correction=noaa-elevation-correction

/**
Returns an instance of the $Transitions class containing the sunrise and
  sunset times for the given day at the given location.  The location is
  given as $longitude and $latitude in degrees (East and North are positive).
The time will normally be noon UTC on the day of interest.  For a slightly
  more accurate result, especially near the Arctic or Antarctic circles
  you can additionally specify a time near the actual sunset/sunrise, in
  which case that part of the result will have slightly improved accuracy.
The sunset doesn't happen until the Sun is physically below the horizon.  How
  far below it needs to go depends on the type of sunset.
  Type is 0, -6, -12 or -18 for geometric, civil, nautical, or astronomical.
  Default is the simple sunrise/sunset where the center of the Sun aligns
  with the horizon.
On a day and location where the Sun does not rise or set, both of the
  times are null.
The calculation compensates for the refraction caused by the curvature of the
  atmosphere relative to the Sun's rays.  By default it considers the Sun to
  have set when it is actually 0.833 degrees under the horizon.  Use
  --noaa_elevation_correction to get the slightly smaller correction given by
  $elevation-correction.
In practice the refraction depends on the weather, so it is merely an
  approximation.  No correction is applied by default for civil, nautical,
  and astronomical dusk.
*/
sunrise-sunset noon/Time --time/Time=noon longitude/num latitude/num type/num=0.0 --noaa-elevation-correction/bool=false -> Transitions:
  transit := null
  decl := declination noon --time=time --longitude=longitude: | tr |
    transit = tr
  latitude-rad := degrees-to-radians_ latitude
  sin-sin := (sin latitude-rad) * (sin decl)
  cos-cos := (cos latitude-rad) * (cos decl)
  // subhorizon_angle is thus always negative, and in radians.
  correction/float := ?
  if noaa-elevation-correction:
    correction = elevation-correction (degrees-to-radians_ type)
  else:
    correction = type == 0 ? (degrees-to-radians_ 0.833) : 0.0
  subhorizon-angle ::= (degrees-to-radians_ type) - correction
  acos-input := ((sin subhorizon-angle) - sin-sin) / cos-cos
  if acos-input < -1.0: return Transitions.light
  else if acos-input > 1.0: return Transitions.dark
  else if acos-input.is-nan: return Transitions.light
  half-day := (acos acos-input) * TWO-PI-RECIPROCAL_  // Time in days from solar noon to sunrise/sunset.
  half-duration := Duration --ns=(half-day * NANOSECONDS-PER-DAY_).to-int
  sunrise := transit - half-duration
  sunset := transit + half-duration
  return Transitions sunrise sunset

/**
The position of the sun at a given time and place.
The elevation is not corrected for the refraction of the atmosphere near the
  horizon.  If this is desired set $noaa-elevation-correction to be true.
*/
solar-position time/Time longitude/num latitude/num --noaa-elevation-correction/bool=false -> SolarPosition:
  hour-angle := 0.0
  decl := declination time --longitude=longitude: | transit |
    difference := transit.to time
    // The Earth rotates one degree each 240 seconds.
    hour-angle = difference.in-ms / 240_000.0

  if hour-angle < -180: hour-angle += 360
  if hour-angle > 180: hour-angle -= 360

  hour-angle = degrees-to-radians_ hour-angle

  latitude-rad := degrees-to-radians_ latitude
  sin-decl := sin decl
  cos-decl := cos decl
  sin-latitude := sin latitude-rad
  cos-latitude := cos latitude-rad
  cos-hour-angle := cos hour-angle

  sin-sin := sin-latitude * sin-decl
  cos-cos-cos := cos-decl * cos-latitude * cos-hour-angle

  asin-input := sin-sin + cos-cos-cos

  elevation := asin asin-input

  sin-cos := sin-decl * cos-latitude
  cos-cos-sin := cos-hour-angle * cos-decl * sin-latitude

  acos-input := (sin-cos - cos-cos-sin) / (cos elevation)

  azimuth /float := ?

  azimuth = (-1.0 <= acos-input <= 1.0) ? (acos acos-input) : 0.0
  if hour-angle > 0:
    azimuth = 2 * PI - azimuth

  if noaa-elevation-correction:
    elevation += elevation-correction elevation

  return SolarPosition azimuth elevation --noaa-elevation-correction=noaa-elevation-correction
