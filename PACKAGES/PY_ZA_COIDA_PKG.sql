--------------------------------------------------------
--  DDL for Package PY_ZA_COIDA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PY_ZA_COIDA_PKG" AUTHID CURRENT_USER as
/* $Header: pyzacoid.pkh 120.4 2006/06/15 09:22:50 amahanty ship $         */
  Function get_working_days
  (
   p_period_start in date
  ,p_period_end   in date
  )
  Return number;

  Pragma restrict_references(get_working_days, WNDS);

-- *****************************************************************************
/*
  Function get_emp_absence
  (
   p_start_date    date
  ,p_end_date      date
  ,p_type          varchar2
  )
  Return number;

  Pragma restrict_references(get_emp_absence, WNDS);
*/
-- *****************************************************************************

  Function get_emp_days_worked
  (
   p_start_date  date
  ,p_end_date    date
  ,p_payroll_id  number
  ,p_person_id   number default null
  )
  Return number;

  Pragma restrict_references(get_emp_days_worked, WNDS);

End py_za_coida_pkg;

 

/
