--------------------------------------------------------
--  DDL for Package WIP_DATETIMES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_DATETIMES" AUTHID CURRENT_USER AS
/* $Header: wipdates.pls 115.8 2003/10/31 22:36:55 rlohani ship $ */

/* Converts a date varchar in canonical to a date varchar
   in user display format */
FUNCTION Cchar_to_Uchar(Cchar IN VARCHAR2) return VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Cchar_to_Uchar, WNDS, WNPS);

/* Converts a datetime varchar in canonical to a datetime
   varchar in user display format */
FUNCTION CcharDT_to_Uchar(CcharDT IN VARCHAR2) return VARCHAR2;
PRAGMA RESTRICT_REFERENCES(CcharDT_to_Uchar, WNDS, WNPS);

/* Converts a date varchar in canonical to a date[time] varchar
   in whatever format passed in by Ofmt_mask */
FUNCTION Cchar_to_char(Cchar IN VARCHAR2, Ofmt_mask IN VARCHAR2) return VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Cchar_to_char, WNDS, WNPS);

/* Converts a datetime varchar in canonical to a date[time] varchar
   in whatever format passed in by Ofmt_mask */
FUNCTION CcharDT_to_char(CcharDT IN VARCHAR2, Ofmt_mask IN VARCHAR2) return VARCHAR2;
PRAGMA RESTRICT_REFERENCES(CcharDT_to_char, WNDS, WNPS);

/* canonical datetime varchar to date */
FUNCTION CcharDT_to_date(CcharDT IN VARCHAR2) RETURN DATE;
PRAGMA RESTRICT_REFERENCES(CcharDT_to_date, WNDS, WNPS);

/* takes two datetime variables and returns their difference in minutes*/
FUNCTION datetime_diff_to_mins(dt1 DATE, dt2 DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(datetime_diff_to_mins, WNDS, WNPS);

/* this function takes a date and a number (seconds to represent the
   time since 00:00:00 of this date) and return a date */
FUNCTION Date_Timenum_to_DATE(dt dATE, time number) RETURN DATE;
PRAGMA RESTRICT_REFERENCES(Date_Timenum_to_DATE, WNDS, WNPS);

/* this function returns the julian date in floating point format */
FUNCTION DT_to_float(dt DATE)  RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(DT_to_float, WNDS, WNPS);

/* this function takes a julian date in a floating point format and returns a date */
FUNCTION float_to_DT(fdt NUMBER)  RETURN DATE;
PRAGMA RESTRICT_REFERENCES(float_to_DT, WNDS, WNPS);

/* this function takes a  in a date only value in LE Timezone, appends 23:59:59
 and then converts to the specified timezone */

FUNCTION le_date_to_server(p_le_date DATE,
                         p_org_id NUMBER) RETURN DATE;


END WIP_DATETIMES;

 

/
