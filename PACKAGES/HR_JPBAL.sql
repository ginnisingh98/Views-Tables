--------------------------------------------------------
--  DDL for Package HR_JPBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_JPBAL" AUTHID CURRENT_USER AS
/* $Header: pyjpbal.pkh 120.0.12000000.2 2007/02/21 04:02:28 keyazawa noship $ */
/* ------------------------------------------------------------------------------------ */
	PROCEDURE check_expiry(
			p_owner_payroll_action_id	IN	NUMBER,
			p_user_payroll_action_id	IN	NUMBER,
			p_owner_assignment_action_id	IN	NUMBER,
			p_user_assignment_action_id	IN	NUMBER,
			p_owner_effective_date		IN	DATE,
			p_user_effective_date		IN	DATE,
			p_dimension_name		IN	VARCHAR2,
			p_expiry_information	 OUT NOCOPY NUMBER);
/* ------------------------------------------------------------------------------------ */
	PROCEDURE check_expiry(
			p_owner_payroll_action_id	IN	NUMBER,
			p_user_payroll_action_id	IN	NUMBER,
			p_owner_assignment_action_id	IN	NUMBER,
			p_user_assignment_action_id	IN	NUMBER,
			p_owner_effective_date		IN	DATE,
			p_user_effective_date		IN	DATE,
			p_dimension_name		IN	VARCHAR2,
			p_expiry_information	 OUT NOCOPY DATE);
/* ------------------------------------------------------------------------------------ */
	FUNCTION balance(
			p_assignment_action_id	IN NUMBER,
			p_defined_balance_id    IN NUMBER)
	RETURN NUMBER;
/* ------------------------------------------------------------------------------------ */
	FUNCTION balance(
			p_assignment_action_id	IN NUMBER,
			p_item_name		IN VARCHAR2)
	RETURN NUMBER;
/* ------------------------------------------------------------------------------------ */
	PROCEDURE create_dimension(
			errbuf		 OUT NOCOPY VARCHAR2,
			retcode		 OUT NOCOPY NUMBER,
			p_business_group_id	IN NUMBER,
			p_suffix		IN VARCHAR2,
			p_level			IN VARCHAR2,
			p_dim_date_type		IN VARCHAR2,
			p_start_dd_mm		IN VARCHAR2,
			p_frequency		IN NUMBER);
/* ------------------------------------------------------------------------------------ */
	FUNCTION calc_balance_date(
			p_assignment_id		IN NUMBER,
			p_balance_type_id	IN NUMBER,
			p_effective_date	IN DATE,
			p_dimension_name	IN VARCHAR2)
	RETURN NUMBER;
/* ------------------------------------------------------------------------------------ */
	FUNCTION calc_asg_run_action(
			p_assignment_action_id	IN NUMBER,
			p_balance_type_id	IN NUMBER)
	RETURN NUMBER;
/* ------------------------------------------------------------------------------------ */
	FUNCTION calc_asg_run_date(
			p_assignment_id		IN NUMBER,
			p_balance_type_id	IN NUMBER,
			p_effective_date	IN DATE)
	RETURN NUMBER;
/* ------------------------------------------------------------------------------------ */
	FUNCTION calc_asg_run(
	        	p_assignment_action_id  IN NUMBER,
		        p_balance_type_id       IN NUMBER,
			p_assignment_id		IN NUMBER)
	RETURN NUMBER;
/* ------------------------------------------------------------------------------------ */
	FUNCTION calc_asg_proc_ptd_action(
			p_assignment_action_id	IN NUMBER,
			p_balance_type_id	IN NUMBER)
	RETURN NUMBER;
/* ------------------------------------------------------------------------------------ */
	FUNCTION calc_asg_proc_ptd_date(
			p_assignment_id		IN NUMBER,
			p_balance_type_id	IN NUMBER,
			p_effective_date	IN DATE)
	RETURN NUMBER;
/* ------------------------------------------------------------------------------------ */
	FUNCTION calc_asg_proc_ptd(
			p_assignment_action_id	IN NUMBER,
			p_balance_type_id	IN NUMBER,
			p_assignment_id		IN NUMBER)
	RETURN NUMBER;
/* ------------------------------------------------------------------------------------ */
	FUNCTION calc_asg_mtd_jp_action(
			p_assignment_action_id	IN NUMBER,
			p_balance_type_id	IN NUMBER)
	RETURN NUMBER;
/* ------------------------------------------------------------------------------------ */
	FUNCTION calc_asg_mtd_jp_date(
			p_assignment_id		IN NUMBER,
			p_balance_type_id	IN NUMBER,
			p_effective_date	IN DATE)
	RETURN NUMBER;
/* ------------------------------------------------------------------------------------ */
	FUNCTION calc_asg_mtd_jp(
			p_assignment_action_id	IN NUMBER,
			p_balance_type_id	IN NUMBER,
			p_assignment_id		IN NUMBER)
	RETURN NUMBER;
/* ------------------------------------------------------------------------------------ */
	FUNCTION calc_asg_ytd_jp_action(
			p_assignment_action_id	IN NUMBER,
			p_balance_type_id	IN NUMBER)
	RETURN NUMBER;
/* ------------------------------------------------------------------------------------ */
	FUNCTION calc_asg_ytd_jp_date(
			p_assignment_id		IN NUMBER,
			p_balance_type_id	IN NUMBER,
			p_effective_date	IN DATE)
	RETURN NUMBER;
/* ------------------------------------------------------------------------------------ */
	FUNCTION calc_asg_ytd_jp(
			p_assignment_action_id	IN NUMBER,
			p_balance_type_id	IN NUMBER,
			p_assignment_id		IN NUMBER)
	RETURN NUMBER;
/* ------------------------------------------------------------------------------------ */
	FUNCTION calc_asg_fytd_jp_action(
			p_assignment_action_id	IN NUMBER,
			p_balance_type_id	IN NUMBER)
	RETURN NUMBER;
/* ------------------------------------------------------------------------------------ */
	FUNCTION calc_asg_fytd_jp_date(
			p_assignment_id		IN NUMBER,
			p_balance_type_id	IN NUMBER,
			p_effective_date	IN DATE)
	RETURN NUMBER;
/* ------------------------------------------------------------------------------------ */
	FUNCTION calc_asg_fytd_jp(
			p_assignment_action_id	IN NUMBER,
			p_balance_type_id	IN NUMBER,
			p_assignment_id		IN NUMBER)
	RETURN NUMBER;
/* ------------------------------------------------------------------------------------ */
	FUNCTION calc_asg_fytd2_jp_action(
			p_assignment_action_id	IN NUMBER,
			p_balance_type_id	IN NUMBER)
	RETURN NUMBER;
/* ------------------------------------------------------------------------------------ */
	FUNCTION calc_asg_fytd2_jp_date(
			p_assignment_id		IN NUMBER,
			p_balance_type_id	IN NUMBER,
			p_effective_date	IN DATE)
	RETURN NUMBER;
/* ------------------------------------------------------------------------------------ */
	FUNCTION calc_asg_fytd2_jp(
			p_assignment_action_id	IN NUMBER,
			p_balance_type_id	IN NUMBER,
			p_assignment_id		IN NUMBER)
	RETURN NUMBER;
/* ------------------------------------------------------------------------------------ */
  function calc_asg_apr2mar_jp_action(
    p_assignment_action_id in number,
    p_balance_type_id      in number)
  return number;
/* ------------------------------------------------------------------------------------ */
  function calc_asg_apr2mar_jp_date(
    p_assignment_id   in number,
    p_balance_type_id in number,
    p_effective_date  in date)
  return number;
/* ------------------------------------------------------------------------------------ */
  function calc_asg_apr2mar_jp(
    p_assignment_action_id in number,
    p_balance_type_id      in number,
    p_assignment_id        in number)
  return number;
/* ------------------------------------------------------------------------------------ */
	FUNCTION calc_asg_aug2jul_jp_action(
			p_assignment_action_id	IN NUMBER,
			p_balance_type_id	IN NUMBER)
	RETURN NUMBER;
/* ------------------------------------------------------------------------------------ */
	FUNCTION calc_asg_aug2jul_jp_date(
			p_assignment_id		IN NUMBER,
			p_balance_type_id	IN NUMBER,
			p_effective_date	IN DATE)
	RETURN NUMBER;
/* ------------------------------------------------------------------------------------ */
	FUNCTION calc_asg_aug2jul_jp(
			p_assignment_action_id	IN NUMBER,
			p_balance_type_id	IN NUMBER,
			p_assignment_id		IN NUMBER)
	RETURN NUMBER;
/* ------------------------------------------------------------------------------------ */
	FUNCTION calc_asg_jul2jun_jp_action(
			p_assignment_action_id	IN NUMBER,
			p_balance_type_id	IN NUMBER)
	RETURN NUMBER;
/* ------------------------------------------------------------------------------------ */
	FUNCTION calc_asg_jul2jun_jp_date(
			p_assignment_id		IN NUMBER,
			p_balance_type_id	IN NUMBER,
			p_effective_date	IN DATE)
	RETURN NUMBER;
/* ------------------------------------------------------------------------------------ */
	FUNCTION calc_asg_jul2jun_jp(
			p_assignment_action_id	IN NUMBER,
			p_balance_type_id	IN NUMBER,
			p_assignment_id		IN NUMBER)
	RETURN NUMBER;
/* ------------------------------------------------------------------------------------ */
	FUNCTION calc_asg_itd_action(
			p_assignment_action_id	IN NUMBER,
			p_balance_type_id	IN NUMBER)
	RETURN NUMBER;
/* ------------------------------------------------------------------------------------ */
	FUNCTION calc_asg_itd_date(
			p_assignment_id		IN NUMBER,
			p_balance_type_id	IN NUMBER,
			p_effective_date	IN DATE)
	RETURN NUMBER;
/* ------------------------------------------------------------------------------------ */
	FUNCTION calc_asg_itd(
			p_assignment_action_id	IN NUMBER,
			p_balance_type_id	IN NUMBER,
			p_assignment_id		IN NUMBER)
	RETURN NUMBER;
/* ------------------------------------------------------------------------------------ */
	FUNCTION calc_retro_action(
			p_assignment_action_id	IN NUMBER,
			p_balance_type_id	IN NUMBER)
	RETURN NUMBER;
/* ------------------------------------------------------------------------------------ */
	FUNCTION calc_retro_date(
			p_assignment_id		IN NUMBER,
			p_balance_type_id	IN NUMBER,
			p_effective_date	IN DATE)
	RETURN NUMBER;
/* ------------------------------------------------------------------------------------ */
	FUNCTION calc_retro(
			p_assignment_action_id	IN NUMBER,
			p_balance_type_id	IN NUMBER,
			p_assignment_id		IN NUMBER)
	RETURN NUMBER;
/* ------------------------------------------------------------------------------------ */
	FUNCTION calc_payment_action(
			p_assignment_action_id	IN NUMBER,
			p_balance_type_id	IN NUMBER)
	RETURN NUMBER;
/* ------------------------------------------------------------------------------------ */
	FUNCTION calc_payment_date(
			p_assignment_id		IN NUMBER,
			p_balance_type_id	IN NUMBER,
			p_effective_date	IN DATE)
	RETURN NUMBER;
/* ------------------------------------------------------------------------------------ */
	FUNCTION calc_payment(
			p_assignment_action_id	IN NUMBER,
			p_balance_type_id	IN NUMBER,
			p_assignment_id		IN NUMBER)
	RETURN NUMBER;
/* ------------------------------------------------------------------------------------ */
	FUNCTION calc_element_itd_bal(
			p_assignment_action_id	IN NUMBER,
			p_balance_type_id	IN NUMBER,
			p_source_id		IN NUMBER)
	RETURN NUMBER;
/* ------------------------------------------------------------------------------------ */
	FUNCTION calc_element_ptd_bal(
			p_assignment_action_id	IN NUMBER,
			p_balance_type_id	IN NUMBER,
			p_source_id		IN NUMBER)
	RETURN NUMBER;
-----------------------------------------------------------------------
	FUNCTION get_element_reference(
			p_run_result_id        IN NUMBER,
       		        p_database_item_suffix IN VARCHAR2)
	RETURN VARCHAR2;
/* ------------------------------------------------------------------------------------ */
	FUNCTION calc_all_balances(
			p_assignment_action_id	IN NUMBER,
			p_defined_balance_id	IN NUMBER)
	RETURN NUMBER;
/* ------------------------------------------------------------------------------------ */
	FUNCTION calc_all_balances(
			p_effective_date	IN DATE,
			p_assignment_id		IN NUMBER,
			p_defined_balance_id	IN NUMBER)
	RETURN NUMBER;
/* ------------------------------------------------------------------------------------ */
END hr_jpbal;
 

/
