--------------------------------------------------------
--  DDL for Package Body PAY_KR_DRT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_DRT" AS
/* $Header: pykrdrt.pkb 120.0.12010000.3 2018/03/23 10:34:00 dduvvuri noship $ */
/* ************************************************************************
 +======================================================================+
 |                Copyright (c) 2018, 2018 Oracle Corporation           |
 |                   Redwood Shores, California, USA                    |
 |                        All rights reserved.                          |
 +======================================================================+
 Package Body Name : pay_kr_drt
 Package File Name : pykrdrt.pkb
 Description : KR Payroll package for Data Removal Tool

 Change List:
 ------------

 Name        Date          Version Bug       Text
 ----------- ------------  ------- --------- ------------------------------
 dduvvuri    14-Mar-2018   120.0             Created
************************************************************************ */

    g_package   VARCHAR2(100) := 'pay_kr_drt.';

    -- Function to return if the Row needs to be filtered out.
    -- If Y is returned, row will be considered for further processing.

    PROCEDURE additional_filter(p_person_id IN NUMBER,
                               p_business_group_id IN NUMBER,
                               p_row_id IN VARCHAR2,
                               p_table_name IN VARCHAR2,
                               p_filter_value OUT NOCOPY VARCHAR2)
     IS

       l_procedure            VARCHAR2(100) := 'additional_filter';
       l_rows                 INTEGER;
       l_filter_value         VARCHAR2(100) := 'N';

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
          AND     piv.name in ( 'Business Place Name' , 'Attachment Seq No' ,'Case Number' ,'Account Number' )
		  AND     piv.legislation_code = 'KR'
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
          AND     piv.name in ( 'Business Place Name' , 'Attachment Seq No' ,'Case Number' ,'Account Number' )
		  AND     piv.legislation_code = 'KR'
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
		AND     ffue.legislation_code = 'KR'
        AND     ffue.user_entity_name in
		        (
'X_KR_BP_NAME',
'X_KR_BP_NUMBER',
'X_KR_BP_REP_NAME',
'X_KR_BP_REP_NI',
'X_KR_BP_TAX_OFFICE_CODE',
'X_KR_CORP_NAME',
'X_KR_CORP_NUMBER',
'X_KR_CORP_REP_NAME',
'X_KR_CORP_REP_NI',
'X_KR_CORP_TEL_NUMBER',
'X_KR_EMP_COUNTRY_CODE',
'X_KR_EMP_NAME',
'X_KR_EMP_NATIONALITY',
'X_KR_EMP_NI',
'X_KR_HIA_BUSINESS_PLACE_CODE',
'X_KR_HIA_BUSINESS_PLACE_UNIT',
'X_KR_HIA_EMPLOYEE_NAME',
'X_KR_HIA_HI_NUMBER',
'X_KR_HIA_REGISTRATION_NUMBER',
'X_KR_NPA_BRANCH_CODE',
'X_KR_NPA_BUSINESS_PLACE_CODE',
'X_KR_NPA_COMPUTERIZATION_CODE',
'X_KR_NPA_REGISTRATION_NUMBER',
'X_KR_PREV_BP_NAME',
'X_KR_PREV_BP_NUMBER',
'X_YEA_TAX_GRP_BUS_REG_NUM',
'X_YEA_TAX_GRP_NAME',
'A_SEPARATION_PAY_TAX_DEFERRING_DETAILS_TRANS_SEP_PEN_ACCT_NUM_ENTRY_VALUE',
'A_SEPARATION_PAY_TAX_DEFERRING_DETAILS_TRANS_SEP_PEN_BUS_NUM_ENTRY_VALUE',
'A_SEPARATION_PENSION_ACCOUNT_DETAILS_ACCOUNT_NUMBER_ENTRY_VALUE',
'A_SEPARATION_PENSION_ACCOUNT_DETAILS_DEFINED_TYPE_ENTRY_VALUE'
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
       l_udf_mask_value       VARCHAR2(2000) := null;

    BEGIN
	  hr_utility.trace('Entering '||g_package||l_procedure);

	  IF p_table_name = 'PAY_ELEMENT_ENTRY_VALUES_F' OR p_table_name = 'PAY_RUN_RESULT_VALUES' THEN
       p_udf_mask_value := '12345';
	  ELSE
	   p_udf_mask_value := l_udf_mask_value;
      END IF;


	  hr_utility.trace('Leaving '||g_package||l_procedure);

    END mask_value_udf;

END pay_kr_drt;

/
