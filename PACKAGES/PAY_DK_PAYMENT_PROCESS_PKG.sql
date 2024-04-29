--------------------------------------------------------
--  DDL for Package PAY_DK_PAYMENT_PROCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DK_PAYMENT_PROCESS_PKG" AUTHID CURRENT_USER as
/* $Header: pydkpaypr.pkh 120.16.12010000.9 2010/03/05 11:37:59 rsahai ship $ */

level_cnt NUMBER;
/* Added for bug fix 8501177 */
FUNCTION get_Assignment_Action (
      p_assignment_id   NUMBER
   )
      RETURN NUMBER;

FUNCTION get_defined_balance_id (
      p_dimension_name   VARCHAR2,
      p_balance_name     VARCHAR2
   )
      RETURN NUMBER;
/* Added for bug fix 8501177 */

FUNCTION get_parameter(
                 p_parameter_string  IN VARCHAR2
                ,p_token             IN VARCHAR2
                ,p_segment_number    IN NUMBER DEFAULT NULL )RETURN VARCHAR2;

FUNCTION get_lookup_meaning (p_lookup_type varchar2,p_lookup_code varchar2) RETURN VARCHAR2 ;


/* Added for Third Party Payments */
FUNCTION get_ass_action_context(p_assignment_id NUMBER) RETURN NUMBER;

FUNCTION get_date_earned_context(p_assignment_id NUMBER) RETURN DATE;

--FUNCTION get_prev_bal_paid(p_assignment_id NUMBER, p_balance_name VARCHAR2) RETURN NUMBER;
  /* Added p_org_id to function for pension changes */
FUNCTION get_prev_bal_paid(p_assignment_id NUMBER, p_org_id NUMBER, p_balance_name VARCHAR2) RETURN NUMBER;

FUNCTION get_phy_record_no(p_person_id NUMBER, p_assignment_id NUMBER, p_pp_id VARCHAR2) RETURN NUMBER;

/* Added for bug fix 4563148 */
FUNCTION check_numeric(p_text VARCHAR2) RETURN NUMBER;

/* Added during Holiday Pay plug-in and OS I10 enhancement */
/* Changed to return Varchar2 for bug */
FUNCTION get_pension_provider(p_org_name VARCHAR2) RETURN VARCHAR2;

FUNCTION get_ident_codes(p_bg_id               IN  NUMBER
                        ,p_effective_date      IN DATE
			,p_tax_rc              OUT NOCOPY VARCHAR2
			,p_amb_rc              OUT NOCOPY VARCHAR2
			,p_sp_rc               OUT NOCOPY VARCHAR2
			,p_hol_days_rc         OUT NOCOPY VARCHAR2) RETURN NUMBER;
/* Added to support multiple pensions for OSI02 for bug fix 5563150*/
FUNCTION get_pen_values(p_eff_date DATE,p_ele_type_id NUMBER, p_ee_id NUMBER, p_iv_name VARCHAR2) RETURN VARCHAR2;

/* Added to support override for Use of Holiday Card for transfer to Holiday Bank for bug fix 5533140*/
FUNCTION get_use_hol_card(p_payroll_action_id NUMBER,p_date_earned DATE ) RETURN VARCHAR2;

FUNCTION get_pay_period_per_year(p_payroll_action_id NUMBER,p_date_earned DATE ) RETURN NUMBER;




CURSOR get_ds_record_details IS
--9036229
SELECT  'CHECK_DIGIT_DS=P'
       ,  to_char(PAY_DK_PAYMENT_PROCESS_PKG.get_parameter(legislative_parameters,'CHECK_DIGIT_DS',null))
       , 'TRANSFER_DS_CVR_NO=P'
       ,  hoi2.org_information1
       , 'IDENTIFICATION_DELIVERY=P'
       ,  fnd_global.conc_request_id
       , 'TRANSFER_IDENTIFICATION_DS=P'
       ,  NVL(PAY_DK_PAYMENT_PROCESS_PKG.get_parameter(legislative_parameters,'IDENTIFICATION_DS',null),' ')
       , 'TRANSFER_PAYROLL_NAME=P'
       ,  pap.PAYROLL_NAME
       , 'CONSOLIDATION_NAME=P'
       ,  pcs.consolidation_set_name
       , 'START_DATE=P'
       ,  to_char(ppa.start_date,'YYYYMMDD')
       , 'END_DATE=P'
       ,  to_char(ppa.effective_date,'YYYYMMDD')
       , 'PAYMENT_METHOD=P'
       ,  pop.org_payment_method_name
       , 'DS_NAME=P'
       ,  hou.name
       , 'TRANSFER_PAYER_REG_NO=P'
       ,  pea.segment1
       , 'TRANSFER_PAYER_ACCT_NO=P'
       ,  pea.segment3
FROM    hr_organization_units		hou
      , hr_organization_information	hoi1
      , hr_organization_information	hoi2
      , pay_payroll_actions		ppa
      , pay_consolidation_sets      pcs
      , pay_all_payrolls_f		pap
      , pay_payment_types		ppt
      , pay_external_accounts		pea
      , pay_org_payment_methods_f	pop
	, PAY_ORG_PAY_METHOD_USAGES_F popmu  --9036229
WHERE ppa.payroll_action_id = pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
AND pap.payroll_id = ppa.payroll_id
AND pap.payroll_id = nvl(APPS.PAY_DK_PAYMENT_PROCESS_PKG.get_parameter(legislative_parameters,'PAYROLL_ID',null), pap.payroll_id)  --9036229
AND pcs.consolidation_set_id = pap.consolidation_set_id
AND pop.org_payment_method_id = nvl(PAY_DK_PAYMENT_PROCESS_PKG.get_parameter(legislative_parameters,'PAYMENT_METHOD_ID',null), pop.org_payment_method_id)
AND pop.external_account_id   = pea.external_account_id
AND hou.business_group_id = ppa.business_group_id
AND hoi1.organization_id = hou.organization_id
AND hou.organization_id = nvl(PAY_DK_PAYMENT_PROCESS_PKG.get_parameter(legislative_parameters,'DS_NAME',null),hou.organization_id)
AND hoi1.org_information_context='CLASS'
AND hoi1.org_information1 = nvl2(PAY_DK_PAYMENT_PROCESS_PKG.get_parameter(legislative_parameters,'DS_NAME',null),'HR_LEGAL_EMPLOYER','DK_SERVICE_PROVIDER' )
AND hoi1.org_information2 ='Y'
AND hoi2.org_information_context=nvl2(PAY_DK_PAYMENT_PROCESS_PKG.get_parameter(legislative_parameters,'DS_NAME',null),'DK_LEGAL_ENTITY_DETAILS','DK_SERVICE_PROVIDER_DETAILS')
AND hoi2.organization_id =  hoi1.organization_id
AND ppa.effective_date BETWEEN hou.date_from AND nvl(hou.date_to, ppa.effective_date)
AND ppa.effective_date BETWEEN pap.effective_start_date AND pap.effective_end_date
AND ppt.payment_type_id = PAY_DK_PAYMENT_PROCESS_PKG.get_parameter(legislative_parameters,'PT_ID')
AND ppt.payment_type_id = pop.payment_type_id
AND pop.business_group_id = ppa.business_group_id
AND pop.defined_balance_id is not null
--9036229
AND popmu.payroll_id = pap.payroll_id
AND popmu.org_payment_method_id = pop.org_payment_method_id
AND ppa.effective_date BETWEEN popmu.effective_start_date AND popmu.effective_end_date
--9036229
AND ppa.effective_date BETWEEN pop.effective_start_date AND pop.effective_end_date;
--9036229

/*  ----9036229
SELECT   'CHECK_DIGIT_DS=P'
       ,  to_char(PAY_DK_PAYMENT_PROCESS_PKG.get_parameter(legislative_parameters,'CHECK_DIGIT_DS',null))
       , 'TRANSFER_DS_CVR_NO=P'
       ,  hoi2.org_information1
       , 'IDENTIFICATION_DELIVERY=P'
       ,  fnd_global.conc_request_id
       , 'TRANSFER_IDENTIFICATION_DS=P'
       ,  PAY_DK_PAYMENT_PROCESS_PKG.get_parameter(legislative_parameters,'IDENTIFICATION_DS',null)
       , 'TRANSFER_PAYROLL_NAME=P'
       ,  pap.PAYROLL_NAME
       , 'CONSOLIDATION_NAME=P'
       ,  pcs.consolidation_set_name
       , 'START_DATE=P'
       ,  to_char(ppa.start_date,'YYYYMMDD')
       , 'END_DATE=P'
       ,  to_char(ppa.effective_date,'YYYYMMDD')
       , 'PAYMENT_METHOD=P'
       ,  pop.org_payment_method_name
       , 'DS_NAME=P'
       ,  hou.name
       , 'TRANSFER_PAYER_REG_NO=P'
       ,  pea.segment1
       , 'TRANSFER_PAYER_ACCT_NO=P'
       ,  pea.segment3
FROM    hr_organization_units		hou
      , hr_organization_information	hoi1
      , hr_organization_information	hoi2
      , pay_payroll_actions		ppa
      , pay_consolidation_sets          pcs
      , pay_all_payrolls_f		pap
      , pay_external_accounts		pea
      , pay_org_payment_methods_f	pop
WHERE ppa.payroll_action_id = pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
AND pap.payroll_id = ppa.payroll_id
AND pcs.consolidation_set_id = pap.consolidation_set_id
AND pop.org_payment_method_id = ppa.org_payment_method_id
AND pop.external_account_id   = pea.external_account_id
AND hou.business_group_id = ppa.business_group_id
AND hoi1.organization_id = hou.organization_id
AND hou.organization_id = nvl(PAY_DK_PAYMENT_PROCESS_PKG.get_parameter(legislative_parameters,'DS_NAME',null),hou.organization_id)
AND hoi1.org_information_context='CLASS'
AND hoi1.org_information1 = nvl2(PAY_DK_PAYMENT_PROCESS_PKG.get_parameter(legislative_parameters,'DS_NAME',null),'HR_LEGAL_EMPLOYER','DK_SERVICE_PROVIDER' )
AND hoi1.org_information2 ='Y'
AND hoi2.org_information_context=nvl2(PAY_DK_PAYMENT_PROCESS_PKG.get_parameter(legislative_parameters,'DS_NAME',null),'DK_LEGAL_ENTITY_DETAILS','DK_SERVICE_PROVIDER_DETAILS')
AND hoi2.organization_id =  hoi1.organization_id
AND ppa.effective_date BETWEEN hou.date_from AND nvl(hou.date_to, ppa.effective_date)
AND ppa.effective_date BETWEEN pap.effective_start_date AND pap.effective_end_date;
*/  ----9036229


/* Added context for PAYROLL_ACTION_ID for enh 6344939 */
CURSOR get_section_record_details IS
SELECT   'TRANSFER_DISPOSAL_DATE=P'
       , to_char(fnd_date.canonical_to_date(PAY_DK_PAYMENT_PROCESS_PKG.get_parameter(legislative_parameters,'PAYMENT_DD',null)),'DDMMYY')
       , 'TRANSFER_PAYER_CVR_NO=P'
       , hoi2.org_information1
       , 'TRANSFER_LE_ID=P'
       , to_char(hou.ORGANIZATION_ID)
       , 'PAYROLL_ACTION_ID=C'
       ,  'TRANSFER_TYPE=P'		--9036229
       ,  '20' "type"			--9036229
       , pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
FROM       pay_payroll_actions		ppa
       , hr_organization_units		hou
       , hr_organization_information	hoi1
       , hr_organization_information	hoi2
WHERE ppa.payroll_action_id = pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
AND hou.business_group_id =  ppa.business_group_id
AND hoi1.organization_id = hou.organization_id
AND hoi1.org_information_context='CLASS'
AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
AND hoi1.org_information2 = 'Y'
AND hoi2.org_information_context='DK_LEGAL_ENTITY_DETAILS'
AND hoi2.organization_id =  hoi1.organization_id
AND nvl(hoi2.org_information1,0)= nvl2(PAY_DK_PAYMENT_PROCESS_PKG.get_parameter(legislative_parameters,'DS_NAME',null),pay_magtape_generic.get_parameter_value('TRANSFER_DS_CVR_NO') ,nvl(hoi2.org_information1,0))
AND ppa.effective_date BETWEEN hou.date_from AND nvl(hou.date_to, ppa.effective_date);

CURSOR get_transfer_record_details IS
SELECT   'PAYEE_REG_NO=P'
	, pea.segment1
	, 'PAYEE_ACCT_NO=P'
	, pea.segment3
	, 'PAYEE_AMOUNT=P'
	, to_char(ppp.value*100)
	, 'IDENTIFICATION_PAYEE=P'
	, substr(to_char(pap.national_identifier),1,instr(to_char(pap.national_identifier),'-')-1) ||substr(to_char(pap.national_identifier),instr(to_char(pap.national_identifier),'-')+1)--to_char(pap.national_identifier)
	, 'FULL_NAME=P'
	, pap.full_name
FROM per_all_assignments_f		paf
   , per_all_people_f			pap
   , hr_soft_coding_keyflex		scl
   , pay_payroll_actions		ppa
   , pay_assignment_actions		paa
   , pay_pre_payments			ppp
   , pay_external_accounts		pea
   , pay_personal_payment_methods_f	ppm
   , PAY_ORG_PAYMENT_METHODS_f pop  --9036229
WHERE ppa.payroll_action_id =  pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
AND paf.business_group_id = ppa.business_group_id
AND paf.payroll_id = ppa.PAYROLL_ID
AND pap.per_information_category ='DK'
AND paf.person_id = pap.person_id
AND paf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
AND ppa.effective_date  between  paf.effective_start_date  AND paf.effective_end_date
AND ppa.effective_date  between  pap.effective_start_date  AND pap.effective_end_date
AND scl.enabled_flag = 'Y'
AND scl.segment1 = pay_magtape_generic.get_parameter_value('TRANSFER_LE_ID')
AND    paa.payroll_action_id = ppa.payroll_action_id
AND    ppp.pre_payment_id  = paa.pre_payment_id
AND    paa.assignment_id = paf.assignment_id
AND    ppm.personal_payment_method_id  = ppp.personal_payment_method_id
AND    ppp.value > 0
AND ppm.external_account_id   = pea.external_account_id
AND ppa.effective_date  BETWEEN  ppm.effective_start_date  AND ppm.effective_end_date
--9036229
AND pop.org_payment_method_id = ppm.org_payment_method_id
AND pop.business_group_id = ppa.business_group_id
AND pop.defined_balance_id is not null;


--9036229
CURSOR get_section_rp_details IS
SELECT   'TRANSFER_DISPOSAL_DATE=P'
       , to_char(fnd_date.canonical_to_date(PAY_DK_PAYMENT_PROCESS_PKG.get_parameter(legislative_parameters,'PAYMENT_DD',null)),'DDMMYY')
       , 'TRANSFER_PAYER_CVR_NO=P'
       , hoi2.org_information1
       , 'TRANSFER_LE_ID=P'
       , to_char(hou.ORGANIZATION_ID)
       , 'PAYROLL_ACTION_ID=C'
       , pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
       ,  'TRANSFER_TYPE=P'
       ,  '90' "type"
FROM       pay_payroll_actions		ppa
       , hr_organization_units		hou
       , hr_organization_information	hoi1
       , hr_organization_information	hoi2
WHERE ppa.payroll_action_id = pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
AND hou.business_group_id =  ppa.business_group_id
AND hoi1.organization_id = hou.organization_id
AND hoi1.org_information_context='CLASS'
AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
AND hoi1.org_information2 = 'Y'
AND hoi2.org_information_context='DK_LEGAL_ENTITY_DETAILS'
AND hoi2.organization_id =  hoi1.organization_id
AND nvl(hoi2.org_information1,0)= nvl2(PAY_DK_PAYMENT_PROCESS_PKG.get_parameter(legislative_parameters,'DS_NAME',null),pay_magtape_generic.get_parameter_value('TRANSFER_DS_CVR_NO') ,nvl(hoi2.org_information1,0))
AND ppa.effective_date BETWEEN hou.date_from AND nvl(hou.date_to, ppa.effective_date)
AND hou.ORGANIZATION_ID = pay_magtape_generic.get_parameter_value('TRANSFER_LE_ID'); --9036229

CURSOR get_transfer_rp_record_details IS
SELECT   'PAYEE_REG_NO=P'
	, pea.segment1
	, 'PAYEE_ACCT_NO=P'
	, pea.segment3
	, 'PAYEE_AMOUNT=P'
	, to_char(SUM(ppp.value*100))
	, 'IDENTIFICATION_PAYEE=P'
	, substr(to_char(pap.national_identifier),1,instr(to_char(pap.national_identifier),'-')-1) ||substr(to_char(pap.national_identifier),instr(to_char(pap.national_identifier),'-')+1)--to_char(pap.national_identifier)
	, 'FULL_NAME=P'
	, pap.full_name
FROM per_all_assignments_f		paf
   , per_all_people_f			pap
   , hr_soft_coding_keyflex		scl
   , pay_payroll_actions		ppa
   , pay_assignment_actions		paa
   , pay_pre_payments			ppp
   , pay_external_accounts		pea
   , pay_personal_payment_methods_f	ppm
   , PAY_ORG_PAYMENT_METHODS_f pop  --9036229
WHERE ppa.payroll_action_id =  pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
AND paf.business_group_id = ppa.business_group_id
AND paf.payroll_id = ppa.PAYROLL_ID
AND pap.per_information_category ='DK'
AND paf.person_id = pap.person_id
AND paf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
AND ppa.effective_date  between  paf.effective_start_date  AND paf.effective_end_date
AND ppa.effective_date  between  pap.effective_start_date  AND pap.effective_end_date
AND scl.enabled_flag = 'Y'
AND scl.segment1 = pay_magtape_generic.get_parameter_value('TRANSFER_LE_ID')
AND    paa.payroll_action_id = ppa.payroll_action_id
AND    ppp.pre_payment_id  = paa.pre_payment_id
AND    paa.assignment_id = paf.assignment_id
AND    ppm.personal_payment_method_id  = ppp.personal_payment_method_id
AND    ppp.value > 0
AND ppm.external_account_id   = pea.external_account_id
AND ppa.effective_date  BETWEEN  ppm.effective_start_date  AND ppm.effective_end_date
AND pop.org_payment_method_id = ppm.org_payment_method_id
AND pop.business_group_id = ppa.business_group_id
AND pop.defined_balance_id is null
GROUP BY
'PAYEE_REG_NO=P'
	, pea.segment1
	, 'PAYEE_ACCT_NO=P'
	, pea.segment3
	, 'PAYEE_AMOUNT=P'
	, 'IDENTIFICATION_PAYEE=P'
	, substr(to_char(pap.national_identifier),1,instr(to_char(pap.national_identifier),'-')-1) ||substr(to_char(pap.national_identifier),instr(to_char(pap.national_identifier),'-')+1)--to_char(pap.national_identifier)
	, 'FULL_NAME=P'
	, pap.full_name;
--9036229


/* Added the following for Third Party Payments */

CURSOR get_info_record_details IS
SELECT  'TRANSFER_INFO_TYPE=P'
       , puci.value
       , 'TRANSFER_INFO_DISPOSAL_DATE=P'
       , to_char(fnd_date.canonical_to_date(PAY_DK_PAYMENT_PROCESS_PKG.get_parameter(legislative_parameters,'INFOTYPE'||puci.value||'_DD',null)),'DDMMYY')
       , 'TRANSFER_PBS_NO=P'
       , puci1.value
       , 'TRANSFER_RECEIVER_NAME=P'
       , pur.row_low_range_or_name
FROM     pay_payroll_actions		ppa
       , pay_user_tables		put
       , pay_user_columns		puc
       , pay_user_column_instances_f	puci
       , pay_user_rows_f		pur
       , pay_user_columns puc1
       , pay_user_column_instances_f puci1
       , pay_user_rows_f pur1
WHERE ppa.payroll_action_id = pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
AND put.user_table_name = 'DK_PBS_DATA'
AND put.LEGISLATION_CODE ='DK'
AND puc.user_table_id = put.user_table_id
AND puc.user_column_name =  'Information Type'
AND puci.user_column_id = puc.user_column_id
AND ppa.effective_date between puci.effective_start_date and puci.effective_end_date
AND pur.user_row_id = puci.user_row_id
AND ppa.effective_date between pur.effective_start_date and pur.effective_end_date
and puc1.user_table_id = put.user_table_id
and puc1.user_column_name = 'PBS Number'
and puci1.user_column_id = puc1.user_column_id
/* Added for bug fix 5071004 */
and puci1.business_group_id =ppa.business_group_id
and ppa.effective_date between puci1.effective_start_date and puci1.effective_end_date
and pur1.user_row_id = puci1.user_row_id
and pur1.user_row_id = pur.user_row_id
and ppa.effective_date  between pur1.effective_start_date and pur1.effective_end_date
UNION
SELECT  'TRANSFER_INFO_TYPE=P'
       , hoi2.ORG_INFORMATION2
       , 'TRANSFER_INFO_DISPOSAL_DATE=P'
       , to_char(fnd_date.canonical_to_date(PAY_DK_PAYMENT_PROCESS_PKG.get_parameter(legislative_parameters,'INFOTYPE_PENSION_DD',null)),'DDMMYY')
       , 'TRANSFER_PBS_NO=P'
       , hoi2.ORG_INFORMATION1
       , 'TRANSFER_RECEIVER_NAME=P'
       , hou.name
FROM     pay_payroll_actions		ppa
       , hr_organization_units		hou
       , hr_organization_information	hoi1
       , hr_organization_information	hoi2
WHERE ppa.payroll_action_id = pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
AND hou.business_group_id =  ppa.business_group_id
AND hoi1.organization_id = hou.organization_id
AND hoi1.org_information_context='CLASS'
AND hoi1.org_information1 = 'DK_PENSION_PROVIDER'
AND hoi1.org_information2 = 'Y'
AND hoi2.org_information_context='DK_PENSION_PROVIDER_DETAILS'
AND hoi2.organization_id =  hoi1.organization_id
AND ppa.effective_date BETWEEN hou.date_from AND nvl(hou.date_to, ppa.effective_date);


/* Modified for bug fix 4551283 to change FULL_NAME to Employer's name*/
/* Modified for bug fix 4554812 to filter on pension provider */
/* Modified for bug fix 5887000 for PAYMENT_END_DATE */
/* Modified for pension changes , also added UNION */
CURSOR get_info_record_00_details IS
SELECT    'IDENTIFICATION_PAYEE=P'
	,  substr(to_char(pap.national_identifier),1,instr(to_char(pap.national_identifier),'-')-1) ||substr(to_char(pap.national_identifier),instr(to_char(pap.national_identifier),'-')+1)--to_char(pap.national_identifier)
	, 'FULL_NAME=P'
	,  pap.full_name
	, 'PAYMENT_START_DATE=P'
	,  to_char(ppa.START_DATE,'YYYYMMDD')
	, 'PAYMENT_END_DATE=P'
	,  to_char(PAY_DK_PAYMENT_PROCESS_PKG.get_date_earned_context(paa.ASSIGNMENT_ID),'YYYYMMDD')
	, 'ASSIGNMENT_ACTION_ID=C'
        , PAY_DK_PAYMENT_PROCESS_PKG.get_ass_action_context(paa.ASSIGNMENT_ID)
	, 'TRANSFER_ASSIGNMENT_ID=P'
	, paa.ASSIGNMENT_ID
	, 'TRANSFER_TERMINATION_DATE=P'
	/* Re-written to obtain correct dates*/
        /*, to_char(fnd_date.canonical_to_date(nvl(scl.segment8,pap.effective_end_date)),'YYYYMMDD')*/
	, to_char(decode(scl.segment8,null,pap.effective_end_date,fnd_date.canonical_to_date(scl.segment8)),'YYYYMMDD')
	, 'TRANSFER_PERSON_ID=P'
	, to_char(pap.person_id)
	, 'TRANSFER_EMPLOYMENT_CATEGORY=P'
	, paf.employment_category
	, 'PHYS_RECO_NO=P'
	, to_char(PAY_DK_PAYMENT_PROCESS_PKG.get_phy_record_no(pap.person_id, paf.assignment_id,peev.screen_entry_value))
	/* Added for Holiday pay plug-in and OS I 10 enhancement */
	, 'EFFECTIVE_DATE=P'
	, to_char(ppa.effective_date)
	, 'BUSINESS_GROUP_ID=P'
	, to_char(ppa.business_group_id)
        , 'PAYROLL_ACTION_ID=C'
        , pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
        , 'ORGANIZATION_ID=C'
        , peev.screen_entry_value
        , 'TRANSFER_ORGANIZATION_ID=P'
        , peev.screen_entry_value
	/* Added for bug fix 5533140 */
        , 'ASSIGNMENT_ID=C'
        , paa.ASSIGNMENT_ID
        , 'DATE_EARNED=C'
        , fnd_date.date_to_canonical(PAY_DK_PAYMENT_PROCESS_PKG.get_date_earned_context(paa.ASSIGNMENT_ID))
FROM per_all_assignments_f		paf
   , per_all_people_f			pap
   , hr_soft_coding_keyflex		scl
   , pay_payroll_actions		ppa
   , pay_assignment_actions		paa
   , pay_pre_payments			ppp
   , pay_external_accounts		pea
   , pay_personal_payment_methods_f	ppm
   /* Added join for bug fix 4554812 */
   /* Removed and re-wrote in function get_pension_provider */
   /*, hr_organization_units		hou */
   /* Added for Pension changes */
   ,pay_element_entries_f		peef
   ,pay_element_types_f			petf
   ,pay_input_values_f			pivf
   ,pay_element_entry_values_f		peev
   ,per_assignment_status_types past   -- 8501177
WHERE ppa.payroll_action_id =  pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
AND paf.business_group_id = ppa.business_group_id
AND paf.payroll_id = ppa.payroll_id
AND pap.per_information_category ='DK'
AND paf.person_id = pap.person_id
AND paf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
AND ppa.effective_date  between  paf.effective_start_date  AND paf.effective_end_date
AND ppa.effective_date  between  pap.effective_start_date  AND pap.effective_end_date
AND scl.enabled_flag = 'Y'
AND scl.segment1 = pay_magtape_generic.get_parameter_value('TRANSFER_LE_ID')
/* Added for bug fix 4554812 */
/* Removed and re-wrote in function get_pension_provider */
/*AND hou.name = pay_magtape_generic.get_parameter_value('TRANSFER_RECEIVER_NAME')*/
/* Removed and re-written for pension changes to get pension provider */
/*AND nvl(scl.segment2,0) = decode(pay_magtape_generic.get_parameter_value('TRANSFER_INFO_TYPE')
                          , 300 , nvl(scl.segment2,0)
			  , 400 , nvl(scl.segment2,0)
			  , 800 , nvl(scl.segment2,0)
			  , 900 , nvl(scl.segment2,0)
			  , PAY_DK_PAYMENT_PROCESS_PKG.get_pension_provider(pay_magtape_generic.get_parameter_value('TRANSFER_RECEIVER_NAME')))--to_char(hou.organization_id))
*/
/* Added for Pension changes -start */
AND  pay_magtape_generic.get_parameter_value('TRANSFER_INFO_TYPE') NOT IN (300, 400, 800, 900)
AND  peef.assignment_id  = paf.assignment_id
AND  ppa.effective_date BETWEEN peef.effective_start_date AND peef.effective_end_date
AND  peef.element_type_id   = petf.element_type_id
AND  petf.legislation_code  ='DK'
AND  petf.element_name  =  'Pension'
AND  ppa.effective_date BETWEEN petf.effective_start_date AND petf.effective_end_date
AND  pivf.element_type_id   = petf.element_type_id
AND  pivf.input_value_id    = peev.input_value_id
AND  pivf.name= 'Third Party Payee'
AND  peev.element_entry_id = peef.element_entry_id
AND  peev.screen_entry_value = PAY_DK_PAYMENT_PROCESS_PKG.get_pension_provider(pay_magtape_generic.get_parameter_value('TRANSFER_RECEIVER_NAME'))
AND  ppa.effective_date BETWEEN pivf.effective_start_date AND pivf.effective_end_date
/* Added for Pension changes -end */
AND paa.payroll_action_id = ppa.payroll_action_id
AND ppp.pre_payment_id  = paa.pre_payment_id
AND paa.assignment_id = paf.assignment_id
AND ppm.personal_payment_method_id  = ppp.personal_payment_method_id
AND ppp.value > 0
AND ppm.external_account_id   = pea.external_account_id
AND ppa.effective_date  BETWEEN  ppm.effective_start_date  AND ppm.effective_end_date
AND paf.assignment_status_type_id = past.assignment_status_type_id
/* Added for bug fix 8501177 */
AND (past.per_system_status = 'ACTIVE_ASSIGN'
     OR

        (pay_balance_pkg.get_value (	PAY_DK_PAYMENT_PROCESS_PKG.get_defined_balance_id ('Payments', 'Pensionable Pay'),
				PAY_DK_PAYMENT_PROCESS_PKG.get_Assignment_Action(paa.ASSIGNMENT_ID),
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL
	)			)
        +
	(pay_balance_pkg.get_value (	PAY_DK_PAYMENT_PROCESS_PKG.get_defined_balance_id ('Payments', 'Pensionable Pay Adjustment'),
				PAY_DK_PAYMENT_PROCESS_PKG.get_Assignment_Action(paa.ASSIGNMENT_ID),
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL
				)
         )> 0
		 )
UNION
SELECT    'IDENTIFICATION_PAYEE=P'
	,  substr(to_char(pap.national_identifier),1,instr(to_char(pap.national_identifier),'-')-1) ||substr(to_char(pap.national_identifier),instr(to_char(pap.national_identifier),'-')+1)--to_char(pap.national_identifier)
	, 'FULL_NAME=P'
	,  pap.full_name
	, 'PAYMENT_START_DATE=P'
	,  to_char(ppa.START_DATE,'YYYYMMDD')
	, 'PAYMENT_END_DATE=P'
	,  to_char(PAY_DK_PAYMENT_PROCESS_PKG.get_date_earned_context(paa.ASSIGNMENT_ID),'YYYYMMDD')
	, 'ASSIGNMENT_ACTION_ID=C'
        , PAY_DK_PAYMENT_PROCESS_PKG.get_ass_action_context(paa.ASSIGNMENT_ID)
	, 'TRANSFER_ASSIGNMENT_ID=P'
	, paa.ASSIGNMENT_ID
	, 'TRANSFER_TERMINATION_DATE=P'
	/* Re-written to obtain correct dates*/
        /*, to_char(fnd_date.canonical_to_date(nvl(scl.segment8,pap.effective_end_date)),'YYYYMMDD')*/
	, to_char(decode(scl.segment8,null,pap.effective_end_date,fnd_date.canonical_to_date(scl.segment8)),'YYYYMMDD')
	, 'TRANSFER_PERSON_ID=P'
	, to_char(pap.person_id)
	, 'TRANSFER_EMPLOYMENT_CATEGORY=P'
	, paf.employment_category
	, 'PHYS_RECO_NO=P'
	, to_char(PAY_DK_PAYMENT_PROCESS_PKG.get_phy_record_no(pap.person_id, paf.assignment_id,null))
	/* Added for Holiday pay plug-in and OS I 10 enhancement */
	, 'EFFECTIVE_DATE=P'
	, to_char(ppa.effective_date)
	, 'BUSINESS_GROUP_ID=P'
	, to_char(ppa.business_group_id)
        , 'PAYROLL_ACTION_ID=C'
        , pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
        , 'ORGANIZATION_ID=C'
        , null
        , 'TRANSFER_ORGANIZATION_ID=P'
        , null
	/* Added for bug fix 5533140 */
        , 'ASSIGNMENT_ID=C'
        , paa.ASSIGNMENT_ID
        , 'DATE_EARNED=C'
        , fnd_date.date_to_canonical(PAY_DK_PAYMENT_PROCESS_PKG.get_date_earned_context(paa.ASSIGNMENT_ID))
FROM per_all_assignments_f		paf
   , per_all_people_f			pap
   , hr_soft_coding_keyflex		scl
   , pay_payroll_actions		ppa
   , pay_assignment_actions		paa
   , pay_pre_payments			ppp
   , pay_external_accounts		pea
   , pay_personal_payment_methods_f	ppm
   /* Added join for bug fix 4554812 */
   /* Removed and re-wrote in function get_pension_provider */
   /*, hr_organization_units		hou */
WHERE ppa.payroll_action_id =  pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
AND paf.business_group_id = ppa.business_group_id
AND paf.payroll_id = ppa.payroll_id
AND pap.per_information_category ='DK'
AND paf.person_id = pap.person_id
AND paf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
AND ppa.effective_date  between  paf.effective_start_date  AND paf.effective_end_date
AND ppa.effective_date  between  pap.effective_start_date  AND pap.effective_end_date
AND scl.enabled_flag = 'Y'
AND scl.segment1 = pay_magtape_generic.get_parameter_value('TRANSFER_LE_ID')
/* Added for bug fix 4554812 */
/* Removed and re-wrote in function get_pension_provider */
/*AND hou.name = pay_magtape_generic.get_parameter_value('TRANSFER_RECEIVER_NAME')*/
/* Removed and re-written for pension changes to get pension provider */
/*AND nvl(scl.segment2,0) = decode(pay_magtape_generic.get_parameter_value('TRANSFER_INFO_TYPE')
                          , 300 , nvl(scl.segment2,0)
			  , 400 , nvl(scl.segment2,0)
			  , 800 , nvl(scl.segment2,0)
			  , 900 , nvl(scl.segment2,0)
			  , PAY_DK_PAYMENT_PROCESS_PKG.get_pension_provider(pay_magtape_generic.get_parameter_value('TRANSFER_RECEIVER_NAME')))--to_char(hou.organization_id))
*/
/* Added for Pension changes -start */
AND  pay_magtape_generic.get_parameter_value('TRANSFER_INFO_TYPE') IN (300, 400, 800, 900)
/* Added for Pension changes -end */
AND paa.payroll_action_id = ppa.payroll_action_id
AND ppp.pre_payment_id  = paa.pre_payment_id
AND paa.assignment_id = paf.assignment_id
AND ppm.personal_payment_method_id  = ppp.personal_payment_method_id
AND ppp.value > 0
AND ppm.external_account_id   = pea.external_account_id
AND ppa.effective_date  BETWEEN  ppm.effective_start_date  AND ppm.effective_end_date;


/* Modified for bug fix 4551283 to change FULL_NAME to Employer's name*/
/* Modified for Pension changes */
CURSOR get_info_record_01_details IS
SELECT   'TRANSFER_PAY_APPL_DATE=P'
       , to_char(min(pee2.effective_start_date) ,'YYYYMMDD')
       , 'TRANSFER_PENSION_START_DATE=P'
       , to_char(pee1.effective_start_date ,'YYYYMMDD')
       , 'ASSIGNMENT_ID=C'
       , paa.ASSIGNMENT_ID
       , 'DATE_EARNED=C'
       , fnd_date.date_to_canonical(PAY_DK_PAYMENT_PROCESS_PKG.get_date_earned_context(paa.ASSIGNMENT_ID))
       , 'PAYROLL_ACTION_ID=C'
       , pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
       , 'FULL_NAME=P'
       , hou.name /*bug fix 4551283*/
FROM pay_payroll_actions		ppa
   , pay_assignment_actions		paa
   , pay_element_entries_f              pee1
   , pay_element_types_f                pet
   , pay_element_entries_f              pee2
   , hr_organization_units              hou /*bug fix 4551283*/
   /* Added for Pension changes */
   , pay_input_values_f			pivf
   , pay_element_entry_values_f		peev1
   , pay_element_entry_values_f		peev2
WHERE  ppa.payroll_action_id = pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
AND    paa.payroll_action_id = ppa.payroll_action_id
AND    pee1.assignment_id = paa.assignment_id
AND    pet.element_name  = 'Pension'
AND    pet.legislation_code ='DK'
AND    pee1.entry_type ='E'
AND    pee1.element_type_id = pet.element_type_id
AND    pee2.assignment_id = paa.assignment_id
AND    pee2.entry_type ='E'
AND    pee2.element_type_id = pet.element_type_id
/* Added for Pension changes -start */
AND  pivf.element_type_id   = pet.element_type_id
AND  pivf.name= 'Third Party Payee'
AND  ppa.effective_date BETWEEN pivf.effective_start_date AND pivf.effective_end_date
AND  peev1.input_value_id = pivf.input_value_id
AND  peev1.element_entry_id = pee1.element_entry_id
AND  peev1.screen_entry_value = PAY_DK_PAYMENT_PROCESS_PKG.get_pension_provider(pay_magtape_generic.get_parameter_value('TRANSFER_RECEIVER_NAME'))
AND  peev2.input_value_id = pivf.input_value_id
AND  peev2.element_entry_id = pee2.element_entry_id
AND  peev2.screen_entry_value = PAY_DK_PAYMENT_PROCESS_PKG.get_pension_provider(pay_magtape_generic.get_parameter_value('TRANSFER_RECEIVER_NAME'))
/* Added for Pension changes -end */
AND    paa.assignment_id = pay_magtape_generic.get_parameter_value('TRANSFER_ASSIGNMENT_ID')
AND    ppa.effective_date BETWEEN pet.effective_start_date and pet.effective_end_date
AND    ppa.effective_date BETWEEN pee1.effective_start_date and pee1.effective_end_date
AND    pee1.effective_start_date >= ppa.start_date
AND    pay_magtape_generic.get_parameter_value('TRANSFER_INFO_TYPE') NOT IN (300, 400, 800, 900)
AND    hou.organization_id = pay_magtape_generic.get_parameter_value('TRANSFER_LE_ID') /*bug fix 4551283*/
AND    ppa.effective_date  BETWEEN  hou.date_from AND nvl(hou.date_to, ppa.effective_date) /*bug fix 4551283*/
GROUP BY pee1.effective_start_date,paa.assignment_id,pee1.element_entry_id,pet.element_type_id,hou.name;


/* Modified for Pension changes */
CURSOR get_info_record_02_details IS
SELECT   'TRANSFER_PAY_APPL_DATE=P'
       , to_char(min(pee2.effective_start_date) ,'YYYYMMDD')
       , 'TRANSFER_PENSION_START_DATE=P'
       , to_char(pee1.effective_start_date ,'YYYYMMDD')
       , 'ASSIGNMENT_ID=C'
       , paa.ASSIGNMENT_ID
       , 'DATE_EARNED=C'
       , fnd_date.date_to_canonical(PAY_DK_PAYMENT_PROCESS_PKG.get_date_earned_context(paa.ASSIGNMENT_ID))
       , 'ASSIGNMENT_ACTION_ID=C'
       , PAY_DK_PAYMENT_PROCESS_PKG.get_ass_action_context(paa.ASSIGNMENT_ID)
       , 'PAYROLL_ACTION_ID=C'
       , pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
       /* Added for bug fix 5563150 */
       , 'ELEMENT_ENTRY_ID=P'
       , to_char(pee1.element_entry_id)
       , 'ELEMENT_TYPE_ID=P'
       , to_char(pet.element_type_id)
FROM pay_payroll_actions		ppa
   , pay_assignment_actions		paa
   , pay_element_entries_f              pee1
   , pay_element_types_f                pet
   , pay_element_entries_f              pee2
   /* Added for Pension changes */
   , pay_input_values_f			pivf
   , pay_element_entry_values_f		peev1
   , pay_element_entry_values_f		peev2
WHERE  ppa.payroll_action_id =  pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
AND    paa.payroll_action_id = ppa.payroll_action_id
AND    pee1.assignment_id = paa.assignment_id
AND    pet.element_name  = 'Pension'
AND    pet.legislation_code ='DK'
AND    pee1.entry_type ='E'
AND    pee1.element_type_id = pet.element_type_id
AND    pee2.assignment_id = paa.assignment_id
AND    pee2.entry_type ='E'
AND    pee2.element_type_id = pet.element_type_id
/* Added for Pension changes -start */
AND  pivf.element_type_id   = pet.element_type_id
AND  pivf.name= 'Third Party Payee'
AND  ppa.effective_date BETWEEN pivf.effective_start_date AND pivf.effective_end_date
AND  peev1.input_value_id = pivf.input_value_id
AND  peev1.element_entry_id = pee1.element_entry_id
AND  peev1.screen_entry_value = PAY_DK_PAYMENT_PROCESS_PKG.get_pension_provider(pay_magtape_generic.get_parameter_value('TRANSFER_RECEIVER_NAME'))
AND  peev2.input_value_id = pivf.input_value_id
AND  peev2.element_entry_id = pee2.element_entry_id
AND  peev2.screen_entry_value = PAY_DK_PAYMENT_PROCESS_PKG.get_pension_provider(pay_magtape_generic.get_parameter_value('TRANSFER_RECEIVER_NAME'))
/* Added for Pension changes -end */
AND    paa.assignment_id = pay_magtape_generic.get_parameter_value('TRANSFER_ASSIGNMENT_ID')
AND    pay_magtape_generic.get_parameter_value('TRANSFER_INFO_TYPE') NOT IN (300, 400, 800, 900)
AND    ppa.effective_date BETWEEN pet.effective_start_date and pet.effective_end_date
AND    ppa.effective_date BETWEEN pee1.effective_start_date and pee1.effective_end_date
GROUP BY pee1.effective_start_date,paa.assignment_id,pee1.element_entry_id,pet.element_type_id;


/* Modified for Pension changes */
CURSOR get_info_record_03_details IS
SELECT   'TRANSFER_PAY_APPL_DATE=P'
       , to_char(min(pee2.effective_start_date),'YYYYMMDD')
       , 'TRANSFER_PENSION_START_DATE=P'
       , to_char(pee1.effective_start_date ,'YYYYMMDD')
       , 'ASSIGNMENT_ACTION_ID=C'
       , PAY_DK_PAYMENT_PROCESS_PKG.get_ass_action_context(paa.ASSIGNMENT_ID)
       , 'ASSIGNMENT_ID=C'
       , paa.ASSIGNMENT_ID
       ,'DATE_EARNED=C'
       , fnd_date.date_to_canonical(PAY_DK_PAYMENT_PROCESS_PKG.get_date_earned_context(paa.ASSIGNMENT_ID))
       , 'PAYROLL_ACTION_ID=C'
       , pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
FROM pay_payroll_actions		ppa
   , pay_assignment_actions		paa
   , pay_element_entries_f              pee1
   , pay_element_types_f                pet
   , pay_element_entries_f              pee2
   /* Added for Pension changes */
   , pay_input_values_f			pivf
   , pay_element_entry_values_f		peev1
   , pay_element_entry_values_f		peev2
WHERE  ppa.payroll_action_id =  pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
AND    paa.payroll_action_id = ppa.payroll_action_id
AND    pee1.assignment_id = paa.assignment_id
AND    pet.element_name  = 'Pension'
AND    pet.legislation_code ='DK'
AND    pee1.entry_type ='E'
AND    pee1.element_type_id = pet.element_type_id
AND    pee2.assignment_id = paa.assignment_id
AND    pee2.entry_type ='E'
AND    pee2.element_type_id = pet.element_type_id
/* Added for Pension changes -start */
AND  pivf.element_type_id   = pet.element_type_id
AND  pivf.name= 'Third Party Payee'
AND  ppa.effective_date BETWEEN pivf.effective_start_date AND pivf.effective_end_date
AND  peev1.input_value_id = pivf.input_value_id
AND  peev1.element_entry_id = pee1.element_entry_id
AND  peev1.screen_entry_value = PAY_DK_PAYMENT_PROCESS_PKG.get_pension_provider(pay_magtape_generic.get_parameter_value('TRANSFER_RECEIVER_NAME'))
AND  peev2.input_value_id = pivf.input_value_id
AND  peev2.element_entry_id = pee2.element_entry_id
AND  peev2.screen_entry_value = PAY_DK_PAYMENT_PROCESS_PKG.get_pension_provider(pay_magtape_generic.get_parameter_value('TRANSFER_RECEIVER_NAME'))
/* Added for Pension changes -end */
AND    pee2.effective_start_date < ppa.start_date
AND    paa.assignment_id = pay_magtape_generic.get_parameter_value('TRANSFER_ASSIGNMENT_ID')
AND    pay_magtape_generic.get_parameter_value('TRANSFER_INFO_TYPE') NOT IN (300, 400, 800, 900)
AND    ppa.effective_date BETWEEN pet.effective_start_date and pet.effective_end_date
AND    ppa.effective_date BETWEEN pee1.effective_start_date and pee1.effective_end_date
GROUP BY pee1.effective_start_date,paa.assignment_id,pee1.element_entry_id,pet.element_type_id;


/* Modified for Pension changes to restrict to a particular Pension Provider*/
CURSOR get_info_record_04_details IS
SELECT 'RETRO_EMPLOYEE_CONTR1=P'
     , nvl(col1.RETRO_EMPLOYEE_CONTR,0)
     , 'RETRO_EMPLOYER_CONTR1=P'
     , nvl(col1.RETRO_EMPLOYER_CONTR,0)
     , 'START_DATE1=P'
     , nvl(to_char(col1.START_DATE,'YYYYMMDD'),0)
     , 'END_DATE1=P'
     , nvl(to_char(col1.END_DATE,'YYYYMMDD'),0)
     , 'RETRO_EMPLOYEE_CONTR2=P'
     , nvl(col2.RETRO_EMPLOYEE_CONTR,0)
     , 'RETRO_EMPLOYER_CONTR2=P'
     , nvl(col2.RETRO_EMPLOYER_CONTR,0)
     , 'START_DATE2=P'
     , nvl(to_char(col2.START_DATE,'YYYYMMDD'),0)
     , 'END_DATE2=P'
     , nvl(to_char(col2.END_DATE,'YYYYMMDD'),0)
     , 'RETRO_EMPLOYEE_CONTR3=P'
     , nvl(col3.RETRO_EMPLOYEE_CONTR,0)
     , 'RETRO_EMPLOYER_CONTR3=P'
     , nvl(col3.RETRO_EMPLOYER_CONTR,0)
     , 'START_DATE3=P'
     , nvl(to_char(col3.START_DATE,'YYYYMMDD'),0)
     , 'END_DATE3=P'
     , nvl(to_char(col3.END_DATE,'YYYYMMDD'),0)
FROM	(SELECT		ROWNUM count
		      , RETRO_EMPLOYEE_CONTR
		      , RETRO_EMPLOYER_CONTR
		      , START_DATE
		      , END_DATE
	 FROM   (SELECT	prrv1.RESULT_VALUE       RETRO_EMPLOYEE_CONTR
		      , prrv2.RESULT_VALUE       RETRO_EMPLOYER_CONTR
		      , prr1.start_date          START_DATE
		      , prr1.end_date            END_DATE
		      , ROWNUM                   COUNT1
		 FROM 	pay_run_results			prr1
		       , pay_run_result_values		prrv1
                       , pay_run_result_values          prrv3
		       , pay_element_types_f            pet1
		       , pay_input_values_f		piv1
                       , pay_input_values_f             piv3
		       , pay_run_results		prr2
		       , pay_run_result_values		prrv2
                       , pay_run_result_values          prrv4
		       , pay_element_types_f            pet2
		       , pay_input_values_f		piv2
                       , pay_input_values_f             piv4
		       , pay_assignment_actions         paa
		       , pay_payroll_actions            ppa
		       , pay_element_entries_f          pee
		 WHERE ppa.payroll_action_id = pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
		 AND   prr1.ELEMENT_TYPE_ID = pet1.ELEMENT_TYPE_ID
		 AND   pee.ELEMENT_ENTRY_ID = prr1.ELEMENT_ENTRY_ID
		 AND   prrv1.RUN_RESULT_ID = prr1.RUN_RESULT_ID
                 AND   prrv3.RUN_RESULT_ID = prr1.RUN_RESULT_ID
		 AND   pet1.element_name  = 'Retro Pension'
		 AND   pet1.legislation_code ='DK'
		 AND   piv1.ELEMENT_TYPE_ID = pet1.element_type_id
		 AND   piv1.NAME ='Pay Value'
		 AND   prrv1.input_value_id = piv1.input_value_id
		 AND   piv3.ELEMENT_TYPE_ID = pet1.element_type_id
		 AND   piv3.NAME ='Third Party Payee'
		 AND   prrv3.input_value_id = piv3.input_value_id
		 AND   prrv3.RESULT_VALUE = pay_magtape_generic.get_parameter_value('TRANSFER_ORGANIZATION_ID')
		 AND   prr2.ELEMENT_TYPE_ID =pet2.ELEMENT_TYPE_ID
		 AND   prrv2.RUN_RESULT_ID = prr2.RUN_RESULT_ID
		 AND   prrv4.RUN_RESULT_ID = prr2.RUN_RESULT_ID
		 AND   prrv4.RESULT_VALUE = prrv3.RESULT_VALUE
		 AND   pet2.element_name  = 'Retro Employer Pension'
		 AND   pet2.legislation_code ='DK'
		 AND   piv2.ELEMENT_TYPE_ID = pet2.element_type_id
		 AND   piv2.NAME ='Pay Value'
		 AND   prrv2.input_value_id = piv2.input_value_id
		 AND   piv4.ELEMENT_TYPE_ID = pet2.element_type_id
		 AND   piv4.NAME ='Third Party Payee'
		 AND   prrv4.input_value_id = piv4.input_value_id
		 AND   prrv4.RESULT_VALUE = pay_magtape_generic.get_parameter_value('TRANSFER_ORGANIZATION_ID')
		 AND   prr1.assignment_action_id = paa.assignment_action_id
		 AND   prr1.assignment_action_id=prr2.assignment_action_id
		 AND   prr1.start_date = prr2.start_date
		 AND   prr1.end_date = prr2.end_date
		 AND   pay_magtape_generic.get_parameter_value('TRANSFER_INFO_TYPE') NOT IN (300, 400, 800, 900)
		 AND   paa.assignment_id = pay_magtape_generic.get_parameter_value('TRANSFER_ASSIGNMENT_ID')
		 AND   ppa.effective_date BETWEEN pet1.effective_start_date and pet1.effective_end_date
		 AND   ppa.effective_date BETWEEN pet2.effective_start_date and pet2.effective_end_date
		 AND   ppa.effective_date BETWEEN piv1.effective_start_date and piv1.effective_end_date
		 AND   ppa.effective_date BETWEEN piv2.effective_start_date and piv2.effective_end_date
		 AND   ppa.effective_date BETWEEN pee.effective_start_date  and pee.effective_end_date
		 AND   ppa.effective_date BETWEEN piv3.effective_start_date and piv3.effective_end_date
		 AND   ppa.effective_date BETWEEN piv4.effective_start_date and piv4.effective_end_date
		ORDER BY prr1.run_result_id)
	 WHERE mod(count1, 3) = 1) col1,
	(SELECT		ROWNUM count
		      , RETRO_EMPLOYEE_CONTR
		      , RETRO_EMPLOYER_CONTR
		      , START_DATE
		      , END_DATE
	 FROM   (SELECT	prrv1.RESULT_VALUE       RETRO_EMPLOYEE_CONTR
		      , prrv2.RESULT_VALUE       RETRO_EMPLOYER_CONTR
		      , prr1.start_date          START_DATE
		      , prr1.end_date            END_DATE
		      , ROWNUM                   COUNT1
		 FROM 	pay_run_results			prr1
		       , pay_run_result_values		prrv1
                       , pay_run_result_values          prrv3
		       , pay_element_types_f            pet1
		       , pay_input_values_f		piv1
                       , pay_input_values_f             piv3
		       , pay_run_results		prr2
		       , pay_run_result_values		prrv2
                       , pay_run_result_values          prrv4
		       , pay_element_types_f            pet2
		       , pay_input_values_f		piv2
                       , pay_input_values_f             piv4
		       , pay_assignment_actions         paa
		       , pay_payroll_actions            ppa
		       , pay_element_entries_f          pee
		 WHERE ppa.payroll_action_id = pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
		 AND   prr1.ELEMENT_TYPE_ID = pet1.ELEMENT_TYPE_ID
		 AND   pee.ELEMENT_ENTRY_ID = prr1.ELEMENT_ENTRY_ID
		 AND   prrv1.RUN_RESULT_ID = prr1.RUN_RESULT_ID
                 AND   prrv3.RUN_RESULT_ID = prr1.RUN_RESULT_ID
		 AND   pet1.element_name  = 'Retro Pension'
		 AND   pet1.legislation_code ='DK'
		 AND   piv1.ELEMENT_TYPE_ID = pet1.element_type_id
		 AND   piv1.NAME ='Pay Value'
		 AND   prrv1.input_value_id = piv1.input_value_id
		 AND   piv3.ELEMENT_TYPE_ID = pet1.element_type_id
		 AND   piv3.NAME ='Third Party Payee'
		 AND   prrv3.input_value_id = piv3.input_value_id
		 AND   prrv3.RESULT_VALUE = pay_magtape_generic.get_parameter_value('TRANSFER_ORGANIZATION_ID')
		 AND   prr2.ELEMENT_TYPE_ID =pet2.ELEMENT_TYPE_ID
		 AND   prrv2.RUN_RESULT_ID = prr2.RUN_RESULT_ID
		 AND   prrv4.RUN_RESULT_ID = prr2.RUN_RESULT_ID
		 AND   prrv4.RESULT_VALUE = prrv3.RESULT_VALUE
		 AND   pet2.element_name  = 'Retro Employer Pension'
		 AND   pet2.legislation_code ='DK'
		 AND   piv2.ELEMENT_TYPE_ID = pet2.element_type_id
		 AND   piv2.NAME ='Pay Value'
		 AND   prrv2.input_value_id = piv2.input_value_id
		 AND   piv4.ELEMENT_TYPE_ID = pet2.element_type_id
		 AND   piv4.NAME ='Third Party Payee'
		 AND   prrv4.input_value_id = piv4.input_value_id
		 AND   prrv4.RESULT_VALUE = pay_magtape_generic.get_parameter_value('TRANSFER_ORGANIZATION_ID')
		 AND   prr1.assignment_action_id = paa.assignment_action_id
		 AND   prr1.assignment_action_id=prr2.assignment_action_id
		 AND   prr1.start_date = prr2.start_date
		 AND   prr1.end_date = prr2.end_date
		 AND   pay_magtape_generic.get_parameter_value('TRANSFER_INFO_TYPE') NOT IN (300, 400, 800, 900)
		 AND   paa.assignment_id = pay_magtape_generic.get_parameter_value('TRANSFER_ASSIGNMENT_ID')
		 AND   ppa.effective_date BETWEEN pet1.effective_start_date and pet1.effective_end_date
		 AND   ppa.effective_date BETWEEN pet2.effective_start_date and pet2.effective_end_date
		 AND   ppa.effective_date BETWEEN piv1.effective_start_date and piv1.effective_end_date
		 AND   ppa.effective_date BETWEEN piv2.effective_start_date and piv2.effective_end_date
		 AND   ppa.effective_date BETWEEN pee.effective_start_date  and pee.effective_end_date
		 AND   ppa.effective_date BETWEEN piv3.effective_start_date and piv3.effective_end_date
		 AND   ppa.effective_date BETWEEN piv4.effective_start_date and piv4.effective_end_date
		ORDER BY prr1.run_result_id)
	 WHERE mod(count1, 3) = 2) col2,
	(SELECT		ROWNUM count
		      , RETRO_EMPLOYEE_CONTR
		      , RETRO_EMPLOYER_CONTR
		      , START_DATE
		      , END_DATE
	 FROM   (SELECT	prrv1.RESULT_VALUE       RETRO_EMPLOYEE_CONTR
		      , prrv2.RESULT_VALUE       RETRO_EMPLOYER_CONTR
		      , prr1.start_date          START_DATE
		      , prr1.end_date            END_DATE
		      , ROWNUM                   COUNT1
		 FROM 	pay_run_results			prr1
		       , pay_run_result_values		prrv1
                       , pay_run_result_values          prrv3
		       , pay_element_types_f            pet1
		       , pay_input_values_f		piv1
                       , pay_input_values_f             piv3
		       , pay_run_results		prr2
		       , pay_run_result_values		prrv2
                       , pay_run_result_values          prrv4
		       , pay_element_types_f            pet2
		       , pay_input_values_f		piv2
                       , pay_input_values_f             piv4
		       , pay_assignment_actions         paa
		       , pay_payroll_actions            ppa
		       , pay_element_entries_f          pee
		 WHERE ppa.payroll_action_id = pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
		 AND   prr1.ELEMENT_TYPE_ID = pet1.ELEMENT_TYPE_ID
		 AND   pee.ELEMENT_ENTRY_ID = prr1.ELEMENT_ENTRY_ID
		 AND   prrv1.RUN_RESULT_ID = prr1.RUN_RESULT_ID
                 AND   prrv3.RUN_RESULT_ID = prr1.RUN_RESULT_ID
		 AND   pet1.element_name  = 'Retro Pension'
		 AND   pet1.legislation_code ='DK'
		 AND   piv1.ELEMENT_TYPE_ID = pet1.element_type_id
		 AND   piv1.NAME ='Pay Value'
		 AND   prrv1.input_value_id = piv1.input_value_id
		 AND   piv3.ELEMENT_TYPE_ID = pet1.element_type_id
		 AND   piv3.NAME ='Third Party Payee'
		 AND   prrv3.input_value_id = piv3.input_value_id
		 AND   prrv3.RESULT_VALUE = pay_magtape_generic.get_parameter_value('TRANSFER_ORGANIZATION_ID')
		 AND   prr2.ELEMENT_TYPE_ID =pet2.ELEMENT_TYPE_ID
		 AND   prrv2.RUN_RESULT_ID = prr2.RUN_RESULT_ID
		 AND   prrv4.RUN_RESULT_ID = prr2.RUN_RESULT_ID
		 AND   prrv4.RESULT_VALUE = prrv3.RESULT_VALUE
		 AND   pet2.element_name  = 'Retro Employer Pension'
		 AND   pet2.legislation_code ='DK'
		 AND   piv2.ELEMENT_TYPE_ID = pet2.element_type_id
		 AND   piv2.NAME ='Pay Value'
		 AND   prrv2.input_value_id = piv2.input_value_id
		 AND   piv4.ELEMENT_TYPE_ID = pet2.element_type_id
		 AND   piv4.NAME ='Third Party Payee'
		 AND   prrv4.input_value_id = piv4.input_value_id
		 AND   prrv4.RESULT_VALUE = pay_magtape_generic.get_parameter_value('TRANSFER_ORGANIZATION_ID')
		 AND   prr1.assignment_action_id = paa.assignment_action_id
		 AND   prr1.assignment_action_id=prr2.assignment_action_id
		 AND   prr1.start_date = prr2.start_date
		 AND   prr1.end_date = prr2.end_date
		 AND   pay_magtape_generic.get_parameter_value('TRANSFER_INFO_TYPE') NOT IN (300, 400, 800, 900)
		 AND   paa.assignment_id = pay_magtape_generic.get_parameter_value('TRANSFER_ASSIGNMENT_ID')
		 AND   ppa.effective_date BETWEEN pet1.effective_start_date and pet1.effective_end_date
		 AND   ppa.effective_date BETWEEN pet2.effective_start_date and pet2.effective_end_date
		 AND   ppa.effective_date BETWEEN piv1.effective_start_date and piv1.effective_end_date
		 AND   ppa.effective_date BETWEEN piv2.effective_start_date and piv2.effective_end_date
		 AND   ppa.effective_date BETWEEN pee.effective_start_date  and pee.effective_end_date
		 AND   ppa.effective_date BETWEEN piv3.effective_start_date and piv3.effective_end_date
		 AND   ppa.effective_date BETWEEN piv4.effective_start_date and piv4.effective_end_date
		 ORDER BY prr1.run_result_id)
	 WHERE mod(count1, 3) = 0) col3
WHERE    col1.count = col2.count (+)
AND      col2.count = col3.count (+);



CURSOR get_info_record_05_details IS
/* Restricted input to only 32 characters for bug fix 4555311 */
/* Modified for bug fix 4593682 to select addresses for all employees, even if they do not have an address */
SELECT   'ADDRESS_1=P'
       ,  rpad(nvl(pad.address_line1,' '),32)
       , 'ADDRESS_2=P'
       ,  rpad(nvl(pad.address_line2,' ') /*||' '*/,32)
       , 'CITY_NAME=P'
       ,  nvl(substr(PAY_DK_PAYMENT_PROCESS_PKG.get_lookup_meaning('DK_POSTCODE_TOWN',pad.postal_code),5),' ') /*||' '*/
       , 'POST_CODE=P'
       , nvl(pad.postal_code,0)
FROM  per_addresses   pad
/* Modified for bug fix 4593682 */
    , per_all_people_f  pap
    , pay_payroll_actions ppa
WHERE  pad.person_id (+)= pap.person_id
AND pad.primary_flag = 'Y' --9403004
AND ppa.effective_date  BETWEEN nvl(pad.date_from,ppa.effective_date) AND nvl(pad.date_to,to_date('31-12-4712','dd-mm-rrrr')) --9403004
    /* pad.person_id = pay_magtape_generic.get_parameter_value('TRANSFER_PERSON_ID') */
AND    pap.person_id = pay_magtape_generic.get_parameter_value('TRANSFER_PERSON_ID')
AND    pay_magtape_generic.get_parameter_value('TRANSFER_INFO_TYPE') NOT IN (300, 400, 800, 900)
      /* Modified for bug fix 7664874 */
AND   ppa.payroll_action_id=pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
AND   ppa.effective_date BETWEEN pap.effective_start_date AND pap.effective_end_date;

END PAY_DK_PAYMENT_PROCESS_PKG;

/
