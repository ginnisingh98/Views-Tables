--------------------------------------------------------
--  DDL for Package PAY_US_EMPLOYEE_PAYSLIP_WEB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_EMPLOYEE_PAYSLIP_WEB" 
/* $Header: pyusempw.pkh 120.1.12010000.8 2010/05/04 16:32:05 mikarthi ship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material AUTHID CURRENT_USER is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : pay_us_employee_payslip_web


    Description : Package contains functions and procedures used
                  by te Online Payslip Views.

    Uses        :

    Change List
    -----------
    Date        Name     Vers    Bug No  Description
    ----        ----     ----    ------  -----------
    21-Feb-2010 mikarthi 115.23  9555144 changed the view in cursor get_choose_payslip
                                         to pay_perf_payslip_action_info_v
    21-Feb-2010 mikarthi 115.22  9394861 New cursor check_emp_personal_payment
    21-Feb-2010 mikarthi 115.21  9394861 NOCOPY hint added
    21-Feb-2010 mikarthi 115.20  9394861 Payslip Perf Enhancement
                                         a) New function check_us_emp_personal_payment
                                         b) New Function check_emp_personal_payment
    05-MAR-2008 sudedas  115.17  6739242 New Function get_netpaydistr_segment
                                         Added.
    08-SEP-2005 ppanda   115.16          For Enhanced multi jurisdiction taxation
                                         a new function added to derive the
					 full jurisdiction name (State, County, City)
					 using the existing function get_jurisdiction_nmame
    05-MAY-2005 ahanda   115.15  4246280 Changed Payslip code to check for
                                         View Payslip offset before showing
                                         Payslip for an employee.
                                         Added overloaded function -
                                         check_emp_personal_payment with
                                         parameter of p_time_period_id
    19-JAN-2005 sodhingr 115.14  4132132 Changed the function get_term_info
    05-NOV-2003 pganguly 115.13          Added two pkg variables.
    19-JUL-2003 ahanda   115.12          Added function format_to_date.
    14-NOV-2002 tclewis  115.11          Changed order of parameters in
                                         get_check_number now AA_ID, PP_ID.
    27-SEP-2002 sodhingr 115.9           Added check for GSCC compliance.
    16-JUN-2002 sodhingr 115.8           Added a new function get_term_info
					 to check
					 the terminated employee based
					 on the legislation_field_info
    13-MAY-2002 pganguly 115.7   2363857 Added a new function
                                         get_legislation_code.
    21-MAR-2002 ekim     115.6           Changed get_doc_eit function.
    24-JAN-2002 dgarg    115.4           Added get_jurisdiction_name
                                         function
    05-OCT-2001 ekim     115.3           Added get_doc_eit function.
    21-SEP-2001 ekim     115.2           Added get_format_value function.
    17-SEP-2001 asasthan 115.1           Added get_check_number for payslip
    08-FEB-2000 ahanda   115.0           Removed all reference to PRAGMA

  ***********************************************************************
  ** Removed All reference to PRAGMA for 11i.
  ***********************************************************************

    01-FEB-2000 ahanda   110.2           Removed element_name parameter from
                                         School dsts function.
    01-FEB-2000 ahanda   110.1           Added function to get School Dst Name.
    01-JUL-1999 ahanda   110.0           Created.

  *******************************************************************/
  AS

-- Global Variable for the Package
--
  g_currency_code varchar2(10)  := null;
  g_legislation_code varchar2(2) := null;
  g_legislation_rule varchar2(30) := null;

  TYPE eit_rec is RECORD
     ( t_level varchar2(150),
       t_id    number,
       t_online varchar2(1),
       t_print varchar2(1));

  TYPE eit_table is TABLE OF eit_rec INDEX BY BINARY_INTEGER;

  eit_tab eit_table;

  FUNCTION get_doc_eit (p_doc_type in varchar,
                        p_mode    in varchar,
                        p_level    in varchar,
                        p_id       in number,
                        p_effective_date date)

  RETURN varchar2;


  FUNCTION get_format_value (p_business_group_id in number,
                             p_value in number)
  return varchar2;


  FUNCTION check_emp_personal_payment
                  (p_assignment_id        number,
                   p_payroll_id           number,
                   p_time_period_id       number,
                   p_assignment_action_id number,
                   p_effective_date       date)
  return varchar2;

  -- Added for Testing
  --
  FUNCTION check_emp_personal_payment
                  (p_assignment_id        number,
                   p_payroll_id           number,
                   p_time_period_id       number,
                   p_assignment_action_id number,
                   p_effective_date       date,
                   p_payment_category     varchar2,
                   p_legislation_code     varchar2)
  return varchar2;


  FUNCTION check_emp_personal_payment
                  (p_assignment_id        number,
                   p_payroll_id           number,
                   p_assignment_action_id number,
                   p_effective_date       date)
  return varchar2;


  FUNCTION get_proposed_emp_salary (p_assignment_id     in number,
                                    p_pay_basis_id      in number,
                                    p_pay_bases_name    in varchar2,
                                    p_period_start_date in date,
                                    p_period_end_date   in date)
  return varchar2;


  FUNCTION get_emp_annualization_factor
                               (p_pay_basis_id    in number,
                                p_period_type     in varchar2,
                                p_pay_bases_name  in varchar2,
                                p_assignment_id   in number,
                                p_period_end_date in date)
  return number;


  FUNCTION get_asgn_annual_hours (p_assignment_id   in number,
                                  p_period_end_date in date)
  return number;


  FUNCTION get_school_dsts_name (p_jurisdiction_code in varchar2)
  return varchar2;

  FUNCTION get_check_number(p_pre_payment_assact in number
                           ,p_pre_payment_id in number)
  return varchar2;


  FUNCTION get_jurisdiction_name( p_jurisdiction_code in varchar2)
  return varchar2;

  FUNCTION get_legislation_code( p_business_group_id in number)
  return varchar2;

  FUNCTION get_term_info (p_business_group_id    in number,
                          p_person_id            in number,
                          p_action_context_id    number)
                        /* for bug 4132132
                         p_effective_start_date date,
                         p_effective_end_date   date) */
  RETURN varchar2;

  FUNCTION get_meaning_payslip_label(p_leg_code    in VARCHAR2,
                                     p_lookup_code in VARCHAR2)
  RETURN VARCHAR2;

  FUNCTION format_to_date(p_char_date in varchar2)
  RETURN date;

  FUNCTION get_full_jurisdiction_name( p_jurisdiction_code in varchar2)
  return varchar2;

  -- This Function has been Added for Bug# 6739242
  -- For CA OT Enhancement pay_action_information started getting
  -- Populated with Account Details that is NOT needed to be displayed
  -- In Self Service Payslip
  FUNCTION get_netpaydistr_segment(p_business_grp_id IN NUMBER
                                  ,p_org_pay_meth_id IN NUMBER)
  RETURN VARCHAR2;


  /* Start of changes for 9394861
  */
  g_job_label       VARCHAR2(50):= '';
  g_check_label     VARCHAR2(50):= '';

  FUNCTION check_us_emp_personal_payment(  p_assignment_id NUMBER
                                        , p_payroll_id NUMBER
                                        , p_time_period_id NUMBER
                                        , p_assignment_action_id NUMBER
                                        , p_effective_date DATE
                                        )
 RETURN VARCHAR2;


 PROCEDURE check_emp_personal_payment(  p_effective_date VARCHAR2,
                                        p_enable_term VARCHAR2,
                                        p_business_group_id VARCHAR2,
                                        p_person_id VARCHAR2,
                                        p_first_call VARCHAR2 default 'N',
                                        p_last_fetch OUT NOCOPY VARCHAR2,
                                        pay_ret_table OUT NOCOPY pay_payslip_list_table);

  cursor get_choose_payslip(v_person_id VARCHAR2, v_eff_date VARCHAR2) IS
  SELECT
    to_char(action_context_id) action_context_id,
    trunc(effective_date) effective_date,
    payroll_id,
    time_period_id,
    assignment_id,
    action_information14,
    check_count
  FROM
    pay_perf_payslip_action_info_v
  WHERE person_id = to_number(v_person_id)
    AND effective_date >= to_date(v_eff_date,'YYYY/MM/DD')
  order by effective_date desc;

/* End of changes for 9394861
  */

end pay_us_employee_payslip_web;

/
