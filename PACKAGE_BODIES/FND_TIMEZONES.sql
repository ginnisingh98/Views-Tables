--------------------------------------------------------
--  DDL for Package Body FND_TIMEZONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_TIMEZONES" AS
/* $Header: AFTZONEB.pls 115.3 2002/03/01 11:32:40 pkm ship    $ */
  function get_code(tz_id in number) return varchar2 is
    cursor c1 is
      select timezone_code
      from fnd_timezones_b
      where upgrade_tz_id = tz_id;
    v_tz_code varchar2(50);
  begin
    if tz_id is not null then
      open c1;
      fetch c1 into v_tz_code;
      close c1;
    end if;
    return v_tz_code;
  end;


  function get_name(tz_code in varchar2) return varchar2 is
    cursor c1 is
    select name
    from   fnd_timezones_vl
    where timezone_code = tz_code;

    v_tz_name varchar2(80);
  begin
    if tz_code is not null then
      open c1;
      fetch c1 into v_tz_name;
      close c1;
    end if;
    return v_tz_name;
  end;

  function get_server_timezone_code return varchar2 is
  begin
    return get_code(fnd_profile.VALUE ('SERVER_TIMEZONE_ID'));
  end;

  function get_client_timezone_code return varchar2 is
  begin
    return get_code(fnd_profile.VALUE ('CLIENT_TIMEZONE_ID'));
  end;

  function get_timezone_enabled_flag return varchar2 is
  begin
    return nvl(fnd_profile.VALUE ('ENABLE_TIMEZONE_CONVERSIONS'),'N');
  end;

  FUNCTION timezones_enabled RETURN VARCHAR2
   IS
      return_flag   VARCHAR2 (1) := 'N';
   BEGIN
      return_flag := 'N';
      IF get_timezone_enabled_flag = 'Y'
        and get_server_timezone_code IS not NULL
        and get_client_timezone_code IS not NULL THEN
           return_flag := 'Y';
      END IF;

      RETURN return_flag;
   END timezones_enabled;

END fnd_timezones;

/
