--------------------------------------------------------
--  DDL for Package PAY_NZ_HOLIDAYS_2003
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NZ_HOLIDAYS_2003" AUTHID CURRENT_USER as
  --  $Header: pynzhl2003.pkh 120.1.12010000.1 2008/07/27 23:17:11 appldev ship $
  --
  --  Copyright (C) 1999 Oracle Corporation
  --  All Rights Reserved
  --
  --  Change List
  --  ===========
  --
  --  Date        Author      Reference Description
  --  -----------+-----------+---------+--------------------------------------------
  --  08 JAN 2004 sclarke               Removed get_anniversary_details
  --  30 DEC 2003 sclarke               Changed parameters to annual_leave_calc_1
  --  04 Dec 2003 sclarke               Updates after testing
  --  19 Nov 2003 sclarke     3064179   Created
  --  12 Mar 2004 sclarke     3547116   Recurring absences
  --  02 APR 2004 sclarke     3541500   Anniversary Date is not moved the initial 7 days
  --  11 JUN 2004 puchil      3654766   Changed the definition of get_previous_rate
  --                                    to accept p_assignment_action_id
  --  23 JUN 2004 bramajey    3608752   Parental Leave Changes. Created
  --                                    functions is_parental_leave_taken
  --                                    ,get_entitled_amount and
  --                                    get_recur_abs_prev_period
  --  05 AUG 2005 rpalli      4536217   As part of bug 4536217(performance issue):
  --					Added overloaded function determine_work_week.
  --                                    Removed eligible_for_accrual function.
  --				        Modified calculate_daily_accrual function.
  --  ------------------------------------------------------------------------------
  --
  --
  -- Returns the UOM for the given Accrual Plan
  --
  function get_accrual_plan_uom
  (p_accrual_plan_id number
  ) return varchar2;
  --
  function cache_anniversary_details
  (p_payroll_id                 in number
  ,p_assignment_id              in number
  ,p_accrual_plan_id            in number
  ,p_calculation_date           in date
  ,p_service_start_date         in date default null
  ,p_anniversary_start_date     out nocopy date
  ,p_anniversary_end_date       out nocopy date
  ,p_years_of_service           out nocopy number
  ) return number;
  --
  function get_working_days_balance
  (p_assignment_id              in number
  ,p_effective_date             in date
  ) return number;
  --
  function get_balance
  (p_assignment_id          in number
  ,p_effective_date         in date
  ,p_balance_name           varchar2
  ,p_dimension_name        varchar2
  ) return number;

  function get_standard_work_week
  (p_assignment_id              in number
  ,p_effective_date             in date
  ) return number;
  --
  function calculate_daily_accrual
  (p_person_id                  in number
  ,p_accrual_plan_id            in number
  ,p_start_date                 in date
  ,p_end_date                   in date
  ,p_annual_accrual             in number
  ,p_work_week                  in number
  )
  return number;
  --
  function determine_work_week
  (p_assignment_id      in number
  ,p_current_day        in date
  ,p_uom                in varchar2
  ,p_annual_accrual     in number
  ,p_chg_asg_hours      IN boolean
  ,p_asg_hours          IN number
  ,p_freq               IN varchar2
  ) return number;

  function determine_work_week
  (p_assignment_id      in number
  ,p_current_day        in date
  ,p_uom                in varchar2
  ,p_annual_accrual     in number
  ) return number;
  --
  -- Used by Formula Function
  --
  function daily_accrual_loop
  (p_payroll_id                 in number
  ,p_assignment_id              in number
  ,p_accrual_plan_id            in number
  ,p_service_start_date         in date default null
  ,p_start_date                 in date
  ,p_end_date                   in date
  ) return number;
  --
  -- Used by Formula Function
  --
  function get_annual_leave_percentage
  (p_accrual_plan_id            number)
  return number;
  --
  -- Used by Formula Function
  --
  function annual_leave_rate_calc_1
  (p_ordinary_rate              in number
  ,p_earnings_prev_12mths       in number
  ,p_earnings_td                in number
  ,p_time_worked_prev_12mths    in number
  ,p_time_worked_td             in number
  ,p_work_week                  in number
  ,p_hire_date                  in date
  ,p_period_start_date          in date
  ,p_period_end_date            in date
  )
  return number;
  --
  -- Used by Formula Function
  --
  function annual_leave_rate_calc_2
  (p_percentage                 in number
  ,p_gross_earnings             in number
  ,p_advance_leave_earnings     in number
  ) return number;
  --
  function previous_period_end_date
  (p_payroll_id                 in number
  ,p_time_period_id             in number
  ) return date;
  --

  FUNCTION get_accrual_entitlement
  (p_assignment_id     IN  NUMBER
  ,p_payroll_id        IN  NUMBER
  ,p_business_group_id IN  NUMBER
  ,p_plan_id           IN  NUMBER
  ,p_calculation_date  IN  DATE
  ,p_net_accrual       OUT NOCOPY NUMBER
  ,p_net_entitlement   OUT NOCOPY NUMBER
  ,p_calc_start_date   OUT NOCOPY DATE
  ,p_last_accrual      OUT NOCOPY DATE
  ,p_next_period_end   OUT NOCOPY DATE)
  RETURN NUMBER;
  --
  ---------------------------------------------------------------------
  --
  --  ANNUAL_LEAVE_NET_ENTITLEMENT
  --
  --  Purpose : Wraps get_accrual_entitlement with parameters
  --            to match the Leave liability process.
  --  Returns : Total entitlement
  --
  ---------------------------------------------------------------------
  --
  PROCEDURE annual_leave_net_entitlement
  (p_assignment_id     IN  NUMBER
  ,p_payroll_id        IN  NUMBER
  ,p_business_group_id IN  NUMBER
  ,p_plan_id           IN  NUMBER
  ,p_calculation_date  IN  DATE
  ,p_start_date        OUT NOCOPY DATE
  ,p_end_date          OUT NOCOPY DATE
  ,p_net_entitlement   OUT NOCOPY NUMBER);

  function get_previous_rate
  (p_element_type_id      number
  ,p_assignment_action_id number /*Bug 3654766*/
  ,p_rate_name            varchar2
  ) return number;
  --

  -- Bug 3608752
  -- Parental Leave changes
  -- Created the following functions
  --
  FUNCTION is_parental_leave_taken
  (p_assignment_id      IN NUMBER
  ,p_business_group_id  IN NUMBER
  ,p_start_date         IN DATE
  ,p_end_date           IN DATE)
  RETURN NUMBER;
  --
  FUNCTION get_entitled_amount
  (p_payroll_id             NUMBER
  ,p_payroll_action_id      NUMBER
  ,p_assignment_id          NUMBER
  ,p_business_group_id      NUMBER
  ,p_accrual_plan_id        NUMBER
  ,p_absence_start_date     DATE
  ,p_period_start_date      DATE
  ,p_period_end_date        DATE
  ,p_entitled_leave_taken   NUMBER
  ,p_curr_rate              NUMBER
  ,p_hire_date              DATE
  ,p_average_rate_p12mths   NUMBER)
  RETURN NUMBER;
  --
  FUNCTION  get_recur_abs_prev_period
  (p_assignment_id        IN NUMBER
  ,p_payroll_id           IN NUMBER
  ,p_absence_start_date   IN DATE
  ,p_curr_aniv_start      IN DATE
  ,p_prev_period_end_date IN DATE
  ,p_plan_id              IN NUMBER
  )
  RETURN NUMBER;

end pay_nz_holidays_2003;

/
