--------------------------------------------------------
--  DDL for Package Body PAY_NO_ARCHIVE_RSEA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NO_ARCHIVE_RSEA" AS
 /* $Header: pynorsea.pkb 120.0.12000000.1 2007/05/20 09:45:02 rlingama noship $ */

	 g_debug   boolean   :=  hr_utility.debug_enabled;
	 g_package           VARCHAR2(33) := ' PAY_NO_ARCHIVE_RSEA.';
	 g_err_num NUMBER;
	 g_errm VARCHAR2(150);

	 -- Function to get defined balance id

	FUNCTION get_defined_balance_id
	  (p_balance_name   		IN  VARCHAR2
	  ,p_dbi_suffix     		IN  VARCHAR2 ) RETURN NUMBER IS

	  l_defined_balance_id 		NUMBER;

	BEGIN

		SELECT pdb.defined_balance_id
		INTO   l_defined_balance_id
		FROM   pay_defined_balances      pdb
		      ,pay_balance_types         pbt
		      ,pay_balance_dimensions    pbd
		WHERE  pbd.database_item_suffix = p_dbi_suffix
		AND    pbd.legislation_code = 'NO'
		AND    pbt.balance_name = p_balance_name
		AND    pbt.legislation_code = 'NO'
		AND    pdb.balance_type_id = pbt.balance_type_id
		AND    pdb.balance_dimension_id = pbd.balance_dimension_id
		AND    pdb.legislation_code = 'NO';

		l_defined_balance_id := NVL(l_defined_balance_id,0);

	RETURN l_defined_balance_id ;
	END get_defined_balance_id ;



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
--		,p_period					OUT  NOCOPY  VARCHAR2
--		,p_year						OUT  NOCOPY  VARCHAR2
		,p_effective_date                         OUT  NOCOPY DATE
		,p_archive					OUT  NOCOPY  VARCHAR2
		) IS

		CURSOR csr_parameter_info(p_payroll_action_id NUMBER) IS
		SELECT PAY_NO_ARCHIVE_RSEA.GET_PARAMETER(legislative_parameters,'LEGAL_EMPLOYER_NAME')
		,PAY_NO_ARCHIVE_RSEA.GET_PARAMETER(legislative_parameters,'LOCAL_UNIT_NAME')
--		,LPAD(PAY_NO_ARCHIVE_RSEA.GET_PARAMETER(legislative_parameters,'PERIOD_RPT'),2,'0')
--		,PAY_NO_ARCHIVE_RSEA.GET_PARAMETER(legislative_parameters,'YEAR_RPT')
		,PAY_NO_ARCHIVE_RSEA.GET_PARAMETER(legislative_parameters,'ARCHIVE')
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
--				,p_period
--				,p_year
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

			l_defined_balance_id NUMBER := 0;
			l_count NUMBER := 0;

			l_business_group_id    NUMBER;
			l_period      VARCHAR2(2);
			l_year      VARCHAR2(4);
			l_canonical_start_date DATE;
			l_canonical_end_date    DATE;
			l_effective_date       DATE;
			l_legal_employer_id    NUMBER ;
			l_local_unit_id        NUMBER ;
			l_emp_id        hr_organization_units.organization_id%TYPE ;
			l_lu_name            hr_organization_units.name%TYPE ;
			l_business_id               hr_organization_information.org_information1%TYPE ;
			l_archive      VARCHAR2(3);

			l_le_name		hr_organization_units.name%TYPE ;
			l_org_number	hr_organization_information.org_information1%TYPE ;
			l_municipal_no	hr_organization_information.org_information1%TYPE ;
			l_industry_status		hr_organization_information.org_information1%TYPE ;
			l_tax_office_name   hr_organization_units.name%TYPE ;
			l_tax_office_id             hr_organization_information.organization_id%TYPE ;

			l_address_line_1 hr_locations.address_line_1%TYPE ;
			l_address_line_2 hr_locations.address_line_2%TYPE ;
			l_address_line_3 hr_locations.address_line_3%TYPE ;
			l_postal_code hr_locations.postal_code%TYPE ;
			l_postal_office hr_locations.postal_code%TYPE ;

			l_phone             hr_organization_information.org_information1%TYPE ;
			l_email               hr_organization_information.org_information1%TYPE ;

			l_taddress_line_1 hr_locations.address_line_1%TYPE ;
			l_taddress_line_2 hr_locations.address_line_2%TYPE ;
			l_taddress_line_3 hr_locations.address_line_3%TYPE ;
			l_tpostal_code hr_locations.postal_code%TYPE ;
			l_tpostal_office hr_locations.postal_code%TYPE ;

			l_reporting_start_date DATE;
			l_reporting_end_date DATE;

			l_municipal_name  VARCHAR2(30);
			l_zone NUMBER;
			l_Witholding_Tax NUMBER;
			l_u_contribution_basis NUMBER;
			l_o_contribution_basis NUMBER;
			l_tWitholding_Tax NUMBER;
			l_tu_contribution_basis NUMBER;
			l_to_contribution_basis NUMBER;
			l_u_rate NUMBER;
			l_o_rate NUMBER;
			l_u_calc_contribution NUMBER;
			l_o_calc_contribution NUMBER;
			l_eWitholding_Tax NUMBER;
			l_eu_contribution_basis NUMBER;
			l_eo_contribution_basis NUMBER;
			l_eu_rate NUMBER;
			l_eo_rate NUMBER;
			l_eu_calc_contribution NUMBER;
			l_eo_calc_contribution  NUMBER;
			l_def_bal_id NUMBER;
			l_tfe_spr_contribution_basis	NUMBER;
			l_tfe_spr_calc_contribution	NUMBER;
			l_fe_spr_contribution_basis	NUMBER;
			l_fe_spr_calc_contribution	NUMBER;
			l_fe_spr_rate				NUMBER;
			l_fe_fm_amount				NUMBER;
			l_fe_fma_calc_contribution	NUMBER;
			l_tfe_fma_calc_contribution	NUMBER;
			l_to_calc_contribution		NUMBER;
			l_tu_calc_contribution		NUMBER;
			l_emp_contri_el				NUMBER;
			l_t_emp_contri_el			NUMBER;
			l_el						NUMBER;
			l_t_emp_contri_el_bimonth NUMBER;
			l_emp_contri_el_bimonth NUMBER;


			TYPE municipaldata IS RECORD
		        (
				municipalcode VARCHAR2(10)
		        );

		        TYPE tmunicipaldata  IS TABLE OF municipaldata
			INDEX BY BINARY_INTEGER;

			gmunicipaldata tmunicipaldata ;


			l_counter NUMBER;
			l_status NUMBER;


       	     		/* Cursors */

			Cursor csr_Local_Unit_Details ( csr_v_local_unit_id  hr_organization_information.ORGANIZATION_ID%TYPE)
				IS
					SELECT o1.name , hoi2.ORG_INFORMATION4
					FROM hr_organization_units o1
					, hr_organization_information hoi1
					, hr_organization_information hoi2
					WHERE  o1.business_group_id =l_business_group_id
					AND hoi1.organization_id = o1.organization_id
					AND hoi1.organization_id =  csr_v_local_unit_id
					AND hoi1.org_information1 = 'NO_LOCAL_UNIT'
					AND hoi1.org_information_context = 'CLASS'
					AND o1.organization_id =hoi2.organization_id
					AND hoi2.ORG_INFORMATION_CONTEXT='NO_LOCAL_UNIT_DETAILS';

			rg_Local_Unit_Details  csr_Local_Unit_Details%rowtype;

			Cursor csr_Legal_Emp_Details ( csr_v_legal_emp_id  hr_organization_information.ORGANIZATION_ID%TYPE)
				IS
					SELECT o1.name ,hoi2.ORG_INFORMATION1 , hoi2.ORG_INFORMATION2 ,  hoi2.ORG_INFORMATION3 ,  hoi2.ORG_INFORMATION5
					FROM hr_organization_units o1
					, hr_organization_information hoi1
					, hr_organization_information hoi2
					WHERE  o1.business_group_id =l_business_group_id
					AND hoi1.organization_id = o1.organization_id
					AND hoi1.organization_id =   csr_v_legal_emp_id
					AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
					AND hoi1.org_information_context = 'CLASS'
					AND o1.organization_id =hoi2.organization_id
					AND hoi2.ORG_INFORMATION_CONTEXT='NO_LEGAL_EMPLOYER_DETAILS' ;


			rg_Legal_Emp_Details  csr_Legal_Emp_Details%rowtype;

			Cursor csr_Legal_Emp_Contact ( csr_v_legal_emp_id  hr_organization_information.ORGANIZATION_ID%TYPE)
				IS
					SELECT hoi2.ORG_INFORMATION2 email , hoi3.ORG_INFORMATION2 phone
					FROM hr_organization_units o1
					, hr_organization_information hoi1
					, hr_organization_information hoi2
					, hr_organization_information hoi3
					WHERE  o1.business_group_id =l_business_group_id
					AND hoi1.organization_id = o1.organization_id
					AND hoi1.organization_id =  csr_v_legal_emp_id
					AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
					AND hoi1.org_information_context = 'CLASS'
					AND hoi2.organization_id (+)= o1.organization_id
					AND hoi2.ORG_INFORMATION_CONTEXT (+)='ORG_CONTACT_DETAILS'
					AND hoi2.org_information1(+)= 'EMAIL'
					AND hoi3.organization_id (+)= o1.organization_id
					AND hoi3.ORG_INFORMATION_CONTEXT (+)='ORG_CONTACT_DETAILS'
					AND hoi3.org_information1 (+) = 'PHONE' ;

			rg_Legal_Emp_Contact  csr_Legal_Emp_Contact%rowtype;

			Cursor csr_Legal_Emp_addr ( csr_v_legal_emp_id  hr_organization_information.ORGANIZATION_ID%TYPE)
				IS
					SELECT hoi1.ADDRESS_LINE_1 , hoi1.ADDRESS_LINE_2 , hoi1.ADDRESS_LINE_3 ,
					hoi1.POSTAL_CODE , SUBSTR(hlu.MEANING , INSTR(hlu.MEANING,' ', 1,1) , LENGTH(hlu.MEANING) -(INSTR(hlu.MEANING,' ', 1,1) -1) ) POSTAL_OFFICE
					FROM hr_organization_units o1
					, hr_locations hoi1
					,hr_organization_information hoi2
					,hr_lookups hlu
					WHERE  o1.business_group_id = l_business_group_id
					AND hoi1.location_id = o1.location_id
					AND hoi2.organization_id =  o1.organization_id
					AND hoi2.organization_id = csr_v_legal_emp_id
					AND hoi2.org_information1 = 'HR_LEGAL_EMPLOYER'
					AND hoi2.org_information_context = 'CLASS'
					AND hlu.lookup_type='NO_POSTAL_CODE'
					AND hlu.enabled_flag='Y'
					AND hlu.lookup_code = hoi1.POSTAL_CODE;



			rg_Legal_Emp_addr  csr_Legal_Emp_addr%rowtype;


			Cursor csr_Tax_Office_Details ( csr_v_tax_office_id  hr_organization_information.ORGANIZATION_ID%TYPE)
				IS
					SELECT o1.name , hoi1.ADDRESS_LINE_1 , hoi1.ADDRESS_LINE_2 , hoi1.ADDRESS_LINE_3 ,
					hoi1.POSTAL_CODE , SUBSTR(hlu.MEANING , INSTR(hlu.MEANING,' ', 1,1)  ) POSTAL_OFFICE
					FROM hr_organization_units o1
					, hr_locations hoi1
					,hr_organization_information hoi2
					,hr_lookups hlu
					WHERE  o1.business_group_id = l_business_group_id
					AND hoi1.location_id = o1.location_id
					AND hoi2.organization_id =  o1.organization_id
					AND hoi2.organization_id = csr_v_tax_office_id
					AND hoi2.org_information1 = 'NO_TAX_OFFICE'
					AND hoi2.org_information_context = 'CLASS'
					AND hlu.lookup_type='NO_POSTAL_CODE'
					AND hlu.enabled_flag='Y'
					AND hlu.lookup_code = hoi1.POSTAL_CODE;


			rg_Tax_Office_Details  csr_Tax_Office_Details%rowtype;

			CURSOR csr_prepaid_assignments_le
			(p_payroll_action_id          	NUMBER,
			p_legal_employer_id		NUMBER,
			l_canonical_start_date	DATE,
			l_canonical_end_date	DATE)
				IS
				SELECT
				DISTINCT act.assignment_id            assignment_id
				FROM   pay_payroll_actions          ppa
				,pay_payroll_actions          appa
				,pay_payroll_actions          appa2
				,pay_assignment_actions       act
				,pay_assignment_actions       act1
				,pay_action_interlocks        pai
				,per_all_assignments_f        as1
				,hr_soft_coding_keyflex         hsck
				 WHERE  ppa.payroll_action_id        = p_payroll_action_id
				 AND    appa.effective_date          BETWEEN l_canonical_start_date
				 AND     l_canonical_end_date
				 AND    appa.action_type             IN ('R','Q')
				-- Payroll Run or Quickpay Run
				 AND    act.payroll_action_id        = appa.payroll_action_id
				 AND    act.source_action_id         IS NULL -- Master Action
				 AND    as1.assignment_id            = act.assignment_id
				 AND    ppa.effective_date           BETWEEN as1.effective_start_date
				AND     as1.effective_end_date
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
				AND  hsck.SOFT_CODING_KEYFLEX_ID=as1.SOFT_CODING_KEYFLEX_ID
				AND EXISTS
				(	SELECT hoi1.organization_id
					FROM hr_organization_units o1
					, hr_organization_information hoi1
					, hr_organization_information hoi2
					, hr_organization_information hoi3
					, hr_organization_information hoi4
					WHERE  hoi1.organization_id = o1.organization_id
					AND hoi1.org_information1 = 'NO_LOCAL_UNIT'
					AND hoi1.org_information_context = 'CLASS'
					AND o1.organization_id = hoi2.org_information1
					AND hoi2.ORG_INFORMATION_CONTEXT='NO_LOCAL_UNITS'
					AND hoi2.organization_id =  hoi3.organization_id
					AND hoi3.ORG_INFORMATION_CONTEXT='CLASS'
					AND hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
					aND hoi3.organization_id = p_legal_employer_id
					AND hoi1.organization_id =  hoi4.organization_id
					AND hoi4.ORG_INFORMATION_CONTEXT='NO_LOCAL_UNIT_DETAILS'
					AND hoi4.ORG_INFORMATION5= 'N'
					AND to_char(hoi1.organization_id) = hsck.segment2 	);



		CURSOR csr_prepaid_assignments_lu(p_payroll_action_id          	NUMBER,
			 p_legal_employer_id			NUMBER,
			 p_local_unit_id				NUMBER,
			 l_canonical_start_date	DATE,
			 l_canonical_end_date	DATE)
			IS
				SELECT  DISTINCT act.assignment_id            assignment_id
				 FROM   pay_payroll_actions          ppa
				,pay_payroll_actions          appa
				,pay_payroll_actions          appa2
				,pay_assignment_actions       act
				,pay_assignment_actions       act1
				,pay_action_interlocks        pai
				,per_all_assignments_f        as1
				,hr_soft_coding_keyflex         hsck
				WHERE  ppa.payroll_action_id        = p_payroll_action_id
				 AND    appa.effective_date          BETWEEN l_canonical_start_date
				 AND     l_canonical_end_date
				 AND    appa.action_type             IN ('R','Q')
				-- Payroll Run or Quickpay Run
				 AND    act.payroll_action_id        = appa.payroll_action_id
				 AND    act.source_action_id         IS NULL -- Master Action
				 AND    as1.assignment_id            = act.assignment_id
				 AND    ppa.effective_date           BETWEEN as1.effective_start_date
				 AND     as1.effective_end_date
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
				  AND   hsck.segment2 = TO_CHAR(p_local_unit_id)
				  AND   act.TAX_UNIT_ID    =  act1.TAX_UNIT_ID
				  AND   act.TAX_UNIT_ID    =  p_legal_employer_id ;


		CURSOR csr_get_mun_num(p_assignment_id NUMBER,p_effective_date  DATE  )
			IS
				SELECT eev1.screen_entry_value  screen_entry_value
				 FROM   per_all_assignments_f      asg1
					 ,per_all_assignments_f      asg2
					 ,per_all_people_f           per
					 ,pay_element_links_f        el
					 ,pay_element_types_f        et
					 ,pay_input_values_f         iv1
					 ,pay_element_entries_f      ee
					 ,pay_element_entry_values_f eev1
				   WHERE  asg1.assignment_id    = p_assignment_id
				     AND p_effective_date BETWEEN asg1.effective_start_date AND asg1.effective_end_date
				     AND p_effective_date BETWEEN per.effective_start_date AND per.effective_end_date
				     AND p_effective_date BETWEEN asg2.effective_start_date AND asg2.effective_end_date
				     AND  per.person_id         = asg1.person_id
				     AND  asg2.person_id        = per.person_id
				     AND  asg2.primary_flag     = 'Y'
				     AND  et.element_name       = 'Tax Card'
				     AND  et.legislation_code   = 'NO'
				     AND  iv1.element_type_id   = et.element_type_id
				     AND  iv1.name              =          'Tax Municipality'
				     AND  el.business_group_id  = per.business_group_id
				     AND  el.element_type_id    = et.element_type_id
				     AND  ee.assignment_id      = asg2.assignment_id
				     AND  ee.element_link_id    = el.element_link_id
				     AND  eev1.element_entry_id = ee.element_entry_id
				     AND  eev1.input_value_id   = iv1.input_value_id
				     AND  p_effective_date BETWEEN ee.effective_start_date AND ee.effective_end_date
				     AND  p_effective_date BETWEEN eev1.effective_start_date AND eev1.effective_end_date;


	     		CURSOR csr_get_mun_dtls(p_municipal_no VARCHAR2, l_effective_date  DATE )
			IS
                SELECT hr_de_general.get_uci(l_effective_date,t.user_table_id,r.user_row_id,'ZONE') zone
                      ,hr_general.decode_lookup('NO_TAX_MUNICIPALITY',
                       hr_de_general.get_uci(l_effective_date,t.user_table_id,r.user_row_id,'MAPPING_ID')) municipal_name
                FROM   pay_user_tables t
                      ,pay_user_rows_f r
                WHERE  t.user_table_name        = 'NO_TAX_MUNICIPALITY'
                  AND  t.legislation_code       = 'NO'
                  AND  r.user_table_id          = t.user_table_id
                  AND  r.row_low_range_or_name  = p_municipal_no
                  AND  l_effective_date BETWEEN r.effective_start_date AND r.effective_end_date;

/*				SELECT  SUBSTR( meaning ,1,1)  zone ,   TRIM(SUBSTR(  meaning ,2)) municipal_name
				FROM   hr_lookups
				WHERE lookup_type='NO_TAX_MUNICIPALITY'
				AND enabled_flag='Y'
				AND lookup_code = p_municipal_no;
*/
				rg_get_mun_dtls  csr_get_mun_dtls%rowtype;


	     		CURSOR csr_lu_dtls(p_legal_employer_id  NUMBER )
			IS
					SELECT hoi1.organization_id
					FROM hr_organization_units o1
					, hr_organization_information hoi1
					, hr_organization_information hoi2
					, hr_organization_information hoi3
					, hr_organization_information hoi4
					WHERE  hoi1.organization_id = o1.organization_id
					AND hoi1.org_information1 = 'NO_LOCAL_UNIT'
					AND hoi1.org_information_context = 'CLASS'
					AND o1.organization_id = hoi2.org_information1
					AND hoi2.ORG_INFORMATION_CONTEXT='NO_LOCAL_UNITS'
					AND hoi2.organization_id =  hoi3.organization_id
					AND hoi3.ORG_INFORMATION_CONTEXT='CLASS'
					AND hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
					aND hoi3.organization_id = p_legal_employer_id
					AND hoi1.organization_id =  hoi4.organization_id
					AND hoi4.ORG_INFORMATION_CONTEXT='NO_LOCAL_UNIT_DETAILS'
					AND hoi4.ORG_INFORMATION5= 'N';

			CURSOR csr_global_value (p_global_name VARCHAR2 , p_date_earned DATE)
			IS
				SELECT global_value
				FROM ff_globals_f
				WHERE global_name = p_global_name
				AND p_date_earned BETWEEN effective_start_date AND effective_end_date;

			Cursor csr_Local_Unit_EL ( csr_v_local_unit_id  hr_organization_information.ORGANIZATION_ID%TYPE, p_date_earned DATE)
				IS
					SELECT hoi2.org_information1
					FROM hr_organization_units o1
					, hr_organization_information hoi1
					, hr_organization_information hoi2
					WHERE  o1.business_group_id =l_business_group_id
					AND hoi1.organization_id = o1.organization_id
					AND hoi1.organization_id =  csr_v_local_unit_id
					AND hoi1.org_information1 = 'NO_LOCAL_UNIT'
					AND hoi1.org_information_context = 'CLASS'
					AND o1.organization_id =hoi2.organization_id
					AND hoi2.ORG_INFORMATION_CONTEXT='NO_NI_EXEMPTION_LIMIT'
					AND p_date_earned between  fnd_date.canonical_to_date(hoi2.org_information2)
					AND  fnd_date.canonical_to_date(hoi2.org_information3);

			rg_Local_Unit_EL  csr_Local_Unit_EL%rowtype;

			Cursor csr_Legal_Emp_EL( csr_v_legal_emp_id  hr_organization_information.ORGANIZATION_ID%TYPE, p_date_earned DATE)
				IS
					SELECT  hoi2.org_information1
					FROM hr_organization_units o1
					, hr_organization_information hoi1
					, hr_organization_information hoi2
					WHERE  o1.business_group_id =l_business_group_id
					AND hoi1.organization_id = o1.organization_id
					AND hoi1.organization_id =   csr_v_legal_emp_id
					AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
					AND hoi1.org_information_context = 'CLASS'
					AND o1.organization_id =hoi2.organization_id
					AND hoi2.ORG_INFORMATION_CONTEXT='NO_NI_EXEMPTION_LIMIT'
					AND p_date_earned between  fnd_date.canonical_to_date(hoi2.org_information2)
					AND  fnd_date.canonical_to_date(hoi2.org_information3);

			rg_Legal_Emp_EL  csr_Legal_Emp_EL%rowtype;

							     /* End of Cursors */

				BEGIN

					g_debug:=true;

					 IF g_debug THEN
						hr_utility.set_location(' Entering Procedure RANGE_CODE',10);
					 END IF;

					 p_sql := 'SELECT DISTINCT person_id
					FROM  per_people_f ppf
					,pay_payroll_actions ppa
					WHERE ppa.payroll_action_id = :payroll_action_id
					AND   ppa.business_group_id = ppf.business_group_id
					ORDER BY ppf.person_id';


					PAY_NO_ARCHIVE_RSEA.GET_ALL_PARAMETERS(
					p_payroll_action_id
					,l_business_group_id
					,l_legal_employer_id
					,l_local_unit_id
--					,l_period
--					,l_year
					,l_effective_date
					,l_archive ) ;

					l_period := to_char(ceil(to_number(to_char(l_effective_date,'MM'))/ 2));
					l_year   := to_char(l_effective_date,'YYYY');

					l_reporting_end_date := LAST_DAY(TO_DATE(LPAD(l_period*2,2,'0')||l_year,'MMYYYY'));


					l_reporting_start_date :=ADD_MONTHS( l_reporting_end_date , -2 ) + 1;

					IF  l_archive = 'Y' THEN

						SELECT count(*)  INTO l_count
						FROM   pay_action_information
						WHERE  action_context_id           = p_payroll_action_id
						AND         action_context_type          = 'PA'
						AND         action_information_category = 'EMEA REPORT DETAILS'
						AND         action_information1             = 'PYNORSEA';

						IF l_count < 1  then

							/* Pick up the details belonging to Legal Employer */

							OPEN  csr_Legal_Emp_Details(l_legal_employer_id);
								FETCH csr_Legal_Emp_Details INTO rg_Legal_Emp_Details;
							CLOSE csr_Legal_Emp_Details;

							l_le_name			:= rg_Legal_Emp_Details.name ;
							l_org_number		:= rg_Legal_Emp_Details.ORG_INFORMATION1 ;
							l_municipal_no		:= rg_Legal_Emp_Details.ORG_INFORMATION2 ;
							l_industry_status		:= rg_Legal_Emp_Details.ORG_INFORMATION3 ;
							l_tax_office_id		:= rg_Legal_Emp_Details.ORG_INFORMATION5 ;

							l_emp_id:=l_legal_employer_id;


							IF l_local_unit_id IS NOT NULL THEN

								/* Pick up the details belonging to Local Unit */

								OPEN  csr_Local_Unit_Details( l_local_unit_id);
									FETCH csr_Local_Unit_Details INTO rg_Local_Unit_Details;
								CLOSE csr_Local_Unit_Details;

								l_lu_name			:=rg_Local_Unit_Details.name;
								l_industry_status		:= rg_Local_Unit_Details.ORG_INFORMATION4 ;

							END IF ;


							/* Pick up the contact details belonging to Legal Employer */

							OPEN  csr_Legal_Emp_contact( l_legal_employer_id);
								FETCH csr_Legal_Emp_contact INTO rg_Legal_Emp_contact;
							CLOSE csr_Legal_Emp_contact;

							l_email			:= rg_Legal_Emp_Contact .email;
							l_phone			:= rg_Legal_Emp_Contact .phone ;


							/* Pick up the Address details belonging to  Legal Employer */

							OPEN  csr_Legal_Emp_addr(l_legal_employer_id);
								FETCH csr_Legal_Emp_addr INTO rg_Legal_Emp_addr;
							CLOSE csr_Legal_Emp_addr;

							l_address_line_1	:= rg_Legal_Emp_addr.address_line_1 ;
							l_address_line_2	:= rg_Legal_Emp_addr.address_line_2 ;
							l_address_line_3	:= rg_Legal_Emp_addr.address_line_3 ;
							l_postal_code		:= rg_Legal_Emp_addr.postal_code ;
							l_postal_office		:= rg_Legal_Emp_addr.postal_office ;

							/* Pick up the tax office details belonging to  Employer*/

							OPEN  csr_Tax_Office_Details( l_tax_office_id );
								FETCH csr_Tax_Office_Details INTO rg_Tax_Office_Details;
							CLOSE csr_Tax_Office_Details;

							l_tax_office_name	:= rg_Tax_Office_Details.name ;
							l_taddress_line_1	:= rg_Tax_Office_Details.ADDRESS_LINE_1 ;
							l_taddress_line_2	:= rg_Tax_Office_Details.ADDRESS_LINE_2;
							l_taddress_line_3	:= rg_Tax_Office_Details.ADDRESS_LINE_3 ;
							l_tpostal_code		:= rg_Tax_Office_Details.POSTAL_CODE ;
							l_tpostal_office		:= rg_Tax_Office_Details.POSTAL_OFFICE;

							IF l_local_unit_id IS NOT NULL THEN

							/* Pick up the Exemption Limit details belonging to  Local Unit*/
								OPEN  csr_Local_Unit_EL( l_local_unit_id , l_reporting_end_date);
								FETCH csr_Local_Unit_EL INTO rg_Local_Unit_EL;
								CLOSE csr_Local_Unit_EL;
								l_el	:= rg_Local_Unit_EL.ORG_INFORMATION1;

							ELSE
							/* Pick up the Exemption Limit details belonging to  Employer*/

								OPEN  csr_Legal_Emp_EL( l_legal_employer_id , l_reporting_end_date);
								FETCH csr_Legal_Emp_EL INTO rg_Legal_Emp_EL;
								CLOSE csr_Legal_Emp_EL;
								l_el	:= rg_Legal_Emp_EL.ORG_INFORMATION1;

							END IF;

							/* Inserting header details belonging to  Employer*/

							pay_action_information_api.create_action_information (
							p_action_information_id        => l_action_info_id
							,p_action_context_id            => p_payroll_action_id
							,p_action_context_type          => 'PA'
							,p_object_version_number        => l_ovn
							,p_effective_date               => l_effective_date
							,p_source_id                    => NULL
							,p_source_text                  => NULL
							,p_action_information_category  => 'EMEA REPORT INFORMATION'
							,p_action_information1          => 'PYNORSEA'
							,p_action_information2          => l_emp_id
							,p_action_information3          => l_period||l_year
							,p_action_information4          => l_org_number
							,p_action_information5          => l_municipal_no
							,p_action_information6          => l_le_name
							,p_action_information7          => l_address_line_1
							,p_action_information8          => l_address_line_2||' '||l_address_line_3
							,p_action_information9          => l_postal_code
							,p_action_information10        => l_postal_office
							,p_action_information11        =>  l_email
							,p_action_information12        => l_phone
							,p_action_information13        => l_tax_office_name
							,p_action_information14        => l_taddress_line_1
							,p_action_information15        => l_taddress_line_2||' '||l_taddress_line_3
							,p_action_information16        => l_tpostal_code||' '||l_tpostal_office
							,p_action_information17        => l_industry_status
							,p_action_information18        => FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_el,0))
							,p_action_information19        => null
							,p_action_information20        => null
							,p_action_information21        => null
							,p_action_information22        =>  null
							,p_action_information23        => null
							,p_action_information24        => null
							,p_action_information25        => null
							,p_action_information26        => null
							,p_action_information27        => null
							,p_action_information28        => null
							,p_action_information29        => null
							,p_action_information30        => null );

							 IF g_debug THEN
								hr_utility.set_location(' Inside Procedure RANGE_CODE',20);
							END IF;



							/* Inserting the selection criteria for generating the report*/

							pay_action_information_api.create_action_information (
							p_action_information_id        => l_action_info_id
							,p_action_context_id            => p_payroll_action_id
							,p_action_context_type          => 'PA'
							,p_object_version_number        => l_ovn
							,p_effective_date               => l_effective_date
							,p_source_id                    => NULL
							,p_source_text                  => NULL
							,p_action_information_category  => 'EMEA REPORT DETAILS'
							,p_action_information1          => 'PYNORSEA'
							,p_action_information2          => l_le_name
							,p_action_information3          => l_lu_name
							,p_action_information4          => l_period
							,p_action_information5          => l_year
							,p_action_information6          =>  null
							,p_action_information7          =>  null
							,p_action_information8          =>  null
							,p_action_information9          =>  null
							,p_action_information10         =>   null
							,p_action_information11         =>   null
							,p_action_information12         =>  null
							,p_action_information13         =>  null
							,p_action_information14         =>  null
							,p_action_information15         =>  null
							,p_action_information16         =>  null
							,p_action_information17         =>   null
							,p_action_information18         =>  null
							,p_action_information19         =>   null
							,p_action_information20         =>  null
							,p_action_information21         =>  null
							,p_action_information22         =>   null
							,p_action_information23         =>  null
							,p_action_information24         =>  null
							,p_action_information25         =>  null
							,p_action_information26         =>  null
							,p_action_information27         =>  null
							,p_action_information28         => null
							,p_action_information29         =>  null
							,p_action_information30         =>  null );

							 IF g_debug THEN
								hr_utility.set_location(' Inside Procedure RANGE_CODE',30);
							END IF;


							/* Inserting municipal codes for the Legal Employer in a PL/SQL table */

							IF l_local_unit_id IS NULL THEN

								l_counter := 0;
								l_status :=  0;
								FOR  prepaid_assignments_le_rec IN  csr_prepaid_assignments_le(p_payroll_action_id ,l_legal_employer_id,l_reporting_start_date,l_reporting_END_date)
								LOOP

									FOR  get_mun_num_rec IN  csr_get_mun_num(prepaid_assignments_le_rec.assignment_id ,l_reporting_start_date  )
									LOOP

										IF l_counter > 0 THEN
											FOR i IN 1 .. l_counter LOOP

												IF gmunicipaldata(i).municipalcode  = get_mun_num_rec.screen_entry_value THEN

													l_status:= 1;
													EXIT ;
												END IF;

											 END LOOP;
										END IF;


										IF l_status= 0 THEN
											l_counter := l_counter + 1;
											gmunicipaldata(l_counter).municipalcode:=get_mun_num_rec.screen_entry_value;

										END IF;

										l_status :=  0;

									END LOOP;

									l_status :=  0;

									FOR  get_mun_num_rec IN  csr_get_mun_num(prepaid_assignments_le_rec.assignment_id ,l_reporting_end_date  )
									LOOP

										IF l_counter > 0 THEN
											FOR i IN 1 .. l_counter LOOP
												IF gmunicipaldata(i).municipalcode  = get_mun_num_rec.screen_entry_value THEN
													l_status:= 1;
													EXIT ;
												END IF;
											 END LOOP;
										END IF;

										IF l_status= 0 THEN
											l_counter := l_counter + 1;
											gmunicipaldata(l_counter).municipalcode:=get_mun_num_rec.screen_entry_value;
										END IF;


										l_status :=  0;

									END LOOP;


								END LOOP;

							ELSE

								/* Inserting municipal codes for the Local Unit in a PL/SQL table */

								l_counter := 0;
								l_status :=  0;

								FOR  prepaid_assignments_lu_rec IN  csr_prepaid_assignments_lu(p_payroll_action_id ,l_legal_employer_id, l_local_unit_id,l_reporting_start_date,l_reporting_END_date)
								LOOP

									FOR  get_mun_num_rec IN  csr_get_mun_num(prepaid_assignments_lu_rec.assignment_id ,l_reporting_start_date  )
									LOOP

										IF l_counter > 0 THEN
											FOR i IN 1 .. l_counter LOOP
												IF gmunicipaldata(i).municipalcode  = get_mun_num_rec.screen_entry_value THEN
													l_status:= 1;
													EXIT ;
												END IF;
											 END LOOP;
										END IF;

											IF l_status= 0 THEN
												l_counter := l_counter + 1;
												gmunicipaldata(l_counter).municipalcode:=get_mun_num_rec.screen_entry_value;
											END IF;


										l_status :=  0;

								END LOOP;

								l_status :=  0;

								FOR  get_mun_num_rec IN  csr_get_mun_num(prepaid_assignments_lu_rec.assignment_id ,l_reporting_end_date  )
								LOOP
									IF l_counter > 0 THEN
										FOR i IN 1 .. l_counter LOOP
											IF gmunicipaldata(i).municipalcode  = get_mun_num_rec.screen_entry_value THEN
												l_status:= 1;
												EXIT ;
											END IF;
										 END LOOP;
									END IF;

									IF l_status= 0 THEN
										l_counter := l_counter + 1;
										gmunicipaldata(l_counter).municipalcode:=get_mun_num_rec.screen_entry_value;
									END IF;

									l_status :=  0;

								END LOOP;

							END LOOP;

						END IF ;

							 IF g_debug THEN
								hr_utility.set_location(' Inside Procedure RANGE_CODE',40);
							END IF;



						/* Setting contexts for balances*/
						pay_balance_pkg.set_context('TAX_UNIT_ID',l_legal_employer_id);
						pay_balance_pkg.set_context('JURISDICTION_CODE',l_municipal_no);
						pay_balance_pkg.set_context('DATE_EARNED',fnd_date.date_to_canonical(l_reporting_end_date));

							 IF g_debug THEN
								hr_utility.set_location(' Inside Procedure RANGE_CODE',50);
							END IF;


							FOR i IN 1 .. l_counter LOOP

								l_municipal_no:=gmunicipaldata(i).municipalcode;
								IF  l_municipal_no IS NOT NULL THEN

									/* Setting municipality details for balances*/
									OPEN  csr_get_mun_dtls(l_municipal_no, l_reporting_end_date);
									FETCH csr_get_mun_dtls INTO rg_get_mun_dtls;
									CLOSE csr_get_mun_dtls;

									l_zone	:= rg_get_mun_dtls.zone ;
									l_municipal_name	:= rg_get_mun_dtls.municipal_name;

									/* Initialising values*/
									l_o_contribution_basis:=0;
									l_u_contribution_basis:=0;
									l_u_calc_contribution :=0;
									l_o_calc_contribution :=0;
									l_Witholding_Tax:=0;
									l_fe_spr_contribution_basis:=0;
									l_fe_spr_calc_contribution:=0;
									l_fe_fma_calc_contribution :=0;
									l_emp_contri_el :=0;
									l_emp_contri_el_bimonth:=0;

									/* Fetching balance values related to employer contributions report*/
									IF  l_local_unit_id  IS  NULL THEN

										FOR lu_dtls_rec IN csr_lu_dtls(l_legal_employer_id )
										LOOP

											pay_balance_pkg.set_context('LOCAL_UNIT_ID',lu_dtls_rec.organization_id);

											-- get defined balance ids
											l_def_bal_id := get_defined_balance_id('Employer Contribution Over 62 Base','_TU_MU_LU_BIMONTH') ;
											l_to_contribution_basis :=  pay_balance_pkg.get_value(l_def_bal_id,NULL,l_legal_employer_id,l_municipal_no,NULL,NULL,NULL,l_reporting_end_date);
											l_o_contribution_basis :=  l_to_contribution_basis + l_o_contribution_basis;

											l_def_bal_id := get_defined_balance_id('Employer Contribution Base','_TU_MU_LU_BIMONTH') ;
											l_tu_contribution_basis := pay_balance_pkg.get_value(l_def_bal_id,NULL,l_legal_employer_id,l_municipal_no,NULL,NULL,NULL,l_reporting_end_date);
											l_u_contribution_basis := l_tu_contribution_basis + l_u_contribution_basis;

											l_def_bal_id := get_defined_balance_id('Employer Contribution Over 62','_TU_MU_LU_BIMONTH') ;
											l_to_calc_contribution :=  pay_balance_pkg.get_value(l_def_bal_id,NULL,l_legal_employer_id,l_municipal_no,NULL,NULL,NULL,l_reporting_end_date);
											l_o_calc_contribution :=  l_to_calc_contribution + l_o_calc_contribution;

											l_def_bal_id := get_defined_balance_id('Employer Contribution','_TU_MU_LU_BIMONTH') ;
											l_tu_calc_contribution := pay_balance_pkg.get_value(l_def_bal_id,NULL,l_legal_employer_id,l_municipal_no,NULL,NULL,NULL,l_reporting_end_date);
											l_u_calc_contribution := l_tu_calc_contribution + l_u_calc_contribution;

											l_def_bal_id := get_defined_balance_id('Tax','_TU_MU_LU_BIMONTH') ;
											l_tWitholding_Tax := pay_balance_pkg.get_value(l_def_bal_id,NULL,l_legal_employer_id,l_municipal_no,NULL,NULL,NULL,l_reporting_end_date);
											l_Witholding_Tax := l_Witholding_Tax + l_tWitholding_Tax;

											l_def_bal_id := get_defined_balance_id('Employer Contribution Special Percentage Base','_TU_MU_LU_BIMONTH') ;
											l_tfe_spr_contribution_basis := pay_balance_pkg.get_value(l_def_bal_id,NULL,l_legal_employer_id,l_municipal_no,NULL,NULL,NULL,l_reporting_end_date);
											l_fe_spr_contribution_basis := l_fe_spr_contribution_basis + l_tfe_spr_contribution_basis;

											l_def_bal_id := get_defined_balance_id('Employer Contribution Special Percentage','_TU_MU_LU_BIMONTH') ;
											l_tfe_spr_calc_contribution := pay_balance_pkg.get_value(l_def_bal_id,NULL,l_legal_employer_id,l_municipal_no,NULL,NULL,NULL,l_reporting_end_date);
											l_fe_spr_calc_contribution := l_fe_spr_calc_contribution + l_tfe_spr_calc_contribution;

											l_def_bal_id := get_defined_balance_id('Employer Contribution Special','_TU_MU_LU_BIMONTH') ;
											l_tfe_fma_calc_contribution := pay_balance_pkg.get_value(l_def_bal_id,NULL,l_legal_employer_id,l_municipal_no,NULL,NULL,NULL,l_reporting_end_date);
											l_fe_fma_calc_contribution := l_fe_fma_calc_contribution + l_tfe_fma_calc_contribution;

											l_def_bal_id := get_defined_balance_id('Employer Contribution Exemption Limit Used','_TU_MU_LU_YTD') ;
											l_t_emp_contri_el := pay_balance_pkg.get_value(l_def_bal_id,NULL,l_legal_employer_id,l_municipal_no,NULL,NULL,NULL,l_reporting_end_date);
											l_emp_contri_el := l_t_emp_contri_el +  l_emp_contri_el;

											l_def_bal_id := get_defined_balance_id('Employer Contribution Exemption Limit Used','_TU_MU_LU_BIMONTH') ;
											l_t_emp_contri_el_bimonth := pay_balance_pkg.get_value(l_def_bal_id,NULL,l_legal_employer_id,l_municipal_no,NULL,NULL,NULL,l_reporting_end_date);
											l_emp_contri_el_bimonth := l_t_emp_contri_el_bimonth +  l_emp_contri_el_bimonth;

											/* Resetting the values*/
											l_to_contribution_basis:=0;
											l_tu_contribution_basis:=0;
											l_to_calc_contribution:=0;
											l_tu_calc_contribution:=0;
											l_tWitholding_Tax:=0;
											l_tfe_spr_contribution_basis:=0;
											l_tfe_spr_calc_contribution:=0;
											l_tfe_fma_calc_contribution :=0;
											l_t_emp_contri_el :=0;
											 l_t_emp_contri_el_bimonth:=0;

										END LOOP;



									ELSE

										pay_balance_pkg.set_context('LOCAL_UNIT_ID',l_local_unit_id);

										-- get defined balance ids
										l_def_bal_id := get_defined_balance_id('Employer Contribution Over 62 Base','_TU_MU_LU_BIMONTH') ;
										l_o_contribution_basis :=  pay_balance_pkg.get_value(l_def_bal_id,NULL,l_legal_employer_id,l_municipal_no,NULL,NULL,NULL,l_reporting_end_date);

										l_def_bal_id := get_defined_balance_id('Employer Contribution Base','_TU_MU_LU_BIMONTH') ;
										l_u_contribution_basis := pay_balance_pkg.get_value(l_def_bal_id,NULL,l_legal_employer_id,l_municipal_no,NULL,NULL,NULL,l_reporting_end_date);

										l_def_bal_id := get_defined_balance_id('Employer Contribution Over 62','_TU_MU_LU_BIMONTH') ;
										l_to_calc_contribution :=  pay_balance_pkg.get_value(l_def_bal_id,NULL,l_legal_employer_id,l_municipal_no,NULL,NULL,NULL,l_reporting_end_date);
										l_o_calc_contribution :=  l_to_calc_contribution + l_o_calc_contribution;

										l_def_bal_id := get_defined_balance_id('Employer Contribution','_TU_MU_LU_BIMONTH') ;
										l_tu_calc_contribution := pay_balance_pkg.get_value(l_def_bal_id,NULL,l_legal_employer_id,l_municipal_no,NULL,NULL,NULL,l_reporting_end_date);
										l_u_calc_contribution := l_tu_calc_contribution + l_u_calc_contribution;

										l_def_bal_id := get_defined_balance_id('Tax','_TU_MU_LU_BIMONTH') ;
										l_Witholding_Tax := pay_balance_pkg.get_value(l_def_bal_id,NULL,l_legal_employer_id,l_municipal_no,NULL,NULL,NULL,l_reporting_end_date);

										l_def_bal_id := get_defined_balance_id('Employer Contribution Special Percentage Base','_TU_MU_LU_BIMONTH') ;
										l_tfe_spr_contribution_basis := pay_balance_pkg.get_value(l_def_bal_id,NULL,l_legal_employer_id,l_municipal_no,NULL,NULL,NULL,l_reporting_end_date);
										l_fe_spr_contribution_basis := l_fe_spr_contribution_basis + l_tfe_spr_contribution_basis;

										l_def_bal_id := get_defined_balance_id('Employer Contribution Special Percentage','_TU_MU_LU_BIMONTH') ;
										l_tfe_spr_calc_contribution := pay_balance_pkg.get_value(l_def_bal_id,NULL,l_legal_employer_id,l_municipal_no,NULL,NULL,NULL,l_reporting_end_date);
										l_fe_spr_calc_contribution := l_fe_spr_calc_contribution + l_tfe_spr_calc_contribution;

										l_def_bal_id := get_defined_balance_id('Employer Contribution Special','_TU_MU_LU_BIMONTH') ;
										l_tfe_fma_calc_contribution := pay_balance_pkg.get_value(l_def_bal_id,NULL,l_legal_employer_id,l_municipal_no,NULL,NULL,NULL,l_reporting_end_date);
										l_fe_fma_calc_contribution := l_fe_fma_calc_contribution + l_tfe_fma_calc_contribution;

										l_def_bal_id := get_defined_balance_id('Employer Contribution Exemption Limit Used','_TU_MU_LU_YTD') ;
										l_t_emp_contri_el := pay_balance_pkg.get_value(l_def_bal_id,NULL,l_legal_employer_id,l_municipal_no,NULL,NULL,NULL,l_reporting_end_date);
										l_emp_contri_el := l_t_emp_contri_el +  l_emp_contri_el;

										l_def_bal_id := get_defined_balance_id('Employer Contribution Exemption Limit Used','_TU_MU_LU_BIMONTH') ;
										l_t_emp_contri_el_bimonth := pay_balance_pkg.get_value(l_def_bal_id,NULL,l_legal_employer_id,l_municipal_no,NULL,NULL,NULL,l_reporting_end_date);
										l_emp_contri_el_bimonth := l_t_emp_contri_el_bimonth +  l_emp_contri_el_bimonth;

									END IF;


									/* Fetching the global value NO_NI_FOREIGN_SPECIAL_RATE*/
									OPEN csr_global_value('NO_NI_FOREIGN_SPECIAL_RATE' , l_reporting_end_date ) ;
									FETCH  csr_global_value INTO l_fe_spr_rate;
									CLOSE csr_global_value;


									/* Fetching the global value NO_NI_FOREIGN_MARINER_AMOUNT*/
									OPEN csr_global_value('NO_NI_FOREIGN_MARINER_AMOUNT' , l_reporting_end_date ) ;
									FETCH  csr_global_value INTO l_fe_fm_amount;
									CLOSE csr_global_value;

									l_u_rate :=0;
									l_o_rate :=0;
									l_eWitholding_Tax :=0;
									l_eu_contribution_basis :=0;
									l_eo_contribution_basis :=0;
									l_eu_rate :=0;
									l_eo_rate :=0;
									l_eu_calc_contribution :=0;
									l_eo_calc_contribution  :=0;


									/* Inserting Local unit level data related to employer contributions*/
								      	pay_action_information_api.create_action_information (
									p_action_information_id        => l_action_info_id
									,p_action_context_id            => p_payroll_action_id
									,p_action_context_type          => 'PA'
									,p_object_version_number        => l_ovn
									,p_effective_date               => l_effective_date
									,p_source_id                    => NULL
									,p_source_text                  => NULL
									,p_action_information_category  => 'EMEA REPORT INFORMATION'
									,p_action_information1          => 'PYNORSEA'
									,p_action_information2          => 'M'
									,p_action_information3          => l_municipal_no
									,p_action_information4          => l_municipal_name
									,p_action_information5          => l_zone
									,p_action_information6          => ROUND(FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_Witholding_Tax,0)))
									,p_action_information7          => ROUND(FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_u_contribution_basis,0)))
									,p_action_information8          => ROUND(FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_o_contribution_basis,0)))
									,p_action_information9          => FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_u_rate,0))
									,p_action_information10        => FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_o_rate,0))
									,p_action_information11        =>  ROUND(FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_u_calc_contribution,0)))
									,p_action_information12        => ROUND(FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_o_calc_contribution,0)))
									,p_action_information13        => ROUND(FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_eWitholding_Tax,0)))
									,p_action_information14        => ROUND(FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_eu_contribution_basis,0)))
									,p_action_information15        => ROUND(FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_eo_contribution_basis,0)))
									,p_action_information16        => FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_eu_rate,0))
									,p_action_information17        => FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_eo_rate,0))
									,p_action_information18        => ROUND(FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_eu_calc_contribution,0)))
									,p_action_information19        => ROUND(FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_eo_calc_contribution ,0)))
									,p_action_information20        =>  ROUND(FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_fe_spr_contribution_basis,0)))
									,p_action_information21        => ROUND(FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_fe_spr_calc_contribution,0)))
									,p_action_information22        =>  FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_fe_spr_rate,0))
									,p_action_information23        => nvl(l_fe_fma_calc_contribution ,0)/ nvl(l_fe_fm_amount,0)
									,p_action_information24        => ROUND(FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_fe_fm_amount,0)))
									,p_action_information25        => ROUND(FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_fe_fma_calc_contribution ,0)))
									,p_action_information26        => ROUND(FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_emp_contri_el,0)))
									,p_action_information27        => ROUND(FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_emp_contri_el_bimonth,0)))
									,p_action_information28        => null
									,p_action_information29        => null
									,p_action_information30        => null );

									 IF g_debug THEN
										hr_utility.set_location(' Inside Procedure RANGE_CODE',60);
									 END IF;


									 l_municipal_no:=NULL;


								END IF;

							 END LOOP;



			END IF;

			END IF;

			 IF g_debug THEN
			      hr_utility.set_location(' Leaving Procedure RANGE_CODE',70);
			 END IF;

		 EXCEPTION
		 WHEN OTHERS THEN
		 -- Return cursor that selects no rows
		 p_sql := 'select 1 from dual where to_char(:payroll_action_id) = dummy';
	 	fnd_file.put_line(fnd_file.log,'Error in EC 1'||substr(sqlerrm , 1, 30));

		 END RANGE_CODE;

	 /* ASSIGNMENT ACTION CODE */
	 PROCEDURE ASSIGNMENT_ACTION_CODE
	 (p_payroll_action_id     IN NUMBER
	 ,p_start_person          IN NUMBER
	 ,p_end_person            IN NUMBER
	 ,p_chunk                 IN NUMBER)
	 IS
	 BEGIN
		IF g_debug THEN
			hr_utility.set_location(' Entering Procedure ASSIGNMENT_ACTION_CODE',80);
		END IF;

		 IF g_debug THEN
		      hr_utility.set_location(' Leaving Procedure ASSIGNMENT_ACTION_CODE',90);
		 END IF;


	END ASSIGNMENT_ACTION_CODE;


	 /* INITIALIZATION CODE */
	 PROCEDURE INITIALIZATION_CODE(p_payroll_action_id IN NUMBER)
	 IS

	 BEGIN
		 IF g_debug THEN
		      hr_utility.set_location(' Entering Procedure INITIALIZATION_CODE',100);
		 END IF;


		 IF g_debug THEN
		      hr_utility.set_location(' Leaving Procedure INITIALIZATION_CODE',110);
		 END IF;

		 EXCEPTION WHEN OTHERS THEN
		 g_err_num := SQLCODE;
		 IF g_debug THEN
		      hr_utility.set_location('ORA_ERR: ' || g_err_num || 'In INITIALIZATION_CODE',120);
		 END IF;
	 END INITIALIZATION_CODE;

 	 /* ARCHIVE CODE */
	 PROCEDURE ARCHIVE_CODE(p_assignment_action_id IN NUMBER
			      ,p_effective_date    IN DATE)
	 IS

	BEGIN
		 IF g_debug THEN
				hr_utility.set_location(' Entering Procedure ARCHIVE_CODE',130);
		 END IF;

		 IF g_debug THEN
				hr_utility.set_location(' Leaving Procedure ARCHIVE_CODE',140);
		 END IF;

	END ARCHIVE_CODE;
 END PAY_NO_ARCHIVE_RSEA;

/
