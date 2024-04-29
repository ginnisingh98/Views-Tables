--------------------------------------------------------
--  DDL for Package Body HR_PAYROLLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PAYROLLS" as
/* $Header: pypyroll.pkb 120.1.12010000.2 2009/09/03 04:34:49 sivanara ship $ */
--
-- Package constants, denoting the base period types.
--
WEEKLY CONSTANT varchar2(1) := 'W';
MONTHLY CONSTANT varchar2(1) := 'M';
SEMIMONTHLY CONSTANT varchar2(1) := 'S';
TEN_DAYS CONSTANT varchar2(1) := 'T';	-- Bug 5935976
--
-- Disable/enable the period name display fetch inline with the view
g_enable_period_name_fetch BOOLEAN := TRUE;
--
--
-- Warning variables used by the form
g_weeks_reset_warn BOOLEAN := FALSE;
g_end_date_changed_warn BOOLEAN := FALSE;
g_no_of_weeks_reset NUMBER := 0;
g_reset_period_start_date per_time_periods.start_date%type;
g_reset_period_end_date per_time_periods.end_date%type;
g_reset_period_name per_time_periods.period_name%type;
g_new_end_date per_time_periods.end_date%type;
g_constant_end_date BOOLEAN := FALSE;
--
-- This procedure does not currently use PER_TIME_PERIOD_RULES, since that
-- table is subject to some change.
--
procedure get_period_details (p_proc_period_type in varchar2,
                              p_base_period_type out nocopy varchar2,
                              p_multiple out nocopy number) is
--
  proc_name CONSTANT varchar2(50) := 'hr_payrolls.get_period_details';
--
  no_periods per_time_period_types.number_per_fiscal_year%type;
--
begin
  hr_utility.set_location(proc_name, 1);
  select tp.number_per_fiscal_year
  into no_periods
  from per_time_period_types tp
  where tp.period_type = p_proc_period_type;
--
  -- Use the number of periods in a fiscal year to deduce the base
  -- period and multiple.
  if no_periods = 1 then             -- Yearly
    p_base_period_type := MONTHLY;
    p_multiple := 12;
  elsif no_periods = 2 then          -- Semi yearly
    p_base_period_type := MONTHLY;
    p_multiple := 6;
  elsif no_periods = 4 then          -- Quarterly
    p_base_period_type := MONTHLY;
    p_multiple := 3;
  elsif no_periods = 6 then          -- Bi monthly
    p_base_period_type := MONTHLY;
    p_multiple := 2;
  elsif no_periods = 12 then         -- Monthly
    p_base_period_type := MONTHLY;
    p_multiple := 1;
  elsif no_periods = 13 then         -- Lunar monthly
    p_base_period_type := WEEKLY;
    p_multiple := 4;
  elsif no_periods = 24 then         -- Semi monthly
    p_base_period_type := SEMIMONTHLY;
    p_multiple := 1;                 -- Not used for semi-monthly
  elsif no_periods = 26 then         -- Fortnightly
    p_base_period_type := WEEKLY;
    p_multiple := 2;
  elsif no_periods = 36 then         -- 10 Day --Bug 5935976
    p_base_period_type := TEN_DAYS;
    p_multiple := 1;
  elsif no_periods = 52 then         -- Weekly
    p_base_period_type := WEEKLY;
    p_multiple := 1;
  else
    -- Unknown period type.
    hr_utility.set_message(801, 'PAY_6601_PAYROLL_INV_PERIOD_TP');
    hr_utility.raise_error;
  end if;
--
end get_period_details;
--
-- Locally defined function that, given the end-date of a semi-month
-- period and the first period's end-date (p_fpe_date) returns
-- the end date of the following semi-monthly period.
--
function next_semi_month(p_semi_month_date in date, p_fpe_date in date)
                         return date is
   day_of_month varchar2(2);
   last_of_month date;
   temp_day varchar2(2);
   func_name CONSTANT varchar2(50) := 'hr_payrolls.next_semi_month';
begin
    hr_utility.set_location(func_name, 1);
    day_of_month := substr(to_char(p_fpe_date, 'DD-MON-YYYY'), 1, 2);
    if (day_of_month = '15') OR (last_day(p_fpe_date) = p_fpe_date) then
      -- The first period's end-date is either the 15th or the end-of-month
      if last_day(p_semi_month_date) = p_semi_month_date then
         -- End of month: add 15 days
         return(p_semi_month_date + 15);
      else
         -- 15th of month: return last day
         return(last_day(p_semi_month_date));
      end if;
    else
      -- The first period's end-date is neither the 15th nor the end-of-month
      -- temp_day = smaller of the 2 day numbers used to calc period end-dates
      temp_day := day_of_month ;
      if temp_day > '15' then
         temp_day := substr(to_char(p_fpe_date - 15, 'DD-MON-YYYY'), 1, 2);
      end if ;
      --
      day_of_month := substr(to_char(p_semi_month_date, 'DD-MON-YYYY'), 1, 2);
      if day_of_month between '01' AND '15' then
         if last_day(p_semi_month_date+15) = last_day(p_semi_month_date) then
            return(p_semi_month_date + 15);
         else
            -- for p_semi_month_date = Feb 14th, for example
            return(last_day(p_semi_month_date));
         end if;
      else  -- if on the 16th or later
         return(to_date(   (temp_day ||
                substr(to_char(add_months(p_semi_month_date,1),'DD-MON-YYYY'),3)
                           ), 'DD-MON-YYYY'));
      end if ;
    end if ;
end next_semi_month;
--
-- Locally defined function that, given the end-date of a semi-month
-- period and the first period's end-date (p_fpe_date) returns
-- the end date of the previous semi-monthly period.
--
function prev_semi_month(p_semi_month_date in date, p_fpe_date in date)
                         return date is
   day_of_month varchar2(2);
   last_of_month date;
   temp_date date;
   temp_day varchar2(2);
   func_name CONSTANT varchar2(50) := 'hr_payrolls.prev_semi_month';
begin
    -- Get the day of the current month.
    hr_utility.set_location(func_name, 1);
    day_of_month := substr(to_char(p_fpe_date, 'DD-MON-YYYY'), 1, 2);
    if (day_of_month = '15') OR (last_day(p_fpe_date) = p_fpe_date) then
      -- The first period's end-date is either the 15th or the end-of-month
      if last_day(p_semi_month_date) = p_semi_month_date then
         -- End of month: return 15th of current month
         return(add_months(p_semi_month_date,-1) + 15);
      else
         -- 15th of month: return last day of previous month
         return(last_day(add_months(p_semi_month_date,-1)));
      end if;
    else
      -- The first period's end-date is neither the 15th nor the end-of-month
      -- temp_day = smaller of the 2 day numbers used to calc period end-dates
      temp_day := day_of_month ;
      if temp_day > '15' then
         temp_day := substr(to_char(p_fpe_date - 15, 'DD-MON-YYYY'), 1, 2);
      end if ;
      --
      day_of_month := substr(to_char(p_semi_month_date, 'DD-MON-YYYY'), 1, 2);
      if day_of_month between '01' AND '15' then
         temp_date := add_months (p_semi_month_date, -1) ;
         if last_day(temp_date+15) = last_day(temp_date) then
            return(temp_date + 15);
         else
            -- for p_semi_month_date = Mar 14th, for example
            return(last_day(temp_date));
         end if;
      else  -- if after the 16th
         return(to_date(   (temp_day ||
                substr(to_char(p_semi_month_date,'DD-MON-YYYY'),3)
                           ), 'DD-MON-YYYY'));
      end if ;
    end if ;
end prev_semi_month;
--
--
-- This function is a customized version of add_months function to
-- suit the requirement where an option has to be provided to the user
-- to create payroll periods with the same end day as the first period.
-- This is controlled by the global variable g_constant_end_date.
-- If g_constant_end_date is not true then the result of add_months is
-- returned back. If g_constant_end_date is true then a period end date
-- which has the day as in the first period end date is determined.
-- This value is returned if such a date is valid for the period else
-- the last day in the period is returned. Bug #3697834.
--
FUNCTION customized_add_months ( p_date_in    in DATE,
				 p_first_period_end_date in DATE,
                                 p_months_shift in NUMBER )
RETURN DATE IS
   l_return_value DATE;
   l_day_of_month VARCHAR2(2);
   l_month_year VARCHAR2(6);
   l_end_of_month DATE;
BEGIN

   l_return_value := add_months(p_date_in, p_months_shift);

   if g_constant_end_date then

      -- Pull out the day number of the first period end date
      l_day_of_month := least ( to_number(to_char(p_first_period_end_date,'DD')), to_number(to_char(last_day ( l_return_value ) , 'DD'))) ;

      -- Grab the month and year of the new date
      l_month_year := to_char(l_return_value, 'MMYYYY');

      -- Combine these components into an actual date

      l_end_of_month := to_date(l_month_year || l_day_of_month, 'MMYYYYDD');


      -- Return the earliest of
      --      (a) the normal result of ADD_MONTHS
      --  and (b) the same day in the new period as in the first period end date.

      l_return_value := LEAST (l_return_value, l_end_of_month);

   end if;

   return l_return_value;

END customized_add_months;
--
-- The period numbers and period names are derived using regular pay date.
-- Since leap years have an extra day in February,
-- for some offsets the period numbers derived might not be consistent.
-- To avoid this an adjustment is done to the regualar pay date in
-- leap years to ignore the extra day in february.
-- This function helps in finding out if the adjustment is required or not
-- by returning either -1 , 1 or 0. The value returned is added to the
-- normal regual pay date before using it for deriving period numbers.
-- This is applicable only for payrolls with base period type as MONTHLY.
-- Bug # 3663126.

FUNCTION get_leap_year_offset ( p_period_end_date in date,
                                p_pay_date_offset in number )
RETURN NUMBER IS
--
  l_year varchar2(4);
  l_start_date date;
  l_end_date   date;
  l_date       date;
  l_return_value number;
--
BEGIN

   l_year := to_char( p_period_end_date, 'YYYY');
   l_return_value := 0;

   -- Determine if this is a leap year.

   if ( mod(to_number(l_year), 4) = 0 and  mod(to_number(l_year), 100) <> 0 ) or
          ( mod(to_number(l_year), 4) = 0 and mod(to_number(l_year), 400) = 0 ) then

         l_date := to_date('2902'|| l_year ,'DDMMYYYY');

         if p_pay_date_offset < 0 then

	         l_start_date := p_period_end_date + p_pay_date_offset;
		 l_end_date   := p_period_end_date;

		 if l_date >= l_start_date and l_date <= l_end_date then
			 l_return_value := -1;
                 end if;
	 else
                 l_start_date := p_period_end_date;
		 l_end_date   := p_period_end_date + p_pay_date_offset;

		 if l_date > l_start_date and l_date <= l_end_date then
		        l_return_value := 1;
                 end if;
         end if;
   end if;

   return l_return_value;

END get_leap_year_offset;
--
--
-- This function performs the date calculation according to the
-- base period type for the period type being considered.
-- Note that for WEEKLY base period, the calculation can be
-- performed by adding days ie. straightforward addition operation.
-- For MONTHLY base period, the add_months() function is used.
-- The exception to these general categories is semi-monthly,
-- which is handled explicitly by the SEMIMONTHLY base period.
-- This case only uses the p_multiple parameter to determine whether
-- to add or subtract a semi-month, ie. this function can only
-- increase semi-months unitarily. Furthermore, it has exclusive use
-- of the 'regular_pay_mode' parameter, which for SEMIMONTHLY,
-- indicates whether or not we are calculating for a regular payment
-- date calculation. The p_fpe_date is the first period's end-date
-- and is needed only for semimonthly period calculations.
--
function add_multiple_of_base (p_target_date in date,
                               p_base_period_type in varchar2,
                               p_multiple in number,
                               p_fpe_date in date,
                               p_regular_pay_mode boolean default false,
                               p_pay_date_offset number default null)
                               return date is
--
  func_name CONSTANT varchar2(50) := 'hr_payrolls.add_multiple_of_base';
  rest_of_date varchar2(9);
  temp_date date;
  -- Bug 5935976 for 10 Payroll
  l_date2 date;
  l_day varchar2(10);
  l_month varchar2(10);
  l_year varchar2(10);
  l_start_day varchar2(10);
--
begin
  -- Errors can occur when performing date manipulation.
  if p_base_period_type = WEEKLY then
    hr_utility.set_location(func_name, 1);
    return (p_target_date + (7 * p_multiple));
  elsif p_base_period_type = MONTHLY then
    hr_utility.set_location(func_name, 2);

    -- Replacing add_months with customized_add_months for Bug #3697834.

    if not p_regular_pay_mode then
            temp_date := customized_add_months( p_date_in  => p_target_date,
				                p_first_period_end_date => p_fpe_date,
                                                p_months_shift => p_multiple );

	    return temp_date;
    else
	    temp_date := p_target_date - p_pay_date_offset;
            temp_date := customized_add_months( p_date_in  => temp_date,
				                p_first_period_end_date => p_fpe_date,
                                                p_months_shift => p_multiple );
	    return ( temp_date + p_pay_date_offset );
    end if;
  -- added following code for 10 day Payroll Bug #5935976
  elsif p_base_period_type = TEN_DAYS then

	hr_utility.set_location(func_name, 3);
	l_day := to_char(p_target_date, 'DD');
	l_month := to_char(p_target_date, 'MM');
	l_year := to_char(p_target_date, 'YYYY');
	l_start_day :='01' ;

	if p_multiple > 0 then
		-- return 10, 20, last_day
		-- go front and return end date
	    if l_day = 20 then
		l_date2 := last_day(p_target_date);
	    else
		l_date2 := p_target_date + 10;
	    end if;
	else
		-- return 1, 11,21
		-- go back and return start date
		if p_target_date = last_day(p_target_date) then
			l_start_day := '21';
			l_date2 := to_date( l_start_day ||'-'|| l_month ||'-' ||l_year, 'DD-MM-YYYY');
		else
			l_date2 := p_target_date -9;
		end if;
	end if;
    return (l_date2 );
  --
  else
    -- This is semi-monthly. A pair of semi-months always spand
    -- a whole calendar month. Their start and end dates are either
    -- 1st - 15th or 16th - last day of month. This makes the
    -- addition/subtraction of a period reasonably straightforward,
    -- if a little involved.
    -- On the other hand, if the p_regular_pay_mode is TRUE, we
    -- have to take into account the regular pay date offset.
    if not p_regular_pay_mode then
       if p_multiple > 0 then
          -- Addition of one semi-month.
          return(next_semi_month(p_target_date, p_fpe_date));
       else
          -- Substraction of one semi-month.
          return(prev_semi_month(p_target_date, p_fpe_date));
       end if;
    else
       -- Special calculation for regular payment date offset.
       -- In this special case, we calculate the pay date of the previous
       -- semimonth period: Current pay-date -> Current end-date ->
       -- Previous period's end-date -> Previous period's pay-date.
       temp_date := prev_semi_month (p_target_date - p_pay_date_offset,
                                     p_fpe_date) + p_pay_date_offset ;
       hr_utility.trace('pay date ' || to_char(temp_date, 'dd-mon-yyyy'));
       return(temp_date);
-- OLD CODE
-- Now period's are not guaranteed to end on the 15th or the end_of_month.
--
--       rest_of_date := substr(to_char(p_target_date, 'DD-MON-YYYY'), 3);
--       if p_target_date between
--          to_date(('01' || rest_of_date), 'DD-MON-YYYY') and
--          to_date(('15' || rest_of_date), 'DD-MON-YYYY')
--       then
--          -- First half of month, put to 15th and subtract a period.
--          temp_date := to_date(('15' || rest_of_date), 'DD-MON-YYYY');
--          temp_date := prev_semi_month(temp_date) + p_pay_date_offset;
--          hr_utility.trace('1st half ' || to_char(temp_date, 'dd-mon-yyyy'));
--          return(temp_date);
--       else
--          -- We are in second half of month.
--          temp_date := last_day(p_target_date);
--          temp_date := prev_semi_month(temp_date) + p_pay_date_offset;
--          hr_utility.trace('2nd half ' || to_char(temp_date, 'dd-mon-yyyy'));
--          return(temp_date);
--       end if;
-- OLD CODE
    end if;
  end if;
end add_multiple_of_base;
--
--
-- This procedure determines the period information that is not
-- held directly on the payroll itself, namely:
--
--       1. Start date of first period for payroll.
--       2. Start date of first period to be generated.
--       3. End date of first period to be generated.
--
-- Note that it relies on the base period type, multiple and semi-month
-- count on the payroll details record being populated.
--
procedure derive_payroll_dates(p_pay_det in out nocopy payroll_rec_type) is
--
  proc_name CONSTANT varchar2(50) := 'hr_payrolls.derive_payroll_dates';
--
  earliest_start_date date;
  latest_end_date date;
  no_periods number;
--
begin
  -- Find the start and end dates of the earliest and latest periods
  -- generated for the payroll.
  hr_utility.set_location(proc_name, 1);
  select min(start_date),
         max(end_date),
         count(time_period_id)
  into earliest_start_date,
       latest_end_date,
       no_periods
  from per_time_periods ptp
  where ptp.payroll_id = p_pay_det.payroll_id;
--
  if no_periods = 0 then
    --
    -- No periods have been generated for the payroll before.
    --
--
    -- The start date must be derived.
    hr_utility.set_location(proc_name, 2);
    -- added for 10 day payroll Bug 5935976
    if p_pay_det.base_period_type = TEN_DAYS then
	p_pay_det.first_start_date
                    := add_multiple_of_base(p_pay_det.first_end_date,
                                            p_pay_det.base_period_type,
                                            -(p_pay_det.multiple),
                                            p_pay_det.first_end_date) ;
    else
	p_pay_det.first_start_date
                    := add_multiple_of_base(p_pay_det.first_end_date,
                                            p_pay_det.base_period_type,
                                            -(p_pay_det.multiple),
                                            p_pay_det.first_end_date) + 1;
    end if;
--
    -- The generated start and end dates will be the same as
    -- those of the earliest payroll period.
    p_pay_det.first_gen_start_date := p_pay_det.first_start_date;
    p_pay_det.first_gen_end_date := p_pay_det.first_end_date;
  else
    --
    -- Periods have been generated for the payroll before.
    --
    hr_utility.set_location(proc_name, 3);
    p_pay_det.first_gen_start_date := latest_end_date + 1;
    p_pay_det.first_start_date := earliest_start_date;
--
    -- The end date of the first period to be generated must be
    -- derived.
    hr_utility.set_location(proc_name, 4);
    p_pay_det.first_gen_end_date
                    := add_multiple_of_base((p_pay_det.first_gen_start_date)-1,
                                            p_pay_det.base_period_type,
                                            p_pay_det.multiple,
                                            p_pay_det.first_end_date) ;
  end if;
--
end derive_payroll_dates;
--
PROCEDURE chk_reset ( p_payroll_details   in payroll_rec_type
                     ,p_period_number     in per_time_periods.period_num%type
		     ,p_no_of_periods     in per_time_period_types.number_per_fiscal_year%type
		     ,p_period_start_date in per_time_periods.start_date%type
		     ,p_next_leg_start_date in date
		     ,p_period_end_date   in out nocopy per_time_periods.end_date%type
		     ,p_no_of_weeks_reset in out nocopy number ) IS
--
  proc_name CONSTANT varchar2(50) := 'hr_payrolls.chk_reset';
--
--
  l_no_of_weeks            number := 0;
  l_week_number            number;
  l_year_end_date          date;
  l_next_period_start_date date;
  l_next_period_end_date   date;
  l_last_period            boolean := false;
--
  CURSOR csr_week_number (p_date in date) IS
    select to_char(p_date,'IW') from dual;
--
BEGIN
--
    hr_utility.set_location(proc_name, 1);
    --
    -- Reset the Payroll Periods for Lunar Month
    --

    -- Check if this is the last period of the financial year

       l_next_period_end_date := add_multiple_of_base(p_period_end_date,
	  					      p_payroll_details.base_period_type,
                                                      p_payroll_details.multiple,
                                                      p_payroll_details.first_end_date);

       -- Determine the period number of the this period.

       if (l_next_period_end_date + p_payroll_details.pay_date_offset - (7 * p_no_of_weeks_reset))
                                           >= p_next_leg_start_date then
 	   l_last_period := true;
       else
	   l_last_period := false;
       end if;

    if (((l_last_period = true and p_payroll_details.period_reset_years = 'L')
        or (p_period_number = 1  and p_payroll_details.period_reset_years = 'F'))
	and  p_no_of_periods = 13 ) then

	l_year_end_date := to_date('31/12/' ||
                             to_char(p_period_end_date, 'YYYY'), 'DD/MM/YYYY');

	open csr_week_number(l_year_end_date);
	fetch csr_week_number into l_no_of_weeks;
	close csr_week_number;

	-- Continue only if the year has 53 ISO Weeks

	if l_no_of_weeks = 53 then

	   if p_payroll_details.period_reset_years = 'F' then

		p_period_end_date := add_multiple_of_base(p_period_end_date,
                                                          p_payroll_details.base_period_type,
                                                          p_payroll_details.multiple * 12,
					 	          p_payroll_details.first_end_date);

	   end if;

           l_next_period_start_date := p_period_end_date + 1;

	   open csr_week_number(l_next_period_start_date);
	   fetch csr_week_number into l_week_number;
	   close csr_week_number;

	   -- Calculate the number of weeks to be reset
	   p_no_of_weeks_reset := 0;
	   while l_week_number <> 1 and l_next_period_start_date < p_next_leg_start_date loop

		p_period_end_date := p_period_end_date + 7;
	        l_next_period_start_date := p_period_end_date + 1;
		p_no_of_weeks_reset := p_no_of_weeks_reset + 1;

		open csr_week_number(l_next_period_start_date);
		fetch csr_week_number into l_week_number;
		close csr_week_number;

	   end loop;

	   if p_payroll_details.period_reset_years = 'F' then

		p_period_end_date := add_multiple_of_base(p_period_end_date - (p_no_of_weeks_reset * 7),
                                                          p_payroll_details.base_period_type,
                                                          -(p_payroll_details.multiple * 12),
				  	 	          p_payroll_details.first_end_date);

		p_period_end_date := p_period_end_date + (p_no_of_weeks_reset * 7);

	   end if;

	   if p_no_of_weeks_reset > 1 then

		-- Set the warning variables
  	           g_weeks_reset_warn  := true;
		   g_reset_period_start_date  := p_period_start_date;
		   g_reset_period_end_date    := p_period_end_date;
		   g_no_of_weeks_reset := p_no_of_weeks_reset;

	   end if;

        end if;
    end if;

    hr_utility.set_location(proc_name, 5);
--
END chk_reset;
--
PROCEDURE clear_warnings IS
--
  proc_name CONSTANT varchar2(50) := 'hr_payrolls.clear_warnings';
--
BEGIN
--
    hr_utility.set_location(proc_name, 1);

	g_weeks_reset_warn := false;
	g_end_date_changed_warn  := false;
	g_no_of_weeks_reset := 0;
	g_reset_period_name := null;
	g_new_end_date := null;

    hr_utility.set_location(proc_name, 5);
--
END clear_warnings;
--
--
PROCEDURE get_warnings ( p_weeks_reset_warn       IN OUT nocopy boolean
			,p_end_date_changed_warn  IN OUT nocopy boolean
			,p_no_of_weeks_reset      IN OUT nocopy number
			,p_reset_period_name      IN OUT nocopy per_time_periods.period_name%type
			,p_new_end_date	          IN OUT nocopy per_time_periods.end_date%type ) IS
--
  proc_name CONSTANT varchar2(50) := 'hr_payrolls.get_warnings';
--
BEGIN
--
    hr_utility.set_location(proc_name, 1);

	p_weeks_reset_warn := g_weeks_reset_warn;
	p_end_date_changed_warn := g_end_date_changed_warn;
	p_no_of_weeks_reset := g_no_of_weeks_reset;
	p_reset_period_name := g_reset_period_name;
	p_new_end_date := g_new_end_date;

    hr_utility.set_location(proc_name, 5);
--
END get_warnings;
--
-- This procedure is called either to create payroll processing
-- periods for a payroll for the first time, or to create further
-- periods to the ones which already exist.
-- If no periods already exist, then we only have the end date of
-- the first period, from which we can calculate that period's
-- start date. However, if periods do already exist, then the
-- start date of the first period we must generate is passed in.
-- Note that the end date of the very first period generated/to
-- be generated is ALWAYS passed in. It is from this that we can
-- determine how far into the future we generate payroll periods.
-- Note further that throughout the procedure, reference is made
-- to the period number. For calculation purposes, this is a
-- monotomically increasing number for periods within a legislative
-- year, being reset to 1 for each year. It is NOT the period number
-- which is stored against the period. The requirement is that
-- the displayed period number is a multiple of the base period
-- types comprising the period type of the generated periods
-- eg. the first lunar month period is numbered 4, the second 8 etc.
--
--
procedure insert_proc_periods(p_pay_det in out nocopy payroll_rec_type,
                              p_last_update_date  in date   default sysdate,
                              p_last_updated_by   in number default -1,
                              p_last_update_login in number default -1,
                              p_created_by        in number default -1,
                              p_creation_date     in date   default sysdate,
			      p_first_gen_date    out nocopy date) is
--
  proc_name CONSTANT varchar2(50) := 'hr_payrolls.insert_proc_periods';
--
  per_num number;           -- Monotonic period number, not displayed.
  payroll_start_date       pay_all_payrolls_f.effective_start_date%type;
  payroll_end_date         pay_all_payrolls_f.effective_end_date%type;
  within_period_flag       boolean := FALSE;
  leg_start_date           date;
  end_years_marker         date;
  next_leg_start_date      date;
  period_start_date        date;
  period_end_date          date;
  current_regular_pay_date date;
  l_period_number          number;
  l_period_name            per_time_periods.period_name%type ;
  l_display_period_type    per_time_period_types.display_period_type%type ;
  l_first_period_end_date  date;
  l_period_generate_count  number := 1;
  l_tax_year               number(4);
--
  l_no_of_periods          per_time_period_types.number_per_fiscal_year%type;
  l_no_of_weeks_reset      number := 0;
  l_period_end_date        date;
  l_leap_year_offset       number;
--
  CURSOR c_get_no_of_periods IS
    select tp.number_per_fiscal_year
      from per_time_period_types tp
     where tp.period_type = p_pay_det.period_type;
--
begin
--
  -- Derive the complete date range for this payroll.
  hr_utility.set_location(proc_name, 1);
  select min(ppy.effective_start_date),
         max(ppy.effective_end_date)
  into payroll_start_date,
       payroll_end_date
  from pay_all_payrolls_f ppy
  where ppy.payroll_id = p_pay_det.payroll_id;
  --
  --
  -- The periods generated must exist within the lifetime of the
  -- payroll. Throughout the system, data is viewed within the
  -- context of a period; hence, creating periods outside of the
  -- payroll could introduce problems.
  -- A consequence of this is that no periods will be generated
  -- for the payroll if we cannot fit one into the date-effective
  -- lifetime of the payroll. In this case, we raise an exception.
  -- Note that if the code is invoked to add further periods to existing
  -- ones, and none are created because of the end date on the payroll,
  -- then no exception is raised (this situation could quite possibly
  -- arise).
  --
  if p_pay_det.first_start_date < payroll_start_date or
               p_pay_det.first_end_date > payroll_end_date then
    hr_utility.set_message(801, 'PAY_6603_PAYROLL_NOGEN_PERIODS');
    hr_utility.raise_error;
  end if;
--
  --
  -- Derive the period number of the first period. It is not necessarily
  -- 1, since this period is defined to be the first period whose regular
  -- payment date lies within the legislative year.
  --
  declare
    regular_pay_date         date;
    no_periods               number;
  begin
    -- Loop back to find the first time period with its regular pay date
    -- in the current legislative year. This is period 1, so from this
    -- the period number of the first period to be generated can be
    -- derived.
    hr_utility.set_location(proc_name, 2);

    -- Adjust regular pay date for the first generated period if required.

    l_leap_year_offset := 0;

    if p_pay_det.base_period_type = MONTHLY then

        l_leap_year_offset := get_leap_year_offset ( p_period_end_date => p_pay_det.first_gen_end_date
	                                            ,p_pay_date_offset => p_pay_det.pay_date_offset );

    end if;

    regular_pay_date := p_pay_det.first_gen_end_date + l_leap_year_offset +
                                                 p_pay_det.pay_date_offset ;
--
    -- Append the year component of the first regular pay date
    -- to the legislative year start. This is necessary so that
    -- we can determine the legislative start date to consider
    -- eg. if the pay date is 04-apr-1992, then the legislative start
    --     date in the UK is 06-apr-1991; if the pay date is 07-apr-1992,
    --     then the legislative start date is 06-apr-1992.
    -- Changed for MLS compliance to query the rule mode of the
    -- format DD/MM, then make up the actual date using the regular
    -- pay for the year element as before.
    --
    hr_utility.set_location(proc_name, 3);
    begin
      select to_date(plr.rule_mode || '/' ||
                     to_char(regular_pay_date, 'YYYY'), 'DD/MM/YYYY')
      into leg_start_date
      from pay_legislation_rules plr
      where plr.rule_type = 'L'
      and   plr.legislation_code = p_pay_det.legislation_code ;
--
    -- Also change defaulting.
    EXCEPTION
         when NO_DATA_FOUND then
              leg_start_date := to_date('01/01/' ||
                             to_char(regular_pay_date, 'YYYY'), 'DD/MM/YYYY');
    end;
--
    -- Now establish whether the payment date must always lie within
    -- the period. Default already set to FALSE.
    hr_utility.set_location(proc_name, 11);
--
    declare
      rulemode pay_legislation_rules.rule_mode%type;
    begin
--
      select plr.rule_mode
      into rulemode
      from pay_legislation_rules plr
      where plr.rule_type = 'PDO'
      and   plr.legislation_code = p_pay_det.legislation_code ;
--
      if rulemode = 'N' then
        within_period_flag := TRUE;
      end if;
--
      EXCEPTION
         when NO_DATA_FOUND then null;
    end;
--
    if leg_start_date > regular_pay_date then
      -- Must reduce the legislative start date by a year.
      hr_utility.set_location(proc_name, 4);
      leg_start_date := add_months(leg_start_date, -12);
    end if;
--
    -- Remove the l_leap_year_offset added to the regular pay date
    -- as it is again added in the while loop.

    regular_pay_date := regular_pay_date - l_leap_year_offset ;

    no_periods := 0;
    while regular_pay_date + l_leap_year_offset >= leg_start_date loop
      regular_pay_date := add_multiple_of_base(regular_pay_date,
                                               p_pay_det.base_period_type,
                                               -(p_pay_det.multiple),
                                               p_pay_det.first_end_date,
                                               true,   -- regular pay mode.
                                               p_pay_det.pay_date_offset);
      no_periods := no_periods + 1;
	-- added to calculate previous period end date
       if p_pay_det.base_period_type = TEN_DAYS then
		regular_pay_date := regular_pay_date -1 ;
       end if;

      l_leap_year_offset := 0;

      if p_pay_det.base_period_type = MONTHLY then

         l_leap_year_offset := get_leap_year_offset ( p_period_end_date => regular_pay_date - p_pay_det.pay_date_offset
	                                             ,p_pay_date_offset => p_pay_det.pay_date_offset );

      end if;

    end loop;
--
    per_num := no_periods;
    hr_utility.set_location('per_num '||per_num,10);
  end;  -- Deriving period number.
--

  -- Clear the Global Warning Variables
  --
     clear_warnings;

  --
  -- Insert time periods for the number of years required.
  --
--
  hr_utility.set_location(proc_name, 5);
  end_years_marker := add_months(p_pay_det.first_start_date,
                                             (12 * p_pay_det.no_years));
--
  -- Hold the start date of the next legislative year in order to
  -- determine when we are crossing the year boundary.
  hr_utility.set_location(proc_name, 6);
  next_leg_start_date := add_months(leg_start_date, 12);
  period_start_date := p_pay_det.first_gen_start_date;
  period_end_date := p_pay_det.first_gen_end_date;
--

  -- Code for the resetting of periods for lunar months
     --
     open c_get_no_of_periods;
     fetch c_get_no_of_periods into l_no_of_periods;
     close c_get_no_of_periods;

     -- Check if first generated period has to be reset.
     -- Also check if the first period end date has to be changed (possible only while inserting)

     l_period_end_date := period_end_date;

     chk_reset( p_payroll_details   => p_pay_det
               ,p_period_number     => per_num
               ,p_no_of_periods     => l_no_of_periods
	       ,p_period_start_date => period_start_date
	       ,p_next_leg_start_date => next_leg_start_date
	       ,p_period_end_date   => period_end_date
	       ,p_no_of_weeks_reset => l_no_of_weeks_reset );

     if l_period_end_date <> period_end_date then

	  -- If first generated period is same as first period of the entire payroll then
	  -- first period end date of the payroll has to be updated

	  if p_pay_det.first_start_date = p_pay_det.first_gen_start_date and
	      p_pay_det.first_end_date = p_pay_det.first_gen_end_date then

	      p_pay_det.first_end_date := period_end_date;
	      p_pay_det.first_gen_end_date := period_end_date;

	      update pay_all_payrolls_f
		set first_period_end_date = period_end_date
		where payroll_id = p_pay_det.payroll_id;

		-- Set the warning variable
		g_end_date_changed_warn := true;
		g_new_end_date := period_end_date;

	      if p_pay_det.first_end_date > payroll_end_date then
		hr_utility.set_message(801, 'PAY_6603_PAYROLL_NOGEN_PERIODS');
		hr_utility.raise_error;
	      end if;
     	  else
	      p_pay_det.first_gen_end_date := period_end_date;
          end if;

     end if;
     --

     -- get leap year offset for the first generated period as it might have been
     -- lost.

     l_leap_year_offset := 0;

     if p_pay_det.base_period_type = MONTHLY then

         l_leap_year_offset := get_leap_year_offset ( p_period_end_date => p_pay_det.first_gen_end_date
	                                             ,p_pay_date_offset => p_pay_det.pay_date_offset );

     end if;


  -- Generate periods for the more restrictive of the two date
  -- ranges:
  --
  --    1. Number of years to be generated on the payroll.
  --    2. Date effective lifetime of the payroll.
  --
  while (period_start_date < end_years_marker) and
                          (period_end_date <= payroll_end_date) loop
--
   current_regular_pay_date := period_end_date + p_pay_det.pay_date_offset;
--
-- If payment dates must lie within their periods for the legislation,
-- then check this is the case. It's too difficult to catch all cases
-- at offset definition time.
--
   if within_period_flag = TRUE then
     if  ( current_regular_pay_date < period_start_date )   or
         ( current_regular_pay_date > period_end_date )   then
        hr_utility.set_message(801, 'PAY_6999_PAYROLL_INV_PAY_DATE');
        hr_utility.raise_error;
     end if;
   end if;
--
-- Bug 493007
-- Find the Display Period Type (translated version) for the given
-- Period Type.
--
   select NVL(tpt.display_period_type, p_pay_det.period_type)
   into   l_display_period_type
   from   per_time_period_types_vl tpt
   where  tpt.period_type = p_pay_det.period_type;
--
-- For GB legislation we store the period number as the multiple of
-- constituent base period types.
--
   l_tax_year := (to_char(next_leg_start_date, 'YYYY') - 1);

   if ( p_pay_det.legislation_code = 'GB' ) then
     l_period_number := per_num * p_pay_det.multiple ;
   --
   -- Check to see if a profile value is set to create period names
   -- based on current tax year instead of current calendar year.
   --
   --Bug 1818469
     if (fnd_profile.value('PAY_GENERATE_PAYROLL_PERIODS_TAX_YEAR') = 'Y' and
         period_start_date < next_leg_start_date) then
       l_period_name := to_char(per_num * p_pay_det.multiple) || ' '
                          || to_char(l_tax_year) || ' '
                          || l_display_period_type ;
     else
       l_period_name   := to_char(per_num * p_pay_det.multiple) || ' '
                          || to_char(current_regular_pay_date + l_leap_year_offset - (7 * l_no_of_weeks_reset), 'YYYY') || ' '
                          || l_display_period_type ;
     end if;
   --
   else
     l_period_number := per_num ;
   --
   -- Check to see if a profile value is set to create period names
   -- based on current tax year instead of current calendar year.
   --
     if (fnd_profile.value('PAY_GENERATE_PAYROLL_PERIODS_TAX_YEAR') = 'Y' and
         period_start_date < next_leg_start_date) then
       l_period_name := to_char(per_num) || ' '
                        || to_char(l_tax_year) || ' '
                        || l_display_period_type ;

     else
       l_period_name   := to_char(per_num) || ' '
                          || to_char(current_regular_pay_date + l_leap_year_offset - (7 * l_no_of_weeks_reset), 'YYYY') || ' '
                          || l_display_period_type ;
     end if;
   --
   end if;

   -- Store the reset period name for displaying in the warning message

      if period_start_date = g_reset_period_start_date and period_end_date = g_reset_period_end_date then
		g_reset_period_name := l_period_name;
      end if;

--
   hr_utility.set_location('l_period_name '||l_period_name,10);
    -- Insert the processing time period.
    hr_utility.set_location(proc_name, 7);
    insert into per_time_periods
      (time_period_id,
       payroll_id,
       start_date,
       end_date,
       regular_payment_date,
       cut_off_date,
       pay_advice_date,
       default_dd_date,
       period_type,
       period_num,
       period_name,
       status,
       run_display_number,
       quickpay_display_number,
       last_update_date,
       last_updated_by,
       last_update_login,
       created_by,
       creation_date,
       payslip_view_date)
    select
      per_time_periods_s.nextval,
      p_pay_det.payroll_id,
      period_start_date,
      period_end_date,
      current_regular_pay_date,
      period_end_date + p_pay_det.cut_off_date_offset,
      period_end_date + p_pay_det.pay_advice_date_offset,
      period_end_date + p_pay_det.direct_deposit_date_offset,
      p_pay_det.period_type,
      l_period_number,
      l_period_name,
      'O',
      1,
      1,
      p_last_update_date,
      p_last_updated_by,
      p_last_update_login,
      p_created_by,
      p_creation_date,
      Current_regular_pay_date + p_pay_det.payslip_view_date_offset
    from sys.dual;
--
    -- Increment loop variables.
    hr_utility.set_location(proc_name, 8);
    -- Store the first period end date, on the first loop.
    if l_period_generate_count = 1 then
       l_first_period_end_date := period_end_date;
    end if;
    --
    l_period_generate_count := l_period_generate_count + 1;
    period_start_date := period_end_date + 1;
    --
    period_end_date := add_multiple_of_base(period_end_date,
                                            p_pay_det.base_period_type,
                                            p_pay_det.multiple,
                                            p_pay_det.first_end_date);

    -- Determine the period number.
    hr_utility.set_location(proc_name, 9);

    -- Adjust regular pay date if required.

    l_leap_year_offset := 0;

    if p_pay_det.base_period_type = MONTHLY then

	l_leap_year_offset := get_leap_year_offset ( p_period_end_date => period_end_date
	                                            ,p_pay_date_offset => p_pay_det.pay_date_offset );

    end if;

    if (period_end_date + l_leap_year_offset + p_pay_det.pay_date_offset - (7 * l_no_of_weeks_reset))
                                           >= next_leg_start_date then

      -- Reset the period number since we have just crossed the year
      -- boundary. Also, advance next_leg_start_date to next year.
      per_num := 1;
      hr_utility.set_location(proc_name, 10);
      next_leg_start_date := add_months(next_leg_start_date, 12);
    else
      per_num := per_num + 1;
    end if;

    -- Check if reset is required.

    chk_reset( p_payroll_details   => p_pay_det
              ,p_period_number     => per_num
	      ,p_no_of_periods     => l_no_of_periods
	      ,p_period_start_date => period_start_date
	      ,p_next_leg_start_date => next_leg_start_date
	      ,p_period_end_date   => period_end_date
	      ,p_no_of_weeks_reset => l_no_of_weeks_reset );
--
  end loop;
--
  p_first_gen_date := l_first_period_end_date;
--
end insert_proc_periods;
-------------------------------------------------------------------------
--
-- PROCEDURE create_dynamic_local_cal
-- This procedure is used to derive a call to a localization's
-- calendar procedure, by use of dynamic SQL. All the necessary
-- parameters are here to enable localizations to effectively
-- seed extra calendar data.
-------------------------------------------------------------------------
--
procedure create_dynamic_local_cal (p_payroll_id       in number,
				    p_first_period_end in date,
				    p_first_gen_date   in date,
				    p_period_type      in varchar2,
				    p_base_period_type in varchar2,
				    p_multiple         in number,
				    p_legislation_code in varchar2) is
--
  l_tp_last_end_date date;
  NO_PACKAGE_BODY exception;
  pragma exception_init(NO_PACKAGE_BODY,-6508);
  NO_PACKAGE_PROCEDURE exception;
  pragma exception_init(NO_PACKAGE_PROCEDURE,-6550);
  --
  -- dynamic SQL variables
  --
  sql_curs           number;
  rows_processed     integer;
  statem             varchar2(512);
--
cursor get_period_last_end_date(c_payroll_id in number) is
  select max(end_date)
  from per_time_periods
  where payroll_id = c_payroll_id;
--
begin
--
   open get_period_last_end_date(p_payroll_id);
   fetch get_period_last_end_date into
	 l_tp_last_end_date;
   close get_period_last_end_date;
   --
--
-- Create dynamic SQL call to localization calendars package
--
    statem := 'BEGIN
    pay_'||lower(p_legislation_code)||'_calendars_pkg.create_calendar
                (:p_payroll_id,
                 :p_first_end_date,
                 :p_last_end_date,
		 :p_period_type,
		 :p_base_period_type,
		 :p_multiple,
		 :p_first_period_end); END;';
    --
    sql_curs := dbms_sql.open_cursor;
    --
    dbms_sql.parse(sql_curs,
                   statem,
                   dbms_sql.v7);
    --
    -- Bind all the variables for the dynamic call
    --
    dbms_sql.bind_variable(sql_curs,'p_payroll_id',p_payroll_id);
    dbms_sql.bind_variable(sql_curs,'p_first_end_date',p_first_gen_date);
    dbms_sql.bind_variable(sql_curs,'p_last_end_date',l_tp_last_end_date);
    dbms_sql.bind_variable(sql_curs,'p_period_type',p_period_type);
    dbms_sql.bind_variable(sql_curs,'p_base_period_type',p_base_period_type);
    dbms_sql.bind_variable(sql_curs,'p_multiple',p_multiple);
    dbms_sql.bind_variable(sql_curs,'p_first_period_end',p_first_period_end);
    --
    -- Execute the dyn cursor for the procedure call, then close.
    --
    BEGIN
      --
      rows_processed := dbms_sql.execute(sql_curs);
      --
      -- If one of the user-defined exceptions are raised,
      -- do nothing as it means that the legislation does not
      -- have a package procedure defined for the localization, in which
      -- case we can ignore the call and no further processing outside
      -- the normal payroll periods is necessary.
      -- Other exceptions (that might be raised by the actual
      -- localization's code) can be raised as normal.
      --
    EXCEPTION
      WHEN NO_PACKAGE_BODY OR NO_PACKAGE_PROCEDURE THEN
	 NULL;
      --
    END;
    dbms_sql.close_cursor(sql_curs);
    --
--
end create_dynamic_local_cal;
--
-----------------------------------------------------------------------------
--
-- This procedure is called to insert payroll processing periods.
--
--
procedure create_payroll_proc_periods (p_payroll_id         in number,
                                       p_last_update_date   in date,
                                       p_last_updated_by    in number,
                                       p_last_update_login  in number,
                                       p_created_by         in number,
                                       p_creation_date      in date) is
--
  proc_name CONSTANT varchar2(50) := 'hr_payrolls.create_payroll_proc_periods';
--
  payroll_details payroll_rec_type;
  l_first_gen_end_date date;
--
begin
  payroll_details.payroll_id := p_payroll_id;
  --
  -- Get the payroll details from the date-effective view, so that
  -- the correct number of years is retrieved. All other payroll
  -- attributes that we are interested in cannot be date-effectively
  -- updated.
  --
  hr_utility.set_location(proc_name, 1);
  select ppy.number_of_years,
         ppy.period_type,
         ppy.pay_date_offset,
         ppy.cut_off_date_offset,
         ppy.pay_advice_date_offset,
         ppy.direct_deposit_date_offset,
         ppy.first_period_end_date,
	 ppy.period_reset_years,
	 hr_api.return_legislation_code(ppy.business_group_id),
	 ppy.payslip_view_date_offset
  into   payroll_details.no_years,
         payroll_details.period_type,
         payroll_details.pay_date_offset,
         payroll_details.cut_off_date_offset,
         payroll_details.pay_advice_date_offset,
         payroll_details.direct_deposit_date_offset,
         payroll_details.first_end_date,
         payroll_details.period_reset_years,
	 payroll_details.legislation_code,
	 payroll_details.payslip_view_date_offset
  from pay_all_payrolls    ppy
  where ppy.payroll_id        = p_payroll_id;
  --
  --
  -- Validate the number of years and midpoint offset, where
  -- appropriate.
  --
  -- Number of years must be > 0.
  if payroll_details.no_years <= 0 then
    hr_utility.set_message(801, 'PAY_6604_PAYROLL_INV_NO_YEARS');
    hr_utility.raise_error;
  end if;
--
  -- All of the supported time period types map to either a weekly or
  -- monthly base period and multiple eg. fortnight = 2 * week,
  --                                      bi-monthly = 2 * month.
  --
  -- Determine the base period and multiple for the period type specified.
  get_period_details(payroll_details.period_type,
                     payroll_details.base_period_type,
                     payroll_details.multiple);
  --
  -- Now derive the remaining payroll period dates.
  derive_payroll_dates(payroll_details);
  --
  -- Insert the further periods required.
  insert_proc_periods(payroll_details,
                      p_last_update_date,
                      p_last_updated_by,
                      p_last_update_login,
                      p_created_by,
                      p_creation_date,
		      l_first_gen_end_date);
   --
   -- Create legislative further calendars information.
   --
   create_dynamic_local_cal (p_payroll_id       => p_payroll_id,
   			     p_first_period_end => payroll_details.first_end_date,
			     p_first_gen_date   => l_first_gen_end_date,
			     p_period_type      => payroll_details.period_type,
			     p_base_period_type => payroll_details.base_period_type,
			     p_multiple         => payroll_details.multiple,
			     p_legislation_code => payroll_details.legislation_code);
--
end create_payroll_proc_periods;
------------------------------------------------------------------------------------
--This is a overloaded version of create_payroll_proc_periods with
--additional parameter p_effective_date and  using  PAY_ALL_PAYROLLS_F
--table instead of PAY_ALL_PAYROLLS view.
--
procedure create_payroll_proc_periods (p_payroll_id         in number,
                                       p_last_update_date   in date,
                                       p_last_updated_by    in number,
                                       p_last_update_login  in number,
                                       p_created_by         in number,
                                       p_creation_date      in date,
                                       p_effective_date     in date ) is
--
  proc_name CONSTANT varchar2(50) := 'hr_payrolls.create_payroll_proc_periods';
--
  payroll_details payroll_rec_type;
  l_first_gen_end_date date;
--
begin
  payroll_details.payroll_id := p_payroll_id;
  --
  -- Get the payroll details from the date-effective view, so that
  -- the correct number of years is retrieved. All other payroll
  -- attributes that we are interested in cannot be date-effectively
  -- updated.
  --
  hr_utility.set_location(proc_name, 1);
  select ppy.number_of_years,
         ppy.period_type,
         ppy.pay_date_offset,
         ppy.cut_off_date_offset,
         ppy.pay_advice_date_offset,
         ppy.direct_deposit_date_offset,
         ppy.first_period_end_date,
         pbg.legislation_code,
	 ppy.payslip_view_date_offset,
	 ppy.period_reset_years -- Added for bug 8616134
  into   payroll_details.no_years,
         payroll_details.period_type,
         payroll_details.pay_date_offset,
         payroll_details.cut_off_date_offset,
         payroll_details.pay_advice_date_offset,
         payroll_details.direct_deposit_date_offset,
         payroll_details.first_end_date,
         payroll_details.legislation_code,
	 payroll_details.payslip_view_date_offset,
         payroll_details.period_reset_years -- Added for bug 8616134
  from pay_all_payrolls_f    ppy,
       per_business_groups pbg
  where ppy.payroll_id        = p_payroll_id
  and   ppy.business_group_id + 0 = pbg.business_group_id + 0
  and   ppy.effective_start_date <= p_effective_date
  and   ppy.effective_end_date   >= p_effective_date ;
--
  --
  -- Validate the number of years and midpoint offset, where
  -- appropriate.
  --
  -- Number of years must be > 0.
  if payroll_details.no_years <= 0 then
    hr_utility.set_message(801, 'PAY_6604_PAYROLL_INV_NO_YEARS');
    hr_utility.raise_error;
  end if;
--
  -- All of the supported time period types map to either a weekly or
  -- monthly base period and multiple eg. fortnight = 2 * week,
  --                                      bi-monthly = 2 * month.
  --
  -- Determine the base period and multiple for the period type specified.
  get_period_details(payroll_details.period_type,
                     payroll_details.base_period_type,
                     payroll_details.multiple);
  --
  -- Now derive the remaining payroll period dates.
  derive_payroll_dates(payroll_details);
  --
  -- Insert the further periods required.
  insert_proc_periods(payroll_details,
                      p_last_update_date,
                      p_last_updated_by,
                      p_last_update_login,
                      p_created_by,
                      p_creation_date,
		      l_first_gen_end_date);
   --
   -- Create legislative further calendars information.
   --
   create_dynamic_local_cal (p_payroll_id       => p_payroll_id,
   			     p_first_period_end => payroll_details.first_end_date,
			     p_first_gen_date   => l_first_gen_end_date,
			     p_period_type      => payroll_details.period_type,
			     p_base_period_type => payroll_details.base_period_type,
			     p_multiple         => payroll_details.multiple,
			     p_legislation_code => payroll_details.legislation_code);
--
end create_payroll_proc_periods;
--
------------------------------------------------------------------------------------
--
-- This procedure displays the correct format of period_name
-- depending on ACTION_TYPE.
--
--
function local_display_period_name(p_payroll_action_id IN NUMBER)
--
   RETURN VARCHAR2 is
--
  l_period_name		VARCHAR2(70);
  l_payroll_id          NUMBER;
  l_time_period_id      NUMBER;
  l_effective_date      DATE;
  l_start_date          DATE;
  l_date_earned         DATE;
  l_action_type         VARCHAR2(4);
  l_date_from_and_to    BOOLEAN  := FALSE;
--
   cursor action_info(c_payroll_action_id IN NUMBER) is
   SELECT payroll_id,
          time_period_id,
   	  effective_date,
  	  start_date,
	  date_earned,
	  action_type
   FROM   pay_payroll_actions
   WHERE  payroll_action_id = c_payroll_action_id;
--
   cursor get_name (c_payroll_id IN NUMBER,
		   c_date_earned IN DATE) is
   SELECT period_name
   FROM   per_time_periods
   WHERE  payroll_id = c_payroll_id
   AND    c_date_earned between start_date and end_date;
--
BEGIN
--
   open action_info(p_payroll_action_id);
   FETCH action_info INTO l_payroll_id,
			  l_time_period_id,
			  l_effective_date,
			  l_start_date,
			  l_date_earned,
			  l_action_type;
   close action_info;
   --
   -- Display period name as 'date from and to' if in following action types:
   -- Transfer To GL, Retropay, Costing.
   --
   if l_action_type in ('C','O','P','T') then
      l_date_from_and_to := TRUE;
   end if;
--
-- where no date_earned is set and action type is not 'date from and to' type
-- just report the period as the start and end of the action.
--
   if l_date_earned  IS NULL or l_date_from_and_to THEN
      l_period_name := to_char(l_start_date, 'dd-MON-yyyy')||' - '
      ||to_char (l_effective_date,'dd-MON-yyyy');
   else
     open get_name (l_payroll_id, l_date_earned);
     FETCH get_name into l_period_name;
     close get_name;
   end if;
--
RETURN l_period_name;
--
end local_display_period_name;
--
function display_period_name(p_payroll_action_id IN NUMBER)
return VARCHAR2 IS
BEGIN
  IF g_enable_period_name_fetch THEN
    RETURN local_display_period_name(p_payroll_action_id);
  END IF;
  RETURN NULL;
END display_period_name;
--
function display_period_name_forced(p_payroll_action_id IN NUMBER)
return VARCHAR2 IS
BEGIN
  RETURN local_display_period_name(p_payroll_action_id);
END display_period_name_forced;
--
PROCEDURE enable_display_fetch(p_mode IN BOOLEAN) IS
BEGIN
  g_enable_period_name_fetch := p_mode;
END enable_display_fetch;
--
PROCEDURE set_globals ( p_constant_end_date in boolean ) IS
BEGIN
	g_constant_end_date := p_constant_end_date ;
END set_globals;
--
end hr_payrolls;

/
