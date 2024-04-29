--------------------------------------------------------
--  DDL for Package PYIEEXC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PYIEEXC" AUTHID CURRENT_USER as
/* $Header: pyieexc.pkh 120.0.12010000.2 2009/06/05 06:07:19 knadhan ship $ */
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
     vmkhande    16/04/03   Added expiry code for ASG_QTD
     npershad    30/10/03   Added expiry code for ASG_TWO_YTD
     rtulaban    26/05/04   Added start date code for ASG_TWO_YTD.
     knadhan     05/06/09   Created overridden procedures for all procedure for preventing
                             loss of latest balance when an baalnce adjsutment done.
                            Bug 8522294..
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
) ;

/*------------------------------ ASG_QTD_EC ----------------------------*/
/*
   NAME
      ASG_QTD_EC - Assignment-level Quater to Date expiry check.
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
) ;

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
) ;

/*------------------------------ ASG_TWO_YTD_EC -------------------------*/
/*
   NAME
      ASG_YTD_EC - Assignment Previous Year/Tax Year to Date expiry check
   DESCRIPTION
      Expiry checking code for the following:
        IE Assignment-level Previous Year/Tax Year to Date dimension
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
) ;

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
) ;
-----------------------------------------------------------------------------
-- Procedure: PROC_TWO_YTD_START
-- Description: used by TWO_YTD Dimensions for Run Level Balances only.
--    This procedure accepts a date and assignment action and other
--    params, and returns the start date of the Previous Tax Year, depending
--    on the regular payment date of the payroll action.

procedure proc_two_ytd_start
(
       p_period_type        in     varchar2 default null,
       p_effective_date     in     date     default null,
       p_start_date         out nocopy date,
       p_start_date_code    in     varchar2 default null,
       p_payroll_id         in     number,
       p_bus_grp            in     number   default null,
       p_action_type        in     varchar2 default null,
       p_asg_action         in     number
);

-----------------------------------------------------------------------------
end pyieexc;

/
