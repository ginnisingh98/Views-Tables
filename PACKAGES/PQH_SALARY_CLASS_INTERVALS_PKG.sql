--------------------------------------------------------
--  DDL for Package PQH_SALARY_CLASS_INTERVALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_SALARY_CLASS_INTERVALS_PKG" AUTHID CURRENT_USER as
/* $Header: pqhsalco.pkh 115.1 2002/04/23 13:15:13 pkm ship        $ */
--
function get_salary_interval (
				 p_emp_category   in  varchar2
				,p_annual_salary  in  number default 0)
				return varchar2;

function get_job_sal_interval (
                                 p_emp_category   in  varchar2
                                , p_job_code  in  varchar2
                                ,p_annual_salary  in  number default 0)
                                return varchar2;
end;

 

/
