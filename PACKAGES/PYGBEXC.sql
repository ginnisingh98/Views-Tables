--------------------------------------------------------
--  DDL for Package PYGBEXC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PYGBEXC" AUTHID CURRENT_USER as
/* $Header: pygbexc.pkh 120.0.12010000.3 2009/07/30 09:42:44 jvaradra ship $ */
/*------------------------------ ASG_RUN_EC ----------------------------*/
/*
   NAME
      ASG_RUN_EC - Assignment Run to Date expiry check.
   DESCRIPTION
      Expiry checking code for the following:
        GB Assignment-level Run To Date Balance Dimension
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

/*------------------------------ ASG_PROC_PTD_EC ----------------------------*/
/*
   NAME
      ASG_PROC_PTD_EC - Assignment Processing Period to Date expiry check.
   DESCRIPTION
      Expiry checking code for the following:
        GB Assignment-level Process Period To Date Balance Dimension
   NOTES
      The associtated dimension is expiry checked at assignment action level
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
   p_expiry_information            out nocopy number     -- dimension expired flag.
) ;

-- For 115.9

procedure ASG_PROC_PTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information            out nocopy date     -- dimension expired date.
) ;


/*------------------------------ ASG_PROC_YTD_EC ----------------------------*/
/*
   NAME
      ASG_PROC_YTD_EC - Assignment Processing Year to Date expiry check.
   DESCRIPTION
      Expiry checking code for the following:
        GB Assignment-level Process Year To Date Balance Dimension
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

-- For 115.9

procedure ASG_PROC_YTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information            out nocopy date     -- dimension expired flag.
);

-- For 115.8
/*------------------------------ ASG_PEN_YTD_EC ----------------------------*/
/*
   NAME
      ASG_PEN_YTD_EC - Assignment Processing Pension Year to Date expiry check.
   DESCRIPTION
      Expiry checking code for the following:
        GB Assignment-level Process Pension Year To Date Balance Dimension
   NOTES
      The associated dimension is expiry checked at assignment action level
*/
procedure ASG_PEN_YTD_EC
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

-- For 115.9
procedure ASG_PEN_YTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information            out  nocopy date     -- dimension expired date.
);

/*------------------------------ ASG_STAT_YTD_EC -------------------------*/
/*
   NAME
      ASG_STAT_YTD_EC - Assignment Statutory Year to DAte expiry check
   DESCRIPTION
      Expiry checking code for the following:
        GB Assignment-level Statutory Year to Date dimension
   NOTES
      The associated dimension is expiry checked at payroll action level
*/
procedure ASG_STAT_YTD_EC
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

-- For 115.9
procedure ASG_STAT_YTD_EC
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


/*------------------------------ ASG_PROC_TWO_YTD_EC ----------------------------*/
/*
   NAME
      ASG_PROC_TWO_YTD_EC - Assignment Processing Year to Date expiry check
                            for 2 yearly balance.
   DESCRIPTION
      Expiry checking code for the following:
            GB Assignment level Last Two Years to Date
   NOTES
      The associated dimension is expiry checked at payroll action level
*/
procedure ASG_PROC_TWO_YTD_EC
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

-- For 115.9
procedure ASG_PROC_TWO_YTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy    date     -- dimension expired flag.
);


/*---------------------------- PER_TD_STAT_PTD_EC ----------------------------*/
/*
   NAME
      PER_TD_STAT_PTD_EC Person level TD Stat Expiry Checking
   DESCRIPTION
      Expiry checking code for the following:
        GB PERSON level TD Statutory Period Dimension
   NOTES
      The associated dimension is expiry checked at ASSIGNMENT Action level
      hence requires one extra parameter.

*/
procedure PER_TD_STAT_PTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_balance_context_values     in     varchar2,  -- list of context values
   p_expiry_information            out nocopy number     -- dimension expired flag.
);
procedure proc_ytd_start(p_period_type     in            varchar2 default null,
                         p_effective_date  in            date     default null,
                         p_start_date         out nocopy date,
                         p_start_date_code in            varchar2 default null,
                         p_payroll_id      in            number,
                         p_bus_grp         in            number   default null,
                         p_action_type     in            varchar2 default null,
                         p_asg_action      in            number);

procedure proc_odd_ytd_start(p_period_type     in            varchar2 default null,
                         p_effective_date  in            date     default null,
                         p_start_date         out nocopy date,
                         p_start_date_code in            varchar2 default null,
                         p_payroll_id      in            number,
                         p_bus_grp         in            number   default null,
                         p_action_type     in            varchar2 default null,
                         p_asg_action      in            number);

procedure proc_even_ytd_start(p_period_type     in            varchar2 default null,
                         p_effective_date  in            date     default null,
                         p_start_date         out nocopy date,
                         p_start_date_code in            varchar2 default null,
                         p_payroll_id      in            number,
                         p_bus_grp         in            number   default null,
                         p_action_type     in            varchar2 default null,
                         p_asg_action      in            number);

--For 115.8
procedure proc_pen_ytd_start(p_period_type     in            varchar2 default null,
                             p_effective_date  in            date     default null,
                             p_start_date         out nocopy date,
                             p_start_date_code in            varchar2 default null,
                             p_payroll_id      in            number,
                             p_bus_grp         in            number   default null,
                             p_action_type     in            varchar2 default null,
                            p_asg_action      in            number);


end pygbexc;

/
