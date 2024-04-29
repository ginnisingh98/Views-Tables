--------------------------------------------------------
--  DDL for Package PAY_SG_CPFLINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SG_CPFLINE" AUTHID CURRENT_USER as
/* $Header: pysgcpfl.pkh 120.0.12010000.2 2008/11/27 07:44:14 jalin ship $ */
       level_cnt  number;
       --------------------------------------------------------------------
       -- These are PUBLIC procedures are required by the Archive process.
       -- Their names are stored in PAY_REPORT_FORMAT_MAPPINGS_F so that
       -- the archive process knows what code to execute for each step of
       -- the archive.
       --------------------------------------------------------------------
       procedure range_code
           ( p_payroll_action_id  in   pay_payroll_actions.payroll_action_id%type,
             p_sql                out  nocopy varchar2);
       --
       procedure assignment_action_code
           ( p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type,
             p_start_person_id    in per_all_people_f.person_id%type,
             p_end_person_id      in per_all_people_f.person_id%type,
             p_chunk              in number );
       --
       procedure initialization_code
           ( p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type);
       --
       procedure archive_code
           ( p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
             p_effective_date        in date);
       --
       procedure deinit_code
           ( p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type ) ;
       --

       ------------------------------------------------------------------------
       -- Bug 7532687 - The function to check if the CPF CSN is valid
       ------------------------------------------------------------------------
    function check_cpf_number (p_er_cpf_number   in varchar2,
                             p_er_cpf_category in varchar2,
                             p_er_payer_id     in varchar2) return char;

       --------------------------------------------------------------------------
       -- company_identification cursor
       -- Bug#3501950 - Added CPF_Interest and FWL_Interest parameters
       --------------------------------------------------------------------------
       cursor  company_identification is
       select  'BUSINESS_GROUP_ID=C',
               pay_magtape_generic.get_parameter_value('BUSINESS_GROUP_ID') business_group_id,
               'TAX_UNIT_ID=C',
               pay_magtape_generic.get_parameter_value('LEGAL_ENTITY_ID') tax_unit_id,
               'DOCUMENT_DATE=P',
               to_char(sysdate,'YYYYMMDD') document_date,
               'LEGAL_ENTITY=P',
               hou.name legal_entity,
               'MONTH=P',
               pay_magtape_generic.get_parameter_value('MONTH') month,
               'ADVICE_CODE=P',
               '01' advice_code,
               'AV1_AMOUNT=P',
               to_char(pay_sg_cpfline_balances.stat_type_amount
               ( pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID'), 'AV1')) av1_amount,
               'AV3_AMOUNT=P',
               to_char(pay_sg_cpfline_balances.stat_type_amount
               ( pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID'), 'AV3')) av3_amount,
               'AV4_AMOUNT=P',
               to_char(pay_sg_cpfline_balances.stat_type_amount
               ( pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID'), 'AV4')) av4_amount,
               'AV5_AMOUNT=P',
               to_char(pay_sg_cpfline_balances.stat_type_amount
               ( pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID'), 'AV5')) av5_amount,
               'AV7_AMOUNT=P',
               to_char(pay_sg_cpfline_balances.stat_type_amount
               ( pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID'), 'AV7')) av7_amount,
               'AVA_AMOUNT=P',
               to_char(pay_sg_cpfline_balances.stat_type_amount
               ( pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID'), 'AVA')) ava_amount,
               'AVE_AMOUNT=P',
               to_char(pay_sg_cpfline_balances.stat_type_amount
               ( pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID'), 'AVE')) ave_amount,
               'AVG_AMOUNT=P',
               to_char(pay_sg_cpfline_balances.stat_type_amount
               ( pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID'), 'AVG')) avg_amount,
               'MUS_COUNT=P',
               to_char(pay_sg_cpfline_balances.stat_type_count
               ( pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID'), 'MUS')) mus_count,
               'SHA_COUNT=P',
               to_char(pay_sg_cpfline_balances.stat_type_count
               ( pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID'), 'SHA')) sha_count,
               'SIN_COUNT=P',
               to_char(pay_sg_cpfline_balances.stat_type_count
               ( pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID'), 'SIN')) sin_count,
               'CDA_COUNT=P',
               to_char(pay_sg_cpfline_balances.stat_type_count
               ( pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID'), 'CDA')) cda_count,
               'ECF_COUNT=P',
               to_char(pay_sg_cpfline_balances.stat_type_count
               ( pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID'), 'ECF')) ecf_count,
               'TOTAL_CONTRIBUTION=P',
               to_char(pay_sg_cpfline_balances.stat_type_amount
               ( pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID'), 'TOT')) total_contribution,
               'CPF_INTEREST=P',
               pay_sg_cpfline_balances.get_cpf_interest
               (pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')) cpf_interest,
               'FWL_INTEREST=P',
	       pay_sg_cpfline_balances.get_fwl_interest
               (pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')) fwl_interest
         from  hr_organization_units hou,
               hr_organization_information hoi1,
               hr_organization_information hoi2
        where  hou.organization_id = pay_magtape_generic.get_parameter_value('LEGAL_ENTITY_ID')
          and  hou.organization_id = hoi1.organization_id(+)
          and  hou.organization_id = hoi2.organization_id
          and  hoi1.org_information_context = 'SG_LEGAL_ENTITY'
          and  hoi2.org_information_context = 'CLASS'
          and  hoi2.org_information1 = 'HR_LEGAL'
          and  hoi2.org_information2 = 'Y' ;
       ----------------------------------
       --   Existing_Employees cursor
       --   Bug#3153476   Modified the 'sort parameter'.
       --   Now  cursor passes SORT=1 for employee with permit type 'WP' or 'EP'.
       --   Bug#3298317   Added one more parameter 'permit_type' to function call 'get_balance_value'.
       --                 Rounding the cpf balannces so there are no rounding discrepancies
       --                 between AV1 and sum of AV2 in the file.
       --   Bug: 3619297 - Modified the inner queries added checks on action_context_type.
       ----------------------------------
       cursor  existing_employees is
       select  'DEPARTMENT=P',
               pai.action_information22 department,
               'ASSIGNMENT_ACTION_ID=C',
               paa.assignment_action_id,
               'TAX_UNIT_ID=C',
               paa.tax_unit_id,
               'DATE_EARNED=C',
               pai.action_information20 date_earned,
               'ASSIGNMENT_ID=C',
               paa.assignment_id,
               'SORT=P',
	       decode(pai.action_information1,null,'1',(decode(pai.action_information21,'WP','1',(decode(pai.action_information21,'EP','1',(decode(pai.action_information21,'SP','1','0'))))))) sort,
               pai.action_information3  hire_date,
               'VOL_CPF_LIAB=P',
                to_char(to_number(pai.action_information4))||'#'|| to_char(to_number(pai.action_information4))    vol_cpf_liab,
               'CPF_LIAB=P',
               to_char(to_number(pai.action_information6))||'#'|| to_char(to_number(pai.action_information6))    cpf_liab,
               'VOL_CPF_WITHHELD=P',
               to_char(to_number(pai.action_information5))||'#'|| to_char(to_number(pai.action_information5))    vol_cpf_withheld,
               'CPF_WITHHELD=P',
               to_char(to_number(pai.action_information7))||'#'|| to_char(to_number(pai.action_information7))    cpf_withheld,
               'MBMF_WITHHELD=P',
               pai.action_information8||'#'||pai.action_information8    mbmf_withheld,
               'SINDA_WITHHELD=P',
               pai.action_information9||'#'||pai.action_information9    sinda_withheld,
               'CDAC_WITHHELD=P',
               pai.action_information10||'#'||pai.action_information10  cdac_withheld,
               'ECF_WITHHELD=P',
               pai.action_information11||'#'||pai.action_information11  ecf_withheld,
               'CPF_ORD_ELIG_COMP=P',
               pai.action_information12||'#'||pai.action_information12  cpf_ord_elig_comp,
               'CPF_ADD_ELIG_COMP=P',
               pai.action_information13||'#'||pai.action_information13  cpf_add_elig_comp ,
               'LEGAL_NAME=P',
               pai.action_information17||'#'||pai.action_information17  legal_name,
               'EMPLOYEE_NUMBER=P',
               pai.action_information18||'#'||pai.action_information18  employee_number,
               'EMP_TERMINATION_DATE=P',
               nvl(to_char(fnd_date.canonical_to_date(pai.action_information19),'dd/mm/yyyy'),'01/01/1900')  emp_termination_date
         from  pay_payroll_actions      ppa,
               pay_assignment_actions   paa,
               pay_action_information   pai
        where  ppa.payroll_action_id            = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
          and  ppa.payroll_action_id            = paa.payroll_action_id
          and  paa.assignment_action_id         = pai.action_context_id
          and  pai.action_information_category  = 'SG CPF DETAILS'
          and  pai.action_context_type          = 'AAC'
          and  pai.action_information2          = 'EE'
          and  not exists ( select  1
		              from pay_action_information pai_dup,
		                   pay_assignment_actions paa_dup
                             where pai.action_information_category =  pai_dup.action_information_category
                               and pai.rowid                      <> pai_dup.rowid
		               and paa_dup.payroll_action_id       =  ppa.payroll_action_id
		               and paa_dup.assignment_action_id    =  pai_dup.action_context_id
	                       and pai.action_information1         =  pai_dup.action_information1
                               and  pai_dup.action_context_type     = 'AAC'      )
       union all
       select  'DEPARTMENT=P',
               pai.action_information22 department,
               'ASSIGNMENT_ACTION_ID=C',
               paa.assignment_action_id,
               'TAX_UNIT_ID=C',
               paa.tax_unit_id,
               'DATE_EARNED=C',
               pai.action_information20 date_earned,
               'ASSIGNMENT_ID=C',
               paa.assignment_id,
               'SORT=P',
               decode(pai.action_information1,null,'1',(decode(pai.action_information21,'WP','1',(decode(pai.action_information21,'EP','1',(decode(pai.action_information21,'SP','1','0'))))))) sort,
               pai.action_information3  hire_date,
               'VOL_CPF_LIAB=P',
               pay_sg_cpfline_balances.get_balance_value( 'EE',
                                                  paa.assignment_id,
                                                  nvl(pai.action_information1,pai.source_id),
                                                  pai.action_information22,
	                                          paa.assignment_action_id,
                                                  paa.tax_unit_id,
                                                  'Voluntary CPF Liability',
                                                  pai.action_information4,
                                                  ppa.payroll_action_id,
                                                  pai.action_information21
                                               )  vol_cpf_liab,
               'CPF_LIAB=P',
               pay_sg_cpfline_balances.get_balance_value( 'EE',
                                                 paa.assignment_id,
                                                 nvl(pai.action_information1,pai.source_id),
                                                 pai.action_information22,
	                                         paa.assignment_action_id,
                                                 paa.tax_unit_id,
                                                 'CPF Liability',
                                                 pai.action_information6,
	                                         ppa.payroll_action_id,
						 pai.action_information21
					       ) cpf_liab,
               'VOL_CPF_WITHHELD=P',
               pay_sg_cpfline_balances.get_balance_value( 'EE',
                                                 paa.assignment_id,
                                                 nvl(pai.action_information1,pai.source_id),
                                                 pai.action_information22,
                                                 paa.assignment_action_id,
                                                 paa.tax_unit_id,
                                                 'Voluntary CPF Withheld',
                                                 pai.action_information5,
                                                 ppa.payroll_action_id,
						 pai.action_information21
                                               ) vol_cpf_withheld,
               'CPF_WITHHELD=P',
               pay_sg_cpfline_balances.get_balance_value( 'EE',
                                                 paa.assignment_id,
                                                 nvl(pai.action_information1,pai.source_id),
                                                 pai.action_information22,
                                                 paa.assignment_action_id,
                                                 paa.tax_unit_id,
                                                 'CPF Withheld',
                                                 pai.action_information7,
	                                         ppa.payroll_action_id,
						 pai.action_information21
					       ) cpf_withheld,
               'MBMF_WITHHELD=P',
               pay_sg_cpfline_balances.get_balance_value( 'EE',
                                                 paa.assignment_id,
                                                 nvl(pai.action_information1,pai.source_id),
                                                 pai.action_information22,
                                                 paa.assignment_action_id,
                                                 paa.tax_unit_id,
                                                 'MBMF Withheld',
                                                 pai.action_information8,
	                                         ppa.payroll_action_id,
						 pai.action_information21
                                               ) mbmf_withheld,
               'SINDA_WITHHELD=P',
               pay_sg_cpfline_balances.get_balance_value( 'EE',
                                                 paa.assignment_id,
                                                 nvl(pai.action_information1,pai.source_id),
                                                 pai.action_information22,
                                                 paa.assignment_action_id,
                                                 paa.tax_unit_id,
                                                 'SINDA Withheld',
                                                 pai.action_information9,
                                                 ppa.payroll_action_id,
						 pai.action_information21
                                               ) sinda_withheld,
               'CDAC_WITHHELD=P',
               pay_sg_cpfline_balances.get_balance_value( 'EE',
                                                 paa.assignment_id,
                                                 nvl(pai.action_information1,pai.source_id),
                                                 pai.action_information22,
                                                 paa.assignment_action_id,
                                                 paa.tax_unit_id,
                                                 'CDAC Withheld',
                                                 pai.action_information10,
                                                 ppa.payroll_action_id,
						 pai.action_information21
                                               ) cdac_withheld,
               'ECF_WITHHELD=P',
               pay_sg_cpfline_balances.get_balance_value( 'EE',
                                                 paa.assignment_id,
                                                 nvl(pai.action_information1,pai.source_id),
                                                 pai.action_information22,
                                                 paa.assignment_action_id,
                                                 paa.tax_unit_id,
                                                 'ECF Withheld',
                                                 pai.action_information11,
	                                         ppa.payroll_action_id,
						 pai.action_information21
                                               ) ecf_withheld,
               'CPF_ORD_ELIG_COMP=P',
               pay_sg_cpfline_balances.get_balance_value( 'EE',
                                                 paa.assignment_id,
                                                 nvl(pai.action_information1,pai.source_id),
                                                 pai.action_information22,
                                                 paa.assignment_action_id,
                                                 paa.tax_unit_id,
                                                 'CPF Ordinary Earnings Eligible Comp',
                                                 pai.action_information12,
                                                 ppa.payroll_action_id,
						 pai.action_information21
                                               ) cpf_ord_elig_comp,
               'CPF_ADD_ELIG_COMP=P',
               pay_sg_cpfline_balances.get_balance_value( 'EE',
                                                 paa.assignment_id,
                                                 nvl(pai.action_information1,pai.source_id),
                                                 pai.action_information22,
                                                 paa.assignment_action_id,
                                                 paa.tax_unit_id,
                                                 'CPF Additional Earnings Eligible Comp',
                                                 pai.action_information13,
                                                 ppa.payroll_action_id,
						 pai.action_information21
                                               ) cpf_add_elig_comp ,
               'LEGAL_NAME=P',
               pay_sg_cpfline_balances.get_balance_value( 'EE',
                                                 paa.assignment_id,
                                                 nvl(pai.action_information1,pai.source_id),
                                                 pai.action_information22,
                                                 paa.assignment_action_id,
                                                 paa.tax_unit_id,
                                                 'Legal_Name',
                                                 pai.action_information17,
                                                 ppa.payroll_action_id,
						 pai.action_information21
                                               ) legal_name,
               'EMPLOYEE_NUMBER=P',
               pay_sg_cpfline_balances.get_balance_value(  'EE',
                                                  paa.assignment_id,
                                                  nvl(pai.action_information1,pai.source_id),
                                                  pai.action_information22,
                                                  paa.assignment_action_id,
                                                  paa.tax_unit_id,
                                                  'Employee_Number',
                                                  pai.action_information18,
                                                  ppa.payroll_action_id,
						  pai.action_information21
                                               )  employee_number,
               'EMP_TERMINATION_DATE=P',
               pay_sg_cpfline_balances.get_balance_value( 'EE',
                                                 paa.assignment_id,
                                                 nvl(pai.action_information1,pai.source_id),
                                                 pai.action_information22,
                                                 paa.assignment_action_id,
                                                 paa.tax_unit_id,
                                                 'Emp_Term_Date',
                                                 pai.action_information19,
                                                 ppa.payroll_action_id,
						 pai.action_information21
                                               ) emp_termination_date
         from  pay_payroll_actions      ppa,
               pay_assignment_actions   paa,
               pay_action_information   pai
        where  ppa.payroll_action_id            = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
          and  ppa.payroll_action_id            = paa.payroll_action_id
          and  paa.assignment_action_id         = pai.action_context_id
          and  pai.action_information_category  = 'SG CPF DETAILS'
          and  pai.action_context_type          = 'AAC'
          and  pai.action_information2          = 'EE'
          and  exists ( select  1
		          from pay_action_information pai_dup,
		               pay_assignment_actions paa_dup
                         where pai.action_information_category =  pai_dup.action_information_category
		           and pai.rowid                       <> pai_dup.rowid
		           and paa_dup.payroll_action_id       =  ppa.payroll_action_id
		           and paa_dup.assignment_action_id    =  pai_dup.action_context_id
	                   and pai.action_information1         =  pai_dup.action_information1
     	                  and  pai_dup.action_context_type     = 'AAC'  )
        order by sort asc,department asc, hire_date desc;
       ----------------------------------
       --   New_Employees cursor
       --   Bug#3153476  Modified the 'sort parameter'.
       --   Now cursor passes SORT=1 for employee with permit type 'WP' or 'EP'.
       --   Bug#3298317   Added one more parameter 'permit_type' to function call 'get_balance_value'.
       --                 Rounding the cpf balannces so there are no rounding discrepancies
       --                 between AV1 and sum of AV2 in the file.
       --   Bug: 3619297 - Modified the inner queries added checks on action_context_type.
       ----------------------------------
       cursor  new_employees is
       select  'DEPARTMENT=P',
               pai.action_information22 department,
               'ASSIGNMENT_ACTION_ID=C',
               paa.assignment_action_id,
               'TAX_UNIT_ID=C',
               paa.tax_unit_id,
               'DATE_EARNED=C',
               pai.action_information20 date_earned,
               'ASSIGNMENT_ID=C',
               paa.assignment_id,
               'SORT=P',
               decode(pai.action_information1,null,'1',(decode(pai.action_information21,'WP','1',(decode(pai.action_information21,'EP','1',(decode(pai.action_information21,'SP','1','0'))))))) sort,
               pai.action_information3  hire_date,
               'VOL_CPF_LIAB=P',
               to_char(to_number(pai.action_information4))||'#'|| to_char(to_number(pai.action_information4))    vol_cpf_liab,
               'CPF_LIAB=P',
               to_char(to_number(pai.action_information6))||'#'|| to_char(to_number(pai.action_information6))    cpf_liab,
               'VOL_CPF_WITHHELD=P',
               to_char(to_number(pai.action_information5))||'#'|| to_char(to_number(pai.action_information5))    vol_cpf_withheld,
               'CPF_WITHHELD=P',
               to_char(to_number(pai.action_information7))||'#'|| to_char(to_number(pai.action_information7))    cpf_withheld,
               'MBMF_WITHHELD=P',
               pai.action_information8||'#'||pai.action_information8    mbmf_withheld,
               'SINDA_WITHHELD=P',
               pai.action_information9||'#'||pai.action_information9    sinda_withheld,
               'CDAC_WITHHELD=P',
               pai.action_information10||'#'||pai.action_information10  cdac_withheld,
               'ECF_WITHHELD=P',
               pai.action_information11||'#'||pai.action_information11  ecf_withheld,
               'CPF_ORD_ELIG_COMP=P',
               pai.action_information12||'#'||pai.action_information12  cpf_ord_elig_comp,
               'CPF_ADD_ELIG_COMP=P',
               pai.action_information13||'#'||pai.action_information13  cpf_add_elig_comp ,
               'LEGAL_NAME=P',
               pai.action_information17||'#'||pai.action_information17  legal_name,
               'EMPLOYEE_NUMBER=P',
               pai.action_information18||'#'||pai.action_information18  employee_number,
               'EMP_TERMINATION_DATE=P',
               nvl(to_char(fnd_date.canonical_to_date(pai.action_information19),'dd/mm/yyyy'),'01/01/1900')  emp_termination_date
         from  pay_payroll_actions      ppa,
               pay_assignment_actions   paa,
               pay_action_information   pai
        where  ppa.payroll_action_id            = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
          and  ppa.payroll_action_id            = paa.payroll_action_id
          and  paa.assignment_action_id         = pai.action_context_id
          and  pai.action_information_category  = 'SG CPF DETAILS'
          and  pai.action_context_type          = 'AAC'
          and  pai.action_information2          = 'NEW'
          and  not exists ( select  1
		              from pay_action_information pai_dup,
		                   pay_assignment_actions paa_dup
                             where pai.action_information_category =  pai_dup.action_information_category
                               and pai.rowid                       <> pai_dup.rowid
		               and paa_dup.payroll_action_id       =  ppa.payroll_action_id
		               and paa_dup.assignment_action_id    =  pai_dup.action_context_id
	                       and pai.action_information1         =  pai_dup.action_information1
                               and pai_dup.action_context_type     = 'AAC'    )
       union all
       select  'DEPARTMENT=P',
               pai.action_information22 department,
               'ASSIGNMENT_ACTION_ID=C',
               paa.assignment_action_id,
               'TAX_UNIT_ID=C',
               paa.tax_unit_id,
               'DATE_EARNED=C',
               pai.action_information20 date_earned,
               'ASSIGNMENT_ID=C',
               paa.assignment_id,
               'SORT=P',
               decode(pai.action_information1,null,'1',(decode(pai.action_information21,'WP','1',(decode(pai.action_information21,'EP','1',(decode(pai.action_information21,'SP','1','0'))))))) sort,
               pai.action_information3  hire_date,
               'VOL_CPF_LIAB=P',
               pay_sg_cpfline_balances.get_balance_value( 'NEW',
                                                  paa.assignment_id,
                                                  nvl(pai.action_information1,pai.source_id),
                                                  pai.action_information22,
	                                          paa.assignment_action_id,
                                                  paa.tax_unit_id,
                                                  'Voluntary CPF Liability',
                                                  pai.action_information4,
                                                  ppa.payroll_action_id,
						  pai.action_information21
                                               )  vol_cpf_liab,
               'CPF_LIAB=P',
               pay_sg_cpfline_balances.get_balance_value( 'NEW',
                                                 paa.assignment_id,
                                                 nvl(pai.action_information1,pai.source_id),
                                                 pai.action_information22,
	                                         paa.assignment_action_id,
                                                 paa.tax_unit_id,
                                                 'CPF Liability',
                                                 pai.action_information6,
	                                         ppa.payroll_action_id,
						 pai.action_information21
					       ) cpf_liab,
               'VOL_CPF_WITHHELD=P',
               pay_sg_cpfline_balances.get_balance_value( 'NEW',
                                                 paa.assignment_id,
                                                 nvl(pai.action_information1,pai.source_id),
                                                 pai.action_information22,
                                                 paa.assignment_action_id,
                                                 paa.tax_unit_id,
                                                 'Voluntary CPF Withheld',
                                                 pai.action_information5,
                                                 ppa.payroll_action_id,
						 pai.action_information21
                                               ) vol_cpf_withheld,
               'CPF_WITHHELD=P',
               pay_sg_cpfline_balances.get_balance_value( 'NEW',
                                                 paa.assignment_id,
                                                 nvl(pai.action_information1,pai.source_id),
                                                 pai.action_information22,
                                                 paa.assignment_action_id,
                                                 paa.tax_unit_id,
                                                 'CPF Withheld',
                                                 pai.action_information7,
	                                         ppa.payroll_action_id,
						 pai.action_information21
					       ) cpf_withheld,
               'MBMF_WITHHELD=P',
               pay_sg_cpfline_balances.get_balance_value( 'NEW',
                                                 paa.assignment_id,
                                                 nvl(pai.action_information1,pai.source_id),
                                                 pai.action_information22,
                                                 paa.assignment_action_id,
                                                 paa.tax_unit_id,
                                                 'MBMF Withheld',
                                                 pai.action_information8,
	                                         ppa.payroll_action_id,
						 pai.action_information21
                                               ) mbmf_withheld,
               'SINDA_WITHHELD=P',
               pay_sg_cpfline_balances.get_balance_value( 'NEW',
                                                 paa.assignment_id,
                                                 nvl(pai.action_information1,pai.source_id),
                                                 pai.action_information22,
                                                 paa.assignment_action_id,
                                                 paa.tax_unit_id,
                                                 'SINDA Withheld',
                                                 pai.action_information9,
                                                 ppa.payroll_action_id,
						 pai.action_information21
                                               ) sinda_withheld,
               'CDAC_WITHHELD=P',
               pay_sg_cpfline_balances.get_balance_value( 'NEW',
                                                 paa.assignment_id,
                                                 nvl(pai.action_information1,pai.source_id),
                                                 pai.action_information22,
                                                 paa.assignment_action_id,
                                                 paa.tax_unit_id,
                                                 'CDAC Withheld',
                                                 pai.action_information10,
                                                 ppa.payroll_action_id,
						 pai.action_information21
                                               ) cdac_withheld,
               'ECF_WITHHELD=P',
               pay_sg_cpfline_balances.get_balance_value( 'NEW',
                                                 paa.assignment_id,
                                                 nvl(pai.action_information1,pai.source_id),
                                                 pai.action_information22,
                                                 paa.assignment_action_id,
                                                 paa.tax_unit_id,
                                                 'ECF Withheld',
                                                 pai.action_information11,
	                                         ppa.payroll_action_id,
						 pai.action_information21
                                               ) ecf_withheld,
               'CPF_ORD_ELIG_COMP=P',
               pay_sg_cpfline_balances.get_balance_value( 'NEW',
                                                 paa.assignment_id,
                                                 nvl(pai.action_information1,pai.source_id),
                                                 pai.action_information22,
                                                 paa.assignment_action_id,
                                                 paa.tax_unit_id,
                                                 'CPF Ordinary Earnings Eligible Comp',
                                                 pai.action_information12,
                                                 ppa.payroll_action_id,
						 pai.action_information21
                                               ) cpf_ord_elig_comp,
               'CPF_ADD_ELIG_COMP=P',
               pay_sg_cpfline_balances.get_balance_value( 'NEW',
                                                 paa.assignment_id,
                                                 nvl(pai.action_information1,pai.source_id),
                                                 pai.action_information22,
                                                 paa.assignment_action_id,
                                                 paa.tax_unit_id,
                                                 'CPF Additional Earnings Eligible Comp',
                                                 pai.action_information13,
                                                 ppa.payroll_action_id,
						 pai.action_information21
                                               ) cpf_add_elig_comp ,
               'LEGAL_NAME=P',
               pay_sg_cpfline_balances.get_balance_value( 'NEW',
                                                 paa.assignment_id,
                                                 nvl(pai.action_information1,pai.source_id),
                                                 pai.action_information22,
                                                 paa.assignment_action_id,
                                                 paa.tax_unit_id,
                                                 'Legal_Name',
                                                 pai.action_information17,
                                                 ppa.payroll_action_id,
						 pai.action_information21
                                               ) legal_name,
               'EMPLOYEE_NUMBER=P',
               pay_sg_cpfline_balances.get_balance_value(  'NEW',
                                                  paa.assignment_id,
                                                  nvl(pai.action_information1,pai.source_id),
                                                  pai.action_information22,
                                                  paa.assignment_action_id,
                                                  paa.tax_unit_id,
                                                  'Employee_Number',
                                                  pai.action_information18,
                                                  ppa.payroll_action_id,
						  pai.action_information21
                                               )  employee_number,
               'EMP_TERMINATION_DATE=P',
               pay_sg_cpfline_balances.get_balance_value( 'NEW',
                                                 paa.assignment_id,
                                                 nvl(pai.action_information1,pai.source_id),
                                                 pai.action_information22,
                                                 paa.assignment_action_id,
                                                 paa.tax_unit_id,
                                                 'Emp_Term_Date',
                                                 pai.action_information19,
                                                 ppa.payroll_action_id,
						 pai.action_information21
                                               ) emp_termination_date
         from  pay_payroll_actions      ppa,
               pay_assignment_actions   paa,
               pay_action_information   pai
        where  ppa.payroll_action_id            = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
          and  ppa.payroll_action_id            = paa.payroll_action_id
          and  paa.assignment_action_id         = pai.action_context_id
          and  pai.action_information_category  = 'SG CPF DETAILS'
          and  pai.action_context_type          = 'AAC'
          and  pai.action_information2          = 'NEW'
          and  exists ( select  1
		          from  pay_action_information pai_dup,
		                pay_assignment_actions paa_dup
                         where  pai.action_information_category =  pai_dup.action_information_category
		           and  pai.rowid                       <> pai_dup.rowid
		           and  paa_dup.payroll_action_id       =  ppa.payroll_action_id
		           and  paa_dup.assignment_action_id    =  pai_dup.action_context_id
	                   and  pai.action_information1         =  pai_dup.action_information1
                           and  pai_dup.action_context_type     = 'AAC'   )
        order by sort asc,department asc, hire_date desc;

       ----------------------------------------------------------
       --   Bug: 3619297 - Used lookup SG_CPFLINE_COMM_FUNDS
       --   instead of using dual table to sort the rows.
       ----------------------------------------------------------
      cursor  er_service_employees is
        select 'EMPLOYER_SERVICE=P',
               hl.meaning employer_service,
               'LEGAL_NAME=P',
               pai.action_information17 legal_name,
               'VALUE=P',
               sum(decode(hl.meaning,'SDL', pai.action_information15,
                   'MBMF Fund', pai.action_information8,
                   'SINDA Fund', pai.action_information9,
                   'CDAC Fund', pai.action_information10,
                   'ECF Fund', pai.action_information11,
                   'FWL', pai.action_information16,
                   'SHARE Program Donations', pai.action_information14)) value
         from  pay_payroll_actions    ppa,
               pay_assignment_actions paa,
               pay_action_information pai,
               hr_lookups             hl
          where  ppa.payroll_action_id    = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
            and  ppa.payroll_action_id    = paa.payroll_action_id
            and  paa.assignment_action_id = pai.action_context_id
            and  pai.action_information_category = 'SG CPF DETAILS'
            and  pai.action_context_type         = 'AAC'
	    and  hl.lookup_type = 'SG_CPFLINE_COMM_FUNDS'
            and  decode(hl.meaning,'SDL', pai.action_information15,
                   'MBMF Fund', pai.action_information8,
                   'SINDA Fund', pai.action_information9,
                   'CDAC Fund', pai.action_information10,
                   'ECF Fund', pai.action_information11,
                   'FWL', pai.action_information16,
                   'SHARE Program Donations', pai.action_information14) <> 0
          group by hl.meaning,hl.lookup_code, pai.action_information17, nvl(pai.action_information1,pai.source_id)
          order by hl.lookup_code, pai.action_information17;


end pay_sg_cpfline;

/
