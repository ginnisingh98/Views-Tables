--------------------------------------------------------
--  DDL for Package PAY_NZ_CEC_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NZ_CEC_REPORT_PKG" AUTHID CURRENT_USER AS
/* $Header: pynzcecetc.pkh 120.0.12010000.2 2009/01/30 06:00:44 pmatamsr noship $*/

P_REGISTERED_EMPLOYER_ID Number;
P_ASSIGNMENT_ID Number;
P_START_DATE Date;
P_END_DATE Date;
P_REGISTERED_EMP_NAME varchar2(250);
PER_BUSINESS_GROUP_ID Number(20);
  --------------------------------------------------------------------
  -- This function is used to calculate Sum of balance values between
  -- Start Date and End Date Parameters for a defined balance id .
  -- This function gets called from PAYNZCECETC.xml
  --------------------------------------------------------------------

 Function PAY_NZ_GET_BAL_VALUE(p_assignment_id IN per_assignments_f.assignment_id%type,
                               p_def_bal_id IN pay_defined_balances.defined_balance_id%type,
                               p_start_date IN date,
                               p_end_date IN date)
  return number;

/* Bug 7688345 - This function is used to check whether the report End Date parameter
 * value is prior or after '01-Apr-2009' and accordingly a flag value is returned.*/

 function PAY_NZ_GET_RPT_FLAG (p_end_date IN date)
 return char;

END pay_nz_cec_report_pkg;

/
