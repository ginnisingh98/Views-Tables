--------------------------------------------------------
--  DDL for Package Body PEPTOEXC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PEPTOEXC" as
/* $Header: peptoexc.pkb 115.5 2004/04/19 08:46:17 irgonzal noship $ */

/*
 * The following are expiry checking procedures
 * for date paid balances used by pto accruals
 */

/*------------------------------ ASG_PTO_YTD_EC ----------------------------*/
/*
   NAME
      ASG_PTO_YTD_EC - Assignment Processing Year to Date expiry check.
   DESCRIPTION
   NOTES
      The associated dimension is expiry checked at payroll action level
*/
--
-- This is the flag-based expiry routine.
--
procedure ASG_PTO_YTD_EC
(
   p_owner_payroll_action_id    in         number,    -- run created balance.
   p_user_payroll_action_id     in         number,    -- current run.
   p_owner_assignment_action_id in         number,    -- assact created balance.
   p_user_assignment_action_id  in         number,    -- current assact.
   p_owner_effective_date       in         date,      -- eff date of balance.
   p_user_effective_date        in         date,      -- eff date of current run.
   p_dimension_name             in         varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy number     -- dimension expired flag.
) is

  l_expiry_date date;

begin

  l_expiry_date := trunc(add_months(p_owner_effective_date,12),'Y');

  IF p_user_effective_date >= l_expiry_date THEN
    p_expiry_information := 1;
  ELSE
    p_expiry_information := 0;
  END IF;

end ASG_PTO_YTD_EC;

--
-- This is the overloaded date-based expiry routine.
--
procedure ASG_PTO_YTD_EC
(
   p_owner_payroll_action_id    in         number,    -- run created balance.
   p_user_payroll_action_id     in         number,    -- current run.
   p_owner_assignment_action_id in         number,    -- assact created balance.
   p_user_assignment_action_id  in         number,    -- current assact.
   p_owner_effective_date       in         date,      -- eff date of balance.
   p_user_effective_date        in         date,      -- eff date of current run.
   p_dimension_name             in         varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy date       -- dimension expired date.
) is

  l_expiry_date date;

begin

  l_expiry_date := trunc(add_months(p_owner_effective_date,12),'Y');

  p_expiry_information := l_expiry_date;

end ASG_PTO_YTD_EC;
/*------------------------------ ASG_PTO_TTD_EC ----------------------------*/
/*
   NAME
      ASG_PTO_TTD_EC - Assignment Processing Term to Date expiry check.
   DESCRIPTION
   NOTES
      The associated dimension is expiry checked at payroll action level.
*/
--
-- This is the flag-based expiry routine.
--
procedure ASG_PTO_TTD_EC
(
   p_owner_payroll_action_id    in         number,   -- run created balance.
   p_user_payroll_action_id     in         number,   -- current run.
   p_owner_assignment_action_id in         number,   -- assact created balance.
   p_user_assignment_action_id  in         number,   -- current assact.
   p_owner_effective_date       in         date,     -- eff date of balance.
   p_user_effective_date        in         date,     -- eff date of current run.
   p_dimension_name             in         varchar2, -- balance dimension name.
   p_expiry_information         out nocopy number    -- dimension expired flag.
) is

  l_accrual_year_end date;

begin


  l_accrual_year_end := to_date('31-05-'||to_char(p_owner_effective_date, 'YYYY'), 'DD-MM-YYYY');

  if l_accrual_year_end < p_owner_effective_date then
  --
    l_accrual_year_end := add_months(l_accrual_year_end, 12);
  --
  end if;

  --
  -- Bug 2696406.
  -- Changed < to > so that the balance expires when it should.
  --
  if p_user_effective_date > l_accrual_year_end then
    p_expiry_information := 1;
  else
    p_expiry_information := 0;
  end if;

end ASG_PTO_TTD_EC;

--
-- This is the overloaded date-based expiry routine.
--
procedure ASG_PTO_TTD_EC
(
   p_owner_payroll_action_id    in         number,    -- run created balance.
   p_user_payroll_action_id     in         number,    -- current run.
   p_owner_assignment_action_id in         number,    -- assact created balance.
   p_user_assignment_action_id  in         number,    -- current assact.
   p_owner_effective_date       in         date,      -- eff date of balance.
   p_user_effective_date        in         date,      -- eff date of current run.
   p_dimension_name             in         varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy date       -- dimension expired date.
) is

  l_accrual_year_end date;

begin


  l_accrual_year_end := to_date('31-05-'||to_char(p_owner_effective_date, 'YYYY'), 'DD-MM-YYYY');

  if l_accrual_year_end < p_owner_effective_date then
  --
    l_accrual_year_end := add_months(l_accrual_year_end, 12);
  --
  end if;

  p_expiry_information := l_accrual_year_end;

end ASG_PTO_TTD_EC;

/*-------------------------- ASG_PTO_HD_YTD_EC ----------------------------*/
/*
   NAME
      ASG_PTO_HD_YTD_EC - Assignment Processing Year to Date expiry check.
   DESCRIPTION
   NOTES
      The associated dimension is expiry checked at payroll action level
*/
--
-- This is the flag-based expiry routine.
--
procedure ASG_PTO_HD_YTD_EC
(
   p_owner_payroll_action_id    in         number,    -- run created balance.
   p_user_payroll_action_id     in         number,    -- current run.
   p_owner_assignment_action_id in         number,    -- assact created balance.
   p_user_assignment_action_id  in         number,    -- current assact.
   p_owner_effective_date       in         date,      -- eff date of balance.
   p_user_effective_date        in         date,      -- eff date of current run.
   p_dimension_name             in         varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy number     -- dimension expired flag.
) is

  l_accrual_year_end    date;

begin

  select add_months(pps.date_start,
                    12 + trunc(months_between(bact.effective_date,
                                              pps.date_start
                                              )/12) *12) finyear
  into l_accrual_year_end
  from per_periods_of_service pps,
       per_all_assignments_f asg,
       pay_payroll_actions bact,
       pay_assignment_actions bal_assact
  where bact.payroll_action_id = p_owner_payroll_action_id
  and   bal_assact.payroll_action_id = bact.payroll_action_id
  and   pps.period_of_service_id = asg.period_of_service_id
  and   asg.assignment_id = bal_assact.assignment_id
  and   bal_assact.assignment_action_id = p_owner_assignment_action_id
  and   bact.effective_date between asg.effective_start_date
                                and asg.effective_end_date;

--
--

  if p_user_effective_date >= l_accrual_year_end then
    p_expiry_information := 1;
  else
    p_expiry_information := 0;
  end if;
--
end ASG_PTO_HD_YTD_EC;

--
-- This is the overloaded date-based expiry routine.
--
procedure ASG_PTO_HD_YTD_EC
(
   p_owner_payroll_action_id    in         number,    -- run created balance.
   p_user_payroll_action_id     in         number,    -- current run.
   p_owner_assignment_action_id in         number,    -- assact created balance.
   p_user_assignment_action_id  in         number,    -- current assact.
   p_owner_effective_date       in         date,      -- eff date of balance.
   p_user_effective_date        in         date,      -- eff date of current run.
   p_dimension_name             in         varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy date       -- dimension expired date.
) is

  l_accrual_year_end    date;

begin

  select add_months(pps.date_start,
                    12 + trunc(months_between(bact.effective_date,
                                              pps.date_start
                                              )/12) *12) finyear
  into l_accrual_year_end
  from per_periods_of_service pps,
       per_all_assignments_f asg,
       pay_payroll_actions bact,
       pay_assignment_actions bal_assact
  where bact.payroll_action_id = p_owner_payroll_action_id
  and   bal_assact.payroll_action_id = bact.payroll_action_id
  and   pps.period_of_service_id = asg.period_of_service_id
  and   asg.assignment_id = bal_assact.assignment_id
  and   bal_assact.assignment_action_id = p_owner_assignment_action_id
  and   bact.effective_date between asg.effective_start_date
                                and asg.effective_end_date;

--
--

  p_expiry_information := l_accrual_year_end;

end ASG_PTO_HD_YTD_EC;

/*
 * The following are expiry checking procedures
 * for date earned balances used by pto accruals
 */

/*------------------------------ ASG_PTO_DE_YTD_EC ----------------------------*/
/*
   NAME
      ASG_PTO_DE_YTD_EC - Assignment Processing Year to Date expiry check.
   DESCRIPTION
      Used to check expiry of seeded date earned balance in
      PTO accruals, for a one year plan beginning 01/01.
*/
--
-- This is the flag-based expiry routine.
--
procedure ASG_PTO_DE_YTD_EC
(
   p_owner_payroll_action_id    in         number,    -- run created balance.
   p_user_payroll_action_id     in         number,    -- current run.
   p_owner_assignment_action_id in         number,    -- assact created balance.
   p_user_assignment_action_id  in         number,    -- current assact.
   p_owner_effective_date       in         date,      -- eff date of balance.
   p_user_effective_date        in         date,      -- eff date of current run.
   p_dimension_name             in         varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy number     -- dimension expired flag.
) is

  cursor c_date_earned(p_payroll_action_id number) is
  select date_earned
  from pay_payroll_actions
  where payroll_action_id = p_payroll_action_id;

  l_expiry_date date;
  l_curr_expiry_date date;
  l_owner_date_earned   date;
  l_user_date_earned    date;

begin

  open c_date_earned(p_owner_payroll_action_id);
  fetch c_date_earned into l_owner_date_earned;
  close c_date_earned;

  open c_date_earned(p_user_payroll_action_id);
  fetch c_date_earned into l_user_date_earned;
  close c_date_earned;

  l_expiry_date := trunc(add_months(l_owner_date_earned,12),'Y');
  l_curr_expiry_date := trunc(l_owner_date_earned, 'Y');

  IF l_user_date_earned >= l_expiry_date THEN
    p_expiry_information := 1;
  ELSE
    -- Date is in a previous period
    if l_user_date_earned < l_curr_expiry_date then
      p_expiry_information := 2;
    else
      -- Date is in current period but prior to lat bal run.
      if l_user_date_earned < l_owner_date_earned then
        p_expiry_information := 3;
      else
        -- No it hasn't expired.
        p_expiry_information := 0;
      end if;
    end if;
  --
  END IF;

end ASG_PTO_DE_YTD_EC;

--
-- This is the overloaded date-based expiry routine.
--
procedure ASG_PTO_DE_YTD_EC
(
   p_owner_payroll_action_id    in         number,    -- run created balance.
   p_user_payroll_action_id     in         number,    -- current run.
   p_owner_assignment_action_id in         number,    -- assact created balance.
   p_user_assignment_action_id  in         number,    -- current assact.
   p_owner_effective_date       in         date,      -- eff date of balance.
   p_user_effective_date        in         date,      -- eff date of current run.
   p_dimension_name             in         varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy date       -- dimension expired date.
) is

  cursor c_date_earned(p_payroll_action_id number) is
  select date_earned
  from pay_payroll_actions
  where payroll_action_id = p_payroll_action_id;

  l_expiry_date date;
  l_owner_date_earned   date;

begin

  open c_date_earned(p_owner_payroll_action_id);
  fetch c_date_earned into l_owner_date_earned;
  close c_date_earned;

  l_expiry_date := trunc(add_months(l_owner_date_earned,12),'Y');

  p_expiry_information := l_expiry_date;

end ASG_PTO_DE_YTD_EC;

/*------------------------------ ASG_PTO_DE_SM_YTD_EC ----------------------------*/
/*
   NAME
      ASG_PTO_DE_SM_YTD_EC - Assignment Processing Year to Date expiry check.
   DESCRIPTION
      Used to check expiry of seeded date earned balance in PTO accruals, for our
      simple multiplier plan, beginning 01/06 each year.
*/
--
-- This is the flag-based expiry routine.
--
procedure ASG_PTO_DE_SM_YTD_EC
(
   p_owner_payroll_action_id    in         number,    -- run created balance.
   p_user_payroll_action_id     in         number,    -- current run.
   p_owner_assignment_action_id in         number,    -- assact created balance.
   p_user_assignment_action_id  in         number,    -- current assact.
   p_owner_effective_date       in         date,      -- eff date of balance.
   p_user_effective_date        in         date,      -- eff date of current run.
   p_dimension_name             in         varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy number     -- dimension expired flag.
) is

  cursor c_date_earned(p_payroll_action_id number) is
  select date_earned
  from pay_payroll_actions
  where payroll_action_id = p_payroll_action_id;

  l_expiry_date date;
  l_curr_expiry_date date;
  l_owner_date_earned   date;
  l_user_date_earned    date;

begin
--
  open c_date_earned(p_owner_payroll_action_id);
  fetch c_date_earned into l_owner_date_earned;
  close c_date_earned;

  open c_date_earned(p_user_payroll_action_id);
  fetch c_date_earned into l_user_date_earned;
  close c_date_earned;

  l_expiry_date := to_date('01-06-'||to_char(l_owner_date_earned, 'YYYY'), 'DD-MM-YYYY');

  if l_expiry_date < l_owner_date_earned then
  --
    l_curr_expiry_date := l_expiry_date;
    l_expiry_date := add_months(l_expiry_date, 12);
  --
  else
  --
    l_curr_expiry_date := add_months(l_expiry_date, -12);
  --
  end if;

--
--
  IF l_user_date_earned >= l_expiry_date THEN
    p_expiry_information := 1;
  ELSE
    -- Date is in a previous period
    if l_user_date_earned < l_curr_expiry_date then
      p_expiry_information := 2;
    else
      -- Date is in current period but prior to lat bal run.
      if l_user_date_earned < l_owner_date_earned then
        p_expiry_information := 3;
      else
        -- No it hasn't expired.
        p_expiry_information := 0;
      end if;
    end if;
  --
  END IF;

--
end ASG_PTO_DE_SM_YTD_EC;

--
-- This is the overloaded date-based expiry routine.
--
procedure ASG_PTO_DE_SM_YTD_EC
(
   p_owner_payroll_action_id    in         number,    -- run created balance.
   p_user_payroll_action_id     in         number,    -- current run.
   p_owner_assignment_action_id in         number,    -- assact created balance.
   p_user_assignment_action_id  in         number,    -- current assact.
   p_owner_effective_date       in         date,      -- eff date of balance.
   p_user_effective_date        in         date,      -- eff date of current run.
   p_dimension_name             in         varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy date       -- dimension expired date.
) is

  cursor c_date_earned(p_payroll_action_id number) is
  select date_earned
  from pay_payroll_actions
  where payroll_action_id = p_payroll_action_id;

  l_expiry_date date;
  l_owner_date_earned    date;

begin
--
  open c_date_earned(p_user_payroll_action_id);
  fetch c_date_earned into l_owner_date_earned;
  close c_date_earned;

  l_expiry_date := to_date('01-06-'||to_char(l_owner_date_earned, 'YYYY'), 'DD-MM-YYYY');

  if l_expiry_date < l_owner_date_earned
     and l_owner_date_earned > to_date('30-06-'||
                                       to_char(l_owner_date_earned, 'YYYY'), 'DD-MM-YYYY')
  then
  --
    l_expiry_date := add_months(l_expiry_date, 12);
  --
  end if;
--
  p_expiry_information := l_expiry_date;
--
end ASG_PTO_DE_SM_YTD_EC;

/*------------------------------ ASG_PTO_DE_HD_YTD_EC ------------------------*/
/*
   NAME
      ASG_PTO_DE_HD_YTD_EC - Assignment Processing Year to Date expiry check.
   DESCRIPTION
      Used to check expiry of seeded date earned balance in PTO accruals, for a
      hire date anniversary accrual plan.
*/
--
-- This is the flag-based expiry routine.
--
procedure ASG_PTO_DE_HD_YTD_EC
(
   p_owner_payroll_action_id    in         number,    -- run created balance.
   p_user_payroll_action_id     in         number,    -- current run.
   p_owner_assignment_action_id in         number,    -- assact created balance.
   p_user_assignment_action_id  in         number,    -- current assact.
   p_owner_effective_date       in         date,      -- eff date of balance.
   p_user_effective_date        in         date,      -- eff date of current run.
   p_dimension_name             in         varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy number     -- dimension expired flag.
) is

  cursor c_date_earned(p_payroll_action_id number) is
  select date_earned
  from pay_payroll_actions
  where payroll_action_id = p_payroll_action_id;

  l_expiry_date date;
  l_curr_expiry_date date;
  l_owner_date_earned   date;
  l_user_date_earned    date;

begin
--

  open c_date_earned(p_owner_payroll_action_id);
  fetch c_date_earned into l_owner_date_earned;
  close c_date_earned;

  open c_date_earned(p_user_payroll_action_id);
  fetch c_date_earned into l_user_date_earned;
  close c_date_earned;

  select add_months(pps.date_start,
                    12 + trunc(months_between(bact.date_earned,
                                              pps.date_start
                                              )/12) *12) finyear
  into l_expiry_date
  from per_periods_of_service pps,
       per_all_assignments_f asg,
       pay_payroll_actions bact,
       pay_assignment_actions bal_assact
  where bact.payroll_action_id = p_owner_payroll_action_id
  and   bal_assact.payroll_action_id = bact.payroll_action_id
  and   pps.period_of_service_id = asg.period_of_service_id
  and   asg.assignment_id = bal_assact.assignment_id
  and   bal_assact.assignment_action_id = p_owner_assignment_action_id
  and   bact.date_earned between asg.effective_start_date
                             and asg.effective_end_date;

  l_curr_expiry_date := add_months(l_expiry_date, -12);
--
--

  IF l_user_date_earned >= l_expiry_date THEN
    p_expiry_information := 1;
  ELSE
    -- Date is in a previous period
    if l_user_date_earned < l_curr_expiry_date then
      p_expiry_information := 2;
    else
      -- Date is in current period but prior to lat bal run.
      if l_user_date_earned < l_owner_date_earned then
        p_expiry_information := 3;
      else
        -- No it hasn't expired.
        p_expiry_information := 0;
      end if;
    end if;
  --
  END IF;

--
end ASG_PTO_DE_HD_YTD_EC;

--
-- This is the overloaded date-based expiry routine.
--
procedure ASG_PTO_DE_HD_YTD_EC
(
   p_owner_payroll_action_id    in         number,    -- run created balance.
   p_user_payroll_action_id     in         number,    -- current run.
   p_owner_assignment_action_id in         number,    -- assact created balance.
   p_user_assignment_action_id  in         number,    -- current assact.
   p_owner_effective_date       in         date,      -- eff date of balance.
   p_user_effective_date        in         date,      -- eff date of current run.
   p_dimension_name             in         varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy date       -- dimension expired date.
) is

  cursor c_date_earned(p_payroll_action_id number) is
  select date_earned
  from pay_payroll_actions
  where payroll_action_id = p_payroll_action_id;

  l_expiry_date date;

begin
--
  select add_months(pps.date_start,
                    12 + trunc(months_between(bact.date_earned,
                                              pps.date_start
                                              )/12) *12) finyear
  into l_expiry_date
  from per_periods_of_service pps,
       per_all_assignments_f asg,
       pay_payroll_actions bact,
       pay_assignment_actions bal_assact
  where bact.payroll_action_id = p_owner_payroll_action_id
  and   bal_assact.payroll_action_id = bact.payroll_action_id
  and   pps.period_of_service_id = asg.period_of_service_id
  and   asg.assignment_id = bal_assact.assignment_id
  and   bal_assact.assignment_action_id = p_owner_assignment_action_id
  and   bact.date_earned between asg.effective_start_date
                             and asg.effective_end_date;

--
  p_expiry_information := l_expiry_date;
--
end ASG_PTO_DE_HD_YTD_EC;

end peptoexc;

/
