--------------------------------------------------------
--  DDL for Package QA_CORE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_CORE_PKG" AUTHID CURRENT_USER as
/* $Header: qltcoreb.pls 120.0 2005/05/24 19:25:13 appldev noship $ */

-- Bug 3777530. Permormance Fix for Literals.
-- These two tables are used for procedure exec_sql_with_binds()
-- which will execute all client side dynamic queries
-- instead of executing them with FORMS_DDL() which restrict
-- the use of bind variables.
-- saugupta Wed, 01 Dec 2004 21:12:53 -0800 PDT
TYPE var_in_tab IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;
TYPE value_in_tab IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;

FUNCTION get_result_column_name (ELEMENT_ID IN NUMBER, P_ID IN NUMBER) RETURN VARCHAR2;
--
-- This is a function that returns the unique column name in the table
-- qa_results given an element_id, plan_id combination.
--


FUNCTION get_element_id (ELEMENT_NAME IN VARCHAR2) RETURN NUMBER;
--
-- This is a function that returns the element id (char_id) given
-- an element name.
--


FUNCTION get_plan_id ( PLAN_NAME IN VARCHAR2) RETURN NUMBER;
--
-- This is a function that returns the plan id given a plan name.
--


FUNCTION get_plan_name (GIVEN_PLAN_ID IN NUMBER) RETURN VARCHAR2;
--
-- This is a function that returns the plan name givn a plan id
--


FUNCTION is_mandatory (GIVEN_PLAN_ID IN NUMBER, ELEMENT_ID IN NUMBER) return BOOLEAN;
--
-- This is a function that determines if an element is mandatory for a plan.
-- Calling program must supply a plan_id and the element_id for the element
-- in question.
--


FUNCTION get_element_data_type (ELEMENT_ID IN NUMBER) RETURN NUMBER;
--
-- This is a function that determines the data type of a collection element.
-- This is a overloaded function.  This function takes element id as the
-- parameter.
--
-- The possible data type are:
--
--	datatype 1 is Character
-- 	datatype 2 is Number
-- 	datatype 3 is Date


FUNCTION get_element_data_type (ELEMENT_NAME IN VARCHAR2) RETURN NUMBER;
--
-- This is a function that determines the data type of a collection element.
-- This is a overloaded function.  This function takes element name as the
-- parameter.
--
-- The possible data type are:
--
--	datatype 1 is Character
-- 	datatype 2 is Number
-- 	datatype 3 is Date


PROCEDURE EXEC_SQL (STRING IN VARCHAR2);
 --
-- This is a procedure that executes a sql script.  Calling program must
-- supply a valid sql statement.
--
-- This is a duplicate procedure, I will remove it as soon as
-- I can get a chance -OB

FUNCTION dequote(s1 in varchar2) RETURN varchar2;
-- I am just adding the above function becos its useful in
-- many places  - isivakum

-- Bug 3777530. Permormance Fix for Literals
-- This a generic procedure that can be used to run any Dynamic SQL
-- with dynamic and variable number of bind parameters.
PROCEDURE exec_sql_with_binds(p_sql in varchar2, vars_in IN var_in_tab, values_in IN value_in_tab);

-- Bug 4270911. CU2 SQL Literal fix.
-- Set of procedures to execute a dynamic sql from forms.
-- Wrapper for fnd_dsql procedures.
-- Use restricted to DDL.
-- srhariha. Mon Apr 18 06:11:06 PDT 2005.

-- Simple Wrappers around fnd_dsql

  PROCEDURE dsql_init;

  PROCEDURE dsql_add_text(p_text IN VARCHAR2);

  PROCEDURE dsql_add_bind(p_value       IN VARCHAR2);

  PROCEDURE dsql_add_bind(p_value       IN DATE);

  PROCEDURE dsql_add_bind(p_value       IN NUMBER);

-- Execute procedure. Executes the SQL built by the
-- add_text and add_bind calls.

 PROCEDURE dsql_execute;



END QA_CORE_PKG;


 

/
