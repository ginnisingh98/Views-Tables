--------------------------------------------------------
--  DDL for Package PAY_AE_GENERAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AE_GENERAL" AUTHID CURRENT_USER as
/* $Header: pyaegenr.pkh 120.2 2005/11/10 03:05:26 abppradh noship $ */

--
--


------------------------------------------------------------------------
-- Function LOCAL_NATNATIONALITY_NOT_DEFINED
------------------------------------------------------------------------
	function local_nationality_not_defined return varchar2;
------------------------------------------------------------------------
-- Function LOCAL_NATNATIONALITY_MATCHES
------------------------------------------------------------------------
function local_nationality_matches
		(p_assignment_id IN per_all_assignments_f.assignment_id%type,
		 p_date_earned IN Date)
	 return varchar2;

------------------------------------------------------------------------
-- Function GET_LOCAL_NATIONALITY
------------------------------------------------------------------------
	function get_local_nationality return varchar2;
------------------------------------------------------------------------
-- Function GET_SECTOR
------------------------------------------------------------------------
	function get_sector (p_tax_unit_id IN NUMBER) return varchar2;
------------------------------------------------------------------------
-- Function GET_MESSAGE
------------------------------------------------------------------------
	function get_message
			(p_product           in varchar2
			,p_message_name      in varchar2
			,p_token1            in varchar2 default null
                        ,p_token2            in varchar2 default null
                        ,p_token3            in varchar2 default null)
			return varchar2;
------------------------------------------------------------------------
-- Function GET_TABLE_BANDS
------------------------------------------------------------------------
        function get_table_bands
			(p_Date_Earned     IN DATE
			,p_table_name        in varchar2
			,p_return_type       in varchar2) return number;

-----------------------------------------------------------
-- Functions for EFT file
-----------------------------------------------------------
--
FUNCTION  get_parameter (
          p_parameter_string  in varchar2
         ,p_token             in varchar2
         ,p_segment_number    in number default null) RETURN varchar2;
--
FUNCTION  chk_multiple_assignments(p_effective_date IN DATE
                                  ,p_person_id     IN NUMBER) RETURN VARCHAR2;
--
function get_count RETURN NUMBER;
--
function get_total_sum RETURN NUMBER;
--
function get_credit_sum RETURN NUMBER;
--
function get_debit_sum RETURN NUMBER;
--
function chk_tran_code (p_value IN	VARCHAR2)  RETURN VARCHAR2;
--
------------------------------------------------------------------------
-- Function get_contract
------------------------------------------------------------------------
  function get_contract
    (p_assignment_id IN per_all_assignments_f.assignment_id%type,
     p_date_earned   IN Date)
    return varchar2;
------------------------------------------------------------------------
-- Function get_contract_expiry_status
------------------------------------------------------------------------
  function get_contract_expiry_status
    (p_assignment_id IN per_all_assignments_f.assignment_id%type,
     p_date_earned   IN Date)
    return varchar2;
------------------------------------------------------------------------
-- Function get_termination_initiator
------------------------------------------------------------------------
  function get_termination_initiator
    (p_assignment_id IN per_all_assignments_f.assignment_id%type,
     p_date_earned   IN Date)
    return varchar2;

------------------------------------------------------------------------
-- Function user_gratuity_formula_exists
------------------------------------------------------------------------
  function user_gratuity_formula_exists
    (p_assignment_id IN per_all_assignments_f.assignment_id%type,
     p_date_earned   IN Date)
    return varchar2;

--
------------------------------------------------------------------------
-- Function run_gratuity_formula
------------------------------------------------------------------------
  function run_gratuity_formula
   (p_assignment_id         IN NUMBER
   ,p_date_earned           IN DATE
   ,p_business_group_id     IN NUMBER
   ,p_payroll_id            IN NUMBER
   ,p_payroll_action_id     IN NUMBER
   ,p_assignment_action_id  IN NUMBER
   ,p_tax_unit_id           IN NUMBER
   ,p_element_entry_id      IN NUMBER
   ,p_element_type_id       IN NUMBER
   ,p_original_entry_id     IN NUMBER
   ,p_monthly_gratuity      OUT NOCOPY NUMBER
   ,p_paid_gratuity         OUT NOCOPY NUMBER
   )
  return NUMBER;



------------------------------------------------------------------------
-- Function run_gratuity_salary_formula
------------------------------------------------------------------------
 function run_gratuity_salary_formula
   (p_assignment_id         IN NUMBER
   ,p_date_earned           IN DATE
   ,p_business_group_id     IN NUMBER
   ,p_payroll_id            IN NUMBER
   ,p_payroll_action_id     IN NUMBER
   ,p_assignment_action_id  IN NUMBER
   ,p_tax_unit_id           IN NUMBER
   ,p_element_entry_id      IN NUMBER
   ,p_element_type_id       IN NUMBER
   ,p_original_entry_id     IN NUMBER
   )
  return NUMBER;

------------------------------------------------------------------------
-- Function get_unauth_absence
-- Function for fetching unauthorised absences
------------------------------------------------------------------------
 function get_unauth_absence
   (p_assignment_id         IN NUMBER
   ,p_date_earned           IN DATE
   ,p_business_group_id     IN NUMBER
   --,p_period_start_date     IN VARCHAR2
   --,p_period_end_date       IN VARCHAR2
   )
  return NUMBER;

------------------------------------------------------------------------
-- Function get_gratuity_basis
-- Function for fetching gratuity basis
------------------------------------------------------------------------
 function get_gratuity_basis
   (p_assignment_id         IN NUMBER
   ,p_date_earned           IN DATE
   )
  return VARCHAR2;


end pay_ae_general;

 

/
