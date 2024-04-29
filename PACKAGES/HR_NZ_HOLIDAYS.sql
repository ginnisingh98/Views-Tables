--------------------------------------------------------
--  DDL for Package HR_NZ_HOLIDAYS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_NZ_HOLIDAYS" AUTHID CURRENT_USER AS
  --  $Header: hrnzhol.pkh 115.19 2003/12/21 17:17:09 sclarke ship $
  --
  --    Copyright (C) 1999 Oracle Corporation
  --    All Rights Reserved
  --
  --    Script to create NZ HRMS hr_nz_holidays package
  --
  --  Change List
  --  ===========
  --
  --  Date        Author      Reference Description
  --  -----------+-----------+---------+---------------------------------------
  --  22 Dec 2003 sclarke     3064179   altered comments
  --  06 Dec 2003 sclarke     3064179   Changed for NZ holidays 2003
  --                                    Added comments to indicate redundant
  --                                    functions
  --  13 Mar 2003 vgsriniv    2264070   Added the function check_retro_eoy
  --  03 Dec 2002 srrajago    2689221   Included 'nocopy' option to the 'out'
  --                                    and 'in out' parameters of all the
  --                                    procedures and functions.
  --  25 Jun 2002 vgsriniv    2366349   Added a function get_adjustment_values
  --  12 May 2002 apunekar    2364468   Corrected for errors on 9i.
  --  21 Mar 2002 vgsriniv    2264070   Added functions to handle leaves
  --                                    retroed after EOY period
  --  24 Jan 2002 vgsriniv    2185116   Added two extra parameters to function
  --                                    annual_leave_entitled_to_pay
  --  17 Jan 2002 vgsriniv    2183135   Added function get_acp_start_date
  --  04 Dec 2001 vgsriniv    2127114   added function get_leap_year_mon
  --  31-JUL 2001 rbsinha     1422001   added function average_accrual_rate
  --  02-Jun 2000 SClarke     1323990   Display of Leave accrual vs entitlement
  --  26 Jan 2000 JTurner     1098494   Modified annual_leave_eoy_adjustment
  --                                    function to cater for no carryover
  --  25 Jan 2000 JTurner     1098494   Modified annual_leave_entitled_to_pay
  --                                    function to cater for no carryover
  --  14 Jan 2000 JTURNER     1098494   Added accrual_period_basis
  --                                    function.
  --  11 Jan 2000 J Turner              Moved Header symbol to 2nd line for
  --                                    standards compliance and removed
  --                                    pragmas.
  --  13 Aug 1999 P.Macdonald           Add new functions
  --  30 Jul 1999 J Turner              Added get_net_accrual fn
  --  25 Jul 1999 P.Macdonald           Created

  g_package constant varchar2(33) := ' hr_nz_holidays.';

  FUNCTION get_acp_start_date
  (p_assignment_id    IN    NUMBER
  ,p_plan_id          IN    NUMBER
  ,p_effective_date   IN    DATE)
  RETURN DATE;

  FUNCTION get_accrual_plan_by_category
  (p_assignment_id    IN    NUMBER
  ,p_effective_date   IN    DATE
  ,p_plan_category    IN    VARCHAR2)
  RETURN NUMBER;

  --
  -- =========================================================
  -- 3064179
  -- get_accrual_entitlement
  -- This function becomes redundant on 01-APR-2004
  -- =========================================================
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

 function check_periods
  (p_payroll_id                   in      number)
  return date;
--
--  get_net_accrual
--
--  This function is a wrapper for the
--  per_accrual_calc_functions.get_net_accrual procedure.  The
--  wrapper is required so that a FastFormula function can be
--  registered for use in formulas.
--

  FUNCTION get_net_accrual
  (p_assignment_id     IN  NUMBER
  ,p_payroll_id        IN  NUMBER
  ,p_business_group_id IN  NUMBER
  ,p_plan_id           IN  NUMBER
  ,p_calculation_date  IN  DATE)
  RETURN NUMBER;

  -- =========================================================
  -- 3064179
  -- This function becomes redundant on 01-APR-2004
  -- =========================================================
  PROCEDURE annual_leave_net_entitlement
  (p_assignment_id     IN  NUMBER
  ,p_payroll_id        IN  NUMBER
  ,p_business_group_id IN  NUMBER
  ,p_plan_id           IN  NUMBER
  ,p_calculation_date  IN  DATE
  ,p_start_date        OUT NOCOPY DATE
  ,p_end_date          OUT NOCOPY DATE
  ,p_net_entitlement   OUT NOCOPY NUMBER);

  FUNCTION get_net_entitlement
  (p_assignment_id     IN  NUMBER
  ,p_payroll_id        IN  NUMBER
  ,p_business_group_id IN  NUMBER
  ,p_calculation_date  IN  DATE)
  RETURN NUMBER;

  FUNCTION call_accrual_formula
  (p_assignment_id      IN NUMBER
  ,p_payroll_id         IN NUMBER
  ,p_business_group_id  IN NUMBER
  ,p_accrual_plan_name  IN VARCHAR2
  ,p_formula_name       IN VARCHAR2
  ,p_calculation_date   IN DATE)
  RETURN NUMBER;

  FUNCTION get_annual_leave_plan
  (p_assignment_id      IN NUMBER
  ,p_business_group_id  IN NUMBER
  ,p_calculation_date   IN DATE)
  RETURN NUMBER;

  FUNCTION get_continuous_service_date
  (p_assignment_id      IN NUMBER
  ,p_business_group_id  IN NUMBER
  ,p_accrual_plan_id    IN NUMBER
  ,p_calculation_date   IN DATE)
  RETURN DATE;

  -- =========================================================
  -- 3064179
  -- This function becomes redundant on 01-APR-2004
  -- =========================================================
  FUNCTION get_anniversary_date
  (p_assignment_id      IN NUMBER
  ,p_business_group_id  IN NUMBER
  ,p_calculation_date   IN DATE)
  RETURN DATE;
  -- PRAGMA RESTRICT_REFERENCES(get_anniversary_date, WNDS, WNPS);

  -- =========================================================
  -- 3064179
  -- This function is now redundant
  -- Anniversary is calculated differently
  -- =========================================================
  FUNCTION get_last_anniversary
  (p_assignment_id      IN NUMBER
  ,p_business_group_id  IN NUMBER
  ,p_calculation_date   IN DATE)
  RETURN DATE;

  FUNCTION get_annual_entitlement
  (p_assignment_id      IN NUMBER
  ,p_business_group_id  IN NUMBER
  ,p_calculation_date   IN DATE)
  RETURN NUMBER;

  FUNCTION get_annual_leave_taken
  (p_assignment_id      IN NUMBER
  ,p_business_group_id  IN NUMBER
  ,p_calculation_date   IN DATE
  ,p_start_date         IN DATE
  ,p_end_date           IN DATE)
  RETURN NUMBER;

  FUNCTION num_weeks_for_avg_earnings
  (p_assignment_id      IN  NUMBER
  ,p_start_of_year_date IN  DATE)
  RETURN NUMBER;

  FUNCTION get_ar_element_details
  (p_assignment_id               IN NUMBER
  ,p_business_group_id           IN NUMBER
  ,p_calculation_date            IN DATE
  ,p_element_type_id             OUT NOCOPY NUMBER
  ,p_accual_plan_name_iv_id      OUT NOCOPY NUMBER
  ,p_holiday_year_end_date_iv_id OUT NOCOPY NUMBER
  ,p_hours_accrued_iv_id         OUT NOCOPY NUMBER)
  RETURN NUMBER;


/* Bug# 2185116 Added p_ordinary_rate and p_type parameters */
  FUNCTION annual_leave_entitled_to_pay
  (p_assignment_id      IN NUMBER
  ,p_business_group_id  IN NUMBER
  ,p_payroll_id         in number
  ,p_calculation_date   IN DATE
  ,p_entitled_to_hours  IN NUMBER
  ,p_start_date         IN DATE
  ,p_anniversary_date   IN DATE
  ,p_working_hours      IN NUMBER
  ,p_ordinary_rate      IN NUMBER
  ,p_type               IN VARCHAR2 DEFAULT 'H')
  RETURN NUMBER;

  -- =========================================================
  -- 3064179
  -- This function becomes redundant on 01-APR-2004
  -- =========================================================
  -----------------------------------------------------------------------------
  --  annual_leave_eoy_adjustment
  -----------------------------------------------------------------------------
  function annual_leave_eoy_adjustment
  (p_business_group_id            in     number
  ,p_payroll_id                   in     number
  ,p_assignment_id                in     number
  ,p_asg_hours                    in     number
  ,p_year_end_date                in     date
  ,p_in_advance_pay_carryover     in out nocopy number
  ,p_in_advance_hours_carryover   in out nocopy number)
  return number ;

FUNCTION get_weekdays_in_period
 (p_start_date          IN DATE
 ,p_end_date            IN DATE)
 RETURN NUMBER;

function get_leap_year_mon
  (p_start_date    in date
  ,p_end_date      in date)
return number;

  -- =========================================================
  -- 3064179
  -- This function becomes redundant on 01-APR-2004
  --  accrual_period_basis function
  -- =========================================================
  function accrual_period_basis
  (p_payroll_id                   in      number
  ,p_accrual_plan_id              in      number
  ,p_assignment_id                in      number
  ,p_calculation_start_date       in      date
  ,p_calculation_end_date         in      date
  ,p_service_start_date           in      date
  ,p_business_group_hours         in      number
  ,p_business_group_freq          in      varchar2)
  return number ;
  --
  -- =========================================================
  -- 3064179
  -- This function becomes redundant on 01-APR-2004
  --  accrual_daily_basis function
  -- =========================================================
  function accrual_daily_basis
  (p_payroll_id                   in      number
  ,p_accrual_plan_id              in      number
  ,p_assignment_id                in      number
  ,p_calculation_start_date       in      date
  ,p_calculation_end_date         in      date
  ,p_service_start_date           in      date
  ,p_anniversary_date             in      date
  ,p_business_group_hours         in      number
  ,p_business_group_freq          in      varchar2)
  return number ;
  -----------------------------------------------------------------------------
  --  function to get the average accrual rate  - bug 1422001
  --  used for leave liability process
  -----------------------------------------------------------------------------
function  average_accrual_rate(
              p_assignment_id    IN  per_all_assignments_f.assignment_id%type
             ,p_calculation_date IN  date
             ,p_anniversary_date IN  date
             ,p_asg_hours        IN  number ) return number ;

/* Bug 2264070 Added the following 5 functions to handle leaves retroed after
   EOY period */

function get_act_ann_lev_pay(
              p_assignment_id   IN number
             ,p_element_entry_id IN number
             ,p_assgt_action_id IN number
             ,p_effective_date IN date) return number;

function num_of_weeks_for_avg_earnings(
              p_assignment_id IN  number
             ,p_hol_ann_date IN date) RETURN  number;

function get_current_action_type(
              p_payroll_id       IN  number ) return number;


function gross_earnings_ytd_for_retro(
              p_assignment_id     IN  per_all_assignments_f.assignment_id%type
             ,p_effective_date    IN  date) return number;

function retro_start_date(
              p_assignment_id      IN number) return date;

/* Bug 2366349 Added the function to handle adjustment elements for accrual
   and entitlement */

function get_adjustment_values
  (p_assignment_id                   in      NUMBER
  ,p_accrual_plan_id                 in      NUMBER
  ,p_calc_end_date                   in      DATE
  ,p_adjustment_element              in      VARCHAR2
  ,p_start_date                      in      DATE
  ,p_end_date                        in      DATE)
  return number;

/* Bug 2264070 */
function check_retro_eoy(p_element_entry_id in number)
         Return number;

END hr_nz_holidays ;

 

/
