--------------------------------------------------------
--  DDL for Package Body PYZAEXC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PYZAEXC" as
/* $Header: pyzaexc.pkb 120.4.12010000.2 2009/06/23 11:41:40 rbabla ship $ */
---------------------------------------------------------------------------------------
--   Global variables
---------------------------------------------------------------------------------------

-- Cache result of tax year expiry check
   g_za_ty_owner_pay_action_id number;   -- run created balance.
   g_za_ty_user_pay_action_id  number;   -- current run.
   g_za_ty_expiry_information  number;   -- dimension expired flag.
-- Cache result of calendar year expiry check
   g_za_cy_owner_pay_action_id number;   -- run created balance.
   g_za_cy_user_pay_action_id  number;   -- current run.
   g_za_cy_expiry_information  number;   -- dimension expired flag.
-- Cache result of tax quarter expiry check
   g_za_tq_owner_pay_action_id number;   -- run created balance.
   g_za_tq_user_pay_action_id  number;   -- current run.
   g_za_tq_expiry_information  number;   -- dimension expired flag.
-- Cache result of month expiry check
   g_za_m_owner_pay_action_id number;   -- run created balance.
   g_za_m_user_pay_action_id  number;   -- current run.
   g_za_m_expiry_information  number;   -- dimension expired flag.

--------------------------------- ASG_TAX_YTD_EC --------------------------------------
--   NAME
--      ASG_TAX_YTD_EC - Assignment Tax Year to Date expiry check.
--   DESCRIPTION
--      Expiry checking code for the following:
--         ZA Assignment-level Tax Year to Date Balance Dimension
--   NOTES
--      The associated dimension is expiry checked at payroll action level
--      1 means expired
---------------------------------------------------------------------------------------
procedure ASG_TAX_YTD_EC
   (
      p_owner_payroll_action_id    in     number,    -- run created balance.
      p_user_payroll_action_id     in     number,    -- current run.
      p_owner_assignment_action_id in     number,    -- assact created balance.
      p_user_assignment_action_id  in     number,    -- current assact..
      p_owner_effective_date       in     date,      -- eff date of balance.
      p_user_effective_date        in     date,      -- eff date of current run.
      p_dimension_name             in     varchar2,  -- balance dimension name.
      p_expiry_information            out nocopy number     -- dimension expired flag.
   )
   is

   l_owner_date_earned    date;
   l_user_date_earned     date;
   l_owner_payroll_id     number;
   l_user_payroll_id      number;
   l_owner_tax_year       number;
   l_user_tax_year        number;
   l_expiry_date          date;

begin

   -- If the payroll actions have not changed, return the stored result
   if (p_owner_payroll_action_id = g_za_ty_owner_pay_action_id) and
      (p_user_payroll_action_id = g_za_ty_user_pay_action_id) then

      p_expiry_information := g_za_ty_expiry_information;

   else   -- Check expiry
      /*
      -- Get the owner's date earned and payroll id
      select
         date_earned, payroll_id
      into
         l_owner_date_earned, l_owner_payroll_id
      from
         pay_payroll_actions
      where
         payroll_action_id = p_owner_payroll_action_id;

      -- Get the user's date earned and payroll id
      select
         date_earned, payroll_id
      into
         l_user_date_earned, l_user_payroll_id
      from
         pay_payroll_actions
      where
         payroll_action_id = p_user_payroll_action_id;

      -- Get the owner's tax year
      select
         prd_information1
      into
         l_owner_tax_year
      from
         per_time_periods
      where
         payroll_id = l_owner_payroll_id
      and
         l_owner_date_earned between start_date and end_date;

      -- Get the user's tax year
      select
         prd_information1
      into
         l_user_tax_year
      from
         per_time_periods
      where
         payroll_id = l_user_payroll_id
      and
         l_user_date_earned between start_date and end_date;

      -- If the tax years are the same then the dimension has not expired
      if l_owner_tax_year = l_user_tax_year then
       */
       --added for 5486039
        ASG_TAX_YTD_EC(p_owner_payroll_action_id    =>  p_owner_payroll_action_id
                      , p_user_payroll_action_id     =>  p_user_payroll_action_id
                      , p_owner_assignment_action_id =>  p_owner_assignment_action_id
                      , p_user_assignment_action_id  =>  p_user_assignment_action_id
                      , p_owner_effective_date       =>  p_owner_effective_date
                      , p_user_effective_date        =>  p_user_effective_date
                      , p_dimension_name             =>  p_dimension_name
                      , p_expiry_information         =>  l_expiry_date
                       );

         -- Dimension has not expired
         -- bug 5629444 . When p_user_effective_date = l_expiry_date the dimension
         -- is not expired.
      IF p_user_effective_date <= l_expiry_date THEN
         p_expiry_information := 0;
         g_za_ty_expiry_information := 0;
      else
         -- Dimension has expired
         p_expiry_information := 1;
         g_za_ty_expiry_information := 1;

      end if;

      g_za_ty_owner_pay_action_id := p_owner_payroll_action_id;
      g_za_ty_user_pay_action_id  := p_user_payroll_action_id;

   end if;   -- End check expiry

end ASG_TAX_YTD_EC;
--
--5189195
procedure ASG_TAX_YTD_EC
   (
      p_owner_payroll_action_id    in     number,    -- run created balance.
      p_user_payroll_action_id     in     number,    -- current run.
      p_owner_assignment_action_id in     number,    -- assact created balance.
      p_user_assignment_action_id  in     number,    -- current assact..
      p_owner_effective_date       in     date,      -- eff date of balance.
      p_user_effective_date        in     date,      -- eff date of current run.
      p_dimension_name             in     varchar2,  -- balance dimension name.
      p_expiry_information         out nocopy date   -- dimension expired flag.
   )
   is
    l_tax_start_day       varchar2(50);
    l_tax_year            varchar2(50);
    l_tax_year_start_date date;
--
BEGIN
--hr_utility.trace_on(null,'ZAEXC');
hr_utility.set_location('p_owner_payroll_action_id: '||to_char(p_owner_payroll_action_id),10);
hr_utility.set_location('p_user_payroll_action_id: '||to_char(p_user_payroll_action_id),10);
hr_utility.set_location('p_owner_assignment_action_id: '||to_char(p_owner_assignment_action_id),10);
hr_utility.set_location('p_user_assignment_action_id: '||to_char(p_user_assignment_action_id),10);
hr_utility.set_location('p_owner_effective_date: '||to_char(p_owner_effective_date),10);
hr_utility.set_location('p_user_effective_date: '||to_char(p_user_effective_date),10);
hr_utility.set_location('p_dimension_name: '||to_char(p_dimension_name),10);

 select rule_mode
 into l_tax_start_day
 from pay_legislation_rules
 where legislation_code = 'ZA'
 and rule_type = 'L';

hr_utility.set_location('l_tax_start_day: '||to_char(l_tax_start_day),10);
--
select to_char(p_owner_effective_date,'YYYY')
into l_tax_year
from dual;
hr_utility.set_location('l_tax_year: '||to_char(l_tax_year),20);

--
SELECT to_date(l_tax_start_day||'-'||l_tax_year,'DD/MM/YYYY')
INTO l_tax_year_start_date
FROM dual;
hr_utility.set_location('l_tax_year_start_date: '||to_char(l_tax_year_start_date),30);
--
SELECT (add_months(l_tax_year_start_date,
        (floor(months_between(p_owner_effective_date, l_tax_year_start_date) / 12) + 1) * 12) -1)
INTO p_expiry_information
from dual;

hr_utility.set_location('p_expiry_information: '||to_char(p_expiry_information),40);
--hr_utility.trace_off;
--
end ASG_TAX_YTD_EC;
--------------------------------- ASG_CAL_YTD_EC --------------------------------------
--   NAME
--      ASG_CAL_YTD_EC - Assignment Calendar Year to Date expiry check.
--   DESCRIPTION
--      Expiry checking code for the following:
--         ZA Assignment-level Calendar Year to Date Balance Dimension
--   NOTES
--      The associated dimension is expiry checked at payroll action level
--      1 means expired
---------------------------------------------------------------------------------------
procedure ASG_CAL_YTD_EC
   (
      p_owner_payroll_action_id    in     number,    -- run created balance.
      p_user_payroll_action_id     in     number,    -- current run.
      p_owner_assignment_action_id in     number,    -- assact created balance.
      p_user_assignment_action_id  in     number,    -- current assact..
      p_owner_effective_date       in     date,      -- eff date of balance.
      p_user_effective_date        in     date,      -- eff date of current run.
      p_dimension_name             in     varchar2,  -- balance dimension name.
      p_expiry_information            out nocopy number     -- dimension expired flag.
   )
   is

   l_owner_date_earned    date;
   l_user_date_earned     date;
   l_owner_payroll_id     number;
   l_user_payroll_id      number;
   l_owner_cal_year       number;
   l_user_cal_year        number;
   l_expiry_date          date;
begin

   -- If the payroll actions have not changed, return the stored result
   if (p_owner_payroll_action_id = g_za_cy_owner_pay_action_id) and
      (p_user_payroll_action_id = g_za_cy_user_pay_action_id) then

      p_expiry_information := g_za_cy_expiry_information;

   else   -- Check expiry
  /*
      -- Get the owner's date earned and payroll id
      select
         date_earned, payroll_id
      into
         l_owner_date_earned, l_owner_payroll_id
      from
         pay_payroll_actions
      where
         payroll_action_id = p_owner_payroll_action_id;

      -- Get the user's date earned and payroll id
      select
         date_earned, payroll_id
      into
         l_user_date_earned, l_user_payroll_id
      from
         pay_payroll_actions
      where
         payroll_action_id = p_user_payroll_action_id;

      -- Get the owner's calendar year
      select
         prd_information3
      into
         l_owner_cal_year
      from
         per_time_periods
      where
         payroll_id = l_owner_payroll_id
      and
         l_owner_date_earned between start_date and end_date;

      -- Get the user's calendar year
      select
         prd_information3
      into
         l_user_cal_year
      from
         per_time_periods
      where
         payroll_id = l_user_payroll_id
      and
         l_user_date_earned between start_date and end_date;

      -- If the calendar years are the same then the dimension has not expired
      if l_owner_cal_year = l_user_cal_year then
*/
       --added for 5486039

        ASG_CAL_YTD_EC(p_owner_payroll_action_id    =>  p_owner_payroll_action_id
                      ,p_user_payroll_action_id     =>  p_user_payroll_action_id
                      ,p_owner_assignment_action_id =>  p_owner_assignment_action_id
                      ,p_user_assignment_action_id  =>  p_user_assignment_action_id
                      ,p_owner_effective_date       =>  p_owner_effective_date
                      ,p_user_effective_date        =>  p_user_effective_date
                      ,p_dimension_name             =>  p_dimension_name
                      ,p_expiry_information         =>  l_expiry_date
                       );

      IF p_user_effective_date <= l_expiry_date THEN
         -- Dimension has not expired
         p_expiry_information := 0;
         g_za_cy_expiry_information := 0;
      else
         -- Dimension has expired
         p_expiry_information := 1;
         g_za_cy_expiry_information := 1;

      end if;

      g_za_cy_owner_pay_action_id := p_owner_payroll_action_id;
      g_za_cy_user_pay_action_id  := p_user_payroll_action_id;

   end if;   -- End check expiry

end ASG_CAL_YTD_EC;

-- 5189195
procedure ASG_CAL_YTD_EC
   (
      p_owner_payroll_action_id    in     number,    -- run created balance.
      p_user_payroll_action_id     in     number,    -- current run.
      p_owner_assignment_action_id in     number,    -- assact created balance.
      p_user_assignment_action_id  in     number,    -- current assact..
      p_owner_effective_date       in     date,      -- eff date of balance.
      p_user_effective_date        in     date,      -- eff date of current run.
      p_dimension_name             in     varchar2,  -- balance dimension name.
      p_expiry_information            out nocopy date     -- dimension expired flag.
   )
   is
begin
/* Commented for Bug 8624178
SELECT (trunc(add_months(p_owner_effective_date,12),'Y')-1)
INTO p_expiry_information
from dual;      */

    SELECT max(ptpp.pay_advice_date)
    INTO   p_expiry_information
    FROM   pay_payroll_actions ppa
	  ,per_time_periods    ptp
	  ,per_time_periods    ptpp
    WHERE  ppa.payroll_action_id = p_owner_payroll_action_id
     AND  ppa.payroll_id        = ptp.payroll_id
     and  ptp.payroll_id        = ptpp.payroll_id
     AND  p_owner_effective_date BETWEEN ptp.start_date AND ptp.end_date
     and  ptpp.PRD_INFORMATION3 = ptp.PRD_INFORMATION3;
END ASG_CAL_YTD_EC;
--
--------------------------------- ASG_TAX_QTD_EC --------------------------------------
--   NAME
--      ASG_TAX_QTD_EC - Assignment Tax Quarter to Date expiry check.
--   DESCRIPTION
--      Expiry checking code for the following:
--         ZA Assignment-level Quarter Year to Date Balance Dimension
--   NOTES
--      The associated dimension is expiry checked at payroll action level
--      1 means expired
---------------------------------------------------------------------------------------
procedure ASG_TAX_QTD_EC
   (
      p_owner_payroll_action_id    in     number,    -- run created balance.
      p_user_payroll_action_id     in     number,    -- current run.
      p_owner_assignment_action_id in     number,    -- assact created balance.
      p_user_assignment_action_id  in     number,    -- current assact..
      p_owner_effective_date       in     date,      -- eff date of balance.
      p_user_effective_date        in     date,      -- eff date of current run.
      p_dimension_name             in     varchar2,  -- balance dimension name.
      p_expiry_information            out nocopy number     -- dimension expired flag.
   )
   is

   l_owner_date_earned    date;
   l_user_date_earned     date;
   l_owner_payroll_id     number;
   l_user_payroll_id      number;
   l_owner_tax_quarter    number;
   l_user_tax_quarter     number;
   l_owner_tax_year       number;
   l_user_tax_year        number;
   l_expiry_date          date;
begin

   -- If the payroll actions have not changed, return the stored result
   if (p_owner_payroll_action_id = g_za_tq_owner_pay_action_id) and
      (p_user_payroll_action_id = g_za_tq_user_pay_action_id) then

      p_expiry_information := g_za_tq_expiry_information;

   else   -- Check expiry
        /*
      -- Get the owner's date earned and payroll id
      select
         date_earned, payroll_id
      into
         l_owner_date_earned, l_owner_payroll_id
      from
         pay_payroll_actions
      where
         payroll_action_id = p_owner_payroll_action_id;

      -- Get the user's date earned and payroll id
      select
         date_earned, payroll_id
      into
         l_user_date_earned, l_user_payroll_id
      from
         pay_payroll_actions
      where
         payroll_action_id = p_user_payroll_action_id;

      -- Get the owner's tax quarter and tax year
      select
         prd_information1, prd_information2
      into
         l_owner_tax_year, l_owner_tax_quarter
      from
         per_time_periods
      where
         payroll_id = l_owner_payroll_id
      and
         l_owner_date_earned between start_date and end_date;

      -- Get the user's tax quarter and tax year
      select
         prd_information1, prd_information2
      into
         l_user_tax_year, l_user_tax_quarter
      from
         per_time_periods
      where
         payroll_id = l_user_payroll_id
      and
         l_user_date_earned between start_date and end_date;

      -- If the tax quarters and years are the same then the dimension has not expired
      if (l_owner_tax_year = l_user_tax_year) and
         (l_owner_tax_quarter = l_user_tax_quarter) then
        */
               --added for 5486039

        ASG_TAX_QTD_EC(p_owner_payroll_action_id    =>  p_owner_payroll_action_id
                      ,p_user_payroll_action_id     =>  p_user_payroll_action_id
                      ,p_owner_assignment_action_id =>  p_owner_assignment_action_id
                      ,p_user_assignment_action_id  =>  p_user_assignment_action_id
                      ,p_owner_effective_date       =>  p_owner_effective_date
                      ,p_user_effective_date        =>  p_user_effective_date
                      ,p_dimension_name             =>  p_dimension_name
                      ,p_expiry_information         =>  l_expiry_date
                       );

      IF p_user_effective_date <= l_expiry_date THEN
         -- Dimension has not expired
         p_expiry_information := 0;
         g_za_tq_expiry_information := 0;

      else

         -- Dimension has expired
         p_expiry_information := 1;
         g_za_tq_expiry_information := 1;

      end if;

      g_za_tq_owner_pay_action_id := p_owner_payroll_action_id;
      g_za_tq_user_pay_action_id  := p_user_payroll_action_id;

   end if;   -- End check expiry

end ASG_TAX_QTD_EC;
--
-- 5189195
--
PROCEDURE ASG_TAX_QTD_EC
   (
      p_owner_payroll_action_id    in     number,    -- run created balance.
      p_user_payroll_action_id     in     number,    -- current run.
      p_owner_assignment_action_id in     number,    -- assact created balance.
      p_user_assignment_action_id  in     number,    -- current assact..
      p_owner_effective_date       in     date,      -- eff date of balance.
      p_user_effective_date        in     date,      -- eff date of current run.
      p_dimension_name             in     varchar2,  -- balance dimension name.
      p_expiry_information            out nocopy date     -- dimension expired flag.
   )
   is
    l_tax_start_day       varchar2(50);
    l_tax_year            varchar2(50);
    l_tax_year_start_date date;
--
BEGIN
 select rule_mode
 into l_tax_start_day
 from pay_legislation_rules
 where legislation_code = 'ZA'
 and rule_type = 'L';
--
select to_char(p_owner_effective_date,'YYYY')
into l_tax_year
from dual;
--
SELECT to_date(l_tax_start_day||'-'||l_tax_year,'DD/MM/YYYY')
INTO l_tax_year_start_date
FROM dual;
--
SELECT (add_months(l_tax_year_start_date,
                (floor(months_between(p_owner_effective_date, l_tax_year_start_date) / 3) + 1) * 3) -1 )
INTO p_expiry_information
FROM dual;
--
end ASG_TAX_QTD_EC;
--
--------------------------------- ASG_MTD_EC --------------------------------------
--   NAME
--      ASG_MTD_EC - Assignment Month to Date expiry check.
--   DESCRIPTION
--      Expiry checking code for the following:
--         ZA Assignment-level Month to Date Balance Dimension
--   NOTES
--      The associated dimension is expiry checked at payroll action level
--      1 means expired
---------------------------------------------------------------------------------------
procedure ASG_MTD_EC
   (
      p_owner_payroll_action_id    in     number,    -- run created balance.
      p_user_payroll_action_id     in     number,    -- current run.
      p_owner_assignment_action_id in     number,    -- assact created balance.
      p_user_assignment_action_id  in     number,    -- current assact..
      p_owner_effective_date       in     date,      -- eff date of balance.
      p_user_effective_date        in     date,      -- eff date of current run.
      p_dimension_name             in     varchar2,  -- balance dimension name.
      p_expiry_information            out nocopy number     -- dimension expired flag.
   )
   is

   l_owner_date_earned    date;
   l_user_date_earned     date;
   l_owner_payroll_id     number;
   l_user_payroll_id      number;
   l_owner_month          date;
   l_user_month           date;
   l_expiry_date          date;
begin

   -- If the payroll actions have not changed, return the stored result
   if (p_owner_payroll_action_id = g_za_m_owner_pay_action_id) and
      (p_user_payroll_action_id = g_za_m_user_pay_action_id) then

      p_expiry_information := g_za_m_expiry_information;

   else   -- Check expiry
/*
      -- Get the owner's date earned and payroll id
      select
         date_earned, payroll_id
      into
         l_owner_date_earned, l_owner_payroll_id
      from
         pay_payroll_actions
      where
         payroll_action_id = p_owner_payroll_action_id;

      -- Get the user's date earned and payroll id
      select
         date_earned, payroll_id
      into
         l_user_date_earned, l_user_payroll_id
      from
         pay_payroll_actions
      where
         payroll_action_id = p_user_payroll_action_id;

      -- Get the owner's month end
      select
         pay_advice_date
      into
         l_owner_month
      from
         per_time_periods
      where
         payroll_id = l_owner_payroll_id
      and
         l_owner_date_earned between start_date and end_date;

      -- Get the user's month end
      select
         pay_advice_date
      into
         l_user_month
      from
         per_time_periods
      where
         payroll_id = l_user_payroll_id
      and
         l_user_date_earned between start_date and end_date;

      -- If the month ends are the same then the dimension has not expired
      if l_owner_month = l_user_month then
*/
       --added for 5486039

            ASG_MTD_EC(p_owner_payroll_action_id    =>  p_owner_payroll_action_id
                      ,p_user_payroll_action_id     =>  p_user_payroll_action_id
                      ,p_owner_assignment_action_id =>  p_owner_assignment_action_id
                      ,p_user_assignment_action_id  =>  p_user_assignment_action_id
                      ,p_owner_effective_date       =>  p_owner_effective_date
                      ,p_user_effective_date        =>  p_user_effective_date
                      ,p_dimension_name             =>  p_dimension_name
                      ,p_expiry_information         =>  l_expiry_date
                       );

      IF p_user_effective_date <= l_expiry_date THEN
         -- Dimension has not expired
         p_expiry_information := 0;
         g_za_m_expiry_information := 0;

      else

         -- Dimension has expired
         p_expiry_information := 1;
         g_za_m_expiry_information := 1;

      end if;

      g_za_m_owner_pay_action_id := p_owner_payroll_action_id;
      g_za_m_user_pay_action_id  := p_user_payroll_action_id;

   end if;   -- End check expiry

end ASG_MTD_EC;
--
-- 5189195
procedure ASG_MTD_EC
  (
  p_owner_payroll_action_id    in     number,   -- run created balance.
  p_user_payroll_action_id     in     number,   -- current run.
  p_owner_assignment_action_id in     number,   -- assact created balance.
  p_user_assignment_action_id  in     number,   -- current assact.
  p_owner_effective_date       in     date,     -- eff date of balance.
  p_user_effective_date        in     date,     -- eff date of current run.
  p_dimension_name             in     varchar2, -- balance dimension name.
  p_expiry_information         out NOCOPY  date)   -- dimension expired date.
is
begin
  --
  /* Commented for Bug 8624178
  SELECT ((trunc(add_months(p_owner_effective_date,1),'MM'))-1)
  INTO  p_expiry_information
  FROM dual;
  */

   SELECT ptp.pay_advice_date
   INTO   p_expiry_information
   FROM   per_time_periods    ptp
         ,pay_payroll_actions ppa
   WHERE  ppa.payroll_action_id = p_owner_payroll_action_id
     AND  ppa.payroll_id        = ptp.payroll_id
     AND  p_owner_effective_date BETWEEN ptp.start_date AND ptp.end_date;

  --
end ASG_MTD_EC;
--
--------------------------------- ASG_PTD_EC --------------------------------------
--   NAME
--      ASG_PTD_EC - Assignment Period to Date expiry check.
--   DESCRIPTION
--      Expiry checking code for the following:
--         ZA Assignment-level Period to Date Balance Dimension
--   NOTES
--      The associated dimension is expiry checked at payroll action level
--      1 means expired
---------------------------------------------------------------------------------------
procedure ASG_PTD_EC
   (
      p_owner_payroll_action_id    in     number,    -- run created balance.
      p_user_payroll_action_id     in     number,    -- current run.
      p_owner_assignment_action_id in     number,    -- assact created balance.
      p_user_assignment_action_id  in     number,    -- current assact..
      p_owner_effective_date       in     date,      -- eff date of balance.
      p_user_effective_date        in     date,      -- eff date of current run.
      p_dimension_name             in     varchar2,  -- balance dimension name.
      p_expiry_information            out nocopy number     -- dimension expired flag.
   )
   is

   l_owner_time_period_id number;
   l_user_time_period_id  number;
   l_expiry_date          date;

begin

   -- Select the period of the owning and using action and if they are the same then
   -- the dimension has expired - either a prior period or a different payroll
/*
   -- Get the owner's time_period_id
   select
      time_period_id
   into
      l_owner_time_period_id
   from
      pay_payroll_actions
   where
      payroll_action_id = p_owner_payroll_action_id;

   -- Get the user's time_period_id
   select
      time_period_id
   into
      l_user_time_period_id
   from
      pay_payroll_actions
   where
      payroll_action_id = p_user_payroll_action_id;


   -- If the time periods are the same then the dimension has not expired
   if l_owner_time_period_id = l_user_time_period_id then
*/
       --added for 5486039

            ASG_PTD_EC(p_owner_payroll_action_id    =>  p_owner_payroll_action_id
                      ,p_user_payroll_action_id     =>  p_user_payroll_action_id
                      ,p_owner_assignment_action_id =>  p_owner_assignment_action_id
                      ,p_user_assignment_action_id  =>  p_user_assignment_action_id
                      ,p_owner_effective_date       =>  p_owner_effective_date
                      ,p_user_effective_date        =>  p_user_effective_date
                      ,p_dimension_name             =>  p_dimension_name
                      ,p_expiry_information         =>  l_expiry_date
                       );

      IF p_user_effective_date <= l_expiry_date THEN
      -- Dimension has not expired
      p_expiry_information := 0;
   else
      -- Dimension has expired
      p_expiry_information := 1;

   end if;

end ASG_PTD_EC;
--
-- 5189195
--
procedure ASG_PTD_EC
(
   p_owner_payroll_action_id    in     number,         -- run created balance.
   p_user_payroll_action_id     in     number,         -- current run.
   p_owner_assignment_action_id in     number,         -- assact created balance.
   p_user_assignment_action_id  in     number,         -- current assact..
   p_owner_effective_date       in     date,           -- eff date of balance.
   p_user_effective_date        in     date,           -- eff date of current run.
   p_dimension_name             in     varchar2,       -- balance dimension name.
   p_expiry_information         out nocopy    DATE     -- dimension expired flag.
)  IS
BEGIN
   SELECT ptp.end_date
   INTO   p_expiry_information
   FROM   per_time_periods    ptp
         ,pay_payroll_actions ppa
   WHERE  ppa.payroll_action_id = p_owner_payroll_action_id
     AND  ppa.payroll_id        = ptp.payroll_id
     AND  p_owner_effective_date BETWEEN ptp.start_date AND ptp.end_date;
 END ASG_PTD_EC;
--
end pyzaexc;

/
