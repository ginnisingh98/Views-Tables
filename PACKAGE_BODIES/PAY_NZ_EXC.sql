--------------------------------------------------------
--  DDL for Package Body PAY_NZ_EXC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NZ_EXC" as
/* $Header: pynzexc.pkb 120.3.12010000.4 2008/09/12 12:13:23 lnagaraj ship $ */
--
-- Change List
-- ----------
-- DATE        Name            Vers     Bug No    Description
-- -----------+---------------+--------+--------+-----------------------+
-- 13-Aug-1999 sclarke          1.0                 Created
-- 03-Dec-2002 srrajago         1.1     2689221  Included 'nocopy' option for the 'out'
--                                               parameters of all the procedures,dbdrv
--                                               and checkfile commands.
-- 22-Jul-2003 puchil           1.2     3004603  Added overloaded function to populate
--                                               latest balances for balance adjustment
--                                               correctly
-- 05-Aug-2003 puchil           1.3     3062941  Changed the package name from pynzexc
--                                               to pay_nz_exc
-- 10-Aug-2004 sshankar         1.4     3181581  Changed function ASG_SPAN_EC to use
--                                               effective_date instead of
--                                               regular_payment_date and removed function
--                                               ASG_PTD_EC, expiry checking code for
--                                               _ASG_PTD.
-- 11-Aug-2004 sshankar         1.5     3181581  Removed gscc warnings.
-- 16-Nov-2004 snekkala         1.6     3828575  Added Start Date Code Procedures
-- 25-Nov-2004 snekkala         1.7     3998117  Changed the p_expiry_information
--                                               Values in asg_span_ec
-- 27-Nov-2004 snekkala         1.8     3998117  Changed p_user_effective_date to
--                                               p_owncer_effective_date and reset
--                                               p_expiry_information in asg_span_ec
-- 01-Aug-2005 snekkala         1.9     4259438  Modified cursor csr_get_business_group
--                                               as part of performance
-- 12-Apr-2007 dduvvuri         1.10    5846247  Added Procedure start_code_11mths_prev
--                                               for KiwiSaver Statutory Requirement from
--                                               1st Jul 2007
-- 27-Apr-2007 dduvvuri         1.11    5846247  Changed procedure start_code_11mths_prev.
--                                               Changed Tab characters to spaces
-- 02-AUG-2007 dduvvuri         1.12    6263808  Added Expiry Check for Dimension _ASG_TD in procedure asg_span_ec
-- 30-Jul-2008 avenkatk         1.14    7260523  Modified Start Date returned by start_code_12mths_prev.
-- -----------+---------------+--------+--------+-----------------------+
--
  --
  g_nz_fin_year_start             constant varchar2(6) := '01-04-';
  --
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
  CURSOR  csr_get_business_group
  IS
    SELECT ppa.business_group_id
      FROM pay_assignment_actions     paa
         , pay_payroll_actions        ppa
     WHERE paa.assignment_action_id = p_user_assignment_action_id
       AND ppa.payroll_action_id    = paa.payroll_action_id;

  --
  -- Bug 3181581
  -- Removed cursors csr_user_span_start and csr_owner_start
  --

  --
  l_user_span_start     date;
  l_owner_start         date;
  l_date_dd_mm          varchar2(11);
  l_fy_user_span_start  date;
  l_frequency           number;
  l_dimension_name      pay_balance_dimensions.dimension_name%type ;
  l_business_group_id   pay_payroll_actions.business_group_id%type;
  --
begin

  l_dimension_name := upper(p_dimension_name);

 --
  -- select the start span for the using action.
  -- if the owning action associated with the latest balance, is
  -- before the start of the span for the using regular payment date
  -- then it has expired.
  --
   if lower(l_dimension_name) = '_asg_td' then -- Added for bug 6263808
      p_expiry_information := 0;
      RETURN;
  elsif lower(l_dimension_name) = '_asg_ytd' then
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

  --
  -- Bug 3181581
  -- Changed to use effective date instead of regular_payment_date
  --
  l_user_span_start := hr_nz_routes.span_start(p_user_effective_date
                                              ,l_frequency
                                              ,l_date_dd_mm);
  if p_owner_effective_date < l_user_span_start then
    --
     p_expiry_information := 1;
  else
    --
    p_expiry_information  := 0;
    --
  end if;
  --
  -- Bug 3181581
  -- End
  --
end asg_span_ec;
--

/*
 * Bug 3004603 - Overloaded procedures added to prevent loss of latest balances.
 *               Also added supporting functions.
 */
-------------------------------- next_period ------------------------------------
/*
 * NAME        : next_period
 * DESCRIPTION : Given a date and a payroll action id, returns the date after the
 *               end of the containing payroll action id's pay period.
 */
--
function next_period
( p_payroll_action_id in number
, p_given_date in date )
RETURN date is
   l_next_to_end_date date := NULL;

   /* Get the date next to the end date of the given period,
      having the payroll action id */
   cursor csr_end_date is
     select PTP.end_date
     from   per_time_periods ptp,
            pay_payroll_actions pact
     where  pact.payroll_action_id = p_payroll_action_id
     and    pact.payroll_id = ptp.payroll_id
     and    p_given_date between ptp.start_date and ptp.end_date;

begin
   open csr_end_date;
   fetch csr_end_date into l_next_to_end_date;
   close csr_end_date;

   return l_next_to_end_date;
end next_period;
-------------------------------  next_quarter --------------------------------------------------
/*
 * NAME            : next_quarter
 * DESCRIPTION : Given a date returns the next quarter's start date.
 */
--
function next_quarter
(p_given_date in date)
RETURN date is
begin
   /* Return the next quarter's start date */
   RETURN trunc(add_months(p_given_date,3),'Q');
end next_quarter;

------------------------------  next_year -----------------------------------------------------
/*
 * NAME            : next_year
 * DESCRIPTION : Given a date returns the next year's start date.
 */
--
function next_year
(p_given_date in date)
RETURN date is
begin
   /* Return the next year's start date */
   RETURN trunc(add_months(p_given_date,12),'Y');
end next_year;

------------------------------- next_fin_quarter -------------------------------------------
/*
 * NAME            : next_fin_quarter
 * DESCRIPTION : Given a date returns the next fiscal quarter's start date.
 */
--
function next_fin_quarter
( p_beg_of_the_year in date
, p_given_date in date )
RETURN date is

   -- get offset of fin year start with reference to calender year in months and days
   l_finyr_months_offset NUMBER(2) ;
   l_finyr_days_offset   NUMBER(2) ;

begin

   l_finyr_months_offset := to_char(p_beg_of_the_year,'MM') - 1;
   l_finyr_days_offset   := to_char(p_beg_of_the_year,'DD') - 1;

   /* Return the next fiscal quarter's start date */
   RETURN (add_months(next_quarter(add_months(p_given_date,-l_finyr_months_offset)
                -l_finyr_days_offset),l_finyr_months_offset)+ l_finyr_days_offset);
end next_fin_quarter;

------------------------------- next_fin_year -------------------------------------------
/*
 * NAME            : next_fin_year
 * DESCRIPTION : Given a date returns the next fiscal quarter's start date.
 */
--
function next_fin_year
( p_beg_of_the_year in date
, p_given_date in date )
RETURN date is

   -- get offset of fin year start with reference to calender year in months and days
   l_finyr_months_offset NUMBER(2);
   l_finyr_days_offset   NUMBER(2);

begin
   l_finyr_months_offset  := to_char(p_beg_of_the_year,'MM') - 1;
   l_finyr_days_offset   := to_char(p_beg_of_the_year,'DD') - 1;

   /* Return the next fiscal quarter's start date */
   RETURN (add_months(next_year(add_months(p_given_date,-l_finyr_months_offset)
             -l_finyr_days_offset),l_finyr_months_offset)+ l_finyr_days_offset);
end next_fin_year;
--
---------------------------- Overloaded asg_span_ec ------------------------------------
/*
 *
 *  name
 *     asg_span_ec - assignment processing span to date expiry check.
 *  description
 *     Overloaded expiry checking code for the following:
 *          nz assignment-level process year to date balance dimension
 *          nz assignment-level process fiscal year to date balance dimension
 *          nz assignment-level process fiscal quarter to date balance dimension
 *          nz assignment-level process holiday year to date balance dimension
 *  notes
 *     the associated dimension is expiry checked at assignment action level
 */
--
procedure asg_span_ec
(   p_owner_payroll_action_id    in     number    -- run created balance.
,   p_user_payroll_action_id     in     number    -- current run.
,   p_owner_assignment_action_id in     number    -- assact created balance.
,   p_user_assignment_action_id  in     number    -- current assact.
,   p_owner_effective_date       in     date      -- eff date of balance.
,   p_user_effective_date        in     date      -- eff date of current run.
,   p_dimension_name             in     varchar2  -- balance dimension name.
,   p_expiry_information         out nocopy date  -- dimension expired flag.
) is
   l_beg_of_fiscal_year date;
   l_dimension_name pay_balance_dimensions.dimension_name%type ;

   cursor get_beg_of_fiscal_year(c_owner_payroll_action_id number) is
   select fnd_date.canonical_to_date(org_information11)
   from   pay_payroll_actions PACT,
          hr_organization_information HOI
   where  UPPER(HOI.org_information_context) = 'BUSINESS GROUP INFORMATION'
   and    HOI.organization_id = PACT.business_group_id
   and    PACT.payroll_action_id = c_owner_payroll_action_id;
begin
   l_dimension_name := upper(p_dimension_name);

   IF l_dimension_name = '_ASG_TD' THEN   --Added check for bug 6263808
      p_expiry_information := fnd_date.canonical_to_date('4712/12/31'); --Added check for bug 6263808
   elsif l_dimension_name = '_ASG_YTD' then
      p_expiry_information := next_fin_year(to_date(g_nz_fin_year_start,'DD-MM-'), p_owner_effective_date)-1;
   elsif l_dimension_name = '_ASG_FY_QTD' then
      open get_beg_of_fiscal_year(p_owner_payroll_action_id);
      fetch get_beg_of_fiscal_year into l_beg_of_fiscal_year;
      close get_beg_of_fiscal_year;

      p_expiry_information := next_fin_quarter(l_beg_of_fiscal_year, p_owner_effective_date)-1;
   elsif l_dimension_name = '_ASG_FY_YTD' then
      open get_beg_of_fiscal_year(p_owner_payroll_action_id);
      fetch get_beg_of_fiscal_year into l_beg_of_fiscal_year;
      close get_beg_of_fiscal_year;

      p_expiry_information := next_fin_year(l_beg_of_fiscal_year, p_owner_effective_date)-1;
   end if;
end asg_span_ec;
--
--------------------------------------------------------------------------
--                                                                      --
-- Name           : START_CODE_4WEEK                                    --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : This procedure finds the start date based on the    --
--                  effective date for the dimension name _ASG_4WEEK    --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_effective_date       DATE                         --
--                  p_payroll_id           NUMBER                       --
--                  p_bus_grp              NUMBER                       --
--                  p_asg_action           NUMBER                       --
--            OUT : p_start_date           DATE                         --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date        Userid      Description                            --
--------------------------------------------------------------------------
-- 1.0  16-Nov-2004  snekkala    Created the procedure                  --
--------------------------------------------------------------------------
PROCEDURE start_code_4week( p_effective_date  IN         DATE
                          , p_start_date      OUT NOCOPY DATE
                          , p_payroll_id      IN         NUMBER
                          , p_bus_grp         IN         NUMBER
                          , p_asg_action      IN         NUMBER
                          )
IS
BEGIN
     p_start_date := p_effective_date - 28;
END start_code_4week;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : START_CODE_4WEEKS_PREV                              --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : This procedure finds the start date based on the    --
--                  effective date for dimension  _ASG_4WEEKS_PREV      --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_effective_date       DATE                         --
--                  p_payroll_id           NUMBER                       --
--                  p_bus_grp              NUMBER                       --
--                  p_asg_action           NUMBER                       --
--            OUT : p_start_date           DATE                         --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date        Userid      Description                            --
--------------------------------------------------------------------------
-- 1.0  16-Nov-2004  snekkala    Created the procedure                  --
--------------------------------------------------------------------------
PROCEDURE start_code_4weeks_prev( p_effective_date  IN         DATE
                                , p_start_date      OUT NOCOPY DATE
                                , p_payroll_id      IN         NUMBER
                                , p_bus_grp         IN         NUMBER
                                , p_asg_action      IN         NUMBER
                                )
IS
            CURSOR csr_get_start_date
            IS
              SELECT ptp.start_date - 28
              FROM   per_time_periods       ptp
              WHERE ptp.payroll_id            = p_payroll_id
               AND p_effective_date    between ptp.start_date
                                             and ptp.end_date;
BEGIN

    OPEN csr_get_start_date;
    FETCH csr_get_start_date INTO p_start_date;
    CLOSE csr_get_start_date;

END start_code_4weeks_prev;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : START_CODE_HOL_YTD                                  --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : This procedure finds the start date based on the    --
--                  effective date for the dimension name _ASG_HOL_YTD  --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_effective_date       DATE                         --
--                  p_payroll_id           NUMBER                       --
--                  p_bus_grp              NUMBER                       --
--                  p_asg_action           NUMBER                       --
--            OUT : p_start_date           DATE                         --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date        Userid      Description                            --
--------------------------------------------------------------------------
-- 1.0  16-Nov-2004  snekkala    Created the procedure                  --
--------------------------------------------------------------------------
PROCEDURE start_code_hol_ytd( p_effective_date  IN         DATE
                            , p_start_date      OUT NOCOPY DATE
                            , p_payroll_id      IN         NUMBER
                            , p_bus_grp         IN         NUMBER
                            , p_asg_action      IN         NUMBER
                            )
IS
BEGIN
    p_start_date:= hr_nz_routes.anniversary_span_start(
                                            p_asg_action
                                           ,p_effective_date);

END start_code_hol_ytd;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : START_CODE_12MTHS_PREV                              --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : This procedure finds the start date based on the    --
--                  effective date for dimension _ASG_12MTHS_PREV       --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_effective_date       DATE                         --
--                  p_payroll_id           NUMBER                       --
--                  p_bus_grp              NUMBER                       --
--                  p_asg_action           NUMBER                       --
--            OUT : p_start_date           DATE                         --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date        Userid      Description                            --
--------------------------------------------------------------------------
-- 1.0  16-Nov-2004  snekkala    Created the procedure                  --
-- 2.0  30-Jul-2008  avenkatk    Modified the Start Date
--------------------------------------------------------------------------
PROCEDURE start_code_12mths_prev( p_effective_date  IN         DATE
                                , p_start_date      OUT NOCOPY DATE
                                , p_payroll_id      IN         NUMBER
                                , p_bus_grp         IN         NUMBER
                                , p_asg_action      IN         NUMBER
                                )
IS
BEGIN
    p_start_date := last_day(add_months(p_effective_date,-14)) + 1;
END start_code_12mths_prev;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : START_CODE_11MTHS_PREV                              --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : This procedure finds the start date based on the    --
--                  effective date for dimension _ASG_11MTHS_PREV       --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_effective_date       DATE                         --
--                  p_payroll_id           NUMBER                       --
--                  p_bus_grp              NUMBER                       --
--                  p_asg_action           NUMBER                       --
--            OUT : p_start_date           DATE                         --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date        Userid      Description                            --
--------------------------------------------------------------------------
-- 1.0  12-Apr-2007  dduvvuri    Created the procedure                  --
-- 1.1  27-Apr-2007  dduvvuri    Changed the code                       --
--------------------------------------------------------------------------
PROCEDURE start_code_11mths_prev( p_effective_date  IN         DATE
                                , p_start_date      OUT NOCOPY DATE
                                , p_payroll_id      IN         NUMBER
                                , p_bus_grp         IN         NUMBER
                                , p_asg_action      IN         NUMBER
                                )
IS
BEGIN

        p_start_date := last_day(add_months(p_effective_date,-12))+1;

END start_code_11mths_prev;
--
end pay_nz_exc;

/
