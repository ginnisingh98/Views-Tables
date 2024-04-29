--------------------------------------------------------
--  DDL for Package Body NL_FORMULA_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."NL_FORMULA_FUNCTIONS" AS
-- $Header: penlffnc.pkb 115.1 2001/05/02 06:16:44 pkm ship        $
--
-- Calculates the Target Group
--
FUNCTION get_table_value(bus_group_id number,
			tab_name varchar2,
			col_name varchar2,
			row_value varchar2)
return varchar2
is
l_ret varchar2(1);
Begin
	Begin
		l_ret:= hruserdt.get_table_value(bus_group_id,
						tab_name,
						col_name,
						row_value);
	Exception
		When NO_DATA_FOUND THEN
		l_ret:='0';
	End;
Return l_ret;
end get_table_value;

end nl_formula_functions;

/
