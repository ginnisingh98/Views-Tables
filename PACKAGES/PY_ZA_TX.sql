--------------------------------------------------------
--  DDL for Package PY_ZA_TX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PY_ZA_TX" AUTHID CURRENT_USER AS
/* $Header: pyzatax.pkh 120.2 2005/06/28 00:11:47 kapalani noship $ */

/* Function to calculate tax on a given amount, with no rebate taken into account*/
  PRAGMA RESTRICT_REFERENCES(py_za_tx, WNDS);

  FUNCTION calc_tax_on_table(
    payroll_action_id NUMBER, --context
    p_taxable_amount NUMBER,
    p_tax_rebate  NUMBER
  ) RETURN NUMBER;



/* Function to calculate arrear pension fund abatement on a monthly basis
   as well as the arrear excess figure that should be taken over
   to the next year
*/
  FUNCTION arr_pen_mon_check(
    p_tax_status  IN VARCHAR2,
    p_start_site IN VARCHAR2,
    p_site_factor IN NUMBER,
    p_pen_ind IN VARCHAR2,
    p_apf_ptd_bal IN NUMBER,
    p_apf_ytd_bal IN NUMBER,
    p_apf_exces_bal IN NUMBER,
    p_periods_left IN NUMBER,
    p_period_factor IN NUMBER,
    p_possible_periods_left IN NUMBER,
    p_max_abate IN NUMBER,
    p_exces_itd_upd OUT NOCOPY NUMBER
    ) RETURN NUMBER;

/* Function to calculate arrear retirement annuity abatement on a monthly basis
   as well as the arrear excess figure that should be taken over
   to the next year
*/
  FUNCTION arr_ra_mon_check(
    p_tax_status  In VARCHAR2,
    p_start_site  VARCHAR2,
    p_site_factor  NUMBER,
    p_ra_ind  VARCHAR2,
    p_ara_ptd_bal  NUMBER,
    p_ara_ytd_bal  NUMBER,
    p_ara_exces_bal  NUMBER,
    p_periods_left  NUMBER,
    p_period_factor  NUMBER,
    p_possible_periods_left  NUMBER,
    p_max_abate  NUMBER,
    p_exces_itd_upd OUT NOCOPY NUMBER
    ) RETURN NUMBER;

/* Function: za_site_paye_split to calculate the split between site and paye */
  FUNCTION site_paye_split(
    p_total_tax  IN NUMBER,
    p_tax_on_travel  IN NUMBER,
    p_tax_on_pub_off  IN NUMBER,
    p_site_lim  IN NUMBER,
    p_qual  IN VARCHAR2
    ) RETURN NUMBER;

/* Function: calc_tax_on_perc to calculate tax on a percentage according to tax status */
  FUNCTION calc_tax_on_perc(
    p_amount  IN NUMBER,
    p_tax_status  IN VARCHAR2,
    p_tax_directive_value  IN NUMBER,
    p_cc_tax_perc  IN NUMBER,
    p_temp_tax_perc  IN NUMBER
    )  RETURN NUMBER;

/* Function: tax_period_factor calculates the period factor for the person,
   i.e. did the person work a full period or a half or even one and a half.
*/
  FUNCTION tax_period_factor(
    p_tax_year_start_date  IN DATE,
    p_asg_start_date  IN DATE,
    p_cur_period_start_date  IN DATE,
    p_cur_period_end_date  IN DATE,
    p_total_inc_ytd  IN NUMBER,
    p_total_inc_ptd  IN NUMBER
    )  RETURN NUMBER;

/* Function: pp_factor calculates the possible days the person could work in the year as a factor*/
  FUNCTION tax_pp_factor(
    p_tax_year_start_date  IN DATE,
    p_tax_year_end_date  IN DATE,
    p_asg_start_date  IN DATE,
    p_days_in_year  IN NUMBER
    )  RETURN NUMBER;


/* Function: annualise is used to annualise an amount */
  FUNCTION annualise(
    p_ytd_income  IN NUMBER,
    p_ptd_income  IN NUMBER,
    p_period_left  IN NUMBER,
    p_pp_factor  IN NUMBER,
    p_period_factor  IN NUMBER
    ) RETURN NUMBER;


/* Function to determine if employee has been terminated */
  FUNCTION za_emp_terminated(
    p_ee_date_to IN DATE,
    p_cps_date IN DATE,
    p_cpe_date IN DATE
    ) RETURN VARCHAR2;


/* Function to determine if pay period is a site period or not */
  FUNCTION za_site_period(
    p_pay_periods_left IN NUMBER,
    p_asg_date_to IN DATE,
    p_current_period_start_date IN DATE,
    p_current_period_end_date IN DATE
    ) RETURN VARCHAR2;


/* Function to determine number of days worked in a year, including weekends and holidays*/
  FUNCTION za_days_worked(
    p_asg_date_from IN DATE,
    p_asg_date_to IN DATE,
    p_za_tax_year_from IN DATE,
    p_za_tax_year_to IN DATE
    ) RETURN NUMBER;


/* Function ytd_days_worked calculates the number of days worked up to the present date */
  FUNCTION ytd_days_worked(
    p_tax_year_start  IN DATE,
    p_asg_date_from  IN DATE,
    p_cur_period_start  IN DATE
    ) RETURN NUMBER;


/* Function cal_days_worked calculates the number of days worked from 01 JAN to tax year start*/
  FUNCTION cal_days_worked(
    p_tax_year_start  IN DATE,
    p_asg_date_from  IN DATE
    ) RETURN NUMBER;

/* Function get_ytd_bal_val calculates the ytd balance total
   for balance TRAVELLING_ALLOWANCE_ASG_TAX_YTD.
   This balance is calculated dynamicly since
   the global value it must be multiplied with
   may change during the year and there is no taxable
   balance that is kept. */

  FUNCTION get_ytd_car_allow_val (
    assignment_id  NUMBER,
    p_tax_year_start_date DATE,
    p_tax_year_end_date DATE,
    p_current_period_end_date DATE,
    p_global_value  VARCHAR2
    ) RETURN NUMBER;

/* Fucntion get_cal_car_allow_val calculates the taxbale value of
   balance TRAVELLING_ALLOWANCE for the asg_cal_ytd dimention with
   the applicable global value at the effective time. */

  FUNCTION get_cal_car_allow_val (
  assignment_id  NUMBER,
  p_tax_year_start_date DATE
  ) RETURN NUMBER;



END py_za_tx;

 

/
