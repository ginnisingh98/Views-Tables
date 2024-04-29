--------------------------------------------------------
--  DDL for Package Body FND_DATE_TZ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_DATE_TZ" AS
/* $Header: AFDATTZB.pls 115.4 2003/10/28 16:03:56 psloan ship $ */

PROCEDURE init_timezones_for_fnd_date IS
  BEGIN
    init_timezones_for_fnd_date(true);
  END;


function is_9i_db return varchar2 is
 cursor c1 is
   select 'x'
   from all_objects
   where object_name = 'V$TIMEZONE_NAMES'
     and owner = 'PUBLIC';
 v_dummy varchar2(1);

  begin
   open c1;
   fetch c1 into v_dummy;
   close c1;
   if v_dummy = 'x' then
     return 'Y';
   else
     return 'F';
   end if;
  end;

procedure init_timezones_for_fnd_date(v_enabled boolean) is
  begin
    if v_enabled then
      fnd_date.timezones_enabled := true;
      fnd_date.server_timezone_code := fnd_timezones.get_server_timezone_code;
      fnd_date.client_timezone_code := fnd_timezones.get_client_timezone_code;
    else
      fnd_date.timezones_enabled := false;
      fnd_date.server_timezone_code := null;
      fnd_date.client_timezone_code := null;
    end if;
  end;

END fnd_date_tz;

/
