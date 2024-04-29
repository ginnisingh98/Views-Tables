--------------------------------------------------------
--  DDL for Package PAY_AU_LEAVE_LIABILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AU_LEAVE_LIABILITY" AUTHID CURRENT_USER as
  --  $Header: pyaullal.pkh 115.3 2002/12/04 07:23:12 ragovind ship $

  --  Copyright (C) 1999 Oracle Corporation
  --  All Rights Reserved
  --
  --  Script to create AU HRMS leave liability package.
  --
  --  Change List
  --  ===========
  --
  --  Date        Author   Reference Description
  --  -----------+--------+---------+-------------
  --  14 JUL 2000 rayyadev  N/A       Created
  --  06 oct 2000 rayyadev  N/A       Added the Specification for the leave_
  --				      net accrual Procedure
  --  05 Dec 2002 Ragovind  2689226   Added NOCOPY for the functions leave_net_accrual, leave_net_entitlement, range_code and added gscc

  -----------------------------------------------------------------------------
  -- range_code procedure
  -----------------------------------------------------------------------------

  procedure range_code
  (p_payroll_action_id  in     number
  ,p_sql                out NOCOPY varchar2) ;

  -----------------------------------------------------------------------------
  -- assignment_action_code procedure
  -----------------------------------------------------------------------------

  procedure assignment_action_code
  (p_payroll_action_id  in     number
  ,p_start_person_id    in     number
  ,p_end_person_id      in     number
  ,p_chunk              in     number) ;

  -----------------------------------------------------------------------------
  -- initialization_code procedure
  -----------------------------------------------------------------------------

  procedure initialization_code
  (p_payroll_action_id  in     number) ;

  -----------------------------------------------------------------------------
  -- archive_code procedure
  -----------------------------------------------------------------------------

  procedure archive_code
  (p_assignment_action_id  in     number
  ,p_effective_date        in     date) ;

  -----------------------------------------------------------------------------
  --  hourly_rate procedure
  -----------------------------------------------------------------------------


  procedure hourly_rate ;

  -----------------------------------------------------------------------------
  --  leave_net_entitlement
  -----------------------------------------------------------------------------

  procedure leave_net_entitlement
     (p_assignment_id      in number
     ,p_payroll_id         in number
     ,p_business_group_id  in number
     ,p_plan_id            in number
     ,p_calculation_date   in date
     ,p_start_date         out NOCOPY date
     ,p_end_date	   out NOCOPY date
     ,p_net_entitlement    out NOCOPY number);

     procedure leave_net_accrual
     (p_assignment_id        IN    NUMBER
    ,p_payroll_id           IN    NUMBER
    ,p_business_group_id    IN    NUMBER
    ,p_plan_id              IN    NUMBER
    ,p_calculation_date     IN    DATE
    ,p_net_accrual          OUT NOCOPY  NUMBER
    ,p_net_entitlement      OUT NOCOPY  NUMBER
    ,p_calc_start_date      OUT NOCOPY  DATE
    ,p_last_accrual         OUT NOCOPY  DATE
    ,p_next_period_end      OUT NOCOPY  DATE) ;

    FUNCTION get_weekdays_in_period
 (p_start_date          IN DATE
 ,p_end_date            IN DATE)
 RETURN NUMBER;

end pay_au_leave_liability ;

 

/
