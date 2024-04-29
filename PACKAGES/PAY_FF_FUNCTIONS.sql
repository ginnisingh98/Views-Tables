--------------------------------------------------------
--  DDL for Package PAY_FF_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FF_FUNCTIONS" AUTHID CURRENT_USER as
/* $Header: pyfffunc.pkh 120.6.12010000.2 2009/05/08 10:28:22 sudedas ship $ */
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
----------------------------------------------------
-- Function to calculate Maximum Exclusion Allowance
----------------------------------------------------
function Calc_max_excl_allow (
    p_payroll_action_id             in number,
    p_ee_incld_annual_comp          in number,
    p_total_er_contr_prior_years in number,
    p_years_of_service              in number
    )
 Return number;
--------------------------------------
-- Function to calculate Overall Limit
--------------------------------------
Function Calc_overall_limit (
    p_payroll_action_id             in number,
    p_ee_incld_annual_comp      in number
    )
Return Number;
--
--
---------------------------------------
-- Function to calculate Any Year Limit
---------------------------------------
Function Calc_any_year_limit (
    p_payroll_action_id             in number,
    p_ee_incld_annual_comp          in number,
    p_total_er_contr_prior_years in number,
    p_years_of_service              in number
    )
Return number;
--
--
-------------------------------------------------
-- Function to calculate year of separation Limit
-------------------------------------------------
Function Calc_year_of_sep_limit(
    p_payroll_action_id             in number,
    p_assignment_id                     in number,
    p_ee_incld_annual_comp              in number,
    p_total_er_contr_prior_years        in number,
    p_years_of_service                  in number
    )
Return number;
--
--
-------------------------------------------------
-- Function to calculate effective deferral limit
-------------------------------------------------
Function Calc_elec_def_limit(
    p_payroll_action_id             in number,
    p_catch_up              in varchar2,
    p_total_elec_def        in number,
    p_years_of_service      in number,
    p_catch_up_amt          in number
    )
Return number;
--
--
------------------------------------------
-- Function to calculate length of service
------------------------------------------
Function Calc_length_of_service(
    p_payroll_action_id             in number,
    p_assignment_id     in number,
    p_dummy in varchar)
Return number;
--
------------------------------------------
-- Function to check whether employee is
-- enrolled in both 403(b) and 457 plans
------------------------------------------
------------------------------------------
Function Check_if_emp_in_403b_457_plan(
                 p_payroll_action_id             in number,
		 p_assignment_id in number,
                 p_dummy in VARCHAR)
Return varchar;
--
------------------------------------------
-- Function to Get the 403B Limit
------------------------------------------
Function Get_PQP_Limit(
    p_effective_date                IN DATE   DEFAULT NULL,
    p_payroll_action_id             IN NUMBER DEFAULT NULL,
    p_limit                         IN VARCHAR)
Return number;
--
------------------------------------------

------------------------------------------
-- Function to Get the Annual Salary
------------------------------------------
Function Get_annual_salary (
     p_payroll_action_id in number,
     p_assignment_id     in number,
     p_as_of_date        in date )
Return number;
--
------------------------------------------
-- Function to get the 457 Limit
------------------------------------------
Function get_457_annual_Limit(
    p_effective_date                IN DATE   DEFAULT NULL,
    p_payroll_action_id             IN NUMBER DEFAULT NULL,
    p_limit                         in varchar)
Return number;
----------------------------------------------------
-- Function to calculate 457 limit
----------------------------------------------------
function get_457_calc_limit (
    p_payroll_action_id             in number,
    p_ee_incld_annual_comp          in number
    )
 Return number;

----------------------------------------------------
-- Function to calculate previously unused
----------------------------------------------------
function calc_prev_unused (
    p_assignment_id                 in number,
    p_payroll_action_id             in number,
    p_dummy			    in varchar
    )
return number;
------------------------------------------
----------------------------------------------------
-- Function to calculate 457 vested amount
----------------------------------------------------
function get_457_vested_amt (
   p_assignment_id    in number,
   p_payroll_action_id             in number,
   p_dummy            in varchar)
return number;


----------------------------------------------
--- Function Run Year
----------------------------------------------
function Run_Year (
           p_payroll_action_id             in number,
           p_dummy          in varchar)
return number;

GLB_ORIGINAL_ENTRY_ID NUMBER;
GLB_TEMPLATE_EARNINGS NUMBER;
GLB_STOP_ENTRY_FLAG   VARCHAR2(10);

function get_template_earnings (
           p_ctx_original_entry_id  NUMBER,
           p_template_earnings      NUMBER,
           p_accrued_value          NUMBER,
           p_maximum_amount         NUMBER,
           p_prorate_start_date     DATE,
           p_prorate_end_date       DATE,
           p_payroll_start_date     DATE,
           p_payroll_end_date       DATE,
           p_stop_entry_flag     OUT NOCOPY VARCHAR2,
           p_clear_accrued_flag  OUT NOCOPY VARCHAR2)
return number;

function check_authorization_date (
           p_ctx_original_entry_id  NUMBER,
           p_auth_end_date          DATE,
           p_prorate_end_date       DATE,
           p_payroll_end_date       DATE,
           p_clear_accrued_flag  OUT NOCOPY VARCHAR2)
return varchar2;


-- Global varibale for the function GET_CORRECT_FLSA_EARNINGS
-- Redeclared a new variable to store Original Entry ID as the previous
-- variable is set for the GET_TEMPLATE_EARNINGS function and can be
-- set before entering this function
GLB_PERIOD_EARNINGS number;
GLB_ORIGINAL_ENTRY_ID_2 number;

function get_earnings_calculation (
           p_ctx_asg_action_id      NUMBER,
           p_ctx_original_entry_id  NUMBER,
           p_adjust_flag            VARCHAR2,
           p_max_adjust_amount      NUMBER,
           p_total_earnings         NUMBER,
           p_period_earnings        NUMBER,
           p_prorate_end_date       DATE,
           p_payroll_end_date       DATE)
return number;

GLB_RR_ORIGINAL_ENTRY_ID NUMBER;
GLB_RR_SAL_BASIS_ELEMENT VARCHAR2(1);
GLB_RED_REG_ELE          VARCHAR2(1);
GLB_REG_ELEM             VARCHAR2(80);

function GET_SALARY_BASIS_DETAIL(
           original_entry_id  NUMBER,
           template_earning         NUMBER,
           hours_passed             NUMBER,
           red_reg_earnings  NUMBER,
           red_reg_hours     NUMBER,
           prorate_start            DATE,
           prorate_end              DATE,
           payroll_start_date       DATE,
           payroll_end_date         DATE,
           flsa_time_definition VARCHAR2,
           stop_run_flag        OUT NOCOPY VARCHAR2,
           reduced_template_earnings OUT NOCOPY NUMBER,
           reduced_hours_passed OUT NOCOPY NUMBER,
           red_reg_adjust_amount     NUMBER default 0.05,
           red_reg_adjust_hours      NUMBER default 0.01,
           red_reg_raise_error       VARCHAR2 default 'Y')
return varchar2;

GLB_TIME_DEFINITION_ID NUMBER;
GLB_TIME_DEFINITION_NAME VARCHAR2(80);
GLB_FLSA_TIME_DEFN VARCHAR2(1);

GLB_ASSIGNMENT_ACTION_ID NUMBER DEFAULT NULL;

function get_time_definition(
           TIME_DEFINITION_ID  NUMBER)
RETURN VARCHAR2;

END pay_ff_functions;

/
