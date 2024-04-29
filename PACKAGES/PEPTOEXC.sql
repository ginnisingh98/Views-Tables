--------------------------------------------------------
--  DDL for Package PEPTOEXC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PEPTOEXC" AUTHID CURRENT_USER as
/* $Header: peptoexc.pkh 115.4 2004/01/16 08:41:41 dcasemor noship $ */

/*
 * The following are expiry checking procedures
 * for date paid balances used by pto accruals
 */

/*------------------------------ ASG_PTO_YTD_EC ----------------------------*/
/*
   NAME
      ASG_PTO_YTD_EC - Assignment Processing Year to Date expiry check.
   DESCRIPTION
   NOTES
      The associated dimension is expiry checked at payroll action level
*/
--
-- This is the flag-based expiry routine.
--
procedure ASG_PTO_YTD_EC
(
   p_owner_payroll_action_id    in         number,    -- run created balance.
   p_user_payroll_action_id     in         number,    -- current run.
   p_owner_assignment_action_id in         number,    -- assact created balance.
   p_user_assignment_action_id  in         number,    -- current assact.
   p_owner_effective_date       in         date,      -- eff date of balance.
   p_user_effective_date        in         date,      -- eff date of current run.
   p_dimension_name             in         varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy number     -- dimension expired flag.
);

--
-- This is the overloaded date-based expiry routine.
--
procedure ASG_PTO_YTD_EC
(
   p_owner_payroll_action_id    in         number,    -- run created balance.
   p_user_payroll_action_id     in         number,    -- current run.
   p_owner_assignment_action_id in         number,    -- assact created balance.
   p_user_assignment_action_id  in         number,    -- current assact.
   p_owner_effective_date       in         date,      -- eff date of balance.
   p_user_effective_date        in         date,      -- eff date of current run.
   p_dimension_name             in         varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy date       -- dimension expired date.
);

/*------------------------------ ASG_PTO_TTD_EC ----------------------------*/
/*
   NAME
      ASG_PTO_TTD_EC - Assignment Processing Term to Date expiry check.
   DESCRIPTION
   NOTES
      The associated dimension is expiry checked at payroll action level.
*/
--
-- This is the flag-based expiry routine.
--
procedure ASG_PTO_TTD_EC
(
   p_owner_payroll_action_id    in         number,   -- run created balance.
   p_user_payroll_action_id     in         number,   -- current run.
   p_owner_assignment_action_id in         number,   -- assact created balance.
   p_user_assignment_action_id  in         number,   -- current assact.
   p_owner_effective_date       in         date,     -- eff date of balance.
   p_user_effective_date        in         date,     -- eff date of current run.
   p_dimension_name             in         varchar2, -- balance dimension name.
   p_expiry_information         out nocopy number    -- dimension expired flag.
);

--
-- This is the overloaded date-based expiry routine.
--
procedure ASG_PTO_TTD_EC
(
   p_owner_payroll_action_id    in         number,    -- run created balance.
   p_user_payroll_action_id     in         number,    -- current run.
   p_owner_assignment_action_id in         number,    -- assact created balance.
   p_user_assignment_action_id  in         number,    -- current assact.
   p_owner_effective_date       in         date,      -- eff date of balance.
   p_user_effective_date        in         date,      -- eff date of current run.
   p_dimension_name             in         varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy date       -- dimension expired date.
);

/*-------------------------- ASG_PTO_HD_YTD_EC ----------------------------*/
/*
   NAME
      ASG_PTO_HD_YTD_EC - Assignment Processing Year to Date expiry check.
   DESCRIPTION
   NOTES
      The associated dimension is expiry checked at payroll action level
*/
--
-- This is the flag-based expiry routine.
--
procedure ASG_PTO_HD_YTD_EC
(
   p_owner_payroll_action_id    in         number,    -- run created balance.
   p_user_payroll_action_id     in         number,    -- current run.
   p_owner_assignment_action_id in         number,    -- assact created balance.
   p_user_assignment_action_id  in         number,    -- current assact.
   p_owner_effective_date       in         date,      -- eff date of balance.
   p_user_effective_date        in         date,      -- eff date of current run.
   p_dimension_name             in         varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy number     -- dimension expired flag.
);

--
-- This is the overloaded date-based expiry routine.
--
procedure ASG_PTO_HD_YTD_EC
(
   p_owner_payroll_action_id    in         number,    -- run created balance.
   p_user_payroll_action_id     in         number,    -- current run.
   p_owner_assignment_action_id in         number,    -- assact created balance.
   p_user_assignment_action_id  in         number,    -- current assact.
   p_owner_effective_date       in         date,      -- eff date of balance.
   p_user_effective_date        in         date,      -- eff date of current run.
   p_dimension_name             in         varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy date       -- dimension expired date.
);

/*
 * The following are expiry checking procedures
 * for date earned balances used by pto accruals
 */

/*------------------------------ ASG_PTO_DE_YTD_EC ----------------------------*/
/*
   NAME
      ASG_PTO_DE_YTD_EC - Assignment Processing Year to Date expiry check.
   DESCRIPTION
      Used to check expiry of seeded date earned balance in
      PTO accruals, for a one year plan beginning 01/01.
*/
--
-- This is the flag-based expiry routine.
--
procedure ASG_PTO_DE_YTD_EC
(
   p_owner_payroll_action_id    in         number,    -- run created balance.
   p_user_payroll_action_id     in         number,    -- current run.
   p_owner_assignment_action_id in         number,    -- assact created balance.
   p_user_assignment_action_id  in         number,    -- current assact.
   p_owner_effective_date       in         date,      -- eff date of balance.
   p_user_effective_date        in         date,      -- eff date of current run.
   p_dimension_name             in         varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy number     -- dimension expired flag.
);

--
-- This is the overloaded date-based expiry routine.
--
procedure ASG_PTO_DE_YTD_EC
(
   p_owner_payroll_action_id    in         number,    -- run created balance.
   p_user_payroll_action_id     in         number,    -- current run.
   p_owner_assignment_action_id in         number,    -- assact created balance.
   p_user_assignment_action_id  in         number,    -- current assact.
   p_owner_effective_date       in         date,      -- eff date of balance.
   p_user_effective_date        in         date,      -- eff date of current run.
   p_dimension_name             in         varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy date       -- dimension expired date.
);

/*------------------------------ ASG_PTO_DE_SM_YTD_EC ----------------------------*/
/*
   NAME
      ASG_PTO_DE_SM_YTD_EC - Assignment Processing Year to Date expiry check.
   DESCRIPTION
      Used to check expiry of seeded date earned balance in PTO accruals, for our
      simple multiplier plan, beginning 01/06 each year.
*/
--
-- This is the flag-based expiry routine.
--
procedure ASG_PTO_DE_SM_YTD_EC
(
   p_owner_payroll_action_id    in         number,    -- run created balance.
   p_user_payroll_action_id     in         number,    -- current run.
   p_owner_assignment_action_id in         number,    -- assact created balance.
   p_user_assignment_action_id  in         number,    -- current assact.
   p_owner_effective_date       in         date,      -- eff date of balance.
   p_user_effective_date        in         date,      -- eff date of current run.
   p_dimension_name             in         varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy number     -- dimension expired flag.
);

--
-- This is the overloaded date-based expiry routine.
--
procedure ASG_PTO_DE_SM_YTD_EC
(
   p_owner_payroll_action_id    in         number,    -- run created balance.
   p_user_payroll_action_id     in         number,    -- current run.
   p_owner_assignment_action_id in         number,    -- assact created balance.
   p_user_assignment_action_id  in         number,    -- current assact.
   p_owner_effective_date       in         date,      -- eff date of balance.
   p_user_effective_date        in         date,      -- eff date of current run.
   p_dimension_name             in         varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy date       -- dimension expired date.
);

/*------------------------------ ASG_PTO_DE_HD_YTD_EC ------------------------*/
/*
   NAME
      ASG_PTO_DE_HD_YTD_EC - Assignment Processing Year to Date expiry check.
   DESCRIPTION
      Used to check expiry of seeded date earned balance in PTO accruals, for a
      hire date anniversary accrual plan.
*/
--
-- This is the flag-based expiry routine.
--
procedure ASG_PTO_DE_HD_YTD_EC
(
   p_owner_payroll_action_id    in         number,    -- run created balance.
   p_user_payroll_action_id     in         number,    -- current run.
   p_owner_assignment_action_id in         number,    -- assact created balance.
   p_user_assignment_action_id  in         number,    -- current assact.
   p_owner_effective_date       in         date,      -- eff date of balance.
   p_user_effective_date        in         date,      -- eff date of current run.
   p_dimension_name             in         varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy number     -- dimension expired flag.
);

--
-- This is the overloaded date-based expiry routine.
--
procedure ASG_PTO_DE_HD_YTD_EC
(
   p_owner_payroll_action_id    in         number,    -- run created balance.
   p_user_payroll_action_id     in         number,    -- current run.
   p_owner_assignment_action_id in         number,    -- assact created balance.
   p_user_assignment_action_id  in         number,    -- current assact.
   p_owner_effective_date       in         date,      -- eff date of balance.
   p_user_effective_date        in         date,      -- eff date of current run.
   p_dimension_name             in         varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy date       -- dimension expired date.
);

end peptoexc;

 

/
