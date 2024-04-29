--------------------------------------------------------
--  DDL for Package Body BOM_CALENDAR_API_BK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_CALENDAR_API_BK" AS
-- $Header: BOMCALAB.pls 120.1 2005/06/21 05:29:12 appldev ship $
-- =========================================================================+
--  Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
--                         All rights reserved.                             |
-- =========================================================================+
--                                                                          |
-- File Name    : BOMCALAB.pls                                              |
-- Description  : This API will validate the input date against input       |
--                calendar as a valid working day.   		            |
-- Parameters: 	 x_calendar_code the calendar user wants to use	            |
--		 x_date 	 input date user wants to verify            |
--		 x_working_day   show is this date a working date	    |
--		 err_code	 error code, if any error happens	    |
--		 err_meg	 error message, if any error happens        |
-- Revision                                                                 |
--               Jen-Ya Ku    	 Creation                                   |
--               Rahul Chitko    Fixed bug 1607927. Trucated the date in    |
--                               checking the work day.
-- =========================================================================
PROCEDURE CHECK_WORKING_DAY (
	x_calendar_code  IN VARCHAR2,
	x_date	       IN DATE,
	x_working_day  IN OUT NOCOPY /* file.sql.39 change */ BOOLEAN,
        err_code       IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
	err_meg	       IN OUT NOCOPY /* file.sql.39 change */ VARCHAR)
AS
	l_date_seq_num NUMBER := NULL;

BEGIN
	select CA.seq_num
	into   l_date_seq_num
	from   BOM_CALENDAR_DATES CA
	where  CA.calendar_code = x_calendar_code
	and    CA.calendar_date = trunc(x_date)
	and    CA.exception_set_id = -1;

	if (l_date_seq_num is NULL) then
	    x_working_day := FALSE;
	else
	    x_working_day := TRUE;
	end if;

        err_code := 0;
EXCEPTION
	WHEN NO_DATA_FOUND then
	  err_code := -1;
	  err_meg := 'BOMCALAB: Invalid Calendar code or invalid input date is found';
	WHEN others then
          err_code := SQLCODE;
	  err_meg := substrb(SQLERRM,1,80);
END CHECK_WORKING_DAY;

-- =========================================================================+
--                                                                          |
--                                                                          |
-- Description  : Given a calendar, a date and a time, this function will   |
--                check to see if there is any shift working on that date at|
--                that time. Returns TRUE if there is a working shift and   |
--		  FALSE otherwise.   		                            |
-- Parameters: 	 x_calendar_code the calendar user wants to use	            |
--		 x_date 	 input date user wants to verify            |
----		 err_code	 error code, if any error happens	    |
--		 err_meg	 error message, if any error happens        |
-- Revision                                                                 |
--               Punit Jain    	 Creation                                   |
-- =========================================================================

FUNCTION CHECK_WORKING_SHIFT (
	x_calendar_code IN VARCHAR2,
	x_date		IN DATE,
	err_code        IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
	err_meg	        IN OUT NOCOPY /* file.sql.39 change */ VARCHAR)
return BOOLEAN
is

    CURSOR shift_cursor IS
      	 SELECT CA.shift_num, SH.from_time, SH.to_time, DT.seq_num
      	 FROM BOM_CALENDAR_SHIFTS CA, BOM_SHIFT_TIMES SH,
	      BOM_SHIFT_DATES DT
         WHERE CA.CALENDAR_CODE=x_calendar_code and
	       SH.CALENDAR_CODE=x_calendar_code and
	       CA.SHIFT_NUM = SH.SHIFT_NUM and
	       DT.CALENDAR_CODE = x_calendar_code and
	       DT.SHIFT_NUM = CA.SHIFT_NUM and
	       DT.EXCEPTION_SET_ID = -1 and
	       to_char(DT.SHIFT_DATE, 'YYYY/MM/DD')
               = to_char(x_date, 'YYYY/MM/DD');

    dummy NUMBER;
    x_time NUMBER;
    working_shift BOOLEAN:= FALSE;

BEGIN

    SELECT 1
    INTO dummy
    FROM BOM_CALENDARS
    WHERE CALENDAR_CODE = x_calendar_code;

    x_time := to_number(to_char(x_date, 'SSSSS'));

    FOR shift_var IN shift_cursor LOOP
      -- check if the input date is a valid working date for this shift

      if (shift_var.seq_num is not NULL) then

	/* This is a working day for this shift and so check if the working
	   times for this shift contain the input time
	   It is possible that a shift extends past midnight.  In this case the
	   shift_to_time will be less than the shift_from_time.
	*/

	if shift_var.from_time < shift_var.to_time then
  	   if (x_time between shift_var.from_time and shift_var.to_time) then
	    working_shift:= TRUE;
	   end if;
	elsif (x_time between shift_var.from_time and 86400 or
	       x_time between 0 and shift_var.to_time) then
	    working_shift:=TRUE;
	end if;


      end if;
    end loop;

   return (working_shift);

EXCEPTION
	WHEN NO_DATA_FOUND then
	  err_code := -1;
	  err_meg := 'BOMCALAB: Invalid Calendar code or invalid input date is found';
	  return (FALSE);

	WHEN others then
          err_code := SQLCODE;
	  err_meg := substrb(SQLERRM,1,80);
	  return FALSE;

END check_working_shift;


END BOM_CALENDAR_API_BK;

/
