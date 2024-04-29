--------------------------------------------------------
--  DDL for Package PAY_NL_DIM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NL_DIM_PKG" AUTHID CURRENT_USER AS
/* $Header: pynlexc.pkh 120.1 2005/09/17 05:14:33 gkhangar noship $ */
/*------------------------------ ASG_PTD_EC ----------------------------*/
/*
   NAME
      ASG_PTD_EC - Assignment-level Period to Date expiry check.
   DESCRIPTION
      Expiry checking code for the following:
        NL Assignment-level Period To Date Balance Dimension
   NOTES
      The associated dimension is expiry checked at assignment action level
*/
-- Returns dimension expired flag p_expiry_information as 0 or 1
procedure ASG_PTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy    number     -- dimension expired flag.
) ;

-- Returns the expiry date
procedure ASG_PTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy    DATE     -- dimension expired flag.
) ;



--
--3019423
--Expiry checking code for _PER_PTD
--

/*------------------------------ PER_PTD_EC ----------------------------*/
/*
   NAME
      PER_PTD_EC - Person-level Period to Date expiry check.
   DESCRIPTION
      Expiry checking code for the following:
        NL Person-level Period To Date Balance Dimension
   NOTES
      The associated dimension is expiry checked at assignment action level
*/
procedure PER_PTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy    number     -- dimension expired flag.
) ;

procedure PER_PTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy    DATE     -- dimension expired flag.
) ;

/*------------------------------ ASG_YTD_EC -------------------------*/
/*
   NAME
      ASG_YTD_EC - Assignment Tax Year to Date expiry check
   DESCRIPTION
      Expiry checking code for the following:
        NL Assignment-level Tax Year to Date dimension
   NOTES
      The associated dimension is expiry checked at assignment action level
*/
-- Returns dimension expired flag p_expiry_information as 0 or 1
procedure ASG_YTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy number -- dimension expired flag.
) ;

-- Returns expiry date
procedure ASG_YTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy date -- dimension expired flag.
) ;



--
--3019423
--Expiry checking code for _PER_YTD
--
/*------------------------------ PER_YTD_EC -------------------------*/
/*
   NAME
      PER_YTD_EC - Person Tax Year to Date expiry check
   DESCRIPTION
      Expiry checking code for the following:
        NL Person-level Tax Year to Date dimension
   NOTES
      The associated dimension is expiry checked at Person level
*/
-- Returns dimension expired flag p_expiry_information as 0 or 1
procedure PER_YTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy number -- dimension expired flag.
) ;

procedure PER_YTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy DATE -- dimension expired flag.
) ;



/*------------------------------ ASG_QTD_EC -------------------------*/
/*
   NAME
      ASG_QTD_EC - Assignment Tax Year to Date expiry check
   DESCRIPTION
      Expiry checking code for the following:
        NL Assignment-level Tax Quarter to Date dimension
   NOTES
      The associated dimension is expiry checked at assignment action level
*/
-- Returns dimension expired flag p_expiry_information as 0 or 1
procedure ASG_QTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy number -- dimension expired flag.
);

-- Returns expiry date
procedure ASG_QTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy DATE -- dimension expired flag.
);


--
--3019423
--Expiry checking code for _PER_QTD
--
/*------------------------------ PER_QTD_EC -------------------------*/
/*
   NAME
      PER_QTD_EC - Person Tax Quarter to Date expiry check
   DESCRIPTION
      Expiry checking code for the following:
        NL Person-level Tax Quarter to Date dimension
   NOTES
      The associated dimension is expiry checked at Person level
*/
-- Returns dimension expired flag p_expiry_information as 0 or 1
procedure PER_QTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy number -- dimension expired flag.
);

-- Returns expiry date
procedure PER_QTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy DATE -- dimension expired flag.
);

/*------------------------------ ASG_MON_EC -------------------------*/
/*
   NAME
      ASG_MON_EC - Assignment Tax Year to Date expiry check
   DESCRIPTION
      Expiry checking code for the following:
        NL Assignment-level Tax Month dimension
   NOTES
      The associated dimension is expiry checked at assignment action level
*/
-- Returns dimension expired flag p_expiry_information as 0 or 1
procedure ASG_MON_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy number -- dimension expired flag.
);

-- Returns expiry date
procedure ASG_MON_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy DATE -- dimension expired flag.
);


/*------------------------------ ASG_PROC_PTD_EC ----------------------------*/
/*
   NAME
      ASG_PROC_PTD_EC - Assignment Processing Period to Date expiry check.
   DESCRIPTION
      Expiry checking code for the following:
        NL Element-level Process Period To Date Balance Dimension
   NOTES
      The associtated dimension is expiry checked at payroll action level
*/
-- Returns dimension expired flag p_expiry_information as 0 or 1
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

-- Returns expiry date
procedure ASG_PROC_PTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information            out nocopy DATE     -- dimension expired flag.
) ;


/*------------------------------ ASG_SIT_PTD_EC ----------------------------*/
/*
   NAME
      ASG_SIT_PTD_EC - Assignment SI Type Period to Date expiry check.
   DESCRIPTION
      Expiry checking code for the following:
        NL Element-level Process Period To Date Balance Dimension
   NOTES
      The associtated dimension is expiry checked at payroll action level
*/
-- Returns dimension expired flag p_expiry_information as 0 or 1
procedure ASG_SIT_PTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out    nocopy number     -- dimension expired flag.
) ;

-- Returns expiry date
procedure ASG_SIT_PTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out    nocopy DATE     -- dimension expired flag.
) ;

/*------------------------------ ASG_SIT_QTD_EC ----------------------------*/
/*
   NAME
      ASG_SIT_QTD_EC - Assignment SI Type Tax Quarter to Date expiry check.
   DESCRIPTION
      Expiry checking code for the following:
        NL Element-level Process Quarter To Date Balance Dimension
   NOTES
      The associtated dimension is expiry checked at payroll action level
*/
-- Returns dimension expired flag p_expiry_information as 0 or 1
procedure ASG_SIT_QTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out    nocopy number  -- dimension expired flag.
);

-- Returns expiry date
procedure ASG_SIT_QTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out    nocopy DATE  -- dimension expired flag.
);
/*------------------------------ ASG_SIT_MON_EC ----------------------------*/
/*
   NAME
      ASG_SIT_MON_EC - Assignment SI Type Tax Quarter to Date expiry check.
   DESCRIPTION
      Expiry checking code for the following:
        NL Element-level Process Month Balance Dimension
   NOTES
      The associtated dimension is expiry checked at payroll action level
*/
-- Returns dimension expired flag p_expiry_information as 0 or 1
procedure ASG_SIT_MON_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out    nocopy number  -- dimension expired flag.
);

-- Returns expiry date
procedure ASG_SIT_MON_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out    nocopy DATE  -- dimension expired flag.
);

/*------------------------------ ASG_SIT_YTD_EC ----------------------------*/
/*
   NAME
      ASG_SIT_YTD_EC - Assignment SI Type Tax Year to Date expiry check.
   DESCRIPTION
      Expiry checking code for the following:
        NL Element-level Process Period To Date Balance Dimension
   NOTES
      The associtated dimension is expiry checked at payroll action level
*/
-- Returns dimension expired flag p_expiry_information as 0 or 1
procedure ASG_SIT_YTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out    nocopy number  -- dimension expired flag.
) ;

-- Returns expiry date
procedure ASG_SIT_YTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out    nocopy DATE  -- dimension expired flag.
) ;

/*------------------------------ ASG_RUN_EC ----------------------------*/
/*
   NAME
      ASG_RUN_EC - Assignment Run expiry check.
   DESCRIPTION
      Expiry checking code for the following:
        NL Element-level Process Period To Date Balance Dimension
   NOTES
      The associtated dimension is expiry checked at payroll action level
*/
-- Returns dimension expired flag p_expiry_information as 0 or 1
procedure ASG_RUN_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out    nocopy number  -- dimension expired flag.
) ;

/*------------------------------ ASG_SIT_RUN_EC ----------------------------*/
/*
   NAME
      ASG_SIT_RUN_EC - Assignment Run SI Type Date expiry check.
   DESCRIPTION
      Expiry checking code for the following:
        NL Element-level Process Period To Date Balance Dimension
   NOTES
      The associtated dimension is expiry checked at payroll action level
*/
-- Returns dimension expired flag p_expiry_information as 0 or 1
procedure ASG_SIT_RUN_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out    nocopy number  -- dimension expired flag.
) ;
-----------------------------------------------------------------------------

/*------------------------------ ASG_ITD_EC ----------------------------*/
/*
   NAME
      ASG_ITD_EC - Assignment Inception To Date expiry check.
   DESCRIPTION
      Expiry checking code for the following:
        NL Element-level Process Inception To Date Balance Dimension
   NOTES
      The associated dimension is expiry checked at payroll action level
*/
-- Returns dimension expired flag p_expiry_information as 0 or 1
procedure ASG_ITD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out    nocopy number  -- dimension expired flag.
)  ;

-- Returns expiry date
procedure ASG_ITD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out    nocopy DATE  -- dimension expired flag.
)  ;


--
--3019423
--Expiry checking code for _PER_ITD
--
/*------------------------------ PER_ITD_EC ----------------------------*/
/*
   NAME
      PER_ITD_EC - Person Inception To Date expiry check.
   DESCRIPTION
      Expiry checking code for the following:
        NL Person Inception To Date Balance Dimension
   NOTES
      The associated dimension is expiry checked at Person level
*/
-- Returns dimension expired flag p_expiry_information as 0 or 1
procedure PER_ITD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out    nocopy number  -- dimension expired flag.
)  ;

-- Returns expiry date
procedure PER_ITD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out    nocopy DATE  -- dimension expired flag.
)  ;


/*------------------------------ ASG_LQTD_EC ----------------------------*/
/*
   NAME
      ASG_LQTD_EC - Assignment Lunar Quarter To Date expiry check.

   NOTES
      The associated dimension is expiry checked at payroll action level
*/
-- Returns dimension expired flag p_expiry_information as 0 or 1
procedure ASG_LQTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy number -- dimension expired flag.
);

-- Returns expiry date
procedure ASG_LQTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy DATE -- dimension expired flag.
);


/*------------------------------ PER_PAY_SITP_PTD ----------------------------*/
/*
   NAME
      PER_PAY_SITP_PTD - Person Payroll SI Type Provider Period To Date .

   NOTES
      The associtated dimension is expiry checked at payroll action level
*/
-- Returns dimension expired flag p_expiry_information as 0 or 1
procedure PER_PAY_SITP_PTD
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out    nocopy number     -- dimension expired flag.
);

-- Returns expiry date
procedure PER_PAY_SITP_PTD
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out    nocopy DATE     -- dimension expired flag.
);

/*------------------------------ PER_PAY_PTD_EC ----------------------------*/
/*
   NAME
      PER_PAY_PTD_EC - Person Payroll Period To Date Expiry Check.

   NOTES
      The associated dimension is expiry checked at payroll action level
*/
-- Returns dimension expired flag p_expiry_information as 0 or 1
procedure PER_PAY_PTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out    nocopy number     -- dimension expired flag.
);

-- Returns expiry date
procedure PER_PAY_PTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out    nocopy DATE     -- dimension expired flag.
);



/*------------------------------ ASG_LMONTH_EC ----------------------------*/
/*
   NAME
      ASG_LMONTH_EC - Assignment Lunar Monthly expiry check.

   NOTES
      The associated dimension is expiry checked at payroll action level
*/
-- Returns dimension expired flag p_expiry_information as 0 or 1
procedure ASG_LMONTH_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy number -- dimension expired flag.
);

-- Returns expiry date
procedure ASG_LMONTH_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy DATE -- dimension expired flag.
);



/*------------------------------ ASG_SIT_LMONTH_EC ----------------------------*/
/*
   NAME
      ASG_SIT_LMONTH_EC - Assignment Lunar Monthly expiry check.

   NOTES
      The associated dimension is expiry checked at payroll action level
*/
-- Returns dimension expired flag p_expiry_information as 0 or 1
procedure ASG_SIT_LMON_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy number -- dimension expired flag.
);

-- Returns expiry date
procedure ASG_SIT_LMON_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy DATE -- dimension expired flag.
);


/*------------------------------ PER_PAY_YTD_EC ----------------------------*/
/*
   NAME
      PER_PAY_YTD_EC - Person Payroll Year to Date expiry check.
   DESCRIPTION
      Expiry checking code for the following:
        NL Element-level Process Year To Date Balance Dimension
   NOTES
      The associtated dimension is expiry checked at payroll action level
*/
-- Returns dimension expired flag p_expiry_information as 0 or 1
procedure PER_PAY_YTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out    nocopy number  -- dimension expired flag.
) ;

--Returns Expiry Date
procedure PER_PAY_YTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out    nocopy date  -- dimension expired flag.
) ;



end PAY_NL_DIM_PKG;

 

/
