--------------------------------------------------------
--  DDL for Package Body PAY_CA_DRT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_DRT" AS
/* $Header: pycadrt.pkb 120.0.12010000.6 2018/04/12 05:20:59 sjawid noship $ */
/* ************************************************************************
 +======================================================================+
 |                Copyright (c) 2018, 2018 Oracle Corporation           |
 |                   Redwood Shores, California, USA                    |
 |                        All rights reserved.                          |
 +======================================================================+
 Package Body Name : pay_ca_drt
 Package File Name : pycadrt.pkb
 Description : US Payroll localization package for Data Removal Tool

 Change List:
 ------------

 Name        Date          Version Bug       Text
 ----------- ------------  ------- --------- ------------------------------
 sjawid     03-Mar-2018     120.0              Created
 sjawid     27-Mar-2018     120.0.12010000.4   Modified proc pay_ca_hr_post
 sjawid     29-Mar-2018     120.0.12010000.5   Added DRC procedure
 sjawid	    12-Apr-2018     120.0.12010000.6   bug 27849164 - Modified DRC procedure signature
************************************************************************ */

    g_package   VARCHAR2(100) := 'pay_ca_drt.';

	PROCEDURE write_log
      (message IN varchar2
       ,stage   IN varchar2) IS
       BEGIN
       IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
          fnd_log.string (fnd_log.level_procedure
                          ,message
                          ,stage);
       END IF;
    END write_log;
--

--
  PROCEDURE PAY_CA_HR_DRC
      (person_id       IN         number
      ,result_tbl OUT NOCOPY per_drt_pkg.result_tbl_type) IS

      l_proc varchar2(72);
      p_person_id varchar2(20);
      l_legislation_code varchar2(20);
	  l_success BOOLEAN;

  BEGIN

      l_proc := g_package|| 'pay_ca_hr_drc';
      write_log ('Entering:'|| l_proc,10);

      p_person_id := person_id;
      write_log ('p_person_id: '|| p_person_id,20);

      l_legislation_code := per_per_bus.return_legislation_code (p_person_id);
      write_log ('l_legislation_code: '|| l_legislation_code, 20);

    IF (l_legislation_code = 'CA') THEN

                pay_us_drt.pay_final_process_check
                                    (p_person_id         => p_person_id
                                    ,p_legislation_code  => l_legislation_code
                                    ,p_constraint_months => 18
                                    ,result_tbl          => result_tbl );

    END IF;

      write_log ('Leaving:'|| l_proc,999);

  END PAY_CA_HR_DRC;


	PROCEDURE additional_filter(
              p_person_id IN NUMBER,
              p_business_group_id IN NUMBER,
              p_row_id IN VARCHAR2,
              p_table_name IN VARCHAR2,
              p_filter_value OUT nocopy VARCHAR2) IS


	  l_procedure VARCHAR2(100) := 'additional_filter';
      l_filter_value VARCHAR2(1) := 'N';
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
          AND     piv.name = 'Attachment Number'
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
        AND     piv.name = 'Attachment Number'
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
	END;


	PROCEDURE  mask_value_udf(
               p_person_id IN NUMBER,
               p_business_group_id IN NUMBER,
               p_row_id IN VARCHAR2,
               p_table_name IN VARCHAR2,
               p_column_name IN VARCHAR2,
               p_udf_mask_value OUT nocopy VARCHAR2) IS

	l_procedure VARCHAR2(100) := 'mask_value_udf';
	BEGIN
	  hr_utility.trace('Entering '||g_package||l_procedure);
	  IF p_table_name = 'PAY_ELEMENT_ENTRY_VALUES_F' OR p_table_name = 'PAY_RUN_RESULT_VALUES' THEN
       p_udf_mask_value := 'AA99999';
    END IF;

	  hr_utility.trace('Leaving '||g_package||l_procedure);
	END;

   PROCEDURE pay_ca_hr_post(p_person_id NUMBER)
    IS

       l_procedure            VARCHAR2(100) := '.pay_ca_hr_post';
       l_business_group_id    per_all_people_f.business_group_id%TYPE;
       l_proc_statement       VARCHAR2(2000);
       l_proc_cursor          INTEGER;
       l_rows                 INTEGER;
      -- l_process_status       VARCHAR2(10);

    BEGIN
       hr_utility.trace('Entering '||g_package||l_procedure);
       hr_utility.trace('Parameters are ');
       hr_utility.trace('Person ID  : '||p_person_id);

       pay_drt.extract_details(p_person_id);
       hr_utility.trace('g_legislation_code  : '||pay_drt.g_legislation_code);

       IF pay_drt.g_legislation_code = 'CA' THEN

         pay_us_drt.purge_archive_data ( p_person_id => p_person_id
                                      ,p_legislation_code => pay_drt.g_legislation_code);
       END IF;
       hr_utility.trace('Leaving '||g_package||l_procedure);

    END pay_ca_hr_post;

END pay_ca_drt;

/
