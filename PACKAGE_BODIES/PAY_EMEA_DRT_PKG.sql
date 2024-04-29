--------------------------------------------------------
--  DDL for Package Body PAY_EMEA_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_EMEA_DRT_PKG" AS
/* $Header: pydrtemea.pkb 120.0.12010000.14 2018/04/24 14:46:39 simarsin noship $*/

l_package          CONSTANT VARCHAR2(50):= 'PAY_EMEA_DRT_PKG';
--
--
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
/*
	  n := result_tbl.count + 1;

	  result_tbl (n).person_id := person_id;

	  result_tbl (n).entity_type := entity_type;

	  result_tbl (n).status := status;

	  result_tbl (n).msgcode := msgcode;
		result_tbl (n).msgaplid := msgaplid;
*/
			per_drt_pkg.add_to_results(person_id => person_id
 			  ,entity_type => entity_type
 			  ,status => status
 			  ,msgcode => msgcode
 			  ,msgaplid => msgaplid
 			  ,result_tbl => result_tbl);


END add_to_results;
--
--
PROCEDURE pay_emea_hr_drc
    (person_id       IN         number
    ,result_tbl OUT NOCOPY per_drt_pkg.result_tbl_type) IS

    l_proc varchar2(72);
    p_person_id varchar2(20);
    n number;
    l_temp varchar2(20);
    l_legislation_code varchar2(20);
    l_constraint_months number;

BEGIN

    l_proc := l_package|| 'pay_emea_hr_drc';
    write_log ('Entering:'|| l_proc,10);

    p_person_id := person_id;
    write_log ('p_person_id: '|| p_person_id,20);

    l_legislation_code := per_per_bus.return_legislation_code (p_person_id);
    write_log ('l_legislation_code: '|| l_legislation_code, 20);

    IF (l_legislation_code = 'AE') THEN

			pay_final_process_check(p_person_id, l_legislation_code, 12, result_tbl);

    ELSIF (l_legislation_code = 'BE') THEN

			pay_final_process_check(p_person_id, l_legislation_code, 12, result_tbl);

    ELSIF (l_legislation_code = 'DE') THEN

			pay_final_process_check(p_person_id, l_legislation_code, 120, result_tbl);

    ELSIF (l_legislation_code = 'DK') THEN

			pay_final_process_check(p_person_id, l_legislation_code, 12, result_tbl);

    ELSIF (l_legislation_code = 'ES') THEN

			pay_final_process_check(p_person_id, l_legislation_code, 12, result_tbl);

    ELSIF (l_legislation_code = 'FI') THEN

			pay_final_process_check(p_person_id, l_legislation_code, 12, result_tbl);

    ELSIF (l_legislation_code = 'FR') THEN

			pay_final_process_check(p_person_id, l_legislation_code, 60, result_tbl);

    ELSIF (l_legislation_code = 'HU') THEN

			pay_final_process_check(p_person_id, l_legislation_code, 12, result_tbl);

    ELSIF (l_legislation_code = 'IT') THEN

			pay_final_process_check(p_person_id, l_legislation_code, 12, result_tbl);

    ELSIF (l_legislation_code = 'KW') THEN

			pay_final_process_check(p_person_id, l_legislation_code, 12, result_tbl);

    ELSIF (l_legislation_code = 'NL') THEN

			pay_final_process_check(p_person_id, l_legislation_code, 84, result_tbl);

    ELSIF (l_legislation_code = 'NO') THEN

			pay_final_process_check(p_person_id, l_legislation_code, 12, result_tbl);

    ELSIF (l_legislation_code = 'PL') THEN

			pay_final_process_check(p_person_id, l_legislation_code, 120, result_tbl);

    ELSIF (l_legislation_code = 'RU') THEN

			pay_final_process_check(p_person_id, l_legislation_code, 900, result_tbl);

    ELSIF (l_legislation_code = 'SA') THEN

			pay_final_process_check(p_person_id, l_legislation_code, 12, result_tbl);

    ELSIF (l_legislation_code = 'SE') THEN

			pay_final_process_check(p_person_id, l_legislation_code, 12, result_tbl);

    ELSIF (l_legislation_code = 'ZA') THEN

			pay_final_process_check(p_person_id, l_legislation_code, 60, result_tbl);

    ELSIF (l_legislation_code = 'IE') THEN

			pay_final_process_check(p_person_id, l_legislation_code, 84, result_tbl);

    ELSIF (l_legislation_code = 'RO') THEN

			pay_final_process_check(p_person_id, l_legislation_code, 12, result_tbl);

    ELSIF (l_legislation_code = 'GB') THEN

			pay_final_process_check(p_person_id, l_legislation_code, 72, result_tbl);

    END IF;

    write_log ('Leaving:'|| l_proc,999);

END pay_emea_hr_drc;
--
PROCEDURE pay_final_process_check
    (p_person_id       IN         number
    ,p_legislation_code IN varchar2
    ,p_constraint_months IN number
    ,result_tbl OUT NOCOPY per_drt_pkg.result_tbl_type) IS

	  CURSOR csr_get_termination_date (c_person_id    IN number) IS
	    SELECT   nvl (final_process_date, to_date ('31-12-4712', 'dd-mm-yyyy'))
			FROM    per_periods_of_service
			WHERE   person_id = c_person_id
	    ORDER BY date_start DESC;


--Cursor to check if Employment Certification report has been run
   CURSOR csr_get_emp_cert_rep_val (c_person_id    IN number) IS
		SELECT  1
		FROM    pay_assignment_actions paa
		      , pay_payroll_actions ppa
		      , pay_action_information pai
		WHERE   paa.payroll_action_id = ppa.payroll_action_id
		AND     pai.action_context_id = paa.assignment_action_id
		AND     pai.assignment_id = paa.assignment_id
		AND     pai.action_information_category = 'HU_EMP_CERTIFICATION'
		AND     pai.action_context_type = 'AAP'	    -- new conditions
		AND     ppa.report_type = 'HU_EMP_CERT'
		AND     ppa.action_type = 'X'
		AND     ppa.action_status = 'C'
		AND     paa.assignment_id IN
		        (
		        SELECT  paaf.assignment_id
		        FROM    per_all_assignments_f paaf
		        WHERE   paaf.person_id = c_person_id
		        )
    ORDER BY 1;

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
	 	l_report_run_flag    NUMBER  := 0; -- 0 means the Employment Certificate process is run
BEGIN
    l_success:=TRUE;
    l_proc := l_package|| 'pay_final_process_check';
    write_log ('Entering:'|| l_proc,10);

    l_person_id := p_person_id;
    write_log ('l_person_id: '|| l_person_id,20);

    l_legislation_code := p_legislation_code;
    write_log ('l_legislation_code: '|| l_legislation_code, 20);

    l_constraint_months :=  p_constraint_months;


	    OPEN csr_get_termination_date (p_person_id);

	    FETCH csr_get_termination_date
	      INTO    l_fpd;

	    CLOSE csr_get_termination_date;

	    write_log ('Final Process Date: '
	               || l_fpd, 20);
		IF (l_legislation_code = 'ZA') THEN
	  BEGIN
	    l_month := extract (month FROM l_fpd) ;

	    write_log ('l_month: '
	               || l_month, 20);

	    IF (l_month > 2) THEN
	      SELECT  count (*)
	      INTO    l_count
	      FROM    per_periods_of_service
	      WHERE   person_id = l_person_id
	      AND     add_months (to_date ('28-02-'
	                                   || (extract (year FROM nvl (l_fpd, to_date ('31-12-4712', 'DD-MM-YYYY'))) ), 'dd-mm-yyyy'), l_constraint_months + 12) > sysdate;

	      IF nvl(l_count,0) <> 0 THEN
	        l_success:=FALSE;
	        add_to_results
	                        (person_id   => p_person_id
	                       , entity_type => 'HR'
	                       , status      => 'W'
	                       , msgcode     => 'HR_500500_EMEA_DRC_REP_PRD'
	                       , msgaplid    => 800
	                       , result_tbl  => result_tbl );
	      END IF;
	    ELSE
	      SELECT  count (*)
	      INTO    l_count
	      FROM    per_periods_of_service
	      WHERE   person_id = l_person_id
	      AND     add_months (to_date ('28-02-'
	                                   || (extract (year FROM nvl (l_fpd, to_date ('31-12-4712', 'DD-MM-YYYY'))) ), 'dd-mm-yyyy'), l_constraint_months) > sysdate;

	      IF nvl(l_count,0) <> 0 THEN
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
	ELSIF (l_legislation_code = 'GB') THEN
	  BEGIN
	    OPEN csr_get_termination_date (p_person_id);

	    FETCH csr_get_termination_date
	      INTO    l_fpd;
	    CLOSE csr_get_termination_date;

	    write_log ('Final Process Date: '
	               || l_fpd, 20);

	    l_month := extract (month FROM l_fpd) ;

	    l_day := extract (day FROM l_fpd) ;

	    write_log ('l_month: '
	               || l_month, 20);

	    IF (l_month > 4
	       AND l_day > 5) THEN
	      SELECT  count (*)
	      INTO    l_count
	      FROM    per_periods_of_service
	      WHERE   person_id = l_person_id
	      AND     add_months (to_date ('06-04-'
	                                   || (extract (year FROM nvl (l_fpd, to_date ('31-12-4712', 'DD-MM-YYYY'))) ), 'dd-mm-yyyy'), l_constraint_months + 12) > sysdate;

	      IF nvl(l_count,0) <> 0 THEN
	        l_success:=FALSE;
	        add_to_results
	                        (person_id   => p_person_id
	                       , entity_type => 'HR'
	                       , status      => 'W'
	                       , msgcode     => 'HR_500500_EMEA_DRC_REP_PRD'
	                       , msgaplid    => 800
	                       , result_tbl  => result_tbl );
	      END IF;
	    ELSE
	      SELECT  count (*)
	      INTO    l_count
	      FROM    per_periods_of_service
	      WHERE   person_id = l_person_id
	      AND     add_months (to_date ('05-04-'
	                                   || (extract (year FROM nvl (l_fpd, to_date ('31-12-4712', 'DD-MM-YYYY'))) ), 'dd-mm-yyyy'), l_constraint_months) > sysdate;

	      IF nvl(l_count,0) <> 0 THEN
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
	ELSE
	  BEGIN
	    SELECT  count (*)
	    INTO    l_count
	    FROM    per_periods_of_service
	    WHERE   person_id = l_person_id
	    AND     add_months (to_date ('31-12-'
	                                 || (extract (year FROM nvl (l_fpd, to_date ('31-12-4712', 'DD-MM-YYYY'))) ), 'dd-mm-yyyy'), l_constraint_months) > sysdate;
	  IF l_legislation_code = 'HU' THEN
		  OPEN csr_get_emp_cert_rep_val (l_person_id);
	 	  FETCH csr_get_emp_cert_rep_val INTO l_report_run_flag;

	 	  IF nvl(l_count,0) <> 0 OR csr_get_emp_cert_rep_val%NOTFOUND THEN
		        l_success:=FALSE;
		        add_to_results
		                        (person_id   => p_person_id
		                       , entity_type => 'HR'
		                       , status      => 'W'
		                       , msgcode     => 'HR_500500_EMEA_DRC_REP_PRD'
		                       , msgaplid    => 800
		                       , result_tbl  => result_tbl );
		      END IF;
	 	  CLOSE csr_get_emp_cert_rep_val;
	  ELSE
	    IF nvl(l_count,0) <> 0 THEN
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
--Post Processor Function
--
--NO POST Processing required. Returning Sucess for all scenarios
--
PROCEDURE pay_emea_hr_post
  (p_person_id IN number) IS

  l_proc varchar2(72) DEFAULT 'pay_emea_hr_post';
  l_person_id number;
  l_legislation_code varchar2(20);

BEGIN

  l_proc := l_package|| l_proc;
  write_log ('Post Processor: '|| l_proc, 10);

	l_person_id := p_person_id;
  write_log ('l_person_id: '|| l_person_id,20);

  l_legislation_code := per_per_bus.return_legislation_code (p_person_id);
  write_log ('l_legislation_code: '|| l_legislation_code, 20);


BEGIN

	IF (l_legislation_code = 'ZA' OR l_legislation_code = 'AE' OR l_legislation_code = 'SA' OR l_legislation_code = 'KW' OR
      l_legislation_code = 'NL' OR l_legislation_code = 'NO' OR l_legislation_code = 'IE' OR l_legislation_code = 'DK' ) THEN

 hr_utility.trace('Deleting ff_archive_item_contexts ... ');

            DELETE
            FROM    ff_archive_item_contexts
            WHERE   archive_item_id IN
                (
              SELECT  fai.archive_item_id
              FROM    ff_archive_items fai
                     ,pay_assignment_actions paa
                     ,per_all_assignments_f paaf
              WHERE   paaf.person_id = l_person_id
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
		              , per_all_assignments_f paf
		        WHERE   paa.assignment_id = paf.assignment_id
		        AND     paf.person_id = l_person_id
		        );
		--AND     pay_drt.additional_filter (l_person_id, 'FF_ARCHIVE_ITEMS'
		 --                                , rowid) = 'Y';
             hr_utility.trace('Deleted records  count from  ff_archive_items ' ||sql%rowcount);
  END IF;

         EXCEPTION
          WHEN OTHERS THEN

                 hr_utility.trace('Error encountered. Below are details.');
                 hr_utility.trace('SQL Code    : '||SQLCODE);
                 hr_utility.trace('SQL Message : '||SQLERRM);
                 RAISE;

       END;

END pay_emea_hr_post;
--
--

END PAY_EMEA_DRT_PKG;


/
