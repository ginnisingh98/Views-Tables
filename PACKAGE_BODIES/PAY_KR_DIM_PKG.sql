--------------------------------------------------------
--  DDL for Package Body PAY_KR_DIM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_DIM_PKG" as
/* $Header: pykrdim.pkb 120.0.12010000.3 2008/08/06 07:38:47 ubhat ship $ */
--
type t_fiscal_year is record(
	payroll_action_id	number,
	fiscal_year_start_date	date);
g_fiscal_year	t_fiscal_year;
--
type t_bonus is record(
	payroll_action_id	number,
	assignment_action_id	number,
	bonus_period_start_date	date);
g_bonus	t_bonus;

g_bonus_payroll_action_id          number;
g_bonus_pay_period_start_date  date;
g_bonus_assignment_action_id       number;
g_bonus_bon_period_start_date    date;

-------------------------------- next_period ---------------------------------------------------
--
-- NAME        : next_period
-- DESCRIPTION : Given a date and a payroll action id, returns the date after the
--               end of the containing payroll action id's pay period.

   FUNCTION next_period ( p_payroll_action_id in number,
                          p_given_date in date )
                                               RETURN date is
   l_next_to_end_date date := NULL;
   BEGIN
   /* Get the date next to the end date of the given period,
      having the payroll action id */
     SELECT PTP.end_date+1
       INTO l_next_to_end_date
       FROM per_time_periods ptp,
            pay_payroll_actions pact
      WHERE pact.payroll_action_id = p_payroll_action_id
        AND pact.payroll_id    = ptp.payroll_id
        AND p_given_date between ptp.start_date and ptp.end_date;

     return l_next_to_end_date;

   END next_period;

------------------------------- next_month -----------------------------------------------------
--
-- NAME        : next_month
-- DESCRIPTION : Given a date returns the next month's start date.

   FUNCTION next_month (p_given_date in date )
                  RETURN date is
   BEGIN
   /* Return the next month's start date */
      RETURN trunc(add_months(p_given_date,1),'MM');
   END next_month;

-------------------------------  next_quarter --------------------------------------------------
--
-- NAME            : next_quarter
-- DESCRIPTION : Given a date returns the next quarter's start date.

   FUNCTION next_quarter (p_given_date in date)
                   RETURN date is
   BEGIN
   /* Return the next quarter's start date */
      RETURN trunc(add_months(p_given_date,3),'Q');
   END next_quarter;

------------------------------  next_year -----------------------------------------------------
--
-- NAME            : next_year
-- DESCRIPTION : Given a date returns the next year's start date.

   FUNCTION next_year (p_given_date in date)
                  RETURN date is
   BEGIN
   /* Return the next year's start date */
      RETURN trunc(add_months(p_given_date,12),'Y');
   END next_year;

--------------------------------------------------------------------------------
procedure ptd_ec(
  p_owner_payroll_action_id    in     number,   -- run created balance.
  p_user_payroll_action_id     in     number,   -- current run.
  p_owner_assignment_action_id in     number,   -- assact created balance.
  p_user_assignment_action_id  in     number,   -- current assact.
  p_owner_effective_date       in     date,     -- eff date of balance.
  p_user_effective_date        in     date,     -- eff date of current run.
  p_dimension_name             in     varchar2, -- balance dimension name.
  p_expiry_information         out NOCOPY number)   -- dimension expired flag.
--------------------------------------------------------------------------------
is
  cursor csr_expiry_information is
    select  1
    from    pay_payroll_actions     ppa2,
            pay_payroll_actions     ppa1
    where   ppa1.payroll_action_id = p_owner_payroll_action_id
    and     ppa2.payroll_action_id = p_user_payroll_action_id
    and     ppa2.time_period_id <> ppa1.time_period_id;
begin
  open csr_expiry_information;
  fetch csr_expiry_information into p_expiry_information;
  if csr_expiry_information%NOTFOUND then
    p_expiry_information := 0;
  end if;
  close csr_expiry_information;
end ptd_ec;

--------------------------------------------------------------------------------

procedure ptd_ec(
  p_owner_payroll_action_id    in     number,   -- run created balance.
  p_user_payroll_action_id     in     number,   -- current run.
  p_owner_assignment_action_id in     number,   -- assact created balance.
  p_user_assignment_action_id  in     number,   -- current assact.
  p_owner_effective_date       in     date,     -- eff date of balance.
  p_user_effective_date        in     date,     -- eff date of current run.
  p_dimension_name             in     varchar2, -- balance dimension name.
  p_expiry_information         out NOCOPY date)   -- dimension expired date.
is
begin
  --
  p_expiry_information := next_period(p_owner_payroll_action_id, p_owner_effective_date)-1;
  --
end ptd_ec;

--------------------------------------------------------------------------------
procedure mtd_ec(
  p_owner_payroll_action_id    in     number,   -- run created balance.
  p_user_payroll_action_id     in     number,   -- current run.
  p_owner_assignment_action_id in     number,   -- assact created balance.
  p_user_assignment_action_id  in     number,   -- current assact.
  p_owner_effective_date       in     date,     -- eff date of balance.
  p_user_effective_date        in     date,     -- eff date of current run.
  p_dimension_name             in     varchar2, -- balance dimension name.
  p_expiry_information         out NOCOPY  number)   -- dimension expired flag.
--------------------------------------------------------------------------------
is
begin
  if trunc(p_owner_effective_date, 'MM') = trunc(p_user_effective_date, 'MM') then
    p_expiry_information := 0;
  else
    p_expiry_information := 1;
  end if;
end mtd_ec;

--------------------------------------------------------------------------------
procedure mtd_ec(
  p_owner_payroll_action_id    in     number,   -- run created balance.
  p_user_payroll_action_id     in     number,   -- current run.
  p_owner_assignment_action_id in     number,   -- assact created balance.
  p_user_assignment_action_id  in     number,   -- current assact.
  p_owner_effective_date       in     date,     -- eff date of balance.
  p_user_effective_date        in     date,     -- eff date of current run.
  p_dimension_name             in     varchar2, -- balance dimension name.
  p_expiry_information         out NOCOPY  date)   -- dimension expired date.
--------------------------------------------------------------------------------
is
begin
  --
  p_expiry_information := next_month(p_owner_effective_date)-1;
  --
end mtd_ec;
--------------------------------------------------------------------------------
procedure qtd_ec(
  p_owner_payroll_action_id    in     number,   -- run created balance.
  p_user_payroll_action_id     in     number,   -- current run.
  p_owner_assignment_action_id in     number,   -- assact created balance.
  p_user_assignment_action_id  in     number,   -- current assact.
  p_owner_effective_date       in     date,     -- eff date of balance.
  p_user_effective_date        in     date,     -- eff date of current run.
  p_dimension_name             in     varchar2, -- balance dimension name.
  p_expiry_information         out NOCOPY number)   -- dimension expired flag.
--------------------------------------------------------------------------------
is
begin
  if trunc(p_owner_effective_date, 'Q') = trunc(p_user_effective_date, 'Q') then
    p_expiry_information := 0;
  else
    p_expiry_information := 1;
  end if;
end qtd_ec;

--------------------------------------------------------------------------------
procedure qtd_ec(
  p_owner_payroll_action_id    in     number,   -- run created balance.
  p_user_payroll_action_id     in     number,   -- current run.
  p_owner_assignment_action_id in     number,   -- assact created balance.
  p_user_assignment_action_id  in     number,   -- current assact.
  p_owner_effective_date       in     date,     -- eff date of balance.
  p_user_effective_date        in     date,     -- eff date of current run.
  p_dimension_name             in     varchar2, -- balance dimension name.
  p_expiry_information         out NOCOPY date)   -- dimension expired date.
--------------------------------------------------------------------------------
is
begin
  --
  p_expiry_information := next_quarter(p_owner_effective_date)-1;
  --
end qtd_ec;
--------------------------------------------------------------------------------
procedure ytd_ec(
  p_owner_payroll_action_id    in     number,   -- run created balance.
  p_user_payroll_action_id     in     number,   -- current run.
  p_owner_assignment_action_id in     number,   -- assact created balance.
  p_user_assignment_action_id  in     number,   -- current assact.
  p_owner_effective_date       in     date,     -- eff date of balance.
  p_user_effective_date        in     date,     -- eff date of current run.
  p_dimension_name             in     varchar2, -- balance dimension name.
  p_expiry_information         out NOCOPY number)   -- dimension expired flag.
--------------------------------------------------------------------------------
is
begin
  if trunc(p_owner_effective_date, 'YYYY') = trunc(p_user_effective_date, 'YYYY') then
    p_expiry_information := 0;
  else
    p_expiry_information := 1;
  end if;
end ytd_ec;

--------------------------------------------------------------------------------
procedure ytd_ec(
  p_owner_payroll_action_id    in     number,   -- run created balance.
  p_user_payroll_action_id     in     number,   -- current run.
  p_owner_assignment_action_id in     number,   -- assact created balance.
  p_user_assignment_action_id  in     number,   -- current assact.
  p_owner_effective_date       in     date,     -- eff date of balance.
  p_user_effective_date        in     date,     -- eff date of current run.
  p_dimension_name             in     varchar2, -- balance dimension name.
  p_expiry_information         out NOCOPY date)   -- dimension expired date.
--------------------------------------------------------------------------------
is
begin
  --
  p_expiry_information := next_year(p_owner_effective_date)-1;
  --
end ytd_ec;

--------------------------------------------------------------------------------
function fiscal_year_start_date(p_payroll_action_id in number) return date
--------------------------------------------------------------------------------
is
  l_fiscal_year_start_date  date;
  cursor csr_fiscal_year_start_date is
    select   fnd_date.canonical_to_date(hoi.org_information11)
    from     hr_organization_information  hoi,
             pay_payroll_actions          ppa
    where    ppa.payroll_action_id = p_payroll_action_id
    and      hoi.organization_id = ppa.business_group_id
    and      hoi.org_information_context = 'Business Group Information';
begin
  if g_fiscal_year.payroll_action_id = p_payroll_action_id then
    null;
  else
    open csr_fiscal_year_start_date;
    fetch csr_fiscal_year_start_date into l_fiscal_year_start_date;
    if csr_fiscal_year_start_date%NOTFOUND then
      l_fiscal_year_start_date := NULL;
    end if;
    close csr_fiscal_year_start_date;
    --
    g_fiscal_year.payroll_action_id      := p_payroll_action_id;
    g_fiscal_year.fiscal_year_start_date := nvl(l_fiscal_year_start_date, fnd_date.canonical_to_date('2000/01/01'));
  end if;
  --
  return g_fiscal_year.fiscal_year_start_date;
end fiscal_year_start_date;
--------------------------------------------------------------------------------
procedure fqtd_ec(
  p_owner_payroll_action_id    in     number,   -- run created balance.
  p_user_payroll_action_id     in     number,   -- current run.
  p_owner_assignment_action_id in     number,   -- assact created balance.
  p_user_assignment_action_id  in     number,   -- current assact.
  p_owner_effective_date       in     date,     -- eff date of balance.
  p_user_effective_date        in     date,     -- eff date of current run.
  p_dimension_name             in     varchar2, -- balance dimension name.
  p_expiry_information         out NOCOPY number)   -- dimension expired flag.
--------------------------------------------------------------------------------
is
  l_expiry_date  date;
  l_fiscal_year_start_date  date;
begin
  l_fiscal_year_start_date  := fiscal_year_start_date(p_owner_payroll_action_id);
  l_expiry_date := add_months(l_fiscal_year_start_date,
                              (floor(months_between(p_owner_effective_date, l_fiscal_year_start_date) / 3) + 1) * 3);
  if p_user_effective_date >= l_expiry_date then
    p_expiry_information := 1;
  else
    p_expiry_information := 0;
  end if;
end fqtd_ec;

--------------------------------------------------------------------------------
procedure fqtd_ec(
  p_owner_payroll_action_id    in     number,   -- run created balance.
  p_user_payroll_action_id     in     number,   -- current run.
  p_owner_assignment_action_id in     number,   -- assact created balance.
  p_user_assignment_action_id  in     number,   -- current assact.
  p_owner_effective_date       in     date,     -- eff date of balance.
  p_user_effective_date        in     date,     -- eff date of current run.
  p_dimension_name             in     varchar2, -- balance dimension name.
  p_expiry_information         out NOCOPY date)   -- dimension expired date.
--------------------------------------------------------------------------------
is
  l_expiry_date  date;
  l_fiscal_year_start_date  date;
begin
  --
  l_fiscal_year_start_date  := fiscal_year_start_date(p_owner_payroll_action_id);
  p_expiry_information := add_months(l_fiscal_year_start_date,
                              (floor(months_between(p_owner_effective_date, l_fiscal_year_start_date) / 3) + 1) * 3) -1;
  --
end fqtd_ec;

/* Bug 6263815 - Adding expiry checking code for _itd dimension */
--------------------------------------------------------------------------------
procedure itd_ec(
  p_owner_payroll_action_id    in     number,   -- run created balance.
  p_user_payroll_action_id     in     number,   -- current run.
  p_owner_assignment_action_id in     number,   -- assact created balance.
  p_user_assignment_action_id  in     number,   -- current assact.
  p_owner_effective_date       in     date,     -- eff date of balance.
  p_user_effective_date        in     date,     -- eff date of current run.
  p_dimension_name             in     varchar2, -- balance dimension name.
  p_expiry_information         out NOCOPY number)   -- dimension expired flag.
--------------------------------------------------------------------------------
is
begin
    p_expiry_information := 0;
end itd_ec;

--------------------------------------------------------------------------------
procedure itd_ec(
  p_owner_payroll_action_id    in     number,   -- run created balance.
  p_user_payroll_action_id     in     number,   -- current run.
  p_owner_assignment_action_id in     number,   -- assact created balance.
  p_user_assignment_action_id  in     number,   -- current assact.
  p_owner_effective_date       in     date,     -- eff date of balance.
  p_user_effective_date        in     date,     -- eff date of current run.
  p_dimension_name             in     varchar2, -- balance dimension name.
  p_expiry_information         out NOCOPY date)   -- dimension expired date.
--------------------------------------------------------------------------------
is
begin
  p_expiry_information := fnd_date.canonical_to_date('4712/12/31');
end itd_ec;

--------------------------------------------------------------------------------
procedure fytd_ec(
  p_owner_payroll_action_id    in     number,   -- run created balance.
  p_user_payroll_action_id     in     number,   -- current run.
  p_owner_assignment_action_id in     number,   -- assact created balance.
  p_user_assignment_action_id  in     number,   -- current assact.
  p_owner_effective_date       in     date,     -- eff date of balance.
  p_user_effective_date        in     date,     -- eff date of current run.
  p_dimension_name             in     varchar2, -- balance dimension name.
  p_expiry_information         out NOCOPY number)   -- dimension expired flag.
--------------------------------------------------------------------------------
is
  l_expiry_date  date;
  l_fiscal_year_start_date  date;
begin
  l_fiscal_year_start_date  := fiscal_year_start_date(p_owner_payroll_action_id);
  l_expiry_date := add_months(l_fiscal_year_start_date,
                              (floor(months_between(p_owner_effective_date, l_fiscal_year_start_date) / 12) + 1) * 12);
  if p_user_effective_date >= l_expiry_date then
    p_expiry_information := 1;
  else
    p_expiry_information := 0;
  end if;
end fytd_ec;

--------------------------------------------------------------------------------
procedure fytd_ec(
  p_owner_payroll_action_id    in     number,   -- run created balance.
  p_user_payroll_action_id     in     number,   -- current run.
  p_owner_assignment_action_id in     number,   -- assact created balance.
  p_user_assignment_action_id  in     number,   -- current assact.
  p_owner_effective_date       in     date,     -- eff date of balance.
  p_user_effective_date        in     date,     -- eff date of current run.
  p_dimension_name             in     varchar2, -- balance dimension name.
  p_expiry_information         out NOCOPY date)   -- dimension expired date.
--------------------------------------------------------------------------------
is
  l_fiscal_year_start_date  date;
begin
  --
  l_fiscal_year_start_date  := fiscal_year_start_date(p_owner_payroll_action_id);
  p_expiry_information := add_months(l_fiscal_year_start_date,
                              (floor(months_between(p_owner_effective_date, l_fiscal_year_start_date) / 12) + 1) * 12) -1;
  --
end fytd_ec;
--------------------------------------------------------------------------------
procedure hdtd_ec(
  p_owner_payroll_action_id    in     number,   -- run created balance.
  p_user_payroll_action_id     in     number,   -- current run.
  p_owner_assignment_action_id in     number,   -- assact created balance.
  p_user_assignment_action_id  in     number,   -- current assact.
  p_owner_effective_date       in     date,     -- eff date of balance.
  p_user_effective_date        in     date,     -- eff date of current run.
  p_dimension_name             in     varchar2, -- balance dimension name.
  p_balance_context_values     in     varchar2,  -- list of context value
  p_expiry_information         out NOCOPY number)   -- dimension expired flag.
--------------------------------------------------------------------------------
is
  l_hire_date    date;
  l_expiry_date  date;
  cursor csr_hire_date is
    select  pps.date_start
    from    per_periods_of_service  pps,
            per_assignments_f       pa,
            pay_assignment_actions  paa
    where   paa.assignment_action_id = p_owner_assignment_action_id
    and     pa.assignment_id = paa.assignment_id
    and     p_owner_effective_date
            between pa.effective_start_date and pa.effective_end_date
    and     pps.period_of_service_id = pa.period_of_service_id;
begin
  open csr_hire_date;
  fetch csr_hire_date into l_hire_date;
  close csr_hire_date;
  --
  l_expiry_date := add_months(l_hire_date,
                              (floor(months_between(p_owner_effective_date, l_hire_date) / 12) + 1) * 12);
  if p_user_effective_date >= l_expiry_date then
    p_expiry_information := 1;
  else
    p_expiry_information := 0;
  end if;
end hdtd_ec;
------------------------------------------------------------------------
PROCEDURE hdtd_start_date(p_effective_date  IN  DATE     ,
                     p_start_date      OUT NOCOPY DATE,
                     p_payroll_id      IN  NUMBER   DEFAULT NULL,
                     p_bus_grp         IN  NUMBER   DEFAULT NULL,
                     p_asg_action      IN  NUMBER   DEFAULT NULL)
--------------------------------------------------------------------------
is
cursor csr_start_date is
  select ppos.date_start
  from per_periods_of_service ppos,
       pay_assignment_actions pac,
       per_assignments_f  pa
  Where pac.assignment_action_id = p_asg_action
	and pac.assignment_id = pa.assignment_id
	and ppos.period_of_service_id = pa.period_of_service_id
	and  p_effective_date
	     between pa.effective_start_date and pa.effective_end_date;
BEGIN
  open csr_start_date;
  fetch csr_start_date into p_start_date;
  close csr_start_date;
END hdtd_start_date;

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
procedure hdtd_ec(
  p_owner_payroll_action_id    in     number,   -- run created balance.
  p_user_payroll_action_id     in     number,   -- current run.
  p_owner_assignment_action_id in     number,   -- assact created balance.
  p_user_assignment_action_id  in     number,   -- current assact.
  p_owner_effective_date       in     date,     -- eff date of balance.
  p_user_effective_date        in     date,     -- eff date of current run.
  p_dimension_name             in     varchar2, -- balance dimension name.
  p_balance_context_values     in     varchar2,  -- list of context value
  p_expiry_information         out NOCOPY date)   -- dimension expired date.
--------------------------------------------------------------------------------
is
  l_hire_date    date;
  cursor csr_hire_date is
    select  pps.date_start
    from    per_periods_of_service  pps,
            per_assignments_f       pa,
            pay_assignment_actions  paa
    where   paa.assignment_action_id = p_owner_assignment_action_id
    and     pa.assignment_id = paa.assignment_id
    and     p_owner_effective_date
            between pa.effective_start_date and pa.effective_end_date
    and     pps.period_of_service_id = pa.period_of_service_id;
begin
  open csr_hire_date;
  fetch csr_hire_date into l_hire_date;
  close csr_hire_date;
  --
  p_expiry_information := add_months(l_hire_date,
                              (floor(months_between(p_owner_effective_date, l_hire_date) / 12) + 1) * 12) -1;
  --
end hdtd_ec;
--------------------------------------------------------------------------------
function run_type_name(p_payroll_action_id IN NUMBER
                      ,p_assact_id IN NUMBER DEFAULT NULL) return VARCHAR2
--------------------------------------------------------------------------------
is
  l_run_type_name	pay_run_types_f.run_type_name%TYPE;
  cursor csr_run_type_name is
    select  prt.run_type_name
    from    pay_run_types_f      prt,
            pay_payroll_actions  ppa
    where   ppa.payroll_action_id = p_payroll_action_id
    and     prt.run_type_id = ppa.run_type_id
    and     ppa.effective_date
            between prt.effective_start_date and prt.effective_end_date;

  cursor csr_run_type_name_assact is
    select  prt.run_type_name
    from    pay_run_types_f      prt,
            pay_assignment_actions  paa,
	    pay_payroll_actions ppa
    where   paa.assignment_action_id = p_assact_id
    and     ppa.payroll_action_id = p_payroll_action_id
    and     prt.run_type_id = paa.run_type_id
    and     ppa.effective_date
            between prt.effective_start_date and prt.effective_end_date;

begin
  open csr_run_type_name;
  fetch csr_run_type_name into l_run_type_name;
  if csr_run_type_name%NOTFOUND then
    l_run_type_name := NULL;
  end if;
  close csr_run_type_name;
  --
  if l_run_type_name IS NULL then
    open csr_run_type_name_assact;
    fetch csr_run_type_name_assact into l_run_type_name;
    if csr_run_type_name_assact%NOTFOUND then
      l_run_type_name := NULL;
    end if;
    close csr_run_type_name_assact;
  end if;
  --
  return l_run_type_name;
end run_type_name;
--------------------------------------------------------------------------------
/*
procedure gen_fc(
  p_payroll_action_id          in number,
  p_assignment_action_id       in number,
  p_assignment_id              in number,
  p_effective_date             in date,
  p_dimension_name             in varchar2,
  p_balance_contexts           in varchar2,
  p_feed_flag                  in out NOCOPY number)
--------------------------------------------------------------------------------
IS
  l_run_type_name  pay_run_types_f.run_type_name%TYPE;
BEGIN
  l_run_type_name := run_type_name(p_payroll_action_id,p_assignment_action_id);
  --
  -- Exclude Separation Payment
  --
  if l_run_type_name like 'SEP%' then
    p_feed_flag := 0;
  else
    p_feed_flag := 1;
  end if;
end gen_fc;
*/
--------------------------------------------------------------------------------
procedure bptd_fc(
  p_payroll_action_id          in number,
  p_assignment_action_id       in number,
  p_assignment_id              in number,
  p_effective_date             in date,
  p_dimension_name             in varchar2,
  p_balance_contexts           in varchar2,
  p_feed_flag                  in out NOCOPY number)
--------------------------------------------------------------------------------
IS
  l_run_type_name  pay_run_types_f.run_type_name%TYPE;
BEGIN
  l_run_type_name := run_type_name(p_payroll_action_id,p_assignment_action_id);
  --
  -- Exclude Separation Payment
  --
  if l_run_type_name like 'SEP%' then
    p_feed_flag := 0;
  else
    p_feed_flag := 1;
  end if;
end bptd_fc;
--------------------------------------------------------------------------------
PROCEDURE mth_fc(
  p_payroll_action_id          in number,
  p_assignment_action_id       in number,
  p_assignment_id              in number,
  p_effective_date             in date,
  p_dimension_name             in varchar2,
  p_balance_contexts           in varchar2,
  p_feed_flag                  in out NOCOPY number)
--------------------------------------------------------------------------------
IS
  l_run_type_name  pay_run_types_f.run_type_name%TYPE;
BEGIN
  l_run_type_name := run_type_name(p_payroll_action_id,p_assignment_action_id);
  --
  -- If the run_type is not specified, it is regarded as Monthly Payroll.
  -- e.g. Balance Adjustment etc.
  --
--  if nvl(l_run_type_name, 'MTH') = 'MTH' then
  if l_run_type_name = 'MTH' then
    p_feed_flag := 1;
  else
    p_feed_flag := 0;
  end if;
END mth_fc;
--------------------------------------------------------------------------------
PROCEDURE bon_fc(
  p_payroll_action_id          in number,
  p_assignment_action_id       in number,
  p_assignment_id              in number,
  p_effective_date             in date,
  p_dimension_name             in varchar2,
  p_balance_contexts           in varchar2,
  p_feed_flag                  in out NOCOPY number)
--------------------------------------------------------------------------------
IS
  l_run_type_name  pay_run_types_f.run_type_name%TYPE;
BEGIN
  l_run_type_name := run_type_name(p_payroll_action_id,p_assignment_action_id);
  --
  if l_run_type_name like 'BON\_%' escape '\' then
    p_feed_flag := 1;
  else
    p_feed_flag := 0;
  end if;
END bon_fc;
--------------------------------------------------------------------------------
PROCEDURE sep_fc(
  p_payroll_action_id          in number,
  p_assignment_action_id       in number,
  p_assignment_id              in number,
  p_effective_date             in date,
  p_dimension_name             in varchar2,
  p_balance_contexts           in varchar2,
  p_feed_flag                  in out NOCOPY number)
--------------------------------------------------------------------------------
IS
  l_run_type_name  pay_run_types_f.run_type_name%TYPE;
BEGIN
  l_run_type_name := run_type_name(p_payroll_action_id,p_assignment_action_id);
  --
  if l_run_type_name in ('SEP','SEP_I') then
    p_feed_flag := 1;
  else
    p_feed_flag := 0;
  end if;
END sep_fc;
--------------------------------------------------------------------------------
function bonus_period_start_date(
	p_payroll_id		in number,
	p_effective_date	in date,
	p_assignment_set_id	in number,
	p_run_type_id		in number) return date
--------------------------------------------------------------------------------
is
	l_soy		constant	date  := trunc(p_effective_date, 'YYYY');
	l_run_type_name			pay_run_types_f.run_type_name%TYPE;
	type t_run_type_name_tbl is table of pay_run_types_f.run_type_name%TYPE index by binary_integer;
	type t_assignment_set_id_tbl is table of number index by binary_integer;
	type t_start_date_tbl is table of date index by binary_integer;
	l_run_type_name_tbl		t_run_type_name_tbl;
	l_assignment_set_id_tbl		t_assignment_set_id_tbl;
	l_start_date_tbl		t_start_date_tbl;
	l_bonus_period_start_date	date;
	--
	cursor csr_run_type_name is
		select	run_type_name
		from	pay_run_types_f
		where	run_type_id = p_run_type_id
		and	p_effective_date
			between effective_start_date and effective_end_date;
	--
	cursor csr_pact is
		select
			prt.run_type_name,
			ppa.assignment_set_id,
			ptp.start_date
		from	pay_run_types_f		prt,
			per_time_periods	ptp,
			pay_payroll_actions	ppa
		where	ppa.payroll_id = p_payroll_id
		and	ppa.action_type = 'R'
		and	ppa.effective_date
			between l_soy and p_effective_date
		and	ptp.time_period_id = ppa.time_period_id
		and	p_effective_date
			not between ptp.start_date and ptp.end_date
		and	prt.run_type_id = ppa.run_type_id
		and	ppa.effective_date
			between prt.effective_start_date and prt.effective_end_date
		and	(
					prt.run_type_name = 'MTH'
				or
				/* Bonuses within current payroll period are out of scope. */
				(
						prt.run_type_name like 'BON\_%' escape '\'
					and	p_effective_date
						not between ptp.start_date and ptp.end_date
				)
			)
		order by ppa.effective_date desc, ppa.action_sequence desc;
	--
	cursor csr_start_date is
		select	start_date
		from	per_time_periods
		where	payroll_id = p_payroll_id
		and	p_effective_date
			between start_date and end_date;
begin
	--
	-- Derive run_type_name
	--
	open csr_run_type_name;
	fetch csr_run_type_name into l_run_type_name;
	if csr_run_type_name%NOTFOUND then
		raise NO_DATA_FOUND;
	end if;
	close csr_run_type_name;
	--
	-- Derive all payroll action with the same payroll as current payroll
	-- whose effective_date is between start date of this calendar year
	-- and effective_date in descending order.
	--
	open csr_pact;
	fetch csr_pact bulk collect into l_run_type_name_tbl, l_assignment_set_id_tbl, l_start_date_tbl;
	close csr_pact;
	--
	-- Get the first monthly payroll action with the same payroll_id within bonus period.
	-- Bonus period is from the latest bonus with the same run_type category as current bonus
	-- within the same calendar year.
	--
	for i in 1..l_run_type_name_tbl.count loop
		if (l_run_type_name_tbl(i) = l_run_type_name)
		or (l_run_type_name_tbl(i) in ('BON_RWOP', 'BON_I') and l_run_type_name in ('BON_RWOP', 'BON_I')) then
			if (l_assignment_set_id_tbl(i) is null) or (l_assignment_set_id_tbl(i) = p_assignment_set_id) then
				exit;
			end if;
		end if;
		--
		if l_run_type_name_tbl(i) = 'MTH' then
			l_bonus_period_start_date := l_start_date_tbl(i);
		end if;
	end loop;
	--
	-- If no monthly payroll action exists within bonus period,
	-- set start date of current payroll period as bonus period start date.
	--
	if l_bonus_period_start_date is null then
		open csr_start_date;
		fetch csr_start_date into l_bonus_period_start_date;
		close csr_start_date;
	end if;
	--
	return greatest(l_bonus_period_start_date, l_soy);
end bonus_period_start_date;
--------------------------------------------------------------------------------
function bonus_period_start_date(
	p_assignment_action_id	in number,
	p_payroll_action_id	in number) return date
--------------------------------------------------------------------------------
is
	l_bonus_period_start_date	date;
        --
        cursor csr_ovrd_ass_start_date(p_assignment_action_id number) is
	select
		   fnd_date.canonical_to_date(prrv.result_value)
	  from     pay_run_result_values  prrv,
		   pay_run_results        prr,
		   pay_payroll_actions    ppa,
		   pay_assignment_actions paa,
		   pay_element_types_f    pet,
		   pay_input_values_f     piv
	  where
		   paa.assignment_action_id = p_assignment_action_id
	  and    ppa.payroll_action_id = paa.payroll_action_id
	  and    prr.assignment_action_id = paa.assignment_action_id
	  and    prr.element_type_id = pet.element_type_id
	  and    pet.element_name = 'OVRD_BONUS_PERIOD'
	  and    pet.legislation_code = 'KR'
	  and    ppa.effective_date between pet.effective_start_date and pet.effective_end_date
	  and    prrv.run_result_id = prr.run_result_id
	  and    prrv.input_value_id = piv.input_value_id
	  and    piv.name = 'BONUS_PERIOD_START_DATE'
	  and    piv.legislation_code = 'KR'
	  and    ppa.effective_date between piv.effective_start_date and piv.effective_end_date;
	--
	cursor csr_bonus_period_start_date is
		select
			min(greatest(ptp.start_date, trunc(ppa1.effective_date, 'YYYY')))
		from	per_time_periods	ptp,
			pay_run_types_f		prt2,
			pay_payroll_actions	ppa2,
			pay_assignment_actions	paa2,
			pay_run_types_f		prt1,
			pay_payroll_actions	ppa1,
			pay_assignment_actions	paa1
		where	paa1.assignment_action_id = p_assignment_action_id
		and	ppa1.payroll_action_id = paa1.payroll_action_id
		and	prt1.run_type_id = paa1.run_type_id
		and	ppa1.effective_date
			between prt1.effective_start_date and prt1.effective_end_date
		and	paa2.assignment_id = nvl(paa1.assignment_id, prt1.run_type_id)
		/* Including current bonus assignment_action_id */
		and	paa2.action_sequence <= paa1.action_sequence
		and	ppa2.payroll_action_id = paa2.payroll_action_id
		and	ppa2.action_type in ('R', 'Q')
		and	ppa2.effective_date >= trunc(ppa1.effective_date, 'YYYY')
		and	prt2.run_type_id = paa2.run_type_id
		and	ppa2.effective_date
			between prt2.effective_start_date and prt2.effective_end_date
		/* Including current bonus assignment_action_id */
		and	decode(paa2.assignment_action_id, paa1.assignment_action_id, 'MTH', prt2.run_type_name) = 'MTH'
		and	ptp.time_period_id = nvl(ppa2.time_period_id, prt2.run_type_id)
		and	paa2.action_sequence > (
				/* Latest bonus with same run_type category as corrent bonus. */
				select	nvl(max(paa3.action_sequence), 0)
				from	pay_run_types_f		prt3,
					pay_payroll_actions	ppa3,
					pay_assignment_actions	paa3
				where	paa3.assignment_id = paa1.assignment_id
				and	paa3.action_sequence < paa1.action_sequence
				and	ppa3.payroll_action_id = paa3.payroll_action_id
				and	ppa3.action_type in ('R', 'Q')
				and	ppa3.effective_date >= trunc(ppa1.effective_date, 'YYYY')
				/* Bonuses within current payroll period are out of scope. */
				and	ppa3.time_period_id <> ppa1.time_period_id
				and	prt3.run_type_id = paa3.run_type_id
				and	ppa3.effective_date
					between prt3.effective_start_date and prt3.effective_end_date
				and	decode(prt3.run_type_name, 'BON_RWOP', -1, 'BON_I', -1, prt3.run_type_id) = decode(prt1.run_type_name, 'BON_RWOP', -1, 'BON_I', -1, prt1.run_type_id)
			);
begin
	--
	-- Get the bonus period start date set at payroll level if not available in cache.
	--
	if g_bonus_payroll_action_id = p_payroll_action_id then
           null;
        else
           g_bonus_pay_period_start_date := fnd_date.canonical_to_date(
                                                 pay_kr_ff_functions_pkg.get_legislative_parameter(
                                                                   p_payroll_action_id,
                                                                  'BONUS_PERIOD_START_DATE',
                                                                   null));
           g_bonus_payroll_action_id := p_payroll_action_id;
        end if;


        if g_bonus_assignment_action_id = p_assignment_action_id then
		null;
	else
                --
                -- 1. Get the Bonus Period Start date from the input value 'Bonus Period Start Date' of element
                --    'Overriding Bonus calculation'
                --
		open csr_ovrd_ass_start_date(p_assignment_action_id);
		fetch csr_ovrd_ass_start_date into l_bonus_period_start_date;
		close csr_ovrd_ass_start_date;

                if l_bonus_period_start_date is not null then
		   g_bonus_assignment_action_id	 := p_assignment_action_id;
		   g_bonus_bon_period_start_date := l_bonus_period_start_date;
                end if;
                --
                -- 2. If Bonus Period Start date is not set by element 'Overriding Bonus calculation' then
                --    get Bonus Period Start date from the legislative parameter BONUS_PERIOD_START_DATE
                --
                if (l_bonus_period_start_date is null and
                    g_bonus_pay_period_start_date is not null and
                    p_payroll_action_id = g_bonus_payroll_action_id ) then
		          g_bonus_assignment_action_id	:= p_assignment_action_id;
		          g_bonus_bon_period_start_date := g_bonus_pay_period_start_date;
                end if;
		--
		-- 3. If legislative parameter BONUS_PERIOD_START_DATE is not set,
		--    derive this parameter from PAY_ASSIGNMENT_ACTIONS table
		--    and stores it in cache.
		--
		if (l_bonus_period_start_date is null and
                     g_bonus_pay_period_start_date is null) then
			open csr_bonus_period_start_date;
			fetch csr_bonus_period_start_date into l_bonus_period_start_date;
			close csr_bonus_period_start_date;
			--
			g_bonus_assignment_action_id  := p_assignment_action_id;
		        g_bonus_bon_period_start_date := l_bonus_period_start_date;
		end if;
		--
	end if;
	--
	return g_bonus_bon_period_start_date;
end bonus_period_start_date;
--
Function inc_or_exc_assact (p_bal_asact in pay_assignment_actions.assignment_action_id%type
                     ,p_asact                      in pay_assignment_actions.assignment_action_id%type
                     ,p_bal_asact_rtype_name       in pay_run_types_f.run_type_name%type
                     ,p_asact_rtype_name           in pay_run_types_f.run_type_name%type ) return varchar2 is


/* This function is used to arrive at
  'Total Taxable Earnings Subj to Regular Tax' for bonus payroll runs .
   If current run_type_name in ('BON_RWP' , 'BON_RWOP' ) Then .
    Total Taxable Earnings Subj to Regular Tax =
        Current Bonus + ( MTH + BON_I +BON_RWP + BON_RWOP
                       + BON_O + BON_ALR within Bonus Period )

   If current run_type_name in ('BON_I') Then
    Total Taxable Earnings Subj to Regular Tax =
        Current Bonus + ( MTH + BON_I +BON_RWP + BON_O +
                         BON_ALR within Bonus Period )

   -- Common business practices do not allow running 'regular bonus without period'
   -- and 'irregular bonus'  within the same period

    If current run_type_name in ('BON_O','BON_ALR') Then
       Total Taxable Earnings Subj to Regular Tax =
       Current Bonus + ( MTH + within Bonus Period )
*/


l_include  constant  Varchar2(10) :='INCLUDE';
l_exclude  constant  Varchar2(10) :='EXCLUDE';


begin
  if p_bal_asact = p_asact then
    return l_include ;
  else
    if (p_bal_asact_rtype_name in ('BON_RWOP','BON_RWP' ) ) then
      if substr(p_asact_rtype_name ,1,3 ) in ('MTH','BON') then
        return l_include;
      else
        return l_exclude;
      end if;
    elsif p_bal_asact_rtype_name='BON_I' then
      if p_asact_rtype_name  in ('MTH','BON_I','BON_RWP','BON_ALR') then
        return l_include;
      else
        return l_exclude;
      end if;
    elsif p_bal_asact_rtype_name in ('BON_O','BON_ALR')  then
      if p_asact_rtype_name = 'MTH' then
        return l_include;
       else
        return l_exclude;
       end if;
    else
        return l_exclude ;
    end if ;
  end if;

  -- in  other cases

   return l_exclude ;

end inc_or_exc_assact;


--
end pay_kr_dim_pkg;

/
