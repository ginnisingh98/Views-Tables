--------------------------------------------------------
--  DDL for Package Body HR_ADP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ADP" as
/* $Header: peadppkg.pkb 120.2 2005/10/28 04:21:43 sgelvi noship $ */
-----------------------------------------------------------------------
procedure set_adp_extract_date (p_adp_extract_date date,
                                p_ex_employee_months number default null,
                                p_end_deduction_months number default null)
------------------------------------------------------------------------
is
-- This procedure sets the g_adp_extract_date variable to the given date.
--
begin
   g_adp_extract_date := p_adp_extract_date;
-- The following two assignments to global variables been done to handle
-- cut off date issue.
   g_ex_employee_months   := p_ex_employee_months;
   g_end_deduction_months := p_end_deduction_months;
   HR_PAY_INTERFACE_PKG.g_payroll_extract_date := p_adp_extract_date;
--
end set_adp_extract_date;
--
-----------------------------------------------------------------------
function get_adp_extract_date return date
------------------------------------------------------------------------
is
-- This function returns the g_adp_extract_date set by the call to
-- set_adp_extract_date. If set_adp_extract_date is never called, it
-- returns the sysdate as g_adp_extract_date is initialized to
-- sysdate.
--
begin
   g_adp_extract_date := nvl(g_adp_extract_date, sysdate);
   RETURN g_adp_extract_date;
--
end get_adp_extract_date;
--
-----------------------------------------------------------------------
function get_ex_employee_date return date
------------------------------------------------------------------------
is
-- This function returns the g_adp_extract_date set by the call to
-- set_adp_extract_date. If set_adp_extract_date is never called, it
-- returns the sysdate as g_adp_extract_date is initialized to
-- sysdate.
--
begin
   g_ex_employee_date := trunc(add_months(trunc(hr_adp.get_adp_extract_date),-g_ex_employee_months)
                        - to_char(trunc(hr_adp.get_adp_extract_date),'DD') +1);
   g_ex_employee_date := nvl(g_ex_employee_date, to_date('01/01/0001','DD/MM/YYYY'));
   RETURN g_ex_employee_date;
--
end get_ex_employee_date;
--
-----------------------------------------------------------------------
function get_end_deduction_date return date
------------------------------------------------------------------------
is
-- This function returns the g_adp_extract_date set by the call to
-- set_adp_extract_date. If set_adp_extract_date is never called, it
-- returns the sysdate as g_adp_extract_date is initialized to
-- sysdate.
--
begin
   g_end_deduction_date := trunc(add_months(trunc(hr_adp.get_adp_extract_date),-g_end_deduction_months)
                        - to_char(trunc(hr_adp.get_adp_extract_date),'DD') +1) ;
   g_end_deduction_date := nvl(g_end_deduction_date, to_date('01/01/0001','DD/MM/YYYY'));
   RETURN g_end_deduction_date;
--
end get_end_deduction_date;
--
-----------------------------------------------------------------------
function get_max_ppm_priority(p_assignment_id in number)
                     return number is priority number(15);
------------------------------------------------------------------------
begin
--
select  max(priority)
into    priority
from    pay_personal_payment_methods_f
where   assignment_id = p_assignment_id
and     trunc(hr_adp.get_adp_extract_date)
between effective_start_date
    and effective_end_date ;
return priority;
--
end get_max_ppm_priority;
--
end hr_adp;

/
