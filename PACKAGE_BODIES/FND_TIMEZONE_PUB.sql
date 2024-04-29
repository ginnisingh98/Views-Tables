--------------------------------------------------------
--  DDL for Package Body FND_TIMEZONE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_TIMEZONE_PUB" as
/* $Header: AFTZPUBB.pls 120.0 2006/08/21 05:58:48 appldev noship $ */

  function adjust_datetime(date_time date
                          ,from_tz varchar2
                          ,to_tz varchar2) return date is
    return_date date;
  begin
     return_date := fnd_timezones_pvt.adjust_datetime(date_time, from_tz, to_tz);
     return return_date;
  end adjust_datetime;

end fnd_timezone_pub;

/
