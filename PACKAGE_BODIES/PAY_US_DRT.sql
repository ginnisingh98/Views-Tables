--------------------------------------------------------
--  DDL for Package Body PAY_US_DRT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_DRT" AS
/* $Header: pyusdrt.pkb 120.0.12010000.13 2018/04/24 12:00:13 sjawid noship $ */
/* ************************************************************************
 +======================================================================+
 |                Copyright (c) 2018, 2018 Oracle Corporation           |
 |                   Redwood Shores, California, USA                    |
 |                        All rights reserved.                          |
 +======================================================================+
 Package Body Name : pay_us_drt
 Package File Name : pyusdrt.pkb
 Description : US Payroll localization package for Data Removal Tool

 Change List:
 ------------

 Name        Date          Version Bug       Text
 ----------- ------------  ------- --------- ------------------------------
 sjawid     03-Mar-2018     120.0             Created
 sjawid     13-Mar-2018     120.2             bug 27660716
 sjawid     27-Mar-2018     120.0.12010000.7  Modified proc pay_us_hr_post
 sjawid     03-Apr-2018     120.0.12010000.8  Added DRC procedure
 sjawid     05-Apr-2018     120.0.12010000.9  Modified file to remove GSCC warnings.
 sjawid     05-Apr-2018     120.0.12010000.10 Modified file to remove GSCC warnings.
 sjawid	    12-Apr-2018     120.0.12010000.7  bug 27849164 - Modified DRC procedure signature
 nvelaga    17-Apr-2018     120.0.12010000.12 Bug 27873156 - Made changes to avoid compilation
                                              error ORA-00942: table or view does not exist
                                              on pay_mag_archive_data
 sjawid	    24-Apr-2018     120.0.12010000.13 bug 27913291 - Modified procedure
                                              pay_final_process_check
************************************************************************ */
    g_package   VARCHAR2(100) := 'pay_us_drt.';

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
  PROCEDURE add_to_results
	    (person_id   IN            number
	    ,entity_type IN            varchar2
	    ,status      IN            varchar2
	    ,msgcode     IN            varchar2
	    ,msgaplid    IN            number
	    ,result_tbl  IN OUT NOCOPY per_drt_pkg.result_tbl_type) IS

	    n number(15);

  BEGIN
	     n := result_tbl.count + 1;
	     result_tbl(n).person_id := person_id;
	     result_tbl(n).entity_type := entity_type;
	     result_tbl(n).status := status;
	     result_tbl(n).msgcode := msgcode;
         result_tbl(n).msgaplid := msgaplid;
	     -- hr_utility.set_message (msgaplid,msgcode);
	     --result_tbl(n).msgtext := hr_utility.get_message ();
  END add_to_results;
--

PROCEDURE pay_final_process_check
    (p_person_id       IN         number
    ,p_legislation_code IN varchar2
    ,p_constraint_months IN number
    ,result_tbl OUT NOCOPY per_drt_pkg.result_tbl_type) IS

	  CURSOR csr_get_termination_date (c_person_id    IN number) IS
	    SELECT   nvl(final_process_date,to_date ('31-12-4712', 'DD-MM-YYYY'))
			FROM    per_periods_of_service
			WHERE   person_id = c_person_id
	    ORDER BY date_start DESC;

    l_proc varchar2(72);
    l_person_id varchar2(20);
    n number;
    l_temp varchar2(20);
    l_legislation_code varchar2(20);
    l_constraint_months number;
    l_count number;
	 	l_fpd  date;
		l_month number;
		l_day number;
		l_success BOOLEAN;
    l_retention_date DATE;
  BEGIN
    l_success:=TRUE;
    l_proc := g_package|| 'pay_final_process_check';
    write_log ('Entering:'|| l_proc,10);

    l_person_id := p_person_id;
    write_log ('l_person_id: '|| l_person_id,20);

    l_legislation_code := p_legislation_code;
    write_log ('l_legislation_code: '|| l_legislation_code, 20);
    HR_UTILITY.TRACE('l_legislation_code: '|| l_legislation_code);

    l_constraint_months :=  p_constraint_months;

    IF (l_legislation_code = 'US' OR l_legislation_code = 'CA' OR l_legislation_code = 'MX' ) THEN
	  BEGIN
	    OPEN csr_get_termination_date (p_person_id);

	    FETCH csr_get_termination_date
	      INTO    l_fpd;

	    CLOSE csr_get_termination_date;

	    write_log ('Final Process Date: '
	               || l_fpd, 20);
          HR_UTILITY.TRACE('l_fpd: '|| l_fpd);

      IF l_fpd IS NOT NULL THEN
      l_retention_date :=  add_months(trunc(l_fpd,'YEAR'),l_constraint_months)-1 ;

	    write_log ('l_retention_date: '
	               || l_retention_date, 20);
       hr_utility.trace('l_retention_date :'||TO_CHAR(l_retention_date,'DD-MM-YYYY'));

        IF l_retention_date > SYSDATE THEN
         hr_utility.trace('ERROR');

	          l_success:=FALSE;

	          add_to_results
	                        (person_id   => p_person_id
	                       , entity_type => 'HR'
	                       , status      => 'W'
	                       , msgcode     => 'HR_500500_EMEA_DRC_REP_PRD'
	                       , msgaplid    => 800
	                       , result_tbl  => result_tbl );
	    END IF;
	  END IF;
     END;
    END IF;

    	--If there was no warning for any legislation
	IF l_success = TRUE THEN
          hr_utility.trace('SUCCESS');
		      add_to_results
		                      (person_id   => p_person_id
		                     , entity_type => 'HR'
		                     , status      => 'S'
		                     , msgcode     => null
		                     , msgaplid    => null
		                     , result_tbl  => result_tbl );
	END IF;
    write_log ('Leaving:'|| l_proc,999);

END pay_final_process_check;


--
  PROCEDURE PAY_US_HR_DRC
      (person_id       IN         number
      ,result_tbl OUT NOCOPY per_drt_pkg.result_tbl_type) IS

      l_proc varchar2(72);
      p_person_id varchar2(20);
      l_legislation_code varchar2(20);
	  l_success BOOLEAN;

  BEGIN

      l_proc := g_package|| 'pay_us_hr_drc';
      write_log ('Entering:'|| l_proc,10);

      p_person_id := person_id;
      write_log ('p_person_id: '|| p_person_id,20);

      l_legislation_code := per_per_bus.return_legislation_code (p_person_id);
      write_log ('l_legislation_code: '|| l_legislation_code, 20);

    IF (l_legislation_code = 'US') THEN

                pay_us_drt.pay_final_process_check
                                    (p_person_id         => p_person_id
                                    ,p_legislation_code  => l_legislation_code
                                    ,p_constraint_months => 18
                                    ,result_tbl          => result_tbl );

    END IF;

      write_log ('Leaving:'|| l_proc,999);

  END PAY_US_HR_DRC;
--

	PROCEDURE additional_filter(
              p_person_id NUMBER,
              p_business_group_id NUMBER,
              p_row_id VARCHAR2,
              p_table_name VARCHAR2,
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

	l_procedure VARCHAR2(100) := 'pay_us_drt_utils';
	BEGIN
	  hr_utility.trace('Entering '||g_package||l_procedure);
	  IF p_table_name = 'PAY_ELEMENT_ENTRY_VALUES_F' OR p_table_name = 'PAY_RUN_RESULT_VALUES' THEN
       p_udf_mask_value := 'AA99999';
    END IF;
	  hr_utility.trace('Leaving '||g_package||l_procedure);
	END;

  PROCEDURE purge_archive_data (p_person_id NUMBER, p_legislation_code VARCHAR2)
  IS
    l_procedure            VARCHAR2(100) := 'purge_archive_data';

    -- Added for Bug 27873156
    l_sql_statement  VARCHAR2(300);
    l_sql_cursor     INTEGER;
    l_result         INTEGER;

    table_does_not_exist EXCEPTION;
    PRAGMA EXCEPTION_INIT(table_does_not_exist, -942); -- ORA-00942

  BEGIN
    hr_utility.trace('Entering '||g_package||l_procedure);
    hr_utility.trace('p_legislation_code  : '||p_legislation_code);
    hr_utility.trace('p_person_id  : '||p_person_id);
    IF p_legislation_code = 'US' OR p_legislation_code = 'CA' OR p_legislation_code = 'MX' THEN
       hr_utility.trace('Deleting ff_archive_item_contexts ... ');

       DELETE
       FROM    ff_archive_item_contexts
       WHERE   archive_item_id IN
            (
       SELECT  fai.archive_item_id
       FROM    ff_archive_items fai
              ,pay_assignment_actions paa
              ,per_all_assignments_f paaf
       WHERE   paaf.person_id = p_person_id
       AND     paaf.assignment_id = paa.assignment_id
       AND     paa.assignment_action_id = fai.context1
           );

       hr_utility.trace('Deleted records count from ff_archive_item_contexts ' ||sql%rowcount);
       hr_utility.trace('Deleting ff_archive_items ... ');
       DELETE
       FROM    ff_archive_items
       WHERE   context1 IN
          (
       SELECT  paa.assignment_action_id
       FROM    pay_assignment_actions paa
               ,per_all_assignments_f paf
       WHERE   paa.assignment_id = paf.assignment_id
       AND     paf.person_id = p_person_id
               );
       hr_utility.trace('Deleted records  count from  ff_archive_items ' ||sql%rowcount);

   END IF;

   IF p_legislation_code = 'US' OR p_legislation_code = 'CA' THEN
      hr_utility.trace('Deleting pay_mag_archive_data ... ');

       -- Modified for Bug 27873156

       l_sql_statement := 'DELETE FROM pay_mag_archive_data WHERE assignment_id IN
                              (SELECT paf.assignment_id FROM per_all_assignments_f paf WHERE paf.person_id = :person_id)';

       l_sql_cursor := dbms_sql.open_cursor;
       dbms_sql.parse(l_sql_cursor, l_sql_statement, dbms_sql.v7);
       dbms_sql.bind_variable(l_sql_cursor, ':person_id', p_person_id);

       l_result := dbms_sql.execute(l_sql_cursor);

       dbms_sql.close_cursor(l_sql_cursor);

       hr_utility.trace('Deleted records count from pay_mag_archive_data ' || l_result);

    END IF;

       EXCEPTION

          WHEN table_does_not_exist THEN
               hr_utility.trace('Table Does Not Exists - Ignoring the Exception.');

               IF dbms_sql.is_open(l_sql_cursor) THEN
                  dbms_sql.close_cursor(l_sql_cursor);
               END IF;

          WHEN OTHERS THEN

                 hr_utility.trace('Error encountered. Below are details.');
                 hr_utility.trace('SQL Code    : '||SQLCODE);
                 hr_utility.trace('SQL Message : '||SQLERRM);
                 RAISE;

  END purge_archive_data;

/* Post process procedure */
   PROCEDURE pay_us_hr_post(p_person_id NUMBER)
    IS

       l_procedure            VARCHAR2(100) := '.purge_us_post';
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

       IF pay_drt.g_legislation_code = 'US' THEN

         pay_us_drt.purge_archive_data ( p_person_id => p_person_id
                                      ,p_legislation_code => pay_drt.g_legislation_code);
       END IF;

       hr_utility.trace('Leaving '||g_package||l_procedure);

    END pay_us_hr_post;


END pay_us_drt;

/
