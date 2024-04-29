--------------------------------------------------------
--  DDL for Package Body PAY_PAYACVEA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYACVEA_PKG" as
/* $Header: pyacvea.pkb 115.1 99/07/17 05:41:39 porting ship $ */
--
--
PROCEDURE get_dates(
                    p_element_entry_id IN  number,
                    p_payroll_id       IN  number,
                    p_session_date     IN  date,
                    p_person_id        IN  number,
                    p_start_date       OUT date,
                    p_end_date         OUT date
                   ) IS
--
   return_end_date date;
   l_end_date date;
   l_year varchar2(4);
--
BEGIN
--
-- This procedure gets the start and end dates for the period covered by
-- the accrual.
--
-- The start date is whichever is the later - the first period of the year,
-- or when the employee was enrolled onto the plan (ie when the accrual
-- element was given to the employee).
--
-- Since accruals are based on complete time periods we have a slight problem
-- in determining what year we are in - it is not enough to get the year from
-- the effective date, since the effective date may be halfway into the first
-- period of the year: for example, if we use monthly periods and the effective
-- date is '20-01-1994' then we should use 1993 as the accrual year, since
-- the effective date has not covered a whole accrual period for 1994.
-- If the effective date falls on the last day of the first period (in this
-- example '31-01-1994') then we have a whole accrual period and we can use
-- 1994 as the accrual year. Obviously, if the effective date is later than the
-- end date of the first period of the year then there's no problem.
--
-- The end date requires a little more work - this should be the earliest of the
-- following dates -
--
--   the effective date
--
--   (GET RID OF THIS ????)
--   the end date of the period in which the employee left the plan
--
--   the end date of the period in which the employee's period of service ended
--
--
-- find out what year we're dealing with...
--
   select to_char(ptp.start_date, 'YYYY')
   into   l_year
   from   per_time_periods ptp
   where  p_session_date between
             ptp.start_date and ptp.end_date
   and    ptp.payroll_id = p_payroll_id;
--
-- get the period start date
--
   hr_utility.set_location('pay_payacvea_pkg.get_dates', 1);
   select greatest(ptp1.start_date, ptp2.start_date)
   into   p_start_date
   from   per_time_periods ptp1,
          per_time_periods ptp2
   where  ptp1.start_date =
          (
             select min(ptp3.start_date)
             from   per_time_periods ptp3
             where  ptp3.start_date >=
                      (
                      select min(effective_start_date)
                      from   pay_element_entries_f pee
                      where  pee.element_entry_id = p_element_entry_id
                      )
             and   ptp3.payroll_id = ptp1.payroll_id
         )
   and   ptp1.payroll_id = p_payroll_id
   and   ptp2.start_date =
            (
            select min(ptp3.start_date)
            from   per_time_periods ptp3
            where  ptp3.start_date >=
                      to_date('01-01-'||l_year, 'DD-MM-YYYY')
            and    ptp3.payroll_id = ptp2.payroll_id
          )
   and    ptp2.payroll_id = p_payroll_id;
--
-- get the end date (ie the effective date)
--
   return_end_date := p_session_date;
--
/*
 *****
 ***** REMOVE ???
 *****
-- now get the end date of the period in which the element is no longer
-- effective; this may return no value
--
   hr_utility.set_location('pay_payacvea_pkg.get_dates', 3);
   begin
      select ptp1.end_date
      into   l_end_date
      from   per_time_periods ptp1
      where  ptp1.end_date =
             (
                select max(ptp2.end_date)
                from   per_time_periods ptp2
                where  ptp2.end_date <=
                         (
                         select max(effective_end_date)
                         from   pay_element_entries_f pee
                         where  pee.element_entry_id = p_element_entry_id
                         )
                and   ptp2.payroll_id = ptp1.payroll_id
            )
      and   ptp1.payroll_id = p_payroll_id;
      EXCEPTION
         when NO_DATA_FOUND then null;
   end;
   if l_end_date is not null then
      if l_end_date < return_end_date then
         return_end_date := l_end_date;
      end if;
   end if;
*/
--
-- ...and now the period in which the employee's period of service ends
--
   l_end_date := null;
   hr_utility.set_location('pay_payacvea_pkg.get_dates', 4);
   begin
      select ptp1.end_date
      into   l_end_date
      from   per_time_periods ptp1
      where  ptp1.end_date =
             (
                select max(ptp2.end_date)
                from   per_periods_of_service pos,
                       per_time_periods ptp2
                where  p_session_date between
                          pos.date_start and pos.actual_termination_date
                and    pos.person_id = p_person_id
                and    pos.actual_termination_date <= ptp2.end_date
                and    ptp2.payroll_id = ptp1.payroll_id
            )
      and   ptp1.payroll_id = p_payroll_id;
      EXCEPTION
         when NO_DATA_FOUND then null;
   end;
   if l_end_date is not null then
      if l_end_date < return_end_date then
         return_end_date := l_end_date;
      end if;
   end if;
--
   p_end_date := return_end_date;
--
--
--
END get_dates;
--
--
--
END PAY_PAYACVEA_PKG;

/
