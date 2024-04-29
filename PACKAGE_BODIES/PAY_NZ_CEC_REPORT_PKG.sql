--------------------------------------------------------
--  DDL for Package Body PAY_NZ_CEC_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NZ_CEC_REPORT_PKG" AS
/* $Header: pynzcecetc.pkb 120.0.12010000.3 2009/02/04 13:41:56 pmatamsr noship $*/
/*
*** ------------------------------------------------------------------------+
*** Program:     pay_nz_cec_report_pkg (Package Body)
***
*** Change History
***
*** Date       Changed By  Version  Description of Change
*** ---------  ----------  -------  ----------------------------------------+
*** 28-APR-2008 priupadh   115.0    Initial version
*** 08-MAY-2008 priupadh   115.1    Added IN in parameters and variable
*** 28-JAN-2009 pmatamsr   115.2    Added new function PAY_NZ_GET_RPT_FLAG which returns a
***				    flag value depending on the report End Date parameter.
*** 04-FEB-2009 pmatamsr   115.3    Changes done to date format in order to pass gssc compliance check.
***
*** -------------------------------------------------------------------------------------------------------+
*/

  --------------------------------------------------------------------
  -- This function is used to calculate Sum of balance values between
  -- Start Date and End Date Parameters for a defined balance id .
  -- This function gets called from PAYNZCECETC.xml
  --------------------------------------------------------------------

function PAY_NZ_GET_BAL_VALUE(p_assignment_id IN per_assignments_f.assignment_id%type,
                              p_def_bal_id IN pay_defined_balances.defined_balance_id%type,
			      p_start_date IN date,
			      p_end_date IN date)
return number is

Cursor csr_get_ass_act_id(p_assignment_id per_assignments_f.assignment_id%type,p_start_date date,p_end_date date) is
select paa.assignment_action_id
from pay_assignment_actions paa,
     pay_payroll_actions ppa
where ppa.action_status ='C'
and ppa.action_type in ('R','Q','I','B','V')
and ppa.effective_date between p_start_date and p_end_date
and paa.payroll_action_id=ppa.payroll_action_id
and paa.assignment_id =p_assignment_id;


ln_period_bal number;

begin
ln_period_bal       :=0;

for get_bal in csr_get_ass_act_id(p_assignment_id,p_start_date,p_end_date) loop

               ln_period_bal := ln_period_bal + nvl(pay_balance_pkg.get_value(p_def_bal_id,get_bal.assignment_action_id),0);

end loop;

return ln_period_bal;

end PAY_NZ_GET_BAL_VALUE;

/* Bug 7688345 - This function is used to check whether the report End Date parameter
 * value is prior or after '01-Apr-2009' and accordingly a flag value is returned.*/

function PAY_NZ_GET_RPT_FLAG (p_end_date in date)
return char
is
lp_end_date  date;

begin

lp_end_date := to_date(to_char(p_end_date,'DD/MM/YYYY'),'DD/MM/YYYY');

if lp_end_date < to_date('01/04/2009','DD/MM/YYYY') then
return ('F');
else
return('T');
end if;

end PAY_NZ_GET_RPT_FLAG ;

END pay_nz_cec_report_pkg;

/
