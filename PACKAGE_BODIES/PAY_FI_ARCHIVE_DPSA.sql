--------------------------------------------------------
--  DDL for Package Body PAY_FI_ARCHIVE_DPSA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FI_ARCHIVE_DPSA" AS
 /* $Header: pyfidpsa.pkb 120.5.12010000.3 2009/04/23 12:39:56 rsengupt ship $ */

	g_debug   boolean   :=  hr_utility.debug_enabled;
	g_package           VARCHAR2(33) := ' PAY_FI_ARCHIVE_DPSA.';
	g_payroll_action_id    NUMBER ;
	g_le_assignment_action_id NUMBER ;
	g_lu_assignment_action_id NUMBER ;
	g_emp_type              VARCHAR2(2);
	g_business_group_id     NUMBER;
	g_legal_employer_id     NUMBER;
	g_local_unit_id NUMBER;
	g_year                  VARCHAR2(4);
	g_transact_type VARCHAR2(1);
	g_deduction_ss NUMBER;
	g_effective_date         DATE;
	g_archive       VARCHAR2(1);

	 /* GET PARAMETER */
	 FUNCTION GET_PARAMETER(
		 p_parameter_string IN VARCHAR2
		,p_token            IN VARCHAR2
		,p_segment_number   IN NUMBER default NULL ) RETURN VARCHAR2
	 IS
		   l_parameter  pay_payroll_actions.legislative_parameters%TYPE:=NULL;
		   l_start_pos  NUMBER;
		   l_delimiter  VARCHAR2(1):=' ';
		   l_proc VARCHAR2(40):= g_package||' get parameter ';
	BEGIN
	 --
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
		p_payroll_action_id                    IN   NUMBER
    		,p_business_group_id              OUT  NOCOPY NUMBER
		,p_legal_employer_id                OUT  NOCOPY  NUMBER
		,p_local_unit_id                           OUT  NOCOPY  NUMBER
		,p_year						OUT  NOCOPY  VARCHAR2
		,p_transact_type				OUT  NOCOPY  VARCHAR2
		,p_deduction_ss				OUT  NOCOPY  NUMBER
		,p_effective_date                         OUT  NOCOPY DATE
		,p_archive					OUT  NOCOPY  VARCHAR2
		) IS

		CURSOR csr_parameter_info(p_payroll_action_id NUMBER) IS
		SELECT PAY_FI_ARCHIVE_DPSA.GET_PARAMETER(legislative_parameters,'LEGAL_EMPLOYER_ID')
		,PAY_FI_ARCHIVE_DPSA.GET_PARAMETER(legislative_parameters,'LOCAL_UNIT_ID')
		,PAY_FI_ARCHIVE_DPSA.GET_PARAMETER(legislative_parameters,'YEAR_RPT')
		,PAY_FI_ARCHIVE_DPSA.GET_PARAMETER(legislative_parameters,'TRANSACTION_TYPE')
		,PAY_FI_ARCHIVE_DPSA.GET_PARAMETER(legislative_parameters,'DEDUCTIONS_SS') DEDUCTIONS_SS
		,PAY_FI_ARCHIVE_DPSA.GET_PARAMETER(legislative_parameters,'ARCHIVE')
		,effective_date
		,business_group_id
		FROM  pay_payroll_actions
		WHERE payroll_action_id = p_payroll_action_id;

		l_proc VARCHAR2(240):= g_package||' GET_ALL_PARAMETERS ';
		--
	BEGIN

		 OPEN csr_parameter_info (p_payroll_action_id);

		 FETCH csr_parameter_info
		 INTO	p_legal_employer_id
				,p_local_unit_id
				,p_year
				,p_transact_type
				,p_deduction_ss
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
	PROCEDURE RANGE_CODE
	(p_payroll_action_id    IN    NUMBER
	,p_sql    OUT   NOCOPY VARCHAR2)
	IS
		l_action_info_id NUMBER;
		l_ovn NUMBER;
		l_count NUMBER := 0;
		l_business_group_id    NUMBER;
		l_emp_id        hr_organization_units.organization_id%TYPE ;
		l_le_name            hr_organization_units.name%TYPE ;
		l_lu_name            hr_organization_units.name%TYPE ;
		l_business_id               hr_organization_information.org_information1%TYPE ;
		l_y_number                 hr_organization_information.org_information1%TYPE ;
		l_contact_person    hr_organization_information.org_information1%TYPE ;
		l_phone             hr_organization_information.org_information1%TYPE ;
		l_org_type    hr_organization_information.org_information1%TYPE ;

    		/*Cursors */
		/*Local Unit Information*/
		Cursor csr_Local_Unit_Details ( csr_v_local_unit_id  hr_organization_information.ORGANIZATION_ID%TYPE)
		IS
		SELECT o1.name , hoi2.ORG_INFORMATION1
		FROM hr_organization_units o1
		, hr_organization_information hoi1
		, hr_organization_information hoi2
		WHERE  o1.business_group_id =l_business_group_id
		AND hoi1.organization_id = o1.organization_id
		AND hoi1.organization_id =  csr_v_local_unit_id
		AND hoi1.org_information1 = 'FI_LOCAL_UNIT'
		AND hoi1.org_information_context = 'CLASS'
		AND o1.organization_id =hoi2.organization_id
		AND hoi2.ORG_INFORMATION_CONTEXT='FI_LOCAL_UNIT_DETAILS';

		rg_Local_Unit_Details  csr_Local_Unit_Details%rowtype;

		/*Legal Employer Information*/
		Cursor csr_Legal_Emp_Details ( csr_v_legal_emp_id  hr_organization_information.ORGANIZATION_ID%TYPE)
		IS
		SELECT o1.name ,hoi2.ORG_INFORMATION1 ,  hoi2.ORG_INFORMATION13
		FROM hr_organization_units o1
		, hr_organization_information hoi1
		, hr_organization_information hoi2
		WHERE  o1.business_group_id =l_business_group_id
		AND hoi1.organization_id = o1.organization_id
		AND hoi1.organization_id =   csr_v_legal_emp_id
		AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
		AND hoi1.org_information_context = 'CLASS'
		AND o1.organization_id =hoi2.organization_id
		AND hoi2.ORG_INFORMATION_CONTEXT='FI_LEGAL_EMPLOYER_DETAILS' ;


		rg_Legal_Emp_Details  csr_Legal_Emp_Details%rowtype;

		/*Legal Employer Contact Information*/
		Cursor csr_Legal_Emp_Contact ( csr_v_legal_emp_id  hr_organization_information.ORGANIZATION_ID%TYPE)
		IS
		SELECT hoi4.ORG_INFORMATION2 contact_person , hoi3.ORG_INFORMATION2 phone
		FROM hr_organization_units o1
		, hr_organization_information hoi1
		, hr_organization_information hoi3
		, hr_organization_information hoi4
		WHERE  o1.business_group_id =l_business_group_id
		AND hoi1.organization_id = o1.organization_id
		AND hoi1.organization_id =  csr_v_legal_emp_id
		AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
		AND hoi1.org_information_context = 'CLASS'
		AND hoi3.organization_id (+)= o1.organization_id
		AND hoi3.ORG_INFORMATION_CONTEXT (+)='ORG_CONTACT_DETAILS'
		AND hoi3.org_information1 (+)= 'PHONE'
		AND hoi4.organization_id (+)= o1.organization_id
		AND hoi4.ORG_INFORMATION_CONTEXT (+)='ORG_CONTACT_DETAILS'
		AND hoi4.org_information1 (+)= 'PERSON' ;

		rg_Legal_Emp_Contact  csr_Legal_Emp_Contact%rowtype;

		/*Local Unit Contact Information*/
		Cursor csr_Local_Unit_contact ( csr_v_local_unit_id  hr_organization_information.ORGANIZATION_ID%TYPE)
		IS
		SELECT hoi4.ORG_INFORMATION2 contact_person , hoi3.ORG_INFORMATION2 phone
		FROM hr_organization_units o1
		, hr_organization_information hoi1
		, hr_organization_information hoi3
		, hr_organization_information hoi4
		WHERE  o1.business_group_id =l_business_group_id
		AND hoi1.organization_id = o1.organization_id
		AND hoi1.organization_id =  csr_v_local_unit_id
		AND hoi1.org_information1 = 'FI_LOCAL_UNIT'
		AND hoi1.org_information_context = 'CLASS'
		AND hoi3.organization_id (+)= o1.organization_id
		AND hoi3.ORG_INFORMATION_CONTEXT (+)='ORG_CONTACT_DETAILS'
		AND hoi3.org_information1 (+)= 'PHONE'
		AND hoi4.organization_id (+)= o1.organization_id
		AND hoi4.ORG_INFORMATION_CONTEXT (+)='ORG_CONTACT_DETAILS'
		AND hoi4.org_information1 (+)= 'PERSON' ;

		rg_Local_Unit_contact  csr_Local_Unit_contact%rowtype;

		/* End of Cursors */
		BEGIN

			-- fnd_file.put_line(fnd_file.log,'Range Code 1');

			IF g_debug THEN
				hr_utility.set_location(' Entering Procedure RANGE_CODE',40);
			END IF;

			p_sql := 'SELECT DISTINCT person_id
			FROM  per_people_f ppf
			,pay_payroll_actions ppa
			WHERE ppa.payroll_action_id = :payroll_action_id
			AND   ppa.business_group_id = ppf.business_group_id
			ORDER BY ppf.person_id';

			-- fnd_file.put_line(fnd_file.log,'Range Code 2');

			g_archive := NULL;
			g_emp_type := NULL ;
			g_legal_employer_id := NULL ;
			g_local_unit_id  := NULL ;
			g_effective_date   := NULL ;
			g_payroll_action_id := p_payroll_action_id ;
			g_le_assignment_action_id   := NULL ;
			g_lu_assignment_action_id   := NULL ;
			g_transact_type  := NULL ;
			g_deduction_ss	:= NULL ;

			-- fnd_file.put_line(fnd_file.log,'Range Code 3');

			PAY_FI_ARCHIVE_DPSA.GET_ALL_PARAMETERS(
			p_payroll_action_id
			,l_business_group_id
			,g_legal_employer_id
			,g_local_unit_id
			,g_year
			,g_transact_type
                        ,g_deduction_ss
			,g_effective_date
			,g_archive ) ;

			-- fnd_file.put_line(fnd_file.log,'Range Code 4');

			IF  g_archive = 'Y' THEN

				-- fnd_file.put_line(fnd_file.log,'Range Code 5');

				SELECT count(*)
				INTO l_count
				FROM   pay_action_information
				WHERE  action_information_category = 'EMEA REPORT DETAILS'
				AND        action_information1             = 'PYFIDPSA'
				AND    action_context_id           = p_payroll_action_id;

				-- fnd_file.put_line(fnd_file.log,'Range Code 6');

				IF l_count < 1  then

					hr_utility.set_location('Entered Procedure GETDATA',10);

					-- fnd_file.put_line(fnd_file.log,'Range Code 7');

					OPEN  csr_Legal_Emp_Details(g_legal_employer_id);
					FETCH csr_Legal_Emp_Details INTO rg_Legal_Emp_Details;
					CLOSE csr_Legal_Emp_Details;

					l_le_name	:= rg_Legal_Emp_Details.name ;
					l_y_number   := rg_Legal_Emp_Details.ORG_INFORMATION1 ;
					l_org_type      := rg_Legal_Emp_Details.ORG_INFORMATION13 ;

					-- fnd_file.put_line(fnd_file.log,'Range Code 8');
					IF g_local_unit_id IS NOT NULL THEN

						-- fnd_file.put_line(fnd_file.log,'Range Code 9');

						g_emp_type:='LU' ;
						l_emp_id:=g_local_unit_id;
						hr_utility.set_location('Calculation for Local Unit',40);

						/* Pick up the details belonging to Local Unit */

						OPEN  csr_Local_Unit_Details( g_local_unit_id);
						FETCH csr_Local_Unit_Details INTO rg_Local_Unit_Details;
						CLOSE csr_Local_Unit_Details;

						l_lu_name	  := rg_Local_Unit_Details.name ;
						l_business_id := l_y_number||'-'||rg_Local_Unit_Details.ORG_INFORMATION1 ;

						OPEN  csr_Local_Unit_Details( g_local_unit_id);
						FETCH csr_Local_Unit_Details INTO rg_Local_Unit_Details;
						CLOSE csr_Local_Unit_Details;

						hr_utility.set_location('Pick up the details belonging to Local Unit',60);

						/* Pick up the contact details belonging to  Local Unit*/

						OPEN  csr_Local_Unit_contact( g_local_unit_id);
						FETCH csr_Local_Unit_contact INTO rg_Local_Unit_contact;
						CLOSE csr_Local_Unit_contact;

						l_contact_person	:= rg_Local_Unit_contact.contact_person ;
						l_phone			:= rg_Local_Unit_contact.phone ;

						hr_utility.set_location('Pick up the contact details belonging to  Local Unit',70);
						-- fnd_file.put_line(fnd_file.log,'Range Code 10');
					ELSE
						-- fnd_file.put_line(fnd_file.log,'Range Code 11');
						g_emp_type:='LE' ;
						l_emp_id:=g_legal_employer_id ;

						/* Pick up the details belonging to Legal Employer */

						OPEN  csr_Legal_Emp_Details(g_legal_employer_id);
						FETCH csr_Legal_Emp_Details INTO rg_Legal_Emp_Details;
						CLOSE csr_Legal_Emp_Details;

						l_le_name	:= rg_Legal_Emp_Details.name ;
						l_business_id		:= rg_Legal_Emp_Details.ORG_INFORMATION1 ;

						/* Pick up the contact details belonging to Legal Employer */

						OPEN  csr_Legal_Emp_contact( g_legal_employer_id);
						FETCH csr_Legal_Emp_contact INTO rg_Legal_Emp_contact;
						CLOSE csr_Legal_Emp_contact;

						l_contact_person	:= rg_Legal_Emp_Contact .contact_person ;
						l_phone			:= rg_Legal_Emp_Contact .phone ;

						-- fnd_file.put_line(fnd_file.log,'Range Code 12');

					END IF ;

					-- fnd_file.put_line(fnd_file.log,'Range Code 13');


					pay_action_information_api.create_action_information (
					p_action_information_id        => l_action_info_id
					,p_action_context_id            => p_payroll_action_id
					,p_action_context_type          => 'PA'
					,p_object_version_number        => l_ovn
					,p_effective_date               => g_effective_date
					,p_source_id                    => NULL
					,p_source_text                  => NULL
					,p_action_information_category  => 'EMEA REPORT INFORMATION'
					,p_action_information1          => 'PYFIDPSA'
					,p_action_information2          => g_emp_type
					,p_action_information3          => l_emp_id
					,p_action_information4          => l_business_id
					,p_action_information5          => l_org_type
					,p_action_information6          => l_contact_person
					,p_action_information7          => l_phone
					,p_action_information8          => g_year
					,p_action_information9          => g_transact_type
					,p_action_information10          => null
					,p_action_information11          =>null
					,p_action_information12          =>null
					,p_action_information13          => null
					,p_action_information14          => null
					,p_action_information15          => null
					,p_action_information16          => null
					,p_action_information17          =>  null
					,p_action_information18          => null
					,p_action_information19          =>  null
					,p_action_information20          => null
					,p_action_information21          => null
					,p_action_information22          =>  null
					,p_action_information23          => null
					,p_action_information24          => null
					,p_action_information25          => null
					,p_action_information26          => null
					,p_action_information27          => null
					,p_action_information28          => null
					,p_action_information29          =>  null
					,p_action_information30          =>  null );

					-- fnd_file.put_line(fnd_file.log,'Range Code 14');

					pay_action_information_api.create_action_information (
					p_action_information_id        => l_action_info_id
					,p_action_context_id            => p_payroll_action_id
					,p_action_context_type          => 'PA'
					,p_object_version_number        => l_ovn
					,p_effective_date               => g_effective_date
					,p_source_id                    => NULL
					,p_source_text                  => NULL
					,p_action_information_category  => 'EMEA REPORT DETAILS'
					,p_action_information1          => 'PYFIDPSA'
					,p_action_information2          => l_le_name
					,p_action_information3          => l_lu_name
					,p_action_information4          => g_year
					,p_action_information5          => g_transact_type
					,p_action_information6          =>  null
					,p_action_information7          => null
					,p_action_information8          =>  null
					,p_action_information9          =>  null
					,p_action_information10          => null
					,p_action_information11          =>  null
					,p_action_information12          =>  null
					,p_action_information13          =>  null
					,p_action_information14          =>  null
					,p_action_information15          =>  null
					,p_action_information16          =>  null
					,p_action_information17          =>   null
					,p_action_information18          =>  null
					,p_action_information19          =>   null
					,p_action_information20          =>  null
					,p_action_information21          =>  null
					,p_action_information22          =>   null
					,p_action_information23          =>  null
					,p_action_information24          =>  null
					,p_action_information25          =>  null
					,p_action_information26          =>  null
					,p_action_information27          =>  null
					,p_action_information28          => null
					,p_action_information29          =>  null
					,p_action_information30          =>  null );

					-- fnd_file.put_line(fnd_file.log,'Range Code 15');

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
	 ,p_chunk                 IN NUMBER )
	 IS

		l_canonical_start_date DATE;
		l_canonical_end_date    DATE;
		l_prepay_action_id     NUMBER;
		l_prev_person_id       NUMBER;
		l_prev_local_unit_id  NUMBER;
		l_actid NUMBER;

		 CURSOR csr_prepaid_assignments_lu
		 (p_payroll_action_id          NUMBER
		 ,p_start_person      		NUMBER
		 ,p_end_person			NUMBER
		 ,p_legal_employer_id	NUMBER
		 ,p_local_unit_id			NUMBER
		 ,l_canonical_start_date	DATE
		 ,l_canonical_end_date	DATE)
		 IS
		SELECT  as1.person_id	person_id,
		 act.assignment_id            assignment_id,
		act.assignment_action_id     run_action_id,
		act1.assignment_action_id    prepaid_action_id
		FROM   pay_payroll_actions          ppa
		,pay_payroll_actions          appa
		,pay_payroll_actions          appa2
		,pay_assignment_actions       act
		,pay_assignment_actions       act1
		,pay_action_interlocks        pai
		,per_all_assignments_f        as1
		,hr_soft_coding_keyflex         hsck
		,pay_run_result_values    TARGET
		,pay_run_results          RR
		WHERE  ppa.payroll_action_id        = p_payroll_action_id
		AND    appa.effective_date          BETWEEN l_canonical_start_date
		AND     l_canonical_end_date
		AND    as1.person_id                BETWEEN p_start_person
		AND     p_end_person
		AND    appa.action_type             IN ('R','Q')
		-- Payroll Run or Quickpay Run
		AND    act.payroll_action_id        = appa.payroll_action_id
		AND    act.source_action_id         IS NULL -- Master Action
		AND    as1.assignment_id            = act.assignment_id
--             Commenting Code to Include Terminated Assignments
--		AND    ppa.effective_date           BETWEEN as1.effective_start_date
--		AND     as1.effective_end_date
		AND    act.action_status            = 'C'  -- Completed
		AND    act.assignment_action_id     = pai.locked_action_id
		AND    act1.assignment_action_id    = pai.locking_action_id
		AND    act1.action_status           = 'C' -- Completed
		AND    act1.payroll_action_id     = appa2.payroll_action_id
		AND    appa2.action_type            IN ('P','U')
		AND    appa2.effective_date          BETWEEN l_canonical_start_date
		AND l_canonical_end_date
		-- Prepayments or Quickpay Prepayments
		AND  hsck.SOFT_CODING_KEYFLEX_ID=as1.SOFT_CODING_KEYFLEX_ID
		AND   hsck.segment2 = to_char(p_local_unit_id)
		AND   act.TAX_UNIT_ID    =  act1.TAX_UNIT_ID
		AND   act.TAX_UNIT_ID    =  p_legal_employer_id
		and    TARGET.run_result_id    = RR.run_result_id
		AND   (( RR.assignment_action_id
		in ( Select act2.assignment_action_id
		from pay_assignment_actions act2
		Where    act2.source_action_id=act.assignment_action_id
		AND    act2.action_status            = 'C'  -- Completed
		AND    act2.payroll_action_id        = act.payroll_action_id))
		or
		(RR.assignment_action_id=act.assignment_action_id))
		and    RR.status in ('P','PA')
		ORDER BY  as1.person_id , act.assignment_id  ;


		CURSOR csr_prepaid_assignments_le(p_payroll_action_id          	NUMBER,
			 p_start_person      	NUMBER,
			 p_end_person         NUMBER,
			 p_legal_employer_id			NUMBER,
			 l_canonical_start_date	DATE,
			 l_canonical_end_date	DATE)
		 IS
		SELECT as1.person_id  person_id,
		act.assignment_id            assignment_id,
		act.assignment_action_id     run_action_id,
		act1.assignment_action_id    prepaid_action_id
		FROM   pay_payroll_actions          ppa
		,pay_payroll_actions          appa
		,pay_payroll_actions          appa2
		,pay_assignment_actions       act
		,pay_assignment_actions       act1
		,pay_action_interlocks        pai
		,per_all_assignments_f        as1
		,pay_run_result_values    TARGET
		,pay_run_results          RR
		WHERE  ppa.payroll_action_id        = p_payroll_action_id
		AND    appa.effective_date          BETWEEN l_canonical_start_date
		AND     l_canonical_end_date
		AND    as1.person_id                BETWEEN p_start_person
		AND     p_end_person
		AND    appa.action_type             IN ('R','Q')
		-- Payroll Run or Quickpay Run
		AND    act.payroll_action_id        = appa.payroll_action_id
		AND    act.source_action_id         IS NULL -- Master Action
		AND    as1.assignment_id            = act.assignment_id
		--             Commenting Code to Include Terminated Assignments
--		AND    ppa.effective_date           BETWEEN as1.effective_start_date
--		AND     as1.effective_end_date
		AND    act.action_status            = 'C'  -- Completed
		AND    act.assignment_action_id     = pai.locked_action_id
		AND    act1.assignment_action_id    = pai.locking_action_id
		AND    act1.action_status           = 'C' -- Completed
		AND    act1.payroll_action_id     = appa2.payroll_action_id
		AND    appa2.action_type            IN ('P','U')
		AND    appa2.effective_date          BETWEEN l_canonical_start_date
		AND l_canonical_end_date
		-- Prepayments or Quickpay Prepayments
		AND   act.TAX_UNIT_ID    =  act1.TAX_UNIT_ID
		AND   act.TAX_UNIT_ID    =  p_legal_employer_id
		and    TARGET.run_result_id    = RR.run_result_id
		AND   (( RR.assignment_action_id
		in ( Select act2.assignment_action_id
		from pay_assignment_actions act2
		Where    act2.source_action_id=act.assignment_action_id
		AND    act2.action_status            = 'C'  -- Completed
		AND    act2.payroll_action_id        = act.payroll_action_id))
		or
		(RR.assignment_action_id=act.assignment_action_id))
		and    RR.status in ('P','PA')
		ORDER BY  as1.person_id  , act.assignment_id;



	 BEGIN

		-- fnd_file.put_line(fnd_file.log,'ASSIGNMENT_ACTION_CODE 1');

		IF g_debug THEN
		hr_utility.set_location(' Entering Procedure ASSIGNMENT_ACTION_CODE',60);
		END IF;

		PAY_FI_ARCHIVE_DPSA.GET_ALL_PARAMETERS(
		p_payroll_action_id
		,g_business_group_id
		,g_legal_employer_id
		,g_local_unit_id
		,g_year
		,g_transact_type
		,g_deduction_ss
		,g_effective_date
		,g_archive ) ;

		-- fnd_file.put_line(fnd_file.log,'ASSIGNMENT_ACTION_CODE 2');

		g_payroll_action_id :=p_payroll_action_id;
		l_canonical_start_date := TO_DATE('01'||g_year,'MMYYYY');
		l_canonical_end_date   := LAST_DAY(TO_DATE('12'||g_year,'MMYYYY'));
		l_prepay_action_id := 0;
		l_prev_person_id := 0;


		-- fnd_file.put_line(fnd_file.log,'ASSIGNMENT_ACTION_CODE 3');

		IF g_local_unit_id IS NOT NULL THEN

			g_emp_type := 'LU';

			-- fnd_file.put_line(fnd_file.log,'ASSIGNMENT_ACTION_CODE 4');

			FOR rec_prepaid_assignments IN csr_prepaid_assignments_lu(p_payroll_action_id
				,p_start_person
				,p_end_person
				 ,g_legal_employer_id
				 ,g_local_unit_id
				,l_canonical_start_date
				,l_canonical_end_date)
				LOOP
					IF l_prepay_action_id <> rec_prepaid_assignments.prepaid_action_id
					AND l_prev_person_id <> rec_prepaid_assignments.person_id THEN

						SELECT pay_assignment_actions_s.NEXTVAL
						INTO   l_actid
						FROM   dual;

					       -- Create the archive assignment action

						    hr_nonrun_asact.insact(l_actid
						  ,rec_prepaid_assignments.assignment_id
						  ,p_payroll_action_id
						  ,p_chunk
						  ,NULL);
					-- fnd_file.put_line(fnd_file.log,'ASSIGNMENT_ACTION_CODE 5'||rec_prepaid_assignments.person_id);

					END IF;
						l_prepay_action_id := rec_prepaid_assignments.prepaid_action_id;
						l_prev_person_id := rec_prepaid_assignments.person_id;
				END LOOP;

		ELSE
					 g_emp_type := 'LE';

		 			-- fnd_file.put_line(fnd_file.log,'ASSIGNMENT_ACTION_CODE 6');

					FOR rec_prepaid_assignments IN csr_prepaid_assignments_le(p_payroll_action_id
					,p_start_person
					,p_end_person
					 ,g_legal_employer_id
					,l_canonical_start_date
					,l_canonical_end_date)
					LOOP
						IF l_prepay_action_id <> rec_prepaid_assignments.prepaid_action_id
						AND l_prev_person_id <> rec_prepaid_assignments.person_id THEN

							SELECT pay_assignment_actions_s.NEXTVAL
							INTO   l_actid
							FROM   dual;

						       -- Create the archive assignment action
							    hr_nonrun_asact.insact(l_actid
							  ,rec_prepaid_assignments.assignment_id
							  ,p_payroll_action_id
							  ,p_chunk
							  ,NULL);
				  			-- fnd_file.put_line(fnd_file.log,'ASSIGNMENT_ACTION_CODE 7'||rec_prepaid_assignments.person_id);

						END IF;
						l_prepay_action_id := rec_prepaid_assignments.prepaid_action_id;
						l_prev_person_id := rec_prepaid_assignments.person_id;
					END LOOP;
		END IF;

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
		-- fnd_file.put_line(fnd_file.log,'INITIALIZATION_CODE 1');
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
		/* Cursor to retrieve effective end date of the assignment*/
		CURSOR csr_asg_effective_date
		(p_asg_act_id NUMBER
		,p_start_date DATE
		,p_end_date DATE
		,p_business_group_id NUMBER) IS
		SELECT MAX( EFFECTIVE_END_DATE) EFFECTIVE_END_DATE
		FROM	per_all_assignments             paa
		,pay_assignment_actions      	pac
		WHERE pac.assignment_action_id = p_asg_act_id
		AND paa.assignment_id = pac.assignment_id
		AND paa.EFFECTIVE_START_DATE  <= p_end_date
		AND paa.EFFECTIVE_END_DATE > = p_start_date
		AND assignment_status_type_id IN
		(select assignment_status_type_id
		from per_assignment_status_types
		where per_system_status = 'ACTIVE_ASSIGN'
		and active_flag = 'Y'
		and (( legislation_code is null
		and business_group_id is null)
		OR (BUSINESS_GROUP_ID = p_business_group_id)));

		rg_csr_asg_effective_date  csr_asg_effective_date%rowtype;

		/* Cursor to retrieve Person Details */
		CURSOR csr_get_person_details(p_asg_act_id NUMBER , p_asg_effective_date DATE ) IS
		SELECT pap.first_name first_name , pap.last_name last_name , pap. national_identifier  , pap. person_id  , pac.assignment_id,
		pap.per_information1 place_residence , pap.business_group_id , pap.per_information23 fpin
		FROM
		pay_assignment_actions      	pac,
		per_all_assignments_f             assign,
		per_all_people_f			pap
		WHERE pac.assignment_action_id = p_asg_act_id
		AND assign.assignment_id = pac.assignment_id
		AND assign.person_id = pap.person_id
		AND pap.per_information_category = 'FI'
		AND p_asg_effective_date BETWEEN assign.effective_start_date
		AND assign.effective_end_date
		AND p_asg_effective_date BETWEEN pap.effective_start_date
		AND pap.effective_end_date;

		rg_csr_get_person_details  csr_get_person_details%rowtype;

		/* Cursor to retrieve Defined Balance Id */
		Cursor csr_get_defined_balance_id(csr_v_Balance_Name FF_DATABASE_ITEMS.USER_NAME%TYPE)
		IS
		SELECT   ue.creator_id
		FROM    ff_user_entities  ue,
		ff_database_items di
		WHERE   di.user_name = csr_v_Balance_Name
		AND     ue.user_entity_id = di.user_entity_id
		AND     ue.legislation_code = 'FI'
		AND     ue.business_group_id is NULL
		AND     ue.creator_type = 'B';

		rg_csr_get_defined_balance_id  csr_get_defined_balance_id%rowtype;

		/* Cursor to retrieve Defined Balance Id */
		Cursor csr_bg_get_defined_balance_id
		(csr_v_Balance_Name FF_DATABASE_ITEMS.USER_NAME%TYPE
		,p_business_group_id NUMBER)
		IS
		SELECT   ue.creator_id
		FROM    ff_user_entities  ue,
		ff_database_items di
		WHERE   di.user_name = csr_v_Balance_Name
		AND     ue.user_entity_id = di.user_entity_id
		AND     ue.legislation_code is NULL
		AND     ue.business_group_id = p_business_group_id
		AND     ue.creator_type = 'B';

		rg_csr_bg_get_defined_bal_id  csr_bg_get_defined_balance_id%rowtype;

		/* Cursor to retrieve Balance Types having a particular Balance Category */
		CURSOR csr_balance
		(p_balance_category_name VARCHAR2
		,p_business_group_id NUMBER)
		IS
		SELECT  REPLACE(UPPER(pbt.balance_name),' ' ,'_') balance_name
		FROM pay_balance_types pbt , pay_balance_categories_f pbc
		WHERE pbc.legislation_code='FI'
		AND pbt.business_group_id =p_business_group_id
		AND pbt.balance_category_id = pbc.balance_category_id
		AND pbc.category_name = p_balance_category_name ;


		/* Cursor to retrieve data from the Header record(Employer level) */
		CURSOR csr_rpt_header (p_asg_act_id NUMBER) IS
		SELECT  action_context_id            payroll_action_id  ,action_information2       emp_type     ,action_information3       emp_id
		,action_information4       business_id ,action_information5       org_type ,action_information6       contact_person
		,action_information7       phone ,action_information8       year        ,action_information9       transact_type
		FROM pay_action_information pai , pay_assignment_actions  paa
		WHERE pai.action_information_category = 'EMEA REPORT INFORMATION'
		AND pai.action_information1 = 'PYFIDPSA'
		AND pai.action_context_id = paa.payroll_action_id
		AND paa.assignment_action_id = p_asg_act_id;

		rg_csr_rpt_header  csr_rpt_header%rowtype;

		/* Cursor to retrieve Person Address Details */
		CURSOR csr_per_address
		(p_person_id  PER_ADDRESSES_V.PERSON_ID%TYPE
		,p_business_group_id PER_ADDRESSES_V.BUSINESS_GROUP_ID%TYPE )
		IS
		SELECT   address_line1||' '||address_line2 address , postal_code , d_country
		FROM    per_addresses_v
		WHERE ADDRESS_TYPE='FI_PR'
		AND BUSINESS_GROUP_ID = p_business_group_id
		AND PERSON_ID = p_person_id;

		rg_csr_per_address  csr_per_address%rowtype;

		/* Cursor to retrieve Tax Card Type*/
		CURSOR csr_get_tax_card_type(p_assignment_id NUMBER , p_start_date  DATE , p_end_date  DATE ) IS
		SELECT  eev1.screen_entry_value  screen_entry_value
		FROM   per_all_assignments_f      asg1
		,per_all_assignments_f      asg2
		,per_all_people_f           per
		,pay_element_links_f        el
		,pay_element_types_f        et
		,pay_input_values_f         iv1
		,pay_element_entries_f      ee
		,pay_element_entry_values_f eev1
		WHERE  asg1.assignment_id    = p_assignment_id
		AND  per.person_id         = asg1.person_id
		AND  asg2.person_id        = per.person_id
		AND  asg2.primary_flag     = 'Y'
		AND  et.element_name       = 'Tax Card'
		AND  et.legislation_code   = 'FI'
		AND  iv1.element_type_id   = et.element_type_id
		AND  iv1.name              = 'Tax Card Type'
		AND  el.business_group_id  = per.business_group_id
		AND  el.element_type_id    = et.element_type_id
		AND  ee.assignment_id      = asg2.assignment_id
		AND  ee.element_link_id    = el.element_link_id
		AND  eev1.element_entry_id = ee.element_entry_id
		AND  eev1.input_value_id   = iv1.input_value_id
		AND  asg1.effective_end_date > p_start_date
		AND  asg1.effective_start_date <  p_end_date
		AND  per.effective_end_date    > p_start_date
		AND  per.effective_start_date <  p_end_date
		AND  asg2.effective_end_date > p_start_date
		AND  asg2.effective_start_date <  p_end_date
		AND  ee.effective_end_date      > p_start_date
		AND  ee.effective_start_date <  p_end_date
		AND  ((eev1.effective_start_date < p_start_date
		AND  eev1.effective_end_date > p_start_date )
		OR	 (eev1.effective_start_date BETWEEN  p_start_date AND p_end_date
		AND  eev1.effective_end_date > p_end_date ));

		rg_csr_get_tax_card_type  csr_get_tax_card_type%rowtype;

		/* Cursor to check archived data */
		CURSOR csr_arch_chk (p_record_id VARCHAR2, p_payment_type  VARCHAR2, p_assignment_action_id NUMBER) IS
		SELECT COUNT(*)
		FROM pay_action_information
		WHERE action_information_category = 'EMEA REPORT INFORMATION'
		AND action_context_type = 'AAP'
		AND action_context_id= p_assignment_action_id
		AND action_information1 =p_record_id
		AND action_information2 = p_payment_type ;

		/* Cursor to check archived data */
		CURSOR csr_country (p_country_code VARCHAR2) IS
		SELECT territory_short_name territory_name , TERRITORY_CODE||' - '||territory_short_name territory_short_name
		FROM  fnd_territories_VL
		WHERE  TERRITORY_CODE=p_country_code;

		rg_csr_country  csr_country%rowtype;


                /*Cursor TO retrive Result Values FOR Elements Attached */ -- Changes  2009
		-- Start
		Cursor csr_result_value ( p_assignment_id IN NUMBER,
		p_element_name IN VARCHAR2,
		p_input_val_name IN VARCHAR2) IS
		SELECT prrv.result_value FROM
		pay_assignment_actions paa,
		pay_run_results prr,
		pay_element_types_f petf,
		pay_input_values_f pivf,
		pay_run_result_values prrv
		WHERE paa.assignment_id = p_assignment_id
		AND paa.assignment_action_id = prr.assignment_action_id
		AND prr.element_type_id = petf.element_type_id
		AND petf.element_name = p_element_name
		AND petf.legislation_code = 'FI'
		AND pivf.element_type_id = petf.element_type_id
		AND pivf.name = p_input_val_name
		AND prrv.input_value_id = pivf.input_value_id
		AND prrv.run_result_id = prr.run_result_id
		AND paa.action_sequence = (SELECT MAX(paa.action_sequence) FROM
					  pay_assignment_actions paa,
					  pay_run_results prr,
					  pay_element_types_f
					  WHERE paa.assignment_id = p_assignment_id
					  AND paa.assignment_action_id = prr.assignment_action_id
					  AND prr.element_type_id = petf.element_type_id
					  AND petf.element_name = p_element_name
					  AND petf.legislation_code = 'FI');

                -- Cursor to find the Bank Details od the Person who is paid.

                CURSOR csr_bank_details(p_assignment_id IN NUMBER,
	   					p_business_group_id IN NUMBER,
						p_report_date IN DATE) IS
		SELECT pea.segment1 Bank_Name,
	               pea.segment2 Bank_Branch,
		       pea.segment3 Account_Number
		FROM   pay_personal_payment_methods_f ppmf,
                       pay_external_accounts pea
		WHERE  ppmf.assignment_id = p_assignment_id
		AND    pea.external_account_id = ppmf.external_account_id
		AND    ppmf.business_group_id = p_business_group_id
		AND    p_report_date
				BETWEEN ppmf.effective_start_date
				AND ppmf.effective_end_date;

                rg_bank_details  csr_bank_details%rowtype;

		-- End 2009


		l_assignment_action_id NUMBER;
		l_action_context_id     NUMBER;
		l_flag NUMBER := 0;
		l_action_info_id NUMBER;
		l_ovn NUMBER;
		l_tax_card_type VARCHAR2(5);
		l_payment_type VARCHAR2(5);
		l_source_text VARCHAR2(10);
		l_source_text2 VARCHAR2(10);
		l_org_type VARCHAR2(5);
		l_country_code	varchar2(50);
	--      l_age_category varchar2(1); defined below

		l_wtax_base	NUMBER ;
		l_tstax_base	 NUMBER;
		l_tax_base	 NUMBER;
		l_notional_base	NUMBER;
		l_person_type  VARCHAR2(3);
		l_record_id     VARCHAR2(10);
		l_dimension   VARCHAR2(100);
		l_dimension1 VARCHAR2(100);
		l_dimension2 VARCHAR2(100);
		l_start_date DATE ;
		l_end_date DATE ;
		l_effective_date DATE ;
		l_ptp_1_wtax_base	NUMBER;
		l_ptp_2_wtax_base	NUMBER;
		l_pt1_1_wtax_base	NUMBER;
		l_pt1_2_wtax_base	NUMBER;
		l_ptp2_1_wtax_base	NUMBER;
		l_ptp2_2_wtax_base	NUMBER;
		l_pth_1_wtax_base	NUMBER;
		l_pth_2_wtax_base	NUMBER;
		l_pth2_1_wtax_base	NUMBER;
		l_pth2_2_wtax_base	NUMBER;
		l_ptg1_base	NUMBER;
		l_ptg_base	NUMBER;
		l_pth4_base	NUMBER;
		l_mtax_base	 NUMBER;
		l_mtax		NUMBER;
		l_tax		NUMBER;
		l_empl_unemp_ins	NUMBER;
		l_pretax_ded			NUMBER;
		l_cum_car_benefit	NUMBER;
		l_cum_mileage		NUMBER;
		l_bik	NUMBER;
		l_tot_mortgage_bik	NUMBER;
		l_mortgage_bik		NUMBER;
		l_mortgage_bik_status	NUMBER;
		l_other_bik		NUMBER;
		l_tot_other_bik	NUMBER;
		l_other_bik_status	NUMBER;
		l_tot_housing_bik	NUMBER;
		l_housing_bik	NUMBER;
		l_housing_bik_status	 NUMBER;
		l_tot_phone_bik	NUMBER;
		l_phone_bik		NUMBER;
		l_phone_bik_status	NUMBER;
		l_lunch_bik	NUMBER;
		l_lunch_bik_status	NUMBER;
		l_external_expenses				NUMBER;
		l_daily_allowance_d_expenses	NUMBER;
		l_daily_allowance_d_status		NUMBER;
		l_half_day_allowance_expenses	NUMBER;
		l_half_day_allowance_status		NUMBER;
		l_daily_allowance_fe_expenses	NUMBER;
		l_daily_allowance_fe_status		NUMBER;
		l_meal_comp_expenses			NUMBER;
		l_meal_comp_status				NUMBER;
		l_tax_free_mileage				NUMBER;
		l_tax_free_mileage_expenses		NUMBER;
		l_stock_option_bik				NUMBER;
		l_tot_stock_option_bik			NUMBER;
		l_emp_pension					NUMBER;
		l_travel_ticket_bik				NUMBER;
		l_tot_travel_ticket_bik				NUMBER;
		l_travel_ticket_bik_status			NUMBER;
		l_pta1_1_tstax_base				NUMBER;
		l_pta1_2_tstax_base				NUMBER;
		l_pta2_1_tstax_base				NUMBER;
		l_pta2_2_tstax_base				NUMBER;
		l_pta4_1_tstax_base				NUMBER;
		l_pta5_1_tstax_base				NUMBER;
		l_pta6_1_tstax_base				NUMBER;
		l_pta7_1_tstax_base				NUMBER;
		l_salary_income					NUMBER;
		l_social_security					NUMBER;
		l_count							NUMBER;
		l_empl_pension					NUMBER;
		l_full_car_benefit_status			NUMBER;
		l_bik_use_car_status				NUMBER;
		l_pt5_1_wtax_base				NUMBER;
		l_pt5_2_wtax_base				NUMBER;
		l_tax_status						VARCHAR2(1);
		l_place_residence				VARCHAR2(60);
		l_ptg1_tax		NUMBER;
		l_s1_tax_base	NUMBER;
		l_s1_tax			NUMBER;
		l_s2_tax_base	NUMBER;
		l_s2_tax			NUMBER;
		l_s3_tax_base	NUMBER;
		l_s3_tax			NUMBER;
		l_lunch_bik_ded_status	NUMBER;
		l_tot_lunch_bik_ded		NUMBER;
		l_lunch_bik_ded			NUMBER;
		l_tot_car_bik_ded		NUMBER;
		l_car_bik_ded			NUMBER;
		l_tot_other_bik_ded		NUMBER;
		l_other_bik_ded			NUMBER;
		l_tax_comp				NUMBER;
		l_tot_pay_eoff			NUMBER;
		l_pay_eoff				NUMBER;
		l_tot_vol_pi				NUMBER;
		l_vol_pi					NUMBER;
		l_tot_total_vol_pi			NUMBER;
		l_total_vol_pi			NUMBER;
		l_te_exem_ss 			NUMBER;
		l_bik_exem_ss 			NUMBER;
		l_sm_exem_ss			NUMBER;
		l_tot_exem_ss 			NUMBER;
		l_ss_ded				NUMBER;
		l_631					NUMBER;
		l_exem_ss				NUMBER;
		l_tot_ss_ded			NUMBER;
		l_bal_date				DATE;
		l_subsidy				NUMBER;
		l_subsidy_status			VARCHAR2(1) DEFAULT 'N' ;
		l_tax_type				VARCHAR2(2);
		l_pt_pension_amt		NUMBER;
		l_subsidy_amt			NUMBER;
		l_subsidy_basis			NUMBER;
		CODE_014				NUMBER;
		CODE_015				NUMBER;
		l_wtax					NUMBER;
		l_te 						NUMBER;
		l_te_ss					NUMBER;
		l_bik_ss	 				NUMBER;
		l_sm_ss				NUMBER;
		l_month					VARCHAR2(2);

                -- Added for 2009 changes
		l_car_ben_val             NUMBER := 0;
		l_full_car_ben            VARCHAR2(2) := 'N';
		l_mobilization_year       NUMBER := 0;
		l_car_abroad              VARCHAR(2) := 'N';
		l_age_category            VARCHAR2(2) ;
		l_bank_acc_num            VARCHAR(20) ;



	BEGIN
		-- fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 1');
		/*Initializing all balance variables*/

		l_count			:=0;
		l_wtax_base		:=0;
		l_tstax_base		:=0;
		l_tax_base		:=0;
		l_notional_base	:=0;
		l_ptp_1_wtax_base	:=0;
		l_ptp_2_wtax_base	:=0;
		l_pt1_1_wtax_base	:=0;
		l_pt1_2_wtax_base	:=0;
		l_ptp2_2_wtax_base	:=0;
		l_ptp2_2_wtax_base	:=0;
		l_pth_1_wtax_base	:=0;
		l_pth_2_wtax_base	:=0;
		l_pth2_1_wtax_base	:=0;
		l_pth2_2_wtax_base	:=0;
		l_ptg1_base		:=0;
		l_ptg_base		:=0;
		l_pth4_base		:=0;
		l_mtax_base	 	:=0;
		l_mtax			:=0;
		l_tax			:=0;
		l_empl_pension	:=0;
		l_empl_unemp_ins	:=0;
		l_pretax_ded			:=0;
		l_cum_car_benefit	:=0;
		l_cum_mileage		:=0;
		l_bik				:=0;
		l_tot_mortgage_bik	:=0;
		l_mortgage_bik		:=0;
		l_mortgage_bik_status :=0;
		l_other_bik			:=0;
		l_tot_other_bik		:=0;
		l_other_bik_status	:=0;
		l_tot_housing_bik	:=0;
		l_housing_bik		:=0;
		l_housing_bik_status	 :=0;
		l_tot_phone_bik		:=0;
		l_phone_bik			:=0;
		l_phone_bik_status	:=0;
		l_lunch_bik			:=0;
		l_lunch_bik_status	:=0;
		l_external_expenses				:=0;
		l_daily_allowance_d_expenses	:=0;
		l_daily_allowance_d_status		:=0;
		l_half_day_allowance_expenses	:=0;
		l_half_day_allowance_status		:=0;
		l_daily_allowance_fe_expenses	:=0;
		l_daily_allowance_fe_status		:=0;
		l_meal_comp_expenses			:=0;
		l_meal_comp_status				:=0;
		l_tax_free_mileage				:=0;
		l_tax_free_mileage_expenses		:=0;
		l_stock_option_bik				:=0;
		l_tot_stock_option_bik			:=0;
		l_emp_pension					:=0;
		l_travel_ticket_bik				:=0;
		l_tot_travel_ticket_bik				:=0;
		l_travel_ticket_bik_status			:=0;
		l_pta1_1_tstax_base				:=0;
		l_pta1_2_tstax_base				:=0;
		l_pta2_1_tstax_base				:=0;
		l_pta2_2_tstax_base				:=0;
		l_pta4_1_tstax_base				:=0;
		l_pta5_1_tstax_base				:=0;
		l_pta6_1_tstax_base				:=0;
		l_pta7_1_tstax_base				:=0;
		l_salary_income					:=0;
		l_social_security					:=0;
		l_pt5_1_wtax_base				:=0;
		l_pt5_2_wtax_base				:=0;
		l_ptg1_tax		:= 0;
		l_s1_tax_base	:= 0;
		l_s1_tax			:= 0 ;
		l_s2_tax_base	:= 0;
		l_s2_tax			:= 0 ;
		l_s3_tax_base	:= 0;
		l_s3_tax			:= 0 ;
		l_lunch_bik_ded_status	:= 0 ;
		l_tot_lunch_bik_ded		:= 0 ;
		l_lunch_bik_ded			:= 0 ;
		l_tot_car_bik_ded		:= 0 ;
		l_car_bik_ded			:= 0 ;
		l_tot_other_bik_ded		:= 0 ;
		l_other_bik_ded			:= 0 ;
		l_tax_comp				:= 0 ;
		l_tot_pay_eoff			:= 0 ;
		l_pay_eoff				:= 0 ;
		l_tot_vol_pi				:= 0 ;
		l_vol_pi					:= 0 ;
		l_total_vol_pi			:= 0 ;
		l_tot_total_vol_pi			:= 0 ;
		l_te_exem_ss 			:= 0 ;
		l_bik_exem_ss 			:= 0 ;
		l_sm_exem_ss			:= 0 ;
		l_tot_exem_ss 			:= 0 ;
		l_ss_ded				:= 0 ;
		l_631					:= 0 ;
		l_exem_ss				:= 0 ;
		l_tot_ss_ded			:= 0 ;
		l_subsidy				:= 0 ;
		l_pt_pension_amt		:= 0 ;
		l_subsidy_amt			:= 0 ;
		l_subsidy_basis			:= 0 ;
		CODE_014				:= 0 ;
		CODE_015				:= 0 ;
		l_wtax					:= 0 ;
		l_te						:= 0 ;
		l_te_ss					:= 0 ;
		l_bik_ss	 				:= 0 ;
		l_sm_ss				:= 0 ;
		l_month					:= 0 ;


		IF g_debug THEN
			hr_utility.set_location(' Entering Procedure ARCHIVE_CODE',380);
		END IF;

		/* Fetching data from the Header record(Employer level) */
		OPEN  csr_rpt_header(p_assignment_action_id);
		FETCH csr_rpt_header INTO rg_csr_rpt_header;
		CLOSE csr_rpt_header;

		/* Fetching report parameters */
		 PAY_FI_ARCHIVE_DPSA.GET_ALL_PARAMETERS
		( rg_csr_rpt_header.payroll_action_id
		,g_business_group_id
		,g_legal_employer_id
		,g_local_unit_id
		,g_year
		,g_transact_type
		,g_deduction_ss
		,g_effective_date
		,g_archive ) ;

		-- fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 2');

		IF g_archive='Y' THEN

			l_start_date := TO_DATE('01'||g_year,'MMYYYY');
			l_end_date   := LAST_DAY(TO_DATE('12'||g_year,'MMYYYY'));
			l_effective_date :=  l_end_date ;
			-- fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 3');

			/* Fetching Person Details */
			OPEN  csr_asg_effective_date(p_assignment_action_id , l_start_date , l_end_date , g_business_group_id );
			FETCH csr_asg_effective_date INTO rg_csr_asg_effective_date;
			CLOSE csr_asg_effective_date;

			/* Fetching Person Details */
			OPEN  csr_get_person_details(p_assignment_action_id , rg_csr_asg_effective_date.EFFECTIVE_END_DATE );
			FETCH csr_get_person_details INTO rg_csr_get_person_details;
			CLOSE csr_get_person_details;

			/* Setting Context */
			BEGIN
				pay_balance_pkg.set_context('ASSIGNMENT_ACTION_ID',p_assignment_action_id);
				pay_balance_pkg.set_context('TAX_UNIT_ID',g_legal_employer_id);
				IF  rg_csr_rpt_header.emp_type = 'LU'	THEN
					pay_balance_pkg.set_context('LOCAL_UNIT_ID',g_local_unit_id);
				END IF;

			END;

			 -- fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 4'||rg_csr_get_person_details.person_id);
			 l_assignment_action_id:=p_assignment_action_id;

			 IF  rg_csr_rpt_header.emp_type = 'LU'	THEN
				l_dimension:='_PER_LU_EMPLTYPE_TC_YTD';
				l_dimension1:='_PER_LU_YTD';
				l_dimension2:='_PER_LU_MONTH';
			ELSE
				l_dimension:='_PER_LE_EMPLTYPE_TC_YTD';
				l_dimension1:='_PER_LE_YTD';
				l_dimension2:='_PER_LE_MONTH';
			END IF ;

			-- fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 5');
			OPEN  csr_Get_Defined_Balance_Id( 'WITHHOLDING_TAX_BASE'||l_dimension1);
			FETCH csr_Get_Defined_Balance_Id INTO rg_csr_get_defined_balance_id;
			CLOSE csr_Get_Defined_Balance_Id;
			l_wtax_base :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;

			OPEN  csr_Get_Defined_Balance_Id( 'TAX_AT_SOURCE_BASE'||l_dimension1);
			FETCH csr_Get_Defined_Balance_Id INTO rg_csr_get_defined_balance_id;
			CLOSE csr_Get_Defined_Balance_Id;
			l_tstax_base :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;

			OPEN  csr_Get_Defined_Balance_Id( 'NOTIONAL_SALARY'||l_dimension1);
			FETCH csr_Get_Defined_Balance_Id INTO rg_csr_get_defined_balance_id;
			CLOSE csr_Get_Defined_Balance_Id;
			l_notional_base :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;

			-- fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 6');


			/*Determining Resident Type*/
			IF  l_wtax_base > 0 THEN
			       -- Finnish Resident
				l_person_type:= 'FI';
				l_record_id := 'VSPSERIE';
			ELSIF l_tstax_base > 0 THEN
			       -- Foreign Resident
				l_person_type:= 'FR';
				l_record_id := 'VSRAERIE';
			ELSIF l_notional_base > 0 THEN
			       -- Finnish Resident Working Abroad
				l_person_type:= 'WO';
				l_record_id := 'VSPSERIE';
			END IF;

			-- fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 7');

			-- Start Changes 2009
			/*Added for Codes 123,124 - VSPSERIE (For Finnish Residents Only) */
                        -- Code 123 - Car Benefit , Age category

			IF l_person_type = 'FI' THEN
			-- Code 123
			-- Allowed values (note that values will not change, only the rule
			-- for calculating the taxable value):
			-- A: (Mobilization year: 2008, 2007 or 2006)
			-- B: (Mobilization year: 2005, 2004 or 2003)
			-- C: Mobilization year 2002 or before)
			-- U: Car benefit used abroad

				OPEN csr_result_value(rg_csr_get_person_details.assignment_id,'Car Benefit','Mobilization Year');
				FETCH csr_result_value INTO l_mobilization_year;
				CLOSE csr_result_value;

				OPEN csr_result_value(rg_csr_get_person_details.assignment_id,'Car Benefit','Car Abroad');
				FETCH csr_result_value INTO l_car_abroad;
				CLOSE csr_result_value;

				IF l_car_abroad = 'Y' THEN
				l_age_category := 'U';
				ELSE
					IF l_mobilization_year IN (2008,2007,2006) THEN
					l_age_category := 'A';
					END IF;

					IF l_mobilization_year IN (2005,2004,2003) THEN
					l_age_category := 'B';
					END IF;

					IF l_mobilization_year <= 2002 AND l_mobilization_year > 0 THEN
					l_age_category := 'C';
					END IF;


				END IF;

			 -- Code 124 Full Car Benefit
			 -- Allowed Values
			 -- 0 = No
			 -- 1 = Yes

			        OPEN csr_result_value(rg_csr_get_person_details.assignment_id,'Car Benefit','Full Benefit');
				FETCH csr_result_value INTO l_full_car_ben;
				CLOSE csr_result_value;

				IF l_full_car_ben = 'Y' THEN
				l_car_ben_val := 1;
				ELSE
				l_car_ben_val := 0;
				END IF;

			 END IF;

			 -- Code-325 VSRAERIE - For Foreign Residents.
			 IF l_person_type = 'FR' THEN
				OPEN csr_bank_details (rg_csr_get_person_details.assignment_id,g_business_group_id,p_effective_date);
				FETCH csr_bank_details INTO rg_bank_details;
				CLOSE csr_bank_details;

                          l_bank_acc_num := rg_bank_details.Account_Number;
			  END IF;



			-- End changes 2009

			OPEN  csr_get_tax_card_type(rg_csr_get_person_details.assignment_id ,l_start_date, l_end_date  );
			FETCH csr_get_tax_card_type INTO l_tax_card_type;
			CLOSE csr_get_tax_card_type;

			-- fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 8');
			IF  l_tax_card_type IS NOT NULL AND l_person_type IS NOT NULL THEN
					-- fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 9');

					OPEN  csr_Get_Defined_Balance_Id( 'BENEFITS_IN_KIND'||l_dimension1);
					FETCH csr_Get_Defined_Balance_Id INTO rg_csr_get_defined_balance_id;
					CLOSE csr_Get_Defined_Balance_Id;

					l_bik :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;


					OPEN  csr_Get_Defined_Balance_Id( 'SALARY_INCOME'||l_dimension1);
					FETCH csr_Get_Defined_Balance_Id INTO rg_csr_get_defined_balance_id;
					CLOSE csr_Get_Defined_Balance_Id;

					l_salary_income :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;

					/*Low Paid Employees*/
					OPEN  csr_Get_Defined_Balance_Id( 'SUBSIDY_FOR_LOW_PAID_EMPLOYEES'||l_dimension1);
					FETCH csr_Get_Defined_Balance_Id INTO rg_csr_get_defined_balance_id;
					CLOSE csr_Get_Defined_Balance_Id;
					l_subsidy :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;

					IF l_subsidy > 0 THEN
						l_subsidy_status:='Y' ;
					END IF;

					-- fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 10');

				IF  l_person_type= 'FI' THEN

					/*Determining Payment Type*/
					OPEN  csr_Get_Defined_Balance_Id( 'WITHHOLDING_TAX_BASE'||l_dimension);
					FETCH csr_Get_Defined_Balance_Id INTO rg_csr_get_defined_balance_id;
					CLOSE csr_Get_Defined_Balance_Id;

					-- fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 11');

					IF   l_tax_card_type in ('P', 'C' ) THEN

						-- fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 12');
						l_ptp_1_wtax_base :=pay_balance_pkg.get_value
						(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id
						,P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id
						,P_TAX_UNIT_ID =>g_legal_employer_id
						,P_JURISDICTION_CODE =>NULL
						,P_SOURCE_ID =>NULL
						,P_SOURCE_TEXT =>'PEMP'
						,P_TAX_GROUP =>NULL
						,P_DATE_EARNED =>l_effective_date
						,P_GET_RR_ROUTE =>NULL
						,P_GET_RB_ROUTE =>NULL
						,P_SOURCE_TEXT2 =>'N'
						,P_SOURCE_NUMBER =>NULL
						,P_TIME_DEF_ID =>NULL
						,P_BALANCE_DATE =>NULL
						,P_PAYROLL_ID =>NULL
						,P_ORIGINAL_ENTRY_ID =>NULL
						,P_LOCAL_UNIT_ID =>g_local_unit_id
						,P_SOURCE_NUMBER2 =>NULL
						,P_ORGANIZATION_ID =>NULL
						) ;

						l_ptp_2_wtax_base :=pay_balance_pkg.get_value
						(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id
						,P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id
						,P_TAX_UNIT_ID =>g_legal_employer_id
						,P_JURISDICTION_CODE =>NULL
						,P_SOURCE_ID =>NULL
						,P_SOURCE_TEXT =>'PEMP'
						,P_TAX_GROUP =>NULL
						,P_DATE_EARNED =>l_effective_date
						,P_GET_RR_ROUTE =>NULL
						,P_GET_RB_ROUTE =>NULL
						,P_SOURCE_TEXT2 =>'S'
						,P_SOURCE_NUMBER =>NULL
						,P_TIME_DEF_ID =>NULL
						,P_BALANCE_DATE =>NULL
						,P_PAYROLL_ID =>NULL
						,P_ORIGINAL_ENTRY_ID =>NULL
						,P_LOCAL_UNIT_ID =>g_local_unit_id
						,P_SOURCE_NUMBER2 =>NULL
						,P_ORGANIZATION_ID =>NULL
						) ;

						-- fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 13');
					END IF;

					IF   l_tax_card_type in ('EI', 'FT','S' ) AND (l_ptp_1_wtax_base + l_ptp_2_wtax_base) <=0 THEN
						-- fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 14');
						l_pt1_1_wtax_base :=pay_balance_pkg.get_value
						(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id
						,P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id
						,P_TAX_UNIT_ID =>g_legal_employer_id
						,P_JURISDICTION_CODE =>NULL
						,P_SOURCE_ID =>NULL
						,P_SOURCE_TEXT =>'SEMP'
						,P_TAX_GROUP =>NULL
						,P_DATE_EARNED =>l_effective_date
						,P_GET_RR_ROUTE =>NULL
						,P_GET_RB_ROUTE =>NULL
						,P_SOURCE_TEXT2 =>'N'
						,P_SOURCE_NUMBER =>NULL
						,P_TIME_DEF_ID =>NULL
						,P_BALANCE_DATE =>NULL
						,P_PAYROLL_ID =>NULL
						,P_ORIGINAL_ENTRY_ID =>NULL
						,P_LOCAL_UNIT_ID =>g_local_unit_id
						,P_SOURCE_NUMBER2 =>NULL
						,P_ORGANIZATION_ID =>NULL
						) ;

						l_pt1_2_wtax_base :=pay_balance_pkg.get_value
						(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id
						,P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id
						,P_TAX_UNIT_ID =>g_legal_employer_id
						,P_JURISDICTION_CODE =>NULL
						,P_SOURCE_ID =>NULL
						,P_SOURCE_TEXT =>'SEMP'
						,P_TAX_GROUP =>NULL
						,P_DATE_EARNED =>l_effective_date
						,P_GET_RR_ROUTE =>NULL
						,P_GET_RB_ROUTE =>NULL
						,P_SOURCE_TEXT2 =>'S'
						,P_SOURCE_NUMBER =>NULL
						,P_TIME_DEF_ID =>NULL
						,P_BALANCE_DATE =>NULL
						,P_PAYROLL_ID =>NULL
						,P_ORIGINAL_ENTRY_ID =>NULL
						,P_LOCAL_UNIT_ID =>g_local_unit_id
						,P_SOURCE_NUMBER2 =>NULL
						,P_ORGANIZATION_ID =>NULL
						) ;
						-- fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 15');
					END IF;

					IF   l_tax_card_type in ('C','FT','EI','P', 'S'  )
					AND (l_ptp_1_wtax_base + l_ptp_2_wtax_base + l_pt1_1_wtax_base + l_pt1_2_wtax_base ) <=0 THEN
						-- fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 16');
						l_ptp2_1_wtax_base :=pay_balance_pkg.get_value
						(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id
						,P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id
						,P_TAX_UNIT_ID =>g_legal_employer_id
						,P_JURISDICTION_CODE =>NULL
						,P_SOURCE_ID =>NULL
						,P_SOURCE_TEXT =>'PEMP'
						,P_TAX_GROUP =>NULL
						,P_DATE_EARNED =>l_effective_date
						,P_GET_RR_ROUTE =>NULL
						,P_GET_RB_ROUTE =>NULL
						,P_SOURCE_TEXT2 =>'A'
						,P_SOURCE_NUMBER =>NULL
						,P_TIME_DEF_ID =>NULL
						,P_BALANCE_DATE =>NULL
						,P_PAYROLL_ID =>NULL
						,P_ORIGINAL_ENTRY_ID =>NULL
						,P_LOCAL_UNIT_ID =>g_local_unit_id
						,P_SOURCE_NUMBER2 =>NULL
						,P_ORGANIZATION_ID =>NULL
						) ;

						l_ptp2_2_wtax_base :=pay_balance_pkg.get_value
						(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id
						,P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id
						,P_TAX_UNIT_ID =>g_legal_employer_id
						,P_JURISDICTION_CODE =>NULL
						,P_SOURCE_ID =>NULL
						,P_SOURCE_TEXT =>'SEMP'
						,P_TAX_GROUP =>NULL
						,P_DATE_EARNED =>l_effective_date
						,P_GET_RR_ROUTE =>NULL
						,P_GET_RB_ROUTE =>NULL
						,P_SOURCE_TEXT2 =>'A'
						,P_SOURCE_NUMBER =>NULL
						,P_TIME_DEF_ID =>NULL
						,P_BALANCE_DATE =>NULL
						,P_PAYROLL_ID =>NULL
						,P_ORIGINAL_ENTRY_ID =>NULL
						,P_LOCAL_UNIT_ID =>g_local_unit_id
						,P_SOURCE_NUMBER2 =>NULL
						,P_ORGANIZATION_ID =>NULL
						) ;
						-- fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 17');

					END IF;


					IF   l_tax_card_type in ('EI', 'FT','S' )
					AND (l_ptp_1_wtax_base + l_ptp_2_wtax_base + l_pt1_1_wtax_base + l_pt1_2_wtax_base + l_ptp2_2_wtax_base + l_ptp2_2_wtax_base) <=0 THEN
						-- fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 18');
						l_pth_1_wtax_base :=pay_balance_pkg.get_value
						(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id
						,P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id
						,P_TAX_UNIT_ID =>g_legal_employer_id
						,P_JURISDICTION_CODE =>NULL
						,P_SOURCE_ID =>NULL
						,P_SOURCE_TEXT =>'PUNEMP'
						,P_TAX_GROUP =>NULL
						,P_DATE_EARNED =>l_effective_date
						,P_GET_RR_ROUTE =>NULL
						,P_GET_RB_ROUTE =>NULL
						,P_SOURCE_TEXT2 =>'N'
						,P_SOURCE_NUMBER =>NULL
						,P_TIME_DEF_ID =>NULL
						,P_BALANCE_DATE =>NULL
						,P_PAYROLL_ID =>NULL
						,P_ORIGINAL_ENTRY_ID =>NULL
						,P_LOCAL_UNIT_ID =>g_local_unit_id
						,P_SOURCE_NUMBER2 =>NULL
						,P_ORGANIZATION_ID =>NULL
						) ;

						l_pth_2_wtax_base :=pay_balance_pkg.get_value
						(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id
						,P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id
						,P_TAX_UNIT_ID =>g_legal_employer_id
						,P_JURISDICTION_CODE =>NULL
						,P_SOURCE_ID =>NULL
						,P_SOURCE_TEXT =>'SUNEMP'
						,P_TAX_GROUP =>NULL
						,P_DATE_EARNED =>l_effective_date
						,P_GET_RR_ROUTE =>NULL
						,P_GET_RB_ROUTE =>NULL
						,P_SOURCE_TEXT2 =>'N'
						,P_SOURCE_NUMBER =>NULL
						,P_TIME_DEF_ID =>NULL
						,P_BALANCE_DATE =>NULL
						,P_PAYROLL_ID =>NULL
						,P_ORIGINAL_ENTRY_ID =>NULL
						,P_LOCAL_UNIT_ID =>g_local_unit_id
						,P_SOURCE_NUMBER2 =>NULL
						,P_ORGANIZATION_ID =>NULL
						) ;

						-- fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 19');
					END IF;

					IF   l_tax_card_type in ('EI', 'FT','S' )
					AND (l_ptp_1_wtax_base + l_ptp_2_wtax_base + l_pt1_1_wtax_base + l_pt1_2_wtax_base + l_ptp2_2_wtax_base
					+ l_ptp2_2_wtax_base + l_pth_1_wtax_base + l_pth_2_wtax_base ) <=0 THEN
						-- fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 20');
						l_pth2_1_wtax_base :=pay_balance_pkg.get_value
						(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id
						,P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id
						,P_TAX_UNIT_ID =>g_legal_employer_id
						,P_JURISDICTION_CODE =>NULL
						,P_SOURCE_ID =>NULL
						,P_SOURCE_TEXT =>'PUNEMP'
						,P_TAX_GROUP =>NULL
						,P_DATE_EARNED =>l_effective_date
						,P_GET_RR_ROUTE =>NULL
						,P_GET_RB_ROUTE =>NULL
						,P_SOURCE_TEXT2 =>'A'
						,P_SOURCE_NUMBER =>NULL
						,P_TIME_DEF_ID =>NULL
						,P_BALANCE_DATE =>NULL
						,P_PAYROLL_ID =>NULL
						,P_ORIGINAL_ENTRY_ID =>NULL
						,P_LOCAL_UNIT_ID =>g_local_unit_id
						,P_SOURCE_NUMBER2 =>NULL
						,P_ORGANIZATION_ID =>NULL
						) ;

						l_pth2_2_wtax_base :=pay_balance_pkg.get_value
						(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id
						,P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id
						,P_TAX_UNIT_ID =>g_legal_employer_id
						,P_JURISDICTION_CODE =>NULL
						,P_SOURCE_ID =>NULL
						,P_SOURCE_TEXT =>'SUNEMP'
						,P_TAX_GROUP =>NULL
						,P_DATE_EARNED =>l_effective_date
						,P_GET_RR_ROUTE =>NULL
						,P_GET_RB_ROUTE =>NULL
						,P_SOURCE_TEXT2 =>'A'
						,P_SOURCE_NUMBER =>NULL
						,P_TIME_DEF_ID =>NULL
						,P_BALANCE_DATE =>NULL
						,P_PAYROLL_ID =>NULL
						,P_ORIGINAL_ENTRY_ID =>NULL
						,P_LOCAL_UNIT_ID =>g_local_unit_id
						,P_SOURCE_NUMBER2 =>NULL
						,P_ORGANIZATION_ID =>NULL
						) ;
						-- fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 21');
					END IF;
					-- fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 22');
					/*Determining Contexts*/
					IF   l_tax_card_type IN ('P', 'C' ) AND ( l_ptp_1_wtax_base +  l_ptp_2_wtax_base ) > 0 THEN
						l_payment_type:= 'P';
						IF l_ptp_1_wtax_base  > 0 THEN
							l_source_text :='PEMP';
							l_source_text2 :='N';
							l_tax_base:=l_ptp_1_wtax_base;
						ELSE
							l_source_text :='PEMP';
							l_source_text2 :='S';
							l_tax_base:=l_ptp_2_wtax_base;
						END IF;
					ELSIF l_tax_card_type in ('EI', 'FT','S' )  AND (l_pt1_1_wtax_base  +  l_pt1_2_wtax_base ) > 0 THEN
						l_payment_type:= '1';
						IF l_pt1_1_wtax_base  > 0 THEN
							l_source_text :='SEMP';
							l_source_text2 :='N';
							l_tax_base:=l_pt1_1_wtax_base;
						ELSE
							l_source_text :='SEMP';
							l_source_text2 :='S';
							l_tax_base:=l_pt1_2_wtax_base;
						END IF;
					ELSIF  l_tax_card_type in ('C','FT','EI','P', 'S'  )  AND (l_ptp2_1_wtax_base  +  l_ptp2_2_wtax_base) > 0 THEN
						l_payment_type:= 'P2';
						IF l_ptp2_1_wtax_base  > 0 THEN
							l_source_text :='PEMP';
							l_source_text2 :='A';
							l_tax_base:=l_ptp2_1_wtax_base;
						ELSE
							l_source_text :='SEMP';
							l_source_text2 :='A';
							l_tax_base:=l_ptp2_2_wtax_base;
						END IF;

					ELSIF l_tax_card_type in ('EI', 'FT','S' )  AND (l_pth_1_wtax_base  +  l_pth_2_wtax_base ) > 0 THEN
						l_payment_type:= 'H';
						IF l_pth_1_wtax_base  > 0 THEN
							l_source_text :='PUNEMP';
							l_source_text2 :='N';
							l_tax_base:=l_pth_1_wtax_base;
						ELSE
							l_source_text :='SUNEMP';
							l_source_text2 :='N';
							l_tax_base:=l_pth_2_wtax_base;
						END IF;

					ELSIF l_tax_card_type in ('EI', 'FT','S' )  AND (l_pth2_1_wtax_base  +  l_pth2_2_wtax_base ) > 0 THEN
						l_payment_type:= 'H2';
						IF l_pth2_1_wtax_base  > 0 THEN
							l_source_text :='PUNEMP';
							l_source_text2 :='A';
							l_tax_base:=l_pth2_1_wtax_base;
						ELSE
							l_source_text :='SUNEMP';
							l_source_text2 :='A';
							l_tax_base:=l_pth2_2_wtax_base;
						END IF;
					END IF;


					/*Fetching Balance values*/
					OPEN  csr_Get_Defined_Balance_Id( 'WITHHOLDING_TAX'||l_dimension1);
					FETCH csr_Get_Defined_Balance_Id INTO rg_csr_get_defined_balance_id;
					CLOSE csr_Get_Defined_Balance_Id;

					l_tax :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;

					OPEN  csr_Get_Defined_Balance_Id( 'PENSION'||l_dimension1);
					FETCH csr_Get_Defined_Balance_Id INTO rg_csr_get_defined_balance_id;
					CLOSE csr_Get_Defined_Balance_Id;

					l_empl_pension :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;

					OPEN  csr_Get_Defined_Balance_Id( 'UNEMPLOYMENT_INSURANCE'||l_dimension1);
					FETCH csr_Get_Defined_Balance_Id INTO rg_csr_get_defined_balance_id;
					CLOSE csr_Get_Defined_Balance_Id;

					l_empl_unemp_ins :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;

					OPEN  csr_Get_Defined_Balance_Id( 'CUMULATIVE_CAR_BENEFIT'||l_dimension1);
					FETCH csr_Get_Defined_Balance_Id INTO rg_csr_get_defined_balance_id;
					CLOSE csr_Get_Defined_Balance_Id;

					l_cum_car_benefit :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;

					OPEN  csr_Get_Defined_Balance_Id( 'CUMULATIVE_VEHICLE_MILEAGE'||l_dimension1);
					FETCH csr_Get_Defined_Balance_Id INTO rg_csr_get_defined_balance_id;
					CLOSE csr_Get_Defined_Balance_Id;

					l_cum_mileage :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;

					-- fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 23');
					BEGIN
						FOR     balance_rec IN  csr_balance('Mortgage Benefit' , rg_csr_get_person_details.business_group_id)
						LOOP
							OPEN  csr_bg_Get_Defined_Balance_Id( balance_rec.balance_name||l_dimension1,rg_csr_get_person_details.business_group_id);
							FETCH csr_bg_Get_Defined_Balance_Id INTO rg_csr_bg_get_defined_bal_id;
							CLOSE csr_bg_Get_Defined_Balance_Id;
							IF  csr_balance%FOUND THEN
								l_mortgage_bik :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_bg_get_defined_bal_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;
								l_tot_mortgage_bik := l_tot_mortgage_bik + l_mortgage_bik;
							END IF;
						END LOOP ;

						IF  l_tot_mortgage_bik  > 0 THEN
							l_mortgage_bik_status := 1;
						ELSE
							l_mortgage_bik_status := 0;
						END IF;
					EXCEPTION
						WHEN others THEN
						null;
					END;

					BEGIN
						FOR     balance_rec IN  csr_balance('Other Benefits' , rg_csr_get_person_details.business_group_id)
						LOOP
							OPEN  csr_bg_Get_Defined_Balance_Id( balance_rec.balance_name||l_dimension1,rg_csr_get_person_details.business_group_id);
							FETCH csr_bg_Get_Defined_Balance_Id INTO rg_csr_bg_get_defined_bal_id;
							CLOSE csr_bg_Get_Defined_Balance_Id;
							IF  csr_balance%FOUND THEN
								l_other_bik :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_bg_get_defined_bal_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;
								l_tot_other_bik := l_tot_other_bik + l_other_bik;
							END IF;
						END LOOP ;

						IF  l_tot_other_bik  > 0 THEN
							l_other_bik_status := 1;
						ELSE
							l_other_bik_status := 0;
						END IF;


					EXCEPTION
					WHEN others THEN
						null;
					END;

					BEGIN
						FOR     balance_rec IN  csr_balance('Housing Benefit' , rg_csr_get_person_details.business_group_id)
						LOOP
							OPEN  csr_bg_Get_Defined_Balance_Id( balance_rec.balance_name||l_dimension1,rg_csr_get_person_details.business_group_id);
							FETCH csr_bg_Get_Defined_Balance_Id INTO rg_csr_bg_get_defined_bal_id;
							CLOSE csr_bg_Get_Defined_Balance_Id;
							IF  csr_balance%FOUND THEN
								l_housing_bik :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_bg_get_defined_bal_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;
								l_tot_housing_bik := l_tot_housing_bik + l_housing_bik;
							END IF;
						END LOOP ;

						IF  l_tot_housing_bik  > 0 THEN
							l_housing_bik_status := 1;
						ELSE
							l_housing_bik_status := 0;
						END IF;
					EXCEPTION
					WHEN others THEN
						null;
					END;

					BEGIN
						FOR     balance_rec IN  csr_balance('Phone Benefit' , rg_csr_get_person_details.business_group_id)
						LOOP
							OPEN  csr_bg_Get_Defined_Balance_Id( balance_rec.balance_name||l_dimension1,rg_csr_get_person_details.business_group_id);
							FETCH csr_bg_Get_Defined_Balance_Id INTO rg_csr_bg_get_defined_bal_id;
							CLOSE csr_bg_Get_Defined_Balance_Id;
							IF  csr_balance%FOUND THEN
								l_phone_bik :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_bg_get_defined_bal_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;
								l_tot_phone_bik := l_tot_phone_bik + l_phone_bik;
							END IF;
						END LOOP ;

                                                ---- Code added below for Phone Benefit Added Minor Legislative Changes
						-- Bug 8425533
						OPEN  csr_Get_Defined_Balance_Id( 'PHONE_BENEFIT'||l_dimension1);
						FETCH csr_Get_Defined_Balance_Id INTO rg_csr_get_defined_balance_id;
						CLOSE csr_Get_Defined_Balance_Id;
						l_phone_bik :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;
						l_tot_phone_bik := l_tot_phone_bik + l_phone_bik;

						IF  l_tot_phone_bik  > 0 THEN
							l_phone_bik_status := 1;
						ELSE
							l_phone_bik_status := 0;
						END IF;
					EXCEPTION
					WHEN others THEN
						null;
					END;


					OPEN  csr_Get_Defined_Balance_Id('LUNCH_BENEFIT'||l_dimension1);
					FETCH csr_Get_Defined_Balance_Id INTO rg_csr_get_defined_balance_id;
					CLOSE csr_Get_Defined_Balance_Id;

					l_lunch_bik :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;

					IF  l_lunch_bik  > 0 THEN
						l_lunch_bik_status := 1;
					ELSE
						l_lunch_bik_status := 0;
					END IF;

					OPEN  csr_Get_Defined_Balance_Id( 'HALF_DAY_ALLOWANCE_EXPENSES'||l_dimension1);
					FETCH csr_Get_Defined_Balance_Id INTO rg_csr_get_defined_balance_id;
					CLOSE csr_Get_Defined_Balance_Id;

					l_half_day_allowance_expenses :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;

					IF l_half_day_allowance_expenses > 0 THEN
					l_half_day_allowance_status :=1;
					ELSE
					l_half_day_allowance_status :=0;
					END IF;


					OPEN  csr_Get_Defined_Balance_Id( 'DAILY_ALLOWANCE_DOMESTIC_EXPENSES'||l_dimension1);
					FETCH csr_Get_Defined_Balance_Id INTO rg_csr_get_defined_balance_id;
					CLOSE csr_Get_Defined_Balance_Id;

					l_daily_allowance_d_expenses :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;
					IF l_daily_allowance_d_expenses > 0 THEN
						l_daily_allowance_d_status :=1;
					ELSE
						l_daily_allowance_d_status :=0;
					END IF;


					OPEN  csr_Get_Defined_Balance_Id( 'DAILY_ALLOWANCE_FOREIGN_EXPENSES'||l_dimension1);
					FETCH csr_Get_Defined_Balance_Id INTO rg_csr_get_defined_balance_id;
					CLOSE csr_Get_Defined_Balance_Id;

					l_daily_allowance_fe_expenses :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;
					IF l_daily_allowance_fe_expenses > 0 THEN
						l_daily_allowance_fe_status :=1;
					ELSE
						l_daily_allowance_fe_status :=0;
					END IF;


					OPEN  csr_Get_Defined_Balance_Id( 'MEAL_COMPENSATION_EXPENSES'||l_dimension1);
					FETCH csr_Get_Defined_Balance_Id INTO rg_csr_get_defined_balance_id;
					CLOSE csr_Get_Defined_Balance_Id;

					l_meal_comp_expenses :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;

					IF l_meal_comp_expenses > 0 THEN
						l_meal_comp_status :=1;
					ELSE
						l_meal_comp_status :=0;
					END IF;

					OPEN  csr_Get_Defined_Balance_Id( 'TAX_FREE_MILEAGE_EXPENSES'||l_dimension1);
					FETCH csr_Get_Defined_Balance_Id INTO rg_csr_get_defined_balance_id;
					CLOSE csr_Get_Defined_Balance_Id;

					l_tax_free_mileage_expenses :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;


					OPEN  csr_Get_Defined_Balance_Id( 'TAX_FREE_MILEAGE'||l_dimension1);
					FETCH csr_Get_Defined_Balance_Id INTO rg_csr_get_defined_balance_id;
					CLOSE csr_Get_Defined_Balance_Id;

					l_tax_free_mileage :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;

					BEGIN
						FOR        balance_rec IN  csr_balance('Stock Options Benefit' , rg_csr_get_person_details.business_group_id)
						LOOP
							OPEN  csr_bg_Get_Defined_Balance_Id( balance_rec.balance_name||l_dimension1,rg_csr_get_person_details.business_group_id);
							FETCH csr_bg_Get_Defined_Balance_Id INTO rg_csr_bg_get_defined_bal_id;
							CLOSE csr_bg_Get_Defined_Balance_Id;
							IF  csr_balance%FOUND THEN
								l_stock_option_bik :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_bg_get_defined_bal_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;
								l_tot_stock_option_bik := l_tot_stock_option_bik + l_stock_option_bik;
							END IF;
						END LOOP ;
					EXCEPTION
					WHEN others THEN
						null;
					END;

					OPEN  csr_Get_Defined_Balance_Id( 'EMPLOYER_PENSION'||l_dimension1);
					FETCH csr_Get_Defined_Balance_Id INTO rg_csr_get_defined_balance_id;
					CLOSE csr_Get_Defined_Balance_Id;

					l_emp_pension :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;

					BEGIN
						FOR     balance_rec IN  csr_balance('Travel Ticket Benefit' , rg_csr_get_person_details.business_group_id)
						LOOP
							OPEN  csr_bg_Get_Defined_Balance_Id( balance_rec.balance_name||l_dimension1,rg_csr_get_person_details.business_group_id);
							FETCH csr_bg_Get_Defined_Balance_Id INTO rg_csr_bg_get_defined_bal_id;
							CLOSE csr_bg_Get_Defined_Balance_Id;
							IF  csr_balance%FOUND THEN
								l_travel_ticket_bik :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_bg_get_defined_bal_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;
								l_tot_travel_ticket_bik := l_tot_travel_ticket_bik + l_travel_ticket_bik;
							END IF;
						END LOOP ;

						IF  l_tot_travel_ticket_bik  > 0 THEN
							l_travel_ticket_bik_status := 1;
						ELSE
							l_travel_ticket_bik_status := 0;
						END IF;
					EXCEPTION
					WHEN others THEN
						null;
					END;


					BEGIN
						FOR     balance_rec IN  csr_balance('Other Benefits Deductions' , rg_csr_get_person_details.business_group_id)
						LOOP
							OPEN  csr_bg_Get_Defined_Balance_Id( balance_rec.balance_name||l_dimension1,rg_csr_get_person_details.business_group_id);
							FETCH csr_bg_Get_Defined_Balance_Id INTO rg_csr_bg_get_defined_bal_id;
							CLOSE csr_bg_Get_Defined_Balance_Id;
							IF  csr_balance%FOUND THEN
								l_other_bik_ded :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_bg_get_defined_bal_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;
								l_tot_other_bik_ded := l_tot_other_bik_ded + l_other_bik_ded;
							END IF;
						END LOOP ;

					EXCEPTION
					WHEN others THEN
						null;
					END;


					BEGIN
						FOR     balance_rec IN  csr_balance('Car Benefit Deductions' , rg_csr_get_person_details.business_group_id)
						LOOP
							OPEN  csr_bg_Get_Defined_Balance_Id( balance_rec.balance_name||l_dimension1,rg_csr_get_person_details.business_group_id);
							FETCH csr_bg_Get_Defined_Balance_Id INTO rg_csr_bg_get_defined_bal_id;
							CLOSE csr_bg_Get_Defined_Balance_Id;
							IF  csr_balance%FOUND THEN
								l_car_bik_ded :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_bg_get_defined_bal_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;
								l_tot_car_bik_ded := l_tot_car_bik_ded + l_car_bik_ded;
							END IF;
						END LOOP ;

					EXCEPTION
					WHEN others THEN
						null;
					END;

					BEGIN
						FOR     balance_rec IN  csr_balance('Lunch Benefit Deductions' , rg_csr_get_person_details.business_group_id)
						LOOP
							OPEN  csr_bg_Get_Defined_Balance_Id( balance_rec.balance_name||l_dimension1,rg_csr_get_person_details.business_group_id);
							FETCH csr_bg_Get_Defined_Balance_Id INTO rg_csr_bg_get_defined_bal_id;
							CLOSE csr_bg_Get_Defined_Balance_Id;
							IF  csr_balance%FOUND THEN
								l_lunch_bik_ded :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_bg_get_defined_bal_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;
								l_tot_lunch_bik_ded := l_tot_lunch_bik_ded + l_lunch_bik_ded;
							END IF;
						END LOOP ;

						IF  l_tot_lunch_bik_ded  > 0 THEN
							l_lunch_bik_ded_status := 1;
						ELSE
							l_lunch_bik_ded_status := 0;
						END IF;
					EXCEPTION
					WHEN others THEN
						null;
					END;

					OPEN  csr_Get_Defined_Balance_Id( 'TAXABLE_COMPENSATION'||l_dimension1);
					FETCH csr_Get_Defined_Balance_Id INTO rg_csr_get_defined_balance_id;
					CLOSE csr_Get_Defined_Balance_Id;

					l_tax_comp :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;

					BEGIN
						FOR     balance_rec IN  csr_balance('Payments for Elected Official' , rg_csr_get_person_details.business_group_id)
						LOOP
							OPEN  csr_bg_Get_Defined_Balance_Id( balance_rec.balance_name||l_dimension1,rg_csr_get_person_details.business_group_id);
							FETCH csr_bg_Get_Defined_Balance_Id INTO rg_csr_bg_get_defined_bal_id;
							CLOSE csr_bg_Get_Defined_Balance_Id;
							IF  csr_balance%FOUND THEN
								l_pay_eoff :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_bg_get_defined_bal_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;
								l_tot_pay_eoff := l_tot_pay_eoff + l_pay_eoff;
							END IF;
						END LOOP ;
					EXCEPTION
					WHEN others THEN
						null;
					END;


				BEGIN
						FOR     balance_rec IN  csr_balance('Voluntary  PI Fees' , rg_csr_get_person_details.business_group_id)
						LOOP
							OPEN  csr_bg_Get_Defined_Balance_Id( balance_rec.balance_name||l_dimension1,rg_csr_get_person_details.business_group_id);
							FETCH csr_bg_Get_Defined_Balance_Id INTO rg_csr_bg_get_defined_bal_id;
							CLOSE csr_bg_Get_Defined_Balance_Id;
							IF  csr_balance%FOUND THEN
								l_vol_pi :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_bg_get_defined_bal_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;
								l_tot_vol_pi := l_tot_vol_pi + l_vol_pi;
							END IF;
						END LOOP ;
					EXCEPTION
					WHEN others THEN
						null;
					END;

				BEGIN
						FOR     balance_rec IN  csr_balance('Total Voluntary  PI Fees' , rg_csr_get_person_details.business_group_id)
						LOOP
							OPEN  csr_bg_Get_Defined_Balance_Id( balance_rec.balance_name||l_dimension1,rg_csr_get_person_details.business_group_id);
							FETCH csr_bg_Get_Defined_Balance_Id INTO rg_csr_bg_get_defined_bal_id;
							CLOSE csr_bg_Get_Defined_Balance_Id;
							IF  csr_balance%FOUND THEN
								l_total_vol_pi :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_bg_get_defined_bal_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;
								l_tot_total_vol_pi := l_tot_total_vol_pi + l_total_vol_pi;
							END IF;
						END LOOP ;
					EXCEPTION
					WHEN others THEN
						null;
					END;


					OPEN  csr_Get_Defined_Balance_Id( 'TAXABLE_EXPENSES'||l_dimension1);
					FETCH csr_Get_Defined_Balance_Id INTO rg_csr_get_defined_balance_id;
					CLOSE csr_Get_Defined_Balance_Id;
					l_te :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;

					OPEN  csr_Get_Defined_Balance_Id( 'TAXABLE_EXPENSES_SUBJECT_TO_SOCIAL_SECURITY'||l_dimension1);
					FETCH csr_Get_Defined_Balance_Id INTO rg_csr_get_defined_balance_id;
					CLOSE csr_Get_Defined_Balance_Id;
					l_te_ss :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;
					l_te_exem_ss :=l_te - l_te_ss;

					OPEN  csr_Get_Defined_Balance_Id( 'BIK_SUBJECT_TO_SOCIAL_SECURITY'||l_dimension1);
					FETCH csr_Get_Defined_Balance_Id INTO rg_csr_get_defined_balance_id;
					CLOSE csr_Get_Defined_Balance_Id;

					l_bik_ss :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;
					l_bik_exem_ss :=l_bik - l_bik_ss;

					OPEN  csr_Get_Defined_Balance_Id( 'SALARY_SUBJECT_TO_SOCIAL_SECURITY'||l_dimension1);
					FETCH csr_Get_Defined_Balance_Id INTO rg_csr_get_defined_balance_id;
					CLOSE csr_Get_Defined_Balance_Id;

					l_sm_ss :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;
					l_sm_exem_ss := l_salary_income - l_sm_ss;

					l_tot_exem_ss := l_te_exem_ss + l_bik_exem_ss + l_sm_exem_ss;

					OPEN  csr_Get_Defined_Balance_Id( 'EXEMPTED_SOCIAL_SECURITY'||l_dimension1);
					FETCH csr_Get_Defined_Balance_Id INTO rg_csr_get_defined_balance_id;
					CLOSE csr_Get_Defined_Balance_Id;

					l_exem_ss :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;

					BEGIN
						FOR     balance_rec IN  csr_balance('Social Security Fee Deductions' , rg_csr_get_person_details.business_group_id)
						LOOP
							OPEN  csr_bg_Get_Defined_Balance_Id( balance_rec.balance_name||l_dimension1,rg_csr_get_person_details.business_group_id);
							FETCH csr_bg_Get_Defined_Balance_Id INTO rg_csr_bg_get_defined_bal_id;
							CLOSE csr_bg_Get_Defined_Balance_Id;
							IF  csr_balance%FOUND THEN
								l_ss_ded :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_bg_get_defined_bal_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;
								l_tot_ss_ded := l_tot_ss_ded + l_ss_ded;
							END IF;
						END LOOP ;
					EXCEPTION
					WHEN others THEN
						null;
					END;

						l_631:= l_tot_ss_ded + l_exem_ss;

					-- fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 24');



				ELSIF  l_person_type= 'FR' THEN

					-- fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 25');

					/*Determining Payment Type*/
					OPEN  csr_Get_Defined_Balance_Id( 'TAX_AT_SOURCE_BASE'||l_dimension);
					FETCH csr_Get_Defined_Balance_Id INTO rg_csr_get_defined_balance_id;
					CLOSE csr_Get_Defined_Balance_Id;

					l_pta1_1_tstax_base :=pay_balance_pkg.get_value
					(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id
					,P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id
					,P_TAX_UNIT_ID =>g_legal_employer_id
					,P_JURISDICTION_CODE =>NULL
					,P_SOURCE_ID =>NULL
					,P_SOURCE_TEXT =>'PEMP'
					,P_TAX_GROUP =>NULL
					,P_DATE_EARNED =>l_effective_date
					,P_GET_RR_ROUTE =>NULL
					,P_GET_RB_ROUTE =>NULL
					,P_SOURCE_TEXT2 =>'N'
					,P_SOURCE_NUMBER =>NULL
					,P_TIME_DEF_ID =>NULL
					,P_BALANCE_DATE =>NULL
					,P_PAYROLL_ID =>NULL
					,P_ORIGINAL_ENTRY_ID =>NULL
					,P_LOCAL_UNIT_ID =>g_local_unit_id
					,P_SOURCE_NUMBER2 =>NULL
					,P_ORGANIZATION_ID =>NULL
					) ;

					IF l_pta1_1_tstax_base <= 0 THEN
						l_pta1_2_tstax_base :=pay_balance_pkg.get_value
						(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id
						,P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id
						,P_TAX_UNIT_ID =>g_legal_employer_id
						,P_JURISDICTION_CODE =>NULL
						,P_SOURCE_ID =>NULL
						,P_SOURCE_TEXT =>'PEMP'
						,P_TAX_GROUP =>NULL
						,P_DATE_EARNED =>l_effective_date
						,P_GET_RR_ROUTE =>NULL
						,P_GET_RB_ROUTE =>NULL
						,P_SOURCE_TEXT2 =>'S'
						,P_SOURCE_NUMBER =>NULL
						,P_TIME_DEF_ID =>NULL
						,P_BALANCE_DATE =>NULL
						,P_PAYROLL_ID =>NULL
						,P_ORIGINAL_ENTRY_ID =>NULL
						,P_LOCAL_UNIT_ID =>g_local_unit_id
						,P_SOURCE_NUMBER2 =>NULL
						,P_ORGANIZATION_ID =>NULL
						) ;
					END IF;

						l_pta2_1_tstax_base := l_pta1_1_tstax_base;

						l_pta2_2_tstax_base :=l_pta1_2_tstax_base;

					IF (l_pta1_1_tstax_base + l_pta1_2_tstax_base + l_pta2_1_tstax_base + l_pta2_2_tstax_base ) <= 0 THEN
						l_pta4_1_tstax_base :=pay_balance_pkg.get_value
						(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id
						,P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id
						,P_TAX_UNIT_ID =>g_legal_employer_id
						,P_JURISDICTION_CODE =>NULL
						,P_SOURCE_ID =>NULL
						,P_SOURCE_TEXT =>'PUNEMP'
						,P_TAX_GROUP =>NULL
						,P_DATE_EARNED =>l_effective_date
						,P_GET_RR_ROUTE =>NULL
						,P_GET_RB_ROUTE =>NULL
						,P_SOURCE_TEXT2 =>'N'
						,P_SOURCE_NUMBER =>NULL
						,P_TIME_DEF_ID =>NULL
						,P_BALANCE_DATE =>NULL
						,P_PAYROLL_ID =>NULL
						,P_ORIGINAL_ENTRY_ID =>NULL
						,P_LOCAL_UNIT_ID =>g_local_unit_id
						,P_SOURCE_NUMBER2 =>NULL
						,P_ORGANIZATION_ID =>NULL
						) ;
					END IF;

					IF (l_pta1_1_tstax_base + l_pta1_2_tstax_base + l_pta2_1_tstax_base + l_pta2_2_tstax_base + l_pta4_1_tstax_base ) <= 0 THEN
						l_pta5_1_tstax_base :=pay_balance_pkg.get_value
						(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id
						,P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id
						,P_TAX_UNIT_ID =>g_legal_employer_id
						,P_JURISDICTION_CODE =>NULL
						,P_SOURCE_ID =>NULL
						,P_SOURCE_TEXT =>'PUNEMP'
						,P_TAX_GROUP =>NULL
						,P_DATE_EARNED =>l_effective_date
						,P_GET_RR_ROUTE =>NULL
						,P_GET_RB_ROUTE =>NULL
						,P_SOURCE_TEXT2 =>'PA'
						,P_SOURCE_NUMBER =>NULL
						,P_TIME_DEF_ID =>NULL
						,P_BALANCE_DATE =>NULL
						,P_PAYROLL_ID =>NULL
						,P_ORIGINAL_ENTRY_ID =>NULL
						,P_LOCAL_UNIT_ID =>g_local_unit_id
						,P_SOURCE_NUMBER2 =>NULL
						,P_ORGANIZATION_ID =>NULL
						) ;
					END IF;

					IF (l_pta1_1_tstax_base + l_pta1_2_tstax_base + l_pta2_1_tstax_base + l_pta2_2_tstax_base + l_pta4_1_tstax_base + l_pta5_1_tstax_base ) <= 0 THEN
						l_pta6_1_tstax_base :=pay_balance_pkg.get_value
						(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id
						,P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id
						,P_TAX_UNIT_ID =>g_legal_employer_id
						,P_JURISDICTION_CODE =>NULL
						,P_SOURCE_ID =>NULL
						,P_SOURCE_TEXT =>'PUNEMP'
						,P_TAX_GROUP =>NULL
						,P_DATE_EARNED =>l_effective_date
						,P_GET_RR_ROUTE =>NULL
						,P_GET_RB_ROUTE =>NULL
						,P_SOURCE_TEXT2 =>'A'
						,P_SOURCE_NUMBER =>NULL
						,P_TIME_DEF_ID =>NULL
						,P_BALANCE_DATE =>NULL
						,P_PAYROLL_ID =>NULL
						,P_ORIGINAL_ENTRY_ID =>NULL
						,P_LOCAL_UNIT_ID =>g_local_unit_id
						,P_SOURCE_NUMBER2 =>NULL
						,P_ORGANIZATION_ID =>NULL
						) ;
					END IF;

					IF (l_pta1_1_tstax_base + l_pta1_2_tstax_base + l_pta2_1_tstax_base + l_pta2_2_tstax_base + l_pta4_1_tstax_base + l_pta5_1_tstax_base + l_pta6_1_tstax_base) <= 0 THEN
						 l_pta7_1_tstax_base:=pay_balance_pkg.get_value
						(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id
						,P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id
						,P_TAX_UNIT_ID =>g_legal_employer_id
						,P_JURISDICTION_CODE =>NULL
						,P_SOURCE_ID =>NULL
						,P_SOURCE_TEXT =>'PEMP'
						,P_TAX_GROUP =>NULL
						,P_DATE_EARNED =>l_effective_date
						,P_GET_RR_ROUTE =>NULL
						,P_GET_RB_ROUTE =>NULL
						,P_SOURCE_TEXT2 =>'KP'
						,P_SOURCE_NUMBER =>NULL
						,P_TIME_DEF_ID =>NULL
						,P_BALANCE_DATE =>NULL
						,P_PAYROLL_ID =>NULL
						,P_ORIGINAL_ENTRY_ID =>NULL
						,P_LOCAL_UNIT_ID =>g_local_unit_id
						,P_SOURCE_NUMBER2 =>NULL
						,P_ORGANIZATION_ID =>NULL
						) ;
					END IF;
					-- fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 26');
					l_org_type:=rg_csr_rpt_header.org_type;

					/*Determining Contexts*/
					IF   l_tax_card_type IN ('TS' ) THEN
						-- fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 26'||l_tax_card_type);

						IF  (l_pta1_1_tstax_base  +  l_pta1_2_tstax_base) > 0  AND l_org_type = 'PRIV' THEN
							l_payment_type:= 'A1';
							IF l_pta1_1_tstax_base  > 0 THEN
								l_source_text :='PEMP';
								l_source_text2 :='N';
								l_tax_base:=l_pta1_1_tstax_base;
							ELSE
								l_source_text :='PEMP';
								l_source_text2 :='S';
								l_tax_base:=l_pta1_2_tstax_base;
							END IF;

						ELSIF (l_pta2_1_tstax_base  +  l_pta2_2_tstax_base) > 0  AND l_org_type = 'PUB' THEN
							l_payment_type:= 'A2';
							IF l_pta1_1_tstax_base  > 0 THEN
								l_source_text :='PEMP';
								l_source_text2 :='N';
								l_tax_base:=l_pta2_1_tstax_base;
							ELSE
								l_source_text :='PEMP';
								l_source_text2 :='S';
								l_tax_base:=l_pta2_2_tstax_base;
							END IF;

						ELSIF (l_pta4_1_tstax_base  > 0 )  THEN
								l_payment_type:= 'A4';
								l_source_text :='PUNEMP';
								l_source_text2 :='N' ;
								l_tax_base:=l_pta4_1_tstax_base;
						ELSIF (l_pta5_1_tstax_base  > 0 )  THEN
								l_payment_type:= 'A5';
								l_source_text :='PUNEMP';
								l_source_text2 :='PA' ;
								l_tax_base:=l_pta5_1_tstax_base;
						ELSIF (l_pta6_1_tstax_base  > 0 )  THEN
								l_payment_type:= 'A6';
								l_source_text :='PUNEMP';
								l_source_text2 :='A' ;
								l_tax_base:=l_pta6_1_tstax_base;
						ELSIF (l_pta7_1_tstax_base  > 0 )  THEN
								l_payment_type:= 'A7';
								l_source_text :='PEMP';
								l_source_text2 :='KP' ;
								l_tax_base:=l_pta7_1_tstax_base;
						END IF;
						-- fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 27');
						/* Fetching Person Address Details */
						OPEN  csr_per_address(  rg_csr_get_person_details.person_id , rg_csr_get_person_details.business_group_id );
						FETCH csr_per_address INTO rg_csr_per_address;
						CLOSE csr_per_address;

						OPEN  csr_Get_Defined_Balance_Id( 'TAX_AT_SOURCE'||l_dimension1);
						FETCH csr_Get_Defined_Balance_Id INTO rg_csr_get_defined_balance_id;
						CLOSE csr_Get_Defined_Balance_Id;

						l_tax :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;


						OPEN  csr_Get_Defined_Balance_Id( 'SOCIAL_SECURITY'||l_dimension1);
						FETCH csr_Get_Defined_Balance_Id INTO rg_csr_get_defined_balance_id;
						CLOSE csr_Get_Defined_Balance_Id;

						l_social_security :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;

						/* Cursor to fetch country code against which Tax Agreement is present*/
						OPEN  csr_country( rg_csr_get_person_details.place_residence);
						FETCH csr_country INTO rg_csr_country;
						CLOSE csr_country;

						IF rg_csr_country. territory_short_name IS NOT NULL THEN
							BEGIN
								l_tax_status:=hruserdt.get_table_value(g_business_group_id,'FI_REGIONAL_MEMBERSHIP','TAX AGREEMENT',rg_csr_country. territory_short_name,l_effective_date);
							EXCEPTION
							WHEN OTHERS THEN
								NULL;
							END;
						END IF;

						IF l_tax_status<>'Y' THEN
							l_country_code:=null;
							l_place_residence:=rg_csr_country. territory_name ;
						ELSE
							l_country_code:=rg_csr_get_person_details.place_residence;
							l_place_residence:=null;
						END IF;

					END IF;
					-- fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 28');

				ELSIF  l_person_type= 'WO' THEN

						l_payment_type:= '5';
/*
					-- fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 29');
					OPEN  csr_Get_Defined_Balance_Id( 'NOTIONAL_SALARY'||l_dimension);
					FETCH csr_Get_Defined_Balance_Id INTO rg_csr_get_defined_balance_id;
					CLOSE csr_Get_Defined_Balance_Id;

					l_pt5_1_wtax_base :=pay_balance_pkg.get_value
					(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id
					,P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id
					,P_TAX_UNIT_ID =>g_legal_employer_id
					,P_JURISDICTION_CODE =>NULL
					,P_SOURCE_ID =>NULL
					,P_SOURCE_TEXT =>'PEMP'
					,P_TAX_GROUP =>NULL
					,P_DATE_EARNED =>l_effective_date
					,P_GET_RR_ROUTE =>NULL
					,P_GET_RB_ROUTE =>NULL
					,P_SOURCE_TEXT2 =>'WO'
					,P_SOURCE_NUMBER =>NULL
					,P_TIME_DEF_ID =>NULL
					,P_BALANCE_DATE =>NULL
					,P_PAYROLL_ID =>NULL
					,P_ORIGINAL_ENTRY_ID =>NULL
					,P_LOCAL_UNIT_ID =>g_local_unit_id
					,P_SOURCE_NUMBER2 =>NULL
					,P_ORGANIZATION_ID =>NULL
					) ;
l_pt5_2_wtax_base :=pay_balance_pkg.get_value
					(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id
					,P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id
					,P_TAX_UNIT_ID =>g_legal_employer_id
					,P_JURISDICTION_CODE =>NULL
					,P_SOURCE_ID =>NULL
					,P_SOURCE_TEXT =>'SEMP'
					,P_TAX_GROUP =>NULL
					,P_DATE_EARNED =>l_effective_date
					,P_GET_RR_ROUTE =>NULL
					,P_GET_RB_ROUTE =>NULL
					,P_SOURCE_TEXT2 =>'WO'
					,P_SOURCE_NUMBER =>NULL
					,P_TIME_DEF_ID =>NULL
					,P_BALANCE_DATE =>NULL
					,P_PAYROLL_ID =>NULL
					,P_ORIGINAL_ENTRY_ID =>NULL
					,P_LOCAL_UNIT_ID =>g_local_unit_id
					,P_SOURCE_NUMBER2 =>NULL
					,P_ORGANIZATION_ID =>NULL
					) ;


					IF (l_pt5_1_wtax_base  > 0 )  THEN
						l_source_text :='PEMP';
						l_source_text2 :='WO' ;
						l_wtax_base:= l_pt5_1_wtax_base;
					ELSE
						l_source_text :='SEMP';
						l_source_text2 :='WO' ;
						l_wtax_base:= l_pt5_2_wtax_base;
					END IF;
	*/

					OPEN  csr_Get_Defined_Balance_Id( 'NOTIONAL_SALARY'||l_dimension1);
					FETCH csr_Get_Defined_Balance_Id INTO rg_csr_get_defined_balance_id;
					CLOSE csr_Get_Defined_Balance_Id;
					l_tax_base :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;
					l_tax := 0;
					l_mtax_base := l_tax_base  ;
					l_mtax := l_tax;

				END IF;


				IF   l_person_type<> 'WO' THEN
					-- fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 31');

					OPEN  csr_Get_Defined_Balance_Id( 'OTHER_PAYMENTS_SUBJECT_TO_TAX'||l_dimension1);
					FETCH csr_Get_Defined_Balance_Id INTO rg_csr_get_defined_balance_id;
					CLOSE csr_Get_Defined_Balance_Id;

					l_pth4_base :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;

					OPEN  csr_Get_Defined_Balance_Id( 'COMPENSATION_FOR_USE_OF_ITEM'||l_dimension1);
					FETCH csr_Get_Defined_Balance_Id INTO rg_csr_get_defined_balance_id;
					CLOSE csr_Get_Defined_Balance_Id;

					l_ptg_base :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;

					-- fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 32');

					IF l_tax_card_type <>'TS' THEN
						-- fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 33');

						OPEN  csr_Get_Defined_Balance_Id( 'CAPITAL_INCOME_BASE'||l_dimension1);
						FETCH csr_Get_Defined_Balance_Id INTO rg_csr_get_defined_balance_id;
						CLOSE csr_Get_Defined_Balance_Id;

						l_ptg1_base :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;

						OPEN  csr_Get_Defined_Balance_Id( 'CAPITAL_INCOME_TAX'||l_dimension1);
						FETCH csr_Get_Defined_Balance_Id INTO rg_csr_get_defined_balance_id;
						CLOSE csr_Get_Defined_Balance_Id;

						l_ptg1_tax :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;


					END IF;

					/*Proportion the Tax Base and Tax according to Payment Types*/
					-- fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 34');
					IF  l_tax_base > 0 THEN
						l_mtax_base := l_tax_base - (l_pth4_base + l_ptg_base) ;
						l_mtax := round((l_mtax_base/l_tax_base) * l_tax,2);

						IF  l_pth4_base > 0 THEN
							l_s1_tax_base := l_pth4_base  ;
							l_s1_tax := round((l_s1_tax_base/l_tax_base) * l_tax,2);
						END IF;

						IF  l_ptg_base > 0 THEN
							l_s2_tax_base := l_ptg_base ;
							l_s2_tax := round((l_s2_tax_base/l_tax_base) * l_tax,2);
						END IF;

						IF  l_ptg1_base > 0 THEN
							l_s3_tax_base := l_ptg1_base;
							l_s3_tax		:=  l_ptg1_tax ;
						END IF;

					END IF;




					OPEN  csr_Get_Defined_Balance_Id( 'DEDUCTIONS_BEFORE_TAX'||l_dimension1);
					FETCH csr_Get_Defined_Balance_Id INTO rg_csr_get_defined_balance_id;
					CLOSE csr_Get_Defined_Balance_Id;

					l_pretax_ded :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;

					OPEN  csr_Get_Defined_Balance_Id( 'EXTERNAL_EXPENSES'||l_dimension1);
					FETCH csr_Get_Defined_Balance_Id INTO rg_csr_get_defined_balance_id;
					CLOSE csr_Get_Defined_Balance_Id;

					l_external_expenses :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id ) ;
					-- fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 35');
				END IF;

				IF l_payment_type IS NOT NULL THEN
					-- fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 36');
					OPEN  csr_arch_chk(l_record_id , l_payment_type , p_assignment_action_id);
					FETCH csr_arch_chk INTO l_count;
					CLOSE csr_arch_chk;

					IF  l_count < 1 and l_record_id ='VSPSERIE'  THEN
					/* Values in action_information29 for record id VSPSERIE
					1	Identifier for record no  1 for primary payment type record for VSPSERIE
					2	Identifier for record no 2 for primary payment type record for VSPSERIE
					3	Identifier for records for Legal Persons
					*/

						IF l_source_text2 ='N' AND LENGTH(rg_csr_get_person_details.national_identifier) = 9 AND l_payment_type='H' THEN

							FOR i IN 1..12
							LOOP

								SELECT LAST_DAY(TO_DATE('01'||LPAD(i,2,'0')||g_year,'DDMMYYYY'))  , LPAD(i,2,'0')
								INTO l_bal_date, l_month
								FROM DUAL;

								IF  TO_NUMBER(TO_CHAR(l_bal_date,'MM'))  <= TO_NUMBER(TO_CHAR(rg_csr_asg_effective_date.EFFECTIVE_END_DATE,'MM')) THEN


									OPEN  csr_Get_Defined_Balance_Id( 'WITHHOLDING_TAX'||l_dimension2);
									FETCH csr_Get_Defined_Balance_Id INTO rg_csr_get_defined_balance_id;
									CLOSE csr_Get_Defined_Balance_Id;
									l_wtax :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id, P_ASSIGNMENT_ID =>rg_csr_get_person_details.assignment_id , P_VIRTUAL_DATE => l_bal_date) ;


									OPEN  csr_Get_Defined_Balance_Id( 'WITHHOLDING_TAX_BASE'||l_dimension2);
									FETCH csr_Get_Defined_Balance_Id INTO rg_csr_get_defined_balance_id;
									CLOSE csr_Get_Defined_Balance_Id;
									l_wtax_base :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id, P_ASSIGNMENT_ID =>rg_csr_get_person_details.assignment_id, P_VIRTUAL_DATE => l_bal_date) ;

									pay_action_information_api.create_action_information (
									p_action_information_id=> l_action_info_id,
									p_action_context_id=> p_assignment_action_id,
									p_action_context_type=> 'AAP',
									p_object_version_number=> l_ovn,
									p_effective_date=> g_effective_date,
									p_source_id=> NULL,
									p_source_text=> NULL,
									p_action_information_category=> 'EMEA REPORT INFORMATION',
									p_action_information1=> 'PYFIDPSA',
									p_action_information2=>rg_csr_get_person_details.person_id,
									p_action_information3=>l_record_id ,
									p_action_information4=>l_payment_type,
									p_action_information5=>g_transact_type ,
									p_action_information6=> g_year,
									p_action_information7=> rg_csr_rpt_header.business_id,
									p_action_information8=> rg_csr_get_person_details.national_identifier,
									p_action_information9=>  FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_wtax_base*100,0)) ,
									p_action_information10=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_wtax*100,0)) ,
									p_action_information11=>  NULL ,
									p_action_information12=> NULL ,
									p_action_information13=> NULL ,
									p_action_information14=> NULL ,
									p_action_information15=> l_month ,
									p_action_information16=> NULL ,
									p_action_information17=> NULL ,
									p_action_information18=> NULL ,
									p_action_information19=> NULL ,
									p_action_information20=> NULL ,
									p_action_information21=> NULL ,
									p_action_information22=> NULL ,
									p_action_information23=>  NULL ,
									p_action_information24=>  NULL ,
									p_action_information25=> NULL ,
									p_action_information26=> NULL ,
									p_action_information27=> NULL ,
									p_action_information28=> NULL ,
									p_action_information29=> '3' ,
									p_action_information30 => NULL);

								/*Reason for putting i in action_information15 is to allow summation of records of type 3 and 1
								of the record id VSPSERIE*/

								END IF;

							END LOOP;

						ELSE

								-- fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 37');
								pay_action_information_api.create_action_information (
								p_action_information_id=> l_action_info_id,
								p_action_context_id=> p_assignment_action_id,
								p_action_context_type=> 'AAP',
								p_object_version_number=> l_ovn,
								p_effective_date=> g_effective_date,
								p_source_id=> NULL,
								p_source_text=> NULL,
								p_action_information_category=> 'EMEA REPORT INFORMATION',
								p_action_information1=> 'PYFIDPSA',
								p_action_information2=>rg_csr_get_person_details.person_id,
								p_action_information3=>l_record_id ,
								p_action_information4=>l_payment_type,
								p_action_information5=>g_transact_type ,
								p_action_information6=> g_year,
								p_action_information7=> rg_csr_rpt_header.business_id,
								p_action_information8=> rg_csr_get_person_details.national_identifier,
								p_action_information9=>  FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_mtax_base*100,0) - nvl(l_bik*100,0)),
								p_action_information10=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_mtax*100,0)) ,
								p_action_information11=> FND_NUMBER.NUMBER_TO_CANONICAL((nvl(l_empl_pension,0) + nvl(l_empl_unemp_ins,0))*100 ) ,
								p_action_information12=>  FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_pretax_ded*100,0)) ,
								p_action_information13=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_cum_car_benefit*100,0)) ,
								p_action_information14=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_cum_mileage,0)) ,
								p_action_information15=> l_age_category,  -- Changes 2009
								p_action_information16=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_tot_mortgage_bik*100,0)) ,
								p_action_information17=> FND_NUMBER.NUMBER_TO_CANONICAL((nvl(l_tot_other_bik,0) +nvl(ROUND((l_tot_travel_ticket_bik*(3/4)),2),0))*100) ,
								p_action_information18=> l_housing_bik_status||l_phone_bik_status||l_lunch_bik_status||l_other_bik_status||l_travel_ticket_bik_status||l_lunch_bik_ded_status,
								p_action_information19=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_external_expenses*100,0)),
								p_action_information20=> l_daily_allowance_d_status||l_half_day_allowance_status||l_daily_allowance_fe_status||l_meal_comp_status,
								p_action_information21=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_tax_free_mileage,0)),
								p_action_information22=>FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_tax_free_mileage_expenses*100,0)),
								p_action_information23=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_tot_stock_option_bik*100,0)),
								p_action_information24=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_emp_pension*100,0)),
								p_action_information25=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_bik*100,0)),
								p_action_information26=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl((ROUND((l_tot_travel_ticket_bik/4),2))*100,0)),
								p_action_information27=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_tot_exem_ss*100,0)),
								p_action_information28=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_631*100,0)),
								p_action_information29=>  '1' ,
								p_action_information30 => NULL
								);

								pay_action_information_api.create_action_information (
								p_action_information_id=> l_action_info_id,
								p_action_context_id=> p_assignment_action_id,
								p_action_context_type=> 'AAP',
								p_object_version_number=> l_ovn,
								p_effective_date=> g_effective_date,
								p_source_id=> NULL,
								p_source_text=> NULL,
								p_action_information_category=> 'EMEA REPORT INFORMATION',
								p_action_information1=> 'PYFIDPSA',
								p_action_information2=>rg_csr_get_person_details.person_id,
								p_action_information3=>l_record_id ,
								p_action_information4=>l_payment_type,
								p_action_information5=>g_transact_type ,
								p_action_information6=> g_year,
								p_action_information7=> rg_csr_rpt_header.business_id,
								p_action_information8=> rg_csr_get_person_details.national_identifier,
								p_action_information9=>   FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_tax_comp*100,0)),
								p_action_information10=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_tot_pay_eoff *100,0)),
								p_action_information11=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_tot_vol_pi*100,0)),
								p_action_information12=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_tot_total_vol_pi*100,0)),
								p_action_information13=> l_full_car_benefit_status||l_bik_use_car_status,
								p_action_information14=>  FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_tot_car_bik_ded*100,0)),
								p_action_information15=>  FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_tot_other_bik_ded*100,0)),
								p_action_information16=> l_car_ben_val,     -- Changes 2009
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
								p_action_information29=>  '2',
								p_action_information30 => NULL
								);

								IF  l_s1_tax_base > 0 THEN
									pay_action_information_api.create_action_information (
									p_action_information_id=> l_action_info_id,
									p_action_context_id=> p_assignment_action_id,
									p_action_context_type=> 'AAP',
									p_object_version_number=> l_ovn,
									p_effective_date=> g_effective_date,
									p_source_id=> NULL,
									p_source_text=> NULL,
									p_action_information_category=> 'EMEA REPORT INFORMATION',
									p_action_information1=> 'PYFIDPSA',
									p_action_information2=>rg_csr_get_person_details.person_id,
									p_action_information3=>l_record_id ,
									p_action_information4=>'H4',
									p_action_information5=>g_transact_type ,
									p_action_information6=> g_year,
									p_action_information7=> rg_csr_rpt_header.business_id,
									p_action_information8=> rg_csr_get_person_details.national_identifier,
									p_action_information9=>  FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_s1_tax_base*100,0)),
									p_action_information10=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_s1_tax*100,0)) ,
									p_action_information11=>  NULL,
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
									p_action_information29=> 1,
									p_action_information30 => NULL
									);
								END IF;

								IF  l_s2_tax_base > 0 THEN
									pay_action_information_api.create_action_information (
									p_action_information_id=> l_action_info_id,
									p_action_context_id=> p_assignment_action_id,
									p_action_context_type=> 'AAP',
									p_object_version_number=> l_ovn,
									p_effective_date=> g_effective_date,
									p_source_id=> NULL,
									p_source_text=> NULL,
									p_action_information_category=> 'EMEA REPORT INFORMATION',
									p_action_information1=> 'PYFIDPSA',
									p_action_information2=>rg_csr_get_person_details.person_id,
									p_action_information3=>l_record_id ,
									p_action_information4=>'G',
									p_action_information5=>g_transact_type ,
									p_action_information6=> g_year,
									p_action_information7=> rg_csr_rpt_header.business_id,
									p_action_information8=> rg_csr_get_person_details.national_identifier,
									p_action_information9=>  FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_s2_tax_base*100,0)),
									p_action_information10=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_s2_tax*100,0)) ,
									p_action_information11=>  NULL,
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
									p_action_information29=> 1,
									p_action_information30 =>NULL
									);
								END IF;

								-- fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 38');
								IF  l_s3_tax_base > 0 THEN
									pay_action_information_api.create_action_information (
									p_action_information_id=> l_action_info_id,
									p_action_context_id=> p_assignment_action_id,
									p_action_context_type=> 'AAP',
									p_object_version_number=> l_ovn,
									p_effective_date=> g_effective_date,
									p_source_id=> NULL,
									p_source_text=> NULL,
									p_action_information_category=> 'EMEA REPORT INFORMATION',
									p_action_information1=> 'PYFIDPSA',
									p_action_information2=>rg_csr_get_person_details.person_id,
									p_action_information3=>l_record_id ,
									p_action_information4=>'G1',
									p_action_information5=>g_transact_type ,
									p_action_information6=> g_year,
									p_action_information7=> rg_csr_rpt_header.business_id,
									p_action_information8=> rg_csr_get_person_details.national_identifier,
									p_action_information9=>  FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_s3_tax_base*100,0)),
									p_action_information10=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_s3_tax*100,0)) ,
									p_action_information11=>  NULL,
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
									p_action_information29=>  1,
									p_action_information30 => NULL
									);
								END IF;

						END IF;

					ELSIF  l_count < 1 and l_record_id ='VSRAERIE' THEN
						-- fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 39');

						pay_action_information_api.create_action_information (
					       p_action_information_id=> l_action_info_id,
					       p_action_context_id=> p_assignment_action_id,
					       p_action_context_type=> 'AAP',
					       p_object_version_number=> l_ovn,
					       p_effective_date=> g_effective_date,
					       p_source_id=> NULL,
					       p_source_text=> NULL,
					       p_action_information_category=> 'EMEA REPORT INFORMATION',
					       p_action_information1=> 'PYFIDPSA',
					       p_action_information2=>rg_csr_get_person_details.person_id,
					       p_action_information3=>l_record_id ,
					       p_action_information4=>l_payment_type,
					       p_action_information5=>g_transact_type ,
					       p_action_information6=> g_year,
					       p_action_information7=> rg_csr_rpt_header.business_id,
					       p_action_information8=> rg_csr_get_person_details.national_identifier,
					       p_action_information9=>  rg_csr_get_person_details.last_name ,
					       p_action_information10=> rg_csr_get_person_details.first_name ,
					       p_action_information11=> rg_csr_per_address.address ,
					       p_action_information12=> rg_csr_per_address.postal_code ,
					       p_action_information13=> rg_csr_per_address.d_country ,
					       p_action_information14=> l_country_code ,
					       p_action_information15=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_mtax_base*100,0) - nvl(l_bik*100,0)),
					       p_action_information16=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_mtax*100,0)) ,
					       p_action_information17=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_salary_income*100,0)) ,
					       p_action_information18=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_bik*100,0)),
					       p_action_information19=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_pretax_ded*100,0)) ,
					       p_action_information20=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_external_expenses*100,0)),
					       p_action_information21=> rg_csr_rpt_header.contact_person,
					       p_action_information22=>rg_csr_rpt_header.phone,
					       p_action_information23=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_social_security	*100,0)),
					       p_action_information24=> l_place_residence,
					       p_action_information25=> rg_csr_get_person_details.fpin,
					       p_action_information26=> l_bank_acc_num,   -- changes 2009
					       p_action_information27=> NULL,
					       p_action_information28=> NULL,
					       p_action_information29=> NULL,
					       p_action_information30=> NULL
					    );
					    IF  l_s1_tax_base > 0 THEN
							pay_action_information_api.create_action_information (
						       p_action_information_id=> l_action_info_id,
						       p_action_context_id=> p_assignment_action_id,
						       p_action_context_type=> 'AAP',
						       p_object_version_number=> l_ovn,
						       p_effective_date=> g_effective_date,
						       p_source_id=> NULL,
						       p_source_text=> NULL,
						       p_action_information_category=> 'EMEA REPORT INFORMATION',
						       p_action_information1=> 'PYFIDPSA',
						        p_action_information2=>rg_csr_get_person_details.person_id,
						       p_action_information3=>l_record_id ,
						       p_action_information4=>'D1',
						       p_action_information5=>g_transact_type ,
						       p_action_information6=> g_year,
						       p_action_information7=> rg_csr_rpt_header.business_id,
						       p_action_information8=> rg_csr_get_person_details.national_identifier,
						       p_action_information9=>  rg_csr_get_person_details.last_name ,
						       p_action_information10=> rg_csr_get_person_details.first_name ,
						       p_action_information11=> rg_csr_per_address.address ,
						       p_action_information12=> rg_csr_per_address.postal_code ,
						       p_action_information13=> rg_csr_per_address.d_country ,
						       p_action_information14=> l_country_code ,
						       p_action_information15=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_s1_tax_base*100,0)),
						       p_action_information16=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_s1_tax*100,0)) ,
						       p_action_information17=> NULL,
						       p_action_information18=> NULL,
						       p_action_information19=> NULL,
						       p_action_information20=> NULL,
						       p_action_information21=> rg_csr_rpt_header.contact_person,
						       p_action_information22=>rg_csr_rpt_header.phone,
					       	       p_action_information23=> NULL,
						       p_action_information24=> l_place_residence,
						       p_action_information25=>  rg_csr_get_person_details.fpin,
						       p_action_information26=> NULL,
						       p_action_information27=> NULL,
						       p_action_information28=> NULL,
						       p_action_information29=> NULL,
						       p_action_information30=>NULL
						    );
						END IF;

						IF  l_s2_tax_base > 0 THEN
							pay_action_information_api.create_action_information (
						       p_action_information_id=> l_action_info_id,
						       p_action_context_id=> p_assignment_action_id,
						       p_action_context_type=> 'AAP',
						       p_object_version_number=> l_ovn,
						       p_effective_date=> g_effective_date,
						       p_source_id=> NULL,
						       p_source_text=> NULL,
						       p_action_information_category=> 'EMEA REPORT INFORMATION',
						       p_action_information1=> 'PYFIDPSA',
						        p_action_information2=>rg_csr_get_person_details.person_id,
						       p_action_information3=>l_record_id ,
						       p_action_information4=>'A3',
						       p_action_information5=>g_transact_type ,
						       p_action_information6=> g_year,
						       p_action_information7=> rg_csr_rpt_header.business_id,
						       p_action_information8=> rg_csr_get_person_details.national_identifier,
						       p_action_information9=>  rg_csr_get_person_details.last_name ,
						       p_action_information10=> rg_csr_get_person_details.first_name ,
						       p_action_information11=> rg_csr_per_address.address ,
						       p_action_information12=> rg_csr_per_address.postal_code ,
						       p_action_information13=> rg_csr_per_address.d_country ,
						       p_action_information14=> l_country_code ,
						       p_action_information15=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_s2_tax_base*100,0)),
						       p_action_information16=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_s2_tax*100,0)) ,
						       p_action_information17=> NULL,
						       p_action_information18=> NULL,
						       p_action_information19=> NULL,
						       p_action_information20=> NULL,
						       p_action_information21=> rg_csr_rpt_header.contact_person,
						       p_action_information22=>rg_csr_rpt_header.phone,
					       	       p_action_information23=> NULL,
						       p_action_information24=>l_place_residence,
						       p_action_information25=>  rg_csr_get_person_details.fpin,
						       p_action_information26=> NULL,
						       p_action_information27=> NULL,
						       p_action_information28=> NULL,
						       p_action_information29=> NULL,
						       p_action_information30=> NULL
						    );
						END IF;

						-- fnd_file.put_line(fnd_file.log,'ARCHIVE CODE 40');
					END IF;

					IF l_subsidy_status ='Y' THEN

						IF l_record_id='VSPSERIE' THEN
							l_tax_type:='80';
						ELSE
							l_tax_type:='82';
						END IF;
						l_record_id:='VSPSTUKI';


						FOR i IN 1..12
							LOOP
							SELECT LAST_DAY(TO_DATE('01'||LPAD(i,2,'0')||g_year,'DDMMYYYY')),LPAD(i,2,'0')
							INTO l_bal_date,l_month
							FROM DUAL;

							IF  TO_NUMBER(TO_CHAR(l_bal_date,'MM'))  <= TO_NUMBER(TO_CHAR(rg_csr_asg_effective_date.EFFECTIVE_END_DATE,'MM')) THEN

								CODE_014:= 0;
								CODE_015:= 0;

								OPEN  csr_Get_Defined_Balance_Id( 'PART_TIME_PENSIONER_AMOUNT'||l_dimension2);
								FETCH csr_Get_Defined_Balance_Id INTO rg_csr_get_defined_balance_id;
								CLOSE csr_Get_Defined_Balance_Id;

								l_pt_pension_amt :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id, P_ASSIGNMENT_ID =>rg_csr_get_person_details.assignment_id , P_VIRTUAL_DATE => l_bal_date) ;

								OPEN  csr_Get_Defined_Balance_Id( 'SUBSIDY_FOR_LOW_PAID_EMPLOYEES'||l_dimension2);
								FETCH csr_Get_Defined_Balance_Id INTO rg_csr_get_defined_balance_id;
								CLOSE csr_Get_Defined_Balance_Id;
								l_subsidy_amt :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id, P_ASSIGNMENT_ID =>rg_csr_get_person_details.assignment_id , P_VIRTUAL_DATE => l_bal_date) ;


								IF l_subsidy_amt > 0 THEN

									OPEN  csr_Get_Defined_Balance_Id( 'SUBSIDY_BASIS'||l_dimension2);
									FETCH csr_Get_Defined_Balance_Id INTO rg_csr_get_defined_balance_id;
									CLOSE csr_Get_Defined_Balance_Id;
									l_subsidy_basis :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>rg_csr_get_defined_balance_id.creator_id, P_ASSIGNMENT_ID =>rg_csr_get_person_details.assignment_id , P_VIRTUAL_DATE => l_bal_date) ;


									IF l_pt_pension_amt > 0 THEN
										CODE_015:= l_subsidy_basis;
									ELSE
										CODE_014:= l_subsidy_basis;
									END IF;

									pay_action_information_api.create_action_information (
									p_action_information_id=> l_action_info_id,
									p_action_context_id=> p_assignment_action_id,
									p_action_context_type=> 'AAP',
									p_object_version_number=> l_ovn,
									p_effective_date=> g_effective_date,
									p_source_id=> NULL,
									p_source_text=> NULL,
									p_action_information_category=> 'EMEA REPORT INFORMATION',
									p_action_information1=> 'PYFIDPSA',
									p_action_information2=>rg_csr_get_person_details.person_id,
									p_action_information3=>l_record_id ,
									p_action_information4=>l_tax_type,
									p_action_information5=>g_transact_type ,
									p_action_information6=> g_year,
									p_action_information7=> rg_csr_rpt_header.business_id,
									p_action_information8=> rg_csr_get_person_details.national_identifier,
									p_action_information9=>  l_month,
									p_action_information10=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(CODE_014*100 ,0)) ,
									p_action_information11=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(CODE_015 *100,0)) ,
									p_action_information12=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_subsidy_amt*100,0)) ,
									p_action_information13=> '1',
									p_action_information14=> NULL ,
									p_action_information15=> NULL,
									p_action_information16=> NULL ,
									p_action_information17=> NULL ,
									p_action_information18=> NULL ,
									p_action_information19=> NULL ,
									p_action_information20=> NULL ,
									p_action_information21=> NULL ,
									p_action_information22=> NULL ,
									p_action_information23=>  NULL ,
									p_action_information24=>  NULL ,
									p_action_information25=> NULL ,
									p_action_information26=> NULL ,
									p_action_information27=> NULL ,
									p_action_information28=> NULL ,
									p_action_information29=> NULL,
									p_action_information30 => NULL
									);
								END IF;
							END IF;
						END LOOP;

					END IF;

				END IF;
			END IF;
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

		/* Cursor to retrieve data from the Header record(Employer level) */
		CURSOR csr_prpt_header (p_payroll_action_id NUMBER) IS
		SELECT  action_information2       emp_type     ,action_information3       emp_id
		,action_information4       business_id ,action_information5       org_type ,action_information6       contact_person
		,action_information7       phone ,action_information8       year        ,action_information9       transact_type
		FROM pay_action_information pai
		WHERE action_information_category = 'EMEA REPORT INFORMATION'
		AND action_information1 = 'PYFIDPSA'
		AND action_context_id = p_payroll_action_id;

		rg_csr_prpt_header  csr_prpt_header%rowtype;

	 /* Cursor to fetch data  related to Finnish Residents*/
		CURSOR csr_arch_fi (p_payroll_action_id NUMBER) IS
		SELECT  substr(action_information4,1,1)  payment_type , SUM(nvl(action_information9,0)) payment ,  SUM(nvl(action_information10,0)) tax , COUNT(*) num
		,SUM(nvl(action_information12,0)) pretax_ded, SUM(nvl(action_information11,0))  pen_unemp_ins , SUM(nvl(action_information25,0)) bik
		, SUM(nvl(action_information27,0) +  nvl(action_information23,0))  CODE_670 ,SUM(nvl(action_information28,0))  CODE_631
		FROM pay_action_information pai , pay_assignment_actions paa
		WHERE pai.action_information_category = 'EMEA REPORT INFORMATION'
		AND pai.action_context_type= 'AAP'
		AND pai.action_context_id= paa.assignment_action_id
		AND paa.payroll_action_id = p_payroll_action_id
		AND action_information3 ='VSPSERIE'
		AND action_information4 <>'P2'
		AND action_information29 IN ('1','3')
		GROUP BY substr(action_information4 ,1,1);

	 /* Cursor to fetch data  related to Finnish Residents Payment Type P2*/
		CURSOR csr_arch_fi_p2 (p_payroll_action_id NUMBER) IS
		SELECT  substr(action_information4,1,1)  payment_type , SUM(nvl(action_information9,0)) payment ,  SUM(nvl(action_information10,0)) tax , COUNT(*) num
		,SUM(nvl(action_information12,0)) pretax_ded, SUM(nvl(action_information11,0))  pen_unemp_ins , SUM(nvl(action_information25,0)) bik
		, SUM(nvl(action_information27,0) +  nvl(action_information23,0))  CODE_670 ,SUM(nvl(action_information28,0))  CODE_631
		FROM pay_action_information pai , pay_assignment_actions paa
		WHERE pai.action_information_category = 'EMEA REPORT INFORMATION'
		AND pai.action_context_type= 'AAP'
		AND pai.action_context_id= paa.assignment_action_id
		AND paa.payroll_action_id = p_payroll_action_id
		AND action_information3 ='VSPSERIE'
		AND action_information4 ='P2'
		AND action_information29 ='1'
		GROUP BY substr(action_information4 ,1,1);

		rg_csr_arch_fi_p2  csr_arch_fi_p2%rowtype;



	 /* Cursor to fetch data  related to Foreign Residents Social Security Not Liable*/
		CURSOR csr_arch_fr_nss ( p_payroll_action_id NUMBER) IS
		SELECT  SUM(nvl(action_information15,0)) payment,  SUM(nvl(action_information16,0)) tax , COUNT(*) num,
		SUM(nvl(action_information19,0))  pretax_ded, SUM(nvl(action_information18,0)) bik
		FROM pay_action_information pai , pay_assignment_actions paa
		WHERE pai.action_information_category = 'EMEA REPORT INFORMATION'
		AND pai.action_context_type= 'AAP'
		AND pai.action_context_id= paa.assignment_action_id
		AND paa.payroll_action_id = p_payroll_action_id
		AND action_information3 ='VSRAERIE'
		AND NVL(action_information23,0) < 1
		GROUP BY action_information3;


	/* Cursor to fetch data  related to Foreign Residents Social Security liable*/
		CURSOR csr_arch_fr_ss ( p_payroll_action_id NUMBER) IS
		SELECT  SUM(nvl(action_information15,0)) payment,  SUM(nvl(action_information16,0)) tax , COUNT(*) num,
		SUM(nvl(action_information19,0))  pretax_ded, SUM(nvl(action_information18,0)) bik
		FROM pay_action_information pai , pay_assignment_actions paa
		WHERE pai.action_information_category = 'EMEA REPORT INFORMATION'
		AND pai.action_context_type= 'AAP'
		AND pai.action_context_id= paa.assignment_action_id
		AND paa.payroll_action_id = p_payroll_action_id
		AND action_information3 ='VSRAERIE'
		AND NVL(action_information23,0) > 0
		GROUP BY action_information3;

	/* Cursor to fetch data  related to Record VSPSERIE*/
		CURSOR csr_VSPSERIE (p_payroll_action_id NUMBER) IS
		SELECT  pai.action_information30
		FROM pay_action_information pai , pay_assignment_actions paa
		WHERE paa.payroll_action_id = p_payroll_action_id
		AND pai.action_context_id= paa.assignment_action_id
		AND pai.action_context_type= 'AAP'
		AND pai.action_information_category = 'EMEA REPORT INFORMATION'
		AND  pai.action_information1 = 'PYFIDPSA'
		AND pai.action_information3  ='VSPSERIE'
		AND action_information29 IN ('1','3')
		ORDER BY pai.action_information2 , action_information29 , action_information15
		FOR UPDATE OF pai.action_information30;

		/* Cursor to fetch data  related to Record VSRAERIE*/
		CURSOR csr_VSRAERIE(p_payroll_action_id NUMBER) IS
		SELECT  pai.action_information30
		FROM pay_action_information pai , pay_assignment_actions paa
		WHERE paa.payroll_action_id = p_payroll_action_id
		AND pai.action_context_id= paa.assignment_action_id
		AND pai.action_context_type= 'AAP'
		AND pai.action_information_category = 'EMEA REPORT INFORMATION'
		AND  pai.action_information1 = 'PYFIDPSA'
		AND pai.action_information3  ='VSRAERIE'
		ORDER BY pai.action_information2
		FOR UPDATE OF pai.action_information30;

		/* Cursor to fetch data  related to Record VSPSVYSL*/
		CURSOR csr_VSPSVYSL(p_payroll_action_id NUMBER) IS
		SELECT  *
		FROM pay_action_information pai
		WHERE pai.action_context_id= p_payroll_action_id
		AND pai.action_context_type= 'PA'
		AND  pai.action_information_category = 'EMEA REPORT INFORMATION'
		AND  pai.action_information1 = 'PYFIDPSA'
		AND  pai.action_information2    =    'VSPSVYSL'
		ORDER BY pai.action_information4
		FOR UPDATE OF pai.action_information30;

		rg_chk_csr_VSPSVYSL  csr_VSPSVYSL%rowtype;

		/* Cursor to fetch data  related to Record VSPSVYHT*/
		CURSOR csr_VSPSVYHT(p_payroll_action_id NUMBER) IS
		SELECT  *
		FROM pay_action_information pai
		WHERE pai.action_context_id= p_payroll_action_id
		AND pai.action_context_type= 'PA'
		AND  pai.action_information_category = 'EMEA REPORT INFORMATION'
		AND  pai.action_information1 = 'PYFIDPSA'
		AND  pai.action_information2    =    'VSPSVYHT'
		FOR UPDATE OF pai.action_information30;

		rg_chk_csr_VSPSVYHT  csr_VSPSVYHT%rowtype;

		/* Cursor to fetch data  related to Record VSPSTUKI*/
		CURSOR csr_VSPSTUKI(p_payroll_action_id NUMBER) IS
		SELECT  pai.action_information30
		FROM pay_action_information pai , pay_assignment_actions paa
		WHERE paa.payroll_action_id = p_payroll_action_id
		AND pai.action_context_id= paa.assignment_action_id
		AND pai.action_context_type= 'AAP'
		AND pai.action_information_category = 'EMEA REPORT INFORMATION'
		AND  pai.action_information1 = 'PYFIDPSA'
		AND pai.action_information3  =  'VSPSTUKI'
		ORDER BY pai.action_information2
		FOR UPDATE OF pai.action_information30;

		rg_chk_csr_VSPSTUKI  csr_VSPSTUKI%rowtype;


		l_tot_count		NUMBER;
		l_tot_bik			NUMBER;
		l_tot_pretax_ded	NUMBER;
		l_tot_pen_unemp_ins	NUMBER;

		l_tot_payment		NUMBER;
		l_payment_status	NUMBER;
		l_action_info_id NUMBER;
		l_ovn			NUMBER;
		l_end_code		NUMBER;
		 l_vspsvysl_status	NUMBER;
		 l_tot_631	NUMBER;
		 l_tot_670	NUMBER;



	BEGIN
		-- fnd_file.put_line(fnd_file.log,'DEINITIALIZATION_CODE 1');
		/*Initializing the variables*/

		l_tot_count		:=0;
		l_tot_bik			:=0;
		l_tot_pretax_ded	:=0;
		l_tot_pen_unemp_ins	:=0;
		l_tot_payment		:=0;
		l_payment_status	:=0;
		 l_vspsvysl_status	:=0;
		  l_tot_631	:=0;
		 l_tot_670	:=0;

		IF g_debug THEN
			hr_utility.set_location(' Entering Procedure DEINITIALIZATION_CODE',380);
		END IF;

		 /* Fetching data from the Header record(Employer level) */
		OPEN  csr_prpt_header(p_payroll_action_id);
		FETCH csr_prpt_header INTO rg_csr_prpt_header;
		CLOSE csr_prpt_header;

		PAY_FI_ARCHIVE_DPSA.GET_ALL_PARAMETERS(
		p_payroll_action_id
		,g_business_group_id
		,g_legal_employer_id
		,g_local_unit_id
		,g_year
		,g_transact_type
		,g_deduction_ss
		,g_effective_date
		,g_archive ) ;

		g_emp_type:= rg_csr_prpt_header.emp_type;
		IF g_transact_type IN ( 1 , 2) THEN
				g_transact_type := 2;
		END IF;

		IF g_archive='Y' THEN
			-- fnd_file.put_line(fnd_file.log,'DEINITIALIZATION_CODE 3');

			FOR rg_csr_arch_fi IN csr_arch_fi(p_payroll_action_id)
			LOOP
				-- fnd_file.put_line(fnd_file.log,'DEINITIALIZATION_CODE 4');


				IF	rg_csr_arch_fi.payment_type ='H' THEN
					OPEN  csr_arch_fi_p2(p_payroll_action_id);
					FETCH csr_arch_fi_p2 INTO rg_csr_arch_fi_p2;
					CLOSE csr_arch_fi_p2;

					-- fnd_file.put_line(fnd_file.log,'DEINITIALIZATION_CODE 5');
					pay_action_information_api.create_action_information (
					p_action_information_id=> l_action_info_id,
					p_action_context_id=> p_payroll_action_id,
					p_action_context_type=> 'PA',
					p_object_version_number=> l_ovn,
					p_effective_date=> g_effective_date,
					p_source_id=> NULL,
					p_source_text=> NULL,
					p_action_information_category=> 'EMEA REPORT INFORMATION',
					p_action_information1=> 'PYFIDPSA',
					p_action_information2=>  'VSPSVYSL',
					p_action_information3=>g_transact_type,
					p_action_information4=> rg_csr_arch_fi.payment_type ,
					p_action_information5=> g_year,
					p_action_information6=>  rg_csr_prpt_header.business_id,
					p_action_information7=>  FND_NUMBER.NUMBER_TO_CANONICAL(rg_csr_arch_fi.payment + nvl(rg_csr_arch_fi_p2.payment,0)  ),
					p_action_information8=> FND_NUMBER.NUMBER_TO_CANONICAL(rg_csr_arch_fi.tax + nvl(rg_csr_arch_fi_p2.tax,0)) ,
					p_action_information9=> FND_NUMBER.NUMBER_TO_CANONICAL(rg_csr_arch_fi.num + nvl(rg_csr_arch_fi_p2.num,0)),
					p_action_information10=> FND_NUMBER.NUMBER_TO_CANONICAL(rg_csr_arch_fi.CODE_670 + nvl(rg_csr_arch_fi_p2.CODE_670,0) ),
					p_action_information11=> FND_NUMBER.NUMBER_TO_CANONICAL(rg_csr_arch_fi.CODE_631 + nvl(rg_csr_arch_fi_p2.CODE_631,0) ),
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

					l_tot_count :=   l_tot_count + 1 ;
					l_tot_bik :=  nvl(rg_csr_arch_fi.bik,0) +  nvl(rg_csr_arch_fi_p2.bik,0) +  l_tot_bik;
					l_tot_pretax_ded:=  nvl(rg_csr_arch_fi.pretax_ded,0) +   nvl(rg_csr_arch_fi_p2.pretax_ded,0) +  l_tot_pretax_ded;
					l_tot_pen_unemp_ins:=  nvl(rg_csr_arch_fi.pen_unemp_ins,0) + nvl(rg_csr_arch_fi_p2.pen_unemp_ins,0)  +  l_tot_pen_unemp_ins;
					l_tot_payment:=  nvl(rg_csr_arch_fi.payment,0) +   nvl(rg_csr_arch_fi_p2.payment,0) +  l_tot_payment;
					l_tot_631:=  nvl(rg_csr_arch_fi.code_631,0) + nvl(rg_csr_arch_fi_p2.code_631,0)  +  l_tot_631;
					l_tot_670:=  nvl(rg_csr_arch_fi.code_670,0) + nvl(rg_csr_arch_fi_p2.code_670,0)  +  l_tot_670;

					-- fnd_file.put_line(fnd_file.log,'DEINITIALIZATION_CODE 6');
				ELSE
					pay_action_information_api.create_action_information (
					p_action_information_id=> l_action_info_id,
					p_action_context_id=> p_payroll_action_id,
					p_action_context_type=> 'PA',
					p_object_version_number=> l_ovn,
					p_effective_date=> g_effective_date,
					p_source_id=> NULL,
					p_source_text=> NULL,
					p_action_information_category=> 'EMEA REPORT INFORMATION',
					p_action_information1=> 'PYFIDPSA',
					p_action_information2=>  'VSPSVYSL',
					p_action_information3=>g_transact_type,
					p_action_information4=> rg_csr_arch_fi.payment_type ,
					p_action_information5=> g_year,
					p_action_information6=>  rg_csr_prpt_header.business_id,
					p_action_information7=>  FND_NUMBER.NUMBER_TO_CANONICAL(nvl(rg_csr_arch_fi.payment ,0) ),
					p_action_information8=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(rg_csr_arch_fi.tax,0) ) ,
					p_action_information9=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(rg_csr_arch_fi.num,0)) ,
					p_action_information10=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(rg_csr_arch_fi.CODE_670,0)) ,
					p_action_information11=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(rg_csr_arch_fi.CODE_631,0)) ,
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
					p_action_information30=> NULL
					);

					l_tot_count :=   l_tot_count + 1 ;
					l_tot_bik :=  nvl(rg_csr_arch_fi.bik,0) +  l_tot_bik;
					l_tot_pretax_ded:=  nvl(rg_csr_arch_fi.pretax_ded,0) +  l_tot_pretax_ded;
					l_tot_pen_unemp_ins:=  nvl(rg_csr_arch_fi.pen_unemp_ins,0) +  l_tot_pen_unemp_ins;
					l_tot_payment:=  nvl(rg_csr_arch_fi.payment,0) +  l_tot_payment;
					l_tot_631:=  nvl(rg_csr_arch_fi.code_631,0)  +  l_tot_631;
					l_tot_670:=  nvl(rg_csr_arch_fi.code_670,0) + l_tot_670;
					-- fnd_file.put_line(fnd_file.log,'DEINITIALIZATION_CODE 6');

				END IF;
END LOOP;
			-- fnd_file.put_line(fnd_file.log,'DEINITIALIZATION_CODE 7');
			FOR rg_csr_arch_fr_ss IN csr_arch_fr_ss(p_payroll_action_id)
			LOOP
				-- fnd_file.put_line(fnd_file.log,'DEINITIALIZATION_CODE 8');
				pay_action_information_api.create_action_information (
				p_action_information_id=> l_action_info_id,
				p_action_context_id=> p_payroll_action_id,
				p_action_context_type=> 'PA',
				p_object_version_number=> l_ovn,
				p_effective_date=> g_effective_date,
				p_source_id=> NULL,
				p_source_text=> NULL,
				p_action_information_category=> 'EMEA REPORT INFORMATION',
				p_action_information1=> 'PYFIDPSA',
				p_action_information2=> 'VSPSVYSL',
				p_action_information3=>g_transact_type,
				p_action_information4=> '14' ,
				p_action_information5=> g_year,
				p_action_information6=>  rg_csr_prpt_header.business_id,
				p_action_information7=>  FND_NUMBER.NUMBER_TO_CANONICAL(nvl(rg_csr_arch_fr_ss.payment,0)),
				p_action_information8=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(rg_csr_arch_fr_ss.tax,0)) ,
				p_action_information9=>  FND_NUMBER.NUMBER_TO_CANONICAL(nvl(rg_csr_arch_fr_ss.num,0)),
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
				p_action_information30=> NULL
				);

				l_tot_count := l_tot_count + 1;
				l_tot_bik :=  nvl(rg_csr_arch_fr_ss.bik,0) +  l_tot_bik;
				l_tot_pretax_ded:=  nvl(rg_csr_arch_fr_ss.pretax_ded,0) +  l_tot_pretax_ded;
				l_tot_payment:=  nvl(rg_csr_arch_fr_ss.payment,0) +  l_tot_payment;
				-- fnd_file.put_line(fnd_file.log,'DEINITIALIZATION_CODE 9');

			END LOOP;
			-- fnd_file.put_line(fnd_file.log,'DEINITIALIZATION_CODE 10');
			FOR rg_csr_arch_fr_nss IN csr_arch_fr_nss(p_payroll_action_id)
			LOOP
				-- fnd_file.put_line(fnd_file.log,'DEINITIALIZATION_CODE 11');
				pay_action_information_api.create_action_information (
				p_action_information_id=> l_action_info_id,
				p_action_context_id=> p_payroll_action_id,
				p_action_context_type=> 'PA',
				p_object_version_number=> l_ovn,
				p_effective_date=> g_effective_date,
				p_source_id=> NULL,
				p_source_text=> NULL,
				p_action_information_category=> 'EMEA REPORT INFORMATION',
				p_action_information1=> 'PYFIDPSA',
				p_action_information2=> 'VSPSVYSL',
				p_action_information3=>g_transact_type,
				p_action_information4=> '22',
				p_action_information5=> g_year,
				p_action_information6=>  rg_csr_prpt_header.business_id,
				p_action_information7=>  FND_NUMBER.NUMBER_TO_CANONICAL(nvl(rg_csr_arch_fr_nss.payment,0)),
				p_action_information8=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(rg_csr_arch_fr_nss.tax,0)) ,
				p_action_information9=>  FND_NUMBER.NUMBER_TO_CANONICAL(nvl(rg_csr_arch_fr_nss.num,0)),
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
				p_action_information30=> NULL
				);

				l_tot_count :=   l_tot_count + 1;
				l_tot_bik :=  nvl(rg_csr_arch_fr_nss.bik,0) +  l_tot_bik;
				l_tot_pretax_ded:=  nvl(rg_csr_arch_fr_nss.pretax_ded,0) +  l_tot_pretax_ded;
				l_tot_payment:=  nvl(rg_csr_arch_fr_nss.payment ,0) +  l_tot_payment;
				-- fnd_file.put_line(fnd_file.log,'DEINITIALIZATION_CODE 11');
			END LOOP;

			IF l_tot_payment  = 0 THEN
				l_payment_status:=1;
			END IF;

			OPEN csr_VSPSVYSL(p_payroll_action_id );
			FETCH csr_VSPSVYSL INTO rg_chk_csr_VSPSVYSL;
				IF csr_VSPSVYSL%FOUND THEN
					l_vspsvysl_status:=1;
				END IF;
			CLOSE csr_VSPSVYSL;

			IF l_vspsvysl_status=1 THEN

					IF g_deduction_ss IS NOT NULL THEN
						l_tot_631:= g_deduction_ss*100;
					END IF;

				-- fnd_file.put_line(fnd_file.log,'DEINITIALIZATION_CODE 12');
				pay_action_information_api.create_action_information (
				p_action_information_id=> l_action_info_id,
				p_action_context_id=> p_payroll_action_id,
				p_action_context_type=> 'PA',
				p_object_version_number=> l_ovn,
				p_effective_date=> g_effective_date,
				p_source_id=> NULL,
				p_source_text=> NULL,
				p_action_information_category=> 'EMEA REPORT INFORMATION',
				p_action_information1=> 'PYFIDPSA',
				p_action_information2=>  'VSPSVYHT',
				p_action_information3=>g_transact_type,
				p_action_information4=> g_year,
				p_action_information5=> rg_csr_prpt_header.business_id,
				p_action_information6=>  rg_csr_prpt_header.contact_person,
				p_action_information7=>  rg_csr_prpt_header.phone,
				p_action_information8=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_tot_count,0)),
				p_action_information9=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_tot_bik,0)),
				p_action_information10=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_tot_pen_unemp_ins,0)),
				p_action_information11=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_tot_pretax_ded,0)),
				p_action_information12=> l_payment_status,
				p_action_information13=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_tot_631,0)),
				p_action_information14=> FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_tot_670,0)),
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

				-- fnd_file.put_line(fnd_file.log,'DEINITIALIZATION_CODE 14');
			END IF;

			l_end_code:=0 ;

			FOR rg_csr_VSPSERIE IN csr_VSPSERIE(p_payroll_action_id )
			LOOP
				l_end_code:=l_end_code + 1  ;
				UPDATE pay_action_information pai
				SET pai.action_information30 =l_end_code
				WHERE CURRENT OF csr_VSPSERIE;
			END LOOP;

			FOR rg_csr_VSRAERIE IN csr_VSRAERIE(p_payroll_action_id )
			LOOP
				l_end_code:=l_end_code + 1  ;
				UPDATE pay_action_information pai
				SET pai.action_information30 =l_end_code
				WHERE CURRENT OF csr_VSRAERIE;
			END LOOP;

			FOR rg_csr_VSPSTUKI IN csr_VSPSTUKI(p_payroll_action_id )
			LOOP
				l_end_code:=l_end_code + 1  ;
				UPDATE pay_action_information
				SET action_information30 =l_end_code
				WHERE CURRENT OF csr_VSPSTUKI;
			END LOOP;

			FOR rg_csr_VSPSVYSL IN csr_VSPSVYSL(p_payroll_action_id )
			LOOP
				l_end_code:=l_end_code + 1  ;
				UPDATE pay_action_information
				SET action_information30 =l_end_code
				WHERE CURRENT OF csr_VSPSVYSL;
			END LOOP;

			FOR rg_csr_VSPSVYHT IN csr_VSPSVYHT(p_payroll_action_id )
			LOOP
				l_end_code:=l_end_code + 1  ;
				UPDATE pay_action_information
				SET action_information30 =l_end_code
				WHERE CURRENT OF csr_VSPSVYHT;
			END LOOP;





	END IF;---ARCHIVE=YES

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

	g_payroll_action_id			:=NULL;
	g_le_assignment_action_id	:=NULL;
	g_lu_assignment_action_id	:=NULL;
	g_emp_type					:=NULL;
	g_business_group_id		:=NULL;
	g_legal_employer_id			:=NULL;
	g_local_unit_id				:=NULL;
	g_year						:=NULL;
	g_transact_type				:=NULL;
	g_deduction_ss				:=NULL;
	g_effective_date				:=NULL;
	g_archive					:=NULL;

END PAY_FI_ARCHIVE_DPSA;

/
