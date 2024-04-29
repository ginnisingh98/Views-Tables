--------------------------------------------------------
--  DDL for Package FND_TIMEZONE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_TIMEZONE_PUB" AUTHID CURRENT_USER as
/* $Header: AFTZPUBS.pls 120.0 2006/08/21 05:56:23 appldev noship $ */

  function adjust_datetime(date_time date
                          ,from_tz varchar2
                          ,to_tz   varchar2) return date;
  PRAGMA restrict_references(adjust_datetime, WNDS, WNPS, RNDS);
end fnd_timezone_pub;

 

/
