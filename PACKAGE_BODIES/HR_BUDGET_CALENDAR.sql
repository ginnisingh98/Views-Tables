--------------------------------------------------------
--  DDL for Package Body HR_BUDGET_CALENDAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_BUDGET_CALENDAR" as
/* $Header: pybudcal.pkb 115.1 99/07/17 05:46:32 porting sh $ */
--
 /*===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+
  Name
    hr_budget_calendar
  Purpose
    Maintains budgetary calendars ie. creates and removes time periods
    representing years of calendar.
  Notes
    Used by the PAYWSDCL (Define Budgetary Calendar) form.
  History
    11-Mar-94  J.S.Hobbs   40.0         Date created.
 ============================================================================*/
--
 -- Constants to represent the basic period types.
 WEEKLY      constant varchar2(1) := 'W';
 MONTHLY     constant varchar2(1) := 'M';
 SEMIMONTHLY constant varchar2(1) := 'S';
--
  -- A record structure to hold information on a calendar.
 type t_cal_details is record
 (
  period_set_name        varchar2(80),
  start_date             date,
  number_of_years        number,
  actual_period_type     varchar2(30),
  proc_period_type       varchar2(30),
  number_per_fiscal_year number,
  midpoint_offset        number,
  base_period_type       varchar2(30),
  multiplier             number,
  start_year_number      number
 );
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   midpoint_offset                                                       --
 -- Purpose                                                                 --
 --   Returns the midpoint offset used by a semi-monthly calendar.          --
 -- Arguments                                                               --
 --   See Below.                                                            --
 -- Notes                                                                   --
 --   Used in the PAYWSDCL (Define Budgetary Calendar) form on post query   --
 --   to display the midpoint offset used in semi-monthly calendars.        --
 -----------------------------------------------------------------------------
--
 function midpoint_offset
 (
  p_period_set_name        varchar2,
  p_start_date             date
 ) return number is
--
   v_midpoint_offset number;
--
 begin
--
   -- Find the first time period for the calendar and find how many days are
   -- between the start and end of the period.
   begin
     select tpe.end_date - tpe.start_date + 1
     into   v_midpoint_offset
     from   per_time_periods tpe
     where  tpe.period_set_name = p_period_set_name
       and  tpe.start_date = p_start_date;
   exception
     when no_data_found then
       hr_utility.set_message(801, 'ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE',
				    'hr_budget_calendar.midpoint_offset');
       hr_utility.set_message_token('STEP', '1');
       hr_utility.raise_error;
   end;
--
   return v_midpoint_offset;
--
 end midpoint_offset;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   num_of_cal_yrs                                                        --
 -- Purpose                                                                 --
 --   Counts the number of calendar years that have already been created    --
 --   for a calendar.                                                       --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   Used in the PAYWSDCL (Define Budgetary Calendar) form on post query   --
 --   to display the current number of calendar years created.              --
 -----------------------------------------------------------------------------
--
 function num_of_cal_yrs
 (
  p_period_set_name varchar2
 ) return number is
--
   cursor csr_lock_calendar is
     select cal.period_set_name
     from   pay_calendars cal
     where  cal.period_set_name = p_period_set_name
     for    update;
--
   v_yr_count number := 0;
--
 begin
--
   -- Lock the calendar to stop other users changing the number of calendar
   -- years.
   open csr_lock_calendar;
   close csr_lock_calendar;
--
   -- Count the number of existing periods for the calendar.
   begin
     select count(*)
     into   v_yr_count
     from   per_time_period_sets tps
     where  tps.period_set_name = p_period_set_name;
   exception
     when no_data_found then null;
   end;
--
   return (v_yr_count);
--
 end num_of_cal_yrs;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Ins_time_period                                                       --
 -- Purpose                                                                 --
 --   Create a time period for a calendar.                                  --
 -- Arguments                                                               --
 --   See Below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 procedure Ins_time_period
 (
  p_period_set_name varchar2,
  p_prd_type        varchar2,
  p_yr_num          number,
  p_qtr_num         number,
  p_prd_num         number,
  p_prd_start_date  date,
  p_prd_end_date    date
 ) is
--
 begin
--
   -- Creates a single time period for a calendar if the time period to be
   -- created does not overlap with an existing time period for the calendar.
   insert into per_time_periods
   (time_period_id,
    period_set_name,
    period_name,
    period_type,
    year_number,
    period_year,
    quarter_num,
    period_num,
    start_date,
    end_date,
    last_update_date,
    last_updated_by,
    last_update_login,
    created_by,
    creation_date)
   select
    per_time_periods_s.nextval,
    p_period_set_name,
    to_char(p_prd_num) || ' ' || to_char(p_prd_end_date, 'YYYY') || ' ' ||
      p_prd_type,
    p_prd_type,
    fnd_number.canonical_to_number(to_char(p_prd_end_date, 'YYYY')),
    p_yr_num,
    p_qtr_num,
    p_prd_num,
    p_prd_start_date,
    p_prd_end_date,
    trunc(sysdate),
    0,
    0,
    0,
    trunc(sysdate)
   from  sys.dual;
--
 end ins_time_period;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   time_period_end_date                                                  --
 -- Purpose                                                                 --
 --   Calculates the end date of a period.                                  --
 -- Arguments                                                               --
 --   See Notes.                                                            --
 -- Notes                                                                   --
 --   All period types except Semi-Monthly are defined in terms of a base   --
 --   period type ie. week or month and a multiplier that determines how    --
 --   many of the base period type make up a period.                        --
 --   eg. Semi-Year  ==  6 x month, Fortnight  ==  2 x week etc ...         --
 --   Given the base period type and the multiplier it is possible to       --
 --   calculate the end date of a period given its start date.              --
 -----------------------------------------------------------------------------
--
 function time_period_end_date
 (
  p_period_start_date date,
  p_base_period_type  varchar2,
  p_multiplier        number,
  p_midpoint_offset   number,
  p_saved_end_date    in out date
 ) return date is
--
   v_prd_end_date date;
--
 begin
--
   -- Period type is defined in terms of multiples of weeks eg. fortnight etc...
   if p_base_period_type = WEEKLY then
     return (p_period_start_date + (7 * p_multiplier) - 1);
--
   -- Period type is defined in terms of multiples of months eg. bi-month etc...
   elsif p_base_period_type = MONTHLY then
     return (add_months(p_period_start_date, p_multiplier) - 1);
--
   -- Period type is semi-month ie. each month is split into 2 halves divided
   -- by the midpoint offset eg. 01-jan-1990 - 15-jan-1990, 16-jan-1990 -
   -- 31-jan-1990 etc ... where the midpoint offset would be 15. The midpoint
   -- offset is added to the start date of the fist half and is not absolote
   -- ie. a midpoint offset of 15 does not mean that the first half will
   -- always end on the 15th of the month.
   else
--
     -- To simplify processing of semi-monthly calendars both halves of the
     -- period are calculated together. The first half end date is returned
     -- and the second half is saved. When the function is called again the
     -- second half end date is returned.
     if p_saved_end_date is not null then
--
       v_prd_end_date   := p_saved_end_date;
       p_saved_end_date := null;
       return v_prd_end_date;
--
     else
--
       p_saved_end_date := add_months(p_period_start_date,1) - 1;
       return (p_period_start_date + p_midpoint_offset - 1);
--
     end if;
--
   end if;
--
 end time_period_end_date;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   get_cal_details                                                       --
 -- Purpose                                                                 --
 --   Builds up a record containing information on the calendar. This is    --
 --   required to be able to generate the calendar.                         --
 -- Arguments                                                               --
 --   See Below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 function get_cal_details
 (
  p_period_set_name varchar2,
  p_midpoint_offset number,
  p_number_of_years number
 ) return t_cal_details is
--
   v_cal_details t_cal_details;
   v_num_yrs     number;
--
 begin
--
   v_cal_details.period_set_name := p_period_set_name;
   v_cal_details.midpoint_offset := p_midpoint_offset;
--
   begin
     select cal.start_date,
	    cal.actual_period_type,
            cal.proc_period_type,
	    tpt.number_per_fiscal_year
     into   v_cal_details.start_date,
	    v_cal_details.actual_period_type,
	    v_cal_details.proc_period_type,
	    v_cal_details.number_per_fiscal_year
     from   pay_calendars cal,
	    per_time_period_types tpt
     where  cal.period_set_name = p_period_set_name
       and  tpt.period_type = cal.actual_period_type;
   exception
     when no_data_found then
       hr_utility.set_message(801, 'ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE',
				    'hr_budget_calendar.get_cal_details');
       hr_utility.set_message_token('STEP', '1');
       hr_utility.raise_error;
   end;
--
   -- Find the base period type and multiplier for the period type.
   hr_payrolls.get_period_details
     (v_cal_details.actual_period_type,
      v_cal_details.base_period_type,
      v_cal_details.multiplier);
--
   -- See how many years of the calendar have already been defined.
   v_num_yrs := num_of_cal_yrs(v_cal_details.period_set_name);

   -- If there have not been any calendar years created yet then it is not
   -- necessary to change the definition of the calendar ie. the calendar
   -- start date and number of years can be used.
   -- If a number of years have already been created then the definition of the
   -- calendar has to be changed so that only the new calendar years are
   -- created ie. if 5 years of calendar exist and the number of years is now
   -- 7 years then it is only necessary to create 2 years of calendar starting
   -- from when the 5 years of calendar finished.
   -- If the number of years is actually less than or the same as the number
   -- of existing years then no action needs to be taken.
   if v_num_yrs = 0 then
--
     v_cal_details.number_of_years   := p_number_of_years;
     v_cal_details.start_year_number := 1;
--
   elsif v_num_yrs < p_number_of_years then
--
     -- Find how many years of time periods need to be created.
     v_cal_details.number_of_years := p_number_of_years - v_num_yrs;
--
     -- Set the start date of the calendar to be the day after the last time
     -- period.
     select max(tpe.end_date) + 1
     into   v_cal_details.start_date
     from   per_time_periods tpe
     where  tpe.period_set_name = v_cal_details.period_set_name;
--
     v_cal_details.start_year_number := v_num_yrs + 1;
--
   else
--
     v_cal_details.number_of_years := 0;
--
   end if;
--
   return v_cal_details;
--
 end get_cal_details;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   generate                                                              --
 -- Purpose                                                                 --
 --   Generates a number of years of time periods for a calendar.           --
 -- Arguments                                                               --
 --   p_number_of_years should be the number of calendar years that exist   --
 --   after the code has completed.                                         --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 procedure generate
 (
  p_period_set_name varchar2,
  p_midpoint_offset number,
  p_number_of_years number
 ) is
--
   v_cal_details        t_cal_details;
   v_yr_created         boolean := FALSE;
   v_yr_num             number := 0;
   v_qtr_num            number;
   v_prd_num            number := 0;
   v_prd_start_date     date;
   v_prd_end_date       date;
   v_yr_start_date      date;
   v_yr_end_date        date;
   v_1st_qtr_end_date   date;
   v_2nd_qtr_end_date   date;
   v_3rd_qtr_end_date   date;
   v_4th_qtr_end_date   date;
   v_saved_prd_end_date date;
--
 begin
--
   -- Fetch calendar information required to generate the calendar years ie.
   -- basic period type, number per fiscal year etc ...
   v_cal_details := get_cal_details(p_period_set_name,
		                    p_midpoint_offset,
		                    p_number_of_years);
--
   -- No calendar years need to be created so exit procedure.
   if v_cal_details.number_of_years = 0 then
     return;
   end if;
--
   v_yr_num           := v_cal_details.start_year_number;
   v_yr_start_date    := v_cal_details.start_date;
--
   -- Create v_num_yrs years of time periods for the calendar.
   for v_yr_count in 1..v_cal_details.number_of_years loop
--
     v_yr_created     := FALSE;
     v_yr_end_date    := add_months(v_yr_start_date, 12) - 1;
     v_prd_num        := 1;
     v_prd_start_date := v_yr_start_date;
--
     -- Calculate the quarter end dates for later use in calculating which
     -- quarter a period lies in.
     v_1st_qtr_end_date := add_months(v_yr_start_date,3) - 1;
     v_2nd_qtr_end_date := add_months(v_yr_start_date,6) - 1;
     v_3rd_qtr_end_date := add_months(v_yr_start_date,9) - 1;
     v_4th_qtr_end_date := add_months(v_yr_start_date,12) - 1;
--
     -- Create a calendar year. This is to allow the 2.3 form to query back
     -- calendars created by the 4.0 form and vice versa.
     insert into per_time_period_sets
     (start_date,
      period_set_name,
      period_type,
      end_date_q1,
      end_date_q2,
      end_date_q3,
      end_date_q4,
      month_mid_day,
      year_number)
     values
     (v_yr_start_date,
      v_cal_details.period_set_name,
      v_cal_details.actual_period_type,
      v_1st_qtr_end_date,
      v_2nd_qtr_end_date,
      v_3rd_qtr_end_date,
      v_4th_qtr_end_date,
      v_cal_details.midpoint_offset,
      v_yr_num);
--
     -- Keep looping until a calendars year of time periods have been created.
     loop
--
       -- Get the end date of the period about to be created.
       v_prd_end_date := time_period_end_date
                           (v_prd_start_date,
                            v_cal_details.base_period_type,
                            v_cal_details.multiplier,
                            v_cal_details.midpoint_offset,
			    v_saved_prd_end_date);
--
       -- If the period ends on or overlaps with the end of the calendar year
       -- then adjust its end date so it falls within the calendar year and
       -- also flag that a calendar year of time periods has been created.
       if v_prd_end_date >= v_yr_end_date then
         v_prd_end_date := v_yr_end_date;
         v_yr_created   := TRUE;
       end if;
--
       -- Set the quarter number to the quarter in which the end of the
       -- period falls NB. for period types with a number per fiscal year < 4
       -- then there will not be enough periods to divide between the quarters.
       if v_cal_details.number_per_fiscal_year >= 4 then
         if v_prd_end_date between v_yr_start_date and
				   v_1st_qtr_end_date then
	   v_qtr_num := 1;
         elsif v_prd_end_date between v_1st_qtr_end_date + 1 and
				      v_2nd_qtr_end_date then
	   v_qtr_num := 2;
         elsif v_prd_end_date between v_2nd_qtr_end_date + 1 and
				      v_3rd_qtr_end_date then
	   v_qtr_num := 3;
         else
	   v_qtr_num := 4;
         end if;
       end if;
--
       -- Create time period.
       ins_time_period
	 (v_cal_details.period_set_name,
          v_cal_details.actual_period_type,
	  v_yr_num,
	  v_qtr_num,
          v_prd_num,
          v_prd_start_date,
          v_prd_end_date);
--
       exit when v_yr_created;
--
       -- Increment the period number for the next period and also calculate
       -- the start date of the next period.
       v_prd_num        := v_prd_num + 1;
       v_prd_start_date := v_prd_end_date + 1;
--
     end loop;
--
     v_yr_num        := v_yr_num + 1;
     v_yr_start_date := v_prd_end_date + 1;
--
   end loop;
--
 end generate;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   remove                                                                --
 -- Purpose                                                                 --
 --   Removes a number of years of time periods for a calendar.             --
 -- Arguments                                                               --
 --   p_number_of_years should be the number of calendar years that exist   --
 --   after the code has completed.                                         --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 procedure remove
 (
  p_period_set_name   varchar2,
  p_number_of_years   number,
  p_at_least_one_year boolean
 ) is
--
   cursor csr_budget_values is
     select tpe.time_period_id
     from   per_time_periods tpe
     where  tpe.period_set_name = p_period_set_name
       and  tpe.period_year     > p_number_of_years
       and  exists
	    (select null
	     from   per_budget_values bv
	     where  bv.time_period_id = tpe.time_period_id);
--
   v_time_period_id number;
--
 begin
--
   -- At least one year of time periods must exist for the calendar unless the
   -- calendar is being removed where all time period need to be removed.
   if p_at_least_one_year and p_number_of_years < 1 then
       hr_utility.set_message(801, 'HR_7087_TIME_ONE_YR_AT_LEAST');
       hr_utility.raise_error;
   else
--
     -- See if any of the time periods to be removed are used by a budget.
     open csr_budget_values;
     fetch csr_budget_values into v_time_period_id;
     if csr_budget_values%found then
       close csr_budget_values;
       hr_utility.set_message(801, 'HR_7088_TIME_USED_IN_BUDGET');
       hr_utility.raise_error;
     else
       close csr_budget_values;
     end if;
--
     -- Remove all time periods that exist in years greater than the new
     -- number of years.
     delete from per_time_periods tpe
     where  tpe.period_set_name = p_period_set_name
       and  tpe.period_year     > p_number_of_years;
--
     -- Remove calendar years.
     delete from per_time_period_sets tps
     where  tps.period_set_name = p_period_set_name
       and  tps.year_number > p_number_of_years;
--
   end if;
--
 end remove;
--
end HR_BUDGET_CALENDAR;

/
