--------------------------------------------------------
--  DDL for Package WMS_DATECHECK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_DATECHECK_PVT" AUTHID CURRENT_USER AS
/* $Header: WMSVPPDS.pls 120.0 2005/05/25 09:03:54 appldev noship $*/
--

/*Date_Valid
 *   returns
 *      'Y' - current date falls within date range
 *      'N' - current date does not fall within range
 *   Parameters
 *      org_id NUMBER - ID of the organization for which the rules
 *                      engine is being run  Passing NULL for org_id
 *                      has no effect if date_type is always, fulldate,
 *                      day, date, month, or year
 *      date_type VARCHAR2 - equivalent to Date_Type column in table.
 *                           This value signals how to process the date info.
 *                           If this value is NULL, Date_Valid assumes
 *                           date_type is fulldate.
 *      from_val NUMBER - The from value.  Equivalent to Date_Type_From in
 *                        table.Ignored if date_type is fulldate or always.
 *                        NULL value implies no "from" boundray.
 *      to_val NUMBER - The to value. Equivalent to Date_Type_From in table.
 *                      Ignored if date_type is fulldate or always. NULL
 *                      value implies no "to" boundray.
 *      from_date DATE - The from value used if date_type is fulldate.
 *                       Equivalent to Effective_From in table.
 *                        NULL value implies no "from" boundray.
 *      to_date DATE - The to value used if date_type is fulldate.
 *                       Equivalent to Effective_to in table.
 *                        NULL value implies no "from" boundray.
 */


FUNCTION Date_Valid
		(org_id NUMBER,	--Organization ID
		 date_type VARCHAR2 ,
		 from_val NUMBER, --same as Date_Type_From
		 to_val NUMBER,  --same as Date_Type_To
		 from_date DATE, --same as Effective_From
		 to_date DATE)  --same as Effective_To
return VARCHAR2;


/* Helper functions for Date_Valid */

FUNCTION Get_Current_Date
	(format VARCHAR2)
return VARCHAR2;


FUNCTION Check_Between
	(cur_val NUMBER,
	 from_val NUMBER,
	 to_val NUMBER)
return VARCHAR2;


/* Constants used in Date_Valid
 * 	Correspond to lookup_type MTL_PP_DATE_TYPE
 */

c_fulldate 	CONSTANT NUMBER := 1;
c_day 		CONSTANT NUMBER := 2;
c_date 		CONSTANT NUMBER := 3;
c_month 	CONSTANT NUMBER := 4;
c_year	 	CONSTANT NUMBER := 5;
c_shift		CONSTANT NUMBER := 6;
c_week	 	CONSTANT NUMBER := 7;
c_cal_period	CONSTANT NUMBER := 8;
c_acct_period	CONSTANT NUMBER := 9;
c_quarter 	CONSTANT NUMBER := 10;
c_always 	CONSTANT NUMBER := 11;




END WMS_DateCheck_PVT;

 

/
