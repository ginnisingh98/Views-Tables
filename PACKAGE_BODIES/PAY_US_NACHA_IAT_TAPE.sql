--------------------------------------------------------
--  DDL for Package Body PAY_US_NACHA_IAT_TAPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_NACHA_IAT_TAPE" as
/* $Header: pytapnaciat.pkb 120.0.12010000.3 2010/03/31 12:20:37 mikarthi noship $ */
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

    Name        : pay_us_nacha_iat_tape

    Description : This package holds building blocks used in the generation
                  of nacha IAT Tape.

    Uses        : hr_utility

    Change List
    -----------
    Date        Name          Vers    Bug No     Description
    ----        ----          ----    ------     ------------------------------
    AUG-17-2009 MIKARTHI      115.0              Initial Version
    JAN-20-2010 MIKARTHI      115.1   9275642    Modified cursor c_emp_details.
    MAR-31-2010 MIKARTHI      115.2   9413224    Modified cursor c_emp_details.
                                                 New Cursor c_emp_details_override


  */


-------------------------- get_addr_delim -------------------------------------

  FUNCTION get_addr_delim (p_addr_detail VARCHAR2)
	RETURN VARCHAR2 IS
	BEGIN
  			IF p_addr_detail IS NULL THEN
  					RETURN NULL;
  			ELSE
  					RETURN '*';
  			END IF;

  	END;

-------------------------- run_formula -------------------------------------

  PROCEDURE run_formula (p_business_group_id NUMBER,
                         p_effective_date DATE,
                         p_direct_dep_date VARCHAR2,
                         p_org_payment_method_id NUMBER,
                         p_csr_org_pay_third_party VARCHAR2,
                         p_file_id_modifier VARCHAR2,
                         p_test_file VARCHAR2,
                         p_payroll_id NUMBER) IS

  v_prepayment_id NUMBER := NULL;
  v_amount NUMBER := NULL;
  v_block_count NUMBER := NULL;
  n_person_id NUMBER;



      --Address sorted on Address type so that if IAT address is present, precedence is given for that.
      --Bug 9275642. Removed check for Address Type in case Primary Address is being picked.
      --             Also ordering such that Nulls will be returned first so that if IAT address is present then it is given precedence
      --             over the Primary address
      --Bug 9413224. Passing the override date, rather than the end date
      cursor c_emp_details_override  (l_direct_dep_date date )is
            (SELECT full_name         ,
                   paa.organization_id,
                   pap.person_id      ,
                   pap.employee_number,
                   pav.ADDRESS_LINE1,
                   pav.TOWN_OR_CITY ,
                   pav.REGION_2     ,
                   pav.REGION_1     ,
                   pav.D_COUNTRY    ,
                   pav.POSTAL_CODE
            FROM   per_all_assignments_f paa,
                   per_all_people_f pap,
				   PER_ADDRESSES_V pav
            WHERE  paa.person_id     = pap.person_id
               AND paa.assignment_id = g_assignment_id
			   and l_direct_dep_date BETWEEN paa.EFFECTIVE_START_DATE AND NVL(paa.EFFECTIVE_END_DATE,l_direct_dep_date)
										and pav.person_id = pap.person_id
               and l_direct_dep_date BETWEEN pap.EFFECTIVE_START_DATE AND NVL(pap.EFFECTIVE_END_DATE,l_direct_dep_date)
               AND (pav.ADDRESS_TYPE = 'IAT'
                    or (pav.primary_flag = 'Y' ))
               and l_direct_dep_date BETWEEN pav.date_from and NVL(pav.date_to,l_direct_dep_date))
               order by decode(pav.address_type, 'IAT',1,2);

    --Bug 9413224. Fetching Date Paid from the pay_payroll_actions table corresponding
    --             each pre-payment run, which is then used to fetch date tracked
    --             address details and employee number changes.
    cursor c_emp_details  (l_prepayment_id number )is
            (SELECT full_name          ,
                   paaf.organization_id,
                   pap.person_id      ,
                   pap.employee_number,
                   pav.ADDRESS_LINE1,
                   pav.TOWN_OR_CITY ,
                   pav.REGION_2     ,
                   pav.REGION_1     ,
                   pav.D_COUNTRY    ,
                   pav.POSTAL_CODE
            FROM   per_all_assignments_f paaf,
                   per_all_people_f pap,
                   pay_pre_payments           ppp,
                   pay_action_interlocks      pai,
                   pay_payroll_actions        ppa,
                   pay_assignment_actions     paa,
				   PER_ADDRESSES_V pav
            WHERE  paaf.person_id     = pap.person_id
               AND paaf.assignment_id = g_assignment_id
               and ppp.pre_payment_id = l_prepayment_id
               and ppp.assignment_action_id = pai.locking_action_id
               and pai.locked_action_id = paa.assignment_action_id
               and ppa.payroll_action_id = paa.payroll_action_id
               and ppa.action_type in ('R', 'Q')
               and ((paa.source_action_id is not null and ppa.run_type_id is not null) or
                  (paa.source_action_id is null and ppa.run_type_id is null))
			   and ppa.effective_date BETWEEN paaf.EFFECTIVE_START_DATE AND NVL(paaf.EFFECTIVE_END_DATE,ppa.effective_date)
			   and pav.person_id = pap.person_id
               and ppa.effective_date BETWEEN pap.EFFECTIVE_START_DATE AND NVL(pap.EFFECTIVE_END_DATE,ppa.effective_date)
               AND (pav.ADDRESS_TYPE = 'IAT'
                    or (pav.primary_flag = 'Y'))
               and ppa.effective_date BETWEEN pav.date_from and NVL(pav.date_to,ppa.effective_date))
               order by decode(pav.address_type, 'IAT',1,2);

    /* ***************************************************************
     NAME
       get_formula_id
     DESCRIPTION
       Gets Formula Id
     NOTES
       Local function.
   *********************************************************************/


  FUNCTION get_formula_id (p_formula_name VARCHAR2)
  RETURN VARCHAR2 IS
  ff_formula_id VARCHAR2(9);
  BEGIN
    hr_utility.set_location('pay_us_nacha_tape.get_formula_id', 1);
--
    SELECT TO_CHAR(FORMULA_ID) INTO ff_formula_id
    FROM   FF_FORMULAS_F
    WHERE  p_effective_date BETWEEN EFFECTIVE_START_DATE AND
                                    EFFECTIVE_END_DATE
    AND    FORMULA_NAME = p_formula_name;
--
    hr_utility.TRACE('Formula ID : '|| ff_formula_id);
    RETURN ff_formula_id;
  EXCEPTION
    WHEN no_data_found THEN
      hr_utility.set_message(801, 'FFX37_FORMULA_NOT_FOUND');
      hr_utility.set_message_token('1', p_formula_name);
      hr_utility.raise_error;
  END get_formula_id;


/* ***************************************************************
     NAME
       get_transfer_param
     DESCRIPTION
       Gets value for the named parameter
     NOTES
       Local function.
   *********************************************************************/

  FUNCTION get_transfer_param (p_param_name VARCHAR2 )
  RETURN NUMBER IS
  param_value NUMBER;
  BEGIN
    hr_utility.set_location('pay_us_nacha_tape.get_effective_date', 20);
    IF pay_mag_tape.internal_prm_names(3) = p_param_name
      THEN
      param_value := fnd_number.canonical_to_number(pay_mag_tape.internal_prm_values(3));
    ELSIF pay_mag_tape.internal_prm_names(4) = p_param_name
      THEN
      param_value := fnd_number.canonical_to_number(pay_mag_tape.internal_prm_values(4));
    ELSIF pay_mag_tape.internal_prm_names(5) = p_param_name
      THEN
      param_value := fnd_number.canonical_to_number(pay_mag_tape.internal_prm_values(5));
    ELSIF pay_mag_tape.internal_prm_names(6) = p_param_name
      THEN
      param_value := fnd_number.canonical_to_number(pay_mag_tape.internal_prm_values(6));
    ELSIF pay_mag_tape.internal_prm_names(7) = p_param_name
      THEN
      param_value := fnd_number.canonical_to_number(pay_mag_tape.internal_prm_values(7));
    ELSIF pay_mag_tape.internal_prm_names(8) = p_param_name
      THEN
      param_value := fnd_number.canonical_to_number(pay_mag_tape.internal_prm_values(8));
    END IF;
    RETURN param_value;
  END get_transfer_param;

--==============================

  --Writing File  Header
  PROCEDURE write_file_header IS

  BEGIN

    hr_utility.TRACE('Writing File Header');
    hr_utility.TRACE('.... Writing File Header Context');

    pay_mag_tape.internal_cxt_values(1) := '3';
    pay_mag_tape.internal_cxt_names(2) := 'ORG_PAY_METHOD_ID';
    pay_mag_tape.internal_cxt_values(2) := g_org_payment_method_id;
    pay_mag_tape.internal_cxt_names(3) := 'DATE_EARNED';
    pay_mag_tape.internal_cxt_values(3) := fnd_date.date_to_canonical(p_effective_date);
--
    hr_utility.TRACE('.... Writing File Header Parameters');
    hr_utility.TRACE('g_file_header ' || g_file_header);

    pay_mag_tape.internal_prm_values(1) := '5';
    pay_mag_tape.internal_prm_values(2) := g_file_header;
    pay_mag_tape.internal_prm_names(3) := 'FILE_ID_MODIFIER';
    pay_mag_tape.internal_prm_values(3) := p_file_id_modifier;
    pay_mag_tape.internal_prm_names(4) := 'CREATION_DATE';
    pay_mag_tape.internal_prm_values(4) := g_date;
    pay_mag_tape.internal_prm_names(5) := 'CREATION_TIME';
    pay_mag_tape.internal_prm_values(5) := g_time;

    hr_utility.TRACE('Leaving File Header');

    hr_utility.set_location('run_formula.File_head', 6);

  END; /* end write_file_header */

--==================================================

--Write Batch Header
  PROCEDURE write_batch_header
  IS

  BEGIN
    hr_utility.TRACE('Writing IAT Batch Header');

    g_overflow_batch := 'N';
    hr_utility.TRACE('....IAT g_overflow_batch is : '|| g_overflow_batch);

--Two different cursors are used based on the oracle db version for performance improvement
    IF (nvl(hr_general2.get_oracle_db_version, 0) < 10.0) THEN
      OPEN csr_assignments (g_legal_company_id,
                            g_payroll_action_id,
                            g_csr_org_pay_meth_id,
                            g_rowid );
    ELSE
      OPEN csr_assignments_no_rule (g_legal_company_id,
                                    g_payroll_action_id,
                                    g_csr_org_pay_meth_id,
                                    g_rowid );
    END IF;

    g_temp_count := 0;
    g_batch_number := g_batch_number + 1;

   -- Context for NACHA_BATCH_HEADER
   -- first context is number of contexts
    hr_utility.TRACE('.... Writing IAT Batch Header Context');

    pay_mag_tape.internal_cxt_values(1) := '4';
    pay_mag_tape.internal_cxt_names(2) := 'TAX_UNIT_ID';
    pay_mag_tape.internal_cxt_values(2) := TO_CHAR(g_legal_company_id);
    pay_mag_tape.internal_cxt_names(3) := 'DATE_EARNED';
    pay_mag_tape.internal_cxt_values(3) := fnd_date.date_to_canonical(p_effective_date);
    pay_mag_tape.internal_cxt_names(4) := 'ORG_PAY_METHOD_ID';
    pay_mag_tape.internal_cxt_values(4) := g_org_payment_method_id;

   -- Parameters for NACHA_BATCH_HEADER
   -- first parameter is number of parameters
   -- second parameter is formula is
    hr_utility.TRACE('.... Writing Batch Header Parameters');

    pay_mag_tape.internal_prm_values(1) := '6';
    pay_mag_tape.internal_prm_values(2) := g_batch_header;

    pay_mag_tape.internal_prm_names(3) := 'COMPANY_ENTRY_DESCRIPTION';
    pay_mag_tape.internal_prm_values(3) := g_company_entry_desc;

    pay_mag_tape.internal_prm_names(4) := 'EFFECTIVE_ENTRY_DATE';
    pay_mag_tape.internal_prm_values(4) := nvl(p_direct_dep_date,
                                               TO_CHAR(p_effective_date, 'YYMMDD'));
    pay_mag_tape.internal_prm_names(5) := 'BATCH_NUMBER';
    pay_mag_tape.internal_prm_values(5) := TO_CHAR(g_batch_number);

    pay_mag_tape.internal_prm_names(6) := 'FORMAT_TYPE';
    pay_mag_tape.internal_prm_values(6) := 'IAT';



    hr_utility.TRACE('Leaving Batch Header');

  END; /* write_batch_header */

--=========================================

/******************************************************************
   NAME
       write_entry_detail
   DESCRIPTION
       Writes the Entry Detail Record .
   NOTES
       Local function.
********************************************************************/


  PROCEDURE write_entry_detail IS

  BEGIN

    hr_utility.TRACE('Writing Entry Detail');

    hr_utility.TRACE('.... Writing Entry Detail Context');
    g_count := g_count + 1;


    hr_utility.TRACE('Entry Detail : g_hash ' || g_hash);
--

   -- Context Setup for NACHA_ENTRY_DETAIL
   -- First context value is number of contexts
    pay_mag_tape.internal_cxt_values(1) := '4';
    pay_mag_tape.internal_cxt_names(2) := 'DATE_EARNED';
    pay_mag_tape.internal_cxt_values(2) := fnd_date.date_to_canonical(p_effective_date);
    pay_mag_tape.internal_cxt_names(3) := 'PER_PAY_METHOD_ID';
    pay_mag_tape.internal_cxt_values(3) := to_char(g_personal_payment_method_id);
    pay_mag_tape.internal_cxt_names(4) := 'ORG_PAY_METHOD_ID';
    pay_mag_tape.internal_cxt_values(4) := g_org_payment_method_id;


   -- Parameter Setup for NACHA_ENTRY_DETAIL
   -- First parameter value is number of parameters
   -- second parameter value is formula id

    hr_utility.TRACE('.... Writing Entry Detail Parameters');

    pay_mag_tape.internal_prm_values(1) := '8';
    pay_mag_tape.internal_prm_values(2) := g_entry_detail;

    IF g_temp_count = 0 THEN
      -- If this is the first entry detail of a batch, reset these
      -- parameters.
      pay_mag_tape.internal_prm_names(3) := 'TRANSFER_ENTRY_COUNT';
      pay_mag_tape.internal_prm_values(3) := '0';
      pay_mag_tape.internal_prm_names(4) := 'TRANSFER_ENTRY_HASH';
      pay_mag_tape.internal_prm_values(4) := '0';
      pay_mag_tape.internal_prm_names(5) := 'TRANSFER_CREDIT_AMOUNT';
      pay_mag_tape.internal_prm_values(5) := '0';
/*      pay_mag_tape.internal_prm_names(7) := 'TRANSFER_ORG_PAY_TOT';
      pay_mag_tape.internal_prm_values(7) := '0';*/


      g_temp_count := 1;
      hr_utility.set_location('run_formula.Assignment', 8);

    END IF;

   -- Parameters 3-5 are transferred from previous formula
   -- 3 - TRANSFER_ENTRY_COUNT
   -- 4 - TRANSFER_ENTRY_HASH
   -- 5 - TRANSFER_CREDIT_AMOUNT
    pay_mag_tape.internal_prm_names(6) := 'TRANSFER_PAY_VALUE';
    pay_mag_tape.internal_prm_values(6) := fnd_number.number_to_canonical(v_amount);

    pay_mag_tape.internal_prm_names(7) := 'TRACE_SEQUENCE_NUMBER';
    pay_mag_tape.internal_prm_values(7) := TO_CHAR(g_count);

    pay_mag_tape.internal_prm_names(8) := 'TEST_FILE';
    pay_mag_tape.internal_prm_values(8) := p_test_file;

    hr_utility.set_location('run_formula.Assignment', 7);



    g_addenda_write := 'Y';


   -- Update PRENOTE Date
    IF v_amount = 0 THEN
      UPDATE PAY_EXTERNAL_ACCOUNTS a
      SET    a.PRENOTE_DATE = nvl(to_date(p_direct_dep_date, 'YYMMDD'),
                                  p_effective_date)
      WHERE  a.PRENOTE_DATE IS NULL
      AND    a.EXTERNAL_ACCOUNT_ID =
                  (SELECT b.EXTERNAL_ACCOUNT_ID
                   FROM   PAY_PERSONAL_PAYMENT_METHODS_F b
                   WHERE  b.PERSONAL_PAYMENT_METHOD_ID =
                   g_personal_payment_method_id
                   AND    p_effective_date BETWEEN b.EFFECTIVE_START_DATE
                   AND b.EFFECTIVE_END_DATE);
    END IF;

    hr_utility.TRACE('Entry Detail : TRANSFER_ENTRY_HASH ' || get_transfer_param ('TRANSFER_ENTRY_HASH'));

    hr_utility.TRACE('Leaving Entry Detail');

  END; /* write_entry_detail */

 /******************************************************************
   NAME
       write_org_entry_detail
   DESCRIPTION
       Writes the Org Entry Detail Record .
   NOTES
       Local function.
********************************************************************/

  PROCEDURE write_org_entry_detail IS

  BEGIN

    hr_utility.TRACE('Writing Org Entry Detail');

    IF g_nacha_balance_flag = 'Y' THEN
      g_count := g_count + 1;
      g_addenda_write := 'Y';
			g_org_addenda := 'Y';
    END IF;

    g_batch_control_write := 'Y';

    IF g_overflow_flag = 'Y' THEN
      g_overflow_flag := 'N';
      g_overflow_batch := 'Y';
    END IF;

   -- Context Setup for NACHA_ORG_PAY_ENTRY_DETAIL
   -- first context is number of context values
    hr_utility.TRACE('.... Writing Org Entry Detail Context');

    pay_mag_tape.internal_cxt_values(1) := '3';
    pay_mag_tape.internal_cxt_names(2) := 'ORG_PAY_METHOD_ID';
    pay_mag_tape.internal_cxt_values(2) := g_csr_org_pay_meth_id;
    pay_mag_tape.internal_cxt_names(3) := 'DATE_EARNED';
    pay_mag_tape.internal_cxt_values(3) := fnd_date.date_to_canonical(p_effective_date);

  -- Parameter Setup for NACHA_ORG_PAY_ENTRY_DETAIL
  -- first parameter is number of parameters
  -- second parameter is formula id
    hr_utility.TRACE('.... Writing Org Entry Detail Parameters');

    pay_mag_tape.internal_prm_values(1) := '8';
    pay_mag_tape.internal_prm_values(2) := g_org_pay_entry_detail;

  -- Parameters 3-6 are transferred from previous formula
  -- 3 - TRANSFER_ENTRY_COUNT
  -- 4 - TRANSFER_ENTRY_HASH
  -- 5 - TRANSFER_CREDIT_AMOUNT

    pay_mag_tape.internal_prm_names(6) := 'TRANSFER_PAY_VALUE';
    pay_mag_tape.internal_prm_values(6) := get_transfer_param ('TRANSFER_CREDIT_AMOUNT');

    pay_mag_tape.internal_prm_names(7) := 'TRACE_SEQUENCE_NUMBER';
    pay_mag_tape.internal_prm_values(7) := TO_CHAR(g_count);

    pay_mag_tape.internal_prm_names(8) := 'TEST_FILE';
    pay_mag_tape.internal_prm_values(8) := p_test_file;


--Closing the cursor which was opened based on db version
    IF (nvl(hr_general2.get_oracle_db_version, 0) < 10.0) THEN
      CLOSE csr_assignments;
    ELSE
      CLOSE csr_assignments_no_rule;
    END IF;
    hr_utility.set_location('run_formula.org_pay_entry_detail', 9);

    hr_utility.TRACE('Leaving Org Entry Detail');

  END; /* write_org_entry_detail */


/******************************************************************
   NAME
       write_addenda
   DESCRIPTION
       Writes the Addenda Record .
   NOTES
       Local function.
********************************************************************/


  PROCEDURE write_addenda IS

  BEGIN

    hr_utility.TRACE('Writing IAT Addenda');

    g_addenda_num := g_addenda_num - 1;

    IF g_addenda_num = 0 THEN
      g_addenda_write := 'N';
    END IF;

    hr_utility.TRACE('g_addenda_num ' || g_addenda_num);

    IF g_addenda_num = 6 THEN

      hr_utility.TRACE('First Addenda');

      pay_mag_tape.internal_cxt_values(1) := '3';

      pay_mag_tape.internal_cxt_names(2) := 'DATE_EARNED';
      pay_mag_tape.internal_cxt_values(2) := fnd_date.date_to_canonical(p_effective_date);

      pay_mag_tape.internal_cxt_names(3) := 'PAYROLL_ID';
      pay_mag_tape.internal_cxt_values(3) := g_payroll_id;

      g_addenda := get_formula_id('NACHA_IAT_ADDENDA1');
      pay_mag_tape.internal_prm_values(1) := '11';
      pay_mag_tape.internal_prm_values(2) := g_addenda;

     -- Parameters 3-6 are transferred from previous formula
      -- 3 - TRANSFER_ENTRY_COUNT
      -- 4 - TRANSFER_ENTRY_HASH
      -- 5 - TRANSFER_CREDIT_AMOUNT

      pay_mag_tape.internal_prm_names(7) := 'ADDENDA_NUMBER';
      pay_mag_tape.internal_prm_values(7) := to_char(7 - g_addenda_num);

      pay_mag_tape.internal_prm_names(8) := 'TRACE_SEQUENCE_NUMBER';
      pay_mag_tape.internal_prm_values(8) := to_char(g_count);

      pay_mag_tape.internal_prm_names(9) := 'TEST_FILE';
      pay_mag_tape.internal_prm_values(9) := p_test_file;

      pay_mag_tape.internal_prm_names(10) := 'FULL_NAME';
      IF g_org_addenda = 'N' THEN
        pay_mag_tape.internal_prm_values(10) := g_full_name;
      ELSE
        pay_mag_tape.internal_prm_values(10) := g_org_name;
      END IF;

      pay_mag_tape.internal_prm_names(11) := 'ORG_ADDENDA';
      pay_mag_tape.internal_prm_values(11) := g_org_addenda;

    ELSIF g_addenda_num = 5 THEN

      hr_utility.TRACE('Second Addenda');

      g_addenda := get_formula_id('NACHA_IAT_ADDENDA2');
      pay_mag_tape.internal_prm_values(1) := '9';
      pay_mag_tape.internal_prm_values(2) := g_addenda;


     -- Parameters 3-6 are transferred from previous formula
      -- 3 - TRANSFER_ENTRY_COUNT
      -- 4 - TRANSFER_ENTRY_HASH
      -- 5 - TRANSFER_CREDIT_AMOUNT

      pay_mag_tape.internal_prm_names(6) := 'ADDENDA_NUMBER';
      pay_mag_tape.internal_prm_values(6) := to_char(7 - g_addenda_num);
      pay_mag_tape.internal_prm_names(7) := 'TRACE_SEQUENCE_NUMBER';
      pay_mag_tape.internal_prm_values(7) := to_char(g_count);
      pay_mag_tape.internal_prm_names(8) := 'ORG_NAME';
      pay_mag_tape.internal_prm_values(8) := g_org_name;
      pay_mag_tape.internal_prm_names(9) := 'ORG_STREET';
      pay_mag_tape.internal_prm_values(9) := g_street_address;

    ELSIF g_addenda_num = 4 THEN

      hr_utility.TRACE('Third Addenda');

      g_addenda := get_formula_id('NACHA_IAT_ADDENDA3');
      pay_mag_tape.internal_prm_values(1) := '9';
      pay_mag_tape.internal_prm_values(2) := g_addenda;

     -- Parameters 3-6 are transferred from previous formula
      -- 3 - TRANSFER_ENTRY_COUNT
      -- 4 - TRANSFER_ENTRY_HASH
      -- 5 - TRANSFER_CREDIT_AMOUNT
      -- 6 - TRANSFER_PAY_VALUE
      -- 7 - TRANSFER_ORG_PAY_TOT

      pay_mag_tape.internal_prm_names(6) := 'ADDENDA_NUMBER';
      pay_mag_tape.internal_prm_values(6) := to_char(7 - g_addenda_num);

      pay_mag_tape.internal_prm_names(7) := 'TRACE_SEQUENCE_NUMBER';
      pay_mag_tape.internal_prm_values(7) := to_char(g_count);

      pay_mag_tape.internal_prm_names(8) := 'ORG_CITY_STATE';
      pay_mag_tape.internal_prm_values(8) := g_city || get_addr_delim(g_state) || g_state || '\';

      pay_mag_tape.internal_prm_names(9) := 'ORG_COUNTRY_POSTAL';
      pay_mag_tape.internal_prm_values(9) := g_country || get_addr_delim(g_postal_code) || g_postal_code || '\';

    ELSIF g_addenda_num = 3 THEN

      hr_utility.TRACE('Fourth Addenda');

      pay_mag_tape.internal_cxt_values(1) := '3';

      pay_mag_tape.internal_cxt_names(2) := 'DATE_EARNED';
      pay_mag_tape.internal_cxt_values(2) := fnd_date.date_to_canonical(p_effective_date);

      pay_mag_tape.internal_cxt_names(3) := 'ORG_PAY_METHOD_ID';
      pay_mag_tape.internal_cxt_values(3) := g_org_payment_method_id;

      hr_utility.TRACE('Fourth Addenda');
      g_addenda := get_formula_id('NACHA_IAT_ADDENDA4');
      pay_mag_tape.internal_prm_values(1) := '7';
      pay_mag_tape.internal_prm_values(2) := g_addenda;

     -- Parameters 3-6 are transferred from previous formula
      -- 3 - TRANSFER_ENTRY_COUNT
      -- 4 - TRANSFER_ENTRY_HASH
      -- 5 - TRANSFER_CREDIT_AMOUNT


      pay_mag_tape.internal_prm_names(6) := 'ADDENDA_NUMBER';
      pay_mag_tape.internal_prm_values(6) := to_char(7 - g_addenda_num);

      pay_mag_tape.internal_prm_names(7) := 'TRACE_SEQUENCE_NUMBER';
      pay_mag_tape.internal_prm_values(7) := to_char(g_count);

    ELSIF g_addenda_num = 2 THEN

      hr_utility.TRACE('Fifth Addenda');

      g_addenda := get_formula_id('NACHA_IAT_ADDENDA5');

	  pay_mag_tape.internal_cxt_values(1) := '4';

      pay_mag_tape.internal_cxt_names(2) := 'DATE_EARNED';
      pay_mag_tape.internal_cxt_values(2) := fnd_date.date_to_canonical(p_effective_date);

      pay_mag_tape.internal_cxt_names(3)   := 'PER_PAY_METHOD_ID';
      pay_mag_tape.internal_cxt_values(3)  := to_char(g_personal_payment_method_id);

	  pay_mag_tape.internal_cxt_names(4) := 'ORG_PAY_METHOD_ID';
	  pay_mag_tape.internal_cxt_values(4) := g_org_payment_method_id;

      pay_mag_tape.internal_prm_values(1) := '8';
      pay_mag_tape.internal_prm_values(2) := g_addenda;

     -- Parameters 3-6 are transferred from previous formula
      -- 3 - TRANSFER_ENTRY_COUNT
      -- 4 - TRANSFER_ENTRY_HASH
      -- 5 - TRANSFER_CREDIT_AMOUNT


      pay_mag_tape.internal_prm_names(6) := 'ADDENDA_NUMBER';
      pay_mag_tape.internal_prm_values(6) := to_char(7 - g_addenda_num);

      pay_mag_tape.internal_prm_names(7) := 'TRACE_SEQUENCE_NUMBER';
      pay_mag_tape.internal_prm_values(7) := to_char(g_count);

      pay_mag_tape.internal_prm_names(8) := 'ORG_ADDENDA';
      pay_mag_tape.internal_prm_values(8) := g_org_addenda;


    ELSIF g_addenda_num = 1 THEN

      hr_utility.TRACE('Sixth Addenda');

	  pay_mag_tape.internal_cxt_values(1) := '3';

      pay_mag_tape.internal_cxt_names(2) := 'DATE_EARNED';
      pay_mag_tape.internal_cxt_values(2) := fnd_date.date_to_canonical(p_effective_date);

      pay_mag_tape.internal_cxt_names(3) := 'ORG_PAY_METHOD_ID';
      pay_mag_tape.internal_cxt_values(3) := g_org_payment_method_id;

      g_addenda := get_formula_id('NACHA_IAT_ADDENDA6');
      pay_mag_tape.internal_prm_values(1) := '10';
      pay_mag_tape.internal_prm_values(2) := g_addenda;

     -- Parameters 3-6 are transferred from previous formula
      -- 3 - TRANSFER_ENTRY_COUNT
      -- 4 - TRANSFER_ENTRY_HASH
      -- 5 - TRANSFER_CREDIT_AMOUNT

      pay_mag_tape.internal_prm_names(6) := 'ADDENDA_NUMBER';
      pay_mag_tape.internal_prm_values(6) := to_char(7 - g_addenda_num);

      pay_mag_tape.internal_prm_names(7) := 'TRACE_SEQUENCE_NUMBER';
      pay_mag_tape.internal_prm_values(7) := to_char(g_count);

      pay_mag_tape.internal_prm_names(8) := 'EMPLOYEE_NUMBER';
	  pay_mag_tape.internal_prm_values(8) := to_char(g_emp_num);

      pay_mag_tape.internal_prm_names(9) := 'EMPLOYEE_ADDR';
	  pay_mag_tape.internal_prm_values(9) := to_char(g_emp_adress);

      pay_mag_tape.internal_prm_names(10) := 'ORG_ADDENDA';
      pay_mag_tape.internal_prm_values(10) := g_org_addenda;

    ELSIF g_addenda_num = 0 THEN

      hr_utility.TRACE('Seventh Addenda');

	  pay_mag_tape.internal_cxt_values(1) := '3';

      pay_mag_tape.internal_cxt_names(2) := 'DATE_EARNED';
      pay_mag_tape.internal_cxt_values(2) := fnd_date.date_to_canonical(p_effective_date);

      pay_mag_tape.internal_cxt_names(3) := 'ORG_PAY_METHOD_ID';
      pay_mag_tape.internal_cxt_values(3) := g_org_payment_method_id;

      g_addenda := get_formula_id('NACHA_IAT_ADDENDA7');
      pay_mag_tape.internal_prm_values(1) := '10';
      pay_mag_tape.internal_prm_values(2) := g_addenda;

     -- Parameters 3-6 are transferred from previous formula
      -- 3 - TRANSFER_ENTRY_COUNT
      -- 4 - TRANSFER_ENTRY_HASH
      -- 5 - TRANSFER_CREDIT_AMOUNT

      pay_mag_tape.internal_prm_names(6) := 'ADDENDA_NUMBER';
      pay_mag_tape.internal_prm_values(6) := to_char(7 - g_addenda_num);

      pay_mag_tape.internal_prm_names(7) := 'TRACE_SEQUENCE_NUMBER';
      pay_mag_tape.internal_prm_values(7) := to_char(g_count);

      pay_mag_tape.internal_prm_names(8) := 'EMP_CITY_STATE';
      pay_mag_tape.internal_prm_values(8) := g_emp_city ||  get_addr_delim(g_emp_state )|| g_emp_state || '\';

      pay_mag_tape.internal_prm_names(9) := 'EMP_COUNTRY_POSTAL';
      pay_mag_tape.internal_prm_values(9) := g_emp_country ||  get_addr_delim(g_emp_postal) || g_emp_postal || '\';

      pay_mag_tape.internal_prm_names(10) := 'ORG_ADDENDA';
      pay_mag_tape.internal_prm_values(10) := g_org_addenda;

      g_org_addenda := 'N';

    ELSE

      hr_utility.TRACE('No Addenda Records to Write');

    END IF;


   -- we do not change the count till after so we can have the same trace number
   -- in both entry detail and addenda rec
    g_addenda_count := g_addenda_count + 1;

    hr_utility.TRACE('Leaving Addenda');

  END; /* write_addenda */


/******************************************************************
   NAME
       write_batch_control
   DESCRIPTION
       Writes the Batch Control Record .
   NOTES
       Local function.
********************************************************************/


  PROCEDURE write_batch_control IS

  BEGIN
    hr_utility.TRACE('Writing IAT Batch Control');

    g_batch_control_write := 'N';

    g_hash := g_hash + get_transfer_param ('TRANSFER_ENTRY_HASH');

    hr_utility.TRACE('Batch Control : g_hash ' || g_hash);
    hr_utility.TRACE('Batch Control : TRANSFER_ENTRY_HASH ' || get_transfer_param ('TRANSFER_ENTRY_HASH'));

    g_amount := g_amount + get_transfer_param ('TRANSFER_CREDIT_AMOUNT');

   -- Context Setup for NACHA_BATCH_CONTROL
   -- First context value is number of context values

    hr_utility.TRACE('.... Writing Batch Control Context');

    pay_mag_tape.internal_cxt_values(1) := '4';
    pay_mag_tape.internal_cxt_names(2) := 'TAX_UNIT_ID';
    pay_mag_tape.internal_cxt_values(2) := TO_CHAR(g_legal_company_id);
    pay_mag_tape.internal_cxt_names(3) := 'DATE_EARNED';
    pay_mag_tape.internal_cxt_values(3) := fnd_date.date_to_canonical(p_effective_date);
    pay_mag_tape.internal_cxt_names(4) := 'ORG_PAY_METHOD_ID';
    pay_mag_tape.internal_cxt_values(4) := g_org_payment_method_id;

  -- Parameter Setup for NACHA_BATCH_CONTROL
  -- First parameter value is number of parameters

    hr_utility.TRACE('.... Writing Batch Control Parameters');

    pay_mag_tape.internal_prm_values(1) := '6';
    pay_mag_tape.internal_prm_values(2) := g_batch_control;

    -- Parameters 4-7 are transferred from previous formula
    -- 3 - TRANSFER_ENTRY_COUNT
    -- 4 - TRANSFER_ENTRY_HASH
    -- 5 - TRANSFER_CREDIT_AMOUNT


    pay_mag_tape.internal_prm_names(6) := 'BATCH_NUMBER';
    pay_mag_tape.internal_prm_values(6) := TO_CHAR(g_batch_number);

    hr_utility.set_location('run_formula.Batch_ctrl', 9);

    hr_utility.TRACE('Leaving Batch Control');

  END; /* write_batch_control */

/******************************************************************
   NAME
       write_file_control
   DESCRIPTION
       Writes the File Control Record .
   NOTES
       Local function.
********************************************************************/

  PROCEDURE write_file_control IS

  BEGIN

    hr_utility.TRACE('Writing File Control');

    /*
    hr_utility.TRACE('g_batch_number: ' || g_batch_number);
    hr_utility.TRACE('g_count: ' || g_count);
    hr_utility.TRACE('g_addenda_count: ' || g_addenda_count);

    hr_utility.TRACE('File Control : g_hash ' || g_hash);
    */

    v_block_count := CEIL(((2 * g_batch_number ) +
                           g_count + g_addenda_count + 2) / 10);
    g_pad_count := (v_block_count * 10) -
    ((2 * g_batch_number ) +
     g_count + g_addenda_count + 2);

    hr_utility.TRACE('.... Writing File Control Context');

   -- dscully - added contexts for NACHA_BALANCED_NACHA_FILE DBI
    pay_mag_tape.internal_cxt_values(1) := '3';
    pay_mag_tape.internal_cxt_names(2) := 'ORG_PAY_METHOD_ID';
    pay_mag_tape.internal_cxt_values(2) := g_org_payment_method_id;
    pay_mag_tape.internal_cxt_names(3) := 'DATE_EARNED';
    pay_mag_tape.internal_cxt_values(3) := fnd_date.date_to_canonical(p_effective_date);

    hr_utility.TRACE('.... Writing File Control Parameters');

    pay_mag_tape.internal_prm_values(1) := '8';
    pay_mag_tape.internal_prm_values(2) := g_file_control;

    pay_mag_tape.internal_prm_names(3) := 'BATCH_NUMBER';
    pay_mag_tape.internal_prm_values(3) := TO_CHAR(g_batch_number);

    pay_mag_tape.internal_prm_names(4) := 'BLOCK_COUNT';
    pay_mag_tape.internal_prm_values(4) := TO_CHAR(v_block_count);

    pay_mag_tape.internal_prm_names(5) := 'FILE_ENTRY_COUNT';
    pay_mag_tape.internal_prm_values(5) := TO_CHAR(g_count + g_addenda_count);

    pay_mag_tape.internal_prm_names(6) := 'FILE_ENTRY_HASH';
    pay_mag_tape.internal_prm_values(6) := TO_CHAR(g_hash);

    pay_mag_tape.internal_prm_names(7) := 'FILE_CREDIT_AMOUNT';
    pay_mag_tape.internal_prm_values(7) := fnd_number.number_to_canonical(g_amount);

    pay_mag_tape.internal_prm_names(8) := 'TRANSFER_PAD_COUNT';
    pay_mag_tape.internal_prm_values(8) := TO_CHAR(g_pad_count);
--
    hr_utility.set_location('run_formula.File_Control', 11);
    hr_utility.TRACE('Leaving File Control');

  END; /* write_file_control */

/******************************************************************
   NAME
       write_padding
   DESCRIPTION
       Writes the Padding Record .
   NOTES
       Local function.
********************************************************************/
  PROCEDURE write_padding IS

  BEGIN

    hr_utility.TRACE('Writing Padding');

    pay_mag_tape.internal_cxt_values(1) := '1';

    hr_utility.TRACE('Writing Padding for IAT');
    pay_mag_tape.internal_prm_values(1) := '3';
    pay_mag_tape.internal_prm_values(2) := g_padding;
    pay_mag_tape.internal_prm_names(3) := 'TRANSFER_PAD_COUNT';
    pay_mag_tape.internal_prm_values(3) := TO_CHAR(g_pad_count);

    IF g_pad_count = 1 THEN
      CLOSE csr_nacha_batch;
    ELSE
      g_pad_count := g_pad_count - 1;
    END IF;


    hr_utility.TRACE('Leaving IAT Padding');

  END; /* write_padding */

/*****************************END of Local Functions ****************/


  BEGIN

    hr_utility.TRACE('Entering pay_us_nacha_iat_tape.run_formula');
    pay_mag_tape.internal_prm_names(1) := 'NO_OF_PARAMETERS';
    pay_mag_tape.internal_prm_names(2) := 'NEW_FORMULA_ID';
    pay_mag_tape.internal_prm_values(1) := '2';

    pay_mag_tape.internal_cxt_names(1) := 'NUMBER_OF_CONTEXT';
    pay_mag_tape.internal_cxt_values(1) := '1';
    hr_utility.set_location('pay_us_nacha_iat_tape.run_formula', 1);


    IF NOT csr_nacha_batch%ISOPEN AND g_first_exec = 'Y' THEN

      g_first_exec := 'N';

      hr_utility.set_location('run_formula.Init', 5);
      g_payroll_action_id := fnd_number.canonical_to_number(
                                                            pay_mag_tape.internal_prm_values(3));

      hr_utility.TRACE('g_payroll_action_id : ' || g_payroll_action_id);


      g_org_payment_method_id := p_org_payment_method_id;

      g_payroll_id := p_payroll_id;

      g_company_entry_desc := 'SALARY';
      g_descriptive_date := g_date;


      -- Intialize global varibles
      g_temp_count := 0; /* Flag to initialize batch running totals */
      g_pad_count :=  - 1; /* Number of times the padding formula called */


      --Fetching the Formula ID for all the Formulae
      g_file_header := get_formula_id('NACHA_IAT_FILE_HEADER');
      g_batch_header := get_formula_id('NACHA_IAT_BATCH_HEADER');
      g_entry_detail := get_formula_id('NACHA_IAT_ENTRY_DETAIL');
      g_org_pay_entry_detail := get_formula_id('NACHA_IAT_ORG_PAY_ENTRY_DETAIL');
      g_batch_control := get_formula_id('NACHA_IAT_BATCH_CONTROL');
      g_file_control := get_formula_id('NACHA_IAT_FILE_CONTROL');
      g_padding := get_formula_id('NACHA_IAT_PADDING');

      IF g_org_payment_method_id IS NULL THEN
        OPEN csr_org_flex_info (p_business_group_id,
                                g_payroll_action_id,
                                p_effective_date);
        FETCH csr_org_flex_info INTO g_org_payment_method_id, g_payroll_id;
        CLOSE csr_org_flex_info;

      END IF;

      hr_utility.TRACE('g_payroll_id : ' || g_payroll_id);
      hr_utility.TRACE('g_organization_id : ' || g_organization_id);

      IF g_org_payment_method_id IS NOT NULL THEN
        hr_utility.TRACE('g_org_payment_method_id = ' || g_org_payment_method_id);
        write_file_header;
      ELSE
        hr_utility.set_message(801, 'HR_7711_SCL_FLEX_NOT_FOUND');
        hr_utility.raise_error;
      END IF;

	  hr_utility.TRACE('p_business_group_id = ' || p_business_group_id);
      hr_utility.TRACE('g_payroll_action_id <' || g_payroll_action_id);
      hr_utility.TRACE('p_effective_date <' || p_effective_date);

      OPEN csr_nacha_batch(p_business_group_id, g_payroll_action_id, p_effective_date);


/****************Level 1.2 The second major else if clause ***************/
    ELSE /* main */

      IF g_addenda_write = 'Y' THEN

        write_addenda;

      ELSIF g_batch_control_write = 'Y' THEN

        write_batch_control;

      ELSIF (csr_assignments%ISOPEN OR csr_assignments_no_rule%ISOPEN) THEN
        IF (nvl(hr_general2.get_oracle_db_version, 0) < 10.0) THEN

          FETCH csr_assignments INTO g_assignment_id, g_assignment_action_id,
          v_amount, g_personal_payment_method_id,
          v_prepayment_id, g_rowid;

          IF csr_assignments%FOUND THEN

            IF v_amount > 99999999.99 THEN
              hr_utility.set_message(801, 'PAY_US_PAYMENT_OVERFLOW');
              pay_core_utils.push_message(801, 'PAY_US_PAYMENT_OVERFLOW', 'P');
              pay_core_utils.push_token('ASSIGNMENT_NO', g_assignment_id);
              raise_application_error( - 20101, 'Error in pay_us_nacha_tape.run_formula');

            END IF ;

           --Bug 9413224. Use c_emp_details_override if Override date is provided
           --             Else use c_emp_details
            --OPEN c_emp_details(p_effective_date);
            if p_direct_dep_date is not null then
                hr_utility.TRACE('p_direct_dep_date is not null ' || p_direct_dep_date);

                OPEN c_emp_details_override(to_date(p_direct_dep_date,'YYMMDD'));
                FETCH c_emp_details_override INTO g_full_name, g_organization_id, n_person_id, g_emp_num,
                                        g_emp_adress, g_emp_city, g_emp_state, g_emp_county, g_emp_country, g_emp_postal;
                CLOSE c_emp_details_override;

            else
                hr_utility.TRACE('p_direct_dep_date is null ');
                OPEN c_emp_details(v_prepayment_id);
            FETCH c_emp_details INTO g_full_name, g_organization_id, n_person_id, g_emp_num,
                                    g_emp_adress, g_emp_city, g_emp_state, g_emp_county, g_emp_country, g_emp_postal;
                CLOSE c_emp_details;

                hr_utility.TRACE('g_emp_num : ' || g_emp_num);

            end if;

            --No need of this check as any employee for which payroll has been run will atleast have the primary address
            /*IF c_emp_details%NOTFOUND THEN
                CLOSE c_emp_details;
                hr_utility.set_message(801, 'PAY_US_IAT_NO_ADDRESS');
                hr_utility.set_message_token('ASSIGN_NUM', g_assignment_id);
                hr_utility.raise_error;
            END IF;*/



            hr_utility.TRACE('full_name : ' || g_full_name);

            g_overflow_amount := g_overflow_amount + v_amount;

            IF g_overflow_amount > 99999999.99 THEN
              g_overflow_amount := 0;
              g_overflow_flag := 'Y';
              g_addenda_num := 7;
              write_org_entry_detail;

            ELSE
              g_addenda_num := 7;
              write_entry_detail;
            END IF;

          ELSE /* setup context and params for NACHA_ORG_PAY_ENTRY_DETAIL */
            g_addenda_num := 7;
            write_org_entry_detail;
          END IF;
        ELSE

          FETCH csr_assignments_no_rule INTO g_assignment_id, g_assignment_action_id,
          v_amount, g_personal_payment_method_id,
          v_prepayment_id, g_rowid;

          IF csr_assignments_no_rule%FOUND THEN

            g_overflow_amount := g_overflow_amount + v_amount;

            IF v_amount > 99999999.99 THEN
              hr_utility.set_message(801, 'PAY_US_PAYMENT_OVERFLOW');
              pay_core_utils.push_message(801, 'PAY_US_PAYMENT_OVERFLOW', 'P');
              pay_core_utils.push_token('ASSIGNMENT_NO', g_assignment_id);
              raise_application_error( - 20101, 'Error in pay_us_nacha_tape.run_formula');
            END IF;


           --Bug 9413224. Use c_emp_details_override if Override date is provided
           --             Else use c_emp_details
            --            OPEN c_emp_details(p_effective_date);
            if p_direct_dep_date is not null then
                hr_utility.TRACE('p_direct_dep_date is not null ' || p_direct_dep_date);

                OPEN c_emp_details_override(to_date(p_direct_dep_date,'YYMMDD'));
                FETCH c_emp_details_override INTO g_full_name, g_organization_id, n_person_id, g_emp_num,
                                        g_emp_adress, g_emp_city, g_emp_state, g_emp_county, g_emp_country, g_emp_postal;
                CLOSE c_emp_details_override;

                hr_utility.TRACE('g_emp_num : ' || g_emp_num);

            else
                hr_utility.TRACE('p_direct_dep_date is null ');
                OPEN c_emp_details(v_prepayment_id);
            FETCH c_emp_details INTO g_full_name, g_organization_id, n_person_id, g_emp_num,
                                  g_emp_adress, g_emp_city, g_emp_state, g_emp_county, g_emp_country, g_emp_postal;
                CLOSE c_emp_details;

                hr_utility.TRACE('g_emp_num : ' || g_emp_num);

            end if;


            --No need of this check as, any employee for which payroll has been run will atleast have the primary address
            /*IF c_emp_details%NOTFOUND THEN
                CLOSE c_emp_details;
                hr_utility.set_message(801, 'PAY_US_IAT_NO_ADDRESS');
                hr_utility.set_message_token('ASSIGN_NUM', g_assignment_id);
                hr_utility.raise_error;
            END IF;*/
            IF g_overflow_amount > 99999999.99 THEN
              g_overflow_amount := 0;
              g_overflow_flag := 'Y';
              g_addenda_num := 7;
              write_org_entry_detail;
            ELSE
              g_addenda_num := 7;
              write_entry_detail;
            END IF;

          ELSE /* setup context and params for NACHA_ORG_PAY_ENTRY_DETAIL */
            g_addenda_num := 7;
            write_org_entry_detail;

          END IF;
        END IF;
      ELSE

        hr_utility.TRACE('Before Batch cursor');

        FETCH csr_nacha_batch INTO g_csr_org_pay_meth_id,
        g_legal_company_id,
        g_nacha_balance_flag;

        hr_utility.TRACE('after fetch  Batch cursor');

        IF csr_nacha_batch %FOUND THEN
      				  /* to reset rowid when GRE changes. Bug 1967949 */
          hr_utility.TRACE('b4 g_legal_company_id is : ' || g_legal_company_id);
          hr_utility.TRACE('b4 g_reset_greid is : ' || g_reset_greid);
          hr_utility.TRACE('b4 g_rowid is : ' || g_rowid);

          IF g_reset_greid <> g_legal_company_id THEN
            g_rowid := NULL;
            g_reset_greid := g_legal_company_id;
          END IF;

          --Fetching the Address of GRE

          SELECT hou.name         ,
                 hl.ADDRESS_LINE_1,
                 hl.TOWN_OR_CITY  ,
                 hl.REGION_2      ,
                 hl.REGION_1      ,
                 hl.COUNTRY       ,
                 hl.POSTAL_CODE
          INTO   g_org_name      ,
                 g_street_address,
                 g_city          ,
                 g_state         ,
                 g_county        ,
                 g_country       ,
                 g_postal_code
          FROM   hr_organization_units hou,
                 hr_locations hl
          WHERE  hou.location_id     = hl.location_id
             AND hou.organization_id = g_legal_company_id
             and p_effective_date between hou.date_from and nvl(hou.date_to,p_effective_date);

          /*hr_utility.TRACE('p_business_group_id : ' || p_business_group_id);
          hr_utility.TRACE('g_legal_company_id : ' || g_legal_company_id);
          hr_utility.TRACE('g_organization_id : ' || g_organization_id);
          hr_utility.TRACE('g_org_name : ' || g_org_name);
          hr_utility.TRACE('g_street_address : ' || g_street_address);
          hr_utility.TRACE('g_city : ' || g_city);
          hr_utility.TRACE('g_state : ' || g_state);
          hr_utility.TRACE('g_county : ' || g_county);
          hr_utility.TRACE('g_country : ' || g_country);
          hr_utility.TRACE('g_postal_code : ' || g_postal_code);*/

          write_batch_header;

        ELSE

          hr_utility.TRACE('g_pad_count ' || g_pad_count);
          IF g_pad_count =  - 1 THEN
            write_file_control;
          ELSIF g_pad_count > 0 THEN
            write_padding;
          END IF;
        END IF;
      END IF; /* g_addenda_write = 'Y' */
    END IF; /* main */

  END run_formula;

END pay_us_nacha_iat_tape;

/
