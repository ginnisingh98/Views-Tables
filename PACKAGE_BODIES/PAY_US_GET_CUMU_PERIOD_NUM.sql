--------------------------------------------------------
--  DDL for Package Body PAY_US_GET_CUMU_PERIOD_NUM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_GET_CUMU_PERIOD_NUM" AS
/* $Header: pyuscfun.pkb 120.0 2005/05/29 09:18:44 appldev noship $ */


/*************************************************************************

FUNCTION CUMU_PERIOD_NUM

This function first gets the heir date and payroll id for assignment_id
and date earned.It compares the heir date with the date earned if it is
in the same year then we need to get the period number as of the heir date
and as of the date earned and calculate the difference else we get the
first period number for the current year.

*************************************************************************/

FUNCTION cumulative_period_number(
                          p_pact_id       number,
                          p_date_earned   date,
                          p_assignment_id number)
RETURN NUMBER IS

l_hire_date             date;
l_payroll_id            number;
l_period_number         number;
l_hire_period_number    number;
l_earned_period_number  number;

l_date_earned      date;
l_start_date       date;
l_end_date         date;
l_date_paid        date;
l_period_type      per_time_periods.period_type%type;
l_days_since_hired number;
l_frequency        number;

BEGIN -- main
   begin --main 2
--	hr_utility.trace_on(null,'oracle');

	hr_utility.trace('The Assignment Id is: '|| p_assignment_id);
	hr_utility.trace('The Date Earned is: '|| p_date_earned);
	hr_utility.trace('The PACT_ID is: '|| p_pact_id);

-- get the period number, payroll id, period start date , period end date,
-- date paid and period type
     begin
          select  ptp.period_num, ppa.payroll_id, ptp.start_date,
                  ptp.end_date,ppa.effective_date date_paid, ptp.period_type
          into    l_period_number,l_payroll_id, l_start_date,
                  l_end_date,l_date_paid, l_period_type
          from    per_time_period_types pty,
                  per_time_periods      ptp,
                  pay_payroll_actions   ppa
          where   ppa.payroll_action_id = p_pact_id
          and     ptp.time_period_id    = ppa.time_period_id
          and     pty.period_type       = ptp.period_type;

          hr_utility.trace('The Period number is: '|| l_period_number);
          hr_utility.trace('The date paid is: '|| l_date_paid);

    exception when others then

          hr_utility.trace('In exception of start period number'||substr(SQLERRM,1,80));
--  returning 0 now, but will change later on to have a meaningful message here
            return(0);
    end;

-- get the minimum hire date
   begin
	select min(SERVICE.date_start)	into l_hire_date
	from    per_periods_of_service SERVICE,
       		per_all_assignments_f ASS
    where   ASS.assignment_id = p_assignment_id
    and     ASS.person_id = SERVICE.person_id
    and     SERVICE.date_start <= l_date_paid;
   exception when others then
        hr_utility.trace('In exception of hire date'||substr(SQLERRM,1,80));
--  returning 0 now, but will change later on to have a meaningful message here
            return(0);

   end;
--is hire date and date paid in the same year

if trunc(l_date_paid,'YYYY') = trunc(l_hire_date,'YYYY') then
   -- ie. the year of hire date and date paid is same
   --
   -- get the period number as of the hire date
    begin
           l_earned_period_number := l_period_number; /*Move the l_period_number found above*/


      -- following query can raise an exception if the payroll is not defined as of the hire date
  		select ptp.period_num into l_period_number
   		from   per_time_periods ptp
   		where  ptp.payroll_id = l_payroll_id
   		and    l_hire_date between ptp.start_date and ptp.end_date;

        /* Return the difference in the paid period number and the hired period number */
        l_period_number := l_earned_period_number;


     	hr_utility.trace('The Period number is: '|| l_period_number);
    exception when others then
        -- get the difference in number of day between hire date and date paid
        -- we use trunc to remove the decimal places
        --** need to confirm for the use of l_start_date or l_end_date
--        l_days_since_hired := trunc( l_start_date - l_hire_date );
-- think should use end date instead of start date to take into account the
-- current pay period.

        l_days_since_hired := trunc( l_end_date - l_hire_date );
       	hr_utility.trace('Days Since Hired: '|| l_days_since_hired);

        -- get the frequency of the payroll
        IF l_period_type = 'Semi-Month' THEN
           hr_utility.trace('Period type 1'||l_period_type);
           l_frequency := 15;

        ELSIF l_period_type = 'Calendar Month' THEN
              hr_utility.trace('Period type 2'||l_period_type);
              l_frequency := 30;
        ELSIF l_period_type = 'Bi-Month' THEN
              hr_utility.trace('Period type 3'||l_period_type);
              l_frequency := 60;

	 ELSE
              hr_utility.trace('Period type 4'||l_period_type);
              l_frequency := trunc(l_end_date - l_start_date) + 1;
        END IF;
            hr_utility.trace('Frequency : '||l_frequency);
            -- find the period number
            l_period_number := trunc(l_days_since_hired/l_frequency);
    end;
 end if;
hr_utility.trace_off;
return(l_period_number);
--

END cumulative_period_number; -- main2

exception when others then

	hr_utility.trace('final exception');
--  returning 0 now, but will change later on to have a meaningful message here
            return(0);
       -- null;
END;
END pay_us_get_cumu_period_num;


/
