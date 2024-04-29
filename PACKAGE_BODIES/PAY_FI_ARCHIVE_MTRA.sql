--------------------------------------------------------
--  DDL for Package Body PAY_FI_ARCHIVE_MTRA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FI_ARCHIVE_MTRA" AS
 /* $Header: pyfimtra.pkb 120.1.12000000.2 2007/02/28 12:07:40 psingla noship $ */

	 TYPE lock_rec IS RECORD (
	      archive_assact_id    NUMBER);

	 TYPE lock_table      IS TABLE OF  lock_rec      INDEX BY BINARY_INTEGER;

	 g_debug   boolean   :=  hr_utility.debug_enabled;
	 g_lock_table   		          lock_table;
	 g_index             NUMBER := -1;
	 g_index_assact      NUMBER := -1;
	 g_index_bal	    NUMBER := -1;
	 g_package           VARCHAR2(33) := ' PAY_FI_ARCHIVE_MTRA.';
	 g_payroll_action_id	NUMBER;
	 g_arc_payroll_action_id NUMBER;
	 g_business_group_id NUMBER;
	 g_format_mask VARCHAR2(50);
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
       ,p_business_group_id               OUT  NOCOPY NUMBER
       ,p_legal_employer_id			OUT  NOCOPY  NUMBER
       ,p_local_unit_id				OUT  NOCOPY  NUMBER
       ,p_adjustment_wt				OUT  NOCOPY NUMBER
	,p_adjustment_ss			OUT  NOCOPY  NUMBER
	,p_adjustment_ts			OUT  NOCOPY  NUMBER
	,p_vat						OUT  NOCOPY  NUMBER
	,p_month					OUT  NOCOPY  VARCHAR2
	,p_year						OUT  NOCOPY  VARCHAR2
	,p_due_date                                 OUT  NOCOPY  DATE
	,p_ref_number                             OUT  NOCOPY  NUMBER
	,p_effective_date				OUT  NOCOPY DATE
	,p_archive					OUT  NOCOPY  VARCHAR2
	) IS

		CURSOR csr_parameter_info(p_payroll_action_id NUMBER) IS
		SELECT PAY_FI_ARCHIVE_MTRA.GET_PARAMETER(legislative_parameters,'LEGAL_EMPLOYER_ID')
		,PAY_FI_ARCHIVE_MTRA.GET_PARAMETER(legislative_parameters,'LOCAL_UNIT_ID')
		,FND_NUMBER.CANONICAL_TO_NUMBER(PAY_FI_ARCHIVE_MTRA.GET_PARAMETER(legislative_parameters,'ADJUSTMENT_WT'))
		,FND_NUMBER.CANONICAL_TO_NUMBER(PAY_FI_ARCHIVE_MTRA.GET_PARAMETER(legislative_parameters,'ADJUSTMENT_SS'))
		,FND_NUMBER.CANONICAL_TO_NUMBER(PAY_FI_ARCHIVE_MTRA.GET_PARAMETER(legislative_parameters,'ADJUSTMENT_TS'))
		,FND_NUMBER.CANONICAL_TO_NUMBER(PAY_FI_ARCHIVE_MTRA.GET_PARAMETER(legislative_parameters,'VAT'))
		,PAY_FI_ARCHIVE_MTRA.GET_PARAMETER(legislative_parameters,'MONTH_RPT')
		,PAY_FI_ARCHIVE_MTRA.GET_PARAMETER(legislative_parameters,'YEAR_RPT')
		,PAY_FI_ARCHIVE_MTRA.GET_PARAMETER(legislative_parameters,'ARCHIVE')
		,FND_DATE.CANONICAL_TO_DATE(PAY_FI_ARCHIVE_MTRA.GET_PARAMETER(legislative_parameters,'DUE_DATE'))
		,PAY_FI_ARCHIVE_MTRA.GET_PARAMETER(legislative_parameters,'REF_NUMBER')
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
				,p_adjustment_wt
				,p_adjustment_ss
				,p_adjustment_ts
				,p_vat
				,p_month
				,p_year
				,p_archive
				,p_due_date
				,p_ref_number
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
			l_effective_date       DATE;
			l_legal_employer_id    NUMBER ;
			l_local_unit_id        NUMBER ;
			l_adjustment_wt         NUMBER ;
			l_adjustment_ss NUMBER ;
			l_adjustment_ts        NUMBER ;
			l_vat  NUMBER ;
			l_emp_type  VARCHAR2(2);
			l_emp_id        hr_organization_units.organization_id%TYPE ;
			l_due_date1     DATE ;
			l_due_date2     VARCHAR2(30);
			l_ref_number  NUMBER ;
			l_ref_num  VARCHAR2(20);

			l_Record_code                       VARCHAR2(240)   :=' ';
			l_tax_payer_name            hr_organization_units.name%TYPE ;
			l_le_name            hr_organization_units.name%TYPE ;
			l_lu_name            hr_organization_units.name%TYPE ;
			l_address_line_1 hr_locations.address_line_1%TYPE ;
			l_address_line_2 hr_locations.address_line_2%TYPE ;
			l_address_line_3 hr_locations.address_line_3%TYPE ;
			l_postal_code hr_locations.postal_code%TYPE ;
			l_town_or_city hr_locations.town_or_city%TYPE ;
			l_country hr_locations.country%TYPE ;
			l_business_id               hr_organization_information.org_information1%TYPE ;
			l_Sal_subject_Wt    NUMBER;
			l_Sal_subject_Ts    NUMBER;
			l_Pay_subject_Wt    NUMBER;
			l_Pay_subject_ts    NUMBER;
			l_wt_deduction      NUMBER;
			l_employer_ss_fee   NUMBER;
			l_ss_fee    NUMBER;
			l_exem_ss_fee       NUMBER;
			l_ins_ss_fee        NUMBER;
			l_ts_deduction      NUMBER;
			l_vat_bal           NUMBER;
			l_y_number		   hr_organization_information.org_information1%TYPE ;
			l_contact_person    hr_organization_information.org_information1%TYPE ;
			l_phone             hr_organization_information.org_information1%TYPE ;
			l_fax               hr_organization_information.org_information1%TYPE ;
			l_tax_office_ba     pay_external_accounts.segment3%TYPE ;
			l_tax_office_pay_meth_id hr_organization_information.org_information2%TYPE ;
			l_tax_office_name   hr_organization_units.name%TYPE ;
			l_employer_ba       pay_external_accounts.segment3%TYPE ;
			l_employer_pay_meth_id      hr_organization_information.org_information1%TYPE ;
			l_tax_office_id             hr_organization_information.organization_id%TYPE ;
			l_assignment_action_id      pay_assignment_actions.assignment_action_id%TYPE;
			l_counter   number := 0;
			l_archive      VARCHAR2(3);
			l_reporting_date DATE;
			l_termination_date           date;
			l_ele_effective_date             date;
			l_tax_card_type_code         varchar2 (50);
			l_subsidy_for_low_paid_emp   number ;
			l_subsidy_witholding_tax_ded         number := 0;
        		l_subsidy_tax_at_source_dec          number := 0;
			l_subsidy_for_low_paid_bal           ff_database_items.user_name%type;






           	     					/* Cursors */

			Cursor csr_Local_Unit_Details ( csr_v_local_unit_id  hr_organization_information.ORGANIZATION_ID%TYPE)
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

			Cursor csr_Legal_Emp_Details ( csr_v_legal_emp_id  hr_organization_information.ORGANIZATION_ID%TYPE)
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

			Cursor csr_Legal_Emp_Contact ( csr_v_legal_emp_id  hr_organization_information.ORGANIZATION_ID%TYPE)
				IS
					SELECT hoi4.ORG_INFORMATION2 contact_person , hoi3.ORG_INFORMATION2 phone ,hoi2.ORG_INFORMATION2 fax
					FROM hr_organization_units o1
					, hr_organization_information hoi1
					, hr_organization_information hoi2
					, hr_organization_information hoi3
					, hr_organization_information hoi4
					WHERE  o1.business_group_id =l_business_group_id
					AND hoi1.organization_id = o1.organization_id
					AND hoi1.organization_id =  csr_v_legal_emp_id
					AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
					AND hoi1.org_information_context = 'CLASS'
					AND hoi2.organization_id (+)= o1.organization_id
					AND hoi2.ORG_INFORMATION_CONTEXT (+)='ORG_CONTACT_DETAILS'
					AND hoi2.org_information1(+)= 'FAX'
					AND hoi3.organization_id (+)= o1.organization_id
					AND hoi3.ORG_INFORMATION_CONTEXT (+)='ORG_CONTACT_DETAILS'
					AND hoi3.org_information1 (+)= 'PHONE'
					AND hoi4.organization_id (+)= o1.organization_id
					AND hoi4.ORG_INFORMATION_CONTEXT (+)='ORG_CONTACT_DETAILS'
					AND hoi4.org_information1 (+)= 'PERSON' ;

			rg_Legal_Emp_Contact  csr_Legal_Emp_Contact%rowtype;

			Cursor csr_Local_Unit_contact ( csr_v_local_unit_id  hr_organization_information.ORGANIZATION_ID%TYPE)
				IS
					SELECT hoi4.ORG_INFORMATION2 contact_person , hoi3.ORG_INFORMATION2 phone ,hoi2.ORG_INFORMATION2 fax
					FROM hr_organization_units o1
					, hr_organization_information hoi1
					, hr_organization_information hoi2
					, hr_organization_information hoi3
					, hr_organization_information hoi4
					WHERE  o1.business_group_id =l_business_group_id
					AND hoi1.organization_id = o1.organization_id
					AND hoi1.organization_id =  csr_v_local_unit_id
					AND hoi1.org_information1 = 'FI_LOCAL_UNIT'
					AND hoi1.org_information_context = 'CLASS'
					AND hoi2.organization_id (+)= o1.organization_id
					AND hoi2.ORG_INFORMATION_CONTEXT (+)='ORG_CONTACT_DETAILS'
					AND hoi2.org_information1(+)= 'FAX'
					AND hoi3.organization_id (+)= o1.organization_id
					AND hoi3.ORG_INFORMATION_CONTEXT (+)='ORG_CONTACT_DETAILS'
					AND hoi3.org_information1 (+)= 'PHONE'
					AND hoi4.organization_id (+)= o1.organization_id
					AND hoi4.ORG_INFORMATION_CONTEXT (+)='ORG_CONTACT_DETAILS'
					AND hoi4.org_information1 (+)= 'PERSON' ;

			rg_Local_Unit_contact  csr_Local_Unit_contact%rowtype;

			Cursor csr_Local_Unit_addr ( csr_v_local_unit_id  hr_organization_information.ORGANIZATION_ID%TYPE)
				IS
					SELECT hoi1.ADDRESS_LINE_1 , hoi1.ADDRESS_LINE_2 ,  hoi1.ADDRESS_LINE_3 ,
					hoi1.POSTAL_CODE , hoi1.TOWN_OR_CITY , hoi1.COUNTRY
					FROM hr_organization_units o1
					, hr_locations hoi1
					,hr_organization_information hoi2
					WHERE  o1.business_group_id = l_business_group_id
					AND hoi1.location_id = o1.location_id
					AND hoi2.organization_id =  o1.organization_id
					AND hoi2.organization_id = csr_v_local_unit_id
					AND hoi2.org_information1 = 'FI_LOCAL_UNIT'
					AND hoi2.org_information_context = 'CLASS' ;

			rg_Local_Unit_addr  csr_Local_Unit_addr%rowtype;

			Cursor csr_Legal_Emp_addr ( csr_v_legal_emp_id  hr_organization_information.ORGANIZATION_ID%TYPE)
				IS
								SELECT hoi1.ADDRESS_LINE_1 , hoi1.ADDRESS_LINE_2 , hoi1.ADDRESS_LINE_3 ,
					hoi1.POSTAL_CODE , hoi1.TOWN_OR_CITY , hoi1.COUNTRY
					FROM hr_organization_units o1
					, hr_locations hoi1
					,hr_organization_information hoi2
					WHERE  o1.business_group_id = l_business_group_id
					AND hoi1.location_id = o1.location_id
					AND hoi2.organization_id =  o1.organization_id
					AND hoi2.organization_id = csr_v_legal_emp_id
					AND hoi2.org_information1 = 'HR_LEGAL_EMPLOYER'
					AND hoi2.org_information_context = 'CLASS' ;


			rg_Legal_Emp_addr  csr_Legal_Emp_addr%rowtype;

			Cursor csr_Tax_Office_Details ( csr_v_tax_office_id  hr_organization_information.ORGANIZATION_ID%TYPE)
				IS
					SELECT o1.name ,hoi2.ORG_INFORMATION1 ,hoi2.ORG_INFORMATION2
					FROM hr_organization_units o1
					, hr_organization_information hoi1
					, hr_organization_information hoi2
					, hr_organization_information hoi3
					WHERE  o1.business_group_id =l_business_group_id
					AND hoi1.organization_id = o1.organization_id
					AND hoi1.organization_id =  csr_v_tax_office_id
					AND hoi1.org_information1 = 'PROV_TAX_OFFICE'
					AND hoi1.org_information_context = 'CLASS'
					AND hoi3.organization_id = o1.organization_id
					AND hoi3.org_information1 = 'HR_PAYEE'
					AND hoi3.org_information_context = 'CLASS'
					AND o1.organization_id =hoi2.organization_id
					AND hoi2.ORG_INFORMATION_CONTEXT='FI_THIRD_PARTY_PAYMENT';

			rg_Tax_Office_Details  csr_Tax_Office_Details%rowtype;

			Cursor csr_account_number ( csr_v_payment_method_id  pay_org_payment_methods_f.org_payment_method_id%TYPE)
				IS
					SELECT b.segment3
					FROM pay_org_payment_methods_f a , pay_external_accounts b
					WHERE a.org_payment_method_id = csr_v_payment_method_id
					AND a.external_account_id = b.external_account_id
					AND a.business_group_id=l_business_group_id
					AND a.pmeth_information_category ='FI Third Party Payment';

			rg_account_number  csr_account_number%rowtype;

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

                             /* Cursor to take all the payroll runs for the given period for given Payroll Type and Payroll */
      cursor csr_prepaid_assignments_lu (

         p_legal_employer_id   number,
         p_local_unit_id       number,
         p_start_date          date,
         p_end_date            date
      ) is
         select   paaf.person_id, act.assignment_id assignment_id, act.assignment_action_id run_action_id,
                  act1.assignment_action_id
                        prepaid_action_id, appa.effective_date, appa.payroll_action_id,
                  appa2.payroll_action_id payactid, hsck.segment2 local_unit_id
             from pay_payroll_actions appa,
                  pay_payroll_actions appa2,
                  pay_assignment_actions act,
                  pay_assignment_actions act1,
                  pay_action_interlocks pai,
                  per_all_assignments_f paaf,
                  hr_soft_coding_keyflex hsck,
                  hr_organization_information hoi--,
                --  pay_payrolls_f ppa
            where appa.action_type in ('R', 'Q')
              and act.payroll_action_id = appa.payroll_action_id
              and act.source_action_id is null -- Master Action
              and act.action_status = 'C' -- Completed
              and act.assignment_action_id = pai.locked_action_id
              and act1.assignment_action_id = pai.locking_action_id
              and act1.action_status = 'C' -- Completed
              and act1.payroll_action_id = appa2.payroll_action_id
              and appa2.action_type in ('P', 'U')
              and paaf.assignment_id = act.assignment_id
              --  and paaf.assignment_id = p_assignemtn_id
              and appa.effective_date between paaf.effective_start_date and paaf.effective_end_date
              and appa.effective_date between p_start_date and p_end_date
              and paaf.primary_flag = 'Y'
             -- and paaf.person_id between p_start_person and p_end_person
--              and ppa.payroll_id = paaf.payroll_id
--              and ppa.payroll_id = nvl (g_payroll_id, ppa.payroll_id)
--              and ppa.period_type = g_payroll_type
--              and g_year_last_date between ppa.effective_start_date and ppa.effective_end_date
              and hsck.soft_coding_keyflex_id = paaf.soft_coding_keyflex_id
              and hsck.segment2 = nvl (to_char (p_local_unit_id), hsck.segment2)
              and hoi.organization_id = p_legal_employer_id
              and hoi.org_information_context = 'FI_LOCAL_UNITS'
              and hoi.org_information1 = hsck.segment2
         order by person_id, assignment_id, payroll_action_id, prepaid_action_id;

	 /* Cursor to get the latest effective_date */
	 cursor csr_asg_effective_date (
         p_asg_id              number,
         p_end_date            date,
         p_start_date          date,
         p_business_group_id   number
      ) is
         select max (effective_end_date) effective_date
           from per_all_assignments_f paa
          where assignment_id = p_asg_id
            and paa.effective_start_date <= p_end_date
            and paa.effective_end_date > = p_start_date
            and assignment_status_type_id in (select assignment_status_type_id
                                                from per_assignment_status_types
                                               where per_system_status = 'ACTIVE_ASSIGN'
                                                 and active_flag = 'Y'
                                                 and (   (legislation_code is null and business_group_id is null)
                                                      or (business_group_id = p_business_group_id)
                                                     ));
         /* To get the tax Card Type */
           cursor get_element_details (
         p_assignment_id   number,
         p_value_date      date
      ) is
         select eev1.screen_entry_value screen_entry_value
           from per_all_assignments_f asg1,
                per_all_assignments_f asg2,
                per_all_people_f per,
                pay_element_links_f el,
                pay_element_types_f et,
                pay_input_values_f iv1,
                pay_element_entries_f ee,
                pay_element_entry_values_f eev1
          where asg1.assignment_id = p_assignment_id
            and p_value_date between asg1.effective_start_date and asg1.effective_end_date
            and p_value_date between asg2.effective_start_date and asg2.effective_end_date
            and p_value_date between per.effective_start_date and per.effective_end_date
            and per.person_id = asg1.person_id
            and asg2.person_id = per.person_id
            and asg2.primary_flag = 'Y'
            and et.element_name = 'Tax Card'
            and (et.legislation_code = 'FI' or et.business_group_id = g_business_group_id)
            and iv1.element_type_id = et.element_type_id
            and iv1.name = 'Tax Card Type'
            and el.business_group_id = per.business_group_id
            and el.element_type_id = et.element_type_id
            and ee.assignment_id = asg2.assignment_id
            and ee.element_link_id = el.element_link_id
            and eev1.element_entry_id = ee.element_entry_id
            and eev1.input_value_id = iv1.input_value_id
            and p_value_date between ee.effective_start_date and ee.effective_end_date
            and p_value_date between eev1.effective_start_date and eev1.effective_end_date;

          l_person_id  per_all_people_f.person_id%type := -1;
	  l_month_start_date date;

         /* End of Cursors */


				BEGIN
				--	g_debug:=true;
					 IF g_debug THEN
						hr_utility.set_location(' Entering Procedure RANGE_CODE',10);
					 END IF;

					 p_sql := 'SELECT DISTINCT person_id
					FROM  per_people_f ppf
					,pay_payroll_actions ppa
					WHERE ppa.payroll_action_id = :payroll_action_id
					AND   ppa.business_group_id = ppf.business_group_id
					ORDER BY ppf.person_id';

					PAY_FI_ARCHIVE_MTRA.GET_ALL_PARAMETERS(
					p_payroll_action_id
					,l_business_group_id
					,l_legal_employer_id
					,l_local_unit_id
					,l_adjustment_wt
					,l_adjustment_ss
					,l_adjustment_ts
					,l_vat
					,l_month
					,l_year
					,l_due_date1
					,l_ref_number
					,l_effective_date
					,l_archive ) ;

					l_reporting_date := last_day(to_date(l_month || l_year,'MMYYYY'));

					l_ref_num:=lpad(l_ref_number,20,'0');

					IF	l_due_date1     IS NULL THEN
						l_due_date2:= NULL;
					ELSE
						l_due_date2:= FND_DATE.DATE_TO_CANONICAL(l_due_date1);
					END IF;


					IF  l_archive = 'Y' THEN



					SELECT count(*)  INTO l_count
					FROM   pay_action_information
					WHERE  action_information_category = 'EMEA REPORT DETAILS'
					AND        action_information1             = 'PYFIMTRA'
					AND    action_context_id           = p_payroll_action_id;



					IF l_count < 1  then


						hr_utility.set_location('Entered Procedure GETDATA',10);

						BEGIN
							pay_balance_pkg.set_context('TAX_UNIT_ID',l_legal_employer_id);
							pay_balance_pkg.set_context('LOCAL_UNIT_ID',l_local_unit_id);
							pay_balance_pkg.set_context('DATE_EARNED',fnd_date.date_to_canonical(l_reporting_date));
							pay_balance_pkg.set_context('JURISDICTION_CODE',NULL);
							pay_balance_pkg.set_context('SOURCE_ID',NULL);
							pay_balance_pkg.set_context('TAX_GROUP',NULL);
						END;
						hr_utility.set_location('Set the contexts',20);


						hr_utility.set_location('Calculated the Wage Payment Month and Due Date',30);


						OPEN  csr_Legal_Emp_Details(l_legal_employer_id);
							FETCH csr_Legal_Emp_Details INTO rg_Legal_Emp_Details;
						CLOSE csr_Legal_Emp_Details;

						l_le_name	:= rg_Legal_Emp_Details.name ;
						l_y_number   := rg_Legal_Emp_Details.ORG_INFORMATION1 ;


						IF l_local_unit_id IS NOT NULL THEN

						l_emp_type:='LU' ;
						l_emp_id:=l_local_unit_id;
						hr_utility.set_location('Calculation for Local Unit',40);

						BEGIN

							SELECT		MAX(ASSIGNMENT_ACTION_ID)
							INTO		l_assignment_action_id
							FROM		pay_run_balances
							WHERE		local_unit_id = l_local_unit_id
							AND		 TO_CHAR(effective_date,'MMYYYY')=l_month||l_year ;

						EXCEPTION
							WHEN others THEN
							NULL;
						END;

						hr_utility.set_location('Fetched the Assignment action id',50);


						/* Pick up the details belonging to Local Unit */

						OPEN  csr_Local_Unit_Details( l_local_unit_id);
							FETCH csr_Local_Unit_Details INTO rg_Local_Unit_Details;
						CLOSE csr_Local_Unit_Details;

						l_tax_payer_name	:= rg_Local_Unit_Details.name ;
						l_lu_name	:= rg_Local_Unit_Details.name ;
						l_business_id		:= l_y_number||'-'||rg_Local_Unit_Details.ORG_INFORMATION1 ;
						l_tax_office_id		:= rg_Local_Unit_Details.ORG_INFORMATION7 ;


						hr_utility.set_location('Pick up the details belonging to Local Unit',60);

						/* Pick up the contact details belonging to  Local Unit*/

						OPEN  csr_Local_Unit_contact( l_local_unit_id);
						FETCH csr_Local_Unit_contact INTO rg_Local_Unit_contact;
						CLOSE csr_Local_Unit_contact;

						l_contact_person	:= rg_Local_Unit_contact.contact_person ;
						l_phone			:= rg_Local_Unit_contact.phone ;
						l_fax			:= rg_Local_Unit_contact.fax ;

						hr_utility.set_location('Pick up the contact details belonging to  Local Unit',70);

						/* Pick up the Address details belonging to  Local Unit*/

						OPEN  csr_Local_Unit_addr( l_local_unit_id);
							FETCH csr_Local_Unit_addr INTO rg_Local_Unit_addr;
						CLOSE csr_Local_Unit_addr;

						l_address_line_1	:= rg_Local_Unit_addr.address_line_1 ;
						l_address_line_2	:= rg_Local_Unit_addr.address_line_2 ;
						l_address_line_3	:= rg_Local_Unit_addr.address_line_3 ;
						l_postal_code		:= rg_Local_Unit_addr.postal_code ;
						l_town_or_city		:= rg_Local_Unit_addr.town_or_city ;
						l_country		:= rg_Local_Unit_addr.country ;


						l_subsidy_for_low_paid_bal := 'SUBSIDY_FOR_LOW_PAID_EMPLOYEES_PER_LU_MONTH';

						OPEN  csr_Get_Defined_Balance_Id( 'TAX_AT_SOURCE_LU_MONTH');

						FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;

						CLOSE csr_Get_Defined_Balance_Id;

						l_ts_deduction := pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id );



						OPEN  csr_Get_Defined_Balance_Id( 'WITHHOLDING_TAX_LU_MONTH');
						FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
						CLOSE csr_Get_Defined_Balance_Id;

						l_wt_deduction := pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id );


						OPEN  csr_Get_Defined_Balance_Id( 'VAT_LU_MONTH');
						FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
						CLOSE csr_Get_Defined_Balance_Id;

						l_vat_bal := pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id );

						OPEN  csr_Get_Defined_Balance_Id( 'SALARIES_SUBJECT_TO_WITHHOLD_TAX_LU_MONTH');
						FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
						CLOSE csr_Get_Defined_Balance_Id;

						l_Sal_subject_Wt :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id );

						OPEN  csr_Get_Defined_Balance_Id( 'SALARIES_SUBJECT_TO_TAX_AT_SOURCE_LU_MONTH');
						FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
						CLOSE csr_Get_Defined_Balance_Id;



						l_Sal_subject_Ts := pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id );

						OPEN  csr_Get_Defined_Balance_Id( 'PAYMENTS_SUBJECT_TO_WITHHOLD_TAX_LU_MONTH');
						FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
						CLOSE csr_Get_Defined_Balance_Id;

						l_Pay_subject_Wt := pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id );

						OPEN  csr_Get_Defined_Balance_Id( 'PAYMENTS_SUBJECT_TO_TAX_AT_SOURCE_LU_MONTH');
						FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
						CLOSE csr_Get_Defined_Balance_Id;

						l_Pay_subject_ts := pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id );


						OPEN  csr_Get_Defined_Balance_Id( 'SOCIAL_SECURITY_LU_MONTH');
						FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
						CLOSE csr_Get_Defined_Balance_Id;

						l_ss_fee :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id );

						OPEN  csr_Get_Defined_Balance_Id( 'EXEMPTED_SOCIAL_SECURITY_LU_MONTH');
						FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
						CLOSE csr_Get_Defined_Balance_Id;

						 l_exem_ss_fee := pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id );



						OPEN  csr_Get_Defined_Balance_Id( 'INSURANCE_SALARY_LU_MONTH');
						FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
						CLOSE csr_Get_Defined_Balance_Id;

						l_ins_ss_fee := pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id, P_ASSIGNMENT_ACTION_ID =>l_assignment_action_id );

						 l_employer_ss_fee := nvl(l_ss_fee,0)  +  nvl(l_exem_ss_fee,0)  +  nvl(l_ins_ss_fee ,0) ;
					ELSE

						l_emp_type:='LE' ;
						l_emp_id:=l_legal_employer_id ;

						BEGIN

							SELECT		MAX(ASSIGNMENT_ACTION_ID)
							INTO		l_assignment_action_id
							FROM		pay_run_balances
							WHERE		tax_unit_id =l_legal_employer_id
							AND		 TO_CHAR(effective_date,'MMYYYY')=l_month||l_year ;

						EXCEPTION
							WHEN others THEN
							NULL;
						END;

						/* Pick up the details belonging to Legal Employer */

						OPEN  csr_Legal_Emp_Details(l_legal_employer_id);
							FETCH csr_Legal_Emp_Details INTO rg_Legal_Emp_Details;
						CLOSE csr_Legal_Emp_Details;

						l_tax_payer_name	:= rg_Legal_Emp_Details.name ;
						l_business_id		:= rg_Legal_Emp_Details.ORG_INFORMATION1 ;
						l_tax_office_id		:= rg_Legal_Emp_Details.ORG_INFORMATION11 ;

						/* Pick up the contact details belonging to Legal Employer */

						OPEN  csr_Legal_Emp_contact( l_legal_employer_id);
							FETCH csr_Legal_Emp_contact INTO rg_Legal_Emp_contact;
						CLOSE csr_Legal_Emp_contact;

						l_contact_person	:= rg_Legal_Emp_Contact .contact_person ;
						l_phone			:= rg_Legal_Emp_Contact .phone ;
						l_fax			:= rg_Legal_Emp_Contact .fax ;


						/* Pick up the Address details belonging to  Legal Employer */

						OPEN  csr_Legal_Emp_addr(l_legal_employer_id);
							FETCH csr_Legal_Emp_addr INTO rg_Legal_Emp_addr;
						CLOSE csr_Legal_Emp_addr;

						l_address_line_1	:= rg_Legal_Emp_addr.address_line_1 ;
						l_address_line_2	:= rg_Legal_Emp_addr.address_line_2 ;
						l_address_line_3	:= rg_Legal_Emp_addr.address_line_3 ;
						l_postal_code		:= rg_Legal_Emp_addr.postal_code ;
						l_town_or_city		:= rg_Legal_Emp_addr.town_or_city ;
						l_country		:= rg_Legal_Emp_addr.country ;

 					        l_subsidy_for_low_paid_bal := 'SUBSIDY_FOR_LOW_PAID_EMPLOYEES_PER_LE_MONTH';

						OPEN  csr_Get_Defined_Balance_Id( 'TAX_AT_SOURCE_LE_MONTH');
						FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
						CLOSE csr_Get_Defined_Balance_Id;

						l_ts_deduction := pay_balance_pkg.get_value(lr_Get_Defined_Balance_Id.creator_id,NULL,  l_legal_employer_id, NULL, NULL, NULL, l_reporting_date );

						OPEN  csr_Get_Defined_Balance_Id( 'WITHHOLDING_TAX_LE_MONTH');
						FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
						CLOSE csr_Get_Defined_Balance_Id;

						l_wt_deduction := pay_balance_pkg.get_value(lr_Get_Defined_Balance_Id.creator_id,NULL,  l_legal_employer_id, NULL, NULL, NULL, l_reporting_date );


						OPEN  csr_Get_Defined_Balance_Id( 'VAT_LE_MONTH');
						FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
						CLOSE csr_Get_Defined_Balance_Id;

						l_vat_bal := pay_balance_pkg.get_value(lr_Get_Defined_Balance_Id.creator_id,NULL,  l_legal_employer_id, NULL, NULL, NULL, l_reporting_date );

						OPEN  csr_Get_Defined_Balance_Id( 'SALARIES_SUBJECT_TO_WITHHOLD_TAX_LE_MONTH');
						FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
						CLOSE csr_Get_Defined_Balance_Id;

						l_Sal_subject_Wt := pay_balance_pkg.get_value(lr_Get_Defined_Balance_Id.creator_id,NULL,  l_legal_employer_id, NULL, NULL, NULL, l_reporting_date );

						OPEN  csr_Get_Defined_Balance_Id( 'SALARIES_SUBJECT_TO_TAX_AT_SOURCE_LE_MONTH');
						FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
						CLOSE csr_Get_Defined_Balance_Id;

						l_Sal_subject_Ts := pay_balance_pkg.get_value(lr_Get_Defined_Balance_Id.creator_id,NULL,  l_legal_employer_id, NULL, NULL, NULL, l_reporting_date );

						OPEN  csr_Get_Defined_Balance_Id( 'PAYMENTS_SUBJECT_TO_WITHHOLD_TAX_LE_MONTH');
						FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
						CLOSE csr_Get_Defined_Balance_Id;

						l_Pay_subject_Wt := pay_balance_pkg.get_value(lr_Get_Defined_Balance_Id.creator_id,NULL,  l_legal_employer_id, NULL, NULL, NULL, l_reporting_date );

						OPEN  csr_Get_Defined_Balance_Id( 'PAYMENTS_SUBJECT_TO_TAX_AT_SOURCE_LE_MONTH');
						FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
						CLOSE csr_Get_Defined_Balance_Id;

						l_Pay_subject_ts := pay_balance_pkg.get_value(lr_Get_Defined_Balance_Id.creator_id,NULL,  l_legal_employer_id, NULL, NULL, NULL, l_reporting_date );


						OPEN  csr_Get_Defined_Balance_Id( 'SOCIAL_SECURITY_LE_MONTH');
						FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
						CLOSE csr_Get_Defined_Balance_Id;

						l_ss_fee := pay_balance_pkg.get_value(lr_Get_Defined_Balance_Id.creator_id,NULL,  l_legal_employer_id, NULL, NULL, NULL, l_reporting_date );

						OPEN  csr_Get_Defined_Balance_Id( 'EXEMPTED_SOCIAL_SECURITY_LE_MONTH');
						FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
						CLOSE csr_Get_Defined_Balance_Id;

						 l_exem_ss_fee := pay_balance_pkg.get_value(lr_Get_Defined_Balance_Id.creator_id,NULL,  l_legal_employer_id, NULL, NULL, NULL, l_reporting_date );

						OPEN  csr_Get_Defined_Balance_Id( 'INSURANCE_SALARY_LE_MONTH');
						FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
						CLOSE csr_Get_Defined_Balance_Id;

						 l_ins_ss_fee := pay_balance_pkg.get_value(lr_Get_Defined_Balance_Id.creator_id,NULL,  l_legal_employer_id, NULL, NULL, NULL, l_reporting_date );

						 l_employer_ss_fee := nvl(l_ss_fee,0)  +  nvl(l_exem_ss_fee,0)  +  nvl(l_ins_ss_fee ,0) ;


					END IF ;



					/* Pick up the tax office details belonging to  Employer*/

					OPEN  csr_Tax_Office_Details( l_tax_office_id );
						FETCH csr_Tax_Office_Details INTO rg_Tax_Office_Details;
					CLOSE csr_Tax_Office_Details;

					l_tax_office_name		:= rg_Tax_Office_Details.name ;
					l_tax_office_pay_meth_id	:= rg_Tax_Office_Details.ORG_INFORMATION2 ;
					l_employer_pay_meth_id		:= rg_Tax_Office_Details.ORG_INFORMATION1 ;

					hr_utility.set_location('Pick up the tax office details belonging to  Employer',70);

					OPEN  csr_account_number( l_tax_office_pay_meth_id );
						FETCH csr_account_number INTO rg_account_number;
					CLOSE csr_account_number;

					l_tax_office_ba	:= rg_account_number.segment3 ;

					OPEN  csr_account_number( l_employer_pay_meth_id);
						FETCH csr_account_number INTO rg_account_number;
					CLOSE csr_account_number;

					l_employer_ba		:= rg_account_number.segment3 ;
						hr_utility.set_location('Before populating pl/sql table',70);
					IF  l_vat  IS  NULL THEN
						l_vat:=l_vat_bal;
					END IF;

					l_month_start_date := trunc(l_reporting_date,'MM');

                                                 for rec_prepaid_assignments in csr_prepaid_assignments_lu (
  						     p_legal_employer_id   => l_legal_employer_id,
                                 		     p_local_unit_id       => l_local_unit_id,
						     p_start_date          => l_month_start_date,
						     p_end_date            => l_reporting_date)
					    loop
						   if rec_prepaid_assignments.person_id <> l_person_id then
						       open csr_asg_effective_date (
								p_asg_id                 => rec_prepaid_assignments.assignment_id,
								p_end_date               => l_reporting_date,
								p_start_date             => l_month_start_date,
								p_business_group_id      => l_business_group_id
									);

						       fetch csr_asg_effective_date into l_termination_date;
                                                       close csr_asg_effective_date;

						       if l_termination_date < l_reporting_date then
                                                          l_ele_effective_date := l_termination_date;
                                                       else
                                                          l_ele_effective_date := l_reporting_date;
                                                       end if;
							l_tax_card_type_code := null;

							-- Get the tax card type
							open get_element_details (rec_prepaid_assignments.assignment_id,l_ele_effective_date);
						        fetch get_element_details into l_tax_card_type_code;
		                                        close get_element_details;

							open  csr_get_defined_balance_id( l_subsidy_for_low_paid_bal);
							fetch csr_get_defined_balance_id into lr_get_defined_balance_id;
							close csr_get_defined_balance_id;

							l_subsidy_for_low_paid_emp := pay_balance_pkg.get_value(p_defined_balance_id   => lr_Get_Defined_Balance_Id.creator_id,
							                                                        p_assignment_id        => rec_prepaid_assignments.assignment_id,
													        p_virtual_date         => l_ele_effective_date
															);

							IF l_tax_card_type_code = 'TS' then
							   l_subsidy_tax_at_source_dec := l_subsidy_tax_at_source_dec + l_subsidy_for_low_paid_emp;
							else
							   l_subsidy_witholding_tax_ded := l_subsidy_witholding_tax_ded + l_subsidy_for_low_paid_emp;
							end if;

						     end if;
						      l_person_id :=  rec_prepaid_assignments.person_id;
					   end loop;

					pay_action_information_api.create_action_information (
					p_action_information_id         => l_action_info_id
					,p_action_context_id            => p_payroll_action_id
					,p_action_context_type          => 'PA'
					,p_object_version_number        => l_ovn
					,p_effective_date               => l_effective_date
					,p_source_id                    => NULL
					,p_source_text                  => NULL
					,p_action_information_category  => 'EMEA REPORT INFORMATION'
					,p_action_information1          => 'PYFIMTRA'
					,p_action_information2          => l_emp_type
					,p_action_information3          => FND_NUMBER.NUMBER_TO_CANONICAL(l_subsidy_tax_at_source_dec) --l_emp_id
					,p_action_information4          => l_month||l_year
					,p_action_information5          => l_tax_payer_name
					,p_action_information6          => l_address_line_1
					,p_action_information7          => l_address_line_2
					,p_action_information8          => l_address_line_3
					,p_action_information9          => l_postal_code || '  ' ||l_town_or_city ||'  '||l_country
					,p_action_information10          =>  l_business_id
					,p_action_information11          => FND_NUMBER.NUMBER_TO_CANONICAL(l_Sal_subject_Wt)
					,p_action_information12          => FND_NUMBER.NUMBER_TO_CANONICAL(l_Sal_subject_Ts)
					,p_action_information13          => FND_NUMBER.NUMBER_TO_CANONICAL(l_Pay_subject_Wt)
					,p_action_information14          => FND_NUMBER.NUMBER_TO_CANONICAL(l_Pay_subject_ts)
					,p_action_information15          => FND_NUMBER.NUMBER_TO_CANONICAL(l_wt_deduction)
					,p_action_information16          => FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_adjustment_wt,0))
					,p_action_information17          =>  FND_NUMBER.NUMBER_TO_CANONICAL(l_employer_ss_fee)
					,p_action_information18          => FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_adjustment_ss,0))
					,p_action_information19          =>  FND_NUMBER.NUMBER_TO_CANONICAL(l_ts_deduction)
					,p_action_information20          => FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_adjustment_ts,0))
					,p_action_information21          => FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_vat,0))
					,p_action_information22          => l_contact_person
					,p_action_information23          => l_phone
					,p_action_information24          => l_fax
					,p_action_information25          => l_tax_office_ba
					,p_action_information26          => l_tax_office_name
					,p_action_information27          => l_employer_ba
					,p_action_information28          => l_due_date2
					,p_action_information29          =>  l_ref_num
					,p_action_information30          => FND_NUMBER.NUMBER_TO_CANONICAL(l_subsidy_witholding_tax_ded)  ); -- null );


					pay_action_information_api.create_action_information (
					p_action_information_id        => l_action_info_id
					,p_action_context_id            => p_payroll_action_id
					,p_action_context_type          => 'PA'
					,p_object_version_number        => l_ovn
					,p_effective_date               => l_effective_date
					,p_source_id                    => NULL
					,p_source_text                  => NULL
					,p_action_information_category  => 'EMEA REPORT DETAILS'
					,p_action_information1          => 'PYFIMTRA'
					,p_action_information2          => l_le_name
					,p_action_information3          => l_lu_name
					,p_action_information4          => l_month
					,p_action_information5          => l_year
					,p_action_information6          =>  null
					,p_action_information7          =>  null
					,p_action_information8          =>  null
					,p_action_information9          =>  null
					,p_action_information10          =>   null
					,p_action_information11          =>   null
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
		IF g_debug THEN
			hr_utility.set_location(' Entering Procedure ASSIGNMENT_ACTION_CODE',60);
		END IF;

		 IF g_debug THEN
		      hr_utility.set_location(' Leaving Procedure ASSIGNMENT_ACTION_CODE',70);
		 END IF;


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

		 EXCEPTION WHEN OTHERS THEN
		 g_err_num := SQLCODE;
		 IF g_debug THEN
		      hr_utility.set_location('ORA_ERR: ' || g_err_num || 'In INITIALIZATION_CODE',180);
		 END IF;
	 END INITIALIZATION_CODE;

 	 /* ARCHIVE CODE */
	 PROCEDURE ARCHIVE_CODE(p_assignment_action_id IN NUMBER
			      ,p_effective_date    IN DATE)
	 IS

	BEGIN
		 IF g_debug THEN
				hr_utility.set_location(' Entering Procedure ARCHIVE_CODE',80);
		 END IF;

		 IF g_debug THEN
				hr_utility.set_location(' Leaving Procedure ARCHIVE_CODE',90);
		 END IF;

	END ARCHIVE_CODE;
 END PAY_FI_ARCHIVE_MTRA;

/
