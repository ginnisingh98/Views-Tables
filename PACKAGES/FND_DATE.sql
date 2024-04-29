--------------------------------------------------------
--  DDL for Package FND_DATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_DATE" AUTHID CURRENT_USER as
/* $Header: AFDDATES.pls 120.1.12010000.8 2016/07/19 17:55:13 emiranda ship $ */


  canonical_mask    varchar2(15) := 'YYYY/MM/DD';
  canonical_DT_mask varchar2(26) := 'YYYY/MM/DD HH24:MI:SS';
  name_in_mask      varchar2(15) := 'DD-MON-YYYY';
  name_in_DT_mask   varchar2(26) := 'DD-MON-YYYY HH24:MI:SS';
  nls_mask       varchar2(20);
  nls_DT_mask    varchar2(40);
-- It's possible to specify multiple masks seperated
-- by a '|' so the user masks need to be longer.

  user_mask  varchar2(100);
  userDT_mask  varchar2(200);
  output_mask  varchar2(20);
  outputDT_mask  varchar2(40);

-- Initialization routine

  procedure initialize(
  p_user_mask varchar2,
  p_userDT_mask varchar2 default NULL);

-- Date/DisplayDate functions - covers on the now obsolete Date/CharDate
-- functions.  These functions are used to convert a date to and from
-- the display format.

  function displaydate_to_date(
    chardate varchar2)
  return date;
  PRAGMA restrict_references(displaydate_to_date, WNDS, WNPS, RNDS);

  function displayDT_to_date(
    charDT varchar2)
  return date;
  PRAGMA restrict_references(displayDT_to_date, WNDS, WNPS, RNDS);

  function date_to_displaydate(
    dateval date)
  return varchar2;
  PRAGMA restrict_references(date_to_displaydate, WNDS, WNPS, RNDS);

  function date_to_displayDT(
    dateval date)
  return varchar2;
  PRAGMA restrict_references(date_to_displayDT, WNDS, WNPS, RNDS);

-- Date/CharDate functions

  function chardate_to_date(
    chardate varchar2)
  return date;
  PRAGMA restrict_references(chardate_to_date, WNDS, WNPS, RNDS);

  function charDT_to_date(
    charDT varchar2)
  return date;
  PRAGMA restrict_references(charDT_to_date, WNDS, WNPS, RNDS);

  function date_to_chardate(
    dateval date)
  return varchar2;
  PRAGMA restrict_references(date_to_chardate, WNDS, WNPS, RNDS);

  function date_to_charDT(
    dateval date)
  return varchar2;
  PRAGMA restrict_references(date_to_charDT, WNDS, WNPS, RNDS);

-- Canonical functions

  function canonical_to_date(
    canonical varchar2)
  return date;
  PRAGMA restrict_references(canonical_to_date, WNDS, WNPS, RNDS);

  function date_to_canonical(
    dateval date)
  return varchar2;
  PRAGMA restrict_references(date_to_canonical, WNDS, WNPS, RNDS);

  --
  -- This function converts the given string to date
  -- by using the given date mask, and trying
  -- several language settings.
  -- Language is important if the mask has 'MON' or
  -- similar language dependent fragments.
  --
  FUNCTION string_to_date(p_string IN VARCHAR2,
        p_mask   IN VARCHAR2)
    RETURN DATE;
  PRAGMA restrict_references(string_to_date, WNDS, WNPS, RNPS);

  --
  -- This function is similar to string_to_date
  -- but it returns the result in canonical_DT_mask format.
  --
  FUNCTION string_to_canonical(p_string IN VARCHAR2,
             p_mask   IN VARCHAR2)
    RETURN VARCHAR2;
  PRAGMA restrict_references(string_to_canonical, WNDS, WNPS);


-- Test procedure - used to verify functionality
  procedure test;

 -- TZ*
 -- private TZ variables
 -- DO NOT user outside of fnd_date.

  server_timezone_code varchar2(50);
  client_timezone_code varchar2(50);

  timezones_enabled boolean;

  -- over loaded function for fake dates.
  -- pass in a new client timezone and over ride the default client timezone
  function displayDT_to_date(charDT varchar2,new_client_tz_code varchar2) return date;
  PRAGMA restrict_references(displayDT_to_date, WNDS, WNPS, RNDS);

  -- over loaded function for fake dates.
  -- pass in a new client timezone and over ride the default client timezone
  function date_to_displayDT(dateval date,new_client_tz_code varchar2) return varchar2;
  PRAGMA restrict_references(date_to_displayDT, WNDS, WNPS, RNDS);

  -- public version of call for adjust_datetime.
  function adjust_datetime(date_time date
                          ,from_tz varchar2
                          ,to_tz   varchar2) return date;
  PRAGMA restrict_references(adjust_datetime, WNDS, WNPS, RNDS);
  -- *TZ


  --Bug 9384487   Overloaded intialize procedure

  procedure initialize_with_calendar(
    p_user_mask varchar2,
    p_userDT_mask varchar2 default NULL,
    p_user_calendar varchar2 default 'GREGORIAN');


-- Bug 9734709 Added by non-Gregorian calendar support.
  user_calendar varchar2(20);
  is_non_gregorian boolean;
  calendar_aware_alt CONSTANT number :=2;
  calendar_aware CONSTANT number := 1;
  calendar_unaware CONSTANT number := 0;
  calendar_aware_default number := calendar_unaware;

  function calendar_awareness_profile(
    p_application_id    number) return varchar2;

-- Overloaded Date/DisplayDate functions - covers on the now obsolete Date/CharDate
-- functions.  These functions are used to convert a date to and from
-- the display format.  Supports calendar awareness

  function displaydate_to_date(
    chardate varchar2,
    calendar_aware number )
  return date;
  PRAGMA restrict_references(displaydate_to_date, WNDS, WNPS, RNDS);

  function displayDT_to_date(
    charDT varchar2,
    calendar_aware number )
  return date;
  PRAGMA restrict_references(displayDT_to_date, WNDS, WNPS, RNDS);

  function date_to_displaydate(
    dateval date,
    calendar_aware number )
  return varchar2;
  PRAGMA restrict_references(date_to_displaydate, WNDS, WNPS, RNDS);

  function date_to_displayDT(
    dateval date,
    calendar_aware number )
  return varchar2;
  PRAGMA restrict_references(date_to_displayDT, WNDS, WNPS, RNDS);

-- Date/CharDate functions

  function chardate_to_date(
    chardate varchar2,
    calendar_aware number )
  return date;
  PRAGMA restrict_references(chardate_to_date, WNDS, WNPS, RNDS);

  function charDT_to_date(
    charDT varchar2,
    calendar_aware number )
  return date;
  PRAGMA restrict_references(charDT_to_date, WNDS, WNPS, RNDS);

  function date_to_chardate(
    dateval date,
    calendar_aware number )
  return varchar2;
  PRAGMA restrict_references(date_to_chardate, WNDS, WNPS, RNDS);

  function date_to_charDT(
    dateval date,
    calendar_aware number )
  return varchar2;
  PRAGMA restrict_references(date_to_charDT, WNDS, WNPS, RNDS);

 -- over loaded function for fake dates.  Supports calendar awareness
  -- pass in a new client timezone and over ride the default client timezone
  function displayDT_to_date(charDT varchar2,
    new_client_tz_code varchar2,
    calendar_aware number ) return date;
  PRAGMA restrict_references(displayDT_to_date, WNDS, WNPS, RNDS);

  -- over loaded function for fake dates. Supports calendar awareness
  -- pass in a new client timezone and over ride the default client timezone
  function date_to_displayDT(dateval date,
    new_client_tz_code varchar2,
    calendar_aware number ) return varchar2;
  PRAGMA restrict_references(date_to_displayDT, WNDS, WNPS, RNDS);

-- Bug 19613037 ISO 8601 formatting and parsing functions.

  iso8601_mask varchar2(26) := 'YYYY-MM-DD"T"HH24:MI:SS"Z"';
  iso8601_mask_localtime varchar2(26) := 'YYYY-MM-DD"T"HH24:MI:SS';

  function date_to_iso8601(dateval in Date) return varchar2;

  function date_to_iso8601_localtime(dateval in Date) return varchar2;

  function iso8601_to_date(iso8601 varchar2) return date;

  -- Reset the LOCAL-CACHE value for server-time-zone to be
  -- reevaluated on the next execution, it will load
  -- the value from fnd_timezones.get_server_timezone_code
  --
  -- FOR INTERNAL USE ONLY BY ATG-DEVELOPMENT
  procedure reset_chk_serverTZ;

end FND_DATE;

/

  GRANT EXECUTE ON "APPS"."FND_DATE" TO "EBSBI";
