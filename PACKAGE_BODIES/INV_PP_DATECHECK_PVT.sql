--------------------------------------------------------
--  DDL for Package Body INV_PP_DATECHECK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_PP_DATECHECK_PVT" AS
/* $Header: INVVPPDB.pls 115.1 2003/11/12 09:33:19 gbhagra noship $*/
--

/*Date_Valid
 *   returns
 *	'Y' - current date falls within date range
 *	'N' - current date does not fall within range
 *   Parameters
 *	org_id NUMBER - ID of the organization for which the rules
 *			engine is being run  Passing NULL for org_id
 *			has no effect if date_type is always, fulldate,
 *			day, date, month, or year
 *	date_type VARCHAR2 - equivalent to Date_Type column in table.
 *			     This value signals how to process the date info.
 *			     If this value is NULL, Date_Valid assumes
 *			     date_type is fulldate.
 *  	from_val NUMBER - The from value.  Equivalent to Date_Type_From in
 *			  table.Ignored if date_type is fulldate or always.
 *			  NULL value implies no "from" boundray.
 *	to_val NUMBER - The to value. Equivalent to Date_Type_From in table.
 *			Ignored if date_type is fulldate or always. NULL
 * 			value implies no "to" boundray.
 *	from_date DATE - The from value used if date_type is fulldate.
 *			 Equivalent to Effective_From in table.
 *			  NULL value implies no "from" boundray.
 *	to_date DATE - The to value used if date_type is fulldate.
 *			 Equivalent to Effective_to in table.
 *			  NULL value implies no "from" boundray.
 *
 *	Given a "from" date and a "to" date, Date_Valid checks
 * to see if the current date falls in the given range.  The date
 * values passed in can be of different types (e.g. Day, Date, Shift, etc.).
 * First, Date_valid finds the current date by getting sysdate from the
 * database (calls function Get_Current_Date).
 * Second, it converts the current date to the appropriate date
 * date type (e.g. 15-OCT-99 becomes '6' for date_type Friday).  Third,
 * it checks to see if the current value is between the from and to
 * values (calls function Check_Between).
 */

FUNCTION Date_Valid
		(org_id NUMBER,	--Organization ID
		 date_type VARCHAR2,
		 from_val NUMBER, --same as Date_Type_From
		 to_val NUMBER,  --same as Date_Type_To
		 from_date DATE, --same as Effective_From
		 to_date DATE)  --same as Effective_To
return VARCHAR2 IS

cur_date DATE;	--holds today's date
cur_val NUMBER; --holds the value for today for the given date_type
ret_val VARCHAR2(1);
cal_code VARCHAR2(10);
except_set NUMBER;
cur_seconds NUMBER;
set_name VARCHAR2(15);
date_type_num NUMBER;

cursor cal_param IS
	SELECT calendar_code, calendar_exception_set_id
	FROM MTL_PARAMETERS
	WHERE organization_id = org_id;


cursor current_shifts IS
	SELECT shift_num
	FROM BOM_SHIFT_DATES
	WHERE calendar_code = cal_code AND
	      exception_set_id = nvl(except_set, -1) AND
	      shift_date = cur_date AND
	      shift_num NOT IN (SELECT shift_num
			FROM BOM_SHIFT_TIMES
			WHERE calendar_code = cal_code AND
	     		cur_seconds not between FROM_TIME and TO_TIME) AND
	      seq_num IS NOT NULL;

cursor current_week IS
	SELECT seq_num
	FROM BOM_CAL_WEEK_START_DATES
	WHERE calendar_code = cal_code AND
	      exception_set_id = nvl(except_set, -1) AND
	      cur_date BETWEEN week_start_date AND next_date;


cursor current_cal_period IS
	SELECT period_sequence_num
	FROM BOM_PERIOD_START_DATES
	WHERE calendar_code = cal_code AND
	      exception_set_id = nvl(except_set, -1) AND
	      cur_date between period_start_date and next_date;

cursor current_acct_period IS
	SELECT period_num
	FROM org_acct_periods
	WHERE organization_id = org_id
	AND INV_LE_TIMEZONE_PUB.get_le_day_for_inv_org(cur_date,org_id) BETWEEN period_start_date AND
			     schedule_close_date;

cursor period_set IS
	SELECT period_set_name
	FROM org_acct_periods
	WHERE organization_id = org_id;

cursor current_quarter IS
	SELECT quarter_num
	FROM gl_periods
	WHERE period_set_name = set_name AND
	      cur_date BETWEEN quarter_start_date AND
			       add_months(quarter_start_date, 3);


BEGIN

date_type_num := to_number(date_type);


--date-type = always, return true
if (date_type_num = c_always) then
	return 'Y';

--date-type = full date or is null
elsif (date_type_num = c_fulldate OR date_type_num IS NULL) then

	--get current date in dd-mon-yy format
	cur_date :=Get_Current_Date(NULL);
	if ((cur_date >= from_date OR  from_date IS NULL) AND
	    (cur_date <= to_date   OR  to_date   IS NULL)) then
		return 'Y';
	else
		return 'N';
	end if;

elsif (date_type_num = c_day) then
	-- D returns number of the dat (Sunday = 1)
	cur_val := to_number(Get_Current_Date('D'));
	ret_val := Check_Between(cur_val, from_val, to_val);
	return ret_val;

elsif (date_type_num = c_date) then

	--DD returns numerical date
	cur_val := to_number(Get_Current_Date('DD'));
	ret_val := Check_Between(cur_val, from_val, to_val);
	return ret_val;

elsif (date_type_num = c_month) then
	--MM returns number of the month (Jan = 1)
	cur_val := to_number(Get_Current_Date('MM'));
	ret_val := Check_Between(cur_val, from_val, to_val);
	return ret_val;

elsif (date_type_num = c_year) then
	--YYYY returns 4-digit year
	cur_val := to_number(Get_Current_Date('YYYY'));
	ret_val := Check_Between(cur_val, from_val, to_val);
	return ret_val;

elsif (date_type_num = c_shift) then

	--get the calendar code and exception_set_id
	OPEN cal_param;
	FETCH cal_param into cal_code, except_set;
	CLOSE cal_param;
	if (cal_code IS NULL)  then
		return 'F';
	end if;

	--SSSSS returns Seconds since midnight
	cur_seconds := to_number(Get_Current_Date('SSSSS'));
	cur_date := Get_Current_Date(NULL);
	OPEN current_shifts;
	FETCH current_shifts INTO cur_val;

	--shifts can overlap, so select can return multiple rows
	WHILE current_shifts%FOUND LOOP
		ret_val := Check_Between(cur_val, from_val, to_val);
		if (ret_val = 'Y') then
			CLOSE current_shifts;
			return 'Y';
		end if;
		FETCH current_shifts INTO cur_val;
	end loop;
	CLOSE current_shifts;
	return 'N';

elsif (date_type_num = c_week) then

	--get calendar_code and exception_set_id
	OPEN cal_param;
	FETCH cal_param into cal_code, except_set;
	CLOSE cal_param;
	if (cal_code IS NULL)  then
		return 'F';
	end if;

	cur_date := Get_Current_Date(NULL);

	OPEN current_week;
	FETCH current_week INTO cur_val;
	ret_val := Check_Between(cur_val, from_val, to_val);
	return ret_val;

elsif (date_type_num = c_cal_period) then

	--get calendar code and exception set id
	OPEN cal_param;
	FETCH cal_param into cal_code, except_set;
	ClOSE cal_param;
	if (cal_code IS NULL)  then
		return 'F';
	end if;
	cur_date := Get_Current_Date(NULL);

	OPEN current_cal_period;
	FETCH current_cal_period INTO cur_val;
	CLOSE current_cal_period;
	ret_val := Check_Between(cur_val, from_val, to_val);
	return ret_val;

elsif (date_type_num = c_acct_period) then

	cur_date := Get_Current_Date(NULL);

	OPEN current_acct_period;
	FETCH current_acct_period INTO cur_val;
        CLOSE current_acct_period;

        ret_val := Check_Between(cur_val, from_val, to_val);
	return ret_val;

elsif (date_type_num = c_quarter) then

	--get the period_set_name
	OPEN period_set;
	FETCH period_set INTO set_name;
	CLOSE period_set;

	cur_date := Get_Current_Date(NULL);
	OPEN current_quarter;
	FETCH current_quarter INTO cur_val;

	--returns multiple values since serveral periods in a single
	--quarter
	WHILE current_quarter%FOUND LOOP
		ret_val := Check_Between(cur_val, from_val, to_val);
		if(ret_val = 'Y') then
			CLOSE current_quarter;
			return 'Y';
		end if;
		FETCH current_quarter INTO cur_val;
	end loop;
	CLOSE current_quarter;
	return 'N';

else
	return 'N';
end if;

END Date_Valid;


/*Get_Current_Date
 * 	Returns sysdate in form specified in format
 *	Passing NULL format = default sysdate format (DD-MON-YY)
 */


FUNCTION Get_Current_Date(format VARCHAR2)
return VARCHAR2 IS

cursor c_date IS
	SELECT sysdate
	FROM DUAL;

cur_date DATE;

BEGIN

OPEN c_date;
FETCH c_date into cur_date;
CLOSE c_date;

if (format IS NOT NULL) then
	return to_char(cur_date, format);
else
	return to_char(cur_date);
end if;

end Get_Current_Date;


/*Check_Between
 *	Returns 'Y' if cur_val between from_val and to_val
 * 	Returns 'N' otherwise
 */


FUNCTION Check_Between
	(cur_val 	NUMBER,
	 from_val	NUMBER,
	 to_val		NUMBER)

return VARCHAR2 IS

BEGIN
	if (cur_val IS NULL) then
		return 'N';
	end if;

	--easy case. current falls between from and to
	if (to_val >= from_val) then
		if ((cur_val >= from_val OR from_val IS NULL) AND
		    (cur_val <= to_val OR to_val IS NULL)) THEN
			return 'Y';
		else
			return 'N';
		end if;
	else
		if((cur_val >=from_val OR from_val IS NULL) OR
		   (cur_val <= to_val OR to_val IS NULL)) THEN
			return 'Y';
		else
			return 'N';
		end if;
	end if;

end Check_Between;

END INV_PP_DateCheck_PVT;

/
