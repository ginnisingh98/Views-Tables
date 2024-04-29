--------------------------------------------------------
--  DDL for Package Body PSP_MATRIX_DRIVER2_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_MATRIX_DRIVER2_PKG" as
--$Header: PSPLSM2B.pls 115.8 2002/09/25 02:15:48 vdharmap ship $

start_period	BINARY_INTEGER:=1;
TYPE	mat_tab IS TABLE OF DATE
	INDEX BY BINARY_INTEGER;
 dat mat_tab;

procedure set_start_period(n NUMBER) is
BEGIN
start_period:=n;
END set_start_period;

FUNCTION get_max_periods RETURN NUMBER is
BEGIN
RETURN dat.COUNT;
END;

FUNCTION get_dynamic_prompt(n NUMBER) RETURN VARCHAR2 IS
prompt varchar2(30);
BEGIN
--if (start_period+n > get_max_periods) then  ** commented and intro following line for 2365076
if (start_period+n <  1) then
	return null;
else
	   prompt:=to_char(dat(start_period+n),'MON-YY');
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

/* the function returns the total scheduled percentage of each distinct period in the temp table*/

FUNCTION get_dynamic_totals(n NUMBER) RETURN NUMBER IS
total NUMBER;
st_date DATE;
BEGIN
st_date:= dat(start_period+n);
--if (start_period+n > get_max_periods) then   -- replaced this condn with below cond for 2365076
if (start_period+n < 1) then
	return null;
else
  select sum(PERIOD_SCHEDULE_PERCENT)
	into total
	from psp_matrix_driver2
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
  st_date:=trunc(begin_date,'MONTH');
  en_date:=trunc(end_date,'MONTH');
  LOOP
	i:=i+1;
	dat(i):=add_months(st_date,num);
  	EXIT WHEN (dat(i)>=en_date);
	num:=num+1;
  --dbms_output.put_line('date is:'||to_char(temp));
  END LOOP;
  --dbms_output.put_line('reached here');
  OPEN sched_lines(sch_id);
  LOOP
  	FETCH sched_lines INTO sch_rec;
  	EXIT WHEN sched_lines%NOTFOUND;
	num:=dat.COUNT;
  	FOR i in 1 .. num LOOP
  	  if ((sch_rec.sbd between dat(i) and last_day(dat(i))AND(sch_rec.sed>=last_day(dat(i)))))then
      	    	per:= sch_rec.sp*psp_general.business_days(sch_rec.sbd,last_day(dat(i)))/psp_general.business_days(dat(i),last_day(dat(i)));
	  elsif ((dat(i) between sch_rec.sbd and sch_rec.sed)AND(last_day(dat(i))>=sch_rec.sed))then
		per:= sch_rec.sp*psp_general.business_days(dat(i),sch_rec.sed)/psp_general.business_days(dat(i),last_day(dat(i)));
	  elsif((sch_rec.sbd between dat(i) and last_day(dat(i)))and(sch_rec.sed<=last_day(dat(i))))then
      	    	per:= sch_rec.sp*psp_general.business_days(sch_rec.sbd,sch_rec.sed)/psp_general.business_days(dat(i),last_day(dat(i)));
	  elsif ((dat(i) between sch_rec.sbd and sch_rec.sed)AND(last_day(dat(i))<=sch_rec.sed))then
		per:= sch_rec.sp;
          else
            per:=0;
          --dbms_output.put_line('reached here'||to_char(per));
  	  end if;
 	  per:=round(per,2);
	  --dbms_output.put_line(to_char(per));
  	  insert into psp_matrix_driver2(SCHEDULE_LINE_ID,
				PERIOD,
				PERIOD_SCHEDULE_PERCENT) values
				(sch_rec.l_id,
				 dat(i),
				 per);
  	END LOOP;
  END LOOP;

END load_table;

end psp_matrix_driver2_pkg;

/
