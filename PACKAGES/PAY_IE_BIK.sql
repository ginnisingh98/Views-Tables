--------------------------------------------------------
--  DDL for Package PAY_IE_BIK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IE_BIK" AUTHID CURRENT_USER AS
/* $Header: pyiebik.pkh 120.0.12010000.2 2009/03/20 05:48:16 knadhan ship $ */

FUNCTION get_global_value(p_name in VARCHAR2,
                          p_effective_date in DATE)
return number;

FUNCTION get_max_start_date(p_payroll_action_id IN number,
                            p_max_start_date in DATE,
                            p_benefit_start_date IN DATE)
return date;

FUNCTION get_max_no_of_periods(p_payroll_action_id  in number,
                               p_maximum_start_date in DATE,
                               p_minimum_end_date in DATE,
                               p_formula_context in varchar2)
return number;

FUNCTION get_least_date(p_payroll_action_id  in number,
                        c_end_date in date)
return date;


FUNCTION get_balance_values(p_assignment_action_id number,
                            p_source_id number,
                            p_date_earned date,
                            p_balance_name varchar2)
return number ;

FUNCTION get_address(l_address_type varchar2,
                     l_address_id varchar2)
return varchar2;

FUNCTION get_landlord_address(l_address_type varchar2,
                              l_address_id varchar2)
return varchar2 ;
/*ADDED 3 new functions for Bug No. 3745749*/
FUNCTION GET_INV_UNA_DAYS(p_element_entry_id in number,
                          p_vehicle_alloc_end_date in DATE,
			  p_curr_period_end_date in DATE) return number;
FUNCTION GET_INV_TOT_MLGE(p_element_entry_id in number,
                          p_vehicle_alloc_end_date in DATE,
			  p_curr_period_end_date in DATE) return number;
FUNCTION GET_INV_BUS_MLGE(p_element_entry_id in number,
                          p_vehicle_alloc_end_date in DATE,
			  p_curr_period_end_date in DATE) return number;

/*ADDED for 2009 BIK Vehicle based on Emission 8236523 */
FUNCTION get_fiscal_rating(p_allocation_id in number)
                        return number;

end pay_ie_bik;

/
