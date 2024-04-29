--------------------------------------------------------
--  DDL for Package PSP_MATRIX_DRIVER3_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_MATRIX_DRIVER3_PKG" AUTHID CURRENT_USER as
-- $Header: PSPLSP3S.pls 115.4 2002/04/17 19:21:18 pkm ship     $
	procedure load_table(sch_id  number,begin_date date,end_date date);
	FUNCTION get_dynamic_totals(n NUMBER) RETURN NUMBER;
	procedure purge_table;
	procedure set_start_period(n NUMBER);
	PROCEDURE set_payroll_id(n NUMBER);
--	FUNCTION check_exceedence RETURN BOOLEAN;
	FUNCTION get_max_periods RETURN NUMBER;
	FUNCTION get_start_period(n NUMBER) RETURN DATE;
	pragma RESTRICT_REFERENCES  ( get_start_period, WNDS, WNPS );
	FUNCTION get_dynamic_prompt(n NUMBER) RETURN VARCHAR2;
end psp_matrix_driver3_pkg;

 

/
