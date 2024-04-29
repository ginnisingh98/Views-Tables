--------------------------------------------------------
--  DDL for Package Body PAY_PAYFV_ELEMENT_ENTRIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYFV_ELEMENT_ENTRIES_PKG" as
/* $Header: payfvele.pkb 115.4 2003/01/16 13:08:22 adhunter noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|                       Copyright (c) 2001 Oracle Corporation                  |
|                          Redwood Shores, California, USA                     |
|                               All rights reserved                            |
+==============================================================================+

Name
        Supporting functions for BIS view PAY_PAYFV_ELEMENT_ENTRIES.
Purpose
        To return non-id table information where needed to enhance the
        performance of the view.
History
 115.0  15-Jan-2001  J.Tomkins     Created

 115.1  23-Feb-2001  J.Tomkins     Removed '_all' from table names to include
                                   required security (Bug. 1425084)
 115.2  09-Dec-2002  joward        MLS enabled grade name
 115.3  23-Dec-2002  joward        MLS enabled job name
*/
--------------------------------------------------------------------------------
FUNCTION get_job (p_job_id IN NUMBER) RETURN VARCHAR2 IS
--
l_name	VARCHAR2(240);
--
begin
--
select 	name
into	l_name
from   	per_jobs_vl
where 	job_id = p_job_id;
--
return  l_name;
--
exception
when others then
return (NULL);
--
end get_job;
-----------------------------------------------------------
FUNCTION get_position (p_pos_id IN NUMBER) RETURN VARCHAR2 IS
--
l_name	VARCHAR2(240);
--
begin
--
select 	name
into	l_name
from   	per_positions
where 	position_id = p_pos_id;
--
return  l_name;
--
exception
when others then
return (NULL);
--
end get_position;
-----------------------------------------------------------
FUNCTION get_grade (p_grade_id IN NUMBER) RETURN VARCHAR2 IS
--
l_name	VARCHAR2(240);
--
begin
--
select 	name
into	l_name
from   	per_grades_vl
where 	grade_id = p_grade_id;
--
return  l_name;
--
exception
when others then
return (NULL);
--
end get_grade;
-----------------------------------------------------------
FUNCTION get_location (p_loc_id IN NUMBER) RETURN VARCHAR2 IS
--
l_location	VARCHAR2(20);
--
begin
--
select 	location_code
into	l_location
from   	hr_locations_all_tl
where 	location_id = p_loc_id
and     language    = userenv('LANG');
--
return  l_location;
--
exception
when others then
return (NULL);
--
end get_location;
-----------------------------------------------------------
FUNCTION get_pay_basis (p_pay_id IN NUMBER) RETURN VARCHAR2 IS
--
l_basis	VARCHAR2(30);
--
begin
--
select 	pay_basis
into	l_basis
from   	per_pay_bases
where 	pay_basis_id = p_pay_id;
--
return  l_basis;
--
exception
when others then
return (NULL);
--
end get_pay_basis;
-----------------------------------------------------------
FUNCTION get_payroll (p_payroll_id IN NUMBER) RETURN VARCHAR2 IS
--
l_payroll VARCHAR2(80);
--
begin
--
select  payroll_name
into    l_payroll
from    pay_payrolls_f
where   payroll_id = p_payroll_id
and     sysdate    between effective_start_date
                   and     effective_end_date;
--
return  l_payroll;
--
exception
when others then
return (NULL);
--
end get_payroll;
--
END PAY_PAYFV_ELEMENT_ENTRIES_PKG;

/
