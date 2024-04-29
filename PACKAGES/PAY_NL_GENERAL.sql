--------------------------------------------------------
--  DDL for Package PAY_NL_GENERAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NL_GENERAL" AUTHID CURRENT_USER as
/* $Header: pynlgenr.pkh 120.4.12000000.3 2007/07/04 11:57:33 abhgangu noship $ */


-- +********************************************************************+
-- |                        PUBLIC FUNCTIONS                            |
-- +********************************************************************+

------------------------------------------------------------------------
-- Function GET_POSTAL_CODE
------------------------------------------------------------------------
function get_postal_code
			(p_postal_code  in varchar2)
return varchar2;

------------------------------------------------------------------------
-- Function GET_POSTAL_CODE_NEW
------------------------------------------------------------------------
function get_postal_code_new
			(p_postal_code  in varchar2)
return varchar2;


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

---------------------------------------------------------------------------
--  Function:    PAY_PERIOD_ASG_DATES
--  Description: Function returns pay period assignment dates
---------------------------------------------------------------------------

function get_period_asg_dates (p_assignment_id in number
		      ,p_period_start_date in date
		      ,p_period_end_date in date
		      ,p_asg_start_date out nocopy date
		      ,p_asg_end_date out nocopy date
		      ) return number ;

---------------------------------------------------------------------------
-- Function : get_run_result_value
-- Function returns the run result value given the assignment_action_id,
-- element_type_id, input_value_id,run_result_id
---------------------------------------------------------------------------

function get_run_result_value(p_assignment_action_id number
			      ,p_element_type_id number
                              ,p_input_value_id number
                              ,p_run_result_id number
                              ,p_UOM varchar2)return varchar2;


------------------------------------------------------------------
-- Function : get_run_result_value
-- This is a generic function that returns the run result value
-- given the assignment_action_id , element_Type_id,
-- input_value_id
------------------------------------------------------------------

function get_run_result_value(p_assignment_action_id number,
                              p_element_type_id number,
                              p_input_value_id number)return number;



---------------------------------------------------------------------------
-- Function : get_retro_period
-- Function returns the retro period for the given element_entry_id and
-- date_earned
---------------------------------------------------------------------------

function get_retro_period
        (
             p_element_entry_id in pay_element_entries_f.element_entry_id%TYPE,
             p_date_earned in pay_payroll_actions.date_earned%TYPE
        )    return date;

---------------------------------------------------------------------------
-- Function : get_defined_balance_id
-- Function returns the defined balance id
---------------------------------------------------------------------------
FUNCTION get_defined_balance_id(p_user_name IN VARCHAR2) RETURN NUMBER;

---------------------------------------------------------------------------
-- Function : get_iv_run_result
-- Function returns the input value run_result for the specified element
-- input value name
---------------------------------------------------------------------------
FUNCTION get_iv_run_result(p_run_result_id IN NUMBER
							,p_element_type_id IN NUMBER
							,p_input_value_name IN VARCHAR2) RETURN VARCHAR2;
---------------------------------------------------------------------------
-- Function : get_sit_type_name
-- Function returns the Si Type Name for specified Context Balance
---------------------------------------------------------------------------
FUNCTION get_sit_type_name(p_balance_type_id pay_balance_types.balance_type_id%TYPE
							,p_assgn_action_id  NUMBER
							,p_date_earned      DATE
							,p_si_type	    VARCHAR2) RETURN VARCHAR2;




---------------------------------------------------------------------------
-- Procedure : insert_leg_rule
-- Creates a Row in Pay_Legislation_Rules
---------------------------------------------------------------------------
PROCEDURE insert_leg_rule(errbuf out nocopy varchar2, retcode out nocopy  varchar2,p_retropay_method IN number) ;

---------------------------------------------------------------------------
-- Function : get_default_retro_definition
-- Function returns the Default Retro Definition ID
---------------------------------------------------------------------------
FUNCTION get_default_retro_definition(p_business_group_id IN number) RETURN number;

Function get_global_value(l_date_earned date,l_global_name varchar2) return varchar2;
Function get_global_value(l_date_earned date,l_payroll_action_id number,l_global_name varchar2) RETURN varchar2;



 --
------------------------- create_scl_flex_dict -------------------------
--
-- create the SCL key flexfield database items for a given id flex number.
--
procedure create_scl_flex_dict
(
    p_id_flex_num in number
);
--

---------------------------------------------------------------------------
-- Procedure : cache_formula
-- Procedure checks if a given Fast Formula at all exists and if so
-- then is it in a compiled state.
-- Four globals should be declared in the package where this procedure is
-- being called. The globals to be declared are as follows:
-- g_<function>_formula_exists  BOOLEAN := TRUE
-- g_<function>_formula_cached  BOOLEAN := FALSE
-- g_<function>_formula_id      ff_formulas_f.formula_id%TYPE
-- g_<function>_formula_name    ff_formulas_f.formula_name%TYPE
-- The usage of this function with the above declared globals can be
-- understood from the function get_part_time_perc in the package pay_nl_si_pkg
---------------------------------------------------------------------------
PROCEDURE cache_formula(p_formula_name           IN VARCHAR2
                        ,p_business_group_id     IN NUMBER
                        ,p_effective_date        IN DATE
                        ,p_formula_id		 IN OUT NOCOPY NUMBER
                        ,p_formula_exists	 IN OUT NOCOPY BOOLEAN
                        ,p_formula_cached	 IN OUT NOCOPY BOOLEAN
                        );

---------------------------------------------------------------------------
-- Procedure : run_formula
-- Procedure runs a fast formula and returns the result in the p_output
-- parameter.
---------------------------------------------------------------------------

PROCEDURE run_formula(p_formula_id      IN NUMBER
                     ,p_effective_date  IN DATE
                     ,p_formula_name    IN VARCHAR2
                     ,p_inputs          IN ff_exec.inputs_t
                     ,p_outputs         IN OUT NOCOPY ff_exec.outputs_t);



FUNCTION get_element_type_id(p_element_name VARCHAR2,
                             p_effective_date DATE)
RETURN number;

FUNCTION get_input_value_id(p_element_type_id NUMBER,
                            p_input_value_name VARCHAR2,
                            p_effective_date DATE)
RETURN number;

---------------------------------------------------------------------------
-- Function : get_employee_address
-- Function returns the Employee Address with no spaces in the postal code
---------------------------------------------------------------------------
FUNCTION get_employee_address(p_person_id       IN            NUMBER
                             ,p_effective_date  IN            DATE
                             ,p_house_number    IN OUT NOCOPY VARCHAR2
                             ,p_house_no_add    IN OUT NOCOPY VARCHAR2
                             ,p_street_name     IN OUT NOCOPY VARCHAR2
                             ,p_line1           IN OUT NOCOPY VARCHAR2
                             ,p_line2           IN OUT NOCOPY VARCHAR2
                             ,p_line3           IN OUT NOCOPY VARCHAR2
                             ,p_city            IN OUT NOCOPY VARCHAR2
                             ,p_country         IN OUT NOCOPY VARCHAR2
                             ,p_postal_code     IN OUT NOCOPY VARCHAR2
     			     ,p_address_type    IN            VARCHAR2  DEFAULT NULL
                             )
    RETURN NUMBER;
---------------------------------------------------------------------------
-- Function : get_emp_address
-- Function returns the Employee Address with postal code in the correct format
---------------------------------------------------------------------------
FUNCTION get_emp_address(p_person_id       IN            NUMBER
                             ,p_effective_date  IN            DATE
                             ,p_house_number    IN OUT NOCOPY VARCHAR2
                             ,p_house_no_add    IN OUT NOCOPY VARCHAR2
                             ,p_street_name     IN OUT NOCOPY VARCHAR2
                             ,p_line1           IN OUT NOCOPY VARCHAR2
                             ,p_line2           IN OUT NOCOPY VARCHAR2
                             ,p_line3           IN OUT NOCOPY VARCHAR2
                             ,p_city            IN OUT NOCOPY VARCHAR2
                             ,p_country         IN OUT NOCOPY VARCHAR2
                             ,p_postal_code     IN OUT NOCOPY VARCHAR2
     			     ,p_address_type    IN            VARCHAR2  DEFAULT NULL
                             )
    RETURN NUMBER;
---------------------------------------------------------------------------
-- Function : get_organization_address
-- Function returns the Organization Address with no spaces in the postal code
---------------------------------------------------------------------------
FUNCTION get_organization_address(p_org_id        IN            NUMBER
                                 ,p_bg_id         IN            NUMBER
                                 ,p_house_number  IN OUT NOCOPY VARCHAR2
                                 ,p_house_no_add  IN OUT NOCOPY VARCHAR2
                                 ,p_street_name	  IN OUT NOCOPY VARCHAR2
                                 ,p_line1	      IN OUT NOCOPY VARCHAR2
                                 ,p_line2	      IN OUT NOCOPY VARCHAR2
                                 ,p_line3	      IN OUT NOCOPY VARCHAR2
                                 ,p_city	      IN OUT NOCOPY VARCHAR2
                                 ,p_country	      IN OUT NOCOPY VARCHAR2
                                 ,p_postal_code	  IN OUT NOCOPY VARCHAR2
                                 )
   RETURN NUMBER;
---------------------------------------------------------------------------
-- Function : get_org_address
-- Function returns the Organization Address with postal code in the correct format
---------------------------------------------------------------------------
FUNCTION get_org_address(p_org_id        IN            NUMBER
                                 ,p_bg_id         IN            NUMBER
                                 ,p_house_number  IN OUT NOCOPY VARCHAR2
                                 ,p_house_no_add  IN OUT NOCOPY VARCHAR2
                                 ,p_street_name	  IN OUT NOCOPY VARCHAR2
                                 ,p_line1	      IN OUT NOCOPY VARCHAR2
                                 ,p_line2	      IN OUT NOCOPY VARCHAR2
                                 ,p_line3	      IN OUT NOCOPY VARCHAR2
                                 ,p_city	      IN OUT NOCOPY VARCHAR2
                                 ,p_country	      IN OUT NOCOPY VARCHAR2
                                 ,p_postal_code	  IN OUT NOCOPY VARCHAR2
                                 )
   RETURN NUMBER;

---------------------------------------------------------------------------
-- Function : get_country_name
-- Function returns the Contry name withe country_code as input parameter
---------------------------------------------------------------------------
FUNCTION get_country_name(p_territory_code IN  VARCHAR2)
  RETURN VARCHAR2;

-------------------------------------------------------------------------------
-- Function : get_retro_sum_sec_class
-- Function returns the sum of retrospective values for a sub classification
-- for a period.
-------------------------------------------------------------------------------
FUNCTION get_retro_sum_sec_class(p_retro_period IN DATE,
                            p_sec_class_name IN VARCHAR2,
			                 p_assact_id IN NUMBER)
RETURN NUMBER;
-------------------------------------------------------------------------------
-- Function : get_retro_sum_pri_class
-- Function returns the sum of retrospective values for a sub classification
-- for a period.
-------------------------------------------------------------------------------
FUNCTION get_retro_sum_pri_class(p_retro_period IN DATE,
                            p_pri_class_name IN VARCHAR2,
			                 p_assact_id IN NUMBER)
RETURN NUMBER;
-------------------------------------------------------------------------------
-- Function : get_retro_sum_element
-- Function returns the sum of retrospective values  values for an element
-------------------------------------------------------------------------------
FUNCTION get_retro_sum_element(p_retro_period IN DATE,
                               p_input_value_id IN NUMBER,
                               p_element_type_id  IN NUMBER,
                               p_context IN VARCHAR2,
			       p_end_of_year IN VARCHAR2,
			        p_assact_id IN NUMBER)
RETURN NUMBER;
------------------------------------------------------------------------------
--Function :get_sum_element_pri_class
--Function returns the sum of non retrospective values for an element
--Classification
-----------------------------------------------------------------------------
FUNCTION get_sum_element_pri_class(p_effective_date IN DATE,
                            p_pri_class_name IN VARCHAR2,
			                 p_assact_id IN NUMBER)
RETURN NUMBER;
-----------------------------------------------------------------------------
--Function :format_number_field
--Function returns formatted string for a number with decimal
-----------------------------------------------------------------------------
function format_number_field(p_number number,
                             p_mpy_factor number,
                             p_field_length number)
return varchar2;
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- Function :get_file_id
-- Function returns file id on the effective date
-------------------------------------------------------------------------------
FUNCTION  get_file_id(p_effective_date DATE) RETURN VARCHAR2;
-----------------------------------------------------------------------------
-- Function :get_parameter
-- Function returns the parameter to be passed
-------------------------------------------------------------------------------
FUNCTION  get_parameter (
          p_parameter_string  in varchar2
         ,p_token             in varchar2
         ,p_segment_number    in number default null) RETURN varchar2;

-----------------------------------------------------------------------------
-- Function :chk_multiple_assignments
-- Function to determine the existance of multiple assignments for an employee
-------------------------------------------------------------------------------
FUNCTION  chk_multiple_assignments(p_effective_date IN DATE
                                  ,p_person_id     IN NUMBER) RETURN VARCHAR2;

------------------------------------------------------------------------------
--Function :get_sum_element_sec_class
--Function returns the sum of non retrospective values for an element
--with the given Secondary Classification
-----------------------------------------------------------------------------
FUNCTION get_sum_element_sec_class(p_effective_date IN DATE,
				   p_sec_class_name IN VARCHAR2,
			           p_assact_id IN NUMBER)
RETURN NUMBER;

-----------------------------------------------------------------------------
-- Function :get_retro_status
-- Function to determine whether replacement retropay method is running
-------------------------------------------------------------------------------
FUNCTION get_retro_status(p_date_earned date,p_payroll_action_id number)
RETURN VARCHAR2;

-----------------------------------------------------------------------------
-- Function :get_num_payroll_periods
-- Function to get number of payroll periods in a year
-------------------------------------------------------------------------------
FUNCTION get_num_payroll_periods(p_payroll_action_id IN NUMBER)
RETURN NUMBER;
-----------------------------------------------------------------------------
-- Function :check_de_dp_dimension
-- Function to check whether Date paid or balance date dimenions to be used.
-------------------------------------------------------------------------------
FUNCTION check_de_dp_dimension(p_pay_act_id  NUMBER
                              ,p_ass_id      NUMBER
                              ,p_ass_act_id  NUMBER) RETURN VARCHAR2;

-----------------------------------------------------------------------------
-- Function :check_de_dp_dimension_old
-------------------------------------------------------------------------------
FUNCTION check_de_dp_dimension_old(p_pay_act_id  NUMBER
                              ,p_ass_id      NUMBER
                              ,p_ass_act_id  NUMBER) RETURN VARCHAR2;

-----------------------------------------------------------------------------
-- Function :check_de_dp_dimension
-- Function to check whether Date paid or balance date dimenions to be used.
-------------------------------------------------------------------------------
FUNCTION check_de_dp_dimension_qtd(p_pay_act_id  NUMBER
                                  ,p_ass_id      NUMBER
                                  ,p_ass_act_id  NUMBER
                                  ,p_type        VARCHAR2) RETURN VARCHAR2;
--
-----------------------------------------------------------------------------
-- Globals to be used in CHECK_DE_DP_DIMENSION.
-------------------------------------------------------------------------------
g_result VARCHAR2(5);
g_qtd_result VARCHAR2(5);
g_period_type VARCHAR2(30);
g_parent_id NUMBER;
g_payroll_action_id NUMBER;
g_assignment_id NUMBER;
g_Late_Hire_Indicator VARCHAR2(10);
--
--
END PAY_NL_GENERAL;

 

/
