--------------------------------------------------------
--  DDL for Package Body PYIEEXC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PYIEEXC" as
/* $Header: pyieexc.pkb 120.2.12010000.2 2009/06/05 06:06:23 knadhan ship $ */
/* Copyright (c) Oracle Corporation 1994. ll rights reserved. */
/*
  PRODUCT
     Oracle*Payroll
  NAME
     pyieexc.pkb - PaYroll IE legislation EXpiry Checking code.
  DESCRIPTION
     Contains the expiry checking code for the balance dimensions
     created for IRELAND.
  PUBLIC FUNCTIONS
     <none>
  PRIVATE FUNCTIONS
     <none>
  NOTES
     expiry checking has been made much simpler than the dimensions it
     supports by the imposition of 2 rules:
       1) on payroll transfer latest balances are trashed ( so we don't
          need to check for the date of transfer etc we need only worry
          about the start date of the current payroll period and payroll
          year.
       2) legislative balances rely on the regular payment date of the period
          to dictate the legislative poeriod they fall into - you can't transfer
          onto a payroll until the new payrolls period regular payment date is
          after the regular payment date of the last period processed. This
          supports the rule that you can't transfer from a longer processing
          period to a shorter one until the end of the longer period.

  MODIFIED (DD/MM/YY)
     rmakhija 15/06/01 - first created by editing similar package of GB Localization.
     abhaduri    16/04/02 - added ASG_PROC_PTD_EC procedure for new dimension
                            _ELEMENT_PTD for Attachment of Earnings Order.
     smrobins    30/09/02 -  changed ASG_YTD_EC procedure, to derive expiry
                             from effective date of action, rather than
                             regular payment date.
     mmahmad     24/01/03 -  Added NOCOPY
     vmkhande    16/04/03    Added expiry code for ASG_QTD
     npershad    30/10/03   Added expiry code for ASG_TWO_YTD
     rtulaban    26/05/04   Added start date code for ASG_TWO_YTD
     rbhardwa    01/03/06   Made changes to accomodate offset payrolls.
                            Bug 5070091.
     knadhan     05/06/09   Created overridden procedures for all procedure for preventing
                             loss of latest balance when an baalnce adjsutment done.
                            Bug 8522294.
*/
/*------------------------------ ASG_PTD_EC ----------------------------*/
/*
   NAME
      ASG_PTD_EC - Assignment Period to Date expiry check.
   DESCRIPTION
      Expiry checking code for the following:
        IE Assignment-level Period To Date Balance Dimension
   NOTES
      The associated dimension is expiry checked at assignment action level
*/

/* 8522294 */
FUNCTION next_period
(
   p_pactid      IN  NUMBER,
   p_date        IN  DATE
) RETURN DATE is
   l_return_val DATE := NULL;
BEGIN
   select TP.end_date + 1
   into   l_return_val
   from   per_time_periods TP,
          pay_payroll_actions PACT
   where  PACT.payroll_action_id = p_pactid
   and    PACT.payroll_id = TP.payroll_id
   and    p_date between TP.start_date and TP.end_date;

   RETURN l_return_val;

END next_period;

FUNCTION next_quarter
(
   p_date        IN  DATE
) RETURN DATE is
BEGIN

  RETURN trunc(add_months(p_date,3),'Q');

END next_quarter;


FUNCTION next_year
(
   p_date        IN  DATE
) RETURN DATE is
BEGIN

  RETURN trunc(add_months(p_date,12),'Y');

END next_year;

FUNCTION next_two_year
(
   p_date        IN  DATE
) RETURN DATE is
BEGIN

  RETURN trunc(add_months(p_date,24),'Y');

END next_two_year;

procedure ASG_PTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out NOCOPY  number     -- dimension expired flag.
) is
l_period_start_date date;
begin
   select ptp.start_date
   into   l_period_start_date
   from   per_time_periods ptp, pay_payroll_actions ppa
   where  ppa.payroll_action_id = p_user_payroll_action_id
   and    ppa.payroll_id = ptp.payroll_id
   and    p_user_effective_date between ptp.start_date and ptp.end_date;
   -- see if balance was written in this period. If not it is expired
   IF p_owner_effective_date >= l_period_start_date THEN
      p_expiry_information := 0;
   ELSE
      p_expiry_information := 1;
   END IF;
end ASG_PTD_EC;

/* 8522294 */
procedure ASG_PTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out NOCOPY  date     -- dimension expired flag.
) is
l_period_start_date date;
begin
  hr_utility.set_location('k:p_owner_payroll_action_id ' || p_owner_payroll_action_id,10);
  hr_utility.set_location('k:p_user_payroll_action_id ' || p_user_payroll_action_id,20);
  hr_utility.set_location('k:p_owner_assignment_action_id ' || p_owner_assignment_action_id,30);
  hr_utility.set_location('k:p_user_assignment_action_id ' || p_user_assignment_action_id,40);
  hr_utility.set_location('k:p_user_effective_date ' || to_char(p_user_effective_date,'dd-mon-yyyy'),50);
  hr_utility.set_location('k:p_owner_effective_date ' || to_char(p_owner_effective_date,'dd-mon-yyyy'),60);
  hr_utility.set_location('k:p_dimension_name ' || p_dimension_name,70);
   p_expiry_information  := next_period(p_owner_payroll_action_id,
                                 p_owner_effective_date) -  1;

  hr_utility.set_location('k:p_expiry_information ' || to_char(p_expiry_information,'dd-mon-yyyy'),70);
end ASG_PTD_EC;

/*------------------------------ ASG_YTD_EC ----------------------------*/
/*
   NAME
      ASG_YTD_EC - Assignment Tax Year to Date expiry check.
   DESCRIPTION
      Expiry checking code for the following:
        IE Assignment-level Tax Year To Date Balance Dimension
   NOTES
      The associated dimension is expiry checked at assignment action level
*/
procedure ASG_YTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out NOCOPY  number     -- dimension expired flag.
) is
   l_tax_year_start  date;
   l_user_payroll_id number;
begin
   /* select the start of the financial year - if the owning action is
    * before this or for a different payroll then its expired
   */
   Select to_date('01-01-' || to_char( fnd_number.canonical_to_number(
          to_char( BACT.effective_date,'YYYY'))
             +  decode(sign( BACT.effective_date - to_date('01-01-'
                 || to_char(BACT.effective_date,'YYYY'),'DD-MM-YYYY')),
           -1,-1,0)),'DD-MM-YYYY') finyear, BACT.payroll_id
   into l_tax_year_start, l_user_payroll_id
   from  pay_payroll_actions BACT
   where BACT.payroll_action_id = p_user_payroll_action_id;
--
--
   if p_owner_effective_date < l_tax_year_start then
      p_expiry_information := 1;
   else
      p_expiry_information := 0;
   end if;
--

end ASG_YTD_EC;

/* 8522294 */

procedure ASG_YTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out NOCOPY  date     -- dimension expired flag.
) is
   l_tax_year_start  date;
   l_user_payroll_id number;
begin
  hr_utility.set_location('k:p_owner_payroll_action_id ' || p_owner_payroll_action_id,10);
  hr_utility.set_location('k:p_user_payroll_action_id ' || p_user_payroll_action_id,20);
  hr_utility.set_location('k:p_owner_assignment_action_id ' || p_owner_assignment_action_id,30);
  hr_utility.set_location('k:p_user_assignment_action_id ' || p_user_assignment_action_id,40);
  hr_utility.set_location('k:p_user_effective_date ' || to_char(p_user_effective_date,'dd-mon-yyyy'),50);
  hr_utility.set_location('k:p_owner_effective_date ' || to_char(p_owner_effective_date,'dd-mon-yyyy'),60);
  hr_utility.set_location('k:p_dimension_name ' || p_dimension_name,70);
   p_expiry_information  := next_year(p_owner_effective_date) -1;

 hr_utility.set_location('k:p_expiry_information ' || to_char(p_expiry_information,'dd-mon-yyyy'),70);

end ASG_YTD_EC;

/*------------------------------ ASG_PROC_PTD_EC ----------------------------*/
/*
   NAME
      ASG_PROC_PTD_EC - Assignment Processing Period to Date expiry check.
   DESCRIPTION
      Expiry checking code for the following:
        IE Assignment-level Process Period To Date Balance Dimension
   NOTES
      The associated dimension is expiry checked at payroll action level
*/
procedure ASG_PROC_PTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out NOCOPY  number     -- dimension expired flag.
) is
   l_user_time_period_id number;
   l_owner_time_period_id number;
begin
   /*
    *  Select the period of the owning and using action and if they are
    *  the same then the dimension has expired - either a prior period
    *  or a different payroll
    */

   select time_period_id
   into l_user_time_period_id
   from pay_payroll_actions
   where payroll_action_id = p_user_payroll_action_id;

   select time_period_id
   into l_owner_time_period_id
   from pay_payroll_actions
   where payroll_action_id = p_owner_payroll_action_id;

   if l_user_time_period_id = l_owner_time_period_id then
      p_expiry_information := 0;
   else
      p_expiry_information := 1;
   end if;

end ASG_PROC_PTD_EC;

/* 8522294 */

procedure ASG_PROC_PTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out NOCOPY  date     -- dimension expired flag.
) is
   l_user_time_period_id number;
   l_owner_time_period_id number;
begin
  hr_utility.set_location('k:p_owner_payroll_action_id ' || p_owner_payroll_action_id,10);
  hr_utility.set_location('k:p_user_payroll_action_id ' || p_user_payroll_action_id,20);
  hr_utility.set_location('k:p_owner_assignment_action_id ' || p_owner_assignment_action_id,30);
  hr_utility.set_location('k:p_user_assignment_action_id ' || p_user_assignment_action_id,40);
  hr_utility.set_location('k:p_user_effective_date ' || to_char(p_user_effective_date,'dd-mon-yyyy'),50);
  hr_utility.set_location('k:p_owner_effective_date ' || to_char(p_owner_effective_date,'dd-mon-yyyy'),60);
  hr_utility.set_location('k:p_dimension_name ' || p_dimension_name,70);

p_expiry_information  := next_period(p_owner_payroll_action_id,
                                 p_owner_effective_date) -  1;
  hr_utility.set_location('k:p_expiry_information ' || to_char(p_expiry_information,'dd-mon-yyyy'),70);
end ASG_PROC_PTD_EC;
/*------------------------------ ASG_QTD_EC ----------------------------*/
/*
   NAME
      ASG_QTD_EC - Assignment Quater to Date expiry check.
   DESCRIPTION
      Expiry checking code for the following:
        IE Assignment-level Quater To Date Balance Dimension
   NOTES
      The associated dimension is expiry checked at assignment action level
*/
procedure ASG_QTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out NOCOPY  number     -- dimension expired flag.
) is
begin
  hr_utility.trace('p_user_effective_date ' || to_char(p_user_effective_date,'dd-mon-yyyy'));
  hr_utility.trace('p_owner_effective_date ' || to_char(p_owner_effective_date,'dd-mon-yyyy'));
  IF p_user_effective_date >= trunc(add_months(p_owner_effective_date,3),'Q')
    THEN
    hr_utility.trace(' 1 ');
    P_expiry_information := 1; -- Expired!
  ELSE
    hr_utility.trace(' 0 ');
    P_expiry_information := 0; -- OK!
  END IF;
end ASG_QTD_EC;

/* 8522294 */
procedure ASG_QTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out NOCOPY  date     -- dimension expired flag.
) is
begin
  hr_utility.set_location('k:p_owner_payroll_action_id ' || p_owner_payroll_action_id,10);
  hr_utility.set_location('k:p_user_payroll_action_id ' || p_user_payroll_action_id,20);
  hr_utility.set_location('k:p_owner_assignment_action_id ' || p_owner_assignment_action_id,30);
  hr_utility.set_location('k:p_user_assignment_action_id ' || p_user_assignment_action_id,40);
  hr_utility.set_location('k:p_user_effective_date ' || to_char(p_user_effective_date,'dd-mon-yyyy'),50);
  hr_utility.set_location('k:p_owner_effective_date ' || to_char(p_owner_effective_date,'dd-mon-yyyy'),60);
  hr_utility.set_location('k:p_dimension_name ' || p_dimension_name,70);
  p_expiry_information  := next_quarter(p_owner_effective_date) - 1;

  hr_utility.set_location('k:p_expiry_information ' || to_char(p_expiry_information,'dd-mon-yyyy'),70);
end ASG_QTD_EC;
/*------------------------------ ASG_TWO_YTD_EC ----------------------------*/
/*
   NAME
      ASG_TWO_YTD_EC - Assignment Tax Year/Previous Year to Date expiry check.
   DESCRIPTION
      Expiry checking code for the following:
        IE Assignment-level Tax Year/Previous Year To Date Balance Dimension
   NOTES
      The associated dimension is expiry checked at assignment action level
*/
procedure ASG_TWO_YTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out NOCOPY  number     -- dimension expired flag.
) is
   l_tax_year_start  date;
   l_user_payroll_id number;
begin
   /* select the start of the financial year - if the owning action is
    * before this or for a different payroll then its expired
   */
   Select to_date('01-01-' || to_char((fnd_number.canonical_to_number(
          to_char( BACT.effective_date,'YYYY')) - 1)
             +  decode(sign( BACT.effective_date - to_date('01-01-'
                 || to_char(BACT.effective_date,'YYYY'),'DD-MM-YYYY')),
           -1,-1,0)),'DD-MM-YYYY') finyear, BACT.payroll_id
   into l_tax_year_start, l_user_payroll_id
   from  pay_payroll_actions BACT
   where BACT.payroll_action_id = p_user_payroll_action_id;
--
--
   if p_owner_effective_date < l_tax_year_start then
      p_expiry_information := 1;
   else
      p_expiry_information := 0;
   end if;
--

end ASG_TWO_YTD_EC;

/* 8522294 */

procedure ASG_TWO_YTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out NOCOPY  date     -- dimension expired flag.
) is
   l_tax_year_start  date;
   l_user_payroll_id number;
begin
  hr_utility.set_location('k:p_owner_payroll_action_id ' || p_owner_payroll_action_id,10);
  hr_utility.set_location('k:p_user_payroll_action_id ' || p_user_payroll_action_id,20);
  hr_utility.set_location('k:p_owner_assignment_action_id ' || p_owner_assignment_action_id,30);
  hr_utility.set_location('k:p_user_assignment_action_id ' || p_user_assignment_action_id,40);
  hr_utility.set_location('k:p_user_effective_date ' || to_char(p_user_effective_date,'dd-mon-yyyy'),50);
  hr_utility.set_location('k:p_owner_effective_date ' || to_char(p_owner_effective_date,'dd-mon-yyyy'),60);
  hr_utility.set_location('k:p_dimension_name ' || p_dimension_name,70);
  p_expiry_information  := next_two_year(p_owner_effective_date) -1;

  hr_utility.set_location('k:p_expiry_information ' || to_char(p_expiry_information,'dd-mon-yyyy'),70);

end ASG_TWO_YTD_EC;
----------------------------------------------------------------------------
-- Procedure: PROC_TWO_YTD_START
-- Description: used by TWO_YTD Dimensions for Run Level Balances only.
--    This procedure accepts a date and assignment action and other
--    params, and returns the start date of the Previous Tax Year, depending
--    on the regular payment date of the payroll action.

procedure proc_two_ytd_start(p_period_type    in      varchar2 default null,
                         p_effective_date     in      date     default null,
                         p_start_date         out nocopy date,
                         p_start_date_code    in      varchar2 default null,
                         p_payroll_id         in      number,
                         p_bus_grp            in      number   default null,
                         p_action_type        in      varchar2 default null,
                         p_asg_action         in      number)
is
l_tax_year_start date;
begin
    select to_date('01-01-' || to_char(( fnd_number.canonical_to_number(
          to_char( PPA.effective_date,'YYYY'))- 1)                              -- Bug 5070091 Offset payroll change
             +  decode(sign( PPA.effective_date - to_date('01-01-'
                 || to_char(PPA.effective_date,'YYYY'),'DD-MM-YYYY')),
           -1,-1,0)),'DD-MM-YYYY') finyear
      into l_tax_year_start
   from --per_time_periods    PTP,
        pay_payroll_actions ppa,
        pay_assignment_actions paa
   where ppa.payroll_action_id = paa.payroll_action_id
   and   paa.assignment_action_id = p_asg_action
   and   ppa.payroll_id = p_payroll_id;
 --  and   PTP.time_period_id = ppa.time_period_id;
--
  p_start_date := l_tax_year_start;
--
end proc_two_ytd_start;
----------------------------------------------------------------------------


end pyieexc;

/
