--------------------------------------------------------
--  DDL for Package Body PAY_FR_SCHEDULE_CALCULATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FR_SCHEDULE_CALCULATION" as
/* $Header: pyfrwktm.pkb 120.1 2005/06/14 05:17:28 aparkes noship $ */
--
g_udt_name VARCHAR2(50) := 'FR_COMPANY_WORK_PATTERNS';
g_date_start date;
g_date_end date;
g_assignment_id number;
g_asg_start_date date;
g_asg_end_date date;
g_person_id number;
g_business_group_id number;
g_asg_periods number;
g_default_offset number := 1;
--
TYPE wp_rec_type is RECORD (start_date date
                              ,end_date  date
                              ,pattern varchar2(30)
                              ,pattern_start number
                              ,pattern_index number
                              ,pattern_length number
                            );
TYPE wp_tab_type is TABLE of wp_rec_type INDEX BY BINARY_INTEGER;
--
TYPE days_rec_type is RECORD (hours number
                             ,protected varchar2(1)
                             ,public_holiday varchar2(1)
                             ,public_holiday_override varchar2(1)
                             ,public_holiday_in_lieu varchar2(1)
                             ,absence_non_working varchar2(1)
                             );
TYPE days_tab_type is TABLE of days_rec_type INDEX BY BINARY_INTEGER;
--
TYPE pattern_tab_type is TABLE of VARCHAR2(2) INDEX BY BINARY_INTEGER;
days_tab days_tab_type;
work_pattern wp_tab_type;
pattern pattern_tab_type;
--
procedure initialise(p_assignment_id number
                    ,p_effective_date date) is
--
cursor csr_asg is
select trunc(a.effective_start_date) effective_start_date
,      trunc(a.effective_end_date) effective_end_date
,      a.person_id
,      a.business_group_id business_group_id
,      scl.segment5 work_pattern
,      nvl(scl.segment11,g_default_offset) work_pattern_start_day
from per_all_assignments_f a
,    hr_soft_coding_keyflex scl
where a.assignment_id = p_assignment_id
and   a.soft_coding_keyflex_id = scl.soft_coding_keyflex_id(+)
order by a.effective_start_date;
--
--
l_days_worked number;
l_start number;
l_end number;
l_prev_work_pattern varchar2(30);
l_prev_pattern_start Number;
l_prev_start_date date;
l_prev_end_date date;
i number;
l_shift_pattern_index number := 1;
--
procedure load_pattern(p_pattern in varchar2
                     ,p_effective_date date
                     ,p_pattern_index out nocopy number
                     ,p_pattern_length out nocopy number) is
--
  cursor c_get_days is
  select ci.value
  from pay_user_tables t
  ,    pay_user_columns c
  ,    pay_user_rows_f r
  ,    pay_user_column_instances_f ci
  where t.user_table_name = g_udt_name
  and c.business_group_id = g_business_group_id
  and   t.user_table_id = r.user_table_id
  and   t.user_table_id = c.user_table_id
  and   c.user_column_name = p_pattern
  and   ci.user_column_id = c.user_column_id
  and   ci.user_row_id = r.user_row_id
  and p_effective_date
      between r.effective_start_date and r.effective_end_date
  and p_effective_date
      between ci.effective_start_date and ci.effective_end_date
  order by r.display_sequence;
--
l_length number := 0;
l_pattern_index number;
begin
   l_pattern_index := l_shift_pattern_index;
   --
   for d in c_get_days loop
       pattern(l_shift_pattern_index) := d.value;
       l_shift_pattern_index := l_shift_pattern_index + 1;
       l_length := l_length + 1;
   end loop;
   --
   p_pattern_index := l_pattern_index;
   p_pattern_length := l_length;
end load_pattern;
--
begin
--
/* if the assignment has already been initialised then exit */
if g_assignment_id = p_assignment_id  then
   null;
else
--
/* Get distinct working pattern details for the assignment */
   l_prev_work_pattern := null;
   l_prev_start_date := null;
   l_prev_end_date := null;
   l_prev_pattern_start := null;
   i := 0;
   pattern.delete;
     for l_asg_rec in csr_asg loop
       g_person_id         := l_asg_rec.person_id;
       g_business_group_id := l_asg_rec.business_group_id;
       g_assignment_id     := p_assignment_id;
       if g_asg_start_date is Null then
	   g_asg_start_date := l_asg_rec.effective_start_date;
       end if;
       --Bug:2454782.Also checked the update of pattern start day.
       if l_asg_rec.work_pattern = l_prev_work_pattern and
          l_asg_rec.work_pattern_start_day = l_prev_pattern_start then
          l_prev_end_date := l_asg_rec.effective_end_date;
       else
          if l_prev_work_pattern is not null then
             i := i + 1;
             work_pattern(i).start_date := l_prev_start_date;
             work_pattern(i).end_date := l_prev_end_date;
             work_pattern(i).pattern := l_prev_work_pattern;
             work_pattern(i).pattern_start :=l_prev_pattern_start;
             --
             load_pattern(l_prev_work_pattern
                         ,p_effective_date
                         ,work_pattern(i).pattern_index
                         ,work_pattern(i).pattern_length);
             --
          end if;
          --
          l_prev_start_date := l_asg_rec.effective_start_date;
          l_prev_end_date := l_asg_rec.effective_end_date;
          l_prev_work_pattern := l_asg_rec.work_pattern;
          l_prev_pattern_start := l_asg_rec.work_pattern_start_day;
       end if;
     end loop;
   i := i + 1;
   work_pattern(i).start_date := l_prev_start_date;
   work_pattern(i).end_date := l_prev_end_date;
   work_pattern(i).pattern_start := l_prev_pattern_start;
   work_pattern(i).pattern := l_prev_work_pattern;
             --
             load_pattern(l_prev_work_pattern
                         ,p_effective_date
                         ,work_pattern(i).pattern_index
                         ,work_pattern(i).pattern_length);
             --
   g_asg_periods := i;
   g_asg_end_date := l_prev_end_date;

 -- UNCOMMENT THE FOLLOWING TO DEBUG IN SQL * PLUS
 /*
  --Displays Work Pattern info assigned to the employee
   Dbms_Output.Put_line(rpad('Start Date',10)||' '
                      ||rpad('End Date',10)||' '
                      ||rpad('Work Pattern',20)||' '
                      ||rpad('Start',5)||' '
                      ||rpad('Index',5)||' '
                      ||rpad('Length',6));
   Dbms_Output.Put_line(rpad('-',10,'-')||' '
                      ||rpad('-',10,'-')||' '
                      ||rpad('-',20,'-')||' '
                      ||rpad('-',5,'-')||' '
                      ||rpad('-',5,'-')||' '
                      ||rpad('-',5,'-'));
  For i in 1..g_asg_periods Loop
   Dbms_output.put_line(rpad(work_pattern(i).start_date,10) || ' '
                      ||rpad(work_pattern(i).end_date,10) ||' '
                      ||rpad(work_pattern(i).pattern,20) ||' '
                      ||rpad(work_pattern(i).pattern_start,5)||' '
                      ||rpad(work_pattern(i).pattern_index,5)||' '
                      ||rpad(work_pattern(i).pattern_length,5));
  End Loop;
  Dbms_Output.Put_line(chr(10));

  --Displays Pattern Table information
  Dbms_Output.Put_Line(rpad('index',5)||' '
                     ||rpad('Working Hours',13));
  Dbms_Output.Put_Line(rpad('-',5,'-')||' '
                     ||rpad('-',13,'-'));
  For i in 1..l_shift_pattern_index-1 Loop
  Dbms_Output.Put_Line(rpad(i,5)||' '
                     ||rpad(pattern(i),13));
  End Loop;
  Dbms_Output.Put_line(chr(10));

   */

 end if;
end initialise;
----------------------------------------------------------
--
procedure derive_schedule(p_assignment_id number
                         ,p_date_start date
                         ,p_date_end date) is
cursor csr_ph is
select to_number(to_char(holiday_date,'J')) day
from per_standard_holidays
where legislation_code = 'FR'
and holiday_date between p_date_start and p_date_end;
--
cursor csr_ph_overrides is
select to_number(to_char(date_not_taken,'J')) day
from per_std_holiday_absences
where person_id = g_person_id
and date_not_taken between p_date_start and p_date_end;
--
cursor csr_ph_in_lieu is
select to_number(to_char(actual_date_taken,'J')) day
from per_std_holiday_absences
where person_id = g_person_id
and actual_date_taken between p_date_start and p_date_end;
--
cursor csr_absence_non_working is
select to_number(to_char(
               greatest(a.date_start,p_date_start),'J'))     date_start
,      to_number(to_char(
          least(nvl(a.date_end,p_date_end),p_date_end),'J')) date_end
from per_absence_attendances a
,    per_absence_attendance_types aat
,    per_shared_types nw
where a.person_id = g_person_id
and a.date_start <= p_date_end
and nvl(a.date_end,p_date_end) >= p_date_start
and a.absence_attendance_type_id = aat.absence_attendance_type_id
and aat.absence_category = nw.system_type_cd
and nvl(nw.business_group_id,a.business_group_id) = a.business_group_id
and nw.lookup_type = 'ABSENCE_CATEGORY'
and nw.information1 = 'Y';
--
l_start number;
l_end number;
x number;
l_pattern_offset number;
l_pattern_start number;
i Number;
--
begin
/* In the case of Starters and Leavers it may be necessary to infer the
pattern wither before or after their assignment starts/ends.

This is achieved by modifying the 1st assignment period start date and the
last assignment period end date if they are within the p_date_start and p_date_end date range.
*/
--

if p_date_start < g_asg_start_date then
   l_pattern_offset := p_date_start - work_pattern(1).start_date;
   work_pattern(1).pattern_start :=
         mod(l_pattern_offset + work_pattern(1).pattern_start
            ,work_pattern(1).pattern_length);
    If work_pattern(1).pattern_start <= 0 Then
        work_pattern(1).pattern_start := work_pattern(1).pattern_start + work_pattern(1).pattern_length;
    End If;

   work_pattern(1).start_date := trunc(p_date_start);
end if;
--
if p_date_end > g_asg_end_date then
   work_pattern(g_asg_periods).end_date := trunc(p_date_end);
end if;
--
if trunc(p_date_start) = trunc(g_date_start) and
  trunc(p_date_end) = trunc(g_date_end)  and
  p_assignment_id = g_assignment_id then
   null;
else


days_tab.delete;

for a in 1..g_asg_periods loop
--
    if work_pattern(a).end_date >= trunc(p_date_start) and
       work_pattern(a).start_date <= trunc(p_date_end) then
       --

   l_start := to_number(to_char(greatest(p_date_start,work_pattern(a).start_date),'J'));
   l_end   := to_number(to_char(least(p_date_end,work_pattern(a).end_date),'J'));
/* Determine the pattern day on start date of period */
       l_pattern_offset := greatest(trunc(p_date_start)
                                  ,work_pattern(a).start_date)
                          - work_pattern(a).start_date;
       l_pattern_start := mod(l_pattern_offset + work_pattern(a).pattern_start
                             ,work_pattern(a).pattern_length);
       --
       If l_pattern_start = 0 Then
         l_pattern_start := work_pattern(a).pattern_length;
       End If;

       --
       x := work_pattern(a).pattern_index + l_pattern_start - 1;
        for d in l_start..l_end loop
            if work_pattern(a).pattern_length = 0 then
                days_tab(d).hours := 0;
            else
                if pattern(x) = 'P' then
                   days_tab(d).hours := 0;
                   days_tab(d).protected := 'Y';
                else
                   days_tab(d).hours := pattern(x);
                end if;
            end if;
            --
            /* Increment index counter */
            if x - work_pattern(a).pattern_index + 1
                  >= work_pattern(a).pattern_length then
               x := work_pattern(a).pattern_index;
            else
               x := x + 1;
            end if;
       end loop;
    end if;
end loop;
--

/* Load public holidays */
for h in csr_ph loop
   days_tab(h.day).public_holiday := 'Y';
end loop;
--

/* Load public holiday overrides */
for o in csr_ph_overrides loop
   days_tab(o.day).public_holiday_override := 'Y';
end loop;
--

/* Load public holiday taken in lieu */
for l in csr_ph_in_lieu loop
   days_tab(l.day).public_holiday_in_lieu := 'Y';
end loop;
--

/* Load absences treated as non-working days */
for a in csr_absence_non_working loop
   for n in a.date_start..a.date_end loop
       days_tab(n).absence_non_working := 'Y';
   end loop;
end loop;
--
l_start := to_number(to_char(p_date_start,'J'));
l_end := to_number(to_char(p_date_end,'J'));
--
  g_date_start := trunc(p_date_start);
  g_date_end := trunc(p_date_end);
end if;
-----------------------------------------------------
l_start := to_number(to_char(p_date_start,'J'));
l_end := to_number(to_char(p_date_end,'J'));

--Displays the main pl/sql table
/*
dbms_output.put_line(rpad('Day',21)|| ' '
                  || rpad('Hours',5)|| ' '
                  || rpad('Protected',9)|| ' '
                  || rpad('Public Holiday',14)|| ' '
                  || rpad('PH Override',11)|| ' '
                  || rpad('PH in lieu',10)|| ' '
                  || rpad('Absence NW',10));
dbms_output.put_line(rpad('-',21,'-')|| ' '
                  || rpad('-',5,'-')|| ' '
                  || rpad('-',9,'-')|| ' '
                  || rpad('-',14,'-')|| ' '
                  || rpad('-',11,'-')|| ' '
                  || rpad('-',10,'-')|| ' '
                  || rpad('-',10,'-'));

for d in l_start..l_end loop
dbms_output.put_line(rpad(to_date(d,'J'),10)|| ' '||rpad(TO_CHAR(TO_DATE(d,'J'),'DAY'),10)||' '||
rpad(days_tab(d).hours,5) || ' '||
rpad(nvl(days_tab(d).protected,' '),9) || ' '||
rpad(nvl(days_tab(d).public_holiday,' '),14) || ' '||
rpad(nvl(days_tab(d).public_holiday_override,' '),11) || ' '||
rpad(nvl(days_tab(d).public_holiday_in_lieu,' '),10) || ' '||
rpad(nvl(days_tab(d).absence_non_working,' '),10)
);
end loop;
*/
end derive_schedule;
--
/* ---------------------------------------------------------
Function holiday_days

This function counts the number of working days between the
Start and End Dates passed in as parameters.

It takes into account public holidays as these should not be
counted as holidays if they fall on a working day. If the
public holiday is scheduled to be worked then it is treated
as working day for the purposes of counting working days.
A holiday taken in lieu of a public holiday is treated as
a non-working day for the purposes of counting working days.

Other types of absence do not affect the count of holidays.
------------------------------------------------------------ */
function holiday_days(p_assignment_id number
                         ,p_effective_date date
                         ,p_date_start date
                         ,p_date_end date
                         ) return number is
l_days_worked number := 0;
l_start number;
l_end number;
begin
--
/* Call initialise in case this is a new person */
   initialise(p_assignment_id
             ,p_effective_date);
/* Call derive_schedule in case this is a new period */
   derive_schedule(p_assignment_id
                  ,p_date_start
                  ,p_date_end);
   --
/* count the number of days */
   --
l_start := to_number(to_char(p_date_start,'J'));
l_end := to_number(to_char(p_date_end,'J'));
--
   for d in l_start..l_end loop
          if not(days_tab(d).hours = 0) then
          if days_tab(d).public_holiday = 'Y' then
             if days_tab(d).public_holiday_override = 'Y' then
                l_days_worked := l_days_worked + 1;
             end if;
          else
             if days_tab(d).public_holiday_in_lieu = 'Y' then
                null;
             else
                l_days_worked := l_days_worked + 1;
             end if;
          end if;
       end if;
   end loop;
   return l_days_worked;
end;
--
/* ---------------------------------------------------------
Function protected_days

This function takes counts the number of protected days
between the Start and End Dates passed in as parameters.

It takes into account public holidays as these should
not be counted as holidays if they fall on a working day.

Other types of absence do not affect the count of holidays.

 --------------------------------------------------------- */
function protected_days(p_assignment_id number
                         ,p_effective_date date
                         ,p_date_start date
                         ,p_date_end date
                         ) return number is
l_protected_days number := 0;
l_start number;
l_end number;
begin
--
/* Call initialise in case this is a new person */
   initialise(p_assignment_id
             ,p_effective_date);
/* Call derive_schedule in case this is a new period */
   derive_schedule(p_assignment_id
                  ,p_date_start
                  ,p_date_end);
   --
/* count the number of protected days */
   --
l_start := to_number(to_char(p_date_start,'J'));
l_end := to_number(to_char(p_date_end,'J'));
--
   for d in l_start..l_end loop
       if days_tab(d).protected = 'Y' then
          if days_tab(d).public_holiday = 'Y' then
             null;
          else
                l_protected_days := l_protected_days + 1;
          end if;
       end if;
   end loop;
   return l_protected_days;
end;
--
/* ---------------------------------------------------------
Function scheduled_working_days

This function will return the number of working days for the
assignment between the start and end dates. The effective
date parameter is used to determine the work pattern records
from the user defined table.

Only the work schedule will be used to determine the number
of days scheduled to be worked. Public Holidays and other
absences are excluded from the evaluation.

This will be used by the Sickness functionality to evaluate
the Sickness Deduction.

------------------------------------------------------------ */
function scheduled_working_days(p_assignment_id number
                         ,p_effective_date date
                         ,p_date_start date
                         ,p_date_end date
                         ) return number is
l_days_worked number := 0;
l_start number;
l_end number;
i Number;
begin
--
/* Call initialise in case this is a new person */
   initialise(p_assignment_id
             ,p_effective_date);
/* Call derive_schedule in case this is a new period */
   derive_schedule(p_assignment_id
                  ,p_date_start
                  ,p_date_end);
   --
/* count the number of days */
   --
l_start := to_number(to_char(p_date_start,'J'));
l_end := to_number(to_char(p_date_end,'J'));
--

   i := days_tab.FIRST;
   While i Is Not Null Loop
   If Not(days_tab(i).hours = 0) Then
          	   l_days_worked := l_days_worked + 1;
   End If;

   i := days_tab.NEXT(i);
   End Loop;


   return l_days_worked;
end;
--
/* ---------------------------------------------------------
Function scheduled_working_hours

This function will return the number of working hours for the
assignment between the start and end dates. The effective date
parameter is used to determine the work pattern records from
the user defined table.

Only the work schedule will be used to determine the number of
hours scheduled to be worked. Public Holidays and other absences
are excluded from the evaluation.

This will be used by the Proration functionality to evaluate
the Scheduled Hours Method.

------------------------------------------------------------ */
function scheduled_working_hours(p_assignment_id number
                         ,p_effective_date date
                         ,p_date_start date
                         ,p_date_end date
                         ) return number is
l_hours_worked number := 0;
l_start number;
l_end number;
i Number;
begin
--
/* Call initialise in case this is a new person */
   initialise(p_assignment_id
             ,p_effective_date);
/* Call derive_schedule in case this is a new period */
   derive_schedule(p_assignment_id
                  ,p_date_start
                  ,p_date_end);
   --
/* count the number of hours */
   --
l_start := to_number(to_char(p_date_start,'J'));
l_end := to_number(to_char(p_date_end,'J'));
--

   i := days_tab.FIRST;
   While i Is Not Null Loop
   If Not(days_tab(i).hours = 0) Then
          	   l_hours_worked := l_hours_worked + days_tab(i).hours;
   End If;

   i := days_tab.NEXT(i);
   End Loop;



   return l_hours_worked;
end;
--
/*------------------------------------------------------------
For the purposes of a Sickness report the last working day prior to
the sickness and the next working day following a particular day is required.

These functions loop through days prior to / following the P_DATE
determining whether the day is a working day. If it reaches the
P_LIMIT_DATE it stops and returns NULL. The default value
for the P_LIMIT_DATE is 12 months prior to / following the P_DATE.

------------------------------------------------------*/
function get_next_last_working_day(p_assignment_id number
                         ,p_effective_date date
                         ,p_date date
                         ,p_limit_date date
                         ,p_next_last number
                         ) return date is
l_date date;
l_start number;
l_end number;
l_working_date date;
d number;
l_limit_date date;
l_act_date Date;
l_last_act_date Date;
Cursor c_start_asg is
         Select Min(effective_start_date)
         From per_all_assignments_f paaf
         Where
              paaf.assignment_id = g_assignment_id;

begin
   initialise(p_assignment_id
             ,p_effective_date);


   Open c_start_asg ;
   Fetch c_start_asg into l_act_date;
   Close c_start_asg;
   l_last_act_date := l_act_date;
   l_act_date := greatest(l_act_date,p_date);

   --
   if p_limit_date is null then
      If p_next_last = 1 then
      l_limit_date := add_months(p_date,12*p_next_last);
      Else
      l_limit_date := greatest(add_months(l_act_date,12*p_next_last),l_last_act_date);

      End If;
   else
      if p_next_last = 1 then
         l_limit_date := greatest(p_date+1,p_limit_date);
      else
         l_limit_date := least(l_act_date-1,greatest(p_limit_date,l_act_date));
      end if;
   end if;
   --
   l_date := l_act_date+p_next_last;
   while sign(l_limit_date - l_date) <> p_next_last * -1  loop
    derive_schedule(p_assignment_id
                  ,l_date
                  ,l_date);
     --
     d := to_number(to_char(l_date,'J'));
       if not(days_tab(d).hours = 0) then
          if days_tab(d).public_holiday = 'Y' then
             if days_tab(d).public_holiday_override = 'Y' then
                if days_tab(d).absence_non_working = 'Y' then
                   null;
                else
                   l_working_date := l_date;
                   exit;
                end if;
             end if;
          else
             if days_tab(d).public_holiday_in_lieu = 'Y' then
                null;
             else
                if days_tab(d).absence_non_working = 'Y' then
                   null;
                else
                   l_working_date := l_date;
                   exit;
                end if;
             end if;
          end if;
       end if;
     l_date := l_date + p_next_last;
   end loop;
   --

   return l_working_date;
end;
------------------------------------------------------------
function get_last_working_day(p_assignment_id number
                         ,p_effective_date date
                         ,p_date date
                         ,p_limit_date date
                         ) return date is
begin
  return get_next_last_working_day(p_assignment_id
                         ,p_effective_date
                         ,p_date
                         ,p_limit_date
                         ,-1
                         );
end;
--
function get_next_working_day(p_assignment_id number
                         ,p_effective_date date
                         ,p_date date
                         ,p_limit_date date
                         ) return date is
begin
  return get_next_last_working_day(p_assignment_id => p_assignment_id
                         ,p_effective_date => p_effective_date
                         ,p_date => p_date
                         ,p_limit_date => p_limit_date
                         ,p_next_last => 1
                         );
end get_next_working_day;
--
end pay_fr_schedule_calculation;

/
