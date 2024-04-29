--------------------------------------------------------
--  DDL for Package Body MTH_TZ_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTH_TZ_UTIL" AS
/*$Header: mthtzutb.pls 120.0.12010000.6 2009/08/21 09:49:29 sdonthu noship $*/

/* *****************************************************************************
* Function		: CONVERT_TZ                                           *
* Description 	 	: This function is used to return the Date by passed   *
*                         date, source and target time zone                    *
* File Name	 	: MTHTZUTS.PLS		             		       *
* Visibility		: Public              				       *
* Parameters	 	: date, from_tz, to_tz                                 *
* Return Value		: date                                                 *
* Modification log	:						       *
*			Author		Date			Change         *
*	                Tawen Kan	01-Mar-2007	Initial Creation       *
***************************************************************************** */

Function convert_tz (date_time date
                     ,from_tz varchar2
                     ,to_tz varchar2) RETURN DATE IS return_date date;
    t_date date;
    from_tz_name varchar2(64);
    to_tz_name varchar2(64);
BEGIN
    t_date := date_time;
    SELECT tzname INTO from_tz_name FROM V$TIMEZONE_NAMES WHERE tzabbrev = from_tz AND ROWNUM = 1;
    SELECT tzname INTO to_tz_name  FROM V$TIMEZONE_NAMES WHERE tzabbrev = to_tz AND ROWNUM = 1;

    IF date_time IS NOT null AND from_tz IS NOT null AND to_tz IS not null
       AND from_tz_name IS NOT NULL AND to_tz_name IS NOT NULL THEN
       BEGIN
         return_date :=  to_timestamp_tz(to_char(t_date,'YYYY-MM-DD HH24:MI:SS') || ' ' || from_tz_name, 'YYYY-MM-DD HH24:MI:SS TZR') at time zone to_tz_name;
       EXCEPTION
          WHEN others THEN
              RAISE_APPLICATION_ERROR (-20001, 'Exception has occured');
       END;
    ELSE
       return_date := date_time;
    END IF ;
    RETURN return_date;
END convert_tz;

/* *****************************************************************************
* Function		: FROM_TZ                                              *
* Description 	 	: This function is used to return the Date by passed   *
*                         date, source time zone                               *
* File Name	 	: MTHTZUTS.PLS		             		       *
* Visibility		: Public              				       *
* Parameters	 	: date, from_tz                                        *
* Return Value		: date                                                 *
* Modification log	:						       *
*			Author		Date			Change         *
*	                Tawen Kan	01-Mar-2007	Initial Creation       *
***************************************************************************** */

Function from_tz (date_time date
                  ,from_tz varchar2) RETURN DATE IS
    return_date date;
    t_date date;
    from_tz_name varchar2(64);
BEGIN
    t_date := date_time;
    SELECT tzname INTO from_tz_name FROM V$TIMEZONE_NAMES WHERE tzabbrev = from_tz AND ROWNUM = 1;

    IF date_time IS NOT NULL AND from_tz IS NOT NULL AND from_tz_name IS NOT NULL THEN
       BEGIN
         return_date :=  to_timestamp_tz(to_char(t_date,'YYYY-MM-DD HH24:MI:SS') || ' ' || from_tz_name, 'YYYY-MM-DD HH24:MI:SS TZR') at time zone 'GMT';
       EXCEPTION
           WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR (-20001, 'Exception has occured');
       END;
    ELSE
      return_date := date_time;
    END IF;
    RETURN return_date;
END FROM_TZ;

/* *****************************************************************************
* Function		: TO_TZ                                                *
* Description 	 	: This function is used to return the Date by passed   *
*                         date, target time zone                               *
* File Name	 	: MTHTZUTS.PLS		             		       *
* Visibility		: Public              				       *
* Parameters	 	: date, to_tz                                          *
* Return Value		: date                                                 *
* Modification log	:						       *
*			Author		Date			Change         *
*	                Tawen Kan	01-Mar-2007	Initial Creation       *
***************************************************************************** */

FUNCTION to_tz(date_time date
               ,to_tz varchar2) RETURN DATE IS
    return_date date;
    t_date date;
    to_tz_name varchar2(64);
BEGIN
    t_date := date_time;
    SELECT tzname INTO to_tz_name FROM V$TIMEZONE_NAMES WHERE tzabbrev = to_tz AND ROWNUM = 1;

    IF date_time IS NOT NULL AND to_tz IS NOT NULL THEN
       BEGIN
         return_date :=  to_timestamp_tz(to_char(t_date,'YYYY-MM-DD HH24:MI:SS') || ' ' || 'GMT', 'YYYY-MM-DD HH24:MI:SS TZR') at time zone to_tz_name;
       EXCEPTION
           WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR (-20001, 'Exception has occured');
       END ;
    ELSE
       return_date := date_time;
    END IF;
    RETURN return_date;
END to_tz;

END MTH_TZ_UTIL;

/
