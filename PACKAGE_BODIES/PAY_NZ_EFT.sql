--------------------------------------------------------
--  DDL for Package Body PAY_NZ_EFT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NZ_EFT" as
/* $Header: pynzeft.pkb 120.0.12010000.8 2008/12/08 15:55:38 pmatamsr ship $
**
**  Copyright (c) 1999 Oracle Corporation
**  All Rights Reserved
**
**  EFT direct credit of pay stuff
**
**  Change List
**  ===========
**
**  Date        Author   Reference Description
**  -----------+--------+---------+-------------
**  1 NOV 1999  ATOPOL   N/A       Big bang
** 30 MAY 2000  PUCHIL   2920728   Corrected check_sql errors.
** 07 OCT 2008  PMATAMSR 6891410   As part of NewZealand Direct Credit Enhancement
**             /AVENKATK           procedure add_custom_xml is added to the
**                                 package.This procedure will be called by the
**                                 XML generation process and adds required XML tags
**                                 like BATCH_DUE_DATE,BATCH_CREATION_DATE
**                                 NBNZ_HASH_ACCT and REG_EMPLOYER in the XML
**                                 generated for each assignment.
** 05 DEC 2008  PMATAMSR 7614146   A new cursor get_batch_due_date is added
**                                 to fetch  default_dd_date from the per_time_periods
**                                 as batch_due_date to the NZ Direct Credit XML report.
*/

g_debug 		BOOLEAN := hr_utility.debug_enabled;
g_legislation_code      VARCHAR2(10)    := 'NZ';

/* Bug# 6891410--This  procedure will be called by the XML generation process
 * and adds required XML tags for each assignment*/
PROCEDURE add_custom_xml
IS

  l_text              VARCHAR(900);
  l_batch_due_date   VARCHAR2(100);
  l_batch_creation_date   VARCHAR2(100);

  l_pre_pay_id          VARCHAR2(100);
  l_payroll_action_id   VARCHAR2(100);
  l_assignment_action_id NUMBER(16);
  l_eff_date            DATE;
  l_nbnz_account        VARCHAR2(20);
  l_legal_employer	VARCHAR2(250);
  CURSOR get_effective_date
        (c_payroll_action_id pay_payroll_actions.payroll_action_id%TYPE)
  IS
  SELECT ppa.effective_date
  FROM   pay_payroll_actions ppa
  WHERE  ppa.payroll_action_id  = c_payroll_action_id;

  CURSOR get_nbnz_account_information
        (c_pre_payment_id   pay_pre_payments.pre_payment_id%TYPE
        ,c_effective_date   DATE)
  IS
  SELECT SUBSTR(pea.segment1,3,4)||SUBSTR(LPAD(pea.segment2,8,'0'),2,7)
  FROM  pay_pre_payments ppp
       ,pay_personal_payment_methods_f ppmf
       ,pay_external_accounts  pea
  WHERE ppp.pre_payment_id             = c_pre_payment_id
  AND   ppp.personal_payment_method_id = ppmf.personal_payment_method_id
  AND   ppmf.external_account_id        = pea.external_account_id
  AND   c_effective_date  BETWEEN ppmf.effective_start_date AND ppmf.effective_end_date;

  CURSOR get_legal_employer_info
	(c_payroll_action_id pay_payroll_actions.payroll_action_id%TYPE
	,c_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE)
  IS
  SELECT hou.name
  FROM	pay_assignment_actions paa,
 	hr_organization_units hou
  WHERE paa.payroll_action_id = c_payroll_action_id
  AND	paa.assignment_action_id = c_assignment_action_id
  AND 	to_char(hou.organization_id) = paa.tax_unit_id;

 /*Bug#7614146 -New Cursor added to fetch the batch_due_date from the payroll tables*/

   CURSOR get_batch_due_date(c_pre_payment_id pay_pre_payments.pre_payment_id%TYPE)
   IS
   SELECT to_char(ptp.default_dd_date,'YYYYMMDD')
   FROM        pay_assignment_actions paa,
       pay_pre_payments ppp,
       pay_payroll_actions ppa,
       pay_action_interlocks pai,
       per_time_periods ptp
   WHERE ppp.pre_payment_id = c_pre_payment_id
   AND pai.locking_action_id = ppp.assignment_action_id
   AND paa.assignment_action_id = pai.locked_action_id
   AND ppa.payroll_action_id = paa.payroll_action_id
   AND ppa.payroll_id = ptp.payroll_id
   AND ppa.date_earned BETWEEN ptp.start_date AND ptp.end_date;
  /*End of bug#7614146*/

BEGIN

  if g_debug then
     hr_utility.trace('Add Custom XML starts here .... ');
  end if;
     /*commented for bug#7614146*/
   /*l_batch_due_date           :=  pay_magtape_generic.get_parameter_value('BATCH_DUE_DATE');*/
     l_batch_creation_date      :=  pay_magtape_generic.get_parameter_value('BATCH_CREATION_DATE');
     l_pre_pay_id               :=  pay_magtape_generic.get_parameter_value('PRE_PAY_ID');
     l_payroll_action_id        :=  pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID');
     l_assignment_action_id     :=  pay_magtape_generic.get_parameter_value('TRANSFER_ACT_ID');

  if g_debug then
  /* hr_utility.trace('l_batch_due_date         =>'||l_batch_due_date);*/
     hr_utility.trace('l_batch_creation_date    =>'||l_batch_creation_date);
     hr_utility.trace('l_pre_pay_id             =>'||l_pre_pay_id);
     hr_utility.trace('l_payroll_action_id      =>'||l_payroll_action_id);
     hr_utility.trace('l_assignment_action_id   =>'||l_assignment_action_id);
  end if;

     OPEN get_effective_date(l_payroll_action_id);
     FETCH get_effective_date INTO l_eff_date;
     CLOSE get_effective_date;


     OPEN get_nbnz_account_information(l_pre_pay_id,l_eff_date);
     FETCH get_nbnz_account_information INTO l_nbnz_account;
     CLOSE get_nbnz_account_information;

     OPEN get_legal_employer_info(l_payroll_action_id,l_assignment_action_id);
     FETCH get_legal_employer_info INTO l_legal_employer;
     CLOSE get_legal_employer_info;

     /*Bug#7614146 -Default_dd_date from per_time_periods table is fetched as
      *             Batch Due date into the XML report*/
      OPEN get_batch_due_date(l_pre_pay_id);
      FETCH get_batch_due_date INTO l_batch_due_date;
      CLOSE get_batch_due_date;
     /*End of bug#7614146*/

     l_text :=
        '<NBNZ_HASH_ACCT>'|| l_nbnz_account || '</NBNZ_HASH_ACCT>'||
        '<BATCH_DUE_DATE>'|| l_batch_due_date || '</BATCH_DUE_DATE>'||
        '<BATCH_CREATION_DATE>'||l_batch_creation_date||'</BATCH_CREATION_DATE>'||
        '<REG_EMPLOYER>'||l_legal_employer||'</REG_EMPLOYER>';

     pay_core_files.write_to_magtape_lob(l_text);

  if g_debug then
     hr_utility.trace('Add Custom XML ends here .......');
  end if;

END add_custom_xml;

end pay_nz_eft ;

/
