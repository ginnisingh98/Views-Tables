--------------------------------------------------------
--  DDL for Package PYFREXC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PYFREXC" AUTHID CURRENT_USER as
/* $Header: pyfrexc.pkh 115.1 2002/11/25 15:53:28 asnell noship $ */
/* Copyright (c) Oracle Corporation 1994. All rights reserved. */
/*
  PRODUCT
     Oracle*Payroll
  NAME
     pyfrexc.pkh - PaYroll Test FR legislation EXpiry Checking code.
  DESCRIPTION
     Contains the expiry checking code for dimensions defined in
     script pyfrbdim.sql.
  PUBLIC FUNCTIONS
     <none>
  PRIVATE FUNCTIONS
     <none>
  NOTES
     <none>
  MODIFIED (DD/MM/YY)
     asnell      22/06/00 - first created.
     asnell      25/11/02 - added nocopy to out parms
*/
/*------------------------------ ASG_RUN_EC ----------------------------*/
/*
   NAME
      ASG_RUN_EC - Assignment Run to Date expiry check.
   DESCRIPTION
      Expiry checking code for the following:
        FR Assignment-level Run To Date Balance Dimension
   NOTES
      The associtated dimension is expiry checked at payroll action level
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
) ;

/*------------------------------ ASG_PTD_EC ----------------------------*/
/*
   NAME
      ASG_PTD_EC - Assignment Processing Period to Date expiry check.
   DESCRIPTION
      Expiry checking code for the following:
        FR Assignment-level Process Period To Date Balance Dimension
   NOTES
      The associtated dimension is expiry checked at assignment action level
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
) ;

/*------------------------------ ASG_PROC_YTD_EC ----------------------------*/
/*
   NAME
      ASG_PROC_YTD_EC - Assignment Processing Year to Date expiry check.
   DESCRIPTION
      Expiry checking code for the following:
        FR Assignment-level Process Year To Date Balance Dimension
   NOTES
      The associated dimension is expiry checked at assignment action level
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
) ;

/*------------------------------ feed_month ---------------------------------*/
/*
   NAME
      feed_month - Feed only during the month specified
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
) ;

end pyfrexc;

 

/
