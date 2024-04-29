--------------------------------------------------------
--  DDL for Package Body FND_TIMEZONES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_TIMEZONES_PVT" as
/* $Header: AFTZPVTB.pls 120.1 2005/07/02 04:20:13 appldev ship $ */

-- this package body should only be installed in a 9i db.  It will not compile
-- or run in any db prior to 9i.
  function adjust_datetime(date_time date
                          ,from_tz varchar2
                          ,to_tz varchar2) return date is
    return_date date;
    add_hour number := 0;
    t_date date;
  begin
    t_date := date_time;
    if date_time is not null
     and from_tz is not null
     and to_tz is not null then
      <<try_again>>
      begin
        return_date :=  to_timestamp_tz(to_char(t_date,'YYYY-MM-DD HH24:MI:SS') || ' ' || from_tz,
                                        'YYYY-MM-DD HH24:MI:SS TZR') at time zone to_tz;
        -- exceptions handler to handle case where 'from' timezone datetime
        -- does not exist.  This will try to add one hour to the from time
        -- until 3 hours are reached or it no longer raises the error.
        -- also catches bug 2276107
        exception when others then
          if sqlcode in (-1878,-1891) then
           add_hour := add_hour +1;
           if add_hour > 3 then
             raise;
           else
             t_date := t_date + add_hour/24;
             goto try_again;
           end if;
         else
           raise;
         end if;
      end;
    else
      return_date := date_time;
    end if;
    return return_date;
  end adjust_datetime;

end fnd_timezones_pvt;

/
