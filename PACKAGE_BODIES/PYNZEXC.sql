--------------------------------------------------------
--  DDL for Package Body PYNZEXC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PYNZEXC" as
/* $Header: pynzexc.pkb 115.1 2002/12/03 05:08:25 srrajago ship $ */
--
-- Change List
-- ----------
-- DATE        Name            Vers     Bug No    Description
-- -----------+---------------+--------+--------+-----------------------+
-- 13-Aug-1999 sclarke          1.0                 Created
-- 03-Dec-2002 srrajago         1.1     2689221  Included 'nocopy' option for the 'out'
--                                               parameters of all the procedures,dbdrv
--                                               and checkfile commands.
-- -----------+---------------+--------+--------+-----------------------+
--
  --
  g_nz_fin_year_start             constant varchar2(6) := '01-04-';
  --
-------------------------------- asg_ptd_ec ----------------------------------------------------
--
--  name
--     asg_ptd_ec - assignment processing period to date expiry check.
--  description
--     expiry checking code for the following:
--       nz assignment-level process period to date balance dimension
--  notes
--     the associated dimension is expiry checked at payroll action level
--
procedure asg_ptd_ec
(   p_owner_payroll_action_id    in     number      -- run created balance.
,   p_user_payroll_action_id     in     number      -- current run.
,   p_owner_assignment_action_id in     number      -- assact created balance.
,   p_user_assignment_action_id  in     number      -- current assact..
,   p_owner_effective_date       in     date        -- eff date of balance.
,   p_user_effective_date        in     date        -- eff date of current run.
,   p_dimension_name             in     varchar2    -- balance dimension name.
,   p_expiry_information         out nocopy number      -- dimension expired flag.
) is
  --
  cursor csr_time
  ( p_payroll_action_id       number
  , p_assignment_action_id    number
  , p_effective_date          date) is
  select  ptp.time_period_id
  from    pay_payroll_actions         act
  ,       per_time_periods            ptp
  where   payroll_action_id           = p_payroll_action_id
          and act.date_earned         between ptp.start_date and ptp.end_date
          and act.payroll_id          = ptp.payroll_id
          and act.effective_date      = p_effective_date;
  --
  l_user_time_period_id     number;
  l_owner_time_period_id    number;
  --
begin
  --
  --  select the period of the owning and using action and if they are
  --  the same then the dimension has expired - either a prior period
  --  or a different payroll
  --
  open  csr_time
  (   p_user_payroll_action_id
  ,   p_user_assignment_action_id
  ,   p_user_effective_date   );
  fetch csr_time
  into  l_user_time_period_id;
  close csr_time;
  --
  open  csr_time
  (   p_owner_payroll_action_id
  ,   p_owner_assignment_action_id
  ,   p_owner_effective_date  );
  fetch csr_time
  into  l_owner_time_period_id;
  close csr_time;
  --
  if l_user_time_period_id = l_owner_time_period_id then
    p_expiry_information := 0;
  else
    p_expiry_information := 1;
  end if;
  --
end asg_ptd_ec;
--
-------------------------------- asg_span_ec -----------------------------------------------
--
--  name
--     asg_span_ec - assignment processing year to date expiry check.
--  description
--     expiry checking code for the following:
--       nz assignment-level process year to date balance dimension
--  notes
--     the associated dimension is expiry checked at payroll action level
--
procedure asg_span_ec
(   p_owner_payroll_action_id    in     number    -- run created balance.
,   p_user_payroll_action_id     in     number    -- current run.
,   p_owner_assignment_action_id in     number    -- assact created balance.
,   p_user_assignment_action_id  in     number    -- current assact.
,   p_owner_effective_date       in     date      -- eff date of balance.
,   p_user_effective_date        in     date      -- eff date of current run.
,   p_dimension_name             in     varchar2  -- balance dimension name.
,   p_expiry_information         out nocopy number    -- dimension expired flag.
) is
  --
  cursor  csr_get_business_group is
  select  business_group_id
  from    pay_assignment_actions_v
  where   assignment_action_id = p_user_assignment_action_id;
  --
  cursor  csr_user_span_start(p_frequency number, p_span_start varchar2) is
  select  hr_nz_routes.span_start (    bptp.regular_payment_date
                                  ,   p_frequency
                                  ,   p_span_start    )
  from    per_time_periods            bptp
  ,       pay_payroll_actions         bact
  where   bact.payroll_action_id      = p_user_payroll_action_id
          and bact.effective_date     = p_user_effective_date
          and bact.payroll_id         = bptp.payroll_id
          and bact.date_earned        between bptp.start_date and bptp.end_date;
  --
  cursor  csr_owner_start is
  select  pptp.regular_payment_date
  from    per_time_periods            pptp
  ,       pay_payroll_actions         pact
  where   pact.payroll_action_id      = p_owner_payroll_action_id
          and pact.effective_date     = p_owner_effective_date
          and pact.payroll_id         = pptp.payroll_id
          and pact.date_earned        between pptp.start_date and pptp.end_date;
  --
  l_user_span_start     date;
  l_owner_start         date;
  l_date_dd_mm          varchar2(11);
  l_fy_user_span_start  date;
  l_frequency           number;
  l_dimension_name      pay_balance_dimensions.dimension_name%type := upper(p_dimension_name);
  l_business_group_id   pay_payroll_actions.business_group_id%type;
  --
begin
  --
  -- select the start span for the using action.
  -- if the owning action associated with the latest balance, is
  -- before the start of the span for the using regular payment date
  -- then it has expired.
  --
  if lower(l_dimension_name) = '_asg_ytd' then
    --
    l_frequency := 1;
    l_date_dd_mm := g_nz_fin_year_start;
    --
  elsif lower(l_dimension_name) in ('_asg_fy_ytd','_asg_fy_qtd') then
    --
    open csr_get_business_group;
    fetch csr_get_business_group into l_business_group_id;
    close csr_get_business_group;
    --
    l_fy_user_span_start := hr_nz_routes.get_fiscal_date( l_business_group_id);
    --
    if lower(l_dimension_name) = '_asg_fy_ytd' then
      l_frequency := 1;
    else
      l_frequency := 4;
    end if;
    --
    l_date_dd_mm := to_char(l_fy_user_span_start,'dd-mm-');
    --
  elsif lower(l_dimension_name) = '_asg_hol_ytd' then
    --
    l_frequency := 1;
    l_date_dd_mm := to_char(hr_nz_routes.get_anniversary_date ( p_user_assignment_action_id
                                                              , p_user_effective_date), 'dd-mm-');
    --
  end if;
  --
  open csr_user_span_start (l_frequency, l_date_dd_mm);
  fetch csr_user_span_start into l_user_span_start;
  close csr_user_span_start;
  --
  open  csr_owner_start;
  fetch csr_owner_start into l_owner_start;
  close csr_owner_start;
  --
  if l_owner_start < l_user_span_start then
    p_expiry_information      := 1;
  else
    p_expiry_information      := 0;
  end if;
  --
end asg_span_ec;
--
end pynzexc;

/
