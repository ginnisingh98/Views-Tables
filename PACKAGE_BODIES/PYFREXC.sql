--------------------------------------------------------
--  DDL for Package Body PYFREXC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PYFREXC" as
/* $Header: pyfrexc.pkb 115.2 2002/11/28 18:00:26 asnell noship $ */
/* Copyright (c) Oracle Corporation 1994. All rights reserved. */
/*
  PRODUCT
     Oracle*Payroll
  NAME
     pyfrexc.pkb - PaYroll Test FR legislation EXpiry Checking code.
  DESCRIPTION
     Contains the expiry checking code that was contained as part
     of the dimensions created by pyfrbdim.sql.
  PUBLIC FUNCTIONS
     <none>
  PRIVATE FUNCTIONS
     <none>
  NOTES
     based on UK package pyfrexc.pkb

  MODIFIED (DD/MM/YY)
     asnell   21/06/00 - first created.
     asnell   25/11/02 - added nocopy to out parms
     asnell   28/11/02 - bug 2352944 changes keep expiry code in step
                         with route changes
*/
/*------------------------------ ASG_RUN_EC ----------------------------*/
/*
   NAME
      ASG_RUN_EC - Assignment Run to Date expiry check.
   DESCRIPTION
      Expiry checking code for the following:
        FR Assignment-level Run To Date Balance Dimension
   NOTES
      The associated dimension is expiry checked at payroll action level
*/
procedure ASG_RUN_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information            out nocopy number     -- dimension expired flag.
) is

begin
   if p_user_payroll_action_id = p_owner_payroll_action_id then
      p_expiry_information := 0;
   else
      p_expiry_information := 1;
   end if;

end ASG_RUN_EC;

/*------------------------------ ASG_PROC_PTD_EC ----------------------------*/
/*
   NAME
      ASG_PTD_EC - Assignment Processing Period to Date expiry check.
   DESCRIPTION
      Expiry checking code for the following:
        FR Assignment-level Process Period To Date Balance Dimension
   NOTES
      The associated dimension is expiry checked at payroll action level
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
   p_expiry_information            out nocopy number     -- dimension expired flag.
) is
begin

   if p_owner_effective_date >= trunc(p_user_effective_date,'MM') then
      p_expiry_information := 0;
   else
      p_expiry_information := 1;
   end if;

end ASG_PTD_EC;

/*------------------------------ ASG_PROC_YTD_EC ----------------------------*/
/*
   NAME
      ASG_YTD_EC - Assignment Processing Year to Date expiry check.
   DESCRIPTION
      Expiry checking code for the following:
        FR Assignment-level Process Year To Date Balance Dimension
   NOTES
      The associated dimension is expiry checked at payroll action level
*/
procedure ASG_PROC_YTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information            out nocopy number     -- dimension expired flag.
) is

begin
--
   if p_owner_effective_date >= trunc(p_user_effective_date,'Y') then
      p_expiry_information := 0;
   else
      p_expiry_information := 1;
   end if;

end ASG_PROC_YTD_EC;
/*------------------------------ feed_month ---------------------------------*/
/*
   NAME
      feed_month - only feed in the correct month for the dimension
   DESCRIPTION
      Feed checking code for the following:
        FR ASG Month
   NOTES
      <none>
*/
procedure feed_month
(
   p_payroll_action_id    in     number,
   p_assignment_action_id in     number,
   p_assignment_id        in     number,
   p_effective_date       in     date,
   p_dimension_name       in     varchar2,
   p_balance_contexts     in     varchar2,
   p_feed_flag            in out nocopy number
) is

begin
   hr_utility.trace('feed checking p_balance_contexts:'||p_balance_contexts);

-- this code is called from all the month dimensions. So extract
-- the month number from the dimension name and check against
-- cached month
  if trunc(p_effective_date,'MM') = substr(p_dimension_name,32,2) then p_feed_flag := 1;
                                                else p_feed_flag := 0;
  end if;

end feed_month;

end pyfrexc;

/
