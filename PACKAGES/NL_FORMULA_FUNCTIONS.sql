--------------------------------------------------------
--  DDL for Package NL_FORMULA_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."NL_FORMULA_FUNCTIONS" AUTHID CURRENT_USER AS
-- $Header: penlffnc.pkh 115.1 2001/05/02 06:17:44 pkm ship        $
--
-- Calculate the Target Group
--
FUNCTION get_table_value(bus_group_id number,
			tab_name Varchar2,
			col_name Varchar2,
			row_value Varchar2 )
RETURN varchar2 ;

end nl_formula_functions;


 

/
