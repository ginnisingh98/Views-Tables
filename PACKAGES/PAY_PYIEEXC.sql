--------------------------------------------------------
--  DDL for Package PAY_PYIEEXC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PYIEEXC" AUTHID CURRENT_USER as
/* $Header: pyieexc.pkh 115.4 2003/01/28 10:14:55 mmahmad ship $ */
/* Copyright (c) Oracle Corporation 1994. All rights reserved. */
/*
  PRODUCT
     Oracle*Payroll
  NAME
     pyieexc.pkh - PaYroll Test IE legislation EXpiry Checking code.
  DESCRIPTION
     Contains the expiry checking code for the balance dimensions
     created for IRELAND.
  PUBLIC FUNCTIONS
     <none>
  PRIVATE FUNCTIONS
     <none>
  NOTES
     <none>
  MODIFIED (DD/MM/YY)
     rmakhija    15/06/01 - first created by editing similar package of GB localization.
     abhaduri    16/04/02 - added ASG_PROC_PTD_EC procedure for new dimension
                            _ELEMENT_PTD for Attachment of Earnings Order.
     mmahmad     24/01/03   Added NOCOPY
*/
/*------------------------------ ASG_PTD_EC ----------------------------*/
/*
   NAME
      ASG_PTD_EC - Assignment-level Period to Date expiry check.
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
) ;

/*------------------------------ ASG_YTD_EC -------------------------*/
/*
   NAME
      ASG_YTD_EC - Assignment Tax Year to Date expiry check
   DESCRIPTION
      Expiry checking code for the following:
        IE Assignment-level Tax Year to Date dimension
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
) ;

/*------------------------------ ASG_PROC_PTD_EC ----------------------------*/
/*
   NAME
      ASG_PROC_PTD_EC - Assignment Processing Period to Date expiry check.
   DESCRIPTION
      Expiry checking code for the following:
        IE Element-level Process Period To Date Balance Dimension
   NOTES
      The associtated dimension is expiry checked at payroll action level
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
) ;
-----------------------------------------------------------------------------

end pay_pyieexc;

 

/
