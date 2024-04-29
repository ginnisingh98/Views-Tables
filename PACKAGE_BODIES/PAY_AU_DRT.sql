--------------------------------------------------------
--  DDL for Package Body PAY_AU_DRT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AU_DRT" AS
/* $Header: pyaudrt.pkb 120.0.12010000.3 2018/03/23 10:26:04 dduvvuri noship $ */
/* ************************************************************************
 +======================================================================+
 |                Copyright (c) 2018, 2018 Oracle Corporation           |
 |                   Redwood Shores, California, USA                    |
 |                        All rights reserved.                          |
 +======================================================================+
 Package Body Name : pay_au_drt
 Package File Name : pyaudrt.pkb
 Description : AU Payroll package for Data Removal Tool

 Change List:
 ------------

 Name        Date          Version Bug       Text
 ----------- ------------  ------- --------- ------------------------------
 dduvvuri    14-Mar-2018   120.0             Created
************************************************************************ */

    g_package   VARCHAR2(100) := 'pay_au_drt.';

    -- Function to return if the Row needs to be filtered out.
    -- If Y is returned, row will be considered for further processing.

    PROCEDURE additional_filter(p_person_id IN NUMBER,
                               p_business_group_id IN NUMBER,
                               p_row_id IN VARCHAR2,
                               p_table_name IN VARCHAR2,
                               p_filter_value OUT NOCOPY VARCHAR2)
     IS

       l_procedure            VARCHAR2(100) := 'additional_filter';
       l_business_group_id    per_all_people_f.business_group_id%TYPE;
       l_proc_statement       VARCHAR2(2000);
       l_proc_cursor          INTEGER;
       l_rows                 INTEGER;
       l_filter_value         VARCHAR2(100) := 'N';
       l_person_id            per_all_assignments_f.person_id%TYPE;

    BEGIN
      hr_utility.trace('Entering '||g_package||l_procedure);
      hr_utility.trace('p_row_id '||p_row_id);
      hr_utility.trace('p_table_name '||p_table_name);

      IF p_table_name = 'PAY_ELEMENT_ENTRY_VALUES_F' THEN

        BEGIN
          SELECT  'Y'  INTO l_filter_value
          FROM    pay_element_entry_values_f peev
                 ,pay_input_values_f piv
          WHERE   peev.input_value_id = piv.input_value_id
          AND     piv.name in ( 'Member Number' , 'Tax File Number' ,'Employee Location ID' ,'Employee Location Identifier' )
		  AND     piv.legislation_code = 'AU'
          AND     peev.rowid = p_row_id;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_filter_value := 'N';
        WHEN OTHERS THEN NULL;
        END;
        p_filter_value := l_filter_value;
      END IF;

    IF p_table_name = 'PAY_RUN_RESULT_VALUES' THEN
      BEGIN
        SELECT  'Y'  INTO l_filter_value
        FROM    pay_run_result_values prrv
               ,pay_input_values_f piv
        WHERE   prrv.input_value_id = piv.input_value_id
        AND     piv.name in ( 'Member Number' , 'Tax File Number' ,'Employee Location ID' ,'Employee Location Identifier' )
		AND     piv.legislation_code = 'AU'
        AND     prrv.rowid = p_row_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_filter_value := 'N';
        WHEN OTHERS THEN NULL;
      END;
      p_filter_value := l_filter_value;
    END IF;

	IF p_table_name = 'FF_ARCHIVE_ITEMS' THEN
      BEGIN
        SELECT  'Y'  INTO l_filter_value
        FROM    ff_archive_items ffai
               ,ff_user_entities ffue
        WHERE   ffue.user_entity_id  = ffai.user_entity_id
		AND     ffue.legislation_code = 'AU'
        AND     ffue.user_entity_name in
		        (
'X_EMPLOYEE_ABN',
'X_EMPLOYEE_ADDRESS_1',
'X_EMPLOYEE_ADDRESS_2',
'X_EMPLOYEE_ADDRESS_3',
'X_EMPLOYEE_COUNTRY',
'X_EMPLOYEE_FIRST_NAME',
'X_EMPLOYEE_MIDDLE_NAME',
'X_EMPLOYEE_POSTCODE',
'X_EMPLOYEE_SURNAME',
'X_EMPLOYEE_TAX_FILE_NUMBER',
'X_EMPLOYER_ABN',
'X_EMPLOYER_ADDRESS_1',
'X_EMPLOYER_ADDRESS_2',
'X_EMPLOYER_ADDRESS_3',
'X_EMPLOYER_BRANCH_NUMBER',
'X_EMPLOYER_BUSINESS_NAME',
'X_EMPLOYER_CONTACT_NAME',
'X_EMPLOYER_CONTACT_TELEPHONE',
'X_EMPLOYER_COUNTRY',
'X_EMPLOYER_GROUP_ACT_NO',
'X_EMPLOYER_POSTCODE',
'X_EMPLOYER_STATE',
'X_EMPLOYER_SUBURB',
'X_EMPLOYER_TRADING_NAME',
'X_EMP_EMAIL_ADDRESS',
'X_ETP_DEATH_BENEFIT_ADDRESS_1',
'X_ETP_DEATH_BENEFIT_ADDRESS_2',
'X_ETP_DEATH_BENEFIT_COUNTRY',
'X_ETP_DEATH_BENEFIT_DOB',
'X_ETP_DEATH_BENEFIT_FIRST_NAME',
'X_ETP_DEATH_BENEFIT_MIDDLE_NAME',
'X_ETP_DEATH_BENEFIT_POSTCODE',
'X_ETP_DEATH_BENEFIT_STATE',
'X_ETP_DEATH_BENEFIT_SURNAME',
'X_ETP_DEATH_BENEFIT_TFN',
'X_ETP_EMPLOYEE_ADDRESS_1',
'X_ETP_EMPLOYEE_ADDRESS_2',
'X_ETP_EMPLOYEE_ADDRESS_3',
'X_ETP_EMPLOYEE_COUNTRY',
'X_ETP_EMPLOYEE_DATE_OF_BIRTH',
'X_ETP_EMPLOYEE_END_DATE',
'X_ETP_EMPLOYEE_FIRST_NAME',
'X_ETP_EMPLOYEE_MIDDLE_NAME',
'X_ETP_EMPLOYEE_POSTCODE',
'X_ETP_EMPLOYEE_START_DATE',
'X_ETP_EMPLOYEE_STATE',
'X_ETP_EMPLOYEE_SURNAME',
'X_ETP_TAX_FILE_NUMBER',
'X_SORT_EMPLOYEE_LAST_NAME',
'X_SORT_EMPLOYEE_NUMBER',
'X_SUPPLIER_ABN',
'X_SUPPLIER_ADDRESS_1',
'X_SUPPLIER_ADDRESS_2',
'X_SUPPLIER_ADDRESS_3',
'X_SUPPLIER_CONTACT_NAME',
'X_SUPPLIER_CONTACT_TELEPHONE',
'X_SUPPLIER_COUNTRY',
'X_SUPPLIER_EMAIL',
'X_SUPPLIER_NAME',
'X_SUPPLIER_NUMBER',
'X_SUPPLIER_POSTCODE',
'X_SUPPLIER_STATE'
				)
        AND     ffai.rowid = p_row_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_filter_value := 'N';
        WHEN OTHERS THEN NULL;
      END;
      p_filter_value := l_filter_value;
    END IF;


	   hr_utility.trace('p_filter_value '||l_filter_value);
	   hr_utility.trace('Leaving '||g_package||l_procedure);

    END additional_filter;

    -- Function to return the user-defined value for given table column

    PROCEDURE mask_value_udf(p_person_id IN NUMBER,
                             p_business_group_id IN NUMBER,
                             p_row_id IN VARCHAR2,
                             p_table_name IN VARCHAR2,
                             p_column_name IN VARCHAR2,
                             p_udf_mask_value OUT NOCOPY VARCHAR2)
    IS

       l_procedure            VARCHAR2(100) := 'mask_value_udf';
       l_business_group_id    per_all_people_f.business_group_id%TYPE;
       l_row_id               VARCHAR2(100);

	   l_name varchar2(100);

    BEGIN
	  hr_utility.trace('Entering '||g_package||l_procedure);

	    IF p_table_name = 'PAY_RUN_RESULT_VALUES' THEN

        SELECT  distinct piv.name INTO l_name
        FROM    pay_run_result_values prrv
               ,pay_input_values_f piv
        WHERE   prrv.input_value_id = piv.input_value_id
        AND     piv.name in ( 'Member Number' , 'Tax File Number' ,'Employee Location ID' ,'Employee Location Identifier' )
		AND     piv.legislation_code = 'AU'
        AND     prrv.rowid = p_row_id;

		IF l_name IN ( 'Member Number','Employee Location ID' ,'Employee Location Identifier' ) THEN
		  p_udf_mask_value := null;
		END IF;

		IF l_name IN ( 'Tax File Number' ) THEN
		  p_udf_mask_value := '111 111 111';
		END IF;

		END IF;

	  IF p_table_name = 'FF_ARCHIVE_ITEMS' THEN
		p_udf_mask_value := null;
	  END IF;

	  IF p_table_name = 'PAY_ELEMENT_ENTRY_VALUES_F' THEN

	      SELECT  distinct piv.name  INTO l_name
          FROM    pay_element_entry_values_f peev
                 ,pay_input_values_f piv
          WHERE   peev.input_value_id = piv.input_value_id
          AND     piv.name in ( 'Member Number' , 'Tax File Number' ,'Employee Location ID' ,'Employee Location Identifier' )
		  AND     piv.legislation_code = 'AU'
          AND     peev.rowid = p_row_id;

		IF l_name IN ( 'Member Number','Employee Location ID' ,'Employee Location Identifier' ) THEN
		  p_udf_mask_value := null;
		END IF;

		IF l_name IN ( 'Tax File Number' ) THEN
		  p_udf_mask_value := '111 111 111';
		END IF;

	  END IF;

	  hr_utility.trace('Leaving '||g_package||l_procedure);

    END mask_value_udf;

END pay_au_drt;

/
