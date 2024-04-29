--------------------------------------------------------
--  DDL for Package PAY_NO_HIGH_RATE_TAX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NO_HIGH_RATE_TAX" AUTHID CURRENT_USER as
 /* $Header: pynohtax.pkh 120.3.12010000.1 2008/07/27 23:14:21 appldev ship $ */
 --
 FUNCTION get_tax_values_high_rate    (
                             p_business_group_id IN number
				    ,p_Date_Earned  IN DATE
                            ,p_table_name          IN VARCHAR2
                            ,p_freq            IN VARCHAR2
                            ,p_ptd_amount         IN VARCHAR2
                            ,p_high_tax OUT NOCOPY VARCHAR2
                            ,p_high_tax_base OUT NOCOPY VARCHAR2
                            ,p_high_rate_tax OUT NOCOPY VARCHAR2) return varchar2;
 FUNCTION get_start_range    (
                              p_Date_Earned  IN DATE
                             ,p_business_group_id IN number
                             ,p_table_name          IN VARCHAR2
                             ,p_freq            IN VARCHAR2
                             ,p_ptd_amount         IN VARCHAR2
                             ,p_start_range OUT NOCOPY VARCHAR2) return varchar2;
 FUNCTION get_normal_tax    (
                              p_Date_Earned  IN DATE
                             ,p_business_group_id IN number
                             ,p_table_name          IN VARCHAR2
                             ,p_freq            IN VARCHAR2
                             ,p_type            IN VARCHAR2
                             ,p_ptd_amount         IN VARCHAR2
                             ,p_normal_tax OUT NOCOPY VARCHAR2) return varchar2;
 FUNCTION get_reduced_rule    (
                              p_payroll_action_id   IN number
                             ,p_payroll_id          IN VARCHAR2
                             ,p_reduced_rule OUT NOCOPY VARCHAR2) return varchar2;
function get_message
			(p_product           in varchar2
			,p_message_name      in varchar2
			,p_token1            in varchar2 default null
                        ,p_token2            in varchar2 default null
                        ,p_token3            in varchar2 default null) return varchar2;


-- Modified function get_prim_tax_card for Legislative changes 2007.

/*
 function get_prim_tax_card (
			      p_assignment_id   IN NUMBER
                             ,p_date_earned 	IN DATE
                             ,p_tax_card_type   OUT NOCOPY VARCHAR2
                             ,p_tax_municipality OUT NOCOPY VARCHAR2
                             ,p_tax_percentage   OUT NOCOPY VARCHAR2
                             ,p_tax_table_number OUT NOCOPY VARCHAR2
                             ,p_tax_table_type   OUT NOCOPY VARCHAR2
			     ,p_tft_value	 OUT NOCOPY VARCHAR2
			     ,p_tax_card_msg     OUT NOCOPY VARCHAR2 ) return varchar2;
*/

 function get_prim_tax_card (
			      p_assignment_id		IN NUMBER
                             ,p_date_earned 		IN DATE
			     ,p_assignment_action_id	IN NUMBER
			     ,p_payroll_action_id	IN NUMBER
                             ,p_tax_card_type   OUT NOCOPY VARCHAR2
                             ,p_tax_municipality OUT NOCOPY VARCHAR2
                             ,p_tax_percentage   OUT NOCOPY VARCHAR2
                             ,p_tax_table_number OUT NOCOPY VARCHAR2
                             ,p_tax_table_type   OUT NOCOPY VARCHAR2
			     ,p_tft_value	 OUT NOCOPY VARCHAR2
			     ,p_tax_card_msg     OUT NOCOPY VARCHAR2 ) return varchar2;


FUNCTION get_pay_holiday_rule  ( p_payroll_action_id IN NUMBER
			        ,p_payroll_id IN VARCHAR2
			        ,p_pay_holiday_rule OUT nocopy VARCHAR2) RETURN VARCHAR2 ;


END PAY_NO_HIGH_RATE_TAX;

/
