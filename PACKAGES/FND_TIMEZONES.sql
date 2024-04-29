--------------------------------------------------------
--  DDL for Package FND_TIMEZONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_TIMEZONES" AUTHID CURRENT_USER AS
/* $Header: AFTZONES.pls 115.1 2002/02/21 14:25:05 pkm ship    $ */

  -- returns the code for a given id
  function get_code(tz_id in number) return varchar2;

  -- returns the translated name for a given code
  function get_name(tz_code in varchar2) return varchar2;

  -- returns the server timezone_code
  function get_server_timezone_code return varchar2;

  -- returns the client timezone_code
  function get_client_timezone_code return varchar2;

  -- returns 'Y' or 'N' if timezones should be enabled or not
  function get_timezone_enabled_flag return varchar2;

  -- returns 'Y' is the master switch for TZ is on and both the
  -- server/client timzone_id's are not null
  function timezones_enabled  RETURN VARCHAR2;

END fnd_timezones;

 

/
