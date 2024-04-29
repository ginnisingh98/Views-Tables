--------------------------------------------------------
--  DDL for Package HR_AU_HOLIDAYS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_AU_HOLIDAYS" AUTHID CURRENT_USER AS
  --  $Header: hrauhol.pkh 120.0.12010000.3 2008/12/17 05:40:49 pmatamsr ship $
  --
  --    Copyright (C) 2000 Oracle Corporation
  --    All Rights Reserved
  --
  --    Script to create AU HRMS hr_au_holidays package
  --
  --  Change List
  --  ===========
  --
  --  Date        Author      Ver     Description
  --  -----------+---------+-------+------------------------------------------
  --  16 Dec 2008 pmatamsr  115.14  Bug#7607177-Added function au_get_enrollment_startdate to
  --                                retrieve the PTO accrual enrollment start date.
  --  02 Dec 2002 Apunekar  115.12  Bug#2689173-Added Nocopy to out and in out parameters
  --  10-Dec-2001 srussell  115.10  Put in checkfile syntax.
  --  28-Nov-2001 nnaresh   115.9   Updated for GSCC Standards
  --  12-Sep-2001 shoskatt  115.8   Included the get_leave_initialise function. Bug #1942971
  --  25-Jan-2000 sclarke   115.7   Moved term_lsl_eligibility_years to pay_au_terminations
  --  29-May-2000 makelly   115.6   Added get_net_accrual_wrapper back
  --  26-May-2000 makelly   115.5   Bug 1313971 Removed get_net_accrual wrapper.
  --  03-May-2000 makelly   115.4   Bug 1273677 and added accrual_entitlement fn
  --                                to simplify calls from accrual/absence forms
  --  21-Mar-2000 makelly   115.3   Bug in call to asg_working_hours
  --  15-MAR-2000 sclarke   115.2   New procedure for LSL
  --  21 Jan 2000 makelly   115.1   Initial - Based on hrnzhol.pkh
  --

  g_package constant varchar2(33) := ' hr_au_holidays.';

  FUNCTION get_accrual_plan_by_category
  (p_assignment_id    IN    NUMBER
  ,p_effective_date   IN    DATE
  ,p_plan_category    IN    VARCHAR2)
  RETURN NUMBER;

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


  -----------------------------------------------------------------------------
  --  accrual_daily_basis function
  -----------------------------------------------------------------------------

 FUNCTION accrual_daily_basis
  ( p_payroll_id                   IN      NUMBER
   ,p_accrual_plan_id              IN      NUMBER
   ,p_assignment_id                IN      NUMBER
   ,p_calculation_start_date       IN      DATE
   ,p_calculation_end_date         IN      DATE
   ,p_service_start_date           IN      DATE
   ,p_business_group_hours         IN      NUMBER
   ,p_business_group_freq          IN      VARCHAR2)
   RETURN NUMBER ;

FUNCTION days_suspended
 ( p_assignment_id       IN NUMBER
  ,p_start_date          IN DATE
  ,p_end_date            IN DATE)
  RETURN NUMBER;

FUNCTION check_periods
 ( p_payroll_id                   IN      NUMBER)
  RETURN DATE;

FUNCTION adjust_for_suspend_assign
 ( p_assignment_id                    IN NUMBER
  ,p_adjust_date                      IN DATE
  ,p_start_date                       IN DATE
  ,p_end_date                         IN DATE)
  RETURN DATE;

----------------------------------------------------------------------
---  Bug #1942971 ---- Start
----------------------------------------------------------------------
FUNCTION get_leave_initialise
 ( p_assignment_id                    IN       NUMBER
  ,p_accrual_plan_id                  IN       NUMBER
  ,p_calc_end_date                    IN       DATE
  ,p_initialise_type                  IN       VARCHAR2
  ,p_start_date                       IN       DATE
  ,p_end_date                         IN       DATE)
RETURN NUMBER;
----------------------------------------------------------------------
---  Bug #1942971 ---- End
----------------------------------------------------------------------

FUNCTION get_lsl_entitlement_date
 ( p_accrual_plan_id                  IN       NUMBER
  ,p_assignment_id                    IN       NUMBER
  ,p_enrollment_date                  IN       DATE
  ,p_service_start_date               IN       DATE
  ,p_calculation_date                 IN       DATE
  ,p_next_entitlement_date            IN OUT NOCOPY  DATE)
  RETURN DATE;

FUNCTION validate_accrual_plan_name
    ( p_business_group_id             IN          NUMBER
     ,p_entry_value                   IN          VARCHAR2)
     RETURN NUMBER;

 /*Bug# 7607177 --added function au_get_enrollment_startdate to get the enrollment
                  start date for calculation of PTO Accrual*/

FUNCTION au_get_enrollment_startdate
 ( p_accrual_plan_id                  IN      NUMBER
  ,p_assignment_id                    IN      NUMBER
  ,p_calculation_date                 IN      DATE )
  RETURN DATE;

END hr_au_holidays ;

/
