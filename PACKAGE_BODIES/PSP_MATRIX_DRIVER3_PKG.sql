--------------------------------------------------------
--  DDL for Package Body PSP_MATRIX_DRIVER3_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_MATRIX_DRIVER3_PKG" as
--$Header: PSPLSP3B.pls 115.6 2002/09/25 02:17:44 vdharmap ship $

start_period	BINARY_INTEGER:=1;
TYPE	mat_tab IS TABLE OF DATE
	INDEX BY BINARY_INTEGER;
 dat mat_tab;

p_payroll_id Number;
PROCEDURE add_periods(st_date date, en_date date);
FUNCTION last_period_day(st_date DATE) return DATE;
FUNCTION get_payroll_id RETURN NUMBER;

procedure set_start_period(n NUMBER) is
BEGIN
start_period:=n;
END set_start_period;

FUNCTION get_max_periods RETURN NUMBER is
BEGIN
RETURN dat.COUNT;
END;

FUNCTION get_payroll_id RETURN NUMBER is
BEGIN
	Return p_payroll_id;
END get_payroll_id;

PROCEDURE set_payroll_id(n NUMBER) is
BEGIN
	p_payroll_id := n;
END set_payroll_id;

FUNCTION get_dynamic_prompt(n NUMBER) RETURN VARCHAR2 IS
prompt varchar2(30);
v_period_num varchar2(10);
v_start_date varchar2(4);
st_Date DATE;
en_Date DATE;
v_Payroll_ID Number;
v_new_line_char varchar2(30) :='
';
BEGIN
if (start_period+n) < 1 then     --- replaced "> get_max_periods)"  -- 2365076
	return null;
else
	  v_Payroll_ID := get_payroll_id;
	  st_Date := dat(start_period+n);
	  en_Date := Last_Period_Day(st_Date);

	  Begin
	  	Select 	 to_char(Period_Num) , /* to_char(Start_Date, 'YYYY') Bug fix 1901631 */
			 substr(period_name, instr(period_name, ' ', 1, 1) + 1, 4)
	  	into	 v_period_num, v_start_date
	  	from	 PER_TIME_PERIODS
	  	where	 Start_Date = st_Date
	  	and	 Payroll_ID = v_Payroll_ID;
	  Exception
		when OTHERS Then
			return null;
	  End;

	  -- prompt:=to_char(dat(start_period+n),'DD-MON-YYYY');
   	 --  prompt := v_period_num||chr(13)||chr(10)||v_start_date;
         prompt := v_period_num || v_new_line_char || v_start_date;
	  RETURN prompt;
end if;
END;

FUNCTION get_start_period(n NUMBER) RETURN DATE is
i BINARY_INTEGER;
BEGIN
i:=start_period+n;
/*if (i > get_max_periods) then
	RETURN null;
else*/
RETURN dat(i);
--end if;
END;

procedure add_periods(st_date date, en_date date) is
/**************************************************
This procedure calculates the various periods in the
user desired period.
**************************************************/
  cursor C1 is
	Select a.time_period_id, a.start_date
  	from PER_TIME_PERIODS a
  	where	a.payroll_id = p_payroll_id
  	and  (a.start_date >= st_date and  a.end_date <= en_date)
  	order by a.start_date;

  C1_Row C1%RowType;
  i BINARY_INTEGER := 0;
  n_First_Date DATE;
  n_Last_date DATE;
  n_Start_Date_Match NUMBER := 0;
  b_Calculated_First_Period Boolean := FALSE;
  n_End_Date_Match NUMBER := 0;

BEGIN

  Select count(*)
  into	 n_Start_Date_Match
  from	 PER_TIME_PERIODS a
  where  a.START_DATE = st_date
  and 	 a.payroll_id = p_payroll_id;

  Select count(*)
  into	 n_End_Date_Match
  from	 PER_TIME_PERIODS a
  where  a.END_DATE = en_date
  and 	 a.payroll_id = p_payroll_id;

  Open C1;
  LOOP
	i := i+1;
  	FETCH C1 INTO C1_Row;
  	EXIT WHEN C1%NOTFOUND;
	If NOT(b_Calculated_First_Period) AND n_Start_Date_Match = 0 Then
	     Begin
		Select 	a.START_DATE
		into 	n_First_Date
		from 	PER_TIME_PERIODS a
		where	a.PAYROLL_ID = p_payroll_id
		and	a.TIME_PERIOD_ID = C1_Row.Time_Period_ID - 1;
	    	dat(i) := n_First_Date;
	    	b_Calculated_First_Period := TRUE;
	    	i := i+1;
	    Exception
		when OTHERS Then
			b_Calculated_First_Period := TRUE;
			null;
	    End;
	End If;
	dat(i) := C1_Row.Start_Date;
  END LOOP;

  If i > 1 and n_End_Date_Match = 0 Then
	-- If there is atleast one record and the End Date does not match exactly, then manually add
	-- the last period's Start Date
	     Begin
		Select 	a.START_DATE
		into 	n_Last_Date
		from 	PER_TIME_PERIODS a
		where	a.PAYROLL_ID = p_payroll_id
		and	a.TIME_PERIOD_ID = C1_Row.Time_Period_ID + 1;
		dat(i) := n_Last_Date;
	     Exception
		when OTHERS Then
			null;
	     End;
  End If;

  if i <=1 Then
	-- There were no records obtained from the cursor.
	-- Obtain the first period where the user's start date falls between a pay period's st and en date
	-- Obtain the first period where the user's end date falls between a pay period's st and en date AND
		-- where the pay period does not equal to the User-Start-Date-Pay-Period
	Begin
		Select 	a.START_DATE
		into	n_First_Date
		from	PER_TIME_PERIODS a
		where	a.PAYROLL_ID = p_payroll_id
		and	st_date between a.START_DATE and a.END_DATE;
		dat(i) := n_First_Date;
		i := i+1;
	Exception
		when OTHERS Then
			null;
	End;

	Begin
		Select 	a.START_DATE
		into	n_Last_Date
		from	PER_TIME_PERIODS a
		where	a.PAYROLL_ID = p_payroll_id
		and	en_date between a.START_DATE and a.END_DATE
		and	a.START_DATE <> n_First_Date;
		dat(i) := n_Last_Date;
	Exception
		when OTHERS Then
			null;
	End;
  End If;

  return;
Exception
  When OTHERS Then
	return;
END add_periods;

function last_period_day(st_date DATE) return DATE is
  v_Payroll_ID Number;
  ret_Val DATE;
BEGIN
  v_payroll_id := get_payroll_id;

  Select END_DATE
  into	 ret_Val
  from	 PER_TIME_PERIODS
  where  PAYROLL_ID = v_Payroll_ID
  and	 START_DATE = st_date;

  return ret_Val;

EXCEPTION
  when OTHERS Then
	return NULL;
END last_period_day;

/* the function returns the total scheduled percentage of each distinct period in the temp table*/

FUNCTION get_dynamic_totals(n NUMBER) RETURN NUMBER IS
total NUMBER;
st_date DATE;
BEGIN
st_date:= dat(start_period+n);
if (start_period+n < 1)  then   --- replaced "> get_max_periods" for 2365076
	return null;
else
  select sum(PERIOD_SCHEDULE_PERCENT)
	into total
	from psp_matrix_driver3
	where period = st_date;
  return total;
end if;
END;

procedure purge_table is
begin
 dat.DELETE;
end purge_table;


procedure load_table(sch_id  number,begin_date date,end_date date) is
  CURSOR sched_lines(s_id NUMBER) IS
    SELECT 	schedule_line_id l_id,
		schedule_begin_date sbd,
		schedule_end_date sed,
		schedule_percent sp
    FROM	psp_schedule_lines
    WHERE	schedule_hierarchy_id = s_id;

  i BINARY_INTEGER :=0;

  sch_rec sched_lines%ROWTYPE;
  per number;
  st_date date;
  en_date date;
  num number:=0;

BEGIN
  st_date:= begin_date; --trunc(begin_date,'MONTH');
  en_date:= end_date; --trunc(end_date,'MONTH');

  Add_Periods(st_Date, en_date);

  --dbms_output.put_line('reached here');
  OPEN sched_lines(sch_id);
  LOOP
  	FETCH sched_lines INTO sch_rec;
  	EXIT WHEN sched_lines%NOTFOUND;
	num:=dat.COUNT;
  	FOR i in 1 .. num LOOP
  	  if ((sch_rec.sbd between dat(i) and last_period_day(dat(i))AND(sch_rec.sed >= last_period_day(dat(i)))))then
      	    	per:= sch_rec.sp*psp_general.business_days(sch_rec.sbd,last_period_day(dat(i)))/psp_general.business_days(dat(i),last_period_day(dat(i)));
	  elsif ((dat(i) between sch_rec.sbd and sch_rec.sed)AND(last_period_day(dat(i)) >= sch_rec.sed))then
		per:= sch_rec.sp*psp_general.business_days(dat(i),sch_rec.sed)/psp_general.business_days(dat(i),last_period_day(dat(i)));
	  elsif((sch_rec.sbd between dat(i) and last_period_day(dat(i)))and(sch_rec.sed <= last_period_day(dat(i))))then
      	    	per:= sch_rec.sp*psp_general.business_days(sch_rec.sbd,sch_rec.sed)/psp_general.business_days(dat(i),last_period_day(dat(i)));
	  elsif ((dat(i) between sch_rec.sbd and sch_rec.sed)AND(last_period_day(dat(i)) <= sch_rec.sed))then
		per:= sch_rec.sp;
          else
            per:=0;
          --dbms_output.put_line('reached here'||to_char(per));
  	  end if;
 	  per:=round(per,2);
	  --dbms_output.put_line(to_char(per));
  	  insert into psp_matrix_driver3(SCHEDULE_LINE_ID,
				PERIOD,
				PERIOD_SCHEDULE_PERCENT) values
				(sch_rec.l_id,
				 dat(i),
				 per);
  	END LOOP;
  END LOOP;
-- commit;

EXCEPTION
  When OTHERS Then
	return;
END load_table;

end psp_matrix_driver3_pkg;

/
