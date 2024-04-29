--------------------------------------------------------
--  DDL for Package PAY_FR_OVERTIME
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FR_OVERTIME" AUTHID CURRENT_USER as
/* $Header: pyfrovtm.pkh 115.6 2004/03/31 08:33:54 autiwari noship $ */
function calculate_band
(p_low_value number
,p_band_hours number
,p_overtime_hours number
,p_weekly_reference_hours number
,p_band_factor number
,p_pay_rate number
,p_compensation_method varchar2
,p_high_value out nocopy number
,p_band_full_factor out nocopy number
,p_band_full_pay_rate out nocopy number
,p_band_full_hours out nocopy number
,p_band_full_pay out nocopy number
,p_band_full_accrual out nocopy number
,p_band_reduced_actor out nocopy number
,p_band_reduced_pay_rate out nocopy number
,p_band_reduced_hours out nocopy number
,p_band_reduced_pay out nocopy number
,p_band_reduced_accrual out nocopy number) return number;
--
/* Package Globals */
g_week_end_date date;
--
function set_scheme(p_assignment_id number
                          ,p_date date) return number;
--
function get_scheme(p_scheme_item varchar2) return varchar2;
--
function get_band(p_band number
                 ,p_label out nocopy varchar2
                 ,p_hours out nocopy number
                 ,p_hours_percentage out nocopy number
                 ,p_factor out nocopy number) return number;
--
function last_regularisation
(P_ASSIGNMENT_ID NUMBER
,P_DATE_EARNED DATE
,P_RANGE_END_DATE DATE
,P_RANGE_START_DATE DATE) return date;
--
function determine_regularisation
(P_ASSIGNMENT_ID NUMBER
,P_DATE_EARNED DATE
,P_OVERTIME_PAYROLL_ID NUMBER
,P_PERIOD_TYPE VARCHAR2
,P_NUMBER_OF_WEEKS NUMBER
,P_START_DATE DATE
,P_CURRENT_WEEK_END_DATE DATE
,P_PERIOD_START_DATE OUT NOCOPY DATE
,P_PERIOD_END_DATE OUT NOCOPY DATE) return varchar2;
--
function get_overtime_weeks(p_overtime_payroll_id number
                           ,p_week_start_date date
                           ,p_week_end_date date) return number;
--
function get_overtime_week_dates(p_overtime_payroll_id number
                                ,p_payroll_start_date date
                                ,p_week_number number
                                ,p_week_start_date out nocopy date
                                ,p_week_end_date out nocopy date) return number;
--
function get_overtime_week_dates(p_payroll_id number
                                ,p_overtime_payroll_id number
                                ,p_payroll_start_date date
                                ,p_week_number number
                                ,p_week_start_date out nocopy date
                                ,p_week_end_date out nocopy date) return number;
--
function get_week_details(p_assignment_id number
                         ,p_effective_date date
                         ,p_business_group_id number
                         ,p_assignment_action_id number
                         ,p_payroll_action_id number
                         ,p_week_start_date date
                         ,p_week_end_date date
                         ,p_formula_id number
                         ,p_overtime_hours out nocopy number
                         ,p_quota_hours out nocopy number
                         ,p_compensation_hours out nocopy number) return number;
--
function regularisation(p_assignment_id number
                       ,p_effective_date date
                       ,p_business_group_id number
                       ,p_assignment_action_id number
                       ,p_payroll_action_id number
                       ,p_reg_period_start_date date
                       ,p_reg_period_end_date date
                       ,p_formula_id number
                       ,p_b1_pay_ff out nocopy number
                       ,p_b1_hours_ff out nocopy number
                       ,p_b1_hourly_rate_ff out nocopy number
                       ,p_b1_full_factor out nocopy number
                       ,p_b1_accrual_ff out nocopy number
                       ,p_b1_label_ff out nocopy varchar2
                       ,p_b1_pay_rf out nocopy number
                       ,p_b1_hours_rf out nocopy number
                       ,p_b1_hourly_rate_rf out nocopy number
                       ,p_b1_reduced_factor out nocopy number
                       ,p_b1_accrual_rf out nocopy number
                       ,p_b1_label_rf out nocopy varchar2
                       ,p_b2_pay_ff out nocopy number
                       ,p_b2_hours_ff out nocopy number
                       ,p_b2_hourly_rate_ff out nocopy number
                       ,p_b2_full_factor out nocopy number
                       ,p_b2_accrual_ff out nocopy number
                       ,p_b2_label_ff out nocopy varchar2
                       ,p_b2_pay_rf out nocopy number
                       ,p_b2_hours_rf out nocopy number
                       ,p_b2_hourly_rate_rf out nocopy number
                       ,p_b2_reduced_factor out nocopy number
                       ,p_b2_accrual_rf out nocopy number
                       ,p_b2_label_rf out nocopy varchar2
                       ,p_b3_pay_ff out nocopy number
                       ,p_b3_hours_ff out nocopy number
                       ,p_b3_hourly_rate_ff out nocopy number
                       ,p_b3_full_factor out nocopy number
                       ,p_b3_accrual_ff out nocopy number
                       ,p_b3_label_ff out nocopy varchar2
                       ,p_b3_pay_rf out nocopy number
                       ,p_b3_hours_rf out nocopy number
                       ,p_b3_hourly_rate_rf out nocopy number
                       ,p_b3_reduced_factor out nocopy number
                       ,p_b3_accrual_rf out nocopy number
                       ,p_b3_label_rf out nocopy varchar2
                       ,p_b4_pay_ff out nocopy number
                       ,p_b4_hours_ff out nocopy number
                       ,p_b4_hourly_rate_ff out nocopy number
                       ,p_b4_full_factor out nocopy number
                       ,p_b4_accrual_ff out nocopy number
                       ,p_b4_label_ff out nocopy varchar2
                       ,p_b4_pay_rf out nocopy number
                       ,p_b4_hours_rf out nocopy number
                       ,p_b4_hourly_rate_rf out nocopy number
                       ,p_b4_reduced_factor out nocopy number
                       ,p_b4_accrual_rf out nocopy number
                       ,p_b4_label_rf out nocopy varchar2
                       ,p_b5_pay_ff out nocopy number
                       ,p_b5_hours_ff out nocopy number
                       ,p_b5_hourly_rate_ff out nocopy number
                       ,p_b5_full_factor out nocopy number
                       ,p_b5_accrual_ff out nocopy number
                       ,p_b5_label_ff out nocopy varchar2
                       ,p_b5_pay_rf out nocopy number
                       ,p_b5_hours_rf out nocopy number
                       ,p_b5_hourly_rate_rf out nocopy number
                       ,p_b5_reduced_factor out nocopy number
                       ,p_b5_accrual_rf out nocopy number
                       ,p_b5_label_rf out nocopy varchar2
                       ,p_b6_pay_ff out nocopy number
                       ,p_b6_hours_ff out nocopy number
                       ,p_b6_hourly_rate_ff out nocopy number
                       ,p_b6_full_factor out nocopy number
                       ,p_b6_accrual_ff out nocopy number
                       ,p_b6_label_ff out nocopy varchar2
                       ,p_b6_pay_rf out nocopy number
                       ,p_b6_hours_rf out nocopy number
                       ,p_b6_hourly_rate_rf out nocopy number
                       ,p_b6_reduced_factor out nocopy number
                       ,p_b6_accrual_rf out nocopy number
                       ,p_b6_label_rf out nocopy varchar2
) return number;
--
function check_existing_overtime_week
(p_assignment_id number
,p_element_type_id number
,p_date_earned date
,p_week_end_date date) return varchar2;
--
function get_period_balance
(p_assignment_id number
,p_date_earned date
,p_business_group_id number
,p_element varchar2
,p_start_input varchar2
,p_start_date date
,p_end_input varchar2
,p_end_date date
,p_value_input varchar2) return number;
--
--
------------------------------------------------------------------------
-- Function GET_NORMAL_WEEK_HOURS
--
-- This function will retrieve the normal working hours as of the overtime
-- week end date and convert them into a weekly frequency
------------------------------------------------------------------------
function get_normal_week_hours
(p_business_group_id number
,p_assignment_id number
,p_effective_date date) return number;
--
end pay_fr_overtime;

 

/
