--------------------------------------------------------
--  DDL for Package Body PQH_SALARY_CLASS_INTERVALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_SALARY_CLASS_INTERVALS_PKG" as
/* $Header: pqhsalco.pkb 120.2 2006/04/18 12:44:17 nsanghal noship $ */
--

function get_salary_interval (
				 p_emp_category   in  varchar2
				,p_annual_salary  in  number default 0)
				return varchar2 IS
l_annual_salary Number;
begin
 if (p_emp_category in ('FT','FR')) then
 -- Bug 5018881: Added rounding of salary
    l_annual_salary := round(nvl(p_annual_salary,0),2);

	if l_annual_salary between 0 and 29999.99 then
	   return '01';
	elsif l_annual_salary between 30000 and 39999.99 then
	   return '02';
	elsif l_annual_salary between 40000 and 49999.99 then
	   return '03';
	elsif l_annual_salary between 50000 and 64999.99 then
	   return '04';
	elsif l_annual_salary between 65000 and 79999.99 then
	   return '05';
	elsif l_annual_salary between 80000 and 99999.99 then
	   return '06';
	elsif l_annual_salary >= 100000 then
	   return '07';
	else
            	return to_char(l_annual_salary);
	end if;
 else
	return ' ';
end if;
end;

function get_job_sal_interval (
                                 p_emp_category   in  varchar2
                                ,p_job_code in varchar2
                                ,p_annual_salary  in  number default 0)
                                return varchar2 IS
l_annual_salary Number;
begin

  -- Bug 5018881: Added rounding of salary
 l_annual_salary := round(nvl(p_annual_salary,0),2);
  --
 if ((p_emp_category in ('FT','FR')) and (p_job_code in ('5','6','7'))) then
      if nvl(l_annual_salary,0) = 0 or l_annual_salary between 0 and 29999.99 then
           return '01';
        elsif l_annual_salary between 30000 and 39999.99 then
           return '02';
        elsif l_annual_salary between 40000 and 49999.99 then
           return '03';
        elsif l_annual_salary between 50000 and 64999.99 then
           return '04';
        elsif l_annual_salary between 65000 and 79999.99 then
           return '05';
        elsif l_annual_salary between 80000 and 99999.99 then
           return '06';
        elsif l_annual_salary >= 100000 then
           return '07';
        else
                return to_char(l_annual_salary);
        end if;
 elsif ((p_emp_category in ('FT','FR')) and (p_job_code in ('8','9','10','11'))) then
       if nvl(l_annual_salary,0) = 0 or l_annual_salary between 0 and 19999.99 then
           return '01';
        elsif l_annual_salary between 20000 and 29999.99 then
           return '02';
        elsif l_annual_salary between 30000 and 39999.99 then
           return '03';
        elsif l_annual_salary between 40000 and 49999.99 then
           return '04';
        elsif l_annual_salary >= 50000 then
           return '05';
        else
                return to_char(l_annual_salary);
        end if;
 else
        return ' ';
 end if;
end;

end;

/
