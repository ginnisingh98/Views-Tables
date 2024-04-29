--------------------------------------------------------
--  DDL for Package HR_ADP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ADP" AUTHID CURRENT_USER as
/* $Header: peadppkg.pkh 120.2 2005/10/28 04:21:28 sgelvi noship $ */
--
-- Global variable to set ADP extract date. It is used to allow the extract
-- on any given date instead of the sysdate.
--
  g_adp_extract_date date;
  g_ex_employee_date date;
  g_ex_employee_months number;
  g_end_deduction_date date;
  g_end_deduction_months number;
--
  procedure set_adp_extract_date(p_adp_extract_date in date,
                                 p_ex_employee_months in number default null,
                                 p_end_deduction_months in number default null);
--
  function get_adp_extract_date return date;
  pragma restrict_references(get_adp_extract_date, WNDS, WNDS);
--
  function get_ex_employee_date return date;
  pragma restrict_references(get_ex_employee_date, WNDS, WNDS);
--
  function get_end_deduction_date return date;
  pragma restrict_references(get_end_deduction_date, WNDS, WNDS);
--
  function get_max_ppm_priority(p_assignment_id in number)
  return number;
--
end hr_adp;

 

/
