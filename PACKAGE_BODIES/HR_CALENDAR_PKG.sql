--------------------------------------------------------
--  DDL for Package Body HR_CALENDAR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CALENDAR_PKG" as
/* $Header: hrcalapi.pkb 120.1.12010000.2 2008/11/07 11:03:35 pbalu noship $ */
--
--------------------------------------------------------------------------------
/*
+==============================================================================+
|                       Copyright (c) 1994 Oracle Corporation                  |
|                          Redwood Shores, California, USA                     |
|                               All rights reserved.                           |
+==============================================================================+
--
Name
	Calendars Business Process
Purpose
	To provide routines to give information about calendars
History
	05 sep 95	N Simpson	Created
	07 Sep 95	N Simpson	Added function purpose_usage_id
Version Date        BugNo     Author    Comment
-------+-----------+---------+---------+--------------------------------------
40.3    18-Jul_97   513292    RThirlby  Created another overload of procedure
                                        denormalise_calendar. Altered function
                                        total_availability to accept parameters
                                        for both bg and person pattern in the
                                        same (linked) absence.
40.4	29-Sep-97   504386    RThirlby	Changes made to derive_pattern_cycle
					to enhance performance.
40.5    11-Nov-97   572460    AMills    Added exit to reconcile_schedule to trap
					values where the normal pattern stack
					pointer exceeds the number of rows in
					the normal_pattern table.
40.6    14-Nov-97   504386    AMills    Added extra criteria to 'derive_pattern
					cycle' to ensure normal_pattern table
					is restored for absence periods greater
					than the original time period, where the
					calendar remains the same. Cancelled
					last alteration to reconcile_schedule as
					no longer necessary.
40.7    27-Nov-97  584613    RThirlby	Global variables re-initiated at start
 					of denormalise_calendar, so that the
					Schedules window can be re-queried.
40.8    03-JUL-98  655707    A.Myers 	Added processing_level parameter which
					indicates how much processing needs to
					be done, whether the existing calendar
					can be used or not (used by calling
                                        package SSP_SSP_PKG only).
115.9  23-jul-02 1404898     vmkhande    The denormalise_calendar procedure in
                                         TOTAL_AVAILABILITY funciton is called
                                         if the prcoessing level is less than 2.
                                         When this funciton is called for the
                                         BG calendar usage, the processing level
                                         is set as 2 hence the
                                         denormalise_calendar is not called and
                                         the schedule stack holds incorrect date
					 values. The fix is: The condtion which
					 check the parameter value is to be
					 changed to <= 2.
115.10   15-JUN-04  3669001  kthampan   Changes to the derive_pattern_cycle procdure
                                        to use g_period_from instead of p_period_from
                                        when extending the pattern cycle.
115.11   15-JUN-04           kthampan   Fix GSCC warnings
115.12   24-MAR-08  6850908  pbalu      When a person has two Qualifying patterns and both are created
                                        after the absence start date and there is a gap between the two
                                        Person qualifying patterns then while saving or updating the absence
                                        oracle error no data found occurs
*/
--------------------------------------------------------------------------------
type number_table is table of number index by binary_integer;
type varchar_table is table of varchar2 (30) index by binary_integer;
type date_table is table of date index by binary_integer;
--
one_second constant number := 1/86400; -- a second as a proportion of one day
--
-- Normal pattern construction variables
--
type pattern_info is record (
	availability	varchar_table,
	duration_days	number_table,
	stored_pattern_id	number :=0,
	stored_number_of_bits	number :=0);
	--
type stack is record (
	--
	pointer		integer :=1,
	run_out		boolean := FALSE,
	start_date	date_table,
	end_date	date_table,
	level		number_table,
	availability	varchar_table);
	--
calendar_exception	stack;
usage_exception		stack;
normal_pattern		stack;
schedule		stack;
empty_stack		stack;
--
pattern			pattern_info;
empty_pattern		pattern_info;
index_no		integer;
g_hc_package            constant varchar2 (18) := 'hr_calendar_pkg.';
g_calendar_id		number; --global calendar ID
g_period_from		date;   --global period from
g_period_to		date;   --global period to
initialise_flag		boolean := false;
--
cursor pattern_bits (p_pattern_id	in number) is
--
-- Get the pattern by denormalising the duration of each bit of the pattern
-- to show the duration and availability. The sql separates those bits of the
-- pattern which are directly based on time units from those which are
-- themselves patterns and require a further step to get the time units. There
-- is a business rule which limits the pattern hierarchy to two levels.
--
	select	bit1.time_unit_multiplier,
		bit1.base_time_unit,
		con1.sequence_no,
		0,
		con1.availability
	from	hr_pattern_constructions	CON1,
		hr_pattern_bits			BIT1
	where	bit1.pattern_bit_id = con1.pattern_bit_id
	and	con1.pattern_id = p_pattern_id
	union all
	select	bit2.time_unit_multiplier,
		bit2.base_time_unit,
		con2.sequence_no,
		con3.sequence_no,
		con3.availability
	from	hr_pattern_bits			BIT2,
		hr_pattern_constructions	CON2,
		hr_pattern_constructions	CON3
	where	bit2.pattern_bit_id = con3.pattern_bit_id
	and	con2.component_pattern_id = con3.pattern_id
	and	con2.pattern_id = p_pattern_id
	order by 3,4;
--------------------------------------------------------------------------------
--
function TO_DAYS (
--
-- Convert user-defined time unit into days for ease of comparison and
-- manipulation.
--
	quantity	number,
	units		varchar2) return number is
--
conversion_factor	number :=1;
--
begin
--
if units = 'H' then
  conversion_factor := 24;
--
elsif units = 'W' then
  conversion_factor := 1/7;
--
end if;
--
return (quantity / conversion_factor);
--
end to_days;
--------------------------------------------------------------------------------
--
procedure DERIVE_PATTERN_CYCLE (
--
-- Converts a pattern from a single iteration of undated durations into a
-- schedule of dated chunks.
--
	p_calendar_id	number,
        p_period_from   date,
	p_period_to	date,
	p_called_from_SSP boolean default false) is
--
cursor calendar is
	--
	-- Get the details of the calendar
	--
	select	pattern_start_position,
		calendar_start_time,
		pattern_id
	from	hr_calendars
	where	calendar_id = P_CALENDAR_ID;
--
start_position      integer;
start_time          date;
l_pattern_id        number;
cycle_date          date;
n                   integer :=0;
first_bit	    integer :=1;
total_duration_time number :=0;
duration_time       number :=0;
first_loop          boolean;
old_cycle_date      date;
counter             integer := 0;
l_proc  varchar2 (42) := g_hc_package||'Derive_Pattern_Cycle';
--
begin
--
hr_utility.set_location('Entering:'||l_proc,1);
--
-- Find out which pattern we are dealing with, where within the pattern sequence
-- to start the calendar, and what the start date for the pattern is.
--
-- Bug 504386 - If the same calendar is being passed in, then use the values
-- already in the pl/sql table normal_pattern.
--
if g_calendar_id is null or
   g_calendar_id <> p_calendar_id or
   p_period_to not between g_period_from and g_period_to or
   (p_period_from < g_period_from or p_called_from_SSP = false)
then
   if p_called_from_SSP = true
   then
      if (g_period_from is null or p_period_from < g_period_from)
      then
      --
      -- Do not reset g_period_from if we are currently using it (i.e. it is
      -- not null, but set it if p_period_from is earlier so that we get a
      -- complete calendar.
      --
         g_period_from := p_period_from;
      end if;
   else
      g_period_from := p_period_from;
   end if;
   --
   hr_utility.set_location('      In:'||l_proc||', rederiving calendar',10);
   --
   g_period_to   := p_period_to;
   g_calendar_id := p_calendar_id;
   index_no := 1;
   --
   open calendar;
   fetch calendar into start_position, cycle_date, l_pattern_id;
   close calendar;
   --
   -- Get required pattern from the database, and convert it to units of a day.
   --
   if l_pattern_id <> pattern.stored_pattern_id then
      --
      -- Get pattern construction and cache it in private global variables
      --
      for next_bit in pattern_bits (l_pattern_id) LOOP
         counter := counter+1;
         --
         pattern.duration_days (counter) :=
                    hr_calendar_pkg.to_days (next_bit.time_unit_multiplier,
                                             next_bit.base_time_unit);
         pattern.availability (counter) := next_bit.availability;
      end loop;
      --
      pattern.stored_pattern_id := l_pattern_id;
      pattern.stored_number_of_bits := counter;
   end if;
   --
   -- Bug 504386 - Find out the patterns total duration time
   --
   for n in first_bit..pattern.stored_number_of_bits LOOP
      total_duration_time := total_duration_time + pattern.duration_days (n);
   end loop;
   --
   -- Bug 504386 - Roll forward to the periods required.
   first_loop := TRUE;
   --
   -- Bug 3669001 - change from p_period_from to g_period_from
   while cycle_date <= g_period_from
   loop
      old_cycle_date := cycle_date;
      --
      if first_loop = TRUE
      then
         --
         -- If we are in the first pass through the loop (ie we are on the first
         -- iteration of the pattern) then we must take account of the position
         -- in the pattern on which the calendar starts, because we may not want
         -- to start at the beginning of the pattern.
         --
         first_loop := FALSE;
         first_bit := start_position;
         for n in first_bit..pattern.stored_number_of_bits LOOP
            duration_time := duration_time + pattern.duration_days (n);
         end loop;
      else
         --
         -- If we are in any but the first pass through the loop, then we always
         -- take the whole pattern into account.
         --
         duration_time := total_duration_time;
      end if;
      --
      cycle_date := cycle_date + duration_time;
   end loop;
   --
   --6850908 Begin
   --cycle_date := old_cycle_date;
    --before assigning the old cycle date the value is checked
   IF old_cycle_date <= g_period_from THEN
   cycle_date := old_cycle_date;
   END IF;
   --6850908 End
   --
   -- Generate a denormalised calendar by placing copies of the pattern end to
   -- end, starting with the calendar start date and ending with the end of our
   -- period of interest.
   --
   while cycle_date <= p_period_to
   LOOP
      --
      -- Go through the cached pattern, deriving the dates of the calendar by
      -- taking the date we have reached so far and adding the duration of the
      -- next bit of the pattern to it.
      --
      for n in 1..pattern.stored_number_of_bits LOOP
         --
         -- Derive the dates of the next bit of the calendar.
         --
         normal_pattern.start_date (index_no) := cycle_date;
         --
         normal_pattern.end_date (index_no) :=
               normal_pattern.start_date (index_no) + pattern.duration_days (n);
         --
         -- Increment 'date reached so far' by the duration of the pattern bit.
         --
         cycle_date := cycle_date + pattern.duration_days (n);
         --
         -- Derive the availability value for the next bit of the calendar.
         --
         normal_pattern.availability (index_no) := pattern.availability (n);
         --
         index_no := index_no + 1;
         --
      end loop;
   end loop;
end if;
--
hr_utility.set_location('Leaving :'||l_proc,100);
--
end derive_pattern_cycle;
--------------------------------------------------------------------------------
--
procedure DERIVE_CALENDAR_EXCEPTIONS (
--
-- Cache the calendar exceptions in a pl/sql data structure for use in the
-- reconcile_schedule procedure.
--
p_calendar_id		number,
p_period_start_time	date,
p_period_end_time	date) is
--
cursor calendar_exceptions is
	--
	-- Get all the calendar exceptions for the calendar, which are within
	-- our period of interest
	--
	select	exc.pattern_id,
		exc.exception_start_time
	from	hr_pattern_exceptions	EXC,
		hr_exception_usages	EXC_USE
	where	exc.exception_start_time < p_period_end_time
	and	exc.exception_end_time > p_period_start_time
	and	exc.exception_id = exc_use.exception_id
	and	exc_use.calendar_id = p_calendar_id
	order by exc.exception_start_time;
--
index_no		integer :=1;
cycle_date		date;
--
begin
--
for next_exception in calendar_exceptions LOOP
  --
  -- For each exception in the period on the calendar, derive the dates of each
  -- bit of the pattern on which the exception is based.
  --
  cycle_date := next_exception.exception_start_time;
  --
  for next_exception_bit in pattern_bits (next_exception.pattern_id)
  LOOP
    --
    calendar_exception.start_date (index_no) := cycle_date;
    --
    -- Increment the date reached so far by the duration of the next pattern bit
    --
    cycle_date := cycle_date
	+ (hr_calendar_pkg.to_days (next_exception_bit.time_unit_multiplier,
					next_exception_bit.base_time_unit)) ;
					--
    calendar_exception.end_date (index_no) := cycle_date ;
    --
    calendar_exception.availability (index_no)
	:= next_exception_bit.availability;
    --
    index_no := index_no+1;
    --
  end loop;
  --
end loop;
--
end derive_calendar_exceptions;
--------------------------------------------------------------------------------
--
procedure DERIVE_USAGE_EXCEPTIONS (
--
p_calendar_usage_id	number,
p_period_start_time	date,
p_period_end_time	date) is
--
cursor usage_exceptions is
	--
	-- Get all the exceptions for the specified usage which are within the
	-- period of interest.
	--
	select	exc.pattern_id,
		exc.exception_start_time
	from	hr_pattern_exceptions	EXC,
		hr_exception_usages	EXC_USE
	where	exc.exception_start_time < p_period_end_time
	and	exc.exception_end_time > p_period_start_time
	and	exc.exception_id = exc_use.exception_id
	and	exc_use.calendar_usage_id = p_calendar_usage_id
	order by exc.exception_start_time;
--
index_no		integer :=1;
cycle_date		date;
--
begin
--
for next_exception in usage_exceptions LOOP
  --
  -- For each exception, derive the dates of each bit of the pattern on which
  -- the exception is based.
  --
  cycle_date := next_exception.exception_start_time;
  --
  for next_exception_bit in pattern_bits (next_exception.pattern_id)
  LOOP
    --
    usage_exception.start_date (index_no) := cycle_date;
    --
    -- Increment the date reached so far by the duration of the next pattern bit
    --
    cycle_date := cycle_date
	+ (hr_calendar_pkg.to_days (next_exception_bit.time_unit_multiplier,
 					next_exception_bit.base_time_unit)) ;
					--
    usage_exception.end_date (index_no) := cycle_date  ;
    --
    usage_exception.availability (index_no) := next_exception_bit.availability;
    --
    index_no := index_no+1;
    --
  end loop;
  --
end loop;
--
end derive_usage_exceptions;
--------------------------------------------------------------------------------
procedure RECONCILE_SCHEDULE (
--
-- Reconcile the repeating pattern on which the calendar is based with all the
-- exceptions to that pattern at calendar and usage level.
--
p_period_from	date,
p_period_to	date) is
--
cycle_date	date := p_period_from;
--
begin
--
-- Reset the pointers
--
usage_exception.pointer :=1;
calendar_exception.pointer :=1;
normal_pattern.pointer :=1;
usage_exception.run_out := FALSE;
calendar_exception.run_out := FALSE;
normal_pattern.run_out := FALSE;
--
-- Construct the schedule from the start to the end of the requested period
--
while cycle_date < p_period_to LOOP
  --
  -- There are 3 stacks to be merged; the normal pattern, the exceptions
  -- which apply to the calendar as a whole (calendar exceptions), and
  -- the exceptions which apply only to a particular entity (usage
  -- exceptions).
  --
  -- Set the pointers of each stack to the current or next date
  --
  -- Set the usage exception stack pointer
  --
  if (not usage_exception.run_out) then
    --
    begin
    --
    LOOP
      --
      -- Find the first row which is later than the date we have reached so far
      --
      exit when usage_exception.end_date (usage_exception.pointer) > cycle_date;
      usage_exception.pointer := usage_exception.pointer +1;
      --
    end loop;
    --
    exception
    when no_data_found then
      --
      -- There are no more rows in the data structure so do not attempt more
      -- fetches. Set flag to prevent this.
      --
      usage_exception.run_out := TRUE;
      --
    end;
    --
  end if;
  --
  -- Set the calendar excption stack pointer
  --
  if (not calendar_exception.run_out) then
    --
    begin
    --
    LOOP
      --
      -- Find the first row which is later than the date we have reached so far
      --
      exit when calendar_exception.end_date (calendar_exception.pointer)
	> cycle_date;
      calendar_exception.pointer := calendar_exception.pointer +1;
      --
    end loop;
    --
    exception
    when no_data_found then
      --
      -- There are no more rows in the data structure so do not attempt more
      -- fetches. Set flag to prevent this.
      --
      calendar_exception.run_out := TRUE;
      --
    end;
    --
  end if;
  --
  -- Set the normal pattern stack pointer
  --
  if (not normal_pattern.run_out) then
    --
    begin
    --
    LOOP
      --
      exit when normal_pattern.end_date (normal_pattern.pointer) > cycle_date;
      normal_pattern.pointer := normal_pattern.pointer +1;
      --
    end loop;
    --
    exception
    when no_data_found then
      normal_pattern.run_out := TRUE;
    end;
    --
  end if;
  --
  schedule.start_date (schedule.pointer) := cycle_date;
  --
  if (not usage_exception.run_out)
  and usage_exception.start_date (usage_exception.pointer) <=cycle_date then
    --
    -- We are currently on a usage exception. Usage exceptions override
    -- all other levels, so the schedule takes on all the values of the
    -- usage exception.
    --
    schedule.level (schedule.pointer) := 3;
    schedule.availability (schedule.pointer)
	:= usage_exception.availability (usage_exception.pointer);
    schedule.end_date (schedule.pointer)
	:= usage_exception.end_date (usage_exception.pointer);
    --
  elsif (not calendar_exception.run_out)
  and calendar_exception.start_date (calendar_exception.pointer)
	<= cycle_date then
    --
    -- We are currently on a calendar exception. Assign the level and
    -- availability values of the calendar exception to the schedule
    --
    schedule.level (schedule.pointer) := 2;
    schedule.availability (schedule.pointer)
	:= calendar_exception.availability (calendar_exception.pointer);
    --
    -- Before we can assign the end date value to the schedule, we must
    -- determine if there is a usage exception starting before the calendar
    -- exception ends, because that start date would take precedence
    --
    if (not usage_exception.run_out)
    and usage_exception.start_date (usage_exception.pointer)
	< calendar_exception.end_date (calendar_exception.pointer)
    then
      schedule.end_date (schedule.pointer)
	:= usage_exception.start_date (usage_exception.pointer) ;
    else
      schedule.end_date (schedule.pointer)
	:= calendar_exception.end_date (calendar_exception.pointer);
    end if;
    --
  else
    --
    -- If we get to this point, there must be no exceptions so we are on the
    -- normal pattern. Assign the level and availability values to those of
    -- the normal pattern.
    --
    schedule.level (schedule.pointer) := 1;
    schedule.availability (schedule.pointer)
	:= normal_pattern.availability (normal_pattern.pointer);
    --
    -- Before we can assign the end date of the normal pattern bit to the
    -- schedule, we must determine if there are any exceptions which start
    -- before the normal bit ends. The start of such an exception would take
    -- precedence over the end of the normal pattern bit.
    --
    -- First check for usage exceptions
    --
    if (not usage_exception.run_out)
    and usage_exception.start_date (usage_exception.pointer)
	< normal_pattern.end_date (normal_pattern.pointer) then
      --
      schedule.end_date (schedule.pointer)
	:= usage_exception.start_date (usage_exception.pointer) ;
      --
    -- Now check for calendar exceptions
    --
    elsif (not calendar_exception.run_out)
    and calendar_exception.start_date (calendar_exception.pointer)
	< normal_pattern.end_date (normal_pattern.pointer) then
      --
      schedule.end_date (schedule.pointer) :=
      calendar_exception.start_date (calendar_exception.pointer) ;
      --
    else
      --
      -- There are no exceptions before the normal pattern bit ends
      --
      schedule.end_date (schedule.pointer)
	:= normal_pattern.end_date (normal_pattern.pointer);
      --
    end if;
    --
  end if;
  --
  if schedule.end_date (schedule.pointer) > p_period_to then
    --
    -- Drag the end date back to the end of the period
    --
    schedule.end_date (schedule.pointer) := p_period_to;
    --
  end if;
  --
  -- Move on to the next bit of the schedule
  --
  cycle_date := schedule.end_date (schedule.pointer) + one_second ;
  --
  schedule.pointer := schedule.pointer +1;
  --
end loop;
--
end reconcile_schedule;
--------------------------------------------------------------------------------
--
function START_DATE (row_number integer) return date is
--
-- Returns the start date of the pl/sql table row identified by the row_number
--
l_start_date	date;
--
begin
--
l_start_date := schedule.start_date (row_number);
--
return l_start_date;
--
exception
when no_data_found then
return null;
end start_date;
--------------------------------------------------------------------------------
--
function END_DATE (row_number integer) return date is
--
-- Returns the end date of the pl/sql table row identified by the row_number
--
begin
--
return schedule.end_date (row_number);
--
exception
when no_data_found then
return null;
end end_date;
--------------------------------------------------------------------------------
--
function AVAILABILITY_VALUE (row_number integer) return varchar2 is
--
-- Returns the availability of the pl/sql table row identified by the row_number
--
begin
--
return schedule.availability (row_number);
--
exception
when no_data_found then
return null;
end availability_value;
--------------------------------------------------------------------------------
--
function SCHEDULE_LEVEL_VALUE (row_number integer) return number is
--
-- Returns the level of the pl/sql table row identified by the row_number
--
begin
--
return schedule.level (row_number);
--
exception
when no_data_found then
return null;
end schedule_level_value;
--------------------------------------------------------------------------------
--
procedure DENORMALISE_CALENDAR (
--
-- Derive a denormalised calendar into an internal pl/sql data structure, for
-- the calendar usage passed in. Take into account the repetitive pattern on
-- which the calendar is based, and all exceptions for both the calendar itself
-- and for the usage.
-- NB This procedure is OVERLOADED 3 times! This one is called by SSP.
--
-- Bug 513292 - new cursor which returns both BG and person patterns depending
--              which parameters are passed in.
--
p_person_purpose_usage_id	number,
p_person_primary_key_value	number,
p_bg_purpose_usage_id   	number,
p_bg_primary_key_value     	number,
p_period_from			date,
p_period_to			date,
p_called_from_SSP               boolean default false) is
--
cursor calendar is
	--
	-- Get the calendars and usages
	--
	select	use.calendar_usage_id,
		use.calendar_id,
		use.start_date,
		use.end_date
	from	hr_calendar_usages 	USE
	where	use.purpose_usage_id = p_bg_purpose_usage_id
	and	use.primary_key_value = p_bg_primary_key_value
	and	use.start_date <= p_period_to
	and	use.end_date >= p_period_from
	UNION ALL
        select  use.calendar_usage_id,
                use.calendar_id,
                use.start_date,
                use.end_date
        from    hr_calendar_usages      USE
        where   use.purpose_usage_id = p_person_purpose_usage_id
        and     use.primary_key_value = p_person_primary_key_value
        and     use.start_date <= p_period_to
        and     use.end_date >= p_period_from
        order by 3;
--
start_of_period	date;
end_of_period	date;
--
begin
--
-- Clear the data structures
--
schedule := empty_stack;
--
-- Denormalise the exceptions for the usage and hold them internally
--
for each_calendar_usage in calendar
LOOP
   --
   start_of_period := greatest (each_calendar_usage.start_date, p_period_from);
   end_of_period := least (each_calendar_usage.end_date, p_period_to);
   --
   if initialise_flag <> true then
      normal_pattern := empty_stack;
      initialise_flag := true;
      calendar_exception := empty_stack;
      usage_exception := empty_stack;
   end if;
   --
   derive_pattern_cycle(each_calendar_usage.calendar_id,
                        start_of_period, end_of_period,
                        p_called_from_SSP);
   --
   derive_calendar_exceptions(each_calendar_usage.calendar_id,
                        start_of_period, end_of_period);
   --
   derive_usage_exceptions (each_calendar_usage.calendar_usage_id,
                        start_of_period, end_of_period);
   --
   reconcile_schedule (start_of_period, end_of_period);
   --
end loop;
--
end denormalise_calendar;
--------------------------------------------------------------------------------
--
procedure DENORMALISE_CALENDAR (
--
-- Derive a denormalised calendar into an internal pl/sql data structure, for
-- the calendar usage passed in. Take into account the repetitive pattern on
-- which the calendar is based, and all exceptions for both the calendar itself
-- and for the usage.
-- NB This procedure is OVERLOADED 3 times!
--
p_purpose_usage_id       number,
p_primary_key_value      number,
p_period_from            date,
p_period_to              date) is
--
cursor calendar is
        --
        -- Get the calendars and usages
        --
        select  use.calendar_usage_id,
                use.calendar_id,
                use.start_date,
                use.end_date
        from    hr_calendar_usages      USE,
                hr_calendars            CAL
        where   use.purpose_usage_id = p_purpose_usage_id
        and     use.primary_key_value = p_primary_key_value
        and     use.start_date <= p_period_to
        and     use.end_date >= p_period_from
        and     cal.calendar_id = use.calendar_id
        order by use.start_date;
--
start_of_period date;
end_of_period   date;
--
begin
--
-- Bug 584613 - re-initialise global variables so that the Schedules window can
-- be re-queried.
--
g_period_from := null;
g_period_to   := null;
g_calendar_id := null;
--
-- Clear the data structures
--
schedule := empty_stack;
--
-- Denormalise the exceptions for the usage and hold them internally
--
for each_calendar_usage in calendar
LOOP
  --
  start_of_period := greatest (each_calendar_usage.start_date,
                                p_period_from);
  end_of_period := least (each_calendar_usage.end_date,
                                p_period_to);
                                --
  normal_pattern := empty_stack;
  calendar_exception := empty_stack;
  usage_exception := empty_stack;
  --
  derive_pattern_cycle  (each_calendar_usage.calendar_id,
                        start_of_period,
                        end_of_period);
  --
  derive_calendar_exceptions    (each_calendar_usage.calendar_id,
                                start_of_period,
                                end_of_period);
  --
  derive_usage_exceptions (each_calendar_usage.calendar_usage_id,
                        start_of_period,
                        end_of_period);
--
  reconcile_schedule    (start_of_period,
                        end_of_period);
--
end loop;
--
end denormalise_calendar;
------------------------------------------------------------------------------
--
procedure DENORMALISE_CALENDAR (
--
-- Derive the denormalised calendar into an internal data structure. This
-- procedure does not require that usages be defined for the calendar and does
-- not take any usage exceptions into account.
-- NB This procedure is OVERLOADED 3 times!
--
p_calendar_id		number,
p_calendar_start_time	date,
p_period_from		date,
p_period_to		date) is
--
start_of_period	date := greatest (p_period_from, p_calendar_start_time);
end_of_period	date := p_period_to;
--
begin
-- Bug 584613 - re-initialise global variables so that the Schedules window can
-- be re-queried.
--
g_period_from := null;
g_period_to   := null;
g_calendar_id := null;
--
-- Clear the data structures
--
schedule := empty_stack;
usage_exception := empty_stack;
normal_pattern := empty_stack;
calendar_exception := empty_stack;
--
-- Get the pattern on which the calendar is based
--
derive_pattern_cycle	(p_calendar_id,
                        start_of_period,
			end_of_period);
--
-- Get all the exceptions to the pattern which apply to the calendar
--
derive_calendar_exceptions	(p_calendar_id,
				start_of_period,
				end_of_period);
--
reconcile_schedule	(start_of_period,
			end_of_period);
--
end denormalise_calendar;
--------------------------------------------------------------------------------
--
function SCHEDULE_ROWCOUNT return number is
--
-- Returns the number of rows in the internal plsql data structure which stores
-- the denormalised calendar.
--
begin
--
return greatest (schedule.pointer -1,0);
--
end schedule_rowcount;
--------------------------------------------------------------------------------
--
function TOTAL_AVAILABILITY (
--
-- Returns the amount of time within a calendar for an individual that is
-- marked as having a specified availability. Eg how much time (in days) a
-- person is 'on-call'.
--
-- Bug 513292 - parameters added so that both BG and person patterns can be
--              returned for one (linked absence).
-- Bug 701750 - parameter p_processing_level to control amount of processing,
--              if called by SSP package SSP_SSP_PKG.
--
p_availability			varchar2,
p_person_purpose_usage_id	number,
p_person_primary_key_value	number,
p_bg_purpose_usage_id       	number,
p_bg_primary_key_value      	number,
p_period_from			date,
p_period_to			date,
p_processing_level              number default 0) return number is
--
l_proc  varchar2 (42) := g_hc_package||'Total_Availability';
l_called_from_SSP  boolean := false;
l_total            number :=0;
l_start_date date;
l_end_date   date;
--
begin
--
hr_utility.set_location('Entering:'||l_proc||'. Processing level: '||
                         to_char(p_processing_level),1);
--
if p_processing_level > 0
then
   l_called_from_SSP  := true;
end if;
--
-- derive the calendar for the required period
--
if p_processing_level <= 2 or g_period_from is null
then
   denormalise_calendar(p_person_purpose_usage_id,
                        p_person_primary_key_value,
                        p_bg_purpose_usage_id,
                        p_bg_primary_key_value,
                        p_period_from,
                        p_period_to,
                        l_called_from_SSP);
end if;
--
-- Loop through the schedule, adding up the duration of any period during
-- which the availability matches the required availability value.
--
for this_row in 1..schedule_rowcount loop
--   hr_utility.trace('Schedule rec: '||to_char(this_row) ||
--                    '   Availability: '||schedule.availability (this_row));
--   hr_utility.trace('       Dates: Start:'||
--                    to_char(schedule.start_date (this_row)) || ', End:' ||
--                    to_char(schedule.end_date (this_row)));
   --
   if schedule.availability (this_row) = p_availability then
      l_start_date := schedule.start_date(this_row);
      l_end_date   := schedule.end_date(this_row);
      --
      if p_processing_level > 1
      then
         if l_start_date < p_period_to
         then
            if l_end_date > p_period_from
            then
               if l_start_date < p_period_from
               then
                  l_start_date := p_period_from;
               end if;

               if l_end_date > p_period_to
               then
                  l_end_date := p_period_to;
               end if;

               l_total := l_total + (l_end_date - l_start_date);

               if p_processing_level = 3
               then
                  exit;
               end if;
            end if;
         else
            exit;
         end if;
      else
         l_total := l_total + (l_end_date - l_start_date);
      end if;
   end if;
end loop;
--
hr_utility.set_location('Leaving :'||l_proc||'. Returning '||
                        substr(to_char(l_total),1,8)||' days.',100);
--
return l_total;
--
end total_availability;
--------------------------------------------------------------------------------
function AVAILABILITY (
--
-- Returns the availability value for an individual which is valid at a
-- specified time. Eg At 8 o'clock on 12th March 1995, what is Fred Bloggs'
-- availability?
--
	p_date_and_time		date,
	p_purpose_usage_id	number,
	p_primary_key_value	number)
	--
	return varchar2 is
	--
this_row	integer := 1;
--
begin
--
denormalise_calendar (	p_purpose_usage_id,
			p_primary_key_value,
			p_date_and_time-1,
			p_date_and_time+1);
--
-- Find the row in the internal data structure which covers the required time
--
while this_row <> Schedule_rowcount LOOP
  --
  exit when p_date_and_time between schedule.start_date (this_row) and schedule.end_date (this_row);
  --
  this_row := this_row +1;
  --
end loop;
--
return schedule.availability (this_row);
--
end availability;
--------------------------------------------------------------------------------
function PURPOSE_USAGE_ID (
--
-- Return the purpose usage id for a given entity name and pattern purpose
--
p_entity_name		varchar2,
p_pattern_purpose	varchar2
) return number is
--
cursor csr_purpose_usage is
	--
	-- Get the pattern purpose usage id
	--
	select	purpose_usage_id
	from	hr_pattern_purpose_usages
	where	entity_name = p_entity_name
	and	pattern_purpose = p_pattern_purpose;
	--
l_purpose_usage_id	number := null;
--
begin
--
open csr_purpose_usage;
fetch csr_purpose_usage into l_purpose_usage_id;
close csr_purpose_usage;
--
return l_purpose_usage_id;
--
end purpose_usage_id;
--------------------------------------------------------------------------------
--
end hr_calendar_pkg;

/
