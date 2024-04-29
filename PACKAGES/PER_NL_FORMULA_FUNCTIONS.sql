--------------------------------------------------------
--  DDL for Package PER_NL_FORMULA_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_NL_FORMULA_FUNCTIONS" AUTHID CURRENT_USER AS
-- $Header: penlffnc.pkh 120.0.12000000.1 2007/01/22 00:24:39 appldev ship $
--
-- Calculate the Target Group
--
FUNCTION get_table_value(bus_group_id number,
			tab_name Varchar2,
			col_name Varchar2,
			row_value Varchar2 )
RETURN varchar2 ;

FUNCTION get_table_value(bus_group_id number,
                        date_earned date,
                        payroll_action_id number,
			tab_name Varchar2,
			col_name Varchar2,
			row_value Varchar2 )
RETURN varchar2 ;


end per_nl_formula_functions;


 

/
