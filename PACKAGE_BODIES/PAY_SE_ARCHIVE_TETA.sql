--------------------------------------------------------
--  DDL for Package Body PAY_SE_ARCHIVE_TETA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SE_ARCHIVE_TETA" AS
 /* $Header: pyseteta.pkb 120.0.12000000.1 2007/07/11 12:30:00 dbehera noship $ */

	 TYPE lock_rec IS RECORD (
	      archive_assact_id    NUMBER);

	 TYPE lock_table      IS TABLE OF  lock_rec      INDEX BY BINARY_INTEGER;

	 g_debug   boolean	:=	hr_utility.debug_enabled;
	 g_lock_table   		lock_table;
	 g_index			NUMBER := -1;
	 g_index_assact			NUMBER := -1;
	 g_index_bal			NUMBER := -1;
	 g_package			VARCHAR2(33) := ' PAY_SE_ARCHIVE_TETA.';
	 g_archive			VARCHAR2(1);
	 g_effective_date		DATE;
 	 g_date_report			DATE;
	 g_person_id			NUMBER ;
	 g_business_group_id		NUMBER ;
	 g_payroll_action_id		NUMBER ;



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
	 --
	 --fnd_file.put_line(fnd_file.log,'Range Code 23'||p_token);
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

	 --fnd_file.put_line(fnd_file.log,'Range Code 24');
		RETURN l_parameter;

	 END;

	/* GET ALL PARAMETERS */
	PROCEDURE GET_ALL_PARAMETERS
		(
		p_payroll_action_id			IN	NUMBER
    		,p_business_group_id		OUT  NOCOPY	NUMBER
		,p_person_id		                OUT  NOCOPY	NUMBER
		,p_date_report	                        OUT  NOCOPY	DATE
		,p_effective_date                         OUT  NOCOPY	DATE
		,p_archive					OUT  NOCOPY	VARCHAR2
		) IS

		CURSOR csr_parameter_info(p_payroll_action_id NUMBER) IS
		SELECT PAY_SE_ARCHIVE_TETA.GET_PARAMETER(legislative_parameters,'PERSON_ID')
		,fnd_date.canonical_to_date(PAY_SE_ARCHIVE_TETA.GET_PARAMETER(legislative_parameters,'DATE_REPORT'))
		,PAY_SE_ARCHIVE_TETA.GET_PARAMETER(legislative_parameters,'ARCHIVE')
		,effective_date
		,business_group_id
		FROM  pay_payroll_actions
		WHERE payroll_action_id = p_payroll_action_id;
		l_proc VARCHAR2(240):= g_package||' GET_ALL_PARAMETERS ';
		--
	BEGIN

	--fnd_file.put_line(fnd_file.log,'Range Code 21'||TO_CHAR(p_payroll_action_id));

		 OPEN csr_parameter_info (p_payroll_action_id);

		 FETCH csr_parameter_info
		 INTO	p_person_id
				,p_date_report
				,p_archive
				,p_effective_date
				,p_business_group_id;
		 CLOSE csr_parameter_info;

		 	--fnd_file.put_line(fnd_file.log,'Range Code 22');
		 --
		 IF g_debug THEN
		      hr_utility.set_location(' Leaving Procedure GET_ALL_PARAMETERS',30);
		 END IF;
		 --fnd_file.put_line(fnd_file.log,'Range Code 22222');
	 END GET_ALL_PARAMETERS;

	/* RANGE CODE */
	PROCEDURE RANGE_CODE (p_payroll_action_id    IN    NUMBER
			     ,p_sql    OUT   NOCOPY VARCHAR2)
	IS


			l_action_info_id NUMBER;
			l_ovn NUMBER;
			l_count NUMBER;

			/* Cursors */

			CURSOR csr_person_details
			( csr_v_person_id  NUMBER
			, csr_v_effective_date  DATE )
			IS
			SELECT  *
			FROM  per_all_people_f  ppf
			WHERE ppf.person_id = csr_v_person_id
			AND csr_v_effective_date BETWEEN ppf.effective_start_date
			AND ppf.effective_end_date;


	     /* End of Cursors */

		BEGIN

			 IF g_debug THEN
				hr_utility.set_location(' Entering Procedure RANGE_CODE',40);
			 END IF;

			 p_sql := 'SELECT DISTINCT person_id
			FROM  per_people_f ppf
			,pay_payroll_actions ppa
			WHERE ppa.payroll_action_id = :payroll_action_id
			AND   ppa.business_group_id = ppf.business_group_id
			AND ROWNUM < 2
			ORDER BY ppf.person_id';

			g_archive := NULL;
			g_date_report   := NULL ;
			g_effective_date   := NULL ;
			g_person_id   := NULL ;
			g_payroll_action_id := p_payroll_action_id ;

			--fnd_file.put_line(fnd_file.log,'InsideRange Code');

			 PAY_SE_ARCHIVE_TETA.GET_ALL_PARAMETERS(
			p_payroll_action_id
			,g_business_group_id
			,g_person_id
			,g_date_report
			,g_effective_date
			,g_archive ) ;

			IF  g_archive = 'Y' THEN

				--fnd_file.put_line(fnd_file.log,'Inside Range Code Archive');
				SELECT count(*)
				INTO l_count
				FROM   pay_action_information
				WHERE  action_information_category = 'EMEA REPORT DETAILS'
				AND    action_information1             = 'PYSETETA'
				AND    action_context_id           = p_payroll_action_id;

				IF l_count < 1  then

					--fnd_file.put_line(fnd_file.log,'Range Code Count');
					FOR person_rec IN  csr_person_details( g_person_id  , g_date_report  )
					LOOP

						--fnd_file.put_line(fnd_file.log,'Range Code LOOP');
						pay_action_information_api.create_action_information (
						p_action_information_id        => l_action_info_id
						,p_action_context_id            => p_payroll_action_id
						,p_action_context_type          => 'PA'
						,p_object_version_number        => l_ovn
						,p_effective_date               => g_effective_date
						,p_source_id                    => NULL
						,p_source_text                  => NULL
						,p_action_information_category  => 'EMEA REPORT DETAILS'
						,p_action_information1          => 'PYSETETA'
						,p_action_information2          => g_person_id
						,p_action_information3          => person_rec.full_name
						,p_action_information4          => person_rec.national_identifier
						,p_action_information5          => person_rec.employee_number
						,p_action_information6          => g_date_report
						,p_action_information7          => null
						,p_action_information8          => null
						,p_action_information9          => null
						,p_action_information10          => null
						,p_action_information11          => null
						,p_action_information12          => null
						,p_action_information13          => null
						,p_action_information14          => null
						,p_action_information15          => null
						,p_action_information16          => null
						,p_action_information17          => null
						,p_action_information18          => null
						,p_action_information19          => null
						,p_action_information20          => null
						,p_action_information21          => null
						,p_action_information22          => null
						,p_action_information23          => null
						,p_action_information24          => null
						,p_action_information25          => null
						,p_action_information26          => null
						,p_action_information27          => null
						,p_action_information28          => null
						,p_action_information29          =>  null
						,p_action_information30          =>  null );

					END LOOP;

				END IF;

			END IF;

			IF g_debug THEN
				hr_utility.set_location(' Leaving Procedure RANGE_CODE',50);
			END IF;
				EXCEPTION
					WHEN others THEN
						IF g_debug THEN
							hr_utility.set_location('error raised assignment_action_code ',5);
						END if;
						RAISE;
		END RANGE_CODE;

	 /* ASSIGNMENT ACTION CODE */
	 PROCEDURE ASSIGNMENT_ACTION_CODE
	 (p_payroll_action_id     IN NUMBER
	 ,p_start_person          IN NUMBER
	 ,p_end_person            IN NUMBER
	 ,p_chunk                 IN NUMBER)
	 IS

		CURSOR csr_person_assignments
		( csr_v_person_id  NUMBER
		,csr_v_business_group_id  NUMBER
		, csr_v_effective_date  DATE )
		IS
		SELECT assign.assignment_id
		FROM
		per_all_assignments_f             assign
		,hr_soft_coding_keyflex		scl
		,hr_organization_units		o1
		,hr_organization_information	hoi1
		,hr_organization_information	hoi2
		,hr_organization_information	hoi3
		WHERE assign.person_id= csr_v_person_id
		AND assign.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
		AND o1.business_group_id = csr_v_business_group_id
		AND hoi1.organization_id = o1.organization_id
		AND hoi1.organization_id = TO_CHAR(scl.segment2)
		AND hoi1.org_information1 = 'SE_LOCAL_UNIT'
		AND hoi1.org_information_context = 'CLASS'
		AND o1.organization_id = hoi2.org_information1
		AND hoi2.org_information_context='SE_LOCAL_UNITS'
		AND hoi2.organization_id =  hoi3.organization_id
		AND hoi3.org_information_context='CLASS'
		AND hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
		AND primary_flag   ='Y'
                AND assign.effective_start_date < =csr_v_effective_date
		GROUP BY assign.assignment_id;

		 l_prepay_action_id	NUMBER;
		 l_actid NUMBER;
		 l_assignment_id NUMBER;
		 l_action_sequence NUMBER;
		 l_assact_id     NUMBER;
		 l_pact_id NUMBER;
		 l_flag NUMBER := 0;
		 l_action_info_id NUMBER;
		 l_ovn NUMBER;
	 BEGIN
			IF g_debug THEN
				hr_utility.set_location(' Entering Procedure ASSIGNMENT_ACTION_CODE',60);
			END IF;

			--fnd_file.put_line(fnd_file.log,'Assignment Action Code');

			PAY_SE_ARCHIVE_TETA.GET_ALL_PARAMETERS(
			p_payroll_action_id
			,g_business_group_id
			,g_person_id
			,g_date_report
			,g_effective_date
			,g_archive ) ;

			g_payroll_action_id :=p_payroll_action_id;

			FOR person_assignments_rec IN csr_person_assignments( g_person_id, g_business_group_id, g_date_report)
				LOOP

					--fnd_file.put_line(fnd_file.log,'Assignment Action Code Loop');

					SELECT pay_assignment_actions_s.NEXTVAL
					INTO   l_actid
					FROM   dual;
					  --
					g_index_assact := g_index_assact + 1;
					g_lock_table(g_index_assact).archive_assact_id := l_actid; /* For Element archival */
				       -- Create the archive assignment action
					hr_nonrun_asact.insact(l_actid
					,person_assignments_rec.assignment_id
					,p_payroll_action_id
					,p_chunk
					,NULL);
					-- Create archive to prepayment assignment action interlock
					--
					--hr_nonrun_asact.insint(l_actid,rec_prepaid_assignments.prepaid_action_id);

				END LOOP;

		 IF g_debug THEN
		      hr_utility.set_location(' Leaving Procedure ASSIGNMENT_ACTION_CODE',70);
		 END IF;
	EXCEPTION
	  WHEN others THEN
		IF g_debug THEN
		    hr_utility.set_location('error raised assignment_action_code ',5);
		END if;
	    RAISE;

	END ASSIGNMENT_ACTION_CODE;
	 /* INITIALIZATION CODE */
	 PROCEDURE INITIALIZATION_CODE(p_payroll_action_id IN NUMBER)
	 IS

	 BEGIN
		 IF g_debug THEN
		      hr_utility.set_location(' Entering Procedure INITIALIZATION_CODE',80);
		 END IF;

	    	  IF g_debug THEN
		      hr_utility.set_location(' Leaving Procedure INITIALIZATION_CODE',90);
		 END IF;

	EXCEPTION
	  WHEN others THEN
		IF g_debug THEN
		    hr_utility.set_location('error raised initialization code ',5);
		END if;
	    RAISE;
	 END INITIALIZATION_CODE;

 	 /* ARCHIVE CODE */
	 PROCEDURE ARCHIVE_CODE(p_assignment_action_id IN NUMBER
			      ,p_effective_date    IN DATE)
	 IS


		/* Cursor to retrieve Person Current Employment Time Details */
		CURSOR csr_person_teta
		( csr_v_assign_id  NUMBER
		,csr_v_person_id  NUMBER
		,csr_v_business_group_id  NUMBER
		, csr_v_effective_date  DATE )
		IS
		SELECT assign.assignment_id
		 ,hoi3.organization_id, assign.employment_category
		 , trunc(assign.effective_start_date) effective_start_date
		,trunc(decode(assign.effective_end_date,to_date('31/12/4712','dd/mm/yyyy'), g_date_report ,assign.effective_end_date) ) effective_end_date
		FROM
		per_all_assignments_f             assign
		,hr_soft_coding_keyflex		scl
		,hr_organization_units		o1
		,hr_organization_information	hoi1
		,hr_organization_information	hoi2
		,hr_organization_information	hoi3
		WHERE assign.assignment_id = csr_v_assign_id
		AND assign.person_id = csr_v_person_id
		AND assign.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
		AND o1.business_group_id = csr_v_business_group_id
		AND hoi1.organization_id = o1.organization_id
		AND hoi1.organization_id = TO_CHAR(scl.segment2)
		AND hoi1.org_information1 = 'SE_LOCAL_UNIT'
		AND hoi1.org_information_context = 'CLASS'
		AND o1.organization_id = hoi2.org_information1
		AND hoi2.org_information_context='SE_LOCAL_UNITS'
		AND hoi2.organization_id =  hoi3.organization_id
		AND hoi3.org_information_context='CLASS'
		AND hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
		AND primary_flag   ='Y'
                AND assign.effective_start_date < =csr_v_effective_date
		ORDER BY assign.effective_start_date DESC;


		/* Cursor to retrieve Person Current Employment Time Summary Details */
		CURSOR csr_person_sum_teta
		( csr_v_assign_id  NUMBER
		, csr_v_person_id  NUMBER
		, csr_v_business_group_id  NUMBER
		, csr_v_effective_date  DATE )
		IS
		SELECT assign.assignment_id
		 ,hoi3.organization_id, assign.employment_category
		,sum(decode(assign.effective_end_date,to_date('31/12/4712','dd/mm/yyyy'), g_date_report ,assign.effective_end_date) - assign.effective_start_date ) days_worked
		FROM
		per_all_assignments_f             assign
		,hr_soft_coding_keyflex		scl
		,hr_organization_units		o1
		,hr_organization_information	hoi1
		,hr_organization_information	hoi2
		,hr_organization_information	hoi3
		WHERE assign.assignment_id = csr_v_assign_id
		AND assign.person_id = csr_v_person_id
		AND assign.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
		AND o1.business_group_id = csr_v_business_group_id
		AND hoi1.organization_id = o1.organization_id
		AND hoi1.organization_id = TO_CHAR(scl.segment2)
		AND hoi1.org_information1 = 'SE_LOCAL_UNIT'
		AND hoi1.org_information_context = 'CLASS'
		AND o1.organization_id = hoi2.org_information1
		AND hoi2.org_information_context='SE_LOCAL_UNITS'
		AND hoi2.organization_id =  hoi3.organization_id
		AND hoi3.org_information_context='CLASS'
		AND hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
		AND primary_flag   ='Y'
                AND assign.effective_start_date < =csr_v_effective_date
		GROUP BY assign.assignment_id ,hoi3.organization_id, assign.employment_category;




		/*Cursor for Employee Typeto Legal Employer*/
		CURSOR csr_emp_name
		(
		csr_v_employer_id  NUMBER
		)
		IS
		SELECT  hou.NAME
		FROM hr_organization_units hou
		WHERE hou.organization_id=csr_v_employer_id;

		rec_emp_name  csr_emp_name%ROWTYPE;


		/* Cursor to retrieve Assignment Category */
		CURSOR csr_emp_catg
		( csr_v_lookup_code  VARCHAR2
		, csr_v_effective_date  DATE )
		IS
		SELECT l.meaning employment_category
		FROM hr_leg_lookups l
		WHERE l.lookup_type = 'EMP_CAT'
		AND l.enabled_flag = 'Y'
		AND l.lookup_code = csr_v_lookup_code
		AND csr_v_effective_date
		BETWEEN nvl(start_date_active,csr_v_effective_date)
		AND nvl(end_date_active,csr_v_effective_date) ;

		rec_emp_catg  csr_emp_catg%ROWTYPE;

		/*Cursor for fetching assignment_id*/
		CURSOR csr_assign_id
		IS
		SELECT  paa.assignment_id
		FROM pay_assignment_actions paa
		WHERE paa.assignment_action_id = p_assignment_action_id;

		l_action_context_id	NUMBER;
		l_flag NUMBER := 0;
		l_action_info_id NUMBER;
 		l_ovn NUMBER;
		l_assign_id NUMBER;


	BEGIN
		 IF g_debug THEN
				hr_utility.set_location(' Entering Procedure ARCHIVE_CODE',380);
		 END IF;

			--fnd_file.put_line(fnd_file.log,'Archive Code');
		IF g_archive='Y' THEN



			BEGIN
				SELECT 1
				INTO l_flag
				FROM pay_action_information
				WHERE action_information_category = 'EMEA REPORT INFORMATION'
				AND action_information1 = 'PYSETETA'
				AND action_information2 = 'PER'
				AND action_context_id = p_assignment_action_id;
				EXCEPTION
					WHEN NO_DATA_FOUND THEN
						OPEN  csr_assign_id;
						FETCH csr_assign_id INTO l_assign_id;
						CLOSE csr_assign_id;

						--fnd_file.put_line(fnd_file.log,'Before Loop Archive Code');

						FOR person_teta_rec IN csr_person_teta( l_assign_id,g_person_id, g_business_group_id, g_date_report)
						LOOP


							--fnd_file.put_line(fnd_file.log,'Inside Loop Archive Code');

							OPEN  csr_emp_catg( person_teta_rec.employment_category, g_date_report);
							FETCH csr_emp_catg INTO rec_emp_catg;
							CLOSE csr_emp_catg;

							OPEN  csr_emp_name(person_teta_rec.organization_id) ;
							FETCH csr_emp_name INTO rec_emp_name;
							CLOSE csr_emp_name;


							pay_action_information_api.create_action_information (
							p_action_information_id=> l_action_info_id,
							p_action_context_id=> p_assignment_action_id,
							p_action_context_type=> 'AAP',
							p_object_version_number=> l_ovn,
							p_effective_date=> g_effective_date,
							p_source_id=> NULL,
							p_source_text=> NULL,
							p_action_information_category=> 'EMEA REPORT INFORMATION',
							p_action_information1=> 'PYSETETA',
							p_action_information2=> g_payroll_action_id,
							p_action_information3=> g_person_id   ,
							p_action_information4=> person_teta_rec.organization_id,
							p_action_information5=> rec_emp_name.name,
							p_action_information6=> person_teta_rec.employment_category ,
							p_action_information7=> rec_emp_catg.employment_category ,
							p_action_information8=>  person_teta_rec.effective_start_date,
							p_action_information9=>  person_teta_rec.effective_end_date,
							p_action_information10=> person_teta_rec.effective_end_date - person_teta_rec.effective_start_date ,
							p_action_information11=>  'CH',
							p_action_information12=> NULL ,
							p_action_information13=> NULL,
							p_action_information14=> NULL,
							p_action_information15=> NULL,
							p_action_information16=> NULL,
							p_action_information17=> NULL,
							p_action_information18=> NULL,
							p_action_information19=> NULL,
							p_action_information20=> NULL,
							p_action_information21=> NULL,
							p_action_information22=> NULL,
							p_action_information23=> NULL,
							p_action_information24=> NULL,
							p_action_information25=> NULL,
							p_action_information26=> NULL,
							p_action_information27=> NULL,
							p_action_information28=> NULL,
							p_action_information29=> NULL,
							p_action_information30=> l_assign_id
							);

						END LOOP;

						FOR person_sum_teta_rec	 IN csr_person_sum_teta( l_assign_id,g_person_id, g_business_group_id, g_date_report)
						LOOP


							--fnd_file.put_line(fnd_file.log,'Inside Loop Archive Code');

							OPEN  csr_emp_catg( person_sum_teta_rec.employment_category, g_date_report);
							FETCH csr_emp_catg INTO rec_emp_catg;
							CLOSE csr_emp_catg;

							OPEN  csr_emp_name(person_sum_teta_rec.organization_id) ;
							FETCH csr_emp_name INTO rec_emp_name;
							CLOSE csr_emp_name;


							pay_action_information_api.create_action_information (
							p_action_information_id=> l_action_info_id,
							p_action_context_id=> p_assignment_action_id,
							p_action_context_type=> 'AAP',
							p_object_version_number=> l_ovn,
							p_effective_date=> g_effective_date,
							p_source_id=> NULL,
							p_source_text=> NULL,
							p_action_information_category=> 'EMEA REPORT INFORMATION',
							p_action_information1=> 'PYSETETA',
							p_action_information2=> g_payroll_action_id,
							p_action_information3=> g_person_id   ,
							p_action_information4=> person_sum_teta_rec.organization_id,
							p_action_information5=> rec_emp_name.name,
							p_action_information6=> person_sum_teta_rec.employment_category ,
							p_action_information7=> rec_emp_catg.employment_category ,
							p_action_information8=> person_sum_teta_rec.days_worked ,
							p_action_information9=>  NULL,
							p_action_information10=> NULL,
							p_action_information11=> 'CS',
							p_action_information12=> NULL ,
							p_action_information13=> NULL,
							p_action_information14=> NULL,
							p_action_information15=> NULL,
							p_action_information16=> NULL,
							p_action_information17=> NULL,
							p_action_information18=> NULL,
							p_action_information19=> NULL,
							p_action_information20=> NULL,
							p_action_information21=> NULL,
							p_action_information22=> NULL,
							p_action_information23=> NULL,
							p_action_information24=> NULL,
							p_action_information25=> NULL,
							p_action_information26=> NULL,
							p_action_information27=> NULL,
							p_action_information28=> NULL,
							p_action_information29=> NULL,
							p_action_information30=> l_assign_id
							);

						END LOOP;

				WHEN OTHERS	 THEN
				    NULL;
			END;
		END IF;---ARCHIVE=YES

		IF g_debug THEN
			hr_utility.set_location(' Leaving Procedure ARCHIVE_CODE',390);
		END IF;

	EXCEPTION
		WHEN others THEN
			IF g_debug THEN
				hr_utility.set_location('error raised in archive code ',5);
			END if;
			RAISE;
 	END ARCHIVE_CODE;


 PROCEDURE DEINITIALIZATION_CODE
    (p_payroll_action_id in pay_payroll_actions.payroll_action_id%type) is


	l_years_worked NUMBER;
	l_days_worked NUMBER;
	l_action_info_id NUMBER;
	l_ovn NUMBER;

	/* Cursor to retrieve Person Previous Employment Time  Details */
		CURSOR csr_person_prev_teta
		( csr_v_person_id  NUMBER
		,csr_v_business_group_id  NUMBER
		, csr_v_effective_date  DATE )
		IS
		SELECT  *
		FROM per_previous_employers_v ppev
		WHERE ppev.person_id= csr_v_person_id
		AND ppev.business_group_id = csr_v_business_group_id
                AND ppev.start_date <= csr_v_effective_date
		ORDER BY ppev.start_date DESC;


	/* Cursor to retrieve summary information about the Employee) */
	CURSOR csr_sum_time IS
	SELECT  sum(action_information10) total_days_worked
	FROM pay_action_information
	WHERE action_information_category = 'EMEA REPORT INFORMATION'
	AND action_information1 = 'PYSETETA'
	AND action_information2 = to_char(p_payroll_action_id)
	AND action_information11 IN ('PH','CH');

BEGIN
	 IF g_debug THEN
		hr_utility.set_location(' Entering Procedure DEINITIALIZATION_CODE',380);
	 END IF;

			PAY_SE_ARCHIVE_TETA.GET_ALL_PARAMETERS(
			p_payroll_action_id
			,g_business_group_id
			,g_person_id
			,g_date_report
			,g_effective_date
			,g_archive ) ;

			g_payroll_action_id :=p_payroll_action_id;

			--fnd_file.put_line(fnd_file.log,'Inside  Deinitialization Code');

			FOR person_prev_teta_rec IN csr_person_prev_teta( g_person_id, g_business_group_id, g_date_report)
						LOOP


							--fnd_file.put_line(fnd_file.log,'Inside Loop Archive Code');

							pay_action_information_api.create_action_information (
							p_action_information_id=> l_action_info_id,
							p_action_context_id=> p_payroll_action_id,
							p_action_context_type=> 'PA',
							p_object_version_number=> l_ovn,
							p_effective_date=> g_effective_date,
							p_source_id=> NULL,
							p_source_text=> NULL,
							p_action_information_category=> 'EMEA REPORT INFORMATION',
							p_action_information1=> 'PYSETETA',
							p_action_information2=> g_payroll_action_id,
							p_action_information3=> g_person_id   ,
							p_action_information4=> person_prev_teta_rec.previous_employer_id ,
							p_action_information5=> person_prev_teta_rec.employer_name ,
							p_action_information6=>  NULL,
							p_action_information7=>  NULL,
							p_action_information8=>  person_prev_teta_rec.start_date,
							p_action_information9=>  person_prev_teta_rec.end_date ,
							p_action_information10=>  person_prev_teta_rec.end_date - person_prev_teta_rec.start_date ,
							p_action_information11=> 'PH',
							p_action_information12=> NULL ,
							p_action_information13=> NULL,
							p_action_information14=> NULL,
							p_action_information15=> NULL,
							p_action_information16=> NULL,
							p_action_information17=> NULL,
							p_action_information18=> NULL,
							p_action_information19=> NULL,
							p_action_information20=> NULL,
							p_action_information21=> NULL,
							p_action_information22=> NULL,
							p_action_information23=> NULL,
							p_action_information24=> NULL,
							p_action_information25=> NULL,
							p_action_information26=> NULL,
							p_action_information27=> NULL,
							p_action_information28=> NULL,
							p_action_information29=> NULL,
							p_action_information30=> NULL
							);

						END LOOP;


			FOR  sum_time_rec IN csr_sum_time
			LOOP

					fnd_file.put_line(fnd_file.log,'Inside Loop  Deinitialization Code');
					IF sum_time_rec.total_days_worked   >= 365 THEN

						l_years_worked :=  trunc(sum_time_rec.total_days_worked/365);
						l_days_worked :=  mod(sum_time_rec.total_days_worked,365);

					ELSE
						l_years_worked := 0;
						l_days_worked :=  sum_time_rec.total_days_worked;
					END IF;

					pay_action_information_api.create_action_information (
					p_action_information_id=> l_action_info_id,
					p_action_context_id=> p_payroll_action_id,
					p_action_context_type=> 'PA',
					p_object_version_number=> l_ovn,
					p_effective_date=> g_effective_date,
					p_source_id=> NULL,
					p_source_text=> NULL,
					p_action_information_category => 'EMEA REPORT INFORMATION',
					p_action_information1=> 'PYSETETA',
					p_action_information2=>  'S',
					p_action_information3=> l_years_worked,
					p_action_information4=> l_days_worked ,
					p_action_information5=> NULL,
					p_action_information6=>  NULL,
					p_action_information7=>  NULL,
					p_action_information8=> NULL,
					p_action_information9=> NULL,
					p_action_information10=> NULL,
					p_action_information11=> NULL,
					p_action_information12=> NULL,
					p_action_information13=> NULL,
					p_action_information14=> NULL,
					p_action_information15=> NULL,
					p_action_information16=> NULL,
					p_action_information17=> NULL,
					p_action_information18=> NULL,
					p_action_information19=> NULL,
					p_action_information20=> NULL,
					p_action_information21=> NULL,
					p_action_information22=> NULL,
					p_action_information23=> NULL,
					p_action_information24=> NULL,
					p_action_information25=> NULL,
					p_action_information26=> NULL,
					p_action_information27=> NULL,
					p_action_information28=> NULL,
					p_action_information29=> NULL,
					p_action_information30=> NULL );

				END LOOP;

	IF g_debug THEN
				hr_utility.set_location(' Leaving Procedure DEINITIALIZATION_CODE',390);
	END IF;

EXCEPTION
  WHEN others THEN
	IF g_debug THEN
	    hr_utility.set_location('error raised in DEINITIALIZATION_CODE ',5);
	END if;
    RAISE;
 END;

 BEGIN

	g_archive := NULL;
	g_date_report   := NULL ;
	g_effective_date   := NULL ;
	g_person_id   := NULL ;
	g_payroll_action_id :=  NULL ;

 END PAY_SE_ARCHIVE_TETA;

/
