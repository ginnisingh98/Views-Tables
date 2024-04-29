--------------------------------------------------------
--  DDL for Package Body PAY_US_TAX_BAL_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_TAX_BAL_SUMMARY_PKG" as
/* $Header: pyustxbs.pkb 120.0.12010000.1 2008/07/27 23:57:42 appldev ship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : pay_us_tax_bal_summary_pkg

    Description : This package is used by Tax Balance Summary form AND
    		  contains procedures to fetch federal, state AND local
    		  balances.

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  ------------------------------------
    05-DEC-2003 sdahiya    115.0   3129694  Created.
    22-DEC-2003 sdahiya    115.1   3129694  Properly indented the code. Local
                                            variable names start with 'l_'.
                                            Added few more comments.
    29-JAN-2004 sdahiya    115.2   3362423  Modified following cursors for
                                            performance: -
                                            c_state_ee       c_local2
                                            c_local3         c_local6
                                            c_local8         c_local12
                                            Modified references of these cursors
                                            in GET_STATE and GET_LOCAL procedures.


  *****************************************************************************/



 l_package  VARCHAR2(30) := 'pay_us_tax_bal_summary_pkg.';

 /*****************************************************************************
   Name      :  GET_FED
   Purpose   :  This procedure obtains all federal balance categories,
   		tax types, wage types AND liability types depending on the
   		EE/ER parameter	passed. Along with other parameters, all these
   		balance	categories AND tax/wage/liability types are passed to
   		US payroll package us_taxbal_view_pkg to get actual balance
   		values.
 *****************************************************************************/


PROCEDURE GET_FED (p_ee_er IN VARCHAR2
	         , p_assg_id IN NUMBER
	         , p_asact_id IN NUMBER
	         , p_tax_unit_id IN NUMBER
	         , p_fed_taxes_tab OUT NOCOPY tab_taxes) IS


  /* Cursor to get Federal Taxes/Liabilities/Wages */
  CURSOR c_fed_cur IS
  SELECT
    decode(tax_type_code, 'MEDICARE','Medicare',tax_type_code)||' '
         ||decode(tax_type_code,'FIT',decode(balance_category_code, 'SUBJECT',
	 'Taxable', initcap(balance_category_code)), initcap(balance_category_code)) prompt
      , decode (tax_type_code
      ,'FIT', 1
      ,'SS' , 2
      ,'MEDICARE' , 3
      ,'FUTA', 4
      ,'EIC', 5
      , 6)   ordercol1
   , decode (balance_category_code
      ,'GROSS', 1
      ,'TAXABLE' , 2
      ,'SUBJECT' , 3
      ,'WITHHELD', 4
      ,'ADVANCED', 5
      , 6)   ordercol2
   , tax_type_code
   ,balance_category_code
  FROM pay_us_fed_tax_types_v
  WHERE  ee_or_er_code = p_ee_er
     AND element_name IN ('EIC', 'Medicare_EE', 'FIT', 'SS_EE')
     AND balance_category_code IN ('WITHHELD', 'ADVANCED')
     AND tax_type_code IN ('EIC', 'MEDICARE', 'FIT', 'SS')
  UNION ALL
  SELECT
    decode(tax_type_code, 'MEDICARE','Medicare' ,tax_type_code)||' '
     ||decode(tax_type_code,'FIT',decode(balance_category_code, 'SUBJECT',
	 'Taxable', initcap(balance_category_code)), initcap(balance_category_code)) prompt
   , decode (tax_type_code
      ,'FIT', 1
      ,'SS' , 2
      ,'MEDICARE' , 3
      ,'FUTA', 4
      ,'EIC', 5
      , 6) ordercol1
   , decode (balance_category_code
      ,'GROSS', 1
      ,'TAXABLE' , 2
      ,'SUBJECT' , 3
      ,'WITHHELD', 4
      ,'ADVANCED', 5
      , 6) ordercol2
   , tax_type_code
   ,balance_category_code
  FROM pay_us_fed_ee_wage_types_v
  WHERE  ee_or_er_code = p_ee_er
    AND    ((tax_type_code in ('MEDICARE', 'SS')
            AND balance_category_code = 'TAXABLE')
            OR (tax_type_code IN ('FIT','EIC'))
             )
  UNION ALL
  SELECT
    decode(tax_type_code, 'MEDICARE','Medicare',tax_type_code)||' '
     ||decode(tax_type_code,'FIT',decode(balance_category_code, 'SUBJECT',
	 'Taxable', initcap(balance_category_code)), initcap(balance_category_code)) prompt
   , decode (tax_type_code
      ,'FIT', 1
      ,'SS' , 2
      ,'MEDICARE' , 3
      ,'FUTA', 4
      ,'EIC', 5
      , 6) ordercol1
   , decode (balance_category_code
      ,'GROSS', 1
      ,'TAXABLE' , 2
      ,'SUBJECT' , 3
      ,'WITHHELD', 4
      ,'ADVANCED', 5
      , 6) ordercol2
   , tax_type_code
   ,balance_category_code
  FROM pay_us_fed_liability_types_v
  WHERE  ee_or_er_code = p_ee_er
     AND tax_type_code in ('MEDICARE', 'FUTA', 'SS')
     AND element_name IN ('Medicare_ER', 'FUTA', 'SS_ER')
  UNION ALL
  SELECT
    decode(tax_type_code, 'MEDICARE','Medicare' ,tax_type_code)||' '
     ||decode(tax_type_code,'FIT',decode(balance_category_code, 'SUBJECT',
	 'Taxable', initcap(balance_category_code)), initcap(balance_category_code)) prompt
   , decode (tax_type_code
      ,'FIT', 1
      ,'SS' , 2
      ,'MEDICARE' , 3
      ,'FUTA', 4
      ,'EIC', 5
      , 6) ordercol1
   , decode (balance_category_code
      ,'GROSS', 1
      ,'TAXABLE' , 2
      ,'SUBJECT' , 3
      ,'WITHHELD', 4
      ,'ADVANCED', 5
      , 6) ordercol2
   , tax_type_code
   ,balance_category_code
  FROM pay_us_fed_er_wage_types_v
  WHERE  ee_or_er_code = p_ee_er
    AND  tax_type_code in ('MEDICARE', 'SS','FUTA')
    AND  balance_category_code = 'TAXABLE'
    AND  element_name in ('Medicare_ER','FUTA','SS_ER')
order by 2,3 ;

l_bal_val number;
l_cnt number := 1;
l_procedure varchar2(30) := 'get_fed';

BEGIN
  hr_utility.set_location(l_package||l_procedure, 10);
--hr_utility.trace_on(null,'tax_bal_summary');
  for fed_taxes_rec in c_fed_cur loop
	p_fed_taxes_tab(l_cnt).prompt := fed_taxes_rec.prompt;
        l_bal_val := pay_us_taxbal_view_pkg.us_tax_balance_vm(
			p_tax_balance_category	=> fed_taxes_rec.balance_category_code,
			p_tax_type		=> fed_taxes_rec.tax_type_code,
			p_ee_or_er		=> p_ee_er,
			p_time_type		=> 'YTD',
			p_gre_id_context	=> p_tax_unit_id,
			p_jd_context		=> NULL,
			p_assignment_action_id	=> p_asact_id ,
			p_assignment_id 	=> p_assg_id,
			p_virtual_date 		=> NULL,
                        p_payroll_action_id     => NULL);
        p_fed_taxes_tab(l_cnt).ytd_val := l_bal_val;
        hr_utility.set_location(l_package||l_procedure, 20);
        hr_utility.trace('YTD value = '||l_bal_val);

	l_bal_val := pay_us_taxbal_view_pkg.us_tax_balance_vm(
			p_tax_balance_category	=> fed_taxes_rec.balance_category_code,
			p_tax_type		=> fed_taxes_rec.tax_type_code,
			p_ee_or_er		=> p_ee_er,
			p_time_type		=> 'PTD',
			p_gre_id_context	=> p_tax_unit_id,
			p_jd_context		=> NULL,
			p_assignment_action_id	=> p_asact_id ,
			p_assignment_id 	=> p_assg_id,
			p_virtual_date 		=> NULL,
			p_payroll_action_id     => NULL);
	p_fed_taxes_tab(l_cnt).ptd_val := l_bal_val;
	hr_utility.set_location(l_package||l_procedure, 30);
	hr_utility.trace('PTD value = '||l_bal_val);

	l_bal_val := pay_us_taxbal_view_pkg.us_tax_balance_vm(
			p_tax_balance_category	=> fed_taxes_rec.balance_category_code,
			p_tax_type		=> fed_taxes_rec.tax_type_code,
			p_ee_or_er		=> p_ee_er,
			p_time_type		=> 'MONTH',
			p_gre_id_context	=> p_tax_unit_id,
			p_jd_context		=> NULL,
			p_assignment_action_id	=> p_asact_id ,
			p_assignment_id 	=> p_assg_id,
			p_virtual_date 		=> NULL,
			p_payroll_action_id     => NULL);
	p_fed_taxes_tab(l_cnt).mtd_val := l_bal_val;
	hr_utility.set_location(l_package||l_procedure, 40);
	hr_utility.trace('MTD value = '||l_bal_val);

	l_bal_val := pay_us_taxbal_view_pkg.us_tax_balance_vm(
			p_tax_balance_category	=> fed_taxes_rec.balance_category_code,
			p_tax_type		=> fed_taxes_rec.tax_type_code,
			p_ee_or_er		=> p_ee_er,
			p_time_type		=> 'QTD',
			p_gre_id_context	=> p_tax_unit_id,
			p_jd_context		=> NULL,
			p_assignment_action_id	=> p_asact_id ,
			p_assignment_id 	=> p_assg_id,
			p_virtual_date 		=> NULL,
			p_payroll_action_id     => NULL);
	p_fed_taxes_tab(l_cnt).qtd_val := l_bal_val;
	hr_utility.set_location(l_package||l_procedure, 50);
	hr_utility.trace('QTD value = '||l_bal_val);

	l_cnt := l_cnt + 1;
  end loop;
hr_utility.set_location(l_package||l_procedure, 60);
hr_utility.trace('Normal completion of '||l_package||l_procedure);

EXCEPTION
	WHEN others THEN
	hr_utility.set_location(l_package||l_procedure,70);
	hr_utility.trace('Abormal completion of '||l_package||l_procedure);
	raise_application_error(-20101, 'Error in ' || l_package||l_procedure || ' - ' || sqlerrm);
END GET_FED;



 /*****************************************************************************
   Name      :  GET_STATE
   Purpose   :  This procedure obtains all state level EE/ER balance categories,
   		tax types, wage types AND liability types for a given state.
   		Along with other parameters, all these balance categories AND
   		tax/wage/liability types are passed to US payroll package
   		us_taxbal_view_pkg to get actual balance values.
 *****************************************************************************/

PROCEDURE GET_STATE (p_ee_er IN VARCHAR2
	, p_assg_id IN NUMBER
	, p_asact_id IN NUMBER
	, p_tax_unit_id IN NUMBER
	, p_state_code IN VARCHAR2
	, p_state_taxes_tab OUT NOCOPY tab_taxes) IS

  /* Cursor created as per bug 3362423 */
  CURSOR c_state_dt IS
  SELECT DISTINCT
         NVL(ppa.date_earned,ppa.effective_date)effective_date,
         jurisdiction_code
  FROM  pay_assignment_actions paa
       ,pay_us_emp_state_tax_rules_f pue
       ,pay_payroll_actions ppa
  WHERE paa.assignment_action_id = p_asact_id
    AND pue.assignment_id     = paa.assignment_id
    AND ppa.payroll_action_id = paa.payroll_action_id
    AND ppa.effective_date between pue.effective_start_date
                                 AND pue.effective_end_date
    AND pue.state_code = p_state_code
    AND ppa.action_type in ('Q', 'R', 'V', 'B', 'I');


  /* Cursor to get State Taxes and EE Wages. Modified as per bug 3362423. */
  CURSOR c_state_ee (p_eff_dt IN DATE,p_jurisdiction_code VARCHAR2) IS
  SELECT DISTINCT
     tax_type_code||' '
     ||decode(tax_type_code,'SIT',decode(balance_category_code, 'SUBJECT',
	                                'Taxable', initcap(balance_category_code)), initcap(balance_category_code)) prompt
   , decode (tax_type_code
      ,'SIT', 1
      ,'SUI', 2
      ,'SDI' , 3
      ,'WCE' , 4
      ,'WC2', 5
      , 6) ordercol1
   , decode (balance_category_code
      ,'GROSS', 1
      ,'TAXABLE' , 2
      ,'SUBJECT' , 3
      ,'WITHHELD', 4
      ,'ADVANCED', 5
      , 6) ordercol2
   , tax_type_code
   , balance_category_code
   , jurisdiction_code
  FROM pay_assignment_actions   paa
     ,pay_payroll_actions      ppa
     ,pay_us_state_tax_types_v pstt
     ,pay_us_emp_state_tax_rules_f pue
  WHERE paa.assignment_action_id = p_asact_id
  AND pue.assignment_id     = paa.assignment_id
  AND ppa.payroll_action_id = paa.payroll_action_id
  AND ppa.effective_date between pue.effective_start_date
                             AND pue.effective_end_date
  AND pue.state_code = p_state_code
  AND ppa.action_type in ('Q', 'R', 'V', 'B', 'I')
  AND NVL(ppa.date_earned,ppa.effective_date) between
                pstt.effective_start_date AND pstt.effective_end_date

  UNION ALL
  SELECT DISTINCT
    tax_type_code||' '
     ||decode(tax_type_code,'SIT',decode(balance_category_code, 'SUBJECT',
	 'Taxable', initcap(balance_category_code)), initcap(balance_category_code)) prompt
   , decode (tax_type_code
      ,'SIT', 1
      ,'SUI', 2
      ,'SDI' , 3
      ,'WCE' , 4
      ,'WC2', 5
      , 6) ordercol1
   , decode (balance_category_code
      ,'GROSS', 1
      ,'TAXABLE' , 2
      ,'SUBJECT' , 3
      ,'WITHHELD', 4
      ,'ADVANCED', 5
      , 6) ordercol2
   , tax_type_code
   , balance_category_code
   , p_jurisdiction_code
  FROM pay_us_state_ee_wage_types_v pstt
  WHERE p_eff_dt between
              pstt.effective_start_date AND pstt.effective_end_date
  AND    ((tax_type_code = 'SIT'
          AND balance_category_code = 'SUBJECT')
       OR (tax_type_code <> 'SIT'
           AND balance_category_code = 'TAXABLE')
         )
  AND (element_name like 'SIT%'
       OR element_name like 'SDI%'
       OR element_name like 'SUI%' )
  AND pstt.element_type_id >= 0
  ORDER BY 2,3;

  /* Cursor to get State Liabilities/ER Wages */
  CURSOR c_state_er (p_state_code IN VARCHAR2) IS
  SELECT DISTINCT
     tax_type_code||' '
     ||decode(tax_type_code,'SIT',decode(balance_category_code,
                                        'SUBJECT','Taxable',
                                        initcap(balance_category_code)),
                             initcap(balance_category_code)) prompt
    , decode (tax_type_code
      ,'SIT', 1
      ,'SUI', 2
      ,'SDI' , 3
      ,'WCE' , 4
      ,'WC2', 5
      , 6) ordercol1
    , decode (balance_category_code
      ,'GROSS', 1
      ,'TAXABLE' , 2
      ,'SUBJECT' , 3
      ,'WITHHELD', 4
      ,'ADVANCED', 5
      , 6) ordercol2
    , tax_type_code
    , balance_category_code
    , jurisdiction_code
  FROM  pay_assignment_actions   paa
     ,pay_payroll_actions      ppa
     ,pay_us_state_liability_types_v pstt
     ,pay_us_emp_state_tax_rules_f pue
  WHERE paa.assignment_action_id = p_asact_id
  AND pue.assignment_id     = paa.assignment_id
  AND ppa.payroll_action_id = paa.payroll_action_id
  AND ppa.effective_date between pue.effective_start_date
                             AND pue.effective_end_date
  AND pue.state_code = p_state_code
  AND ppa.action_type in ('Q', 'R', 'V', 'B', 'I')
  AND NVL(ppa.date_earned,ppa.effective_date) between
                      pstt.effective_start_date AND pstt.effective_end_date
  AND pstt.ELEMENT_NAME IN ('SDI_ER', 'SUI_ER')
  AND pstt.BALANCE_CATEGORY_CODE = 'LIABILITY'
  AND pstt.TAX_TYPE_CODE in ('SDI','SUI')
 UNION ALL
  SELECT DISTINCT
    tax_type_code||' '||
       decode(tax_type_code,'SIT',decode(balance_category_code,
                                        'SUBJECT','Taxable',
                                        initcap(balance_category_code)),
                             initcap(balance_category_code)) prompt
   , decode (tax_type_code
      ,'SIT', 1
      ,'SUI', 2
      ,'SDI' , 3
      ,'WCE' , 4
      ,'WC2', 5
      , 6) ordercol1
   , decode (balance_category_code
      ,'GROSS', 1
      ,'TAXABLE' , 2
      ,'WITHHELD' , 3
      ,'SUBJECT', 4
      ,'ADVANCED', 5
      , 6) ordercol2
   , tax_type_code
   , balance_category_code
   , jurisdiction_code
  FROM  pay_assignment_actions   paa
     ,pay_payroll_actions      ppa
     ,pay_us_state_er_wage_types_v pstt
     ,pay_us_emp_state_tax_rules_f pue
  WHERE pue.assignment_id     = paa.assignment_id
  AND ppa.payroll_action_id = paa.payroll_action_id
  AND ppa.effective_date between pue.effective_start_date
                             AND pue.effective_end_date
  AND pue.state_code = p_state_code
  AND ppa.action_type in ('Q', 'R', 'V', 'B', 'I')
  AND NVL(ppa.date_earned,ppa.effective_date) between
               pstt.effective_start_date AND pstt.effective_end_date
  AND paa.assignment_action_id = p_asact_id
  AND ELEMENT_NAME IN ('SDI_ER', 'SUI_ER')
  AND tax_type_code in ('SDI','SUI')
  AND balance_category_code = 'TAXABLE'
  ORDER BY 2,3;

l_bal_val number;
l_cnt number := 1;
l_procedure varchar2(30) := 'get_state';

BEGIN
  hr_utility.set_location(l_package||l_procedure, 10);
--hr_utility.trace_on(null,'tax_bal_summary');
   if p_ee_er = 'EE' then
        for state_dt in c_state_dt loop
	for state_ee in c_state_ee (state_dt.effective_date, state_dt.jurisdiction_code) loop
		p_state_taxes_tab(l_cnt).prompt := state_ee.prompt;
		l_bal_val := pay_us_taxbal_view_pkg.us_tax_balance_vm(
				p_tax_balance_category	=> state_ee.balance_category_code,
				p_tax_type		=> state_ee.tax_type_code,
				p_ee_or_er		=> p_ee_er,
				p_time_type		=> 'YTD',
				p_gre_id_context	=> p_tax_unit_id,
				p_jd_context		=> state_ee.jurisdiction_code,
				p_assignment_action_id	=> p_asact_id ,
				p_assignment_id 	=> p_assg_id,
				p_virtual_date 		=> NULL,
				p_payroll_action_id     => NULL);
		p_state_taxes_tab(l_cnt).ytd_val := l_bal_val;
		hr_utility.set_location(l_package||l_procedure, 20);
		hr_utility.trace('YTD value = '||l_bal_val);

		l_bal_val := pay_us_taxbal_view_pkg.us_tax_balance_vm(
				p_tax_balance_category	=> state_ee.balance_category_code,
				p_tax_type		=> state_ee.tax_type_code,
				p_ee_or_er		=> p_ee_er,
				p_time_type		=> 'PTD',
				p_gre_id_context	=> p_tax_unit_id,
				p_jd_context		=> state_ee.jurisdiction_code,
				p_assignment_action_id	=> p_asact_id ,
				p_assignment_id 	=> p_assg_id,
				p_virtual_date 		=> NULL,
				p_payroll_action_id     => NULL);
		p_state_taxes_tab(l_cnt).ptd_val := l_bal_val;
		hr_utility.set_location(l_package||l_procedure, 30);
		hr_utility.trace('PTD value = '||l_bal_val);

		l_bal_val := pay_us_taxbal_view_pkg.us_tax_balance_vm(
				p_tax_balance_category	=> state_ee.balance_category_code,
				p_tax_type		=> state_ee.tax_type_code,
				p_ee_or_er		=> p_ee_er,
				p_time_type		=> 'MONTH',
				p_gre_id_context	=> p_tax_unit_id,
				p_jd_context		=> state_ee.jurisdiction_code,
				p_assignment_action_id	=> p_asact_id ,
				p_assignment_id 	=> p_assg_id,
				p_virtual_date 		=> NULL,
				p_payroll_action_id     => NULL);
		p_state_taxes_tab(l_cnt).mtd_val := l_bal_val;
		hr_utility.set_location(l_package||l_procedure, 40);
		hr_utility.trace('MTD value = '||l_bal_val);

		l_bal_val := pay_us_taxbal_view_pkg.us_tax_balance_vm(
				p_tax_balance_category	=> state_ee.balance_category_code,
				p_tax_type		=> state_ee.tax_type_code,
				p_ee_or_er		=> p_ee_er,
				p_time_type		=> 'QTD',
				p_gre_id_context	=> p_tax_unit_id,
				p_jd_context		=> state_ee.jurisdiction_code,
				p_assignment_action_id	=> p_asact_id ,
				p_assignment_id 	=> p_assg_id,
				p_virtual_date 		=> NULL,
				p_payroll_action_id     => NULL);
		p_state_taxes_tab(l_cnt).qtd_val := l_bal_val;
		hr_utility.set_location(l_package||l_procedure, 50);
		hr_utility.trace('QTD value = '||l_bal_val);

		l_cnt := l_cnt + 1;
	end loop;
	end loop;
   else
	for state_er in c_state_er (p_state_code) loop
		p_state_taxes_tab(l_cnt).prompt := state_er.prompt;
	        l_bal_val := pay_us_taxbal_view_pkg.us_tax_balance_vm(
				p_tax_balance_category	=> state_er.balance_category_code,
				p_tax_type		=> state_er.tax_type_code,
				p_ee_or_er		=> p_ee_er,
				p_time_type		=> 'YTD',
				p_gre_id_context	=> p_tax_unit_id,
				p_jd_context		=> state_er.jurisdiction_code,
				p_assignment_action_id	=> p_asact_id ,
				p_assignment_id 	=> p_assg_id,
				p_virtual_date 		=> NULL,
	                        p_payroll_action_id     => NULL);
		p_state_taxes_tab(l_cnt).ytd_val := l_bal_val;
		hr_utility.set_location(l_package||l_procedure, 60);
		hr_utility.trace('YTD value = '||l_bal_val);

		l_bal_val := pay_us_taxbal_view_pkg.us_tax_balance_vm(
				p_tax_balance_category	=> state_er.balance_category_code,
				p_tax_type		=> state_er.tax_type_code,
				p_ee_or_er		=> p_ee_er,
				p_time_type		=> 'PTD',
				p_gre_id_context	=> p_tax_unit_id,
				p_jd_context		=> state_er.jurisdiction_code,
				p_assignment_action_id	=> p_asact_id ,
				p_assignment_id 	=> p_assg_id,
				p_virtual_date 		=> NULL,
				p_payroll_action_id     => NULL);
		p_state_taxes_tab(l_cnt).ptd_val := l_bal_val;
		hr_utility.set_location(l_package||l_procedure, 70);
		hr_utility.trace('PTD value = '||l_bal_val);

		l_bal_val := pay_us_taxbal_view_pkg.us_tax_balance_vm(
				p_tax_balance_category	=> state_er.balance_category_code,
				p_tax_type		=> state_er.tax_type_code,
				p_ee_or_er		=> p_ee_er,
				p_time_type		=> 'MONTH',
				p_gre_id_context	=> p_tax_unit_id,
				p_jd_context		=> state_er.jurisdiction_code,
				p_assignment_action_id	=> p_asact_id ,
				p_assignment_id 	=> p_assg_id,
				p_virtual_date 		=> NULL,
				p_payroll_action_id     => NULL);
		p_state_taxes_tab(l_cnt).mtd_val := l_bal_val;
		hr_utility.set_location(l_package||l_procedure, 80);
		hr_utility.trace('MTD value = '||l_bal_val);

		l_bal_val := pay_us_taxbal_view_pkg.us_tax_balance_vm(
				p_tax_balance_category	=> state_er.balance_category_code,
				p_tax_type		=> state_er.tax_type_code,
				p_ee_or_er		=> p_ee_er,
				p_time_type		=> 'QTD',
				p_gre_id_context	=> p_tax_unit_id,
				p_jd_context		=> state_er.jurisdiction_code,
				p_assignment_action_id	=> p_asact_id ,
				p_assignment_id 	=> p_assg_id,
				p_virtual_date 		=> NULL,
				p_payroll_action_id     => NULL);
		p_state_taxes_tab(l_cnt).qtd_val := l_bal_val;
		hr_utility.set_location(l_package||l_procedure, 90);
		hr_utility.trace('QTD value = '||l_bal_val);

		l_cnt := l_cnt + 1;
	end loop;
   end if;
   hr_utility.set_location(l_package||l_procedure, 100);
   hr_utility.trace('Normal completion of '||l_package||l_procedure);
EXCEPTION
	WHEN others THEN
	hr_utility.set_location(l_package||l_procedure,110);
	hr_utility.trace('Abnormal completion of '||l_package||l_procedure);
	raise_application_error(-20101, 'Error in ' || l_package||l_procedure || ' - ' || sqlerrm);
END GET_STATE;





/*****************************************************************************
   Name      :  GET_LOCAL
   Purpose   :  This procedure obtains all local balance categories,
   		tax types AND EE wage types for a given jurisdiction code.
   		Along with other parameters, all these balance	categories
   		AND tax/wage types are passed to US payroll package
   		us_taxbal_view_pkg to get actual balance values.
 *****************************************************************************/

PROCEDURE GET_LOCAL (p_ee_er IN VARCHAR2
	, p_assg_id IN NUMBER
	, p_asact_id IN NUMBER
	, p_tax_unit_id NUMBER
        , p_jurisdiction IN VARCHAR2
        , p_school IN VARCHAR2
        , p_local_taxes_tab OUT NOCOPY tab_taxes) IS


------------Local Taxes ! SCHOOL------------
  /* Cursor for City taxes with tax_type_code <> School */
  CURSOR c_local1 IS
   SELECT DISTINCT
    decode(tax_type_code, 'COUNTY', 'County',
                        'CITY', 'City', tax_type_code)||' '
                       ||initcap(balance_category_code) prompt
      , decode (tax_type_code
       ,'COUNTY', 1
       ,'CITY' , 2
       ,'HT' , 3
       , 6) ordercol1
    , decode (balance_category_code
       ,'TAXABLE' , 2
       ,'SUBJECT' , 3
       ,'WITHHELD' , 4
       , 6) ordercol2
    , tax_type_code
    , balance_category_code
    , city.jurisdiction_code
  FROM
   pay_assignment_actions paa ,
   pay_payroll_actions ppa ,
   pay_us_local_tax_types_v petv ,
   pay_us_emp_city_tax_rules_f city ,
   pay_us_city_names names ,
   pay_us_city_tax_info_f citf
 WHERE paa.payroll_action_id = ppa.payroll_action_id
   AND ppa.effective_date between city.effective_start_date
                           AND city.effective_end_date
   AND city.assignment_id = paa.assignment_id
   AND names.city_code   = substr(city.jurisdiction_code,8,4)
   AND names.county_code = substr(city.jurisdiction_code,4,3)
   AND names.state_code  = substr(city.jurisdiction_code,1,2)
   AND names.primary_flag = 'Y'
   AND citf.jurisdiction_code = city.jurisdiction_code
   AND decode(tax_type_code, 'CITY', citf.city_tax, 'HT' , citf.head_tax, 'N') = 'Y'
   AND ppa.effective_date between citf.effective_start_date AND citf.effective_end_date
   AND petv.tax_type_code IN ('CITY', 'HT')
   AND ppa.action_type in ('Q', 'R', 'V', 'I', 'B')
   AND nvl(ppa.date_earned, ppa.effective_date) between petv.effective_start_date AND petv.effective_end_date
   AND paa.assignment_id = p_assg_id
   AND    assignment_action_id = p_asact_id
   AND    tax_unit_id = p_tax_unit_id
   AND    (city.jurisdiction_code||'' = p_jurisdiction OR
          city.jurisdiction_code||'' = substr(p_jurisdiction,1,6)||'-0000')
   AND    tax_type_code <> 'SCHOOL'
 ORDER BY 2,3;


  /* Cursor created as per bug 3362423 */
 CURSOR c_local_dt2 IS
     SELECT DISTINCT
            NVL(ppa.date_earned,ppa.effective_date)effective_date,
            cnty.jurisdiction_code jurisdiction_code
   FROM
       pay_assignment_actions paa ,
       pay_payroll_actions ppa ,
       pay_us_emp_county_tax_rules_f cnty ,
       pay_us_county_tax_info_f ctif ,
       pay_us_counties names
   WHERE paa.payroll_action_id = ppa.payroll_action_id
   AND ppa.effective_date between cnty.effective_start_date AND cnty.effective_end_date
   AND cnty.assignment_id = paa.assignment_id
   AND names.county_code = substr(cnty.jurisdiction_code,4,3)
   AND names.state_code  = substr(cnty.jurisdiction_code,1,2)
   AND ctif.jurisdiction_code = cnty.jurisdiction_code
   AND ctif.county_tax = 'Y'
   AND ppa.effective_date between ctif.effective_start_date AND ctif.effective_end_date
   AND ppa.action_type in ('Q', 'R', 'V', 'I', 'B')
   AND paa.assignment_id = p_assg_id
   AND assignment_action_id = p_asact_id
   AND tax_unit_id = p_tax_unit_id
   AND (cnty.jurisdiction_code||'' = p_jurisdiction or
        cnty.jurisdiction_code||'' = substr(p_jurisdiction,1,6)||'-0000');


 /* Cursor for County taxes with tax_type_code <> School. Modified as per bug 3362423. */
 CURSOR c_local2(p_eff_date DATE, p_jurisdiction_code VARCHAR2) IS
   SELECT DISTINCT
     decode(tax_type_code, 'COUNTY', 'County', 'CITY', 'City', tax_type_code)||' '
              ||initcap(balance_category_code) prompt
   , decode (tax_type_code
      ,'COUNTY', 1
      ,'CITY' , 2
      ,'HT' , 3
      , 6) ordercol1
  , decode (balance_category_code
      ,'TAXABLE' , 2
      ,'SUBJECT' , 3
      ,'WITHHELD' , 4
      , 6) ordercol2
  , tax_type_code
  , balance_category_code
  , p_jurisdiction_code jurisdiction_code
   FROM
       pay_us_local_tax_types_v petv
   WHERE petv.tax_type_code = 'COUNTY'
   AND p_eff_date between petv.effective_start_date AND petv.effective_end_date
   AND petv.tax_type_code <> 'SCHOOL'
   ORDER BY 2,3;

 /* Cursor created as per bug 3362423 */
  CURSOR c_local_dt3 IS
      SELECT DISTINCT
             NVL(ppa.date_earned,ppa.effective_date)effective_date,
             jurisdiction_code
    FROM pay_assignment_actions paa ,
      pay_payroll_actions ppa ,
      pay_us_asg_schools_v school
   WHERE paa.payroll_action_id = ppa.payroll_action_id
     AND school.assignment_id = paa.assignment_id
     AND school.tax_unit_id = paa.tax_unit_id
     AND ppa.action_type in ('Q', 'R', 'V', 'I', 'B')
     AND paa.assignment_id = p_assg_id
     AND assignment_action_id = p_asact_id
     AND paa.tax_unit_id = p_tax_unit_id
     AND (jurisdiction_code||'' = p_jurisdiction or
         jurisdiction_code||'' = substr(p_jurisdiction,1,6)||'-0000');


 /* Cursor for School taxes with tax_type_code <> School. Modified as per bug 3362423. */
 CURSOR c_local3(p_eff_date DATE, p_jurisdiction_code VARCHAR2) IS
   SELECT DISTINCT
      decode(tax_type_code, 'COUNTY', 'County', 'CITY', 'City', tax_type_code)||' '
               ||initcap(balance_category_code) prompt
    , decode (tax_type_code
      ,'COUNTY', 1
      ,'CITY' , 2
      ,'HT' , 3
      , 6) ordercol1
    , decode (balance_category_code
      ,'TAXABLE' , 2
      ,'SUBJECT' , 3
      ,'WITHHELD' , 4
      , 6) ordercol2
    , tax_type_code
    , balance_category_code
    , p_jurisdiction_code jurisdiction_code
   FROM pay_us_local_tax_types_v petv
   WHERE p_eff_date between petv.effective_start_date AND petv.effective_end_date
     AND petv.tax_type_code <> 'SCHOOL'
   ORDER BY 2,3;

------------Local Taxes ! School ------------


  /* Cursor for City EE Wages with tax_type_code <> School */
  CURSOR c_local4 IS
------------Local EE Wages ! School ---------
   SELECT DISTINCT
     decode(tax_type_code, 'COUNTY', 'County', 'CITY', 'City', tax_type_code)||' '
     ||decode(balance_category_code, 'SUBJECT',
	 'Taxable', initcap(balance_category_code)) prompt
   , decode (tax_type_code
       ,'COUNTY', 1
      ,'CITY', 2
      ,'HT' , 3
      , 6) ordercol1
    , decode (balance_category_code
      ,'TAXABLE' , 2
      ,'SUBJECT' , 3
      ,'WITHHELD' , 4
      , 6) ordercol2
    , tax_type_code
    , balance_category_code
    , city.jurisdiction_code
   FROM   pay_assignment_actions paa
      ,pay_payroll_actions ppa
      ,pay_us_local_ee_wage_types_v petv
      ,pay_us_city_names names
      ,pay_us_emp_city_tax_rules_f city
      ,pay_us_city_tax_info_f citf
    WHERE paa.payroll_action_id = ppa.payroll_action_id
      AND ppa.effective_date between city.effective_start_date AND city.effective_end_date
      AND city.assignment_id = paa.assignment_id
      AND names.city_code = substr(city.jurisdiction_code,8,4)
      AND names.county_code = substr(city.jurisdiction_code,4,3)
      AND names.state_code = substr(city.jurisdiction_code,1,2)
      AND names.primary_flag = 'Y'
      AND citf.jurisdiction_code = city.jurisdiction_code
      AND decode(tax_type_code, 'CITY', citf.city_tax, 'HT', citf.head_tax, 'N') = 'Y'
      AND ppa.effective_date between citf.effective_start_date AND citf.effective_end_date
      AND petv.tax_type_code in ('CITY', 'HT')
      AND ppa.action_type in ('Q', 'R', 'V', 'I', 'B')
      AND nvl(ppa.date_earned, ppa.effective_date) between petv.effective_start_date AND petv.effective_end_date
      AND paa.assignment_id = p_assg_id
      AND assignment_action_id = p_asact_id
      AND tax_unit_id = p_tax_unit_id
      AND (city.jurisdiction_code||'' = p_jurisdiction or
           city.jurisdiction_code||'' = substr(p_jurisdiction,1,6)||'-0000')
      AND tax_type_code <> 'SCHOOL'
   ORDER BY 2,3;

 /* Cursor for County EE Wages with tax_type_code <> School */
 CURSOR c_local5 IS
   SELECT DISTINCT
      decode(tax_type_code, 'COUNTY', 'County', 'CITY', 'City', tax_type_code)||' '
          ||decode(balance_category_code, 'SUBJECT',
	 'Taxable', initcap(balance_category_code)) prompt
    , decode (tax_type_code
      ,'COUNTY', 1
      ,'CITY', 2
      ,'HT' , 3
      , 6) ordercol1
    , decode (balance_category_code
      ,'TAXABLE' , 2
      ,'SUBJECT' , 3
      ,'WITHHELD' , 4
      , 6) ordercol2
    , tax_type_code
    , balance_category_code
    , cnty.jurisdiction_code
   FROM  pay_assignment_actions paa
        ,pay_payroll_actions ppa
        ,pay_us_local_ee_wage_types_v petv
        ,pay_us_emp_county_tax_rules_f cnty
        ,pay_us_county_tax_info_f ctif
        ,pay_us_counties names
   WHERE paa.payroll_action_id = ppa.payroll_action_id
     AND ppa.effective_date between cnty.effective_start_date AND cnty.effective_end_date
     AND cnty.assignment_id = paa.assignment_id
     AND names.county_code = substr(cnty.jurisdiction_code,4,3)
     AND names.state_code = substr(cnty.jurisdiction_code,1,2)
     AND petv.tax_type_code = 'COUNTY'
     AND ctif.jurisdiction_code = cnty.jurisdiction_code
     AND ctif.county_tax = 'Y'
     AND ppa.effective_date between ctif.effective_start_date AND ctif.effective_end_date
     AND ppa.action_type in ('Q', 'R', 'V', 'I', 'B')
     AND nvl(ppa.date_earned, ppa.effective_date) between petv.effective_start_date AND petv.effective_end_date
     AND paa.assignment_id = p_assg_id
     AND assignment_action_id = p_asact_id
     AND tax_unit_id = p_tax_unit_id
     AND (cnty.jurisdiction_code||'' = p_jurisdiction or
         cnty.jurisdiction_code||'' = substr(p_jurisdiction,1,6)||'-0000')
     AND tax_type_code <> 'SCHOOL'
   ORDER BY 2,3;

 /* Cursor created as per bug 3362423 */
  CURSOR c_local_dt6 IS
       SELECT DISTINCT
              NVL(ppa.date_earned,ppa.effective_date)effective_date,
              jurisdiction_code
   FROM pay_assignment_actions paa
      , pay_payroll_actions ppa
      , pay_us_asg_schools_v school
   WHERE paa.payroll_action_id = ppa.payroll_action_id
     AND school.assignment_id = paa.assignment_id
     AND school.tax_unit_id = paa.tax_unit_id
     AND ppa.action_type in ('Q', 'R', 'V', 'I', 'B')
     AND paa.assignment_id = p_assg_id
     AND assignment_action_id = p_asact_id
     AND paa.tax_unit_id = p_tax_unit_id
     AND (jurisdiction_code||'' = p_jurisdiction or
         jurisdiction_code||'' = substr(p_jurisdiction,1,6)||'-0000');

 /* Cursor for School EE Wages with tax_type_code <> School. Modified as per bug 3362423. */
 CURSOR c_local6 (p_eff_date DATE, p_jurisdiction_code VARCHAR2) IS
   SELECT DISTINCT
      decode(tax_type_code, 'COUNTY', 'County', 'CITY', 'City', tax_type_code)||' '
         ||decode(balance_category_code, 'SUBJECT',
	 'Taxable', initcap(balance_category_code)) prompt
    , decode (tax_type_code
       ,'COUNTY', 1
       ,'CITY', 2
       ,'HT' , 3
       , 6) ordercol1
    , decode (balance_category_code
       ,'TAXABLE' , 2
       ,'SUBJECT' , 3
       ,'WITHHELD' , 4
       , 6) ordercol2
    , tax_type_code
    , balance_category_code
    , p_jurisdiction_code jurisdiction_code
   FROM pay_us_local_ee_wage_types_v petv
   WHERE petv.tax_type_code in ('SCHOOL')
     AND p_eff_date between petv.effective_start_date AND petv.effective_end_date
     AND petv.tax_type_code <> 'SCHOOL'
   ORDER BY 2,3;

------------Local EE Wages ! School---------

   /* Cursor for City Taxes with tax_type_code = School */
   CURSOR c_local7 IS
-----local taxes = school-----------
   SELECT DISTINCT
       tax_type_code||' '
          ||initcap(balance_category_code) prompt
     , 1 ordercol1
     , decode (balance_category_code
       ,'TAXABLE' , 2
       ,'SUBJECT' , 3
       ,'WITHHELD' , 4
       , 6) ordercol2
     , tax_type_code
     , balance_category_code
   , city.jurisdiction_code
   FROM pay_assignment_actions paa ,
        pay_payroll_actions ppa ,
        pay_us_local_tax_types_v petv ,
        pay_us_emp_city_tax_rules_f city ,
        pay_us_city_names names ,
        pay_us_city_tax_info_f citf
   WHERE paa.payroll_action_id = ppa.payroll_action_id
     AND ppa.effective_date between city.effective_start_date AND city.effective_end_date
     AND city.assignment_id = paa.assignment_id
     AND names.city_code   = substr(city.jurisdiction_code,8,4)
     AND names.county_code = substr(city.jurisdiction_code,4,3)
     AND names.state_code  = substr(city.jurisdiction_code,1,2)
     AND names.primary_flag = 'Y'
     AND citf.jurisdiction_code = city.jurisdiction_code
     AND decode(tax_type_code, 'CITY', citf.city_tax, 'HT' , citf.head_tax, 'N') = 'Y'
     AND ppa.effective_date between citf.effective_start_date AND citf.effective_end_date
     AND petv.tax_type_code IN ('CITY', 'HT')
     AND ppa.action_type in ('Q', 'R', 'V', 'I', 'B')
     AND nvl(ppa.date_earned, ppa.effective_date) between petv.effective_start_date AND petv.effective_end_date
     AND paa.assignment_id = p_assg_id
     AND assignment_action_id = p_asact_id
     AND tax_unit_id = p_tax_unit_id
     AND city.jurisdiction_code||'' = (substr(p_jurisdiction,1,3)||p_school)
     AND tax_type_code = 'SCHOOL'
   ORDER BY 2,3;

   /* Cursor created as per bug 3362423 */
  CURSOR c_local_dt8 IS
    SELECT DISTINCT
           NVL(ppa.date_earned,ppa.effective_date)effective_date,
           cnty.jurisdiction_code jurisdiction_code
    FROM pay_assignment_actions paa ,
         pay_payroll_actions ppa ,
         pay_us_emp_county_tax_rules_f cnty ,
         pay_us_county_tax_info_f ctif ,
         pay_us_counties names
    WHERE paa.payroll_action_id = ppa.payroll_action_id
      AND ppa.effective_date between cnty.effective_start_date AND cnty.effective_end_date
         AND cnty.assignment_id = paa.assignment_id
         AND names.county_code = substr(cnty.jurisdiction_code,4,3)
         AND names.state_code  = substr(cnty.jurisdiction_code,1,2)
         AND ctif.jurisdiction_code = cnty.jurisdiction_code
         AND ctif.county_tax = 'Y'
         AND ppa.effective_date between ctif.effective_start_date AND ctif.effective_end_date
         AND ppa.action_type in ('Q', 'R', 'V', 'I', 'B')
         AND paa.assignment_id = p_assg_id
         AND assignment_action_id = p_asact_id
         AND tax_unit_id = p_tax_unit_id
         AND cnty.jurisdiction_code||'' = (substr(p_jurisdiction,1,3)||p_school);

  /* Cursor for County Taxes with tax_type_code = School. Modified as per bug 3362423. */
  CURSOR c_local8 (p_eff_date DATE, p_jurisdiction_code VARCHAR2) IS
   SELECT DISTINCT
      tax_type_code||' '
         ||initcap(balance_category_code) prompt
    , 1 ordercol1
    , decode (balance_category_code
        ,'TAXABLE' , 2
        ,'SUBJECT' , 3
        ,'WITHHELD' , 4
        , 6) ordercol2
    , tax_type_code
    , balance_category_code
    , p_jurisdiction_code jurisdiction_code
   FROM
        pay_us_local_tax_types_v petv
   WHERE petv.tax_type_code = 'COUNTY'
     AND p_eff_date between petv.effective_start_date AND petv.effective_end_date
     AND petv.tax_type_code = 'SCHOOL'
   ORDER BY 2,3;

   /* Cursor for School Taxes with tax_type_code = School */
   CURSOR c_local9 IS
    SELECT DISTINCT
       tax_type_code||' '
          ||initcap(balance_category_code) prompt
     , 1 ordercol1
     , decode (balance_category_code
         ,'TAXABLE' , 2
         ,'SUBJECT' , 3
         ,'WITHHELD' , 4
         , 6) ordercol2
     , tax_type_code
     , balance_category_code
     , jurisdiction_code
   FROM pay_assignment_actions paa ,
        pay_payroll_actions ppa ,
        pay_us_local_tax_types_v petv ,
        pay_us_asg_schools_v school
   WHERE paa.payroll_action_id = ppa.payroll_action_id
     AND school.assignment_id = paa.assignment_id
     AND school.tax_unit_id = paa.tax_unit_id
     AND ppa.action_type in ('Q', 'R', 'V', 'I', 'B')
     AND nvl(ppa.date_earned, ppa.effective_date) between petv.effective_start_date AND petv.effective_end_date
     AND paa.assignment_id = p_assg_id
     AND assignment_action_id = p_asact_id
     AND paa.tax_unit_id = p_tax_unit_id
     AND jurisdiction_code||'' = (substr(p_jurisdiction,1,3)||p_school)
     AND tax_type_code = 'SCHOOL'
   ORDER BY 2,3;
----local taxes = school ----------------

  /* Cursor for City EE Wages with tax_type_code = School */
  CURSOR c_local10 IS
-------Local ee wages = School ----------
   SELECT DISTINCT
      tax_type_code||' '
         ||decode(balance_category_code, 'SUBJECT',
         'Taxable', initcap(balance_category_code)) prompt
     , 1 ordercol1
     , decode (balance_category_code
        ,'TAXABLE' , 2
        ,'SUBJECT' , 3
        ,'WITHHELD' , 4
        , 6) ordercol2
     , tax_type_code
     , balance_category_code
     , city.jurisdiction_code
   FROM pay_assignment_actions paa
       ,pay_payroll_actions ppa
       ,pay_us_local_ee_wage_types_v petv
       ,pay_us_city_names names
       ,pay_us_emp_city_tax_rules_f city
       ,pay_us_city_tax_info_f citf
   WHERE paa.payroll_action_id = ppa.payroll_action_id
     AND ppa.effective_date between city.effective_start_date AND city.effective_end_date
     AND city.assignment_id = paa.assignment_id
     AND names.city_code = substr(city.jurisdiction_code,8,4)
     AND names.county_code = substr(city.jurisdiction_code,4,3)
     AND names.state_code = substr(city.jurisdiction_code,1,2)
     AND names.primary_flag = 'Y'
     AND citf.jurisdiction_code = city.jurisdiction_code
     AND decode(tax_type_code, 'CITY', citf.city_tax, 'HT', citf.head_tax, 'N') = 'Y'
     AND ppa.effective_date between citf.effective_start_date AND citf.effective_end_date
     AND petv.tax_type_code in ('CITY', 'HT')
     AND ppa.action_type in ('Q', 'R', 'V', 'I', 'B')
     AND nvl(ppa.date_earned, ppa.effective_date) between petv.effective_start_date AND petv.effective_end_date
     AND paa.assignment_id = p_assg_id
     AND assignment_action_id = p_asact_id
     AND tax_unit_id = p_tax_unit_id
     AND city.jurisdiction_code||'' = (substr(p_jurisdiction,1,3)||p_school)
     AND tax_type_code = 'SCHOOL'
    ORDER BY 2,3;

  /* Cursor for County EE Wages with tax_type_code = School */
  CURSOR c_local11 IS
   SELECT DISTINCT
      tax_type_code||' '
         ||decode(balance_category_code, 'SUBJECT',
	   'Taxable', initcap(balance_category_code)) prompt
      , 1 ordercol1
      , decode (balance_category_code
         ,'TAXABLE' , 2
         ,'SUBJECT' , 3
         ,'WITHHELD' , 4
         , 6) ordercol2
      , tax_type_code
      , balance_category_code
      , cnty.jurisdiction_code
   FROM pay_assignment_actions paa
       ,pay_payroll_actions ppa
       ,pay_us_local_ee_wage_types_v petv
       ,pay_us_emp_county_tax_rules_f cnty
       ,pay_us_county_tax_info_f ctif
       ,pay_us_counties names
   WHERE paa.payroll_action_id = ppa.payroll_action_id
     AND ppa.effective_date between cnty.effective_start_date AND cnty.effective_end_date
     AND cnty.assignment_id = paa.assignment_id
     AND names.county_code = substr(cnty.jurisdiction_code,4,3)
     AND names.state_code = substr(cnty.jurisdiction_code,1,2)
     AND petv.tax_type_code = 'COUNTY'
     AND ctif.jurisdiction_code = cnty.jurisdiction_code
     AND ctif.county_tax = 'Y'
     AND ppa.effective_date between ctif.effective_start_date AND ctif.effective_end_date
     AND ppa.action_type in ('Q', 'R', 'V', 'I', 'B')
     AND nvl(ppa.date_earned, ppa.effective_date) between petv.effective_start_date AND petv.effective_end_date
     AND paa.assignment_id = p_assg_id
     AND assignment_action_id = p_asact_id
     AND tax_unit_id = p_tax_unit_id
     AND cnty.jurisdiction_code||'' = (substr(p_jurisdiction,1,3)||p_school)
     AND tax_type_code = 'SCHOOL'
   ORDER BY 2,3;

  /* Cursor created as per bug 3362423 */
  CURSOR c_local_dt12 IS
       SELECT DISTINCT
              NVL(ppa.date_earned,ppa.effective_date)effective_date,
              jurisdiction_code
     FROM pay_assignment_actions paa
      , pay_payroll_actions ppa
      , pay_us_asg_schools_v school
   WHERE paa.payroll_action_id = ppa.payroll_action_id
     AND school.assignment_id = paa.assignment_id
     AND school.tax_unit_id = paa.tax_unit_id
     AND ppa.action_type in ('Q', 'R', 'V', 'I', 'B')
     AND paa.assignment_id = p_assg_id
     AND assignment_action_id = p_asact_id
     AND paa.tax_unit_id = p_tax_unit_id
     AND jurisdiction_code||'' = (substr(p_jurisdiction,1,3)||p_school);

  /* Cursor for School EE Wages with tax_type_code = School. Modified as per bug 3362423. */
  CURSOR c_local12 (p_eff_date DATE, p_jurisdiction_code VARCHAR2) IS
   SELECT DISTINCT
       tax_type_code||' '
         ||decode(balance_category_code, 'SUBJECT',
    	    'Taxable', initcap(balance_category_code)) prompt
      , 1 ordercol1
      , decode (balance_category_code
         ,'TAXABLE' , 2
         ,'SUBJECT' , 3
         ,'WITHHELD' , 4
         , 6) ordercol2
      , tax_type_code
      , balance_category_code
      , p_jurisdiction_code jurisdiction_code
   FROM pay_us_local_ee_wage_types_v petv
   WHERE p_eff_date between petv.effective_start_date AND petv.effective_end_date
     AND petv.tax_type_code = 'SCHOOL'
   ORDER BY 2,3;
  ------- Local ee wages = school-----------

  l_bal_val number;
  l_cnt number := 1;
  l_procedure varchar2(30) := 'get_local';


  PROCEDURE get_local_balances (p_prompt		      in varchar2,
                              p_tax_type_code         in varchar2,
                              p_balance_category_code in varchar2,
                              p_jurisdiction_code     in varchar2
                             )
  IS
     l_procedure varchar2(30) := 'get_local_balances';
  BEGIN
	      hr_utility.set_location(l_package||l_procedure, 130);
	      p_local_taxes_tab(l_cnt).prompt := p_prompt;
	      l_bal_val := pay_us_taxbal_view_pkg.us_tax_balance_vm(
				p_tax_balance_category	=> p_balance_category_code,
				p_tax_type		=> p_tax_type_code,
				p_ee_or_er		=> p_ee_er,
				p_time_type		=> 'YTD',
				p_gre_id_context	=> p_tax_unit_id,
				p_jd_context		=> p_jurisdiction_code,
				p_assignment_action_id	=> p_asact_id ,
				p_assignment_id 	=> p_assg_id,
				p_virtual_date 		=> NULL,
				p_payroll_action_id     => NULL);
	     p_local_taxes_tab(l_cnt).ytd_val := l_bal_val;
	     hr_utility.set_location(l_package||l_procedure, 140);
	     hr_utility.trace('YTD value = '||l_bal_val);

	     l_bal_val := pay_us_taxbal_view_pkg.us_tax_balance_vm(
				p_tax_balance_category	=> p_balance_category_code,
				p_tax_type		=> p_tax_type_code,
				p_ee_or_er		=> p_ee_er,
				p_time_type		=> 'PTD',
				p_gre_id_context	=> p_tax_unit_id,
				p_jd_context		=> p_jurisdiction_code,
				p_assignment_action_id	=> p_asact_id ,
				p_assignment_id 	=> p_assg_id,
				p_virtual_date 		=> NULL,
				p_payroll_action_id     => NULL);
	     p_local_taxes_tab(l_cnt).ptd_val := l_bal_val;
	     hr_utility.set_location(l_package||l_procedure, 150);
	     hr_utility.trace('PTD value = '||l_bal_val);

	     l_bal_val := pay_us_taxbal_view_pkg.us_tax_balance_vm(
				p_tax_balance_category	=> p_balance_category_code,
				p_tax_type		=> p_tax_type_code,
				p_ee_or_er		=> p_ee_er,
				p_time_type		=> 'MONTH',
				p_gre_id_context	=> p_tax_unit_id,
				p_jd_context		=> p_jurisdiction_code,
				p_assignment_action_id	=> p_asact_id ,
				p_assignment_id 	=> p_assg_id,
				p_virtual_date 		=> NULL,
				p_payroll_action_id     => NULL);
	     p_local_taxes_tab(l_cnt).mtd_val := l_bal_val;
	     hr_utility.set_location(l_package||l_procedure, 160);
	     hr_utility.trace('MTD value = '||l_bal_val);

	     l_bal_val := pay_us_taxbal_view_pkg.us_tax_balance_vm(
				p_tax_balance_category	=> p_balance_category_code,
				p_tax_type		=> p_tax_type_code,
				p_ee_or_er		=> p_ee_er,
				p_time_type		=> 'QTD',
				p_gre_id_context	=> p_tax_unit_id,
				p_jd_context		=> p_jurisdiction_code,
				p_assignment_action_id	=> p_asact_id ,
				p_assignment_id 	=> p_assg_id,
				p_virtual_date 		=> NULL,
				p_payroll_action_id     => NULL);
	     p_local_taxes_tab(l_cnt).qtd_val := l_bal_val;
	     hr_utility.set_location(l_package||l_procedure, 170);
	     hr_utility.trace('QTD value = '||l_bal_val);

  EXCEPTION
	WHEN others THEN
	hr_utility.set_location(l_package||l_procedure,180);
	raise_application_error(-20101, 'Error in ' || l_package||l_procedure || ' - ' || sqlerrm);
  END get_local_balances;

  BEGIN
    hr_utility.set_location(l_package||l_procedure, 10);
    --hr_utility.trace_on(null,'tax_bal_summary');
    hr_utility.trace('opening cursor for city tax, tax_type_code <> SCHOOL');
    FOR localrec in c_local1 LOOP
        get_local_balances (
              p_prompt                => localrec.prompt,
              p_tax_type_code         => localrec.tax_type_code,
              p_balance_category_code => localrec.balance_category_code,
              p_jurisdiction_code     => localrec.jurisdiction_code);
              l_cnt := l_cnt + 1;
    END LOOP;

    hr_utility.set_location(l_package||l_procedure, 20);
    hr_utility.trace('opening cursor for county tax, tax_type_code <> SCHOOL');

    FOR local_dt_rec in c_local_dt2 LOOP
    FOR localrec in c_local2 (local_dt_rec.effective_date, local_dt_rec.jurisdiction_code) LOOP
        get_local_balances (
              p_prompt                => localrec.prompt,
              p_tax_type_code         => localrec.tax_type_code,
              p_balance_category_code => localrec.balance_category_code,
              p_jurisdiction_code     => localrec.jurisdiction_code);
              l_cnt := l_cnt + 1;
    END LOOP;
    END LOOP;

    hr_utility.set_location(l_package||l_procedure, 30);
    hr_utility.trace('opening cursor for school tax, tax_type_code <> SCHOOL');

    FOR local_dt_rec in c_local_dt3 LOOP
    FOR localrec in c_local3 (local_dt_rec.effective_date, local_dt_rec.jurisdiction_code) LOOP
        get_local_balances (
              p_prompt                => localrec.prompt,
              p_tax_type_code         => localrec.tax_type_code,
              p_balance_category_code => localrec.balance_category_code,
              p_jurisdiction_code     => localrec.jurisdiction_code);
              l_cnt := l_cnt + 1;
    END LOOP;
    END LOOP;

    hr_utility.set_location(l_package||l_procedure, 40);
    hr_utility.trace('opening cursor for city EE wages, tax_type_code <> SCHOOL');
    FOR localrec in c_local4 LOOP
        get_local_balances (
              p_prompt                => localrec.prompt,
              p_tax_type_code         => localrec.tax_type_code,
              p_balance_category_code => localrec.balance_category_code,
              p_jurisdiction_code     => localrec.jurisdiction_code);
              l_cnt := l_cnt + 1;
    END LOOP;

    hr_utility.set_location(l_package||l_procedure, 50);
    hr_utility.trace('opening cursor for county EE wages, tax_type_code <> SCHOOL');
    FOR localrec in c_local5 LOOP
        get_local_balances (
              p_prompt                => localrec.prompt,
              p_tax_type_code         => localrec.tax_type_code,
              p_balance_category_code => localrec.balance_category_code,
              p_jurisdiction_code     => localrec.jurisdiction_code);
              l_cnt := l_cnt + 1;
    END LOOP;

    hr_utility.set_location(l_package||l_procedure, 60);
    hr_utility.trace('opening cursor for school EE wages, tax_type_code <> SCHOOL');

    FOR local_dt_rec in c_local_dt6 LOOP
    FOR localrec in c_local6 (local_dt_rec.effective_date, local_dt_rec.jurisdiction_code) LOOP
        get_local_balances (
              p_prompt                => localrec.prompt,
              p_tax_type_code         => localrec.tax_type_code,
              p_balance_category_code => localrec.balance_category_code,
              p_jurisdiction_code     => localrec.jurisdiction_code);
              l_cnt := l_cnt + 1;
    END LOOP;
    END LOOP;

    hr_utility.set_location(l_package||l_procedure, 70);
    hr_utility.trace('opening cursor for city tax, tax_type_code = SCHOOL');
    FOR localrec in c_local7 LOOP
        get_local_balances (
              p_prompt                => localrec.prompt,
              p_tax_type_code         => localrec.tax_type_code,
              p_balance_category_code => localrec.balance_category_code,
              p_jurisdiction_code     => localrec.jurisdiction_code);
              l_cnt := l_cnt + 1;
    END LOOP;

    hr_utility.set_location(l_package||l_procedure, 80);
    hr_utility.trace('opening cursor for county tax, tax_type_code = SCHOOL');
    FOR local_dt_rec in c_local_dt8 LOOP
    FOR localrec in c_local8 (local_dt_rec.effective_date, local_dt_rec.jurisdiction_code) LOOP
        get_local_balances (
              p_prompt                => localrec.prompt,
              p_tax_type_code         => localrec.tax_type_code,
              p_balance_category_code => localrec.balance_category_code,
              p_jurisdiction_code     => localrec.jurisdiction_code);
              l_cnt := l_cnt + 1;
    END LOOP;
    END LOOP;

    hr_utility.set_location(l_package||l_procedure, 90);
    hr_utility.trace('opening cursor for school tax, tax_type_code = SCHOOL');
    FOR localrec in c_local9 LOOP
        get_local_balances (
              p_prompt                => localrec.prompt,
              p_tax_type_code         => localrec.tax_type_code,
              p_balance_category_code => localrec.balance_category_code,
              p_jurisdiction_code     => localrec.jurisdiction_code);
              l_cnt := l_cnt + 1;
    END LOOP;

    hr_utility.set_location(l_package||l_procedure, 100);
    hr_utility.trace('opening cursor for city EE wages, tax_type_code = SCHOOL');
    FOR localrec in c_local10 LOOP
        get_local_balances (
              p_prompt                => localrec.prompt,
              p_tax_type_code         => localrec.tax_type_code,
              p_balance_category_code => localrec.balance_category_code,
              p_jurisdiction_code     => localrec.jurisdiction_code);
              l_cnt := l_cnt + 1;
    END LOOP;

    hr_utility.set_location(l_package||l_procedure, 110);
    hr_utility.trace('opening cursor for county EE wages, tax_type_code = SCHOOL');
    FOR localrec in c_local11 LOOP
        get_local_balances (
              p_prompt                => localrec.prompt,
              p_tax_type_code         => localrec.tax_type_code,
              p_balance_category_code => localrec.balance_category_code,
              p_jurisdiction_code     => localrec.jurisdiction_code);
              l_cnt := l_cnt + 1;
    END LOOP;

    hr_utility.set_location(l_package||l_procedure, 120);
    hr_utility.trace('opening cursor for school EE wages, tax_type_code = SCHOOL');

    FOR local_dt_rec in c_local_dt12 LOOP
    FOR localrec in c_local12 (local_dt_rec.effective_date, local_dt_rec.jurisdiction_code) LOOP
        get_local_balances (
              p_prompt                => localrec.prompt,
              p_tax_type_code         => localrec.tax_type_code,
              p_balance_category_code => localrec.balance_category_code,
              p_jurisdiction_code     => localrec.jurisdiction_code);
              l_cnt := l_cnt + 1;
    END LOOP;
    END LOOP;

    hr_utility.trace('Normal completion of '||l_package||l_procedure);
  EXCEPTION
	WHEN others THEN
	hr_utility.set_location(l_package||l_procedure,190);
	hr_utility.trace('Abnormal completion of '||l_package||l_procedure);
	raise_application_error(-20101, 'Error in ' || l_package||l_procedure || ' - ' || sqlerrm);
  END get_local;

END pay_us_tax_bal_summary_pkg;

/
