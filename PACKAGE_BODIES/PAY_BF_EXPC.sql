--------------------------------------------------------
--  DDL for Package Body PAY_BF_EXPC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BF_EXPC" as
/* $Header: paybfexc.pkb 115.0 1999/11/24 02:18:02 pkm ship      $ */
/* Copyright (c) Oracle Corporation 1994. All rights reserved. */

/*
  PRODUCT
     Oracle*Payroll
  NAME
     pytbfexc.pkb - PaYroll Test BF legislation EXpiry Checking code.
  DESCRIPTION
     Contains the expiry checking code that was contained as part
     of the dimensions created by pyautogn. Following the change
     to latest balance functionality, these need to be contained
     as packaged procedures.
  PUBLIC FUNCTIONS
     <none>
  PRIVATE FUNCTIONS
     <none>
  NOTES
     <none>
  MODIFIED (DD/MM/YY)
     dsaxby   13/11/96 - Added always_expires procedure.
     nbristow 25/01/96 - Year to Date expiry checking was incorrect.
     dsaxby   18/01/95 - Added arcs revision header.
     dsaxby   31/08/94 - first created.
*/

/*------------------------------ pytd_ec ------------------------------------*/
/*
   NAME
      pytd_ec - Person Tax Year To Date expiry check.
   DESCRIPTION
      Expiry checking code for the following:
        BF Person-level Tax Year to Date Balance Dimension
   NOTES
      <none>
*/
procedure pytd_ec
(
   p_owner_payroll_action_id    in     number,   -- run created balance.
   p_user_payroll_action_id     in     number,   -- current run.
   p_owner_assignment_action_id in     number,   -- assact created balance.
   p_user_assignment_action_id  in     number,   -- current assact..
   p_owner_effective_date       in     date,     -- eff date of balance.
   p_user_effective_date        in     date,     -- eff date of current run.
   p_dimension_name             in     varchar2, -- balance dimension name.
   p_expiry_information            out number    -- dimension expired flag.
) is
   l_tax_year_start date;
begin
   /*
    *  Select the start of the current tax year.
    *  Follow this by comparing the tax year
    *  start with effective date of the run
    *  that created the balance.
    *  The dimension has expired if the owner
    *  date is less than the tax year start date,
    *  (i.e. we have passed a tax year boundary).
    */
/*
   select to_date('06-04-' || to_char( to_number(
          to_char( p_owner_effective_date,'YYYY'))
             +  decode(sign( p_user_effective_date - to_date('06-04-'
                 || to_char(p_user_effective_date,'YYYY'),'DD-MM-YYYY')),
      -1,-1,0)),'DD-MM-YYYY')
   into l_tax_year_start
   from dual;
*/
   Select to_date('06-04-' || to_char( to_number(
          to_char( PTP.regular_payment_date,'YYYY'))
             +  decode(sign( PTP.regular_payment_date - to_date('06-04-'
                 || to_char(PTP.regular_payment_date,'YYYY'),'DD-MM-YYYY')),
           -1,-1,0)),'DD-MM-YYYY') finyear
   into l_tax_year_start
   from per_time_periods    PTP,
        pay_payroll_actions BACT
   where BACT.payroll_action_id = p_user_payroll_action_id
   and   PTP.time_period_id = BACT.time_period_id;

   if p_owner_effective_date >= l_tax_year_start then
      p_expiry_information := 0;
   else
      p_expiry_information := 1;
   end if;
end pytd_ec;

/*------------------------------ aytd_ec ------------------------------------*/
/*
   NAME
      aytd_ec - Assignment Tax Year To Date expiry check.
   DESCRIPTION
      Expiry checking code for the following:
        BF Assignment-level Tax Year to Date Balance Dimension
   NOTES
      The associtated dimension is expiry checked at
      Payroll Action level.
*/
procedure aytd_ec
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information            out number     -- dimension expired flag.
) is
   l_tax_year_start date;
begin
   /*
    *  Select the start of the current tax year.
    *  Follow this by comparing the tax year
    *  start with effective date of the run
    *  that created the balance.
    *  The dimension has expired if the owner
    *  date is less than the tax year start date,
    *  (i.e. we have passed a tax year boundary).
    */
/*
   select to_date('06-04-' || to_char( to_number(
          to_char( p_user_effective_date,'YYYY'))
             +  decode(sign( p_user_effective_date - to_date('06-04-'
                 || to_char(p_user_effective_date,'YYYY'),'DD-MM-YYYY')),
      -1,-1,0)),'DD-MM-YYYY')
   into l_tax_year_start
   from dual;
*/

   Select to_date('06-04-' || to_char( to_number(
          to_char( PTP.regular_payment_date,'YYYY'))
             +  decode(sign( PTP.regular_payment_date - to_date('06-04-'
                 || to_char(PTP.regular_payment_date,'YYYY'),'DD-MM-YYYY')),
           -1,-1,0)),'DD-MM-YYYY') finyear
   into l_tax_year_start
   from per_time_periods    PTP,
        pay_payroll_actions BACT
   where BACT.payroll_action_id = p_user_payroll_action_id
   and   PTP.time_period_id = BACT.time_period_id;

   if p_owner_effective_date >= l_tax_year_start then
      p_expiry_information := 0;
   else
      p_expiry_information := 1;
   end if;
end aytd_ec;

/*------------------------------ pptd_ec ------------------------------------*/
/*
   NAME
      pptd_ec - Person Period To Date Expiry Check.
   DESCRIPTION
      Expiry checking code for the following:
        BF Person-level Period to Date Balance Dimension
   NOTES
      Associated dimension is expiry checked at
      Payroll Action level.
*/
procedure pptd_ec
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information            out number     -- dimension expired flag.
) is
   l_period_start_date date;
begin
   select TP.start_date
   into   l_period_start_date
   from   per_time_periods TP,
          pay_payroll_actions PACT
   where  PACT.payroll_action_id = p_user_payroll_action_id
   and    PACT.payroll_id = TP.payroll_id
   and    p_user_effective_date between TP.start_date and TP.end_date;

   if p_owner_effective_date >= l_period_start_date then
      p_expiry_information := 0;
   else
      p_expiry_information := 1;
   end if;
end pptd_ec;

/*------------------------------ aptd_ec ------------------------------------*/
/*
   NAME
      aptd_ec - Assignment Period To Date Expiry Check.
   DESCRIPTION
      Expiry checking code for the following:
        BF Assignment-level Period to Date Balance Dimension
   NOTES
      Associated dimension is expiry checked at
      Payroll Action level.
*/
procedure aptd_ec
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information            out number     -- dimension expired flag.
) is
   l_period_start_date date;
begin
   select TP.start_date
   into   l_period_start_date
   from   per_time_periods TP,
          pay_payroll_actions PACT
   where  PACT.payroll_action_id = p_user_payroll_action_id
   and    PACT.payroll_id = TP.payroll_id
   and    p_user_effective_date between TP.start_date and TP.end_date;
   if p_owner_effective_date >= l_period_start_date then
      p_expiry_information := 0;
   else
      p_expiry_information := 1;
   end if;
end aptd_ec;

/*---------------------------- pptd_alc_ec ---------------------------------*/
/*
   NAME
      aptd_ec - Person Period To Date Assact Level Expiry Check.
   DESCRIPTION
      Expiry checking code for the following:
        BF Person-level Period to Date Balance Dimension (test)
   NOTES
      The associated dimension is expiry checked at
      Assignment Action ID level.

      This expiry checking code does access the list of
      balance context values.
*/
procedure pptd_alc_ec
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_balance_context_values     in     varchar2,  -- list of context values.
   p_expiry_information            out number     -- dimension expired flag.
) is
   l_period_start_date date;
begin
   select TP.start_date
   into   l_period_start_date
   from   per_time_periods       TP,
          pay_assignment_actions ACT,
          pay_payroll_actions    PACT
   where  ACT.assignment_action_id = p_user_assignment_action_id
   and    ACT.payroll_action_id    = PACT.payroll_action_id
   and    PACT.payroll_id          = TP.payroll_id
   and    p_user_effective_date between TP.start_date and TP.end_date;

   if p_owner_effective_date >= l_period_start_date then
      p_expiry_information := 0;
   else
      p_expiry_information := 1;
   end if;

end pptd_alc_ec;

/*-------------------------- never_expires --------------------------------*/
/*
   NAME
      never_expires - Never expires procedure.
   DESCRIPTION
      When called, always returns a value that will not cause expiry.
   NOTES
      Although this expiry check could be replaced in reality with
      the 'never expires' expiry checking level, this is left here
      to reproduce the functionality of the original tests.
*/
procedure never_expires
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information            out number     -- dimension expired flag.
) is
begin
   p_expiry_information := 0;   -- never expires.
end never_expires;

/*-------------------------- always_expires --------------------------------*/
/*
   NAME
      always_expires - Always expires procedure.
   DESCRIPTION
      Returns value that will cause expiry.
   NOTES
      This is useful for where we wish to create a balance on
      the database that is really a run level balance, but happens
      to have a dimension type of 'A' or 'P'.
*/
procedure always_expires
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information            out number     -- dimension expired flag.
) is
begin
   p_expiry_information := 1;   -- never expires.
end always_expires;

/*------------------------------ pcon_ec -----------------------------------*/
/*
   NAME
      pcon_ec - Person CONtracted in Expiry Check.
   DESCRIPTION
      Expiry checking code for the following:
        BF Person-level Contracted In YTD Balance Dimension
   NOTES
      The associated dimension is expiry checked at
      Payroll Action level.

      The associated dimension never expires, thus the
      expiry_information flag always returns (FALSE).
*/
procedure pcon_ec
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information            out number     -- dimension expired flag.
) is
   l_tax_year_start date;
begin
   select to_date('06-04-' || to_char( to_number(
          to_char( p_user_effective_date,'YYYY'))
             +  decode(sign( p_user_effective_date - to_date('06-04-'
                 || to_char(p_user_effective_date,'YYYY'),'DD-MM-YYYY')),
      -1,-1,0)),'DD-MM-YYYY')
   into l_tax_year_start
   from dual;
   if p_owner_effective_date >= l_tax_year_start then
      p_expiry_information := 0;
   else
      p_expiry_information := 1;
   end if;
end pcon_ec;

/*------------------------------ pcon_fc -----------------------------------*/
/*
   NAME
      pcon_fc - Person CONtracted in Feed Check.
   DESCRIPTION
      Feed checking code for the following:
        BF Person-level Contracted In YTD Balance Dimension
   NOTES
      <none>
*/
procedure pcon_fc
(
   p_payroll_action_id    in     number,
   p_assignment_action_id in     number,
   p_assignment_id        in     number,
   p_effective_date       in     date,
   p_dimension_name       in     varchar2,
   p_balance_contexts     in     varchar2,
   p_feed_flag            in out number
) is
   ni_status varchar2(30);
begin
   select nvl(ass_attribute1, 'CO')
   into   ni_status
   from   per_assignments_f
   where  assignment_id = p_assignment_id
   and    p_effective_date between
                effective_start_date and effective_end_date;

   if ni_status = 'CI' then
      p_feed_flag := 1;
   else
      p_feed_flag := 0;
   end if;
end pcon_fc;

end pay_bf_expc;

/
