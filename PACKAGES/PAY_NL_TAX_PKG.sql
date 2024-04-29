--------------------------------------------------------
--  DDL for Package PAY_NL_TAX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NL_TAX_PKG" AUTHID CURRENT_USER as
/* $Header: pynltax.pkh 120.0.12010000.5 2009/12/18 17:25:42 rsahai ship $ */

FUNCTION get_age_payroll_period(p_assignment_id   IN  NUMBER
                               ,p_payroll_id      IN  NUMBER
                               ,p_date_earned     IN  DATE)
                               RETURN NUMBER;

FUNCTION check_age_payroll_period(p_person_id   IN  NUMBER
                               ,p_payroll_id      IN  NUMBER
                               ,p_date_earned     IN  DATE)
                               RETURN NUMBER;

FUNCTION get_age_calendar_year(p_assignment_id   IN  NUMBER
                              ,p_date_earned     IN  DATE)
                              RETURN NUMBER;

FUNCTION get_age_system_date(p_assignment_id   IN  NUMBER
                             ,p_date_earned     IN  DATE)
                              RETURN NUMBER;

FUNCTION chk_lbr_tx_indicator (p_person_id number,p_assignment_id number)
	return	boolean;

FUNCTION get_payroll_prd(p_payroll_id number)
	RETURN VARCHAR2;

PROCEDURE chk_tax_code (p_tax_code in varchar2,
                           p_pay_num in number,
                           p_1_digit out nocopy varchar2,
                           p_2_digit out nocopy varchar2,
                           p_3_digit out nocopy varchar2,
                           p_valid out nocopy boolean
                          );
PROCEDURE get_period_type_code(p_payroll_prd in Varchar2,p_period_type out nocopy varchar2,p_period_code out nocopy number);

PROCEDURE set_spl_inds(  p_spl_ind1 in varchar2
                        ,p_spl_ind2 in varchar2
                        ,p_spl_ind3 in varchar2
                        ,p_spl_ind4 in varchar2
                        ,p_spl_ind5 in varchar2
                        ,p_spl_ind6 in varchar2
                        ,p_spl_ind7 in varchar2
                        ,p_spl_ind8 in varchar2
                        ,p_spl_ind9 in varchar2
                        ,p_spl_ind10 in varchar2
                        ,p_spl_ind11 in varchar2
                        ,p_spl_ind12 in varchar2
                        ,p_spl_ind13 in varchar2
                        ,l_set out nocopy boolean
                        ,p_spl_ind out nocopy varchar2);

PROCEDURE get_spl_inds( p_spl_ind in  varchar2
                        ,p_spl_ind1 out nocopy varchar2
                        ,p_spl_ind2 out nocopy varchar2
                        ,p_spl_ind3 out nocopy varchar2
                        ,p_spl_ind4 out nocopy varchar2
                        ,p_spl_ind5 out nocopy varchar2
                        ,p_spl_ind6 out nocopy varchar2
                        ,p_spl_ind7 out nocopy varchar2
                        ,p_spl_ind8 out nocopy varchar2
                        ,p_spl_ind9 out nocopy varchar2
                        ,p_spl_ind10 out nocopy varchar2
                        ,p_spl_ind11 out nocopy varchar2
                        ,p_spl_ind12 out nocopy varchar2
                        ,p_spl_ind13 out nocopy varchar2
                        );

FUNCTION get_age_hire_date(p_business_group_id   IN  NUMBER
                               ,p_assignment_id      IN  NUMBER
                               ,p_date_earned     IN  DATE)
                               RETURN NUMBER;
Function chk_contribution_exempt (p_assignment_id IN NUMBER
                                  ,p_date_earned IN DATE
					    ,p_assignment_action_id IN NUMBER
				  ,p_marginal_flag OUT nocopy VARCHAR2
				  ,p_influence_flag OUT nocopy VARCHAR2
				  ,p_warning OUT nocopy VARCHAR2
                                  ) return number;

FUNCTION check_age_date_paid(p_assignment_id   IN  NUMBER
                               ,p_payroll_id      IN  NUMBER
                               ,p_payroll_action_id     IN  NUMBER)
                               RETURN NUMBER;

END PAY_NL_TAX_PKG;

/
