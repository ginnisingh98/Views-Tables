--------------------------------------------------------
--  DDL for Package Body PAY_FI_ARCHIVE_LTFA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FI_ARCHIVE_LTFA" AS
 /* $Header: pyfiltfa.pkb 120.4.12000000.4 2007/03/20 05:39:29 dbehera noship $ */

	 TYPE lock_rec IS RECORD (
	      archive_assact_id    NUMBER);

	 TYPE lock_table      IS TABLE OF  lock_rec      INDEX BY BINARY_INTEGER;

	 g_debug   boolean   :=  hr_utility.debug_enabled;
	 g_lock_table   		          lock_table;
	 g_index             NUMBER := -1;
	 g_index_assact      NUMBER := -1;
	 g_index_bal	    NUMBER := -1;
	 g_package           VARCHAR2(33) := ' PAY_FI_ARCHIVE_LTFA.';
	 g_archive VARCHAR2(1);
	 g_emp_type VARCHAR2(2);
	 g_legal_employer_id NUMBER;
	 g_local_unit_id        NUMBER ;
	 g_effective_date       DATE;
	 g_pension_provider hr_organization_units.organization_id%TYPE ;
 	 g_pension_ins_num hr_organization_information.org_information1%TYPE ;
	  g_payroll_action_id    NUMBER ;
	  g_le_assignment_action_id NUMBER ;
  	  g_lu_assignment_action_id NUMBER ;



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
	 fnd_file.put_line(fnd_file.log,'Range Code 23'||p_token);
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
	PROCEDURE GET_ALL_PARAMETERS(
        p_payroll_action_id                    IN   NUMBER
    	,p_business_group_id              OUT  NOCOPY NUMBER
		,p_pension_ins_num                 OUT  NOCOPY  VARCHAR2
		,p_legal_employer_id                OUT  NOCOPY  NUMBER
		,p_local_unit_id                           OUT  NOCOPY  NUMBER
		,p_month					OUT  NOCOPY  VARCHAR2
		,p_year						OUT  NOCOPY  VARCHAR2
		,p_effective_date                         OUT  NOCOPY DATE
		,p_archive					OUT  NOCOPY  VARCHAR2
		) IS

		CURSOR csr_parameter_info(p_payroll_action_id NUMBER) IS
		SELECT PAY_FI_ARCHIVE_LTFA.GET_PARAMETER(legislative_parameters,'LEGAL_EMPLOYER_NAME')
		,PAY_FI_ARCHIVE_LTFA.GET_PARAMETER(legislative_parameters,'LOCAL_UNIT_NAME')
		,PAY_FI_ARCHIVE_LTFA.GET_PARAMETER(legislative_parameters,'PENSION_INS_NUM')
		,PAY_FI_ARCHIVE_LTFA.GET_PARAMETER(legislative_parameters,'MONTH_RPT')
		,PAY_FI_ARCHIVE_LTFA.GET_PARAMETER(legislative_parameters,'YEAR_RPT')
		,PAY_FI_ARCHIVE_LTFA.GET_PARAMETER(legislative_parameters,'ARCHIVE')
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
		 INTO	p_legal_employer_id
				,p_local_unit_id
				,p_pension_ins_num
				,p_month
				,p_year
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
			l_start_date VARCHAR2(30);
			l_end_date VARCHAR2(30);
			l_defined_balance_id NUMBER := 0;
			l_count NUMBER := 0;
			l_prev_prepay          NUMBER := 0;
			l_prepay_action_id     NUMBER;
			l_actid NUMBER;
			l_assignment_id NUMBER;
			l_action_sequence NUMBER;
			l_assact_id     NUMBER;
			l_pact_id NUMBER;
			l_flag NUMBER := 0;
			l_element_context VARCHAR2(5);
			l_business_group_id    NUMBER;
			l_month      VARCHAR2(2);
			l_year      VARCHAR2(4);
			l_canonical_start_date DATE;
			l_canonical_end_date    DATE;
			l_emp_type  VARCHAR2(2);
			l_emp_id        hr_organization_units.organization_id%TYPE ;
			l_customer_num  hr_organization_information.org_information1%TYPE ;
			l_pension_ins_num  hr_organization_information.org_information1%TYPE ;
			l_dept_code    VARCHAR2(3);

			l_Record_code                       VARCHAR2(240)   :=' ';
			l_pp_name            hr_organization_units.name%TYPE ;
			l_emp_name            hr_organization_units.name%TYPE ;
			l_le_name            hr_organization_units.name%TYPE ;
			l_lu_name            hr_organization_units.name%TYPE ;
			l_business_id               hr_organization_information.org_information1%TYPE ;
			l_y_number		   hr_organization_information.org_information1%TYPE ;
			l_assignment_action_id      pay_assignment_actions.assignment_action_id%TYPE;
			l_counter   number := 0;


           	     					/* Cursors */


			CURSOR csr_pension_provider_details ( csr_v_pension_provider_id   hr_organization_information.organization_id%TYPE
			      )
			  IS
				 SELECT o1.NAME
				   FROM hr_organization_units o1
					, hr_organization_information hoi1
					WHERE  o1.business_group_id =l_business_group_id
					AND hoi1.organization_id = o1.organization_id
					AND hoi1.organization_id =  csr_v_pension_provider_id
					AND hoi1.org_information_context = 'CLASS'
					AND hoi1.org_information1 = 'FR_PENSION' ;

			      rg_pension_provider_details      csr_pension_provider_details%ROWTYPE;



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

			Cursor csr_Legal_Emp_Details
			( csr_v_legal_emp_id  hr_organization_information.ORGANIZATION_ID%TYPE
			, csr_v_pension_ins_num  hr_organization_information.ORG_INFORMATION1%TYPE
			, csr_v_effective_date  DATE  )
				IS
					SELECT o1.name ,hoi2.ORG_INFORMATION1 , hoi3.ORG_INFORMATION4 , hoi3.ORG_INFORMATION6, hoi3.ORG_INFORMATION8
					FROM hr_organization_units o1
					, hr_organization_information hoi1
					, hr_organization_information hoi2
					, hr_organization_information hoi3
					WHERE  o1.business_group_id =l_business_group_id
					AND hoi1.organization_id = o1.organization_id
					AND hoi1.organization_id =   csr_v_legal_emp_id
					AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
					AND hoi1.org_information_context = 'CLASS'
					AND o1.organization_id =hoi2.organization_id
					AND hoi2.ORG_INFORMATION_CONTEXT='FI_LEGAL_EMPLOYER_DETAILS'
					AND o1.organization_id =hoi3.organization_id
					AND hoi3.ORG_INFORMATION_CONTEXT='FI_PENSION_PROVIDERS'
					AND  hoi3.org_information6=csr_v_pension_ins_num
					AND csr_v_effective_date  BETWEEN fnd_date.canonical_to_date(hoi3.org_information1) AND
					nvl(fnd_date.canonical_to_date(hoi3.org_information2),to_date('31/12/4712','DD/MM/YYYY')) ;

			rg_Legal_Emp_Details  csr_Legal_Emp_Details%rowtype;
/*
			Cursor csr_lu_pp_dtls ( csr_v_local_unit_id  hr_organization_information.ORGANIZATION_ID%TYPE
			, csr_v_pension_ins_num  hr_organization_information.org_information1%TYPE)
				IS
					SELECT hoi2.ORG_INFORMATION2
					FROM hr_organization_units o1
					, hr_organization_information hoi1
					, hr_organization_information hoi2
					WHERE  o1.business_group_id =l_business_group_id
					AND hoi1.organization_id = o1.organization_id
					AND hoi1.organization_id =  csr_v_local_unit_id
					AND hoi1.org_information1 = 'FI_LOCAL_UNIT'
					AND hoi1.org_information_context = 'CLASS'
					AND o1.organization_id =hoi2.organization_id
					AND hoi2.ORG_INFORMATION_CONTEXT='FI_LU_PENSION_PROVIDERS'
					AND  hoi2.org_information1=csr_v_pension_ins_num ;

			rg_lu_pp_dtls  csr_lu_pp_dtls%rowtype;

			Cursor csr_le_pp_dtls
			( csr_v_legal_emp_id  hr_organization_information.ORGANIZATION_ID%TYPE
			 , csr_v_pension_type  hr_organization_information.org_information1%TYPE
			 , csr_v_pension_provider  hr_organization_information.org_information1%TYPE
			 ,csr_v_effective_date  DATE  )
				IS
					SELECT  hoi2.ORG_INFORMATION6  , hoi2.ORG_INFORMATION8
					FROM hr_organization_units o1
					, hr_organization_information hoi1
					, hr_organization_information hoi2
					WHERE  o1.business_group_id =l_business_group_id
					AND hoi1.organization_id = o1.organization_id
					AND hoi1.organization_id =   csr_v_legal_emp_id
					AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
					AND hoi1.org_information_context = 'CLASS'
					AND o1.organization_id =hoi2.organization_id
					AND hoi2.ORG_INFORMATION_CONTEXT='FI_PENSION_PROVIDERS'
					AND  hoi2.org_information3=csr_v_pension_type
					AND  hoi2.org_information4=csr_v_pension_provider
					AND csr_v_effective_date  BETWEEN fnd_date.canonical_to_date(hoi2.org_information1) AND
					nvl(fnd_date.canonical_to_date(hoi2.org_information2),to_date('31/12/4712','DD/MM/YYYY')) ;


					rg_le_pp_dtls  csr_le_pp_dtls%rowtype;
*/

		CURSOR csr_Department_code (
		csr_v_pension_provider_id   hr_organization_information.organization_id%TYPE,
		csr_v_legal_emp_id   hr_organization_information.organization_id%TYPE,
		csr_v_Local_unit_id   hr_organization_information.ORG_INFORMATION2%TYPE
		 )
			  IS
				 SELECT hoi2.ORG_INFORMATION3
				   FROM hr_organization_units o1
					, hr_organization_information hoi1
					, hr_organization_information hoi2
					WHERE  o1.business_group_id =l_business_group_id
					AND hoi1.organization_id = o1.organization_id
					AND hoi1.organization_id =  csr_v_pension_provider_id
					AND hoi1.org_information_context = 'CLASS'
					AND hoi1.org_information1 = 'FR_PENSION'
					AND o1.organization_id =hoi2.organization_id
					AND hoi2.ORG_INFORMATION_CONTEXT='FI_PENSION_DEPARTMENT_CODES'
					AND hoi2.ORG_INFORMATION1 = csr_v_legal_emp_id
					AND hoi2.ORG_INFORMATION2 = csr_v_Local_unit_id;


		  rg_Department_code      csr_Department_code%ROWTYPE;



			     /* End of Cursors */

				BEGIN

					--fnd_file.put_line(fnd_file.log,'Range Code 1');

					 IF g_debug THEN
						hr_utility.set_location(' Entering Procedure RANGE_CODE',40);
					 END IF;

					 p_sql := 'SELECT DISTINCT person_id
					FROM  per_people_f ppf
					,pay_payroll_actions ppa
					WHERE ppa.payroll_action_id = :payroll_action_id
					AND   ppa.business_group_id = ppf.business_group_id
					ORDER BY ppf.person_id';
						g_archive := NULL;
						g_emp_type := NULL ;
						g_legal_employer_id := NULL ;
						g_local_unit_id  := NULL ;
						g_effective_date   := NULL ;
						g_pension_provider   := NULL ;
						g_pension_ins_num   := NULL ;
						g_payroll_action_id := p_payroll_action_id ;
						g_le_assignment_action_id   := NULL ;
						g_lu_assignment_action_id   := NULL ;


					--fnd_file.put_line(fnd_file.log,'Range Code 2');
					 PAY_FI_ARCHIVE_LTFA.GET_ALL_PARAMETERS(
					p_payroll_action_id
					,l_business_group_id
					,g_pension_ins_num
					,g_legal_employer_id
					,g_local_unit_id
					,l_month
					,l_year
					,g_effective_date
					,g_archive ) ;


					--fnd_file.put_line(fnd_file.log,'Range Code 3');

					IF  g_archive = 'Y' THEN

					 SELECT count(*)
					 INTO l_count
					FROM   pay_action_information
					WHERE  action_information_category = 'EMEA REPORT DETAILS'
					AND        action_information1             = 'PYFILTFA'
					AND    action_context_id           = p_payroll_action_id;

					IF l_count < 1  then

						l_dept_code:='';

						--fnd_file.put_line(fnd_file.log,'Range Code 5');
						hr_utility.set_location('Entered Procedure GETDATA',10);

						OPEN  csr_Legal_Emp_Details(g_legal_employer_id, g_pension_ins_num, g_effective_date);
							FETCH csr_Legal_Emp_Details INTO rg_Legal_Emp_Details;
						CLOSE csr_Legal_Emp_Details;

						l_le_name	:= rg_Legal_Emp_Details.name ;
						--l_y_number   := rg_Legal_Emp_Details.ORG_INFORMATION1 ;
						g_pension_provider   := rg_Legal_Emp_Details.ORG_INFORMATION4 ;

						--fnd_file.put_line(fnd_file.log,'Range Code 4');
						BEGIN
							pay_balance_pkg.set_context('TAX_UNIT_ID',g_legal_employer_id);
							pay_balance_pkg.set_context('LOCAL_UNIT_ID',g_local_unit_id);
							pay_balance_pkg.set_context('DATE_EARNED',fnd_date.date_to_canonical(g_effective_date));
							pay_balance_pkg.set_context('JURISDICTION_CODE',NULL);
							pay_balance_pkg.set_context('SOURCE_ID',NULL);
							pay_balance_pkg.set_context('TAX_GROUP',NULL);
							pay_balance_pkg.set_context('ORGANIZATION_ID',g_pension_provider);
						END;



						OPEN  csr_pension_provider_details(g_pension_provider);
							FETCH csr_pension_provider_details INTO rg_pension_provider_details;
						CLOSE csr_pension_provider_details;

						l_pp_name	:= rg_pension_provider_details.name ;

						/*
						OPEN  csr_le_pp_dtls(g_legal_employer_id,l_pension_type,g_pension_provider,g_effective_date );
							FETCH csr_le_pp_dtls INTO rg_le_pp_dtls;
						CLOSE csr_le_pp_dtls;

						l_customer_num :=rg_le_pp_dtls.ORG_INFORMATION8 ;
						l_pension_ins_num :=rg_le_pp_dtls.ORG_INFORMATION6 ;

						*/

						IF g_local_unit_id IS NOT NULL THEN

						--fnd_file.put_line(fnd_file.log,'Range Code 6');
						BEGIN

							SELECT		MAX(ASSIGNMENT_ACTION_ID)
							INTO		g_lu_assignment_action_id
							FROM		pay_run_balances
							WHERE		local_unit_id = g_local_unit_id
							AND		organization_id  =g_pension_provider
							AND		 TO_CHAR(effective_date,'MMYYYY')=l_month||l_year ;

						EXCEPTION
							WHEN others THEN
							NULL;
						END;

							l_emp_type:='LU' ;
							l_emp_id:=g_local_unit_id;
							hr_utility.set_location('Calculation for Local Unit',40);

							/* Pick up the details belonging to Local Unit */

							OPEN  csr_Local_Unit_Details( g_local_unit_id);
								FETCH csr_Local_Unit_Details INTO rg_Local_Unit_Details;
							CLOSE csr_Local_Unit_Details;

							l_lu_name	  := rg_Local_Unit_Details.name ;

							OPEN  csr_Department_code( g_pension_provider ,g_legal_employer_id,g_local_unit_id);
							FETCH csr_Department_code INTO rg_Department_code;
							CLOSE csr_Department_code;

							l_dept_code	  :=  rg_Department_code.ORG_INFORMATION3;

							--l_emp_name  := rg_Local_Unit_Details.name ;
							--l_business_id := l_y_number||'-'||rg_Local_Unit_Details.ORG_INFORMATION1 ;

							/*
							OPEN  csr_Local_Unit_Details( g_local_unit_id);
							FETCH csr_Local_Unit_Details INTO rg_Local_Unit_Details;
							CLOSE csr_Local_Unit_Details;

							OPEN  csr_lu_pp_dtls( g_local_unit_id , l_pension_ins_num);
							FETCH csr_lu_pp_dtls INTO rg_lu_pp_dtls;
							CLOSE csr_lu_pp_dtls;

							l_customer_num :=rg_lu_pp_dtls.ORG_INFORMATION2 ;
							*/
							hr_utility.set_location('Pick up the details belonging to Local Unit',60);
							--fnd_file.put_line(fnd_file.log,'Range Code 7');

						ELSE
							--fnd_file.put_line(fnd_file.log,'Range Code 8');
								l_emp_type:='LE' ;
								l_emp_id:=g_legal_employer_id ;

								BEGIN

									SELECT		MAX(ASSIGNMENT_ACTION_ID)
									INTO		g_le_assignment_action_id
									FROM		pay_run_balances
									WHERE		tax_unit_id =g_legal_employer_id
									AND		organization_id  =g_pension_provider
									AND		 TO_CHAR(effective_date,'MMYYYY')=l_month||l_year ;

								EXCEPTION
									WHEN others THEN
									NULL;
								END;



								/* Pick up the details belonging to Legal Employer */

								OPEN  csr_Legal_Emp_Details(g_legal_employer_id, g_pension_ins_num, g_effective_date);
									FETCH csr_Legal_Emp_Details INTO rg_Legal_Emp_Details;
								CLOSE csr_Legal_Emp_Details;

								l_le_name	:= rg_Legal_Emp_Details.name ;
								--l_emp_name	:= rg_Legal_Emp_Details.name ;
								--l_business_id		:= rg_Legal_Emp_Details.ORG_INFORMATION1 ;

						--fnd_file.put_line(fnd_file.log,'Range Code 9');
						END IF ;

/*
--fnd_file.put_line(fnd_file.log,'Range Code 10');
					pay_action_information_api.create_action_information (
					p_action_information_id        => l_action_info_id
					,p_action_context_id            => p_payroll_action_id
					,p_action_context_type          => 'PA'
					,p_object_version_number        => l_ovn
					,p_effective_date               => g_effective_date
					,p_source_id                    => NULL
					,p_source_text                  => NULL
					,p_action_information_category  => 'EMEA REPORT INFORMATION'
					,p_action_information1          => 'PYFILTFA'
					,p_action_information2          => l_emp_type
					,p_action_information3          => l_emp_id
					,p_action_information4          => l_month||substr(l_year,3,2)
					,p_action_information5          => substr(l_emp_name,1,33)
					,p_action_information6          => l_business_id
					,p_action_information7          => g_pension_provider
					,p_action_information8          => l_customer_num
					,p_action_information9          => TO_CHAR(g_effective_date,'DDMMYY')
					,p_action_information10          =>  '1'
					,p_action_information11          =>  'A'
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

*/
  					pay_action_information_api.create_action_information (
					p_action_information_id        => l_action_info_id
					,p_action_context_id            => p_payroll_action_id
					,p_action_context_type          => 'PA'
					,p_object_version_number        => l_ovn
					,p_effective_date               => g_effective_date
					,p_source_id                    => NULL
					,p_source_text                  => NULL
					,p_action_information_category  => 'EMEA REPORT DETAILS'
					,p_action_information1          => 'PYFILTFA'
					,p_action_information2          => g_pension_ins_num
					,p_action_information3          => l_pp_name
					,p_action_information4          => l_le_name
					,p_action_information5          => l_lu_name
					,p_action_information6          => l_month
					,p_action_information7          => l_year
					,p_action_information8          =>  g_legal_employer_id
					,p_action_information9          =>  g_local_unit_id
					,p_action_information10          => l_emp_type
					,p_action_information11          => l_dept_code
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

					--fnd_file.put_line(fnd_file.log,'Range Code 11');
			END IF;

			END IF;

			g_emp_type := l_emp_type;

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
		 CURSOR csr_prepaid_assignments_lu(p_payroll_action_id          	NUMBER,
			 p_start_person      	NUMBER,
			 p_end_person         NUMBER,
			 p_legal_employer_id			NUMBER,
			 p_local_unit_id				NUMBER,
  			 p_pension_ins_num			VARCHAR2,
			 l_canonical_start_date	DATE,
			 l_canonical_end_date	DATE)
		 IS
		 SELECT act.assignment_id            assignment_id,
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
			, per_all_people_f         pap
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
                AND     as1.person_id = pap.person_id
		AND     pap.per_information24  = p_pension_ins_num
		 AND    ppa.effective_date           BETWEEN as1.effective_start_date
			    AND     as1.effective_end_date
	        AND    ppa.effective_date           BETWEEN pap.effective_start_date
			    AND     pap.effective_end_date
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
		AND   hsck.segment2 = p_local_unit_id
		AND   act.TAX_UNIT_ID    =  act1.TAX_UNIT_ID
		AND   act.TAX_UNIT_ID    =  p_legal_employer_id
		 ORDER BY act.assignment_id;

CURSOR csr_prepaid_assignments_le(p_payroll_action_id          	NUMBER,
			 p_start_person      	NUMBER,
			 p_end_person         NUMBER,
			 p_legal_employer_id			NUMBER,
 			 p_pension_ins_num			VARCHAR2,
			 l_canonical_start_date	DATE,
			 l_canonical_end_date	DATE)
		 IS
		 SELECT act.assignment_id            assignment_id,
			act.assignment_action_id     run_action_id,
			act1.assignment_action_id    prepaid_action_id
		 FROM   pay_payroll_actions          ppa,
			pay_payroll_actions          appa,
			pay_payroll_actions          appa2,
			pay_assignment_actions       act,
			pay_assignment_actions       act1,
			pay_action_interlocks        pai,
			per_all_assignments_f        as1
			, per_all_people_f         pap
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
                 AND     as1.person_id = pap.person_id
		AND     pap.per_information24  = p_pension_ins_num
		 AND    ppa.effective_date           BETWEEN as1.effective_start_date
			    AND     as1.effective_end_date
	         AND    ppa.effective_date           BETWEEN pap.effective_start_date
			    AND     pap.effective_end_date
		 AND    act.action_status            = 'C'  -- Completed
		 AND    act.assignment_action_id     = pai.locked_action_id
		 AND    act1.assignment_action_id    = pai.locking_action_id
		 AND    act1.action_status           = 'C' -- Completed
		 AND    act1.payroll_action_id       = appa2.payroll_action_id
		 AND    appa2.action_type            IN ('P','U')
		 AND    appa2.effective_date          BETWEEN l_canonical_start_date
				 AND l_canonical_end_date
			-- Prepayments or Quickpay Prepayments
		 AND   act.TAX_UNIT_ID    =  act1.TAX_UNIT_ID
		AND   act.TAX_UNIT_ID    =  p_legal_employer_id
		ORDER BY act.assignment_id;

	Cursor csr_Get_Defined_Balance_Id(csr_v_Balance_Name FF_DATABASE_ITEMS.USER_NAME%TYPE)
				IS
					SELECT	 ue.creator_id
					FROM	ff_user_entities  ue,
							ff_database_items di
					WHERE	di.user_name = csr_v_Balance_Name
					AND	ue.user_entity_id = di.user_entity_id
					AND	ue.legislation_code = 'FI'
					AND	ue.business_group_id is NULL
					AND	ue.creator_type = 'B';

					lr_Get_Defined_Balance_Id  csr_Get_Defined_Balance_Id%rowtype;

		 l_count NUMBER := 0;
		 l_prev_prepay		NUMBER := 0;
		 l_business_group_id	NUMBER;
		 l_month	   VARCHAR2(2);
		l_year	   VARCHAR2(4);
		 l_canonical_start_date	DATE;
		 l_canonical_end_date    DATE;
		 l_pension_ins_num  hr_organization_information.org_information1%TYPE ;


		 l_prepay_action_id	NUMBER;
		 l_actid NUMBER;
		 l_assignment_id NUMBER;
		 l_action_sequence NUMBER;
		 l_assact_id     NUMBER;
		 l_pact_id NUMBER;
		 l_flag NUMBER := 0;
		 l_defined_balance_id NUMBER :=0;
		 l_action_info_id NUMBER;
		 l_ovn NUMBER;
	 BEGIN
			IF g_debug THEN
				hr_utility.set_location(' Entering Procedure ASSIGNMENT_ACTION_CODE',60);
			END IF;

			--fnd_file.put_line(fnd_file.log,'Assignment Action Code 1');
			 PAY_FI_ARCHIVE_LTFA.GET_ALL_PARAMETERS(
					p_payroll_action_id
					,l_business_group_id
					,g_pension_ins_num
					,g_legal_employer_id
					,g_local_unit_id
					,l_month
					,l_year
					,g_effective_date
					,g_archive ) ;

					g_payroll_action_id :=p_payroll_action_id;
					--fnd_file.put_line(fnd_file.log,'Assignment Action Code 2');


					BEGIN
							pay_balance_pkg.set_context('TAX_UNIT_ID',g_legal_employer_id);
							pay_balance_pkg.set_context('LOCAL_UNIT_ID',g_local_unit_id);
							pay_balance_pkg.set_context('DATE_EARNED',fnd_date.date_to_canonical(g_effective_date));
							pay_balance_pkg.set_context('JURISDICTION_CODE',NULL);
							pay_balance_pkg.set_context('SOURCE_ID',NULL);
							pay_balance_pkg.set_context('TAX_GROUP',NULL);
							pay_balance_pkg.set_context('ORGANIZATION_ID',g_pension_provider);
						END;

		l_canonical_start_date := TO_DATE(l_month||l_year,'MMYYYY');
		l_canonical_end_date   := LAST_DAY(TO_DATE(l_month||l_year,'MMYYYY'));
		l_prepay_action_id := 0;

		IF g_local_unit_id IS NOT NULL THEN
						 g_emp_type := 'LU';
			--fnd_file.put_line(fnd_file.log,'Assignment Action Code 3');

			FOR rec_prepaid_assignments IN csr_prepaid_assignments_lu(p_payroll_action_id
				,p_start_person
				,p_end_person
				 ,g_legal_employer_id
				 ,g_local_unit_id
				 ,g_pension_ins_num
				,l_canonical_start_date
				,l_canonical_end_date)
				LOOP
							--fnd_file.put_line(fnd_file.log,'Assignment Action Code 4');
					IF l_prepay_action_id <> rec_prepaid_assignments.prepaid_action_id THEN
						SELECT pay_assignment_actions_s.NEXTVAL
						INTO   l_actid
						FROM   dual;
						  --
						g_index_assact := g_index_assact + 1;
						g_lock_table(g_index_assact).archive_assact_id := l_actid; /* For Element archival */
					       -- Create the archive assignment action
						    hr_nonrun_asact.insact(l_actid
						  ,rec_prepaid_assignments.assignment_id
						  ,p_payroll_action_id
						  ,p_chunk
						  ,NULL);
						-- Create archive to prepayment assignment action interlock
						--
						--hr_nonrun_asact.insint(l_actid,rec_prepaid_assignments.prepaid_action_id);
					END IF;
					-- create archive to master assignment action interlock
					--hr_nonrun_asact.insint(l_actid,rec_prepaid_assignments.run_action_id);
					l_prepay_action_id := rec_prepaid_assignments.prepaid_action_id;
				END LOOP;

		ELSE
					--fnd_file.put_line(fnd_file.log,'Assignment Action Code 5');
					 g_emp_type := 'LE';

					FOR rec_prepaid_assignments IN csr_prepaid_assignments_le(p_payroll_action_id
					,p_start_person
					,p_end_person
					 ,g_legal_employer_id
				 	 ,g_pension_ins_num
					,l_canonical_start_date
					,l_canonical_end_date)
					LOOP
										--fnd_file.put_line(fnd_file.log,'Assignment Action Code 6');
						IF l_prepay_action_id <> rec_prepaid_assignments.prepaid_action_id THEN
							SELECT pay_assignment_actions_s.NEXTVAL
							INTO   l_actid
							FROM   dual;
							  --
							g_index_assact := g_index_assact + 1;
							g_lock_table(g_index_assact).archive_assact_id := l_actid; /* For Element archival */
						       -- Create the archive assignment action
							    hr_nonrun_asact.insact(l_actid
							  ,rec_prepaid_assignments.assignment_id
							  ,p_payroll_action_id
							  ,p_chunk
							  ,NULL);
							-- Create archive to prepayment assignment action interlock
							--
							--hr_nonrun_asact.insint(l_actid,rec_prepaid_assignments.prepaid_action_id);
						END IF;
						-- create archive to master assignment action interlock
						--hr_nonrun_asact.insint(l_actid,rec_prepaid_assignments.run_action_id);
						l_prepay_action_id := rec_prepaid_assignments.prepaid_action_id;
					END LOOP;
		END IF;
			--fnd_file.put_line(fnd_file.log,'Assignment Action Code 7');
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
		/* Cursor to retrieve Person Details */
		 CURSOR csr_get_person_details(p_asg_act_id NUMBER) IS
		SELECT pap.first_name, pap.last_name, pap.pre_name_adjunct, pap.national_identifier  , pap.person_id  , pac.assignment_id
		FROM
		pay_assignment_actions      	pac,
		per_all_assignments             assign,
		per_all_people			pap
		WHERE pac.assignment_action_id = p_asg_act_id
		AND assign.assignment_id = pac.assignment_id
		AND assign.person_id = pap.person_id
		AND pap.per_information_category = 'FI';

		Cursor csr_Get_Defined_Balance_Id(csr_v_Balance_Name FF_DATABASE_ITEMS.USER_NAME%TYPE)
				IS
					SELECT	 ue.creator_id
					FROM	ff_user_entities  ue,
							ff_database_items di
					WHERE	di.user_name = csr_v_Balance_Name
					AND	ue.user_entity_id = di.user_entity_id
					AND	ue.legislation_code = 'FI'
					AND	ue.business_group_id is NULL
					AND	ue.creator_type = 'B';

					lr_Get_Defined_Balance_Id  csr_Get_Defined_Balance_Id%rowtype;

		rg_get_person_details  csr_get_person_details%rowtype;

		l_Sal_subject_pension NUMBER ;
		l_bik_subject_pension NUMBER ;
		l_tax_exp_subject_pension NUMBER ;
		l_assignment_id NUMBER;
	        l_pension NUMBER ;
   	        l_emp_pension NUMBER ;
		 l_action_context_id	NUMBER;
		l_flag NUMBER := 0;
		l_action_info_id NUMBER;
 		l_ovn NUMBER;
		l_Employee_name	VARCHAR2(240);



	BEGIN
		 IF g_debug THEN
				hr_utility.set_location(' Entering Procedure ARCHIVE_CODE',380);
		 END IF;
				--fnd_file.put_line(fnd_file.log,'Archive Code 1');


		IF g_archive='Y' THEN

			OPEN  csr_get_person_details(p_assignment_action_id);
			FETCH csr_get_person_details INTO rg_get_person_details;
			CLOSE csr_get_person_details;

		        IF rg_get_person_details.PRE_NAME_ADJUNCT IS NULL
			THEN
				l_Employee_name :=rg_get_person_details.LAST_NAME
									||' '||rg_get_person_details.FIRST_NAME;
			ELSE
				l_Employee_name :=rg_get_person_details.PRE_NAME_ADJUNCT||
									' '|| rg_get_person_details.LAST_NAME||
									' '|| rg_get_person_details.FIRST_NAME;
			END IF;


			    -- Pick up the defined balance id belonging to

			BEGIN
					pay_balance_pkg.set_context('ASSIGNMENT_ID',rg_get_person_details.assignment_id);
			END;

			 l_assignment_id:=rg_get_person_details.assignment_id;
				--fnd_file.put_line(fnd_file.log,'Archive Code 2');

			    IF  g_emp_type = 'LU'	THEN

								--fnd_file.put_line(fnd_file.log,'Archive Code 3');
				OPEN  csr_Get_Defined_Balance_Id( 'SALARY_SUBJECT_TO_PENSION_PER_PENSION_LU_MONTH');
				FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
				CLOSE csr_Get_Defined_Balance_Id;

				l_Sal_subject_pension :=to_char(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id, P_ASSIGNMENT_ID =>l_assignment_id , P_VIRTUAL_DATE =>  g_effective_date ),'999999999D99') *100;

				OPEN  csr_Get_Defined_Balance_Id( 'BIK_SUBJECT_TO_PENSION_PER_PENSION_LU_MONTH');
				FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
				CLOSE csr_Get_Defined_Balance_Id;

				l_bik_subject_pension :=to_char(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id, P_ASSIGNMENT_ID =>l_assignment_id , P_VIRTUAL_DATE =>  g_effective_date ),'999999999D99') *100;

				OPEN  csr_Get_Defined_Balance_Id( 'TAXABLE_EXPENSES_SUBJECT_TO_PENSION_PER_PENSION_LU_MONTH');
				FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
				CLOSE csr_Get_Defined_Balance_Id;

				l_tax_exp_subject_pension :=to_char(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id, P_ASSIGNMENT_ID =>l_assignment_id , P_VIRTUAL_DATE =>  g_effective_date ),'999999999D99') *100;

/*
				OPEN  csr_Get_Defined_Balance_Id( 'PENSION_PER_PENSION_LU_MONTH');
				FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
				CLOSE csr_Get_Defined_Balance_Id;

				l_pension :=TO_CHAR(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id, P_ASSIGNMENT_ACTION_ID =>g_lu_assignment_action_id ),'999999999D99') * 100;

				OPEN  csr_Get_Defined_Balance_Id( 'EMPLOYER_PENSION_PER_PENSION_LU_MONTH');
				FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
				CLOSE csr_Get_Defined_Balance_Id;

				l_emp_pension :=TO_CHAR(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id, P_ASSIGNMENT_ACTION_ID =>g_lu_assignment_action_id ),'999999999D99') *100;
*/

				--fnd_file.put_line(fnd_file.log,'Archive Code 4');

			    ELSIF   g_emp_type = 'LE'	THEN

			    					--fnd_file.put_line(fnd_file.log,'Archive Code 5');
				OPEN  csr_Get_Defined_Balance_Id( 'SALARY_SUBJECT_TO_PENSION_PER_PENSION_LE_MONTH');
				FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
				CLOSE csr_Get_Defined_Balance_Id;
				l_Sal_subject_pension :=to_char(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id, P_ASSIGNMENT_ID =>l_assignment_id , P_VIRTUAL_DATE =>  g_effective_date ),'999999999D99') *100;

				OPEN  csr_Get_Defined_Balance_Id( 'BIK_SUBJECT_TO_PENSION_PER_PENSION_LE_MONTH');
				FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
				CLOSE csr_Get_Defined_Balance_Id;
				l_bik_subject_pension :=to_char(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id, P_ASSIGNMENT_ID =>l_assignment_id , P_VIRTUAL_DATE =>  g_effective_date ),'999999999D99') *100;

				OPEN  csr_Get_Defined_Balance_Id( 'TAXABLE_EXPENSES_SUBJECT_TO_PENSION_PER_PENSION_LE_MONTH');
				FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
				CLOSE csr_Get_Defined_Balance_Id;
				l_tax_exp_subject_pension :=to_char(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id, P_ASSIGNMENT_ID =>l_assignment_id , P_VIRTUAL_DATE =>  g_effective_date ),'999999999D99') *100;

/*
				OPEN  csr_Get_Defined_Balance_Id( 'PENSION_PER_PENSION_LE_MONTH');
				FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
				CLOSE csr_Get_Defined_Balance_Id;
				l_pension := TO_CHAR(pay_balance_pkg.get_value(lr_Get_Defined_Balance_Id.creator_id,NULL, g_legal_employer_id, NULL, NULL, NULL, g_effective_date ),'999999999D99') * 100;

				OPEN  csr_Get_Defined_Balance_Id( 'EMPLOYER_PENSION_PER_PENSION_LE_MONTH');
				FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
				CLOSE csr_Get_Defined_Balance_Id;
				l_emp_pension := TO_CHAR(pay_balance_pkg.get_value(lr_Get_Defined_Balance_Id.creator_id,NULL,  g_legal_employer_id, NULL, NULL, NULL, g_effective_date ),'999999999D99') *100;
*/
				--fnd_file.put_line(fnd_file.log,'Archive Code 6');
			     END IF;

			      BEGIN
				 SELECT 1
				   INTO l_flag
				   FROM pay_action_information
				  WHERE action_information_category = 'EMEA REPORT INFORMATION'
				    AND action_information1 = 'PYFILTFA'
				    AND action_information2 = 'PER'
				    AND action_context_id = p_assignment_action_id;
			      EXCEPTION
				 WHEN NO_DATA_FOUND
				 THEN

				 	--fnd_file.put_line(fnd_file.log,'Archive Code 7');
				 	 pay_action_information_api.create_action_information (
				       p_action_information_id=> l_action_info_id,
				       p_action_context_id=> p_assignment_action_id,
				       p_action_context_type=> 'AAP',
				       p_object_version_number=> l_ovn,
				       p_effective_date=> g_effective_date,
				       p_source_id=> NULL,
				       p_source_text=> NULL,
				       p_action_information_category=> 'EMEA REPORT INFORMATION',
				       p_action_information1=> 'PYFILTFA',
				       p_action_information2=> 'PER',
				       p_action_information3=>rg_get_person_details.person_id   ,
				       p_action_information4=>l_Employee_name ,
				       p_action_information5=> rg_get_person_details.national_identifier ,
				       p_action_information6=> '3' ,
				       p_action_information7=> FND_NUMBER.NUMBER_TO_CANONICAL(l_Sal_subject_pension) ,
				       p_action_information8=> FND_NUMBER.NUMBER_TO_CANONICAL(l_bik_subject_pension) ,
				       p_action_information9=> FND_NUMBER.NUMBER_TO_CANONICAL(l_tax_exp_subject_pension) ,
				       p_action_information10=> g_payroll_action_id,
				       p_action_information11=> NULL,
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
				    				--fnd_file.put_line(fnd_file.log,'Archive Code 8');
				 WHEN OTHERS
				 THEN
				    NULL;
			      END;

				--fnd_file.put_line(fnd_file.log,'Archive Code 9');
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

/*
     CURSOR csr_person_pay_action_info(p_payroll_action_id  pay_action_information.action_information1%TYPE)
      IS
         SELECT  COUNT(*) emp_count , sum (FND_NUMBER.CANONICAL_TO_NUMBER(action_information7)  + FND_NUMBER.CANONICAL_TO_NUMBER(action_information8) + FND_NUMBER.CANONICAL_TO_NUMBER(action_information9)) emp_sal
	 ,sum (FND_NUMBER.CANONICAL_TO_NUMBER(action_information11))  pension , sum (FND_NUMBER.CANONICAL_TO_NUMBER(action_information12)) emp_pension
	 FROM pay_action_information
	   WHERE action_information_category = 'EMEA REPORT INFORMATION'
	   AND action_information1 = 'PYFILTFA'
	   AND action_information2 = 'PER'
	   AND action_information10 = p_payroll_action_id ;

	   	Cursor csr_Get_Defined_Balance_Id(csr_v_Balance_Name FF_DATABASE_ITEMS.USER_NAME%TYPE)
				IS
					SELECT	 ue.creator_id
					FROM	ff_user_entities  ue,
							ff_database_items di
					WHERE	di.user_name = csr_v_Balance_Name
					AND	ue.user_entity_id = di.user_entity_id
					AND	ue.legislation_code = 'FI'
					AND	ue.business_group_id is NULL
					AND	ue.creator_type = 'B';

					lr_Get_Defined_Balance_Id  csr_Get_Defined_Balance_Id%rowtype;


           l_total NUMBER ;
	   l_total_ins_fee NUMBER ;
	   l_emp_count NUMBER ;
   	   l_emp_sal NUMBER ;
   	   l_pension NUMBER ;
   	   l_emp_pension NUMBER ;
	   l_assignment_action_id      pay_assignment_actions.assignment_action_id%TYPE;
	   l_action_info_id NUMBER;
      	   l_ovn NUMBER;
	   l_business_group_id	NUMBER;
	   l_month	   VARCHAR2(2);
  	   l_year	   VARCHAR2(4);
 	   l_pension_type  hr_organization_information.org_information1%TYPE ;
*/
BEGIN
		 IF g_debug THEN
				hr_utility.set_location(' Entering Procedure DEINITIALIZATION_CODE',380);
		 END IF;
/*
		 --fnd_file.put_line(fnd_file.log,'Deinitialization Code 1');
		 PAY_FI_ARCHIVE_LTFA.GET_ALL_PARAMETERS(
					p_payroll_action_id
					,l_business_group_id
					,l_pension_type
					,g_pension_provider
					,g_legal_employer_id
					,g_local_unit_id
					,l_month
					,l_year
					,g_effective_date
					,g_archive ) ;

		OPEN csr_person_pay_action_info(p_payroll_action_id);
		FETCH csr_person_pay_action_info INTO l_emp_count , l_emp_sal , l_pension , l_emp_pension ;
		CLOSE csr_person_pay_action_info ;

		IF g_local_unit_id IS NULL THEN

			g_emp_type:= 'LE';

		ELSE
			g_emp_type:= 'LU';
		END IF;

		IF g_archive='Y' THEN
		 				--fnd_file.put_line(fnd_file.log,'Deinitialization Code 2');
					l_total_ins_fee :=  l_pension + l_emp_pension;

					l_total := l_total_ins_fee + (nvl(g_penalty_amt,0)*100) ;

			              pay_action_information_api.create_action_information (
				       p_action_information_id=> l_action_info_id,
				       p_action_context_id=> p_payroll_action_id,
				       p_action_context_type=> 'PA',
				       p_object_version_number=> l_ovn,
				       p_effective_date=> g_effective_date,
				       p_source_id=> NULL,
				       p_source_text=> NULL,
				       p_action_information_category=> 'EMEA REPORT INFORMATION',
				       p_action_information1=> 'PYFILTFA',
				       p_action_information2=> g_emp_type,
				       p_action_information3=>'S' ,
				       p_action_information4=> l_emp_count ,
				       p_action_information5=> FND_NUMBER.NUMBER_TO_CANONICAL(l_emp_sal) ,
				       p_action_information6=>  FND_NUMBER.NUMBER_TO_CANONICAL(l_total_ins_fee)  ,
				       p_action_information7=>  FND_NUMBER.NUMBER_TO_CANONICAL((nvl(g_penalty_amt,0))*100) ,
				       p_action_information8=> FND_NUMBER.NUMBER_TO_CANONICAL(l_total) ,
				       p_action_information9=> NULL ,
				       p_action_information10=> p_payroll_action_id,
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

				    		 				--fnd_file.put_line(fnd_file.log,'Deinitialization Code 3');

	END IF;---ARCHIVE=YES

	*/
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
		  g_emp_type := NULL ;
		 g_legal_employer_id := NULL ;
		 g_local_unit_id  := NULL ;
		 g_effective_date   := NULL ;
		g_pension_ins_num := NULL ;
		 g_payroll_action_id :=  NULL ;
 END PAY_FI_ARCHIVE_LTFA;

/
