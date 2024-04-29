--------------------------------------------------------
--  DDL for Package Body PQH_SALARY_RANGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_SALARY_RANGE_PKG" as
/* $Header: pqsalrng.pkb 120.1 2006/02/08 08:38:29 nsanghal noship $ */
--
function get_salary_range (
				 p_emp_category   in  varchar2
				,p_annual_salary  in  number default 0)
				return varchar2 IS
l_annual_salary Number;
begin
if nvl(p_emp_category,'$$') = 'FR' then

/* Bug 4727991: Adding rounding to avoid a separate range created
  in the report
*/
   l_annual_salary := round(nvl(p_annual_salary,0));

	if  l_annual_salary between 0 and 15999 then
	   return ' 0.1-15.9';
	elsif l_annual_salary between 16000 and 19999 then
	   return '16.0-19.9';
	elsif l_annual_salary between 20000 and 24999 then
	   return '20.0-24.9';
	elsif l_annual_salary between 25000 and 32999 then
	   return '25.0-32.9';
	elsif l_annual_salary between 33000 and 42999 then
	   return '33.0-42.9';
	elsif l_annual_salary between 43000 and 54999 then
	   return '43.0-54.9';
	elsif l_annual_salary between 55000 and 69999 then
	   return '55.0-69.0';
	elsif l_annual_salary >=  70000 then
	   return '70.0 PLUS';
	else
		return to_char(l_annual_salary);
	end if;
else
	return ' ';
end if;

end;

end;

/
