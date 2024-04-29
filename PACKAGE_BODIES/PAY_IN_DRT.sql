--------------------------------------------------------
--  DDL for Package Body PAY_IN_DRT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IN_DRT" AS
/* $Header: pyindrt.pkb 120.0.12010000.3 2018/03/23 10:32:36 dduvvuri noship $ */
/* ************************************************************************
 +======================================================================+
 |                Copyright (c) 2018, 2018 Oracle Corporation           |
 |                   Redwood Shores, California, USA                    |
 |                        All rights reserved.                          |
 +======================================================================+
 Package Body Name : pay_in_drt
 Package File Name : pyindrt.pkb
 Description : IN Payroll package for Data Removal Tool

 Change List:
 ------------

 Name        Date          Version Bug       Text
 ----------- ------------  ------- --------- ------------------------------
 dduvvuri    14-Mar-2018   120.0             Created
************************************************************************ */

    g_package   VARCHAR2(100) := 'pay_in_drt.';

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
          AND     piv.name in ( 'Policy Number' , 'Loan Number' ,'Landlord Name' ,'Landlord Address', 'Address Line 2' , 'Address Line 3', 'Landlord PAN' )
		  AND     piv.legislation_code = 'IN'
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
        AND     piv.name in ( 'Policy Number' , 'Loan Number' ,'Landlord Name' ,'Landlord Address', 'Address Line 2' , 'Address Line 3', 'Landlord PAN' )
		AND     piv.legislation_code = 'IN'
        AND     prrv.rowid = p_row_id;
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
	   l_name     varchar2(100) := null ;

    BEGIN
	  hr_utility.trace('Entering '||g_package||l_procedure);

	  IF p_table_name = 'PAY_ELEMENT_ENTRY_VALUES_F' THEN


	      SELECT  distinct piv.name INTO l_name
          FROM    pay_element_entry_values_f peev
                 ,pay_input_values_f piv
          WHERE   peev.input_value_id = piv.input_value_id
          AND     piv.name in ( 'Policy Number' , 'Loan Number' ,'Landlord Name' ,'Landlord Address', 'Address Line 2' , 'Address Line 3', 'Landlord PAN' )
		  AND     piv.legislation_code = 'IN'
          AND     peev.rowid = p_row_id;

		  IF l_name IN ( 'Policy Number' , 'Loan Number') THEN
		     p_udf_mask_value := '00000';
          END IF;

		  IF l_name IN ('Landlord Name' ,'Landlord Address', 'Address Line 2' , 'Address Line 3', 'Landlord PAN' ) THEN
		     p_udf_mask_value := 'abcde';
		  END IF;

      END IF;

	  IF p_table_name = 'PAY_RUN_RESULT_VALUES' THEN

	      SELECT  distinct piv.name  INTO l_name
        FROM    pay_run_result_values prrv
               ,pay_input_values_f piv
        WHERE   prrv.input_value_id = piv.input_value_id
        AND     piv.name in ( 'Policy Number' , 'Loan Number' ,'Landlord Name' ,'Landlord Address', 'Address Line 2' , 'Address Line 3', 'Landlord PAN' )
		AND     piv.legislation_code = 'IN'
        AND     prrv.rowid = p_row_id;

		  IF l_name IN ( 'Policy Number' , 'Loan Number') THEN
		     p_udf_mask_value := '00000';
          END IF;

		  IF l_name IN ('Landlord Name' ,'Landlord Address', 'Address Line 2' , 'Address Line 3', 'Landlord PAN' ) THEN
		     p_udf_mask_value := 'abcde';
		  END IF;

	  END IF;

	  hr_utility.trace('Leaving '||g_package||l_procedure);

    END mask_value_udf;

END pay_in_drt;

/
