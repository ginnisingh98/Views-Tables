--------------------------------------------------------
--  DDL for Package Body PAY_PYIEEXC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PYIEEXC" as
/* $Header: pyieexc.pkb 115.5 2003/01/28 10:14:34 mmahmad ship $ */
/* Copyright (c) Oracle Corporation 1994. All rights reserved. */
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

--------------------------------------------------------------

end pay_pyieexc;

/
