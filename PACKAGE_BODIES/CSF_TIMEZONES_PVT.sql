--------------------------------------------------------
--  DDL for Package Body CSF_TIMEZONES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_TIMEZONES_PVT" AS
/* $Header: CSFDCTZB.pls 120.0 2005/05/24 18:09:53 appldev noship $ */

  -------------------------------------------------------------------------
  -- global package variables
  -------------------------------------------------------------------------
  g_server_tz  varchar2(300) := null;
  g_client_tz  varchar2(300) := null;
  g_tz_enabled varchar2(1)   ;

  -------------------------------------------------------------------------
  -- forward declaration of private functions
  -------------------------------------------------------------------------
  PROCEDURE init;

  -------------------------------------------------------------------------
  -- public functions
  -------------------------------------------------------------------------

  FUNCTION get_server_tz_code return varchar2
  IS
  BEGIN
    return g_server_tz;
  END get_server_tz_code;

  FUNCTION get_client_tz_code return varchar2
  IS
  BEGIN
    return g_client_tz;
  END get_client_tz_code;

  FUNCTION tz_enabled return varchar2
  IS
  BEGIN
    return g_tz_enabled;
  END tz_enabled;

  -- when p_client_tz is set, then user profile will
  -- be overridden
  FUNCTION date_to_client_tz_chardt
  ( p_dateval in date ) return varchar2
  IS
  BEGIN
    return fnd_date.date_to_displaydt(p_dateval);
  END date_to_client_tz_chardt;

  FUNCTION date_to_client_tz_chartime
  ( p_dateval in date
  , p_mask    in varchar2 default null ) return varchar2
  IS
    l_dateval date := null;
  BEGIN
    -- convert server date into client date
    l_dateval := date_to_client_tz_date(p_dateval);
    return to_char(l_dateval, nvl(p_mask,'hh24:mi'));
  END date_to_client_tz_chartime;

  FUNCTION date_to_client_tz_date
  ( p_dateval in date ) return date
  IS
    l_chardt  varchar2(300) := null;
  BEGIN
    -- convert to client time
    l_chardt := date_to_client_tz_chardt(p_dateval);
    -- convert back to date value without tz conversion
    return fnd_date.displaydt_to_date(l_chardt,g_server_tz);
  END date_to_client_tz_date;

  FUNCTION date_to_server_tz_date
  ( p_dateval in date ) return date
  IS
    l_server_cur_time date := null;
    l_client_cur_time date := null;
    l_offset          number := null;
  BEGIN
    l_server_cur_time := sysdate;
    l_client_cur_time := date_to_client_tz_date(l_server_cur_time);
    l_offset := l_server_cur_time - l_client_cur_time;
    return p_dateval + l_offset;
  END date_to_server_tz_date;

  -------------------------------------------------------------------------
  -- forward declaration of private functions
  -------------------------------------------------------------------------
  PROCEDURE init
  IS
  BEGIN
    g_server_tz := fnd_timezones.get_server_timezone_code;
    g_client_tz := fnd_timezones.get_client_timezone_code;
    g_tz_enabled := 'N';

    -- this function is currently not present in fnd_timezones 1158
    -- copied from AFTZONEB.pls 115.3 and modified
    if  nvl(fnd_profile.value('ENABLE_TIMEZONE_CONVERSIONS'),'N') = 'Y'
    and g_server_tz is not null
    and g_client_tz is not null
    then
      -- flag initiated as 'N'
      g_tz_enabled := 'Y';
    end if;
  END init;

BEGIN
  init;
END csf_timezones_pvt;

/
