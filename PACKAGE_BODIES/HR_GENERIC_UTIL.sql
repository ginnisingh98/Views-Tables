--------------------------------------------------------
--  DDL for Package Body HR_GENERIC_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_GENERIC_UTIL" AS
/* $Header: pygenutl.pkb 120.1 2005/10/04 06:31:05 rchennur noship $ */

--
WEEKLY CONSTANT varchar2(1) := 'W';
MONTHLY CONSTANT varchar2(1) := 'M';
SEMIMONTHLY CONSTANT varchar2(1) := 'S';
--
--------------------------- get_period_details ---------------------------
--
PROCEDURE get_period_details (p_proc_period_type IN VARCHAR2,
                              p_base_period_type OUT NOCOPY VARCHAR2,
                              p_multiple         OUT NOCOPY NUMBER) IS
--
l_no_periods per_time_period_types.number_per_fiscal_year%type;
--
l_proc       VARCHAR2(100) := 'hr_generic_util.GET_PERIOD_DETAILS';
--
BEGIN
--
hr_utility.set_location(l_proc, 10);
--
SELECT number_per_fiscal_year
  INTO l_no_periods
  FROM per_time_period_types
 WHERE period_type = p_proc_period_type;
--
hr_utility.set_location(l_proc, 20);
--
-- Use the number of periods in a fiscal year to deduce the base
-- period and multiple.
--
IF l_no_periods = 1 THEN             -- Yearly
   p_base_period_type := MONTHLY;
   p_multiple := 12;
ELSIF l_no_periods = 2 THEN          -- Semi yearly
   p_base_period_type := MONTHLY;
   p_multiple := 6;
ELSIF l_no_periods = 4 THEN          -- Quarterly
   p_base_period_type := MONTHLY;
   p_multiple := 3;
ELSIF l_no_periods = 6 THEN          -- Bi monthly
   p_base_period_type := MONTHLY;
   p_multiple := 2;
ELSIF l_no_periods = 12 THEN         -- Monthly
   p_base_period_type := MONTHLY;
   p_multiple := 1;
ELSIF l_no_periods = 13 THEN         -- Lunar monthly
   p_base_period_type := WEEKLY;
   p_multiple := 4;
ELSIF l_no_periods = 24 THEN         -- Semi monthly
   p_base_period_type := SEMIMONTHLY;
   p_multiple := 1;                -- Not used for semi-monthly
ELSIF l_no_periods = 26 THEN         -- Fortnightly
   p_base_period_type := WEEKLY;
   p_multiple := 2;
ELSIF l_no_periods = 52 THEN         -- Weekly
   p_base_period_type := WEEKLY;
   p_multiple := 1;
ELSE
   -- Unknown period type.
   hr_utility.set_message(801, 'PAY_6601_PAYROLL_INV_PERIOD_TP');
   hr_utility.raise_error;
END IF;
--
hr_utility.set_location(l_proc, 30);
--
END get_period_details;
--
--
--------------------------- next_semi_month ----------------------------
--
-- Locally defined function that, given the end-date of a semi-month
-- period and the first period's end-date (p_fpe_date) returns
-- the end date of the following semi-monthly period.
--
FUNCTION next_semi_month(p_semi_month_date IN DATE,
                         p_fpe_date        IN DATE) return DATE IS
--
day_of_month varchar2(2);
last_of_month date;
temp_day varchar2(2);
--
l_proc          VARCHAR2(100) := 'hr_generic_util.next_semi_month';
--
BEGIN
--
hr_utility.set_location(l_proc, 1);
--
day_of_month := substr(to_char(p_fpe_date, 'DD-MM-YYYY'), 1, 2);
--
IF (day_of_month = '15') OR (last_day(p_fpe_date) = p_fpe_date) THEN
   --
   -- The first period's end-date is either the 15th or the end-of-month
   --
   IF last_day(p_semi_month_date) = p_semi_month_date THEN
         -- End of month: add 15 days
         return(p_semi_month_date + 15);
   ELSE
         -- 15th of month: return last day
         return(last_day(p_semi_month_date));
   END IF;
ELSE
   -- The first period's end-date is neither the 15th nor the end-of-month
   -- temp_day = smaller of the 2 day numbers used to calc period end-dates
   --
   temp_day := day_of_month ;
   IF temp_day > '15' THEN
      temp_day := substr(to_char(p_fpe_date - 15, 'DD-MM-YYYY'), 1, 2);
   END IF;
   --
   day_of_month := substr(to_char(p_semi_month_date, 'DD-MON-YYYY'), 1, 2);
   IF day_of_month between '01' AND '15' THEN
      IF last_day(p_semi_month_date+15) = last_day(p_semi_month_date) THEN
         return(p_semi_month_date + 15);
      ELSE
         -- for p_semi_month_date = Feb 14th, for example
         return(last_day(p_semi_month_date));
      END IF;
   ELSE  -- if on the 16th or later
      return(to_date((temp_day ||
             substr(to_char(add_months(p_semi_month_date,1),'DD-MM-YYYY'),3)
             ), 'DD-MM-YYYY'));
   END IF;
END IF;
--
END next_semi_month;
--
--------------------------- add_multiple_of_base ----------------------------
--
FUNCTION add_multiple_of_base (p_target_date      IN DATE,
                               p_base_period_type IN VARCHAR2,
                               p_multiple         IN NUMBER,
                               p_fpe_date         IN DATE)
                               return DATE IS
--
rest_of_date VARCHAR2(9);
temp_date    DATE;
--
l_proc       VARCHAR2(100) := 'hr_generic_util.ADD_MULTIPLE_OF_BASE';
--
BEGIN
--
-- Errors can occur when performing date manipulation.
--
IF p_base_period_type = WEEKLY THEN
   --
   -- hr_utility.set_location(l_proc, 10);
   --
   return (p_target_date + (7 * p_multiple));
   --
ELSIF p_base_period_type = MONTHLY THEN
   --
   -- hr_utility.set_location(l_proc, 20);
   --
   return (add_months(p_target_date, p_multiple));
   --
ELSE
   -- This is semi-monthly. A pair of semi-months always spand
   -- a whole calendar month. Their start and end dates are either
   -- 1st - 15th or 16th - last day of month. This makes the
   -- addition/subtraction of a period reasonably straightforward,
   -- if a little involved.
   -- IF p_multiple > 0 THEN
      -- Addition of one semi-month.
   --
   return(next_semi_month(p_target_date, p_fpe_date));
   --
   -- ELSE
      -- Substraction of one semi-month.
   -- return(prev_semi_month(p_target_date, p_fpe_date));
   -- END IF;
   --
END IF;
--
END add_multiple_of_base;
--
------------------------- get_period_dates --------------------------------
--
PROCEDURE get_period_dates
            (p_rec_period_start_date IN  DATE
            ,p_period_type           IN  VARCHAR2
            ,p_current_date          IN  DATE
            ,p_period_start_date     OUT NOCOPY DATE
            ,p_period_end_date       OUT NOCOPY DATE) IS
--
l_base_period_type                VARCHAR2(1);
l_multiple                        NUMBER;
l_period_start_date               DATE;
l_period_end_date                 DATE;
--
l_proc      VARCHAR2(100):= 'hr_generic_util.GET_PERIOD_DATES';
--
--
BEGIN
--

hxc_period_evaluation.period_start_stop(p_current_date          => p_current_date,
                                        p_rec_period_start_date => p_rec_period_start_date,
                                        l_period_start          => p_period_start_date,
                                        l_period_end            => p_period_end_date,
                                        l_base_period_type      => p_period_type);


return;

hr_utility.set_location(l_proc, 10);
--
IF p_rec_period_start_date > p_current_date THEN
   hr_utility.set_message(809, 'HXC_APR_REC_DATE_LATER');
   hr_utility.raise_error;
END IF;
--
get_period_details(p_period_type,
                   l_base_period_type,
                   l_multiple);
--
hr_utility.set_location(l_proc, 20);
--
l_period_start_date := p_rec_period_start_date;
l_period_end_date := add_multiple_of_base(l_period_start_date - 1,
                                          l_base_period_type,
                                          l_multiple,
                                          l_period_start_date - 1);
--


LOOP
   --
   EXIT when p_current_date BETWEEN l_period_start_date AND
                                    l_period_end_date;
   --
   l_period_start_date := l_period_end_date + 1;
   l_period_end_date := add_multiple_of_base(l_period_start_date - 1,
                                             l_base_period_type,
                                             l_multiple,
                                             l_period_start_date - 1);
END LOOP;

--
hr_utility.set_location(l_proc, 70);
--
p_period_start_date := l_period_start_date;
p_period_end_date := l_period_end_date;
--
hr_utility.set_location(l_proc, 110);
--
END get_period_dates;
--
END hr_generic_util;

/
