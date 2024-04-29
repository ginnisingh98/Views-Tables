--------------------------------------------------------
--  DDL for Package PAY_US_SQWL_UDF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_SQWL_UDF" AUTHID CURRENT_USER as
/* $Header: pyussqut.pkh 120.0.12010000.4 2010/03/30 15:55:50 emunisek ship $ */
/*  +======================================================================+
REM |                Copyright (c) 1997 Oracle Corporation                 |
REM |                   Redwood Shores, California, USA                    |
REM |                        All rights reserved.                          |
REM +======================================================================+
REM SQL Script File Name : pyussqut.pkh
REM Description          : Package and procedure to build sql for payroll
REM                        processes.
REM Package Name         : pay_us_sqwl_udf
REM Purpose              : Sets up the data to provide SQWL Ulitity
REM                        Processing.
REM
REM Notes                : This data is US specific.
REM
REM Change List:
REM ------------
REM
REM Name         Date       Version Bug     Text
REM ------------ ---------- ------- ------- ------------------------------
REM M Doody      16-FEB-2001 115.0          Initial Version
REM
REM
REM tmehra       17-AUG-2001 115.1          Added 'get_gre_wage_plan_code'
REM
REM tmehra       15-OCT-2001 115.2          Added 'get_asg_wage_plan_code'
REM tmehra       07-MAY-2003 115.4          Added new validation for
REM                                         california sqwl as a new
REM                                         new segment has been introduced
REM                                         for the info type.
REM tmehra       26-AUG-2003 115.6 2219097  Added two new functions for the
REM                                         US W2 enhancements for Govt
REM                                         employer.
REM                                           - get_employment_code
REM                                           - chk_govt_employer
REM                                         Added the following function
REM                                         for US W2 enhancements for Govt
REM                                         employer.
REM                                           - get_archived_emp_code
REM emunisek     05-Mar-2010 115.7 9356178 Added get_out_of_state_code
REM                                         function
REM emunisek     30-Mar-2010 115.8 9356178 Modified the parameter type of
REM                                        p_out_of_state_taxable parameter
REM                                        in function get_out_of_state_code
REM emunisek     30-Mar-2010 115.9 9356178 Made file GSCC Compliant
REM ========================================================================

CREATE OR REPLACE PACKAGE pay_us_sqwl_udf as
*/

  FUNCTION get_qtr_hire_flag(p_emp_per_hire_date DATE, p_transfer_date DATE)
  RETURN   VARCHAR2;


  FUNCTION get_gre_wage_plan_code
     (
      p_tax_unit_id       in     number,
      p_transfer_state    in     varchar
     )
  RETURN  VARCHAR2;


  FUNCTION get_asg_wage_plan_code
     (
      p_assignment_id     in     number,
      p_transfer_state    in     varchar
     )
  RETURN  VARCHAR2;


PROCEDURE chk_for_default_wp     ( p_organization_id     number,
                                   p_org_information_context varchar2,
                                   p_org_information1    varchar2
                                   );


FUNCTION chk_govt_employer       ( p_tax_unit_id           number DEFAULT NULL,
                                   p_assignment_action_id  number DEFAULT NULL
                                 ) RETURN BOOLEAN;

FUNCTION get_employment_code     ( p_medicare_wh           number DEFAULT NULL,
                                   p_ss_wh                 number DEFAULT NULL
                                 ) RETURN varchar2;

FUNCTION get_archived_emp_code   ( p_assignment_action_id  number DEFAULT NULL
                                 ) RETURN varchar2;

/*Added for Bug#9356178*/
FUNCTION get_out_of_state_code   ( p_assignment_action_id number,
                                   p_assignment_id number,
                                   p_tax_unit_id   number,
                                   p_reporting_date date,
				   p_out_of_state_taxable  IN OUT nocopy number
                                 ) RETURN varchar2;

END pay_us_sqwl_udf;


/
