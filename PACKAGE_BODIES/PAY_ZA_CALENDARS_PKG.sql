--------------------------------------------------------
--  DDL for Package Body PAY_ZA_CALENDARS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ZA_CALENDARS_PKG" as
/* $Header: pyzapcal.pkb 120.2 2005/06/28 00:08:22 kapalani noship $ */
-- +======================================================================+
-- |       Copyright (c) 1998 Oracle Corporation South Africa Ltd         |
-- |                Cape Town, Western Cape, South Africa                 |
-- |                           All rights reserved.                       |
-- +======================================================================+
-- SQL Script File Name : pyzapcal.pkb
-- Description          : This sql script seeds the za_pay_calendars
--                        package for the ZA localisation. This package
--                        creates the payroll calendars needed for ZA.
--
-- Change List:
-- ------------
--
-- Name           Date       Version Bug     Text
-- -------------- ---------- ------- ------- ------------------------------
-- F.D. Loubser   03-SEP-98  110.0           Initial Version
-- A. Mills       20-APR-99  110.1           Changed package name and
--                                           main interface procedure
--                                           (create_calendar) so that
--                                           dynamic call from core code
--                                           (hr_payrolls) will work.
-- F.D. Loubser   12-MAY-99  110.2           Added default value for
--                                           l_store_end_date in
--                                           create_za_employee_tax_years
-- F.D. Loubser   09-JUN-99  110.3           Changed 'PAY_' Messages to
--                                           conform to ZA standard
-- F.D. Loubser   11-JUN-99  110.4           Added move to last period
--                                           in Month End for first period
--                                           being start of tax year
-- J.N. Louw      23-AUG-2000 115.0          Updated package for 11i
--                                           Flexible Date Functionality
--                                           -- org_information11
-- L.J. Kloppers  22-Nov-2000 115.1          Move History Section into Package
-- L.J. Kloppers  27-Nov-2000 115.2          Added update of:
--                                           prd_information_category = 'ZA'
-- Ghanshyam      07-Jul-2002 115.0          Moved the contents from
--					     $PER_TOP/patch/115/sql/hrzapcal.pkb
-- ========================================================================


---------------------------------------------------------------------------------------
--   Global variables
---------------------------------------------------------------------------------------

-- Package constants, denoting the base period types.
-- These constants are needed to call the core function add_multiple_of_base
WEEKLY      CONSTANT varchar2(1) := 'W';
MONTHLY     CONSTANT varchar2(1) := 'M';
SEMIMONTHLY CONSTANT varchar2(1) := 'S';

---------------------------------------------------------------------------------------
--   This procedure is a driver that defaults the calendars for the payroll name
--   passed to it. It is only provided as a manual substitute, until the functionality
--   is incorporated into the core code.
--   Parameters:
--   p_payroll_name   - The name of the payroll for which the calendars should be
--                      defaulted.
--   p_effective_date - The effective date
--   NOTE: Error checking is not provided, since this procedure is not supposed to be
--         called as part of a core process.
---------------------------------------------------------------------------------------

procedure do
   (
      p_payroll_name varchar2,
      p_effective_date date
   )
   is

   l_payroll_id     number;
   l_first_end_date date;
   l_last_end_date  date;
   l_period_type    varchar2(30);
   l_period_type2   varchar2(1);
   l_multiple       number;
   l_fpe            date;

begin

   -- Obtain the Payroll ID, First Period End Date and Period Type
   select distinct
      payroll_id, first_period_end_date, period_type
   into
      l_payroll_id, l_fpe, l_period_type
   from
      pay_payrolls_f
   where
      payroll_name = p_payroll_name
   and
      p_effective_date between effective_start_date and effective_end_date;

   -- Obtain the chronologically first end date in the Payroll
   select
      min(end_date)
   into
      l_first_end_date
   from
      per_time_periods
   where
      payroll_id = l_payroll_id;

   -- Obtain the chronologically last end date in the Payroll
   select
      max(end_date)
   into
      l_last_end_date
   from
      per_time_periods
   where
      payroll_id = l_payroll_id;

   -- Determine the base period type and the multiple of the base
   if l_period_type = 'Year' then
      l_period_type2 := MONTHLY;
      l_multiple := 12;
   elsif l_period_type = 'Semi-Year' then
      l_period_type2 := MONTHLY;
      l_multiple := 6;
   elsif l_period_type = 'Quarter' then
      l_period_type2 := MONTHLY;
      l_multiple := 3;
   elsif l_period_type = 'Bi-Month' then
      l_period_type2 := MONTHLY;
      l_multiple := 2;
   elsif l_period_type = 'Calendar Month' then
      l_period_type2 := MONTHLY;
      l_multiple := 1;
   elsif l_period_type = 'Lunar Month' then
      l_period_type2 := WEEKLY;
      l_multiple := 4;
   elsif l_period_type = 'Semi-Month' then
      l_period_type2 := SEMIMONTHLY;
      l_multiple := 1;                 -- Not used for semi-monthly
   elsif l_period_type = 'Bi-Week' then
      l_period_type2 := WEEKLY;
      l_multiple := 2;
   elsif l_period_type = 'Week' then
      l_period_type2 := WEEKLY;
      l_multiple := 1;
   else
      -- Unknown period type.
      hr_utility.set_message(801, 'PAY_6601_PAYROLL_INV_PERIOD_TP');
      hr_utility.raise_error;
   end if;

   -- Call the procedure that creates the ZA calendars with the necessary parameters.
   create_calendar
   (
      l_payroll_id,
      l_first_end_date,
      l_last_end_date,
      l_period_type,
      l_period_type2,
      l_multiple,
      l_fpe
   );
end do;

---------------------------------------------------------------------------------------
--   This procedure is the driving procedure in the creation of the ZA Payroll
--   Calendars. It goes through the following steps:
--    1. Obtain the Business Group Id of the current user
--    2. Obtain the day on which the Company Financial Year starts
--    3. Obtain the date on which the Payroll Tax Year starts
--    4. Generate the Payroll Month Ends between p_first_end_date and p_last_end_date
--    5. Generate the Tax Years between p_first_end_date and p_last_end_date
--    6. Generate the Calendar Years between p_first_end_date and p_last_end_date
--    7. Generate the Tax Quarters between p_first_end_date and p_last_end_date
--   Parameters:
--   p_payroll_id       - The primary key ID of the payroll.
--   p_first_end_date   - The first period end date in the generation time span.
--   p_last_end_date    - The last period end date in the generation time span.
--   p_proc_period_type - The time period type, e.g. Week, Calendar Month.
--   p_base_period_type - The base period type, other period types are multiples of the
--                        base period type, e.g. WEEKLY, MONTHLY, SEMIMONTHLY.
--   p_multiple         - The amount of base periods that make up the period type.
--   p_fpe_date         - The first period end date in the payroll time span.
---------------------------------------------------------------------------------------
procedure create_calendar
   (
      p_payroll_id       in number,
      p_first_end_date   in date,
      p_last_end_date    in date,
      p_proc_period_type in varchar2,
      -- Parameters needed to call the core function add_multiple_of_base
      p_base_period_type in varchar2,
      p_multiple         in number,
      p_fpe_date         in date
   )
   is
   -- The Business Group Id of the current user
   l_business_group_id number;
   -- The day on which the Company Financial Year Starts
   l_fiscal_start_day  number;
   -- The date in DD-MON format on which the Payroll Tax Year starts
   l_tax_year_start    varchar2(50);
   -- Function name used in trace package
   func_name CONSTANT varchar2(50) := 'za_pay_calendars.create_calendar';

begin

   hr_utility.set_location(func_name, 1);
   -- Obtain the Business Group Id of the current user
   l_business_group_id := fnd_profile.value('PER_BUSINESS_GROUP_ID');
   -- Obtain the day on which the Company Financial Year starts
   l_fiscal_start_day := to_number(
                  to_char(retrieve_fiscal_year_start(l_business_group_id), 'DD'));
   --
   -- Obtain the date on which the Payroll Tax Year starts
   l_tax_year_start := retrieve_tax_year_start;

   -- Generate the Payroll Month Ends between p_first_end_date and p_last_end_date
   create_za_payroll_month_ends
   (
      p_payroll_id,
      p_first_end_date,
      p_last_end_date,
      l_fiscal_start_day,
      p_base_period_type,
      p_multiple,
      p_fpe_date
   );

   -- Generate the Tax Years between p_first_end_date and p_last_end_date
   create_za_employee_tax_years
   (
      p_payroll_id,
      p_first_end_date,
      p_last_end_date,
      l_tax_year_start,
      p_proc_period_type
   );

   -- Generate the Calendar Years between p_first_end_date and p_last_end_date
   create_za_employee_cal_years
   (
      p_payroll_id,
      p_first_end_date,
      p_last_end_date,
      p_proc_period_type
   );

   -- Generate the Tax Quarters between p_first_end_date and p_last_end_date
   create_za_tax_quarters
   (
      p_payroll_id,
      p_first_end_date,
      p_last_end_date
   );

end create_calendar;

---------------------------------------------------------------------------------------
--   This function is called to retrieve the Payroll Tax Year Start from the table
--   pay_legislation_rules.
--   NOTE: The function makes sure that the Payroll Tax Year is in DD-MON format.
---------------------------------------------------------------------------------------
function retrieve_tax_year_start return varchar2 is

   -- The Payroll Tax Year start date in DD-MON format.
   l_tax_year_start varchar2(50);
   -- The day of the Payroll Tax Year
   l_tax_day        number;
   -- The month of the Payroll Tax Year
   l_tax_month      varchar2(50);
   -- Function name used in trace package
   func_name CONSTANT varchar2(50) := 'za_pay_calendars.retrieve_tax_year_start';

begin

   hr_utility.set_location(func_name, 1);
   -- Obtain the Tax Year Start from pay_legislation_rules
   select
      rule_mode
   into
      l_tax_year_start
   from
      pay_legislation_rules
   where
      legislation_code = 'ZA'
   and
      rule_type = 'L';

   -- Determine the day of the Tax Year
   l_tax_day :=
      to_number(substr(l_tax_year_start, 1, instr(l_tax_year_start, '-') - 1));
   -- Check whether this is a valid day
   if l_tax_day > 31 then
      raise invalid_number;
   end if;

   -- Determine the month of the Tax Year
   l_tax_month := substr(l_tax_year_start, instr(l_tax_year_start, '-') + 1, 3);
   -- Check whether this is a valid month
   if instr('JAN,FEB,MAR,APR,MAY,JUN,JUL,AUG,SEP,OCT,NOV,DEC', l_tax_month) = 0 then
      raise invalid_number;
   end if;

   return l_tax_year_start;

exception
   -- The Tax Year is not in DD-MON format
   when no_data_found then
      hr_utility.set_message(800, 'PAY_PAYROLL_TAX_YEAR');
      hr_utility.raise_error;
   when too_many_rows then
      hr_utility.set_message(800, 'PAY_PAYROLL_TAX_YEAR');
      hr_utility.raise_error;
   when invalid_number then
      hr_utility.set_message(800, 'PAY_PAYROLL_TAX_YEAR');
      hr_utility.raise_error;

end retrieve_tax_year_start;

---------------------------------------------------------------------------------------
--   This function is called to retrieve the Company Fiscal Year Start for the
--   current Business Group.
--   Parameters:
--   p_business_group_id - The Business Group ID of the currently logged in user.
--   NOTE: The flexfield already forces this value to DD-MON-YYYY format.
---------------------------------------------------------------------------------------
function retrieve_fiscal_year_start
   (
      p_business_group_id in number
   )
   return date is

   -- The start date of the Fiscal year
   l_fiscal_start date;
   -- Function name used in trace package
   func_name CONSTANT varchar2(50) := 'za_pay_calendars.retrieve_fiscal_year_start';

begin

   hr_utility.set_location(func_name, 1);
   -- Determine the Company Fiscal Year Start for the current Business Group
   select
      fnd_date.canonical_to_date(org_information11)
   into
      l_fiscal_start
   from
      hr_organization_information
   where
      organization_id = p_business_group_id
   and
      org_information_context = 'Business Group Information';

   return l_fiscal_start;

exception
   when no_data_found then
      hr_utility.set_message(800, 'PAY_COMPANY_FISCAL_YEAR');
      hr_utility.raise_error;

end retrieve_fiscal_year_start;

---------------------------------------------------------------------------------------
--    This procedure creates the Payroll Month Ends for the ZA calendars, by using the
--    following steps:
--     1. Loop through the periods.
--        2. Calculate the Company Financial Month Start for the current period.
--        3. Store the Financial Month Start and End Date of the current period.
--        4. If the Financial Month Start of the current period is different from that
--           of the previous period, then the previous period is a Payroll Month End.
--           Update all the periods between l_store_end_date and the previous period,
--           so that their Payroll Month End is equal to the Period End Date of the
--           previous period. Store the current period's end in l_store_end_date.
--   NOTE: For the last few periods you might have to generate extra periods, using
--         add_multiple_of_base, in order to find the Payroll Month End.
--   Parameters:
--   p_payroll_id       - The primary key ID of the payroll.
--   p_first_end_date   - The first period end date in the generation time span.
--   p_last_end_date    - The last period end date in the generation time span.
--   p_fiscal_start_day - The day on which the Company Fiscal Year starts.
--   p_base_period_type - The base period type, other period types are multiples of the
--                        base period type, e.g. WEEKLY, MONTHLY, SEMIMONTHLY.
--   p_multiple         - The amount of base periods that make up the period type.
--   p_fpe_date         - The first period end date in the payroll time span.
---------------------------------------------------------------------------------------
procedure create_za_payroll_month_ends
   (
      p_payroll_id       in number,
      p_first_end_date   in date,
      p_last_end_date    in date,
      p_fiscal_start_day in number,
      -- Parameters needed to call the core function add_multiple_of_base
      p_base_period_type in varchar2,
      p_multiple         in number,
      p_fpe_date         in date
   )
   is

   -- Temporary variable used to store the previous period's end date.
   l_previous_end_date  date;
   -- Temporary variable used to store the end date where the Payroll Month starts.
   l_store_end_date     date;
   -- Temporary variable used to store the previous period's end date.
   l_old_end_date       date;
   -- Used to store the current period's end date.
   l_end_date           date;
   -- Temporary variable used to store the Fiscal Month Start.
   l_store_fin_ms       date;
   -- Used to store the current period's Fiscal Month Start.
   l_fin_ms             date;
   -- Function name used in trace package
   func_name CONSTANT varchar2(50) := 'za_pay_calendars.za_payroll_month_ends';

   -- Cursor that holds all the periods in the generation time span.
   cursor get_periods is
      select
         end_date
      from
         per_time_periods
      where
         payroll_id = p_payroll_id
      and
         end_date between p_first_end_date and p_last_end_date
      order by
         end_date;

begin

   hr_utility.set_location(func_name, 1);
   open get_periods;
   -- Store the first period end date
   fetch get_periods into l_store_end_date;

   -- Check whether there are any periods to process
   if get_periods%notfound then
      -- No periods to generate Month Ends for.
      null;
   else
      -- Calculate the Company Financial Month Start for the first period and store it
      l_store_fin_ms :=
         generate_fiscal_month_start(l_store_end_date, p_fiscal_start_day);

      -- Store the previous period end date
      l_previous_end_date := l_store_end_date;

      -- Loop through the remaining periods
      loop
         fetch get_periods into l_end_date;
         exit when get_periods%notfound;

         -- Calculate the Company Financial Month Start for the current period and
         -- compare it with the previous one
         l_fin_ms :=
            generate_fiscal_month_start(l_end_date, p_fiscal_start_day);

         -- If the Company Financial Month Starts differ, then the previous period is a
         -- Payroll Month End
         if l_store_fin_ms <> l_fin_ms then
            -- Update all the periods between l_store_end_date and the previous
            -- period, so that their Payroll Month End is equal to the Period End Date
            -- of the previous period
            update
               per_time_periods
            set
               pay_advice_date = l_previous_end_date
            where
               payroll_id = p_payroll_id
            and
               end_date between l_store_end_date and l_previous_end_date;

            -- Set l_store_end_date to the current period's end date
            l_store_end_date := l_end_date;
         end if;

         -- Store the previous period's end date
         l_previous_end_date := l_end_date;
         l_store_fin_ms := l_fin_ms;
      end loop;

      -- For the last few periods there might not exist enough periods in the payroll
      -- time span to obtain the Payroll Month End, therefore you have to obtain the
      -- Payroll Month End for these periods by generating dummy periods using the
      -- add_multiple_of_base function.
      if l_store_end_date <= p_last_end_date then

         -- Save the period to update from
         l_end_date := l_store_end_date;

         -- Loop until you find a Period End Date that is bigger than the current
         -- Company Financial Month Start
         while l_store_end_date < l_store_fin_ms loop

            -- Store the old end date
            l_old_end_date := l_store_end_date;

            -- Determine the next period's end date
            l_store_end_date := add_multiple_of_base(l_store_end_date,
                                                     p_base_period_type,
                                                     p_multiple,
                                                     p_fpe_date);
         end loop;

         -- Update all the periods between l_store_end_date and the last period,
         -- so that their Payroll Month End is equal to l_old_end_date
         update
            per_time_periods
         set
            pay_advice_date = l_old_end_date
         where
            payroll_id = p_payroll_id
         and
            end_date between l_end_date and p_last_end_date;

      end if;
   end if;
   close get_periods;
end create_za_payroll_month_ends;

---------------------------------------------------------------------------------------
--   This function returns the Company Fiscal Month Start associated with the payroll
--   period. It returns the first date that falls on the day on which the Company
--   Fiscal Year start, and which is larger than the period's end date.
--   Parameters:
--   p_end_date         - The period end date of the pay period.
--   p_fiscal_start_day - The day on which the Company Fiscal Year starts.
---------------------------------------------------------------------------------------
function generate_fiscal_month_start
   (
      p_end_date   in date,
      p_fiscal_start_day in number
   )
   return date is

   -- Temporary variable that holds the Fiscal Month Start.
   l_fiscal_ms date;
   -- Function name used in trace package
   func_name CONSTANT varchar2(50) := 'za_pay_calendars.generate_fiscal_month_start';

begin

   hr_utility.set_location(func_name, 1);
   -- As a first try, try using the day of the fiscal year and the month and year
   -- of the period's end date
   -- next_lower_day checks whether the date exist, otherwise it subtracts days until
   -- the date does exist
   l_fiscal_ms := next_lower_day(p_fiscal_start_day, p_end_date);

   -- The date must be larger than the period's end date, otherwise you must add a
   -- month
   while l_fiscal_ms <= p_end_date loop
      l_fiscal_ms := next_lower_day(p_fiscal_start_day, add_months(l_fiscal_ms, 1));
   end loop;
   return l_fiscal_ms;
end generate_fiscal_month_start;

---------------------------------------------------------------------------------------
--   This function returns p_fiscal_start_day concatenated with p_date's month and
--   year, if it exist, else it returns the next lower date that exist.
--   Parameters:
--   p_fiscal_start_day - The day on which the Fiscal Year starts.
--   p_date             - A valid date that has the month and year of the date to be
--                        returned.
---------------------------------------------------------------------------------------
function next_lower_day
   (
      p_fiscal_start_day in number,
      p_date             in date
   )
   return date is

   -- The last day of the month.
   l_last_day number;
   -- The date of the last day of the month.
   l_last     date;
   -- Function name used in trace package
   func_name CONSTANT varchar2(50) := 'za_pay_calendars.next_lower_day';

begin

   hr_utility.set_location(func_name, 1);
   -- Determine the date of the last day of the month
   l_last := last_day(p_date);

   -- Determine the day of the last day of the month
   l_last_day := to_char(l_last, 'DD');

   -- If the day of the date is larger than the last day of the month,
   -- return the last day of the month, else return the date
   if p_fiscal_start_day >= l_last_day then
      return l_last;
   else
      return to_date(to_char(p_fiscal_start_day) || '-' ||
                     to_char(p_date, 'MM') || '-' ||
                     to_char(p_date, 'YYYY'), 'DD-MM-YYYY');
   end if;

end next_lower_day;

---------------------------------------------------------------------------------------
--   This function performs the date calculation according to the base period type for
--   the period type being considered. Note that for WEEKLY base period, the
--   calculation can be performed by adding days ie. straightforward addition
--   operation. For MONTHLY base period, the add_months() function is used. The
--   exception to these general categories is semi-monthly, which is handled explicitly
--   by the SEMIMONTHLY base period. This case only uses the p_multiple parameter to
--   determine whether to add or subtract a semi-month, ie. this function can only
--   increase semi-months unitarily. Furthermore, it has exclusive use of the
--   'regular_pay_mode' parameter, which for SEMIMONTHLY, indicates whether or not we
--   are calculating for a regular payment date calculation. The p_fpe_date is the
--   first period's end-date and is needed only for semimonthly period calculations.
--   NOTE: This function is a copy of the core function in the hr_payrolls package,
--   which does not have a public interface.
---------------------------------------------------------------------------------------
function add_multiple_of_base
   (
      p_target_date      in date,
      p_base_period_type in varchar2,
      p_multiple         in number,
      p_fpe_date         in date,
      p_regular_pay_mode boolean default false,
      p_pay_date_offset  number  default null
   )
   return date is

   func_name CONSTANT varchar2(50) := 'za_pay_calendars.add_multiple_of_base';
   rest_of_date       varchar2(9);
   temp_date          date;

begin

   -- Errors can occur when performing date manipulation.
   if p_base_period_type = WEEKLY then
      hr_utility.set_location(func_name, 1);
      return (p_target_date + (7 * p_multiple));
   elsif p_base_period_type = MONTHLY then
      hr_utility.set_location(func_name, 2);
      return (add_months(p_target_date, p_multiple));
   else
      -- This is semi-monthly. A pair of semi-months always spand a whole calendar
      -- month. Their start and end dates are either 1st - 15th or 16th - last day of
      -- month. This makes the addition/subtraction of a period reasonably
      -- straightforward, if a little involved.
      -- On the other hand, if the p_regular_pay_mode is TRUE, we have to take into
      -- account the regular pay date offset.
      if not p_regular_pay_mode then
         if p_multiple > 0 then
            -- Addition of one semi-month.
            return(next_semi_month(p_target_date, p_fpe_date));
         else
            -- Substraction of one semi-month.
            return(prev_semi_month(p_target_date, p_fpe_date));
         end if;
      else
         -- Special calculation for regular payment date offset. In this special case,
         -- we calculate the pay date of the previous semimonth period: Current
         -- pay-date -> Current end-date -> Previous period's end-date -> Previous
         -- period's pay-date.
         temp_date := prev_semi_month(p_target_date - p_pay_date_offset,
                                      p_fpe_date) + p_pay_date_offset;
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

---------------------------------------------------------------------------------------
--   Locally defined function that, given the end-date of a semi-month period and the
--   first period's end-date (p_fpe_date) returns the end date of the following
--   semi-monthly period.
--   NOTE: This function is a copy of the core function in the hr_payrolls package,
--   which does not have a public interface.
---------------------------------------------------------------------------------------
function next_semi_month
   (
      p_semi_month_date in date,
      p_fpe_date        in date
   )
   return date is

   day_of_month       varchar2(2);
   last_of_month      date;
   temp_day           varchar2(2);
   func_name CONSTANT varchar2(50) := 'za_pay_calendars.next_semi_month';

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

---------------------------------------------------------------------------------------
--   Locally defined function that, given the end-date of a semi-month period and the
--   first period's end-date (p_fpe_date) returns the end date of the previous
--   semi-monthly period.
--   NOTE: This function is a copy of the core function in the hr_payrolls package,
--   which does not have a public interface.
---------------------------------------------------------------------------------------
function prev_semi_month
   (
      p_semi_month_date in date,
      p_fpe_date        in date
   )
   return date is

   day_of_month varchar2(2);
   last_of_month date;
   temp_date date;
   temp_day varchar2(2);
   func_name CONSTANT varchar2(50) := 'za_pay_calendars.prev_semi_month';

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

---------------------------------------------------------------------------------------
--   This procedure creates the payroll tax years for the ZA calendars, by using the
--   following steps:
--    1. Determine the first tax year start in the generation period:
--       2. Check whether the previous, current or next year is closest to the first
--          period's start date.
--       3. If the first period's Payroll Month End is within 14 days of the Tax Year
--          End, then use that Month End as the first Employee Tax Year End;
--          else,
--          if the Payroll Month End is larger than the Tax Year End, add a year to the
--          Tax Year End. Loop forward through the periods until you find a Payroll
--          Month End that is larger than the Tax Year End, and determine whether the
--          current Payroll Month End or the previous one is closer to the Tax Year
--          End. Use the closest Payroll Month End as the first Employee Tax Year End.
--       4. Update all the periods up to the end of this Payroll Month End with the
--          first Tax Year.
--    5. Default the Tax Year for the rest of the periods:
--       6. Get the number of periods in the year from per_time_period_types.
--       7. Loop through all the remaining periods.
--          8. Jump forward by the amount of periods in the year, and keep moving
--             forward until you find the last period in that Month End. Update the
--             periods in between to the next Tax year.
--       9. Go to the beginning of the loop.
--   10. If there are not enough periods to move forward by an entire year, then just
--       update the remaining periods to the next Tax Year.
--   ASSUMPTION: The tax year start is in 'DD-MON' format.
--   Parameters:
--   p_payroll_id       - The primary key ID of the payroll.
--   p_first_end_date   - The first period end date in the generation time span.
--   p_last_end_date    - The last period end date in the generation time span.
--   p_tax_year_start   - The date on which the tax year starts in DD-MON format.
--   p_proc_period_type - The processing period type, e.g. Week, Calendar Month.
---------------------------------------------------------------------------------------
procedure create_za_employee_tax_years
   (
      p_payroll_id       in number,
      p_first_end_date   in date,
      p_last_end_date    in date,
      p_tax_year_start   in varchar2,
      p_proc_period_type in varchar2
   )
   is

   -- Variable used to hold the start date.
   l_start_date     date;
   -- Variable used to hold the end date.
   l_end_date       date;
   -- Variable used to store the end date.
   l_store_end_date date := p_first_end_date;
   -- Variable used to store the end date.
   l_old_end_date   date;
   -- Variable used to hold the Payroll Month End.
   l_pay_me         date;
   -- Variable used to store the Payroll Month End.
   l_old_pay_me     date;
   -- Variable used to hold the Tax Year.
   l_tax_year       date;
   -- Variable used to move a certain amount of rows forward.
   l_cur_row        number;
   -- The number of periods in the year.
   l_no_periods     number;
   -- Function name used in trace package
   func_name CONSTANT varchar2(50) := 'za_pay_calendars.create_za_employee_tax_years';
   -- Check whether a year should be added
   l_flag           number := 0;

   -- Cursor that holds all the periods in the generation time span.
   cursor get_periods is
      select
         end_date, pay_advice_date
      from
         per_time_periods
      where
         payroll_id = p_payroll_id
      and
         end_date between p_first_end_date and p_last_end_date
      order by
         end_date;

   -- Cursor that looks for a previous payroll month end
   cursor get_previous_periods is
      select
         end_date, pay_advice_date
      from
         per_time_periods
      where
         payroll_id = p_payroll_id
      and
         end_date < p_first_end_date
      order by
         end_date desc;

begin

---------------------------------------------------------------------------------------
--   Determine the first tax year start in the generation period
---------------------------------------------------------------------------------------
   hr_utility.set_location(func_name, 1);
   declare
      l_tax_year2 date;
   begin
      -- Obtain the first period's start date
      select
         start_date
      into
         l_start_date
      from
         per_time_periods
      where
         payroll_id = p_payroll_id
      and
         end_date = p_first_end_date;

      -- Concatenate p_tax_year_start with the year of the start_date
      l_tax_year := to_date(p_tax_year_start ||
                            to_char(l_start_date, 'YYYY'), 'DD-MON-YYYY');

      -- Determine the next year's Tax year start
      l_tax_year2 := to_date(p_tax_year_start ||
                             to_char(add_months(l_start_date, 12), 'YYYY'),
                             'DD-MON-YYYY');

      -- Determine which one of the Tax Year Starts are the closest to the start date
      if abs(l_tax_year2 - l_start_date) < abs(l_tax_year - l_start_date) then
         l_tax_year := l_tax_year2;
      end if;

      -- Convert to a Tax Year End
      l_tax_year := l_tax_year - 1;

   exception
      when no_data_found then
         -- Create a dummy, since it won't be used anyway
         l_tax_year := to_date('01-03-1001', 'DD-MM-YYYY');
   end;

   open get_periods;
   fetch get_periods into l_end_date, l_old_pay_me;
   if get_periods%notfound then
      -- No periods to generate Tax Years for.
      null;
   else
      -- If the first period's Payroll Month End is within 14 days of the Tax Year
      -- End, then use that Month End as the first Employee Tax Year End
      if abs(l_old_pay_me-l_tax_year) < 15 then
         l_tax_year := l_old_pay_me;

         -- Find the last end date in the Payroll Month End
         select
            max(end_date)
         into
            l_store_end_date
         from
            per_time_periods
         where
            payroll_id = p_payroll_id
         and
            pay_advice_date = l_old_pay_me;
      else
         -- If the Payroll Month End is larger than the Tax Year End, then add a year
         -- to the Tax Year End
         if l_old_pay_me > l_tax_year then
            l_tax_year := add_months(l_tax_year, 12);
         end if;

         loop
            -- Get the current period's Payroll Month End
            fetch get_periods into l_end_date, l_pay_me;
            if get_periods%notfound then
               l_flag := 1;
            end if;
            exit when get_periods%notfound;

            -- If the current Payroll Month End is larger than the Tax Year End, then
            -- decide whether this Payroll Month End or the previous one is closer to
            -- the Tax Year End. Use that Month End as the first Employee Tax Year End.
            if l_pay_me > l_tax_year then

               -- Determine whether this Payroll Month End or the previous one is
               -- closer to the Tax Year End.
               if abs(l_old_pay_me - l_tax_year) < abs(l_pay_me - l_tax_year) then
                  l_tax_year := l_old_pay_me;
                  l_store_end_date := l_old_end_date;
               else
                  l_tax_year := l_pay_me;

                  -- Find the last end date in the Payroll Month End
                  select
                     max(end_date)
                  into
                     l_store_end_date
                  from
                     per_time_periods
                  where
                     payroll_id = p_payroll_id
                  and
                     pay_advice_date = l_pay_me;
               end if;

               -- Exit the loop
               exit;

            end if;

            -- Store the previous Payroll Month End and End Date
            l_old_pay_me := l_pay_me;
            l_old_end_date := l_end_date;
         end loop;
      end if;

      -- Update the first periods to the first tax year
      update
         per_time_periods
      set
         prd_information1 = to_char(l_tax_year, 'YYYY'),
		 prd_information_category = 'ZA'
      where
         payroll_id = p_payroll_id
      and
         end_date between p_first_end_date and l_store_end_date;
   end if;
   close get_periods;

---------------------------------------------------------------------------------------
--   Now default the tax year for the rest of the periods
---------------------------------------------------------------------------------------
   open get_periods;
   fetch get_periods into l_end_date, l_pay_me;
   if get_periods%notfound then
      -- No periods to generate Tax Years for.
      null;
   else
      -- Move to the next period to process
      while l_end_date <= l_store_end_date loop
         -- Get the current period's details
         fetch get_periods into l_end_date, l_pay_me;
         exit when get_periods%notfound;
      end loop;

      -- If there are no more periods to process then do nothing
      if get_periods%notfound then
         -- This should never happen
         null;
      else
         begin
            -- Get the number of periods in the year
            select
               number_per_fiscal_year
            into
               l_no_periods
            from
               per_time_period_types
            where
               period_type = p_proc_period_type;

         exception
            -- No details exists for this period type
            when no_data_found then
               hr_utility.set_message(800, 'PAY_NO_PERIOD_DETAILS');
               hr_utility.raise_error;
         end;

         -- Loop through all the periods until you are finished
         while not get_periods%notfound loop

            -- Estimate the location of the next tax year, by adding the amount of
            -- payroll periods in the tax year to the current position
            l_cur_row := get_periods%rowcount + l_no_periods - 1;

            -- Save the current end date
            l_old_end_date := l_end_date;

            -- Determine the current tax year
            if l_flag = 1 then
               l_flag := 0;
            else
               l_tax_year := add_months(l_tax_year, 12);
            end if;

            -- Move forward by the amount of payroll periods in the tax year
            while get_periods%rowcount < l_cur_row loop
               -- Get the current period's details
               fetch get_periods into l_end_date, l_pay_me;
               exit when get_periods%notfound;
            end loop;

            -- If we got to the end of the cursor then we have to update the tax year up
            -- to the end of the cursor, otherwise move forward until you find the last
            -- period in that Payroll Month End
            if get_periods%notfound then
               -- Update the periods up to the last period end date
               update
                  per_time_periods
               set
                  prd_information1 = to_char(l_tax_year, 'YYYY'),
                  prd_information_category = 'ZA'
               where
                  payroll_id = p_payroll_id
               and
                  end_date between l_old_end_date and p_last_end_date;
            else
               -- Find the last period in the current Payroll Month End
               l_old_pay_me := l_pay_me;
               while l_pay_me = l_old_pay_me loop
                  fetch get_periods into l_end_date, l_pay_me;
                  exit when get_periods%notfound;
                  -- Save the previous end date
                  l_store_end_date := l_end_date;
               end loop;

               if get_periods%notfound then
                  -- Update the periods up to the last period end date
                  update
                     per_time_periods
                  set
                     prd_information1 = to_char(l_tax_year, 'YYYY'),
                     prd_information_category = 'ZA'
                  where
                     payroll_id = p_payroll_id
                  and
                     end_date between l_old_end_date and p_last_end_date;
               else
                  -- Update the periods up to the previous period
                  update
                     per_time_periods
                  set
                     prd_information1 = to_char(l_tax_year, 'YYYY'),
                     prd_information_category = 'ZA'
                  where
                     payroll_id = p_payroll_id
                  and
                     end_date between l_old_end_date and l_store_end_date;
               end if;
            end if;
        end loop;
     end if;
   end if;
   close get_periods;
end create_za_employee_tax_years;

---------------------------------------------------------------------------------------
--   This procedure creates the payroll calendar years for the ZA calendars, by using
--   the following steps:
--    1. Determine the first calendar year start in the generation period:
--       2. Check whether the previous, current or next year is closest to the first
--          period's start date.
--       3. If the first period's Payroll Month End is within 14 days of the Cal Year
--          End, then use that Month End as the first Employee Cal Year End;
--          else,
--          if the Payroll Month End is larger than the Cal Year End, add a year to the
--          Cal Year End. Loop forward through the periods until you find a Payroll
--          Month End that is larger than the Cal Year End, and determine whether the
--          current Payroll Month End or the previous one is closer to the Cal Year
--          End. Use the closest Payroll Month End as the first Employee Cal Year End.
--       4. Update all the periods up to the end of this Payroll Month End with the
--          first Cal Year.
--    5. Default the Cal Year for the rest of the periods:
--       6. Get the number of periods in the year from per_time_period_types.
--       7. Loop through all the remaining periods.
--          8. Jump forward by the amount of periods in the year, and keep moving
--             forward until you find the last period in that Month End. Update the
--             periods in between to the next Cal year.
--       9. Go to the beginning of the loop.
--   10. If there are not enough periods to move forward by an entire year, then just
--       update the remaining periods to the next Cal Year.
--   Parameters:
--   p_payroll_id       - The primary key ID of the payroll.
--   p_first_end_date   - The first period end date in the generation time span.
--   p_last_end_date    - The last period end date in the generation time span.
--   p_proc_period_type - The processing period type, e.g. Week, Calendar Month.
---------------------------------------------------------------------------------------
procedure create_za_employee_cal_years
   (
      p_payroll_id       in number,
      p_first_end_date   in date,
      p_last_end_date    in date,
      p_proc_period_type in varchar2
   )
   is

   -- Variable used to hold the start date.
   l_start_date     date;
   -- Variable used to hold the end date.
   l_end_date       date;
   -- Variable used to store the end date.
   l_store_end_date date;
   -- Variable used to store the end date.
   l_old_end_date   date;
   -- Variable used to hold the Payroll Month End.
   l_pay_me         date;
   -- Variable used to store the Payroll Month End.
   l_old_pay_me     date;
   -- Variable used to hold the Calendar Year.
   l_cal_year       date;
   -- Variable used to move a certain amount of rows forward.
   l_cur_row        number;
   -- The number of periods in the year.
   l_no_periods     number;
   -- Function name used in trace package
   func_name CONSTANT varchar2(50) := 'za_pay_calendars.create_za_employee_cal_years';

   -- Cursor that holds all the periods in the generation time span.
   cursor get_periods is
      select
         end_date, pay_advice_date
      from
         per_time_periods
      where
         payroll_id = p_payroll_id
      and
         end_date between p_first_end_date and p_last_end_date
      order by
         end_date;

begin

---------------------------------------------------------------------------------------
--   Determine the first calendar year start in the generation period
---------------------------------------------------------------------------------------
   hr_utility.set_location(func_name, 1);
   declare
      l_cal_year2 date;
   begin
      -- Obtain the first period's start date
      select
         start_date
      into
         l_start_date
      from
         per_time_periods
      where
         payroll_id = p_payroll_id
      and
         end_date = p_first_end_date;

      -- Concatenate 01-JAN with the year of the start_date
      l_cal_year := to_date('01-JAN' ||
                            to_char(l_start_date, 'YYYY'), 'DD-MON-YYYY');

      -- Determine the next year's Calendar year start
      l_cal_year2 := to_date('01-JAN' ||
                             to_char(add_months(l_start_date, 12), 'YYYY'),
                             'DD-MON-YYYY');

      -- Determine which one of the Cal Year Starts are the closest to the start date
      if abs(l_cal_year2 - l_start_date) < abs(l_cal_year - l_start_date) then
         l_cal_year := l_cal_year2;
      end if;

      -- Convert to a Calendar Year End
      l_cal_year := l_cal_year - 1;

   exception
      when no_data_found then
         -- Create a dummy, since it won't be used anyway
         l_cal_year := to_date('01-01-1001', 'DD-MM-YYYY');
   end;

   open get_periods;
   fetch get_periods into l_end_date, l_old_pay_me;
   if get_periods%notfound then
      -- No periods to generate Calendar Years for.
      null;
   else
      -- If the first period's Payroll Month End is within 14 days of the Cal Year
      -- End, then use that Month End as the first Employee Cal Year End
      if abs(l_old_pay_me-l_cal_year) < 15 then
         l_cal_year := l_old_pay_me;

         -- Find the last end date in the Payroll Month End
         select
            max(end_date)
         into
            l_store_end_date
         from
            per_time_periods
         where
            payroll_id = p_payroll_id
         and
            pay_advice_date = l_old_pay_me;

      else
         -- If the Payroll Month End is larger than the Cal Year End, then add a year
         -- to the Cal Year End
         if l_old_pay_me > l_cal_year then
            l_cal_year := add_months(l_cal_year, 12);
         end if;

         loop
            -- Get the current period's Payroll Month End
            fetch get_periods into l_end_date, l_pay_me;
            exit when get_periods%notfound;

            -- If the current Payroll Month End is larger than the Cal Year End, then
            -- decide whether this Payroll Month End or the previous one is closer to
            -- the Cal Year End. Use that Month End as the first Employee Cal Year End.
            if l_pay_me > l_cal_year then

               -- Determine whether this Payroll Month End or the previous one is
               -- closer to the Calendar Year End.
               if abs(l_old_pay_me - l_cal_year) < abs(l_pay_me - l_cal_year) then
                  l_cal_year := l_old_pay_me;
                  l_store_end_date := l_old_end_date;
               else
                  l_cal_year := l_old_pay_me;

                  -- Find the last end date in the Payroll Month End
                  select
                     max(end_date)
                  into
                     l_store_end_date
                  from
                     per_time_periods
                  where
                     payroll_id = p_payroll_id
                  and
                     pay_advice_date = l_pay_me;
               end if;

               -- Exit the loop
               exit;

            end if;

            -- Store the previous Payroll Month End and End Date
            l_old_pay_me := l_pay_me;
            l_old_end_date := l_end_date;
         end loop;
      end if;

      -- Update the first periods to the first calendar year
      update
         per_time_periods
      set
         prd_information3 = to_char(l_cal_year, 'YYYY'),
         prd_information_category = 'ZA'
      where
         payroll_id = p_payroll_id
      and
         end_date between p_first_end_date and l_store_end_date;
   end if;
   close get_periods;

---------------------------------------------------------------------------------------
--   Now default the calendar year for the rest of the periods
---------------------------------------------------------------------------------------
   open get_periods;
   fetch get_periods into l_end_date, l_pay_me;
   if get_periods%notfound then
      -- No periods to generate Calendar Years for.
      null;
   else
      -- Move to the next period to process
      while l_end_date <= l_store_end_date loop
         -- Get the current period's details
         fetch get_periods into l_end_date, l_pay_me;
         exit when get_periods%notfound;
      end loop;

      -- If there are no more periods to process then do nothing
      if get_periods%notfound then
         -- This should never happen
         null;
      else
         begin
            -- Get the number of periods in the year
            select
               number_per_fiscal_year
            into
               l_no_periods
            from
               per_time_period_types
            where
               period_type = p_proc_period_type;

         exception
            -- No details exists for this period type
            when no_data_found then
               hr_utility.set_message(800, 'PAY_NO_PERIOD_DETAILS');
               hr_utility.raise_error;

         end;

         -- Loop through all the periods until you are finished
         while not get_periods%notfound loop

            -- Estimate the location of the next cal year, by adding the amount of
            -- payroll periods in the calendar year to the current position.
            l_cur_row := get_periods%rowcount + l_no_periods - 1;

            -- Save the current end date
            l_old_end_date := l_end_date;

            -- Determine the current calendar year
            l_cal_year := add_months(l_cal_year, 12);

            -- Move forward by the amount of payroll periods in the calendar year
            while get_periods%rowcount < l_cur_row loop
               -- Get the current period's details
               fetch get_periods into l_end_date, l_pay_me;
               exit when get_periods%notfound;
            end loop;

            -- If we got to the end of the cursor then we have to update the cal year up
            -- to the end of the cursor, otherwise move forward until you find the last
            -- period in that Payroll Month End
            if get_periods%notfound then
               -- Update the periods up to the last period end date
               update
                  per_time_periods
               set
                  prd_information3 = to_char(l_cal_year, 'YYYY'),
                  prd_information_category = 'ZA'
               where
                  payroll_id = p_payroll_id
               and
                  end_date between l_old_end_date and p_last_end_date;
            else
               -- Find the last period in the current Payroll Month End
               l_old_pay_me := l_pay_me;
               while l_pay_me = l_old_pay_me loop
                  fetch get_periods into l_end_date, l_pay_me;
                  exit when get_periods%notfound;
                  -- Save the previous end date
                  l_store_end_date := l_end_date;
               end loop;

               if get_periods%notfound then
                  -- Update the periods up to the last period end date
                  update
                     per_time_periods
                  set
                     prd_information3 = to_char(l_cal_year, 'YYYY'),
                     prd_information_category = 'ZA'
                  where
                     payroll_id = p_payroll_id
                  and
                     end_date between l_old_end_date and p_last_end_date;
               else
                  -- Update the periods up to the previous period
                  update
                     per_time_periods
                  set
                     prd_information3 = to_char(l_cal_year, 'YYYY'),
                     prd_information_category = 'ZA'
                  where
                     payroll_id = p_payroll_id
                  and
                     end_date between l_old_end_date and l_store_end_date;
               end if;
            end if;
        end loop;
     end if;
   end if;
   close get_periods;
end create_za_employee_cal_years;

---------------------------------------------------------------------------------------
--   This procedure creates the payroll tax quarters for the ZA calendars, using the
--   following steps:
--    1. Determine the tax year of the first period.
--    2. Default the tax quarters for this tax year by counting down from the end of
--       the tax year, instead of up as explained in the following steps.
--    3. Loop through the rest of the periods.
--       4. Every time you encounter a new Payroll Month End increment the counter.
--       5. If you have counted 3 Payroll Month Ends, update the periods in between
--          to the current quarter value. Increment the quarter value, if the quarter
--          value is 5 then reset it to 1.
--    6. Next period.
--    7. If you did not find 3 Payroll Month Ends, but there are still some periods
--       left, then update these periods to the current quarter value.
--   Parameters:
--   p_payroll_id       - The primary key ID of the payroll.
--   p_first_end_date   - The first period end date in the generation time span.
--   p_last_end_date    - The last period end date in the generation time span.
--   ASSUMPTION: The tax year and payroll month end details were already defaulted.
--   NOTE: This procedure currently only handles Week and Calendar Month period types.
---------------------------------------------------------------------------------------
procedure create_za_tax_quarters
   (
      p_payroll_id       in number,
      p_first_end_date   in date,
      p_last_end_date    in date
   )
   is

   -- Temporary variable that holds the tax year of the first period
   l_tax_year     per_time_periods.prd_information1%TYPE;
   -- Variable used to store the end date of the period
   l_old_end_date date;
   -- Variable used to hold the end date of the period
   l_end_date     date;
   -- Variable used to store the Payroll Month End of the period
   l_old_pay_me   date;
   -- Variable used to hold the Payroll Month End of the period
   l_pay_me       date;
   -- Variable used to count the Payroll Month Ends
   l_count        number;
   -- Variable used to count the Tax Quarters
   l_quarter      number;
   -- Variable used to check for one row left at end of generation span
   l_flag         number := 0;
   -- Function name used in trace package
   func_name CONSTANT varchar2(50) := 'za_pay_calendars.create_za_tax_quarters';

   -- The periods after the first tax year
   cursor get_periods(c_tax_year per_time_periods.prd_information1%TYPE) is
      select
         end_date, pay_advice_date
      from
         per_time_periods
      where
         payroll_id = p_payroll_id
      and
         end_date between p_first_end_date and p_last_end_date
      and
         prd_information1 > c_tax_year
      order by
         end_date;

   -- The periods in the first tax year, in reverse order
   cursor get_periods2(c_tax_year per_time_periods.prd_information1%TYPE) is
      select
         end_date, pay_advice_date
      from
         per_time_periods
      where
         payroll_id = p_payroll_id
      and
         prd_information1 = c_tax_year
      order by
         end_date DESC;

begin

   hr_utility.set_location(func_name, 1);
   begin
      -- Determine the tax year of the first period
      select
         prd_information1
      into
         l_tax_year
      from
         per_time_periods
      where
         payroll_id = p_payroll_id
      and
         end_date = p_first_end_date;

   exception
      -- Create a dummy, since it won't be used anyway
      when no_data_found then
         l_tax_year := '1001';

   end;

   -- Variable used to count 3 payroll months
   l_count := 1;
   -- Variable used to default quarter
   l_quarter := 5;
   open get_periods2(l_tax_year);
   fetch get_periods2 into l_old_end_date, l_old_pay_me;
   if get_periods2%notfound then
      -- No periods to generate Tax Quarters for.
      null;
   else
      loop
         -- Get the current period's Payroll Month End
         fetch get_periods2 into l_end_date, l_pay_me;
         if get_periods2%notfound then
            if get_periods2%rowcount = 1 then
               -- Set l_end_date so that only 1 row will be updated
               l_end_date := l_old_end_date - 1;
               exit;
            else
               exit;
            end if;
         end if;

         if l_pay_me < l_old_pay_me then

            -- If we have entered a new Payroll Month End increment the counter
            l_count := l_count + 1;

            -- Store the old Payroll Month end
            l_old_pay_me := l_pay_me;

            -- Check whether we have reached the last Payroll Month End in the quarter
            if l_count = 4 then

               -- Reset the counter
               l_count := 1;

               -- Increment the quarter
               l_quarter := l_quarter - 1;
               if l_quarter = 0 then
                  l_quarter := 4;
               end if;

               -- Update the periods with the quarter
               update
                  per_time_periods
               set
                  prd_information2 = to_char(l_quarter),
                  prd_information_category = 'ZA'
               where
                  payroll_id = p_payroll_id
               and
                  end_date between l_end_date and l_old_end_date;

               -- Store the beginning of the next quarter
               l_old_end_date := l_end_date;
            end if;

         end if;
      end loop;

      -- Default the last few periods if needed
      if l_end_date < l_old_end_date then

         -- Increment the quarter
         l_quarter := l_quarter - 1;
         if l_quarter = 0 then
            l_quarter := 4;
         end if;

         -- Update the periods with the quarter
         update
            per_time_periods
         set
            prd_information2 = to_char(l_quarter),
            prd_information_category = 'ZA'
         where
            payroll_id = p_payroll_id
         and
            end_date between l_end_date and l_old_end_date;

      end if;
   end if;
   close get_periods2;

   -- Variable used to count 3 payroll months
   l_count := 1;
   -- Variable used to default quarter
   l_quarter := 0;
   open get_periods(l_tax_year);
   fetch get_periods into l_old_end_date, l_old_pay_me;
   if get_periods%notfound then
      -- No periods to generate Tax Quarters for.
      null;
   else
      loop
         -- Get the current period's Payroll Month End
         fetch get_periods into l_end_date, l_pay_me;
         exit when get_periods%notfound;

         if l_pay_me > l_old_pay_me then

            -- Check whether there is one row left to generate
            if l_end_date = p_last_end_date then
               l_flag := 1;
            end if;

            -- If we have entered a new Payroll Month End increment the counter
            l_count := l_count + 1;

            -- Store the old Payroll Month end
            l_old_pay_me := l_pay_me;

            -- Check whether we have reached the last Payroll Month End in the quarter
            if l_count = 4 then

               -- Reset the counter
               l_count := 1;

               -- Increment the quarter
               l_quarter := l_quarter + 1;
               if l_quarter = 5 then
                  l_quarter := 1;
               end if;

               -- Update the periods with the quarter
               update
                  per_time_periods
               set
                  prd_information2 = to_char(l_quarter),
                  prd_information_category = 'ZA'
               where
                  payroll_id = p_payroll_id
               and
                  end_date between l_old_end_date and l_end_date;

               -- Store the beginning of the next quarter
               l_old_end_date := l_end_date;
            end if;

         end if;
      end loop;

      -- Default the last few periods if needed
      if (l_end_date > l_old_end_date) or l_flag = 1 then

         -- Increment the quarter
         l_quarter := l_quarter + 1;
         if l_quarter = 5 then
            l_quarter := 1;
         end if;

         -- Update the periods with the quarter
         update
            per_time_periods
         set
            prd_information2 = to_char(l_quarter),
            prd_information_category = 'ZA'
         where
            payroll_id = p_payroll_id
         and
            end_date between l_old_end_date and l_end_date;

      end if;
   end if;
   close get_periods;

end create_za_tax_quarters;

---------------------------------------------------------------------------------------
--   This procedure creates the period numbers for the ZA calendars. This procedure
--   should be called every time a change is made to the Payroll Tax Year field on the
--   Additional Period Information Flexfield. It uses the following steps:
--    1. Store the first period number of the first tax year in l_period, by selecting
--       it from per_time_periods.
--    2. Loop through the tax years.
--       3. Loop through the periods in the current tax year.
--          4.  Update the period number of the current period to l_period.
--          5.  Increment l_period.
--       4. Next period.
--       5. Reset l_period to 1.
--    6. Next tax year.
--   NOTE: There is no need to call this procedure during the period generation
--   process, the default period numbers should be correct.
--   NOTE: The procedure should be called with the end date of the period on which
--   the change occured as p_first_end_date, and the end date of the last period in
--   p_last_end_date
---------------------------------------------------------------------------------------
procedure create_za_period_numbers
   (
      p_payroll_id       in number,
      p_first_end_date   in date,
      p_last_end_date    in date,
      p_proc_period_type in varchar2
   )
   is

   -- Variable used to hold the current tax year
   l_tax_year per_time_periods.prd_information1%TYPE;
   -- The rowid of the period to be updated
   l_rowid    rowid;
   -- The current period's number
   l_period   number;
   -- The end date of the current period
   l_end_date date;
   -- Function name used in trace package
   func_name CONSTANT varchar2(50) := 'za_pay_calendars.create_za_period_numbers';

   -- All tax years in the generation time span.
   cursor tax_years is
      select distinct
         prd_information1
      from
         per_time_periods
      where
         payroll_id = p_payroll_id
      and
         end_date between p_first_end_date and p_last_end_date
      order by
         prd_information1;

   -- The periods in the current tax year.
   cursor get_periods(c_tax_year per_time_periods.prd_information1%TYPE) is
      select
         rowid, end_date
      from
         per_time_periods
      where
         payroll_id = p_payroll_id
      and
         end_date between p_first_end_date and p_last_end_date
      and
         prd_information1 = c_tax_year
      order by
         end_date;

begin

   hr_utility.set_location(func_name, 1);
   open tax_years;
   fetch tax_years into l_tax_year;
   if tax_years%notfound then
      -- This should never happen
      null;
   else

      begin
         -- Determine the first period number of the first tax year
         select
            period_num
         into
            l_period
         from
            per_time_periods
         where
            payroll_id = p_payroll_id
         and
            end_date = p_first_end_date;

      exception
         -- Create a dummy, since it won't be used anyway.
         when no_data_found then
            l_period := 1;

      end;

      -- Loop through tax years
      loop

         open get_periods(l_tax_year);
         -- Loop through periods in current tax year
         loop

            -- Get the period
            fetch get_periods into l_rowid, l_end_date;
            exit when get_periods%notfound;

            -- Update the period number of the current period
            update
               per_time_periods
            set
               period_num = l_period
            where
               rowid = l_rowid;

            -- Update the period name of the current period
            update
               per_time_periods
            set
               period_name = to_char(l_period) || ' ' || to_char(l_end_date, 'YYYY')
                             || ' ' || p_proc_period_type
            where
               rowid = l_rowid;

            -- Increment the period number
            l_period := l_period + 1;

         end loop;
         close get_periods;

         -- Reset the period number
         l_period := 1;

         -- Get the tax year
         fetch tax_years into l_tax_year;
         exit when tax_years%notfound;

      end loop;

   end if;
   close tax_years;

end create_za_period_numbers;

---------------------------------------------------------------------------------------

end pay_za_calendars_pkg;

/
