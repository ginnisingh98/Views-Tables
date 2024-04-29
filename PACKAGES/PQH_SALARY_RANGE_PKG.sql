--------------------------------------------------------
--  DDL for Package PQH_SALARY_RANGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_SALARY_RANGE_PKG" AUTHID CURRENT_USER as
/* $Header: pqsalrng.pkh 115.2 2002/06/14 11:39:48 pkm ship        $ */

	function get_salary_range(
			p_emp_category 	varchar2,
			p_annual_salary 	number default 0)
		return varchar2;
end;

 

/
