--------------------------------------------------------
--  DDL for Package Body PAY_SG_DRT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SG_DRT" AS
/* $Header: pysgdrt.pkb 120.0.12010000.3 2018/03/23 10:28:41 dduvvuri noship $ */
/* ************************************************************************
 +======================================================================+
 |                Copyright (c) 2018, 2018 Oracle Corporation           |
 |                   Redwood Shores, California, USA                    |
 |                        All rights reserved.                          |
 +======================================================================+
 Package Body Name : pay_sg_drt
 Package File Name : pysgdrt.pkb
 Description : SG Payroll package for Data Removal Tool

 Change List:
 ------------

 Name        Date          Version Bug       Text
 ----------- ------------  ------- --------- ------------------------------
 dduvvuri    14-Mar-2018   120.0             Created
************************************************************************ */

    g_package   VARCHAR2(100) := 'pay_sg_drt.';

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

        p_filter_value := l_filter_value;

      END IF;

    IF p_table_name = 'PAY_RUN_RESULT_VALUES' THEN

      p_filter_value := l_filter_value;

    END IF;

	IF p_table_name = 'FF_ARCHIVE_ITEMS' THEN
      BEGIN
        SELECT  'Y'  INTO l_filter_value
        FROM    ff_archive_items ffai
               ,ff_user_entities ffue
        WHERE   ffue.user_entity_id  = ffai.user_entity_id
		AND     ffue.legislation_code = 'SG'
        AND     ffue.user_entity_name in
		        (
'X_HR_IR8A_FURTHER_DETAILS_SG_PER_REMARKS',
'X_HR_IR8A_FURTHER_DETAILS_SG_NAME_OF_BANK',
'X_HR_IRAS_ADDITIONAL_INFO_SG_PER_ADDITIONAL_INFORMATION',
'X_PEOPLE_FLEXFIELD_SG_SG_INCOME_TAX_NUMBER',
'X_PEOPLE_FLEXFIELD_SG_SG_LEGAL_NAME',
'X_PEOPLE_FLEXFIELD_SG_SG_PAYEE_ID_TYPE',
'X_PEOPLE_FLEXFIELD_SG_SG_PERMIT_TYPE',
'X_PEOPLE_FLEXFIELD_SG_SG_PP_COUNTRY',
'X_PER_ADR_COUNTRY_CODE',
'X_PER_ADR_LINE_1',
'X_PER_ADR_LINE_2',
'X_PER_ADR_LINE_3',
'X_PER_ADR_POSTAL_CODE',
'X_PER_ADR_STYLE',
'X_PER_ADR_TYPE',
'X_PER_CQ_ADR_LINE_1',
'X_PER_CQ_ADR_LINE_2',
'X_PER_CQ_ADR_LINE_3',
'X_PER_NATIONALITY_CODE',
'X_PER_NATIONAL_IDENTIFIER',
'X_PER_OS_ADR_LINE_1',
'X_PER_OS_ADR_LINE_2',
'X_PER_OS_ADR_LINE_3',
'X_PER_PREMISES',
'X_SG_LEGAL_ENTITY_SG_ER_AUTH_PERSON',
'X_SG_LEGAL_ENTITY_SG_ER_AUTH_PERSON_DESIG',
'X_SG_LEGAL_ENTITY_SG_ER_AUTH_PERSON_EMAIL',
'X_SG_LEGAL_ENTITY_SG_ER_CPF_CATEGORY',
'X_SG_LEGAL_ENTITY_SG_ER_DIVISION',
'X_SG_LEGAL_ENTITY_SG_ER_ID_CHECK',
'X_SG_LEGAL_ENTITY_SG_ER_INCOME_TAX_NUMBER',
'X_SG_LEGAL_ENTITY_SG_ER_IRAS_CATEGORY',
'X_SG_LEGAL_ENTITY_SG_ER_OHQ_STATUS',
'X_SG_LEGAL_ENTITY_SG_ER_PAYER_ID',
'X_SG_LEGAL_ENTITY_SG_ER_TELEPHONE_NUMBER',
'X_SG_LEGAL_ENTITY_SG_LEGAL_ENTITY_NAME',
'X_SG_ORG_TELEPHONE_NUMBER'
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

    BEGIN
	  hr_utility.trace('Entering '||g_package||l_procedure);

	  IF p_table_name = 'FF_ARCHIVE_ITEMS' THEN
       p_udf_mask_value := null ;
      END IF;

	  hr_utility.trace('Leaving '||g_package||l_procedure);

    END mask_value_udf;

END pay_sg_drt;

/
