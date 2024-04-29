--------------------------------------------------------
--  DDL for Package PAY_NO_HOLIDAY_PAY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NO_HOLIDAY_PAY" AUTHID CURRENT_USER AS
  /* $Header: pynoholp.pkh 120.0.12000000.1 2007/05/22 07:56:31 rajesrin noship $ */

   -- Function to get the G value.
   FUNCTION get_grate(p_business_group_id IN NUMBER,   p_effective_date IN DATE) RETURN NUMBER;

  --Funtion to get the age of a person as on 31-AUG of the holiday year.
  FUNCTION get_age(p_payroll_proc_start_date IN DATE,   p_date_of_birth IN DATE) RETURN NUMBER;

  /* Function to whether the payroll run is the last payroll run of the year in order
 recalulate the holiday pay over 60*/ FUNCTION get_last_payroll(p_payroll_id IN NUMBER,   p_pay_proc_period_end_date IN DATE) RETURN VARCHAR2;

  -- Function to get the assignments status.
  FUNCTION get_assg_status(p_business_group_id IN NUMBER,   p_asg_id IN NUMBER,   p_pay_proc_period_start_date IN DATE,   p_pay_proc_period_end_date IN DATE) RETURN VARCHAR2;

  -- Function to get the entitlement days as years last payroll run end date.
  FUNCTION get_entitlement_days(p_business_group_id IN NUMBER,   p_asg_id IN NUMBER,   p_tax_unit_id IN NUMBER,   p_effective_date IN DATE,   p_above_60 IN VARCHAR2,   p_entit_days OUT nocopy NUMBER,
           p_entit_days_over_60 OUT nocopy NUMBER) RETURN NUMBER;

  -- Function to get the previous employer details.
  /* Bug 5344736 fix - Adding assignment start date parameter*/
  FUNCTION get_prev_employer_days(p_business_group_id IN NUMBER,   p_assg_id IN NUMBER,   p_emp_hire_date IN DATE,  p_asg_start_date IN DATE) RETURN NUMBER;

  -- Function to get the fixed period for a payroll.
  FUNCTION get_fixed_period(p_payroll_id IN NUMBER,   p_start_date IN DATE) RETURN NUMBER;

  -- Function to get the holiday details required for hoiliday pay calculation.
  FUNCTION get_hol_parameters(p_bus_group_id IN NUMBER,   p_assignment_id IN NUMBER,   p_date_earned IN DATE,   p_tax_unit_id IN NUMBER,   p_hourly_salaried_code IN OUT nocopy VARCHAR2,   p_holiday_entitlement IN OUT nocopy VARCHAR2,
           p_holiday_pay_calc_basis IN OUT nocopy VARCHAR2,   p_holiday_pay_in_fixed_period IN OUT nocopy VARCHAR2,   p_hol_pay_over60_in_fix_period IN OUT nocopy VARCHAR2,   p_holiday_pay_to_be_adjusted IN OUT nocopy VARCHAR2,
	   p_res_hol_pay_to_6g_for_over60 IN OUT nocopy VARCHAR2) RETURN NUMBER;

  -- Function to get the assignment start date.

  /*Bug 5334894 fix- Added a new function to get the assignment start date*/
  FUNCTION get_asg_start_date(p_business_group_id IN NUMBER,   p_assignment_id IN NUMBER,   p_asg_start_date OUT nocopy DATE) RETURN NUMBER;

   --Function to get the accrual act information from absence details
    FUNCTION get_abs_hol_accr_entitl (p_bus_group_id IN NUMBER,   p_assignment_id IN NUMBER,   p_date_earned IN DATE,   p_tax_unit_id IN NUMBER
                                      , p_hol_accrual_entit OUT nocopy VARCHAR2) RETURN NUMBER;

END;

 

/
