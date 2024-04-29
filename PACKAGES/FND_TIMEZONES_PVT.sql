--------------------------------------------------------
--  DDL for Package FND_TIMEZONES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_TIMEZONES_PVT" AUTHID CURRENT_USER as
/* $Header: AFTZPVTS.pls 115.1 2002/02/21 14:25:08 pkm ship    $ */

  function adjust_datetime(date_time date
                          ,from_tz varchar2
                          ,to_tz   varchar2) return date;
  PRAGMA restrict_references(adjust_datetime, WNDS, WNPS, RNDS);
end fnd_timezones_pvt;

 

/
