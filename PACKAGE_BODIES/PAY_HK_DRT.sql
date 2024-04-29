--------------------------------------------------------
--  DDL for Package Body PAY_HK_DRT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_HK_DRT" AS
/* $Header: pyhkdrt.pkb 120.0.12010000.3 2018/03/23 10:30:18 dduvvuri noship $ */
/* ************************************************************************
 +======================================================================+
 |                Copyright (c) 2018, 2018 Oracle Corporation           |
 |                   Redwood Shores, California, USA                    |
 |                        All rights reserved.                          |
 +======================================================================+
 Package Body Name : pay_hk_drt
 Package File Name : pyhkdrt.pkb
 Description : HK Payroll package for Data Removal Tool

 Change List:
 ------------

 Name        Date          Version Bug       Text
 ----------- ------------  ------- --------- ------------------------------
 dduvvuri    14-Mar-2018   120.0             Created
************************************************************************ */

    g_package   VARCHAR2(100) := 'pay_hk_drt.';

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
          AND     piv.name in ( 'Membership ID')
		  AND     piv.legislation_code = 'HK'
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
        AND     piv.name in ( 'Membership ID')
		AND     piv.legislation_code = 'HK'
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
		AND     ffue.legislation_code = 'HK'
        AND     ffue.user_entity_name in
		        (
'X_HK_ARCHIVE_MESSAGE',
'X_HK_CAPACITY_EMPLOYED',
'X_HK_CHINESE_FULL_NAME',
'X_HK_CONTACT',
'X_HK_CORRESPONDENCE_ADDRESS_1',
'X_HK_CORRESPONDENCE_ADDRESS_2',
'X_HK_EMPLOYEE_TFN',
'X_HK_EMPLOYER_NAME',
'X_HK_EMPLOYER_TFN',
'X_HK_HKID',
'X_HK_IR56_A_DESCRIPTION',
'X_HK_IR56_B_DESCRIPTION',
'X_HK_IR56_C_DESCRIPTION',
'X_HK_IR56_D_DESCRIPTION',
'X_HK_IR56_E_DESCRIPTION',
'X_HK_IR56_F_DESCRIPTION',
'X_HK_IR56_G_DESCRIPTION',
'X_HK_IR56_H_DESCRIPTION',
'X_HK_IR56_I_DESCRIPTION',
'X_HK_IR56_J_DESCRIPTION',
'X_HK_IR56_K1_DESCRIPTION',
'X_HK_IR56_K2_DESCRIPTION',
'X_HK_IR56_K3_DESCRIPTION',
'X_HK_IR56_L_DESCRIPTION',
'X_HK_IR56_L_DESCRIPTION',
'X_HK_ISSUE_DATE',
'X_HK_LAST_NAME',
'X_HK_LEGAL_EMPLOYER_ID',
'X_HK_OTHER_NAMES',
'X_HK_OVERSEAS_ADDRESS',
'X_HK_OVERSEAS_CONCERN',
'X_HK_OVERSEAS_NAME',
'X_HK_PASSPORT_INFO',
'X_HK_PRINCIPAL_EMPLOYER_NAME',
'X_HK_QUARTERS_1_ADDRESS',
'X_HK_QUARTERS_1_NATURE',
'X_HK_QUARTERS_2_ADDRESS',
'X_HK_QUARTERS_2_NATURE',
'X_HK_QUARTERS_PROVIDED',
'X_HK_REMARKS',
'X_HK_RESIDENTIAL_ADDRESS_1',
'X_HK_RESIDENTIAL_ADDRESS_2',
'X_HK_RESIDENTIAL_ADDRESS_AREA_CODE',
'X_HK_RES_COUNTRY',
'X_HK_SHEET_NO',
'X_HK_SPOUSE_HKID',
'X_HK_SPOUSE_NAME',
'X_HK_SPOUSE_PASSPORT_INFO'
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
       l_udf_mask_value       VARCHAR2(2000);

    BEGIN
	  hr_utility.trace('Entering '||g_package||l_procedure);

	  IF p_table_name = 'PAY_ELEMENT_ENTRY_VALUES_F' OR p_table_name = 'PAY_RUN_RESULT_VALUES' THEN
       p_udf_mask_value := '00000';
      END IF;

	  IF p_table_name = 'FF_ARCHIVE_ITEMS' THEN
	   p_udf_mask_value := null;
	  END IF;

	  hr_utility.trace('Leaving '||g_package||l_procedure);

    END mask_value_udf;

END pay_hk_drt;

/
