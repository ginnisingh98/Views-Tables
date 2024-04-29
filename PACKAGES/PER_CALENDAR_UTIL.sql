--------------------------------------------------------
--  DDL for Package PER_CALENDAR_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CALENDAR_UTIL" AUTHID CURRENT_USER AS
  /* $Header: pecalutl.pkh 120.0.12010000.4 2008/11/19 07:24:13 osamvats noship $ */

  -- Returns ICalendar format varchar2.
  -- To be called when time is available as date object.
  PROCEDURE CALENDAR_GENERATE_ICAL
    (DTSTARTDATE	IN		 DATE
    ,DTENDDATE 		IN		 DATE
    ,DTSTARTTIME 	IN 		 DATE   DEFAULT NULL
    ,DTENDTIME		IN		 DATE   DEFAULT NULL
    ,SUBJECT            IN             VARCHAR2 DEFAULT NULL
    ,LOCATION           IN             VARCHAR2 DEFAULT NULL
    ,DESCRIPTION        IN             VARCHAR2 DEFAULT NULL
    ,ACCESS             IN             VARCHAR2 DEFAULT 'PUBLIC'
    ,TIMEZONE           IN             VARCHAR2	DEFAULT NULL
    ,METHOD 	        IN 	       VARCHAR2 DEFAULT 'PUBLISH'
    ,IGNORE_TIME_ZONE   IN             BOOLEAN  DEFAULT FALSE
    ,MAIL_TO 	        IN 	       VARCHAR2 DEFAULT NULL
    ,ICAL	        OUT NOCOPY     VARCHAR2
    ,PRIMARY_KEY IN VARCHAR2 DEFAULT NULL
    );

  -- Returns ICalendar format varchar2.
  -- To be called when time is available as varchar2
  PROCEDURE CALENDAR_GENERATE_ICAL
    (DTSTARTDATE	IN		 DATE
    ,DTENDDATE 		IN		 DATE
    ,DTSTARTTIME 	IN 		 VARCHAR2
    ,DTENDTIME		IN		 VARCHAR2
    ,DTTIMEFORMAT       IN 		 VARCHAR2 DEFAULT NULL
    ,SUBJECT            IN             VARCHAR2 DEFAULT NULL
    ,LOCATION           IN             VARCHAR2 DEFAULT NULL
    ,DESCRIPTION        IN             VARCHAR2 DEFAULT NULL
    ,ACCESS            IN              VARCHAR2 DEFAULT 'PUBLIC'
    ,TIMEZONE           IN             VARCHAR2	DEFAULT NULL
    ,METHOD 	        IN 	       VARCHAR2 DEFAULT 'PUBLISH'
    ,IGNORE_TIME_ZONE   IN             BOOLEAN  DEFAULT FALSE
    ,MAIL_TO 	        IN 	       VARCHAR2 DEFAULT NULL
    ,ICAL	        OUT NOCOPY     VARCHAR2
    ,PRIMARY_KEY IN VARCHAR2 DEFAULT NULL
    );



END PER_CALENDAR_UTIL;

/
