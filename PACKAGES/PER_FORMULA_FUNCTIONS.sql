--------------------------------------------------------
--  DDL for Package PER_FORMULA_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_FORMULA_FUNCTIONS" AUTHID CURRENT_USER as
/* $Header: pefmlfnc.pkh 115.4 2002/12/05 16:31:17 pkakar ship $ */

TYPE varchar_80_tbl IS TABLE OF VARCHAR(80) INDEX BY BINARY_INTEGER;
TYPE number_tbl     IS TABLE OF NUMBER      INDEX BY BINARY_INTEGER;
TYPE date_tbl       IS TABLE OF DATE        INDEX BY BINARY_INTEGER;

--
/* =====================================================================
   Name    : Cache Formulas
   Purpose : Populates the PL/SQL table with the given formula_name. If
             the table is already cached, the formula is added.
   Returns : Nothing.
   ---------------------------------------------------------------------*/
procedure cache_formulas (p_formula_name in varchar2);
--
/* =====================================================================
   Name    : Cache Formulas (overloaded)
   Purpose : Populates the PL/SQL table with the given formula_id. If
             the table is already cached, the formula is added.
   Returns : Nothing.
   ---------------------------------------------------------------------*/
procedure cache_formulas (p_formula_id in number);
--
/* =====================================================================
   Name    : Get Cache Formula
   Purpose : Gets the formula_id from a cached pl/sql table to prevent
             a full table scan on ff_formulas_f for each person in the
             payroll run.
   Returns : formula_id if found, otherwise 0.
   ---------------------------------------------------------------------*/
function get_cache_formula(p_formula_name      in varchar2,
                           p_business_group_id in number,
                           p_calculation_date  in date)
                           return number;
--
/* =====================================================================
   Name    : Get Cache Formula (overloaded)
   Purpose : Gets the formula_name from a cached pl/sql table to prevent
             a hit on ff_formulas_f and ff_compiled_info_f.
   Returns : formula_name if found, otherwise null.
   ---------------------------------------------------------------------*/
function get_cache_formula(p_formula_id       in number,
                           p_calculation_date in date)
                           return varchar2;
--
/* =====================================================================
   Name    : Get Formula
   Purpose : Gets the formula_id from a cached pl/sql table to prevent
             a full table scan on ff_formulas_f for each person in the
             payroll run.
   Returns : formula_id if found, otherwise null.
   ---------------------------------------------------------------------*/
function get_formula(p_formula_name      in varchar2,
                     p_business_group_id in number,
                     p_calculation_date  in date)
                     return number;
--
/* =====================================================================
   Name    : Get Formula (overloaded)
   Purpose : Gets the formula_name from a cached pl/sql table to prevent
             a hit on ff_formulas_f and ff_compiled_info_f.
   Returns : formula_name if found, otherwise null.
   ---------------------------------------------------------------------*/
function get_formula(p_formula_id       in number,
                     p_calculation_date in date)
                     return varchar2;
--
/* =====================================================================
   Name    : Loop Control
   Purpose : To repeatedly run a formula while the CONTINUE_PROCESSING_FLAG
             output parameter is set to 'Y'. If the value is 'N' then the
             function will end normally otherwise it will abort.
   Returns : 0 if successful, 1 otherwise
   ---------------------------------------------------------------------*/
function loop_control(p_business_group_id number
		     ,p_calculation_date  date
		     ,p_assignment_id number
                     ,p_payroll_id number
                     ,p_accrual_plan_id number
		     ,p_formula_name   varchar2) return number;
--
/* =====================================================================
   Name    : call_formula
   Purpose : To run a named formula, with no inputs and no outputs
   Returns : 0 if successful, 1 otherwise
   ---------------------------------------------------------------------*/
function call_formula
(p_business_group_id number
,p_calculation_date date
,p_assignment_id number
,p_payroll_id number
,p_accrual_plan_id number
,p_formula_name   varchar2) return number;
--
/* =====================================================================
   Name    : run_formula
   Purpose : To run a named formula, handling the input and output
             parameters.
   ---------------------------------------------------------------------*/
procedure run_formula
(p_formula_name varchar2
,p_business_group_id number
,p_calculation_date date
,p_inputs ff_exec.inputs_t
,p_outputs IN OUT NOCOPY ff_exec.outputs_t);
--
/* =====================================================================
   Name    : run_formula
   Purpose : To run a named formula, handling the input and output
             parameters.
   ---------------------------------------------------------------------*/
procedure run_formula
(p_formula_id number
,p_calculation_date date
,p_inputs ff_exec.inputs_t
,p_outputs IN OUT NOCOPY ff_exec.outputs_t);
--
/* =====================================================================
   Name    : get_number
   Purpose : To retrieve the value of a numeric global variable
   Returns : The value of the varibale if found, NULL otherwise
   ---------------------------------------------------------------------*/
function get_number
(p_name varchar2) return number;
--
/* =====================================================================
   Name    : set_number
   Purpose : To set the value of a numeric global variable
   Returns : 0 if successful, 1 otherwise
   ---------------------------------------------------------------------*/
function set_number
(p_name varchar2
,p_value number) return number;
--
/* =====================================================================
   Name    : get_date
   Purpose : To retrieve the value of a date global variable
   Returns : The value of the varibale if found, NULL otherwise
   ---------------------------------------------------------------------*/
function get_date
(p_name varchar2) return date;
--
/* =====================================================================
   Name    : set_date
   Purpose : To set the value of a date global variable
   Returns : 0 if successful, 1 otherwise
   ---------------------------------------------------------------------*/
function set_date
(p_name varchar2
,p_value date) return number;
--
/* =====================================================================
   Name    : get_text
   Purpose : To retrieve the value of a text global variable
   Returns : The value of the varibale if found, NULL otherwise
   ---------------------------------------------------------------------*/
function get_text
(p_name varchar2) return varchar2;
--
/* =====================================================================
   Name    : set_text
   Purpose : To set the value of a text global variable
   Returns : 0 if successful, 1 otherwise
   ---------------------------------------------------------------------*/
function set_text
(p_name varchar2
,p_value varchar2) return number;
--
/* =====================================================================
   Name    : isnull
   Purpose : To evaluate whether a text variable is NULL
   Returns : 'Y' if it is null, 'N' otherwise
   ---------------------------------------------------------------------*/
function isnull
(p_value varchar2) return varchar2;
--
/* =====================================================================
   Name    : isnull
   Purpose : To evaluate whether a numeric variable is NULL
   Returns : 'Y' if it is null, 'N' otherwise
   ---------------------------------------------------------------------*/
function isnull
(p_value number) return varchar2;
--
/* =====================================================================
   Name    : isnull
   Purpose : To evaluate whether a date variable is NULL
   Returns : 'Y' if it is null, 'N' otherwise
   ---------------------------------------------------------------------*/
function isnull
(p_value date) return varchar2;
--
/* =====================================================================
   Name    : remove_globals
   Purpose : To delete all global variables
   Returns : 0 if successful, 1 otherwise
   ---------------------------------------------------------------------*/
function remove_globals return number;
--
/* =====================================================================
   Name    : clear_globals
   Purpose : To set the value of all global variables to NULL
   Returns : 0 if successful, 1 otherwise
   ---------------------------------------------------------------------*/
function clear_globals return number;
--
/* =====================================================================
   Name    : debug
   Purpose : To output a string using DBMS_OUTPUT
   Returns : 0 if successful, 1 otherwise
   ---------------------------------------------------------------------*/
function debug
(p_message varchar2) return number;
--
/* =====================================================================
   Name    : raise_error
   Purpose : To raise an applications error
   Returns : 0 if successful, 1 otherwise
   ---------------------------------------------------------------------*/
function raise_error
(p_application_id number
,p_message_name varchar2) return number;
--
end per_formula_functions;

 

/
