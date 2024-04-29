--------------------------------------------------------
--  DDL for Package PAY_JP_ZENGIN_TAPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_ZENGIN_TAPE" AUTHID CURRENT_USER AS
/* $Header: pyjptpzn.pkh 120.0 2005/05/29 06:20:49 appldev noship $ */
/******************************************************************************

  Copyright (c) Oracle Corporation (UK) Ltd 1993.
  All Rights Reserved.

  PRODUCT
    Oracle*Payroll

  NAME


  DESCRIPTION
    Magnetic tape format procedure.

1.0 Overview

  A PL/SQL package will be written for each type of magnetic tape. The package
  will include all cursors and procedures required for the particular magnetic
  tape format. A stored procedure provides the top level of control flow for
  the magnetic tape file generation. This may call other procedures dependant
  on the state of the cursors and the input parameters.

  The stored procedure will be called before each execution of a
  formula. Parameters returned as results of the previous formula execution
  will be passed to the procedure. The procedure must handle all context
  cursors needed and may also set parameters required by the formula.

  Using NACHA as an example, for the file header record formula, a call
  to a cursor which fetches legal_company_id must be performed.

  The interface between the 'C' process and the stored procedure will make
  extensive use of PL/SQL tables. PL/SQL tables are single column tables which
  are accessed by an integer index value. Items in the tables will use indexes
  begining with 1 and increasing contiguously to the number of elements. The
  index number will be used to match items in the name and value tables.

  The first element in the value tables will always be the number of elements
  available in the table. The elements in the tables will be of type VARCHAR2
  any conversion necessary should be performed within the PL/SQL procedure.

  The parameters returned by formula execution will be passed
  to the stored procedure. Parameters may or may not be altered by the PL/SQL
  procedure and will be passed back to the formula for the next execution.
  Context tables will always be reset by the PL/SQL procedure.

  The names of the tables used to interface with the PL/SQL procedure are
       param_names     type IN/OUT
       param_values    type IN/OUT
       context_names   type OUT
       context_values  type OUT

  The second item in the output_parameter_value table will be the formula ID
  of the next formula to be executed (the first item is the number of values
  in the table).

    Change List
    -----------
        Date       Name                 Description
        ----------+--------------------+---------------------------------------
        1996/12/01 Tohru Tagawa         Created.
        1997/01/09 Tohru Tagawa         Added group_by expression to the cursor
                                        'zengin_ee_payment'
	1997/07/28 Toru Tagawa		Changed name column to use per_information18
					and per_information19 not last_name,first_name.
					Added nvl function.
	1997/07/30 Toru Tagawa		Fixed bug that bank_pay_dest_account cursor
                                        fails with ORA-00979: not GROUP BY expression.
	1998/07/30 Toru Tagawa		Changed all the cursor for performance tuning.
					Payment Formulas are also modified.
					Alter package clause is added in the end to avoid bug
					caused by Oracle when calling pay_magtape_generic.
        1999/07/19 Toshihide Nanjyo     Add a semicolon to the exit statement.
        2000/02/14 Toru Tagawa          Entity change by Bug.1077383 is applied.
        2002/06/12 Toru Tagawa          All procedures and functions commented out.
Package header:
******************************************************************************/
--
-- Header cursor
-- ORG_PAYMENT_METHOD_ID is mandatory in Japan.
-- So ORG_PAYMENT_METHOD_ID is unique per PAYROLL_ACTION_ID on Magtape process.
CURSOR csr_source_bank IS
	select	'P_REQUEST_ID=P',		to_char(ppa.request_id),
		'P_START_DATE=P',		to_char(ppa.start_date,'DD-MON-YYYY'),
		'P_EFFECTIVE_DATE=P',		to_char(ppa.effective_date,'DD-MON-YYYY'),
		'P_DEPOSIT_DATE=P',		to_char(ppa.overriding_dd_date,'DD-MON-YYYY'),
		'P_CLIENT_CODE=P',		opm.pmeth_information1,
		'P_CLIENT_NAME_KANA=P',		opm.pmeth_information2,
		'P_SOURCE_BANK_CODE=P',		bnk.bank_code,
		'P_SOURCE_BANK_NAME=P',		bnk.bank_name,
		'P_SOURCE_BANK_NAME_KANA=P',	bnk.bank_name_kana,
		'P_SOURCE_BRANCH_CODE=P',	bch.branch_code,
		'P_SOURCE_BRANCH_NAME=P',	bch.branch_name,
		'P_SOURCE_BRANCH_NAME_KANA=P',	bch.branch_name_kana,
		'P_SOURCE_ACCOUNT_TYPE=P',	pea.segment7,
		'P_SOURCE_ACCOUNT_NUMBER=P',	pea.segment8,
		'P_SOURCE_ACCOUNT_NAME_KANA=P',	pea.segment9
	from	pay_jp_bank_branches		bch,
		pay_jp_banks			bnk,
		pay_external_accounts		pea,
		pay_org_payment_methods_f	opm,
		pay_payroll_actions		ppa
	where	ppa.payroll_action_id = to_number(pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID'))
	and	opm.org_payment_method_id = ppa.org_payment_method_id
	and	ppa.effective_date
		between opm.effective_start_date and opm.effective_end_date
	and	pea.external_account_id = opm.external_account_id
	and	bnk.bank_code = pea.segment1
	and	bch.bank_code = bnk.bank_code
	and	bch.branch_code = pea.segment4;
--
-- Destination Bank cursor
--
CURSOR csr_dest_bank IS
	select	'P_DEST_BANK_CODE=P',		bnk.bank_code,
		'P_DEST_BANK_NAME=P',		bnk.bank_name,
		'P_DEST_BANK_NAME_KANA=P',	bnk.bank_name_kana
	from	pay_jp_banks			bnk,
		pay_external_accounts		pea,
		pay_personal_payment_methods_f	ppm,
		pay_payroll_actions		ppa2,	-- Prepay pact
		pay_assignment_actions		paa2,	-- Prepay assact
		pay_pre_payments		ppp,
		pay_assignment_actions		paa	-- Magtape assact
	where	paa.payroll_action_id = to_number(pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID'))
	and	ppp.pre_payment_id = paa.pre_payment_id
	and	paa2.assignment_action_id = ppp.assignment_action_id
	and	ppa2.payroll_action_id = paa2.payroll_action_id
	and	ppm.personal_payment_method_id = ppp.personal_payment_method_id
	and	ppa2.effective_date
		between ppm.effective_start_date and ppm.effective_end_date
	and	pea.external_account_id = ppm.external_account_id
	and	bnk.bank_code = pea.segment1
	group by
		bnk.bank_code,
		bnk.bank_name,
		bnk.bank_name_kana
	order by 2;
--
-- Payment Cursor
--
CURSOR csr_payment IS
	select	'P_DEST_BRANCH_CODE=P',		bch.branch_code,
		'P_DEST_BRANCH_NAME=P',		bch.branch_name,
		'P_DEST_BRANCH_NAME_KANA=P',	bch.branch_name_kana,
		'P_DEST_ACCOUNT_TYPE=P',	pea.segment7,
		'P_DEST_ACCOUNT_NUMBER=P',	pea.segment8,
		'P_DEST_ACCOUNT_NAME_KANA=P',	pea.segment9,
		'P_EMPLOYEE_NUMBER=P',		min(pp.employee_number)	EMPLOYEE_NUMBER,
		'P_FULL_NAME=P',		min(rpad(pp.per_information18 || ' ' || pp.per_information19,20,' ')),
		'P_PAYMENT=P',			to_char(sum(ppp.value))
	from	per_all_people_f		pp,
		per_all_assignments_f		pa,
		pay_jp_bank_branches		bch,
		pay_external_accounts		pea,
		pay_personal_payment_methods_f	ppm,
		pay_payroll_actions		ppa2,	-- Prepay pact
		pay_assignment_actions		paa2,	-- Prepay assact
		pay_pre_payments		ppp,
		pay_assignment_actions		paa	-- Magtape assact
	where	paa.payroll_action_id = to_number(pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID'))
	and	ppp.pre_payment_id = paa.pre_payment_id
	and	paa2.assignment_action_id = ppp.assignment_action_id
	and	ppa2.payroll_action_id = paa2.payroll_action_id
	and	ppm.personal_payment_method_id = ppp.personal_payment_method_id
	and	ppa2.effective_date
		between ppm.effective_start_date and ppm.effective_end_date
	and	pea.external_account_id = ppm.external_account_id
	and	pea.segment1 = pay_magtape_generic.get_parameter_value('P_DEST_BANK_CODE')
	and	bch.bank_code = pea.segment1
	and	bch.branch_code = pea.segment4
	and	pa.assignment_id = paa.assignment_id
	and	ppa2.effective_date
		between pa.effective_start_date and pa.effective_end_date
	and	pp.person_id=pa.person_id
	and	ppa2.effective_date
		between pp.effective_start_date and pp.effective_end_date
	group by
		bch.branch_code,
		bch.branch_name,
		bch.branch_name_kana,
		pea.segment7,
		pea.segment8,
		pea.segment9,
		pa.person_id
	order by 2,lpad(EMPLOYEE_NUMBER,30,' ');
--
    level_cnt number;
--
/*
    PROCEDURE new_formula;
--
    FUNCTION get_process_date(p_assignment_action_id in number,
                              p_entry_date           in date)
    return date;
    FUNCTION validate_process_date(p_assignment_action_id in number,
                                   p_process_date           in date)
    return date;
*/
END pay_jp_zengin_tape;

 

/
