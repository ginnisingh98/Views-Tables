--------------------------------------------------------
--  DDL for Package Body PAY_FI_ARCHIVE_ACRA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FI_ARCHIVE_ACRA" as
/* $Header: pyfiacra.pkb 120.6 2006/04/03 05:43:39 dbehera noship $ */
	 TYPE lock_rec IS RECORD (
	      archive_assact_id    NUMBER);
	 TYPE lock_table      IS TABLE OF  lock_rec      INDEX BY BINARY_INTEGER;
	 g_debug   boolean   :=  hr_utility.debug_enabled;
	 g_lock_table   		          lock_table;
	 g_package           VARCHAR2(33) := ' PAY_FI_ACC_REP_ARCHIVE.';
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
		   l_proc VARCHAR2(40):= g_package||' get parameter ';
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
        p_payroll_action_id                    IN   NUMBER
       ,p_business_group_id               OUT  NOCOPY NUMBER
       ,p_legal_employer_id			OUT  NOCOPY  NUMBER
       ,p_local_unit_id				OUT  NOCOPY  NUMBER
       ,p_element_type_id           OUT NOCOPY NUMBER
       ,p_element_set_id            OUT NOCOPY NUMBER
       ,p_start_date                OUT NOCOPY DATE
       ,p_end_date				    OUT  NOCOPY DATE
       ,p_effective_date          OUT NOCOPY DATE
       ,p_archive					OUT  NOCOPY  VARCHAR2
	) IS
		CURSOR csr_parameter_info(p_payroll_action_id NUMBER) IS
		SELECT PAY_FI_ARCHIVE_ACRA.GET_PARAMETER(legislative_parameters,
		'LEGAL_EMPLOYER')
		,PAY_FI_ARCHIVE_ACRA.GET_PARAMETER(legislative_parameters,'LOCAL_UNIT_NAME')
		,PAY_FI_ARCHIVE_ACRA.GET_PARAMETER(legislative_parameters,'ELEMENT_NAME')
		,PAY_FI_ARCHIVE_ACRA.GET_PARAMETER(legislative_parameters,'ELEMENT_SET')
		,FND_DATE.canonical_to_date(PAY_FI_ARCHIVE_ACRA.GET_PARAMETER
		(legislative_parameters,'START_DATE'))
		,FND_DATE.canonical_to_date(PAY_FI_ARCHIVE_ACRA.GET_PARAMETER
		(legislative_parameters,'END_DATE'))
		,PAY_FI_ARCHIVE_ACRA.GET_PARAMETER(legislative_parameters,'ARCHIVE')
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
			,p_local_unit_id
			,p_element_type_id
          		,p_element_set_id
          		,p_start_date
          		,p_end_date
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
			l_action_info_id NUMBER;
			l_ovn NUMBER;
			l_count NUMBER := 0;
			l_actid NUMBER;
			l_assignment_id NUMBER;
			l_business_group_id    NUMBER;
			l_month      VARCHAR2(2);
			l_year      VARCHAR2(4);
			l_start_date       DATE;
			l_end_date       DATE;
			l_effective_date DATE;
			l_legal_employer_id    NUMBER ;
			l_local_unit_id        NUMBER ;
			d_local_unit_id        NUMBER ;
			l_local      VARCHAR2(10);
			l_emp_type  VARCHAR2(2);
			l_emp_id        hr_organization_units.organization_id%TYPE ;
			l_emp_name       hr_organization_units.name%TYPE;
			l_le_name            hr_organization_units.name%TYPE ;
			l_lu_name            hr_organization_units.name%TYPE ;
			l_element_name       pay_element_types_f.element_name%TYPE;
			l_element_set_name   pay_element_sets.element_set_name%TYPE;
			l_business_id               hr_organization_information.org_information1%TYPE ;
			l_y_number		   hr_organization_information.org_information1%TYPE ;
			l_assignment_action_id      pay_assignment_actions.assignment_action_id%TYPE;
			l_element_type_id    pay_element_types_f.element_type_id%TYPE ;
			d_element_type_id    pay_element_types_f.element_type_id%TYPE ;
			l_element_set_id     pay_element_set_members.element_set_id%TYPE;
			l_con_Segments       pay_cost_allocation_keyflex.concatenated_segments%TYPE;
			l_cost_allocation_softflex_id    pay_costs.cost_allocation_keyflex_id%TYPE;
			l_debit_or_credit    pay_costs.debit_or_credit%TYPE;
			l_cost_value         pay_costs.costed_value%TYPE;
			credit               pay_costs.costed_value%TYPE;
			debit                pay_costs.costed_value%TYPE;
			l_counter   number := 0;
			l_archive      VARCHAR2(3);
           	     					/* Cursors */
			Cursor csr_Local_Unit_Details ( csr_v_local_unit_id
			hr_organization_information.ORGANIZATION_ID%TYPE)
				IS
					SELECT o1.name , hoi2.ORG_INFORMATION1 , hoi2.ORG_INFORMATION7
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
			Cursor csr_Legal_Emp_Details ( csr_v_legal_emp_id
			hr_organization_information.ORGANIZATION_ID%TYPE)
				IS
					SELECT o1.name ,hoi2.ORG_INFORMATION1 , hoi2.ORG_INFORMATION11
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
			Cursor csr_Element_Details(csr_v_element_type_id
			pay_element_types_f.element_type_id%TYPE)
				IS
					SELECT element_name
					FROM pay_element_types_f
	         		        WHERE element_type_id=csr_v_element_type_id
					AND (business_group_id=l_business_group_id
					OR legislation_code='FI');
			rg_Element_Details csr_Element_Details%rowtype;
			Cursor csr_ElementSet_Details(csr_v_element_set_id
			pay_element_sets.element_set_id%TYPE)
		                IS
					SELECT element_set_name
			                FROM pay_element_sets
					WHERE element_set_id=csr_v_element_set_id
					AND (business_group_id=l_business_group_id
					OR legislation_code='FI');
	                rg_ElementSet_Details csr_ElementSet_Details%rowtype;
	                Cursor csr_ElementSet_Members(csr_v_element_set_id
			pay_element_sets.element_set_id%TYPE)
			        IS
					SELECT element_type_id
					FROM pay_element_set_members
					WHERE element_set_id=csr_v_element_set_id;
	                rg_ElementSet_Members csr_ElementSet_Members%rowtype;
	                Cursor csr_Local_unit_Legal(csr_v_legal_unit_id
			hr_organization_units.organization_id%TYPE)
				IS
					SELECT hoi2.ORG_INFORMATION1 local_unit
					FROM hr_organization_units o1
					, hr_organization_information hoi1
					, hr_organization_information hoi2
					WHERE  o1.business_group_id =l_business_group_id
					AND hoi1.organization_id = o1.organization_id
					AND hoi1.organization_id =  csr_v_legal_unit_id
					AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
					AND hoi1.org_information_context = 'CLASS'
					AND o1.organization_id =hoi2.organization_id
					AND hoi2.ORG_INFORMATION_CONTEXT='FI_LOCAL_UNITS';
			Cursor csr_Costing_Details(csr_V_element_type_id
			pay_element_types_f.element_type_id%TYPE)
				IS
					SELECT Distinct pet.element_type_id
					,pet.element_name
					,pcak.concatenated_segments
					,pc.cost_allocation_keyflex_id
					,pc.debit_or_credit
					,sum(pc.costed_value) costed_value
					FROM pay_element_types_f pet
					, pay_input_values_f piv
					, pay_run_results prr
					/*, pay_element_set_members pesm*/
					, pay_costs pc
					, pay_cost_allocation_keyflex pcak
					, pay_assignment_actions paa
					, pay_payroll_actions ppa
					, per_all_assignments_f paaf
					, hr_soft_coding_keyflex hsck
					WHERE pet.element_type_id =l_element_type_id
					AND (pet.business_group_id = l_business_group_id
					OR pet.legislation_code='FI')
					/*AND pet.element_type_id=pesm.element_type_id (+)*/
					AND pet.element_type_id = piv.element_type_id
					AND piv.name ='Pay Value'
					AND nvl(pc.distributed_input_value_id, pc.input_value_id) =
					piv.input_value_id
					AND prr.element_type_id = pet.element_type_id
					AND prr.run_result_id = pc.run_result_id
					AND pc.balance_or_cost       = 'C'
					AND pc.cost_allocation_keyflex_id = pcak.cost_allocation_keyflex_id
					AND prr.assignment_action_id = paa.assignment_action_id
					AND paa.payroll_action_id = ppa.payroll_action_id
					AND ppa.date_earned between pet.effective_start_date and
					pet.effective_end_date
					AND ppa.date_earned between l_start_date and l_end_date
					AND paa.assignment_id = paaf.assignment_id
					AND ppa.date_earned between paaf.effective_start_date and
					paaf.effective_end_date
					AND ppa.date_earned between piv.effective_start_date and
					piv.effective_end_date
					AND paaf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
					AND hsck.segment2 = nvl(l_local,hsck.segment2)
					GROUP BY pet.element_type_id
					,pet.element_name
					,pcak.concatenated_segments
					,pc.debit_or_credit
					,pc.cost_allocation_keyflex_id;
			rg_Costing_Details csr_Costing_Details%rowtype;
			TYPE ty_Costing_Details is TABLE OF csr_Costing_Details%rowtype  INDEX BY
			BINARY_INTEGER;
			Costing_Details ty_Costing_details;
							     /* End of Cursors */
			BEGIN

			     IF g_debug THEN
						hr_utility.set_location(' Entering Procedure RANGE_CODE',10);
		             END IF;
			     p_sql := 'SELECT DISTINCT person_id
			     FROM  per_people_f ppf
			     ,pay_payroll_actions ppa
			     WHERE ppa.payroll_action_id = :payroll_action_id
			     AND   ppa.business_group_id = ppf.business_group_id
			     ORDER BY ppf.person_id';
			     PAY_FI_ARCHIVE_ACRA.GET_ALL_PARAMETERS(
					p_payroll_action_id
					,l_business_group_id
					,l_legal_employer_id
					,l_local_unit_id
					,l_element_type_id
					,l_element_set_id
					,l_start_date
					,l_end_date
					,l_effective_date
					,l_archive ) ;
					/*l_local:=fnd_number.number_to_canonical(l_local_unit_id);*/
 				         l_local:=To_char(l_local_unit_id);
 			     d_element_type_id:=l_element_type_id;
 			     d_local_unit_id:=l_local_unit_id;
			     IF  l_archive = 'Y' THEN
				SELECT count(*)  INTO l_count
				FROM pay_action_information
				WHERE action_information_category = 'EMEA REPORT DETAILS'
				AND action_information1= 'PYFIACRA'
				AND action_context_id= p_payroll_action_id;
					IF l_count < 1  then
						OPEN  csr_Legal_Emp_Details(l_legal_employer_id);
							FETCH csr_Legal_Emp_Details INTO rg_Legal_Emp_Details;
						CLOSE csr_Legal_Emp_Details;
						l_le_name	:= rg_Legal_Emp_Details.name ;
						l_y_number   := rg_Legal_Emp_Details.ORG_INFORMATION1 ;
			                        pay_action_information_api.create_action_information (
							p_action_information_id        => l_action_info_id
							,p_action_context_id            => p_payroll_action_id
							,p_action_context_type          => 'PA'
							,p_object_version_number        => l_ovn
							,p_effective_date               => l_effective_date
			        			,p_source_id                    => NULL
							,p_source_text                  => NULL
							,p_action_information_category  => 'EMEA REPORT INFORMATION'
							,p_action_information1          => 'PYFIACRA'
							,p_action_information2          => 'LE'
							,p_action_information3          => l_legal_employer_id
							,p_action_information4          => l_le_name
							,p_action_information5          => l_y_number
							,p_action_information6          => l_business_group_id);
						IF l_local_unit_id IS NOT NULL THEN
							l_emp_type:='LU' ;
							l_emp_id:=l_local_unit_id;
							/* Pick up the details belonging to Local Unit */
							OPEN  csr_Local_Unit_Details( l_local_unit_id);
								FETCH csr_Local_Unit_Details INTO rg_Local_Unit_Details;
							CLOSE csr_Local_Unit_Details;
							l_lu_name:= rg_Local_Unit_Details.name ;
							l_business_id:= rg_Local_Unit_Details.ORG_INFORMATION1 ;
							l_emp_name:=l_lu_name;
							pay_action_information_api.create_action_information (
								p_action_information_id        => l_action_info_id
								,p_action_context_id            => p_payroll_action_id
								,p_action_context_type          => 'PA'
								,p_object_version_number        => l_ovn
								,p_effective_date               => l_effective_date
			        				,p_source_id                    => NULL
								,p_source_text                  => NULL
								,p_action_information_category  => 'EMEA REPORT INFORMATION'
								,p_action_information1          => 'PYFIACRA'
								,p_action_information2          => 'LU'
								,p_action_information3          => l_local_unit_id
								,p_action_information4          => l_lu_name
								,p_action_information5          => l_legal_employer_id
								,p_action_information6          => l_business_id );

							IF l_element_type_id IS NOT NULL THEN
								For csr_cost in csr_costing_details(l_element_type_id ) LOOP
									l_element_type_id:=csr_cost.element_type_id;
					                                l_element_name:=csr_cost.element_name;
									l_con_segments:=csr_cost.concatenated_segments;
									l_cost_allocation_softflex_id:=csr_cost.cost_allocation_keyflex_id;
									l_debit_or_credit:=csr_cost.debit_or_credit;
									l_cost_value:=csr_cost.costed_value;
									IF csr_cost.debit_or_credit='C' THEN
										credit:=csr_cost.costed_Value;
									ELSE
										debit:=csr_cost.costed_Value;
									END IF;
								END LOOP;
								IF l_cost_value IS NOT NULL THEN
								pay_action_information_api.create_action_information (
									p_action_information_id        => l_action_info_id
									,p_action_context_id            => p_payroll_action_id
									,p_action_context_type          => 'PA'
									,p_object_version_number        => l_ovn
									,p_effective_date               => l_effective_date
			        					,p_source_id                    => NULL
									,p_source_text                  => NULL
									,p_action_information_category  => 'EMEA REPORT INFORMATION'
									,p_action_information1          => 'PYFIACRA'
									,p_action_information2          => 'EL'
									,p_action_information3          => l_element_type_id
									,p_action_information4          => l_element_name
									,p_action_information5          => l_local_unit_id
									,p_action_information6          => l_con_segments
									,p_action_information7          => FND_NUMBER.NUMBER_TO_CANONICAL(credit)
									,p_action_information8          => FND_NUMBER.NUMBER_TO_CANONICAL(debit));
								END IF;
								l_cost_value:=NULL;
								credit:=NULL;
								debit:=NULL;
							ELSE
								OPEN csr_ElementSet_Details(l_element_set_id) ;
									FETCH csr_ElementSet_Details INTO rg_ElementSet_Details;
					                        l_element_set_name:=
								rg_ElementSet_Details.element_set_name;
								CLOSE csr_ElementSet_Details;
								pay_action_information_api.create_action_information (
    									p_action_information_id        => l_action_info_id
	       								,p_action_context_id            => p_payroll_action_id
	   	       							,p_action_context_type          => 'PA'
			     						,p_object_version_number        => l_ovn
			 	       					,p_effective_date               => l_effective_date
			             					,p_source_id                    => NULL
									,p_source_text                  => NULL
									,p_action_information_category  => 'EMEA REPORT INFORMATION'
									,p_action_information1          => 'PYFIACRA'
									,p_action_information2          => 'ES'
									,p_action_information3          => l_element_set_id
									,p_action_information4          => l_element_set_name);
								FOR csr_member in csr_ElementSet_Members(l_element_set_id) LOOP
								       l_element_type_id:=csr_member.element_type_id;
								       For csr_cost in csr_costing_details(l_element_type_id ) LOOP
										l_element_type_id:=csr_cost.element_type_id;
										l_element_name:=csr_cost.element_name;
										l_con_segments:=csr_cost.concatenated_segments;
										l_cost_allocation_softflex_id:=csr_cost.cost_allocation_keyflex_id;
										l_debit_or_credit:=csr_cost.debit_or_credit;
										l_cost_value:=csr_cost.costed_value;
								                IF csr_cost.debit_or_credit='C' THEN
											credit:=csr_cost.costed_Value;
										ELSE
											debit:=csr_cost.costed_Value;
										END IF;
									END LOOP;
									IF l_cost_value IS NOT NULL THEN
										pay_action_information_api.create_action_information (
    											p_action_information_id        => l_action_info_id
	       										,p_action_context_id            => p_payroll_action_id
	   	       									,p_action_context_type          => 'PA'
			     								,p_object_version_number        => l_ovn
			 	       							,p_effective_date               => l_effective_date
			             							,p_source_id                    => NULL
											,p_source_text                  => NULL
											,p_action_information_category  => 'EMEA REPORT INFORMATION'
											,p_action_information1          => 'PYFIACRA'
        										,p_action_information2          => 'EL'
											,p_action_information3          => l_element_type_id
											,p_action_information4          => l_element_name
											,p_action_information5          => l_local_unit_id
											,p_action_information6          => l_con_segments
											,p_action_information7          => FND_NUMBER.NUMBER_TO_CANONICAL(credit)
											,p_action_information8          => FND_NUMBER.NUMBER_TO_CANONICAL(debit));
									END IF;
									l_cost_value:=NULL;
									credit:=NULL;
									debit:=NULL;
								END LOOP;
							END IF;
						ELSE
							FOR csr_Local IN csr_Local_unit_Legal(l_legal_employer_id) LOOP
								OPEN  csr_Local_Unit_Details( csr_Local.local_unit);
									FETCH csr_Local_Unit_Details INTO rg_Local_Unit_Details;
								CLOSE csr_Local_Unit_Details;
								l_local_unit_id:=csr_Local.local_unit;
								/*l_local:=fnd_number.number_to_canonical(l_local_unit_id);*/
								l_local:=To_char(l_local_unit_id);
								l_lu_name	:= rg_Local_Unit_Details.name ;
								l_business_id		:= rg_Local_Unit_Details.ORG_INFORMATION1 ;
								l_emp_name:=l_lu_name;
								pay_action_information_api.create_action_information (
									p_action_information_id        => l_action_info_id
									,p_action_context_id            => p_payroll_action_id
									,p_action_context_type          => 'PA'
									,p_object_version_number        => l_ovn
									,p_effective_date               => l_effective_date
			        					,p_source_id                    => NULL
									,p_source_text                  => NULL
									,p_action_information_category  => 'EMEA REPORT INFORMATION'
									,p_action_information1          => 'PYFIACRA'
									,p_action_information2          => 'LU'
									,p_action_information3          => l_local_unit_id
									,p_action_information4          => l_lu_name
									,p_action_information5          => l_legal_employer_id
									,p_action_information6          => l_business_id );
								IF l_element_type_id IS NOT NULL THEN
									For csr_cost in csr_costing_details(l_element_type_id ) LOOP
										l_element_type_id:=csr_cost.element_type_id;
										l_element_name:=csr_cost.element_name;
										l_con_segments:=csr_cost.concatenated_segments;
										l_cost_allocation_softflex_id:=csr_cost.cost_allocation_keyflex_id;
										l_debit_or_credit:=csr_cost.debit_or_credit;
										l_cost_value:=csr_cost.costed_value;
										IF csr_cost.debit_or_credit='C' THEN
											credit:=csr_cost.costed_Value;
										ELSE
											debit:=csr_cost.costed_Value;
										END IF;
									END LOOP;
									IF l_cost_value IS NOT NULL THEN
									pay_action_information_api.create_action_information (
										p_action_information_id        => l_action_info_id
										,p_action_context_id            => p_payroll_action_id
										,p_action_context_type          => 'PA'
										,p_object_version_number        => l_ovn
										,p_effective_date               => l_effective_date
				        					,p_source_id                    => NULL
										,p_source_text                  => NULL
										,p_action_information_category  => 'EMEA REPORT INFORMATION'
										,p_action_information1          => 'PYFIACRA'
										,p_action_information2          => 'EL'
										,p_action_information3          => l_element_type_id
										,p_action_information4          => l_element_name
										,p_action_information5          => l_local_unit_id
										,p_action_information6          => l_con_segments
										,p_action_information7          => FND_NUMBER.NUMBER_TO_CANONICAL(credit)
										,p_action_information8          => FND_NUMBER.NUMBER_TO_CANONICAL(debit));
									END IF;
									l_cost_value:=NULL;
									credit:=NULL;
									debit:=NULL;
								ELSE
									SELECT count(*)  INTO l_count
        								FROM   pay_action_information
									WHERE  action_information_category = 'EMEA REPORT INFORMATION'
									AND action_information1='PYFIACRA'
      									AND action_information2='ES'
									AND action_context_id= p_payroll_action_id;
    									IF l_count < 1 THEN
										OPEN csr_ElementSet_Details(l_element_set_id ) ;
							                                FETCH csr_ElementSet_Details INTO
											rg_ElementSet_Details;
						                                l_element_set_name:=
										rg_ElementSet_Details.element_set_name;
										CLOSE csr_ElementSet_Details;
										pay_action_information_api.create_action_information (
    											p_action_information_id        => l_action_info_id
	       										,p_action_context_id            => p_payroll_action_id
	   	       									,p_action_context_type          => 'PA'
			     								,p_object_version_number        => l_ovn
				 	       						,p_effective_date               => l_effective_date
				             						,p_source_id                    => NULL
											,p_source_text                  => NULL
											,p_action_information_category  => 'EMEA REPORT INFORMATION'
											,p_action_information1          => 'PYFIACRA'
											,p_action_information2          => 'ES'
											,p_action_information3          => l_element_set_id
											,p_action_information4          => l_element_set_name);
									END IF;
									FOR csr_member in csr_ElementSet_Members(l_element_set_id) LOOP
										l_element_type_id:=csr_member.element_type_id;
										For csr_cost in csr_costing_details(l_element_type_id ) LOOP
											l_element_type_id:=csr_cost.element_type_id;
											l_element_name:=csr_cost.element_name;
											l_con_segments:=csr_cost.concatenated_segments;
											l_cost_allocation_softflex_id:=csr_cost.cost_allocation_keyflex_id;
											l_debit_or_credit:=csr_cost.debit_or_credit;
									                l_cost_value:=csr_cost.costed_value;
											IF csr_cost.debit_or_credit='C' THEN
												credit:=csr_cost.costed_Value;
											ELSE
												debit:=csr_cost.costed_Value;
											END IF;
										END LOOP;
										IF l_cost_value IS NOT NULL THEN
											pay_action_information_api.create_action_information (
    												p_action_information_id        => l_action_info_id
	       											,p_action_context_id            => p_payroll_action_id
	   	       										,p_action_context_type          => 'PA'
			     									,p_object_version_number        => l_ovn
			 	       								,p_effective_date               => l_effective_date
			             								,p_source_id                    => NULL
										                ,p_source_text                  => NULL
												,p_action_information_category  => 'EMEA REPORT INFORMATION'
												,p_action_information1          => 'PYFIACRA'
        											,p_action_information2          => 'EL'
												,p_action_information3          => l_element_type_id
												,p_action_information4          => l_element_name
												,p_action_information5          => l_local_unit_id
												,p_action_information6          => l_con_segments
												,p_action_information7          => FND_NUMBER.NUMBER_TO_CANONICAL(credit)
												,p_action_information8          => FND_NUMBER.NUMBER_TO_CANONICAL(debit));
										END IF;
										l_cost_value:=NULL;
										credit:=NULL;
										debit:=NULL;
									END LOOP;
								END IF;
								l_element_type_id:=NULL;
							END LOOP;
						END IF ;
						IF d_local_unit_id IS NULL THEN
							l_lu_name:=NULL;
						END IF;
						IF d_element_type_id IS NULL THEN
							l_element_name:=NULL;
						END IF;
						pay_action_information_api.create_action_information (
							p_action_information_id        =>  l_action_info_id
							,p_action_context_id            => p_payroll_action_id
            						,p_action_context_type          => 'PA'
           						,p_object_version_number        => l_ovn
							,p_effective_date               => l_effective_date
							,p_source_id                    => NULL
							,p_source_text                  => NULL
							,p_action_information_category  => 'EMEA REPORT DETAILS'
							,p_action_information1          => 'PYFIACRA'
							,p_action_information2          => l_le_name
							,p_action_information3          => l_legal_employer_id
							,p_action_information4          => l_lu_name
							,p_action_information5          => d_local_unit_id
							,p_action_information6          => l_element_name
							,p_action_information7          => d_element_type_id
							,p_action_information8          => l_element_set_name
							,p_action_information9          => l_element_set_id
							,p_action_information10         => l_start_date
							,p_action_information11         => l_end_date);
					END IF;
				END IF;
				IF g_debug THEN
 					hr_utility.set_location(' Leaving Procedure RANGE_CODE',50);
				END IF;
			EXCEPTION
				WHEN OTHERS THEN
				-- Return cursor that selects no rows
				p_sql := 'select 1 from dual where to_char(:payroll_action_id) = dummy';
			END RANGE_CODE;
	 /* ASSIGNMENT ACTION CODE */
	 PROCEDURE ASSIGNMENT_ACTION_CODE
	 (p_payroll_action_id     IN NUMBER
	 ,p_start_person          IN NUMBER
	 ,p_end_person            IN NUMBER
	 ,p_chunk                 IN NUMBER)
	 IS
	 BEGIN
--	 fnd_file.put_line (fnd_file.LOG, 'Entering Assignment Action Code' );
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
	 fnd_file.put_line (fnd_file.LOG, 'Entering Initialization Code' );
		 IF g_debug THEN
		      hr_utility.set_location(' Entering Procedure INITIALIZATION_CODE',80);
		 END IF;
		 IF g_debug THEN
		      hr_utility.set_location(' Leaving Procedure INITIALIZATION_CODE',90);
		 END IF;
		  fnd_file.put_line (fnd_file.LOG, 'Existing Initialization Code' );
		 EXCEPTION WHEN OTHERS THEN
		 g_err_num := SQLCODE;
		 IF g_debug THEN
		      hr_utility.set_location('ORA_ERR: ' || g_err_num ||
		      'In INITIALIZATION_CODE',180);
		 END IF;
	 fnd_file.put_line (fnd_file.LOG, 'Error in Initialization Code' );
	 END INITIALIZATION_CODE;
 	 /* ARCHIVE CODE */
	 PROCEDURE ARCHIVE_CODE(p_assignment_action_id IN NUMBER
			      ,p_effective_date    IN DATE)
	 IS
	BEGIN
	fnd_file.put_line (fnd_file.LOG, 'entering archive code' );
		 IF g_debug THEN
				hr_utility.set_location(' Entering Procedure ARCHIVE_CODE',80);
		 END IF;
		 IF g_debug THEN
				hr_utility.set_location(' Leaving Procedure ARCHIVE_CODE',90);
		 END IF;
    fnd_file.put_line (fnd_file.LOG, 'Exiting archive code' );
	END ARCHIVE_CODE;
 END PAY_FI_ARCHIVE_ACRA;

/
