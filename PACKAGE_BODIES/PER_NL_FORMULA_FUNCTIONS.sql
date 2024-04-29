--------------------------------------------------------
--  DDL for Package Body PER_NL_FORMULA_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_NL_FORMULA_FUNCTIONS" AS
-- $Header: penlffnc.pkb 120.0.12000000.1 2007/01/22 00:24:36 appldev ship $
--
-- Calculates the Target Group
--
FUNCTION get_table_value(bus_group_id number,
			tab_name varchar2,
			col_name varchar2,
			row_value varchar2)
return varchar2
is
 /* Modified the declaration to accomodate the value returned from
 hruserdt.get_table_value function
 l_ret varchar2(1); */
 l_ret pay_user_column_instances_f.value%type;
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


FUNCTION get_table_value(bus_group_id number,
                         date_earned date,
                         payroll_action_id number,
			tab_name varchar2,
			col_name varchar2,
			row_value varchar2)
return varchar2
is
 /* Modified the declaration to accomodate the value returned from
 hruserdt.get_table_value function
 l_ret varchar2(1); */
 l_ret pay_user_column_instances_f.value%type;
 l_date date;
 l_effective_date date;
 l_date_earned date;
 l_payroll_action_id number;

 cursor csr_get_ppa_date is
 select effective_date,date_earned
 from pay_payroll_actions ppa
 where ppa.payroll_action_id = l_payroll_action_id ;

Begin
	Begin
                      l_payroll_action_id := payroll_action_id;
	        open  csr_get_ppa_date;
	        fetch csr_get_ppa_date into l_effective_date,l_date_earned;
	        close csr_get_ppa_date;
	        if date_earned = l_date_earned then
	           l_date := l_effective_date;
	        else
	           l_date := date_earned;
	        end if;
		l_ret:= hruserdt.get_table_value(bus_group_id,
						tab_name,
						col_name,
						row_value,
						l_date);
	Exception
		When NO_DATA_FOUND THEN
		l_ret:='0';
	End;
Return l_ret;
end get_table_value;

end per_nl_formula_functions;

/
