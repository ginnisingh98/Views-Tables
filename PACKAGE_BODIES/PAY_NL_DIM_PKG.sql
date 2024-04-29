--------------------------------------------------------
--  DDL for Package Body PAY_NL_DIM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NL_DIM_PKG" AS
/* $Header: pynlexc.pkb 120.2 2005/09/30 07:57:23 gkhangar noship $ */
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
)  IS
l_period_start_date date;
BEGIN
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
END;
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
)  IS
BEGIN
   SELECT TP.end_date
   INTO   p_expiry_information
   FROM   per_time_periods    TP
         ,pay_payroll_actions PACT
   WHERE  PACT.payroll_action_id = p_owner_payroll_action_id
     AND  PACT.payroll_id        = TP.payroll_id
     AND  p_owner_effective_date BETWEEN TP.start_date AND TP.end_date;
 END;
--
--3019423
--Expiry checking logic for _PER_PTD
--
/*------------------------------ PER_PTD_EC ----------------------------*/
/*
   NAME
      PER_PTD_EC - Person Level Period to Date expiry check.
   DESCRIPTION
      Expiry checking code for the following:
        NL Person-level Period To Date Balance Dimension
   NOTES
      The associated dimension is expiry checked at Person level
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
)  IS
l_period_start_date date;
BEGIN
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
END;
procedure PER_PTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy   DATE     -- dimension expired flag.
)  IS
BEGIN
   SELECT TP.end_date
   INTO   p_expiry_information
   FROM   per_time_periods    TP
         ,pay_payroll_actions PACT
   WHERE  PACT.payroll_action_id = p_owner_payroll_action_id
     AND  PACT.payroll_id        = TP.payroll_id
     AND  p_owner_effective_date BETWEEN TP.start_date AND TP.end_date;
 END;
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
)  IS
BEGIN
    if p_owner_effective_date >= trunc(p_user_effective_date,'Y') then
       p_expiry_information := 0;
    else
       p_expiry_information := 1;
    end if;
END;
procedure ASG_YTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy DATE -- dimension expired flag.
)  IS
BEGIN
p_expiry_information := TRUNC(ADD_MONTHS(p_owner_effective_date, 12), 'Y')-1;
END;
--
--3019423
--Expiry checking logic for _PER_YTD
--
/*------------------------------ PER_YTD_EC -------------------------*/
/*
   NAME
      PER_YTD_EC - Person Tax Year to Date expiry check
   DESCRIPTION
      Expiry checking code for the following:
        NL Person-level Tax Year to Date dimension
   NOTES
      The associated dimension is expiry checked at person level
*/
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
)  IS
BEGIN
    if p_owner_effective_date >= trunc(p_user_effective_date,'Y') then
       p_expiry_information := 0;
    else
       p_expiry_information := 1;
    end if;
END;
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
)  IS
BEGIN
p_expiry_information := TRUNC(ADD_MONTHS(p_owner_effective_date, 12), 'Y')-1;
END;
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
)  IS
BEGIN
    IF p_user_effective_date >= trunc(add_months(p_owner_effective_date,3),'Q') THEN
       p_expiry_information := 1; -- Expired
    ELSE
       p_expiry_information := 0; -- Not Expired
    END IF;
END;
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
)  IS
BEGIN
p_expiry_information := TRUNC(ADD_MONTHS(p_owner_effective_date, 3), 'Q')-1;
END;
--
--3019423
--Expiry checking logic for _PER_QTD
--
/*------------------------------ PER_QTD_EC -------------------------*/
/*
   NAME
      PER_QTD_EC - Person Quarter to Date expiry check
   DESCRIPTION
      Expiry checking code for the following:
        NL Person-level Tax Quarter to Date dimension
   NOTES
      The associated dimension is expiry checked at Person level
*/
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
)  IS
BEGIN
    IF p_user_effective_date >= trunc(add_months(p_owner_effective_date,3),'Q') THEN
       p_expiry_information := 1; -- Expired
    ELSE
       p_expiry_information := 0; -- Not Expired
    END IF;
END;
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
)  IS
BEGIN
p_expiry_information := TRUNC(ADD_MONTHS(p_owner_effective_date, 3), 'Q')-1;
END;
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
)  IS
BEGIN
    if p_owner_effective_date >= trunc(add_months(p_user_effective_date,1),'MM') then
       p_expiry_information := 0;
    else
       p_expiry_information := 1;
    end if;
END;
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
)  IS
BEGIN
p_expiry_information := TRUNC(ADD_MONTHS(p_owner_effective_date, 1), 'MM')-1;
END;
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
)  IS
l_period_start_date date;
BEGIN
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
END;
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
) IS
BEGIN
        select ptp.END_DATE
        into   p_expiry_information
        from   per_time_periods ptp, pay_payroll_actions ppa
        where  ppa.payroll_action_id = p_user_payroll_action_id
        and    ppa.payroll_id = ptp.payroll_id
        and    p_owner_effective_date between ptp.start_date and ptp.end_date;
END;
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
)  IS
  l_period_start_date date;
BEGIN
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
END;
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
)  IS
BEGIN
   SELECT TP.end_date
   INTO   p_expiry_information
   FROM   per_time_periods    TP
         ,pay_payroll_actions PACT
   WHERE  PACT.payroll_action_id = p_owner_payroll_action_id
     AND  PACT.payroll_id        = TP.payroll_id
     AND  p_owner_effective_date BETWEEN TP.start_date AND TP.end_date;
 END;
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
)  IS
BEGIN
    if p_owner_effective_date >= trunc(p_user_effective_date,'Y') then
       p_expiry_information := 0;
    else
       p_expiry_information := 1;
    end if;
END;
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
)  IS
BEGIN
p_expiry_information := TRUNC(ADD_MONTHS(p_owner_effective_date, 12), 'Y')-1;
END;
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
)  IS
BEGIN
    IF p_user_effective_date >= trunc(add_months(p_owner_effective_date,3),'Q') THEN
       p_expiry_information := 1; -- Expired
    ELSE
       p_expiry_information := 0; -- Not Expired
    END IF;
END;
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
)  IS
BEGIN
p_expiry_information := TRUNC(ADD_MONTHS(p_owner_effective_date, 3), 'Q')-1;
END;
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
)  IS
BEGIN
   if p_owner_effective_date >= trunc(add_months(p_user_effective_date,1),'MM') then
          p_expiry_information := 0;
       else
          p_expiry_information := 1;
    end if;
END;
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
)  IS
BEGIN
p_expiry_information := TRUNC(ADD_MONTHS(p_owner_effective_date, 1), 'MM')-1;
END;
/*------------------------------ ASG_ITD_EC ----------------------------*/
/*
   NAME
      ASG_ITD_EC - Assignment Inception To Date expiry check.
   DESCRIPTION
      Expiry checking code for the following:
        NL Element-level Process Inception To Date Balance Dimension
   NOTES
      The associtated dimension is expiry checked at payroll action level
*/
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
)  IS
BEGIN
	p_expiry_information := 0;
END;
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
)  IS
BEGIN
	p_expiry_information := HR_GENERAL.END_OF_TIME;
END;
--
--3019423
--Expiry checking logic for _PER_ITD
--
/*------------------------------PER_ITD_EC ----------------------------*/
/*
   NAME
      PER_ITD_EC - Person Inception To Date expiry check.
   DESCRIPTION
      Expiry checking code for the following:
        NL Person Inception To Date Balance Dimension
   NOTES
      The associated dimension is expiry checked at Person level
*/
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
)  IS
BEGIN
 p_expiry_information := 0;
END;
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
)  IS
BEGIN
	p_expiry_information := HR_GENERAL.END_OF_TIME;
END;
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
)  IS
BEGIN
  if p_user_payroll_action_id = p_owner_payroll_action_id then
      p_expiry_information := 0;
   else
      p_expiry_information := 1;
   end if;
END;
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
)  IS
BEGIN
  if p_user_payroll_action_id = p_owner_payroll_action_id then
      p_expiry_information := 0;
   else
      p_expiry_information := 1;
   end if;
END;
/*------------------------------ ASG_LQTD_EC ----------------------------*/
/*
   NAME
      ASG_LQTD_EC - Assignment Lunar Quarter To Date expiry check.
   NOTES
      The associtated dimension is expiry checked at payroll action level
*/
PROCEDURE ASG_LQTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy number -- dimension expired flag.
)  IS
    --
    l_owner_quarter  NUMBER;
    l_user_quarter   NUMBER;
    --
BEGIN
    --
    SELECT DECODE(trunc((to_number(to_char(p_owner_effective_date,'IW'))-1)/12)
                 ,4,3
                 ,trunc((to_number(to_char(p_owner_effective_date,'IW'))-1)/12))
          ,DECODE(trunc((to_number(to_char(p_user_effective_date,'IW'))-1)/12)
                 ,4,3
                 ,trunc((to_number(to_char(p_user_effective_date,'IW'))-1)/12))
    INTO  l_owner_quarter, l_user_quarter
    FROM  dual;
    --
    IF (l_owner_quarter = l_user_quarter) THEN
        p_expiry_information := 0; -- Not Expired
    ELSE
        p_expiry_information := 1; -- Expired
    END IF;
    --
END ASG_LQTD_EC;
PROCEDURE ASG_LQTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy DATE -- dimension expired flag.
)  IS
l_max_period NUMBER;
l_curr_wkend DATE;
l_lastyr_wkend DATE;
l_week_no NUMBER;
l_no_days NUMBER;
BEGIN
--determine week end of last week of the last year and week end of current week
select trunc(trunc(trunc(p_owner_effective_date,'IW')+6,'Y'),'IW')-1, trunc(p_owner_effective_date,'IW')+6
into  l_lastyr_wkend ,l_curr_wkend
FROM DUAL;
IF (l_lastyr_wkend+53*7) < trunc(add_months(p_owner_effective_date,12),'Y') THEN -- 53 Week year
	l_max_period := 53;
ELSE
	l_max_period := 52;
END IF;
--determine week number for p_owner_effective_date
select (l_curr_wkend-l_lastyr_wkend)/7 into l_week_no from dual;
select (decode(trunc((l_week_no-1)/12+1)*12 ,48,l_max_period,60,l_max_period ,trunc((l_week_no-1)/12+1)*12))*7 into l_no_days from dual;
p_expiry_information := l_lastyr_wkend + l_no_days;
END;
/*------------------------------ PER_PAY_SITP_PTD ----------------------------*/
/*
   NAME
      PER_PAY_SITP_PTD - Person Payroll SI Type Provider Period To Date .
   NOTES
      The associtated dimension is expiry checked at payroll action level
*/
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
) IS
BEGIN
  ASG_SIT_PTD_EC(p_owner_payroll_action_id       => p_owner_payroll_action_id,
                 p_user_payroll_action_id        => p_user_payroll_action_id,
                 p_owner_assignment_action_id    => p_owner_assignment_action_id,
            		 p_user_assignment_action_id     => p_user_assignment_action_id,
                 p_owner_effective_date          => p_owner_effective_date,
                 p_user_effective_date           => p_user_effective_date,
                 p_dimension_name                => p_dimension_name,
                 p_expiry_information            => p_expiry_information);
END;
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
) IS
BEGIN
   SELECT TP.end_date
   INTO   p_expiry_information
   FROM   per_time_periods    TP
         ,pay_payroll_actions PACT
   WHERE  PACT.payroll_action_id = p_owner_payroll_action_id
     AND  PACT.payroll_id        = TP.payroll_id
     AND  p_owner_effective_date BETWEEN TP.start_date AND TP.end_date;
 END;
/*------------------------------ PER_PAY_PTD_EC ----------------------------*/
/*
   NAME
      PER_PAY_PTD_EC - Person Payroll Period To Date Expiry Check.
   NOTES
      The associated dimension is expiry checked at payroll action level
*/
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
) IS
    l_period_start_date date;
BEGIN
  --
  SELECT ptp.start_date
  INTO   l_period_start_date
  FROM   per_time_periods ptp, pay_payroll_actions ppa
  WHERE  ppa.payroll_action_id = p_user_payroll_action_id
  AND    ppa.payroll_id = ptp.payroll_id
  AND    p_user_effective_date BETWEEN ptp.start_date AND ptp.end_date;
  -- see if balance was written in this period. If not it is expired
  IF p_owner_effective_date >= l_period_start_date THEN
          p_expiry_information := 0; -- Not expired
  ELSE
          p_expiry_information := 1;  -- Expired
  END IF;
  --
END PER_PAY_PTD_EC;
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
) IS
BEGIN
   SELECT TP.end_date
   INTO   p_expiry_information
   FROM   per_time_periods    TP
         ,pay_payroll_actions PACT
   WHERE  PACT.payroll_action_id = p_owner_payroll_action_id
     AND  PACT.payroll_id        = TP.payroll_id
     AND  p_owner_effective_date BETWEEN TP.start_date AND TP.end_date;
 END;
/*------------------------------ ASG_LMONTH_EC ----------------------------*/
/*
   NAME
      ASG_LMONTH_EC - Assignment Lunar Month expiry check.
   NOTES
      The associtated dimension is expiry checked at payroll action level
*/
PROCEDURE ASG_LMONTH_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy number -- dimension expired flag.
)  IS
    --
    l_owner_month  NUMBER;
    l_user_month   NUMBER;
    --
BEGIN
    --
    SELECT DECODE(trunc((to_number(to_char(p_owner_effective_date,'IW'))-1)/4)
                 ,13,12
                 ,trunc((to_number(to_char(p_owner_effective_date,'IW'))-1)/4))
          ,DECODE(trunc((to_number(to_char(p_user_effective_date,'IW'))-1)/4)
                 ,13,12
                 ,trunc((to_number(to_char(p_user_effective_date,'IW'))-1)/4))
    INTO  l_owner_month, l_user_month
    FROM  dual;
    --
    IF (l_owner_month = l_user_month) THEN
        p_expiry_information := 0; -- Not Expired
    ELSE
        p_expiry_information := 1; -- Expired
    END IF;
    --
END ASG_LMONTH_EC;
PROCEDURE ASG_LMONTH_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy DATE -- dimension expired flag.
)  IS
l_max_period NUMBER;
l_curr_wkend DATE;
l_lastyr_wkend DATE;
l_week_no NUMBER;
l_no_days NUMBER;
BEGIN
SELECT 	MAX(TP.period_num)
INTO 	l_max_period
FROM 	per_time_periods TP
        ,pay_payroll_actions PACT
WHERE  	PACT.payroll_action_id = p_owner_payroll_action_id
AND  	PACT.payroll_id        = TP.payroll_id
AND 	TP.end_date BETWEEN TRUNC(p_owner_effective_date,'Y')
	AND (TRUNC(ADD_MONTHS(p_owner_effective_date,12),'Y')-1);

IF l_max_period = 13 then
	SELECT 	TP.end_date
	INTO   	p_expiry_information
	FROM   	per_time_periods    TP
	,pay_payroll_actions PACT
	WHERE  	PACT.payroll_action_id = p_owner_payroll_action_id
	AND  	PACT.payroll_id        = TP.payroll_id
	AND  	p_owner_effective_date BETWEEN TP.start_date AND TP.end_date;
ELSE
	--determine week end of last week of the last year and week end of current week
	select trunc(trunc(trunc(p_owner_effective_date,'IW')+6,'Y'),'IW')-1, trunc(p_owner_effective_date,'IW')+6
	into  l_lastyr_wkend ,l_curr_wkend
	FROM DUAL;
	IF (l_lastyr_wkend+53*7) < trunc(add_months(p_owner_effective_date,12),'Y') THEN -- 53 Week year
		l_max_period := 53;
	ELSE
		l_max_period := 52;
	END IF;
	--determine week number for p_owner_effective_date
	select (l_curr_wkend-l_lastyr_wkend)/7 into l_week_no from dual;
	select (decode(trunc((l_week_no-1)/4+1)*4 ,52,l_max_period,56,l_max_period ,trunc((l_week_no-1)/4+1)*4))*7 into l_no_days from dual;
	p_expiry_information := l_lastyr_wkend + l_no_days;
END IF;
END;
------------------------------------------------------------------------------
/*------------------------------ ASG_SIT_LMON_EC ----------------------------*/
/*
   NAME
      ASG_SIT_MON_EC - Assignment SI Type Tax Quarter to Date expiry check.
   DESCRIPTION
      Expiry checking code for the following:
        NL Element-level Process Month Balance Dimension
   NOTES
      The associtated dimension is expiry checked at payroll action level
*/
procedure ASG_SIT_LMON_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out    nocopy number  -- dimension expired flag.
)  IS
 --
    l_owner_month  NUMBER;
    l_user_month   NUMBER;
    --
BEGIN
    --
    SELECT DECODE(trunc((to_number(to_char(p_owner_effective_date,'IW'))-1)/4)
                 ,13,12
                 ,trunc((to_number(to_char(p_owner_effective_date,'IW'))-1)/4))
          ,DECODE(trunc((to_number(to_char(p_user_effective_date,'IW'))-1)/4)
                 ,13,12
                 ,trunc((to_number(to_char(p_user_effective_date,'IW'))-1)/4))
    INTO  l_owner_month, l_user_month
    FROM  dual;
    --
    IF (l_owner_month = l_user_month) THEN
        p_expiry_information := 0; -- Not Expired
    ELSE
        p_expiry_information := 1; -- Expired
    END IF;
    --
END  ASG_SIT_LMON_EC ;
procedure ASG_SIT_LMON_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out    nocopy DATE  -- dimension expired flag.
)  IS
l_max_period NUMBER;
l_curr_wkend DATE;
l_lastyr_wkend DATE;
l_week_no NUMBER;
l_no_days NUMBER;
BEGIN
SELECT 	MAX(TP.period_num)
INTO 	l_max_period
FROM 	per_time_periods TP
        ,pay_payroll_actions PACT
WHERE  	PACT.payroll_action_id = p_owner_payroll_action_id
AND  	PACT.payroll_id        = TP.payroll_id
AND 	TP.end_date BETWEEN TRUNC(p_owner_effective_date,'Y')
	AND (TRUNC(ADD_MONTHS(p_owner_effective_date,12),'Y')-1);

IF l_max_period = 13 then
	SELECT 	TP.end_date
	INTO   	p_expiry_information
	FROM   	per_time_periods    TP
	,pay_payroll_actions PACT
	WHERE  	PACT.payroll_action_id = p_owner_payroll_action_id
	AND  	PACT.payroll_id        = TP.payroll_id
	AND  	p_owner_effective_date BETWEEN TP.start_date AND TP.end_date;
ELSE
	--determine week end of last week of the last year and week end of current week
	select trunc(trunc(trunc(p_owner_effective_date,'IW')+6,'Y'),'IW')-1, trunc(p_owner_effective_date,'IW')+6
	into  l_lastyr_wkend ,l_curr_wkend
	FROM DUAL;
	IF (l_lastyr_wkend+53*7) < trunc(add_months(p_owner_effective_date,12),'Y') THEN -- 53 Week year
		l_max_period := 53;
	ELSE
		l_max_period := 52;
	END IF;
	--determine week number for p_owner_effective_date
	select (l_curr_wkend-l_lastyr_wkend)/7 into l_week_no from dual;
	select (decode(trunc((l_week_no-1)/4+1)*4 ,52,l_max_period,56,l_max_period ,trunc((l_week_no-1)/4+1)*4))*7 into l_no_days from dual;
	p_expiry_information := l_lastyr_wkend + l_no_days;
END IF;
END;
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
)  IS
BEGIN
    if p_owner_effective_date >= trunc(p_user_effective_date,'Y') then
       p_expiry_information := 0;
    else
       p_expiry_information := 1;
    end if;
END PER_PAY_YTD_EC;
procedure PER_PAY_YTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out    nocopy DATE  -- dimension expired flag.
)  IS
BEGIN
p_expiry_information := TRUNC(ADD_MONTHS(p_owner_effective_date, 12), 'Y')-1;
END PER_PAY_YTD_EC;
---------------------------------------------------------------------------
end PAY_NL_DIM_PKG;

/
