--------------------------------------------------------
--  DDL for Package PAY_NZ_LEAVE_LIABILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NZ_LEAVE_LIABILITY" AUTHID CURRENT_USER as
  --  $Header: pynzllal.pkh 115.4 2002/12/03 05:13:48 srrajago ship $

  --  Copyright (C) 1999 Oracle Corporation
  --  All Rights Reserved
  --
  --  Script to create NZ HRMS leave liability package.
  --
  --  Change List
  --  ===========
  --
  --  Date        Author   Reference Description
  --  -----------+--------+---------+-------------
  --  29 NOV 1999 JTURNER  N/A       Created
  --  29 SEP 2000 RAYYADEv  N/A       1420851
  --  30 JUL 2001 rbsinha  1422001    added function retrieve_variable
  --  29 AUG 2002 vgsriniv 2514562   Added dbdrv commands
  --  03 DEC 2002 srrajago 2689221   Included 'nocopy' option for the 'out'
  --                                 parameters of all the procedures.
  -----------------------------------------------------------------------------
  -- range_code procedure
  -----------------------------------------------------------------------------

  procedure range_code
  (p_payroll_action_id  in     number
  ,p_sql                out nocopy varchar2) ;

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
  procedure leave_net_accrual
     (p_assignment_id        IN    NUMBER
    ,p_payroll_id           IN    NUMBER
    ,p_business_group_id    IN    NUMBER
    ,p_plan_id              IN    NUMBER
    ,p_calculation_date     IN    DATE
    ,p_net_accrual          OUT NOCOPY NUMBER
    ,p_net_entitlement      OUT NOCOPY NUMBER
    ,p_calc_start_date      OUT NOCOPY DATE
    ,p_last_accrual         OUT NOCOPY DATE
    ,p_next_period_end      OUT NOCOPY DATE) ;

  -----------------------------------------------------------------------------
  --  wrapper function to retrieve the variable values at run time
  -----------------------------------------------------------------------------
function retrieve_variable(P_NAME IN VARCHAR2,
                           P_DATA_TYPE IN VARCHAR2) return varchar2 ;

end pay_nz_leave_liability ;

 

/
