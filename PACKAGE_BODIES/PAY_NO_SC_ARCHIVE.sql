--------------------------------------------------------
--  DDL for Package Body PAY_NO_SC_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NO_SC_ARCHIVE" as
/* $Header: pynosfca.pkb 120.0.12000000.1 2007/05/20 09:27:43 rlingama noship $ */
	 TYPE lock_rec IS RECORD (
	      archive_assact_id    NUMBER);
	 TYPE lock_table      IS TABLE OF  lock_rec      INDEX BY BINARY_INTEGER;
	 g_debug   boolean   :=  hr_utility.debug_enabled;
	 g_lock_table   		          lock_table;
	 g_package           VARCHAR2(50) := ' PAY_NO_SC_ARCHIVE.';
	 g_business_group_id NUMBER;
	 g_legal_employer_id NUMBER;
	 g_employee_id NUMBER;
	 g_effective_date DATE;
	 g_archive  VARCHAR2(50);
	 g_err_num NUMBER;
	 g_errm VARCHAR2(150);
	 /* GET PARAMETER */
	 FUNCTION GET_PARAMETER(
		 p_parameter_string IN VARCHAR2
		,p_token            IN VARCHAR2
		,p_segment_number   IN NUMBER default NULL ) RETURN VARCHAR2
	 IS
		   l_parameter  pay_payroll_actions.legislative_parameters%TYPE:=NULL;
		   l_start_pos  NUMBER;
		   l_delimiter  VARCHAR2(1):=' ';
		   l_proc VARCHAR2(240):= g_package||' get parameter ';
	BEGIN

		 IF g_debug THEN
			hr_utility.set_location(' Entering Function GET_PARAMETER',10);
		 END IF;
		 l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
		 --
		 IF l_start_pos = 0 THEN
			l_delimiter := '|';
			l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
		 END IF;
		 IF l_start_pos <> 0 THEN
			l_start_pos := l_start_pos + length(p_token||'=');
			l_parameter := substr(p_parameter_string,
			l_start_pos,
			instr(p_parameter_string||' ',
			l_delimiter,l_start_pos)
			- l_start_pos);
			 IF p_segment_number IS NOT NULL THEN
				l_parameter := ':'||l_parameter||':';
				l_parameter := substr(l_parameter,
				instr(l_parameter,':',1,p_segment_number)+1,
				instr(l_parameter,':',1,p_segment_number+1) -1
				- instr(l_parameter,':',1,p_segment_number));
			END IF;
		END IF;
		--
		IF g_debug THEN
			hr_utility.set_location(' Leaving Function GET_PARAMETER',20);
		END IF;
		RETURN l_parameter;
	 END;
	/* GET ALL PARAMETERS */
	PROCEDURE GET_ALL_PARAMETERS(
        p_payroll_action_id         IN   NUMBER
       ,p_business_group_id         OUT  NOCOPY NUMBER
       ,p_legal_employer_id	    OUT  NOCOPY  NUMBER
       ,p_employee		    OUT  NOCOPY  NUMBER
       ,p_archive		    OUT NOCOPY VARCHAR2
       ,p_effective_date            OUT NOCOPY DATE
       	) IS
		CURSOR csr_parameter_info(p_payroll_action_id NUMBER) IS
		SELECT PAY_NO_ARC_HOLIDAY_ENTITLEMENT.GET_PARAMETER(legislative_parameters,
		'LEGAL_EMPLOYER')
		,PAY_NO_ARC_HOLIDAY_ENTITLEMENT.GET_PARAMETER(legislative_parameters,'EMPLOYEEID')
		,PAY_NO_ARC_HOLIDAY_ENTITLEMENT.GET_PARAMETER(legislative_parameters,'ARCHIVE')
		,effective_date
		,business_group_id
		FROM  pay_payroll_actions
		WHERE payroll_action_id = p_payroll_action_id;
		l_proc VARCHAR2(240):= g_package||' GET_ALL_PARAMETERS ';
		--
	BEGIN
	fnd_file.put_line (fnd_file.LOG, 'Entering Get all Parameters' );
		 OPEN csr_parameter_info (p_payroll_action_id);
		 FETCH csr_parameter_info
		 INTO	 p_legal_employer_id
			,p_employee
			,p_archive
			,p_effective_date
			,p_business_group_id;
		 CLOSE csr_parameter_info;
		 --
		 IF g_debug THEN
		      hr_utility.set_location(' Leaving Procedure GET_ALL_PARAMETERS',30);
		 END IF;
	 END GET_ALL_PARAMETERS;

	/* RANGE CODE */
	PROCEDURE RANGE_CODE (p_payroll_action_id    IN    NUMBER
			     ,p_sql    OUT   NOCOPY VARCHAR2)
	IS

	 l_ovn	NUMBER;
	 l_action_info_id NUMBER;

        BEGIN


			 IF g_debug THEN
				hr_utility.set_location(' Entering Procedure RANGE_CODE',10);
		         END IF;



			     PAY_NO_SC_ARCHIVE.GET_ALL_PARAMETERS( p_payroll_action_id
								,g_business_group_id
								,g_legal_employer_id
								,g_employee_id
								,g_archive
								,g_effective_date
								);


		   /** Insert report parameters                  **/
			    pay_action_information_api.create_action_information (
					p_action_information_id	=> l_action_info_id,
					p_action_context_id	=> p_payroll_action_id,
					p_action_context_type	=> 'PA',
					p_object_version_number	=> l_ovn,
					p_effective_date	=> g_effective_date,
					p_source_id		=> NULL,
					p_source_text		=> NULL,
					p_action_information_category=> 'EMEA REPORT DETAILS',
					p_action_information1	=> 'PYNOSFCA',
					p_action_information2	=> g_legal_employer_id,
					p_action_information3	=> g_employee_id,
					p_action_information4	=> fnd_date.date_to_canonical(g_effective_date));


				 p_sql := 'SELECT DISTINCT person_id
					     FROM  per_people_f ppf
					     ,pay_payroll_actions ppa
					     WHERE ppa.payroll_action_id = :payroll_action_id
					     AND   ppa.business_group_id = ppf.business_group_id
					     ORDER BY ppf.person_id';


				hr_utility.set_location(' Leaving Procedure RANGE_CODE',50);


			EXCEPTION
				WHEN OTHERS THEN
				hr_utility.set_location('Exception****',70);
				-- Return cursor that selects no rows
				p_sql := 'select 1 from dual where to_char(:payroll_action_id) = dummy';
	END RANGE_CODE;

	 /* ASSIGNMENT ACTION CODE   PAY_NO_ARC_HOLIDAY_ENTITLEMENT.ASSIGNMENT_ACTION_CODE	 */

	 PROCEDURE ASSIGNMENT_ACTION_CODE
	 (p_payroll_action_id     IN NUMBER
	 ,p_start_person          IN NUMBER
	 ,p_end_person            IN NUMBER
	 ,p_chunk                 IN NUMBER)
	 IS

	 l_actid number;
	 l_start_date date;
	 l_end_date date;
	   /****** Start Of Cursor ******/

	   CURSOR csr_action_creation(csr_v_business_group_id NUMBER,
	   				csr_v_legal_employer_id NUMBER,
	   				csr_v_effective_date DATE,
	   				csr_v_start_date DATE,
	   				csr_v_end_date DATE,
	   				csr_v_person_id NUMBER
	   				)
	   IS
	   SELECT paaf.assignment_id
	   FROM per_all_people_f papf,
	     per_all_assignments_f paaf,
	     per_assignment_status_types past,
	     hr_soft_coding_keyflex hsc,
	     hr_organization_information hoi
	   WHERE paaf.person_id = papf.person_id
	    AND papf.person_id = nvl(csr_v_person_id,papf.person_id)
	    AND paaf.assignment_status_type_id = past.assignment_status_type_id
	    AND papf.business_group_id = csr_v_business_group_id
	    AND hsc.soft_coding_keyflex_id = paaf.soft_coding_keyflex_id
	    AND hoi.org_information1 = hsc.segment2
	    AND hoi.organization_id = csr_v_legal_employer_id
	    AND hoi.org_information_context = 'NO_LOCAL_UNITS'
	    AND past.per_system_status in ('ACTIVE_ASSIGN','SUSP_ASSIGN')
	    AND papf.person_id BETWEEN p_start_person and p_end_person
	    AND csr_v_effective_date BETWEEN papf.effective_start_date
	    AND papf.effective_end_date
	    AND csr_v_effective_date BETWEEN paaf.effective_start_date
 	    AND paaf.effective_end_date
 	    AND EXISTS(select paa.absence_attendance_id from per_absence_attendances paa, per_absence_attendance_types paat
                        where paa.person_id = papf.person_id
                        and  paa.absence_attendance_type_id = paat.absence_attendance_type_id
                        and paat.absence_category in ('CMS','S','PTS')
                        and paa.abs_information1 = 'SC'
                        and paa.date_start between csr_v_start_date and csr_v_end_date
                        and paa.date_end between csr_v_start_date and csr_v_end_date );



	   /**** End Of Cursor  ****/

	 BEGIN



			PAY_NO_SC_ARCHIVE.GET_ALL_PARAMETERS( p_payroll_action_id
							  ,g_business_group_id
							  ,g_legal_employer_id
							  ,g_employee_id
							  ,g_archive
							  ,g_effective_date
					 		    );

		l_start_date := add_months(g_effective_date,-12);
		l_end_date   := g_effective_date;


		FOR csr_act IN csr_action_creation(g_business_group_id,g_legal_employer_id,g_effective_date,l_start_date,l_end_date,g_employee_id)
		LOOP

			SELECT pay_assignment_actions_s.NEXTVAL
			INTO l_actid
			FROM DUAL;

			hr_nonrun_asact.insact (l_actid,
						csr_act.assignment_id,
						p_payroll_action_id,
						p_chunk,
						g_business_group_id
						);
		END LOOP;

		IF g_debug THEN
			hr_utility.set_location(' Entering Procedure ASSIGNMENT_ACTION_CODE',60);
		END IF;
		 IF g_debug THEN
		      hr_utility.set_location(' Leaving Procedure ASSIGNMENT_ACTION_CODE',70);
		 END IF;
--		 	 fnd_file.put_line (fnd_file.LOG, 'Exiting Assignment Action Code' );


	END ASSIGNMENT_ACTION_CODE;
	 /* INITIALIZATION CODE */
	 PROCEDURE INITIALIZATION_CODE(p_payroll_action_id IN NUMBER)
	 IS
	 BEGIN
	-- fnd_file.put_line (fnd_file.LOG, 'Entering Initialization Code' );
	 hr_utility.set_location(' Entering Procedure INITIALIZATION_CODE',80);



	  hr_utility.set_location(' Leaving Procedure INITIALIZATION_CODE',90);

		--  fnd_file.put_line (fnd_file.LOG, 'Existing Initialization Code' );
		 EXCEPTION WHEN OTHERS THEN
		 g_err_num := SQLCODE;
		 IF g_debug THEN
		      hr_utility.set_location(' Err Procedure INITIALIZATION_CODE',110);
		      hr_utility.set_location('ORA_ERR: ' || g_err_num ||
		      'In INITIALIZATION_CODE',180);
		 END IF;
	 fnd_file.put_line (fnd_file.LOG, 'Error in Initialization Code' );
	 END INITIALIZATION_CODE;
 	 /* ARCHIVE CODE */
	PROCEDURE ARCHIVE_CODE(p_assignment_action_id IN NUMBER
			      ,p_effective_date    IN DATE)
	IS


	l_start_date date;
	l_end_date date;
	l_arch_ovn number;
	l_arch_action_info_id number;

	/*** Start of  Cursor ***/
		 Cursor csr_self_certificate(csr_v_business_group_id NUMBER,
		 				csr_v_legal_employer_id NUMBER,
		 				csr_v_effective_date DATE,
		 				csr_v_start_date DATE,
		 				csr_v_end_date DATE,
		 				csr_v_person_id NUMBER
		 				) is
		 	select papf.employee_number,
		 	       papf.full_name,
			       paaf.assignment_id,
			       count(paa.abs_information1) sc_days
			from   per_absence_attendances paa,
			       per_absence_attendance_types paat,
			       per_all_assignments_f paaf,
			       per_assignment_status_types past,
			       pay_assignment_actions paas,
			       per_all_people_f papf,
			       hr_soft_coding_keyflex  hsc,
			       hr_organization_information hoi
			where paas.assignment_action_id = p_assignment_action_id
			and paa.person_id = papf.person_id
			AND papf.person_id = nvl(csr_v_person_id,papf.person_id)
			and  paa.absence_attendance_type_id = paat.absence_attendance_type_id
			and  paaf.person_id = papf.person_id
			AND paaf.assignment_status_type_id = past.assignment_status_type_id
			and paaf.assignment_id = paas.assignment_id
			and papf.business_group_id = csr_v_business_group_id
			and hsc.soft_coding_keyflex_id = paaf.soft_coding_keyflex_id
			and hoi.org_information1 = hsc.segment2
			and hoi.organization_id = csr_v_legal_employer_id
			AND past.per_system_status in ('ACTIVE_ASSIGN','SUSP_ASSIGN')
			and hoi.ORG_INFORMATION_CONTEXT = 'NO_LOCAL_UNITS'
			and paaf.primary_flag = 'Y'
			and paat.absence_category in ('CMS','S','PTS')
			and paa.abs_information1 = 'SC'
			and paa.date_start between csr_v_start_date and csr_v_end_date
			and paa.date_end between csr_v_start_date and csr_v_end_date
			and csr_v_effective_date between papf.effective_start_date and papf.effective_end_date
			and csr_v_effective_date between paaf.effective_start_date and paaf.effective_end_date
			group by papf.employee_number,papf.full_name,paaf.assignment_id;


	 		/**** End of Cursor ***/

	BEGIN
	fnd_file.put_line (fnd_file.LOG, 'entering archive code' );


		l_start_date := trunc(p_effective_date,'YY');
		l_end_date   := last_day(add_months(l_start_date,11));

		FOR csr_he IN csr_self_certificate(g_business_group_id,g_legal_employer_id,p_effective_date,l_start_date,l_end_date,g_employee_id)
		LOOP


			pay_action_information_api.create_action_information (
			    p_action_context_id=> p_assignment_action_id,
			    p_action_context_type=> 'AAP',
			    p_action_information_category=> 'EMEA REPORT INFORMATION',
			    p_assignment_id	   => csr_he.assignment_id,
			    p_action_information1  => 'PYNOSFCA',
			    p_action_information2  => csr_he.employee_number,
			    p_action_information3  => csr_he.full_name,
			    p_action_information4  => csr_he.sc_days,
			    p_action_information_id=> l_arch_action_info_id,
			    p_object_version_number=> l_arch_ovn);
		END LOOP;

		 IF g_debug THEN
				hr_utility.set_location(' Entering Procedure ARCHIVE_CODE',80);
		 END IF;
		 IF g_debug THEN
				hr_utility.set_location(' Leaving Procedure ARCHIVE_CODE',90);
		 END IF;
    fnd_file.put_line (fnd_file.LOG, 'Exiting archive code' );
	END ARCHIVE_CODE;
 END PAY_NO_SC_ARCHIVE;

/
