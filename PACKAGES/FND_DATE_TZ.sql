--------------------------------------------------------
--  DDL for Package FND_DATE_TZ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_DATE_TZ" AUTHID CURRENT_USER as
/* $Header: AFDATTZS.pls 115.4 2003/10/28 16:03:43 psloan ship $ */

-- sends all the necessary information to the fnd_date package so it
-- can calculate the timezone conversions.
-- this assumes that fnd_timezones.timezones_enabled() has been run and returns a 'Y'.
-- init_timezones_for_fnd_date does not do any validation or error checking.
   PROCEDURE init_timezones_for_fnd_date;

-- returns 'Y' if running in a 9i db with the v$timezone_names table
-- available.   This is not an speedy call and should only be called in low volumes.
-- ie. at forms startup etc..
   function is_9i_db return varchar2;

-- overlaoding init_timezones_for_fnd_date so that it will accept a boolean to
-- indicate if timezones should be initialized for fnd_date
-- this way timezone support can be turned on or off.
   procedure init_timezones_for_fnd_date(v_enabled boolean);

END fnd_date_tz;

 

/
