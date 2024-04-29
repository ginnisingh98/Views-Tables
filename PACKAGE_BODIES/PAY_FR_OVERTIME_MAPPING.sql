--------------------------------------------------------
--  DDL for Package Body PAY_FR_OVERTIME_MAPPING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FR_OVERTIME_MAPPING" as
/* $Header: pyfromap.pkb 115.2 2002/11/22 11:35:08 sfmorris noship $ */
/*
+======================================================================+
|              Copyright (c) 1997 Oracle Corporation UK Ltd            |
|                        Reading, Berkshire, England                   |
|                           All rights reserved.                       |
+======================================================================+
Package Body Name : pay_fr_overtime_mapping
Package File Name : pyfromap.pkb
Description : This package contains procedures to support the PYFROMAP
              concurrent process

Change List:
------------

Name           Date       Version Bug     Text
-------------- ---------- ------- ------- ------------------------------
J.Rhodes       02-May-01  115.0           Initial Version
J.Rhodes       21-Nov-02  115.1           NOCOPY Changes
S.Morrison     22-Nov-02  115.2           Fixed GSCC Errors
========================================================================
*/

/* ---------------------------------------------------------------------
 NAME
   generate
 DESCRIPTION
   This procedure generate a mapping of overtime weeks onto the payroll
   period in which they will be paid
  --------------------------------------------------------------------- */
procedure generate
(errbuf out nocopy varchar2
,retcode out nocopy number
,p_overtime_payroll_id number
,p_start_ot_period_id number
,p_end_ot_period_id number
,p_payroll_id number
,p_start_py_period_id number
,p_end_py_period_id number
,p_pattern varchar2
,p_override varchar2) is
--
TYPE period_type is TABLE of NUMBER INDEX by binary_integer;
period period_type;
--
l_dummy date;
l_period_end date;
--
l_min_ot_period date;
l_max_ot_period date;
--
l_min_py_period date;
l_max_py_period date;
--
l_pattern_components number;
l_py_period_counter number;
l_ot_period_counter number;
l_ot_weeks number;
l_py_period_id number;
l_py_period_end_date date;
--
cursor c_get_period_date(p_time_period_id number) is
select start_date,end_date
from per_time_periods
where time_period_id = p_time_period_id;
--
cursor c_get_last_period_end_date(p_payroll_id number) is
select max(end_date)
from per_time_periods
where payroll_id = p_payroll_id;
--
cursor c_payroll_periods is
select time_period_id,end_date
from per_time_periods
where payroll_id = p_payroll_id
and end_date >= l_min_py_period
and end_date <= l_max_py_period
order by end_date;
--
cursor c_overtime_periods is
select time_period_id,end_date
from per_time_periods
where payroll_id = p_overtime_payroll_id
and end_date >= l_min_ot_period
and end_date <= l_max_ot_period
order by end_date;
--
begin
--
/* Determine the minimum and maximum end dates of overtime periods and
   payroll periods based on input parameters */
--
open c_get_period_date(P_START_OT_PERIOD_ID);
fetch c_get_period_date into l_min_ot_period,l_dummy;
close c_get_period_date;
--
if P_END_OT_PERIOD_ID is not null then
   open c_get_period_date(P_END_OT_PERIOD_ID);
   fetch c_get_period_date into l_dummy,l_period_end;
   close c_get_period_date;
end if;
--
open c_get_last_period_end_date(P_OVERTIME_PAYROLL_ID);
fetch c_get_last_period_end_date into l_max_ot_period;
close c_get_last_period_end_date;
--
if l_period_end is not null then
   l_max_ot_period := least(l_period_end,l_max_ot_period);
end if;
--
open c_get_period_date(P_START_PY_PERIOD_ID);
fetch c_get_period_date into l_min_py_period,l_dummy;
close c_get_period_date;
--
l_period_end := null;
if P_END_PY_PERIOD_ID is not null then
   open c_get_period_date(P_END_PY_PERIOD_ID);
   fetch c_get_period_date into l_dummy,l_period_end;
   close c_get_period_date;
end if;
--
open c_get_last_period_end_date(P_PAYROLL_ID);
fetch c_get_last_period_end_date into l_max_py_period;
close c_get_last_period_end_date;
--
if l_period_end is not null then
   l_max_py_period := least(l_period_end,l_max_py_period);
end if;
--
/* Determine the number of components in the pattern */
--
l_pattern_components := LENGTH(P_pattern);
--
/* Load the pattern into local array */
--
FOR x in 1..l_pattern_components LOOP
        if SUBSTR(P_pattern,x,1) between '1' and '6' then
 	   PERIOD(x) := to_number(SUBSTR(P_pattern,x,1));
        else
           fnd_message.set_name('PAY','PAY_74951_INVALID_PATTERN');
           fnd_message.raise_error;
        end if;
END LOOP;
--
/* Initialise the payroll period counter */
--
l_py_period_counter := 1;
--
/* C_PAYROLL_PERIODS will select all the payroll periods in the
   payroll calendar starting with the one defined by
   P_START_PY_PERIOD_ID, ordered by PERIOD_START_DATE */
--
open C_PAYROLL_PERIODS;
fetch C_PAYROLL_PERIODS into l_py_period_id,l_py_period_end_date;
--
/* Initialise the Overtime Period Counter and get the number of
    overtime weeks for the payroll period */
--
l_ot_period_counter := 1;
l_ot_weeks := PERIOD(l_py_period_counter);
--
/* C_OVERTIME_PERIODS will select all the overtime periods in the
   overtime calendar starting with the one defined by
   P_START_OT_PERIOD_ID, ordered by PERIOD_START_DATE */
--
For o in C_OVERTIME_PERIODS loop
--
/* Ensure that the overtime week end date is on or before the payroll period
   end date */
--
   IF o.end_date > l_py_period_end_date then
        fnd_message.set_name('PAY','PAY_74950_OT_AFTER_PAYROLL');
        fnd_message.raise_error;
   END IF;
--
--
/* Update the overtime period record to record the payroll period in which
it will be paid */
--
 	UPDATE PER_TIME_PERIODS
 	SET PRD_INFORMATION_CATEGORY = 'FR',
            PRD_INFORMATION1 = to_char(p_payroll_id),
            PRD_INFORMATION2 = to_char(l_py_period_id)
 	where TIME_PERIOD_ID = o.TIME_PERIOD_ID
        and   (P_OVERRIDE = 'Y' or
              (nvl(P_OVERRIDE,'N') <> 'Y' and PRD_INFORMATION1 is null));
--
/* Increment the counters - if the counters have reached the end of the
number of weeks in the pattern then reset the weeks counter, get the next
payroll period and increment the period counter, otherwise just
increment the weeks counter */
--
 IF l_OT_PERIOD_COUNTER = l_OT_WEEKS THEN
    fetch C_PAYROLL_PERIODS into l_py_period_id,l_py_period_end_date;
    if C_PAYROLL_PERIODS%notfound then
       exit;
    end if;
    l_PY_PERIOD_COUNTER :=
        CEIL(MOD(l_PY_PERIOD_COUNTER,l_PATTERN_COMPONENTS)) + 1;
    l_OT_WEEKS := PERIOD(l_PY_PERIOD_COUNTER);
    l_OT_PERIOD_COUNTER := 1;
 ELSE
    l_OT_PERIOD_COUNTER := l_OT_PERIOD_COUNTER + 1;
 END IF;
--
END LOOP;   /* End of Overtime weeks loop */
--
--
close C_PAYROLL_PERIODS;
--
EXCEPTION WHEN OTHERS THEN
   errbuf := sqlerrm;
end generate;
--
end pay_fr_overtime_mapping;

/
