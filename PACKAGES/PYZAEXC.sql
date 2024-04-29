--------------------------------------------------------
--  DDL for Package PYZAEXC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PYZAEXC" AUTHID CURRENT_USER as
/* $Header: pyzaexc.pkh 120.1.12000000.1 2007/01/18 03:29:32 appldev noship $ */

procedure ASG_TAX_YTD_EC
   (
      p_owner_payroll_action_id    in     number,    -- run created balance.
      p_user_payroll_action_id     in     number,    -- current run.
      p_owner_assignment_action_id in     number,    -- assact created balance.
      p_user_assignment_action_id  in     number,    -- current assact..
      p_owner_effective_date       in     date,      -- eff date of balance.
      p_user_effective_date        in     date,      -- eff date of current run.
      p_dimension_name             in     varchar2,  -- balance dimension name.
      p_expiry_information            out nocopy number     -- dimension expired flag.
   );
--
procedure ASG_TAX_YTD_EC
   (
      p_owner_payroll_action_id    in     number,    -- run created balance.
      p_user_payroll_action_id     in     number,    -- current run.
      p_owner_assignment_action_id in     number,    -- assact created balance.
      p_user_assignment_action_id  in     number,    -- current assact..
      p_owner_effective_date       in     date,      -- eff date of balance.
      p_user_effective_date        in     date,      -- eff date of current run.
      p_dimension_name             in     varchar2,  -- balance dimension name.
      p_expiry_information            out nocopy date     -- dimension expired date.
   );

procedure ASG_CAL_YTD_EC
   (
      p_owner_payroll_action_id    in     number,    -- run created balance.
      p_user_payroll_action_id     in     number,    -- current run.
      p_owner_assignment_action_id in     number,    -- assact created balance.
      p_user_assignment_action_id  in     number,    -- current assact..
      p_owner_effective_date       in     date,      -- eff date of balance.
      p_user_effective_date        in     date,      -- eff date of current run.
      p_dimension_name             in     varchar2,  -- balance dimension name.
      p_expiry_information            out nocopy number     -- dimension expired flag.
   );
--
procedure ASG_CAL_YTD_EC
   (
      p_owner_payroll_action_id    in     number,    -- run created balance.
      p_user_payroll_action_id     in     number,    -- current run.
      p_owner_assignment_action_id in     number,    -- assact created balance.
      p_user_assignment_action_id  in     number,    -- current assact..
      p_owner_effective_date       in     date,      -- eff date of balance.
      p_user_effective_date        in     date,      -- eff date of current run.
      p_dimension_name             in     varchar2,  -- balance dimension name.
      p_expiry_information            out nocopy date     -- dimension expired date.
   );
--
procedure ASG_TAX_QTD_EC
   (
      p_owner_payroll_action_id    in     number,    -- run created balance.
      p_user_payroll_action_id     in     number,    -- current run.
      p_owner_assignment_action_id in     number,    -- assact created balance.
      p_user_assignment_action_id  in     number,    -- current assact..
      p_owner_effective_date       in     date,      -- eff date of balance.
      p_user_effective_date        in     date,      -- eff date of current run.
      p_dimension_name             in     varchar2,  -- balance dimension name.
      p_expiry_information            out nocopy number     -- dimension expired flag.
   );
--
procedure ASG_TAX_QTD_EC
   (
      p_owner_payroll_action_id    in     number,    -- run created balance.
      p_user_payroll_action_id     in     number,    -- current run.
      p_owner_assignment_action_id in     number,    -- assact created balance.
      p_user_assignment_action_id  in     number,    -- current assact..
      p_owner_effective_date       in     date,      -- eff date of balance.
      p_user_effective_date        in     date,      -- eff date of current run.
      p_dimension_name             in     varchar2,  -- balance dimension name.
      p_expiry_information            out nocopy date     -- dimension expired date.
   );
--
procedure ASG_MTD_EC
   (
      p_owner_payroll_action_id    in     number,    -- run created balance.
      p_user_payroll_action_id     in     number,    -- current run.
      p_owner_assignment_action_id in     number,    -- assact created balance.
      p_user_assignment_action_id  in     number,    -- current assact..
      p_owner_effective_date       in     date,      -- eff date of balance.
      p_user_effective_date        in     date,      -- eff date of current run.
      p_dimension_name             in     varchar2,  -- balance dimension name.
      p_expiry_information            out nocopy number     -- dimension expired flag.
   );
--
procedure ASG_MTD_EC
   (
      p_owner_payroll_action_id    in     number,    -- run created balance.
      p_user_payroll_action_id     in     number,    -- current run.
      p_owner_assignment_action_id in     number,    -- assact created balance.
      p_user_assignment_action_id  in     number,    -- current assact..
      p_owner_effective_date       in     date,      -- eff date of balance.
      p_user_effective_date        in     date,      -- eff date of current run.
      p_dimension_name             in     varchar2,  -- balance dimension name.
      p_expiry_information            out nocopy date     --dimension expired date.
   );
--
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
   );
--
procedure ASG_PTD_EC
   (
      p_owner_payroll_action_id    in     number,    -- run created balance.
      p_user_payroll_action_id     in     number,    -- current run.
      p_owner_assignment_action_id in     number,    -- assact created balance.
      p_user_assignment_action_id  in     number,    -- current assact..
      p_owner_effective_date       in     date,      -- eff date of balance.
      p_user_effective_date        in     date,      -- eff date of current run.
      p_dimension_name             in     varchar2,  -- balance dimension name.
      p_expiry_information            out nocopy date     -- dimension expired date.
   );
--

end pyzaexc;

 

/
