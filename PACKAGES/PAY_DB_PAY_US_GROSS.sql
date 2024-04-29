--------------------------------------------------------
--  DDL for Package PAY_DB_PAY_US_GROSS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DB_PAY_US_GROSS" AUTHID CURRENT_USER as
/* $Header: pypusgrs.pkh 115.0 99/07/17 06:27:10 porting ship $ */
/*
rem   Change History
rem
rem      Date               Name                 Description
rem      ----               ----                 -----------
rem      30-JUL-1996        J. ALLOUN            Added error handling.
rem
*/
--
g_default_start_date		date := to_date('01-01-0001','DD-MM-YYYY');
g_todays_date	constant	date := trunc(sysdate);
g_max_end_date	constant	date := to_date('31/12/4712','DD/MM/YYYY');
g_max_elnum	constant	BINARY_INTEGER := 8;
--
TYPE ElemTabType IS TABLE OF
  PAY_ELEMENT_TYPES_F.ELEMENT_NAME%TYPE
  INDEX BY BINARY_INTEGER;
--
TYPE InputTabType IS TABLE OF
  PAY_INPUT_VALUES_F.NAME%TYPE
  INDEX BY BINARY_INTEGER;
--
TYPE ResultTabType IS TABLE OF
  PAY_FORMULA_RESULT_RULES_F.RESULT_NAME%TYPE
  INDEX BY BINARY_INTEGER;
--
TYPE UOMTabType IS TABLE OF
  PAY_INPUT_VALUES_F.UOM%TYPE
  INDEX BY BINARY_INTEGER;
--
TYPE RsltPrefixType IS TABLE OF
  VARCHAR(10)
  INDEX BY BINARY_INTEGER;
--
g_business_group_ID	NUMBER := NULL;	-- business group ID
g_vtx_elem_tab		ElemTabType;	-- VERTEX grossup elements
g_vtx_input_value	InputTabType;	-- Input value/result rule names
g_vtx_result_name	ResultTabType;	-- result rule names
g_vtx_uom		UOMTabType;	-- Unit of Measure
--
--
procedure create_vertex_element_names;
--
function create_gross_up (
			p_business_group_name   IN VARCHAR2 DEFAULT NULL,
			p_element_name		IN VARCHAR2,
			p_classification	IN VARCHAR2,
			p_reporting_name	IN VARCHAR2,
			p_formula_name		IN VARCHAR2,
			p_priority		IN NUMBER,
                        p_effective_start_date  IN DATE     DEFAULT NULL,
			p_effective_end_date	IN DATE     DEFAULT NULL
			) RETURN NUMBER;
--
procedure delete_gross_up (
			p_business_group_id	IN NUMBER,
			p_element_name		IN VARCHAR2
			);
--
function create_linked_elements (
			p_mode			VARCHAR2    DEFAULT 'Grossup',
			p_element_name		VARCHAR2,
			p_element_type_id	NUMBER,
			p_formula_id		NUMBER,
			p_priority		NUMBER,
			p_business_group_name	VARCHAR2    DEFAULT NULL,
			p_start_date		DATE	    DEFAULT NULL,
			p_end_date		DATE	    DEFAULT NULL
			) RETURN NUMBER;
--
procedure create_indirect_link (
			p_element_name		VARCHAR2,
			p_uom			VARCHAR2,
			p_name			VARCHAR2,
			p_display_sequence	NUMBER,
			p_stat_proc_id		NUMBER,
			p_business_group_name	VARCHAR2	DEFAULT NULL,
			p_effective_start_date	DATE		DEFAULT NULL,
			p_effective_end_date	DATE		DEFAULT NULL
			);
--
function create_status_proc_rule(
                        p_effective_start_date  IN DATE,
                        p_effective_end_date    IN DATE,
			p_formula_ID            IN NUMBER   DEFAULT NULL,
			p_element_type_ID       IN NUMBER
                        ) RETURN NUMBER;
--
function create_result_rule(
			p_legislation_code      VARCHAR2 DEFAULT 'US',
			p_result_name		VARCHAR2,
			p_result_type		VARCHAR2 DEFAULT 'I',
			p_severity		VARCHAR2 DEFAULT NULL,
			p_stat_proc_ID		NUMBER,
			p_input_value_ID	NUMBER   DEFAULT NULL,
			p_effective_start_date  DATE,
			p_effective_end_date    DATE
			) RETURN NUMBER;
--
end pay_db_pay_us_gross;

 

/
