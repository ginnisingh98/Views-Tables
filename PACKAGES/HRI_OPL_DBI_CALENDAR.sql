--------------------------------------------------------
--  DDL for Package HRI_OPL_DBI_CALENDAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OPL_DBI_CALENDAR" AUTHID CURRENT_USER AS
/* $Header: hriodcal.pkh 120.0 2005/05/29 07:27:50 appldev noship $ */

PROCEDURE load_calendars(errbuf   OUT NOCOPY  VARCHAR2,
                         retcode  OUT  NOCOPY VARCHAR2);

PROCEDURE load_calendars;

PROCEDURE update_calendars(errbuf   OUT NOCOPY  VARCHAR2,
                           retcode  OUT  NOCOPY VARCHAR2);

PROCEDURE update_calendars;

END hri_opl_dbi_calendar;

 

/
